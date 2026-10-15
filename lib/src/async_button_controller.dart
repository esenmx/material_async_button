part of '../material_async_button.dart';

/// A read-only [ValueListenable] of an [AsyncButton]'s loading state (`true`
/// while `onPressed` is in flight), plus imperative [trigger] / [reset].
///
/// Pipe it into a `ValueListenableBuilder<bool>` for reactive UI outside the
/// button. The loading [value] is observe-only — drive the button with
/// [trigger] / [reset]; there is no public setter, so external code can't
/// desync the displayed state from the running future.
///
/// Use it to:
///   - trigger the attached `onPressed` from outside the button
///     (e.g. a form keyboard "Done" action),
///   - reset to idle,
///   - read [value] / [canTrigger] to gate surrounding UI.
///
/// Dispose like any [ChangeNotifier].
class AsyncButtonController extends ChangeNotifier
    implements ValueListenable<bool> {
  /// Creates a controller in the idle (not-loading) state.
  new();

  bool _isLoading = false;

  /// Whether `onPressed` is currently in flight. Observe-only — mutated by
  /// [trigger] / [reset], never from outside.
  @override
  bool get value => _isLoading;

  /// True when [trigger] would actually run the attached callback (not loading
  /// and a callback is attached). Use it to gate surrounding UI.
  bool get canTrigger => !_isLoading && _onPressed != null;

  // Widget-owned configuration. Refreshed whenever the bound [AsyncButton]
  // updates.
  AsyncCallback? _onPressed;

  bool _isDisposed = false;

  // Run token: a run settles the loading state only while it is still the
  // latest — reset() bumps it, so an abandoned run's completion is ignored.
  int _run = 0;
  _Run? _inFlight;
  Object? _owner;
  Duration _minLoadingDuration = Duration.zero;

  void _cancelFloor() => _inFlight?.cancelFloor();

  // Last binder wins; returns the owner it displaced, if any. A multi-child
  // parent inflates a replacement button before it deactivates the old one,
  // so a double mount is only detectable once the frame settles — AsyncButton
  // checks the displaced owner then.
  Object? _bind(Object owner, {required AsyncCallback? onPressed}) {
    final displaced = identical(_owner, owner) ? null : _owner;
    _owner = owner;
    _onPressed = onPressed;
    return displaced;
  }

  void _unbind(Object owner) {
    if (identical(_owner, owner)) {
      _owner = null;
      _onPressed = null;
    }
  }

  /// Run the attached `onPressed`.
  ///
  /// While a run is in flight, starts nothing and returns that run's Future:
  /// awaiting it waits for the run (including its `minLoadingDuration`) and
  /// sees its error, and a dropped tap Future reports nothing extra. A run
  /// abandoned by [reset] stays the joiner's Future. While idle and the bound
  /// button is disabled (`enabled: false` or `onPressed: null`), returns a
  /// completed Future without running anything; [canTrigger] reports both.
  ///
  /// Completes with a [StateError] after [dispose], or when no [AsyncButton]
  /// is bound (never passed to one, or its button unmounted or switched to
  /// another controller).
  ///
  /// If `onPressed` throws, the button returns to idle and the returned Future
  /// completes with the error; a tap's error reaches the surrounding zone (else
  /// `PlatformDispatcher.instance.onError`). A button is not the place to
  /// surface errors, so handle them in your state management.
  Future<void> trigger() {
    if (_isDisposed) {
      return Future.error(_disposedError('trigger'));
    }
    if (_owner == null) {
      return Future.error(
        StateError(
          'AsyncButtonController.trigger() called with no AsyncButton bound.',
        ),
      );
    }
    if (_inFlight case final inFlight?) {
      return inFlight.future;
    }
    final onPressed = _onPressed;
    if (_isLoading || onPressed == null) {
      return Future.value();
    }
    return _start(onPressed);
  }

  Future<void> _start(AsyncCallback onPressed) async {
    final run = ++_run;
    _setLoading(true);
    final inFlight = _Run(onPressed, _minLoadingDuration);
    _inFlight = inFlight;
    try {
      await inFlight.future;
    } finally {
      // Settle whether onPressed completed or threw; a throw propagates
      // through finally (trigger rethrows) so the error reaches the caller, or
      // for a tap the surrounding zone / PlatformDispatcher.instance.onError.
      _settle(run);
    }
  }

  void _settle(int run) {
    if (run == _run) {
      _inFlight = null;
      _setLoading(false);
    }
  }

  /// Force the button back to idle and abandon the in-flight run.
  ///
  /// The button re-arms at once — an escape hatch for a hung future. The
  /// abandoned run's completion no longer touches the loading state, and a tap
  /// after [reset] is a deliberate new run. Throws a [StateError] after
  /// [dispose].
  void reset() {
    _checkNotDisposed('reset');
    _run++;
    _cancelFloor();
    _inFlight = null;
    _setLoading(false);
  }

  void _checkNotDisposed(String method) {
    if (_isDisposed) {
      throw _disposedError(method);
    }
  }

  StateError _disposedError(String method) =>
      StateError('AsyncButtonController.$method() called after dispose().');

  /// The only mutation point of [value]. Dedupes (like the former
  /// [ValueNotifier]) so listeners fire only on a real change, and never
  /// notifies after [dispose].
  void _setLoading(bool value) {
    if (_isDisposed || _isLoading == value) {
      return;
    }
    _isLoading = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _cancelFloor();
    _onPressed = null;
    _owner = null;
    super.dispose();
  }
}

// An in-flight onPressed and its minLoadingDuration floor, owned by the
// controller that started it.
final class _Run {
  // The floor timer starts before onPressed runs: the floor counts from the
  // tap. onPressed runs inside the try so a synchronous throw still awaits the
  // floor.
  factory(AsyncCallback onPressed, Duration floor) {
    if (floor <= Duration.zero) {
      return _Run._(_guard(onPressed, null), null, null);
    }
    final completer = Completer<void>();
    final timer = Timer(floor, () {
      if (!completer.isCompleted) {
        completer.complete();
      }
    });
    return _Run._(_guard(onPressed, completer.future), timer, completer);
  }

  new _(this.future, this._floorTimer, this._floor);

  final Future<void> future;
  final Timer? _floorTimer;
  final Completer<void>? _floor;

  void cancelFloor() {
    _floorTimer?.cancel();
    if (_floor case final floor? when !floor.isCompleted) {
      floor.complete();
    }
  }

  static Future<void> _guard(
    AsyncCallback onPressed,
    Future<void>? floor,
  ) async {
    try {
      await onPressed();
    } finally {
      if (floor != null) {
        await floor;
      }
    }
  }
}
