part of '../material_async_button.dart';

/// [ValueNotifier] of [AsyncButtonStatus] for an [AsyncButton] or any of
/// the Material wrappers. Pipe it directly into a
/// `ValueListenableBuilder<AsyncButtonStatus>` for reactive UI outside the
/// button — pattern-match the [value] for the error payload on error.
///
/// Use it to:
///   - trigger the attached `onPressed` from outside the button
///     (e.g. a form keyboard "Done" action),
///   - reset to idle,
///   - mark the button as failed from an out-of-band source
///     (e.g. a WebSocket message) via [invalidate],
///   - mark the button as succeeded from outside via [markSuccess].
///
/// Prefer [reset], [invalidate], [markSuccess], or [trigger] over assigning
/// to [value] directly — the imperative methods keep the display-duration
/// timers and cooldown machinery coherent.
///
/// Dispose like any [ChangeNotifier].
class AsyncButtonController extends ValueNotifier<AsyncButtonStatus> {
  AsyncButtonController([super.initial = const .idle()]);

  bool get isIdle => value is AsyncButtonStatusIdle;
  bool get isLoading => value is AsyncButtonStatusLoading;
  bool get isSuccess => value is AsyncButtonStatusSuccess;
  bool get isError => value is AsyncButtonStatusError;

  @visibleForTesting
  bool get isInCooldown => _cooldownActive;

  /// True when [trigger] would actually run the attached callback.
  bool get canTrigger => isIdle && !_cooldownActive && _onPressed != null;

  // Widget-owned configuration. Refreshed on every build.
  AsyncCallback? _onPressed;
  Duration _successDuration = .zero;
  Duration _errorDuration = .zero;
  Duration _cooldownDuration = .zero;
  bool _rethrowErrors = false;

  Timer? _timer;
  bool _cooldownActive = false;
  bool _disposed = false;

  /// Internal hook used by [AsyncButton] to push the host widget's current
  /// configuration into the controller on every build. Calling this from
  /// outside the package is supported (tests drive a detached controller
  /// this way), but the values you set will be overwritten on the next
  /// build if the controller is also bound to an [AsyncButton].
  void attach({
    required AsyncCallback? onPressed,
    required Duration successDuration,
    required Duration errorDuration,
    required Duration cooldownDuration,
    required bool rethrowErrors,
  }) {
    _onPressed = onPressed;
    _successDuration = successDuration;
    _errorDuration = errorDuration;
    _cooldownDuration = cooldownDuration;
    _rethrowErrors = rethrowErrors;
  }

  /// Run the attached `onPressed`. No-op if already loading, in cooldown,
  /// or if no callback is attached.
  Future<void> trigger() async {
    if (!canTrigger) {
      return;
    }
    _cancelTimer();
    value = const .loading();
    try {
      await _onPressed!();
      // External resets (e.g. controller.reset()) may have moved us off
      // loading mid-await. Only continue the success cycle if we're still
      // the one driving.
      if (!_disposed && value is AsyncButtonStatusLoading) {
        value = const .success();
        _scheduleReturnToIdle(_successDuration);
      }
    } catch (error, stack) {
      if (!_disposed && value is AsyncButtonStatusLoading) {
        value = .error(error, stack);
        _scheduleReturnToIdle(_errorDuration);
      }
      if (_rethrowErrors) {
        rethrow;
      }
    }
  }

  /// Force the button back to idle. Cancels any pending display/cooldown.
  void reset() {
    _cancelTimer();
    _cooldownActive = false;
    value = const .idle();
  }

  /// Force the error status from outside. Runs the same display cycle as
  /// if `onPressed` had thrown.
  void invalidate(Object error, [StackTrace? stackTrace]) {
    _cancelTimer();
    value = .error(error, stackTrace);
    _scheduleReturnToIdle(_errorDuration);
  }

  /// Force the success status from outside. Runs the same display cycle as
  /// a completed `onPressed`.
  void markSuccess() {
    _cancelTimer();
    value = const .success();
    _scheduleReturnToIdle(_successDuration);
  }

  void _cancelTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void _scheduleReturnToIdle(Duration displayDuration) {
    if (displayDuration <= .zero) {
      _enterIdleThenCooldown();
      return;
    }
    _timer = Timer(displayDuration, _enterIdleThenCooldown);
  }

  void _enterIdleThenCooldown() {
    if (_disposed) {
      return;
    }
    _timer = null;
    value = const .idle();
    if (_cooldownDuration > .zero) {
      _cooldownActive = true;
      notifyListeners();
      _timer = Timer(_cooldownDuration, () {
        if (_disposed) {
          return;
        }
        _timer = null;
        _cooldownActive = false;
        notifyListeners();
      });
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _cancelTimer();
    super.dispose();
  }
}
