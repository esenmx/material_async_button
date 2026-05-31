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
///   - read [isLoading] / [canTrigger] to gate surrounding UI.
///
/// Dispose like any [ChangeNotifier].
class AsyncButtonController extends ChangeNotifier
    implements ValueListenable<bool> {
  /// Creates a controller in the idle (not-loading) state.
  AsyncButtonController();

  bool _isLoading = false;

  /// Whether `onPressed` is currently in flight. Observe-only — mutated by
  /// [trigger] / [reset], never from outside.
  @override
  bool get value => _isLoading;

  /// Alias for [value] — whether `onPressed` is currently in flight.
  bool get isLoading => _isLoading;

  /// True when [trigger] would actually run the attached callback (not loading
  /// and a callback is attached). Use it to gate surrounding UI.
  bool get canTrigger => !_isLoading && _onPressed != null;

  // Widget-owned configuration. Refreshed whenever the bound [AsyncButton]
  // updates.
  AsyncCallback? _onPressed;

  bool _isDisposed = false;

  /// Binds the host widget's current `onPressed` to the controller.
  ///
  /// [AsyncButton] calls this on every update via same-library access; it is
  /// exposed only so tests can drive a detached controller. Not part of the
  /// consumer-facing API.
  @visibleForTesting
  // A named binding hook, not a property setter — the widget refreshes it on
  // every rebuild, so this stays a method.
  // ignore: use_setters_to_change_properties
  void attach({required AsyncCallback? onPressed}) {
    _onPressed = onPressed;
  }

  /// Run the attached `onPressed`. No-op if already loading or if no callback
  /// is attached.
  ///
  /// If `onPressed` throws, the button returns to idle and the error
  /// **re-propagates** — a button is not the place to surface errors, so handle
  /// them in your state management.
  Future<void> trigger() async {
    if (!canTrigger) {
      return;
    }
    _setLoading(true);
    try {
      await _onPressed!();
    } finally {
      // Reset the UI whether onPressed completed or threw; a throw propagates
      // through finally (trigger rethrows) so the error reaches the surrounding
      // zone / FlutterError.onError.
      _setLoading(false);
    }
  }

  /// Force the button back to idle.
  void reset() {
    _setLoading(false);
  }

  /// Single mutation point. Dedupes (like the former [ValueNotifier]) so
  /// listeners fire only on a real change, and never notifies after [dispose].
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
    super.dispose();
  }
}
