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
  // latest — reset() and adoption bump it, so an abandoned run's completion
  // is ignored.
  int _run = 0;
  Future<void>? _inFlight;
  Object? _owner;
  Duration _minLoadingDuration = Duration.zero;

  // Last binder wins; returns the owner it displaced, if any. A multi-child
  // parent inflates a replacement button before it deactivates the old one,
  // so a double mount is only detectable once the frame settles — AsyncButton
  // checks the displaced owner then (debug only).
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

  /// Sets the `onPressed` that [trigger] runs, with no owning button.
  ///
  /// Exposed only so tests can drive a detached controller; [AsyncButton]
  /// binds through a library-private, owner-checked hook. Not part of the
  /// consumer-facing API.
  @visibleForTesting
  // A named binding hook, not a property setter.
  // ignore: use_setters_to_change_properties
  void attach({required AsyncCallback? onPressed}) {
    _onPressed = onPressed;
  }

  /// Run the attached `onPressed`. No-op if already loading or if no callback
  /// is attached.
  ///
  /// If `onPressed` throws, the button returns to idle and the returned Future
  /// completes with the error; a tap's error reaches the surrounding zone (else
  /// `PlatformDispatcher.instance.onError`). A button is not the place to
  /// surface errors, so handle them in your state management.
  Future<void> trigger() async {
    assert(
      ChangeNotifier.debugAssertNotDisposed(this),
      'trigger() after dispose()',
    );
    final onPressed = _onPressed;
    if (_isLoading || onPressed == null) {
      return;
    }
    final run = ++_run;
    _setLoading(true);
    final pending = _withFloor(onPressed, _minLoadingDuration);
    _inFlight = pending;
    try {
      await pending;
    } finally {
      // Settle whether onPressed completed or threw; a throw propagates
      // through finally (trigger rethrows) so the error reaches the caller, or
      // for a tap the surrounding zone / PlatformDispatcher.instance.onError.
      _settle(run);
    }
  }

  // onPressed runs inside the try so a synchronous throw still awaits the
  // floor and settles.
  static Future<void> _withFloor(
    AsyncCallback onPressed,
    Duration floor,
  ) async {
    final minimum = floor > Duration.zero ? Future<void>.delayed(floor) : null;
    try {
      await onPressed();
    } finally {
      if (minimum != null) {
        await minimum;
      }
    }
  }

  // Runs in didUpdateWidget, i.e. during build: notifying now would rebuild
  // listeners outside the adopting button mid-build. The adopting button reads
  // value in its own build; everyone else hears after the frame, unless the
  // run settled or was reset first (those notify on their own).
  void _adopt(Future<void> pending) {
    final run = ++_run;
    _inFlight = pending;
    _isLoading = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isDisposed && run == _run && _isLoading) {
        notifyListeners();
      }
    });
    pending.then<void>(
      (_) => _settle(run),
      onError: (Object _) => _settle(run),
    );
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
  /// after [reset] is a deliberate new run.
  void reset() {
    _run++;
    _inFlight = null;
    _setLoading(false);
  }

  /// Notifying mutation point (only [_adopt] writes silently). Dedupes (like
  /// the former [ValueNotifier]) so listeners fire only on a real change, and
  /// never notifies after [dispose].
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
    _onPressed = null;
    _owner = null;
    super.dispose();
  }
}
