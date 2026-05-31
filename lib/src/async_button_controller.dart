part of '../material_async_button.dart';

/// `ValueNotifier<bool>` of an [AsyncButton]'s loading state (`true` while
/// `onPressed` is in flight). Pipe it into a `ValueListenableBuilder<bool>` for
/// reactive UI outside the button.
///
/// Use it to:
///   - trigger the attached `onPressed` from outside the button
///     (e.g. a form keyboard "Done" action),
///   - reset to idle.
///
/// Dispose like any [ChangeNotifier].
class AsyncButtonController extends ValueNotifier<bool> {
  /// Creates a controller in the idle (not-loading) state.
  AsyncButtonController() : super(false);

  /// Whether `onPressed` is currently in flight.
  bool get isLoading => value;

  /// True when [trigger] would actually run the attached callback.
  bool get canTrigger => !value && _onPressed != null;

  // Widget-owned configuration. Refreshed whenever the bound [AsyncButton]
  // updates.
  AsyncCallback? _onPressed;

  bool _disposed = false;

  /// Binds the host widget's current `onPressed` to the controller.
  /// [AsyncButton] calls this; you can too (tests drive a detached controller
  /// this way), but a bound button overwrites it on its next update.
  // A named binding hook, not a property setter — tests drive this seam.
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
    value = true;
    try {
      await _onPressed!();
    } finally {
      // Reset the UI whether onPressed completed or threw; a throw propagates
      // through finally (trigger rethrows) so the error reaches the surrounding
      // zone / FlutterError.onError.
      if (!_disposed) {
        value = false;
      }
    }
  }

  /// Force the button back to idle.
  void reset() {
    value = false;
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
