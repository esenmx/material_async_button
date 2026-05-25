import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';

import 'async_button_state.dart';

/// Imperative controller for an [AsyncButtonBuilder] or any of the Material
/// wrappers. Listens like a [ValueListenable] of [AsyncButtonState].
///
/// Use it to:
///   - trigger the attached `onPressed` from outside the button
///     (e.g. a form keyboard "Done" action),
///   - reset to idle,
///   - mark the button as errored from an out-of-band source
///     (e.g. a WebSocket message),
///   - mark the button as succeeded from outside.
///
/// Dispose like any [ChangeNotifier].
class AsyncButtonController extends ChangeNotifier
    implements ValueListenable<AsyncButtonState> {
  AsyncButtonController({AsyncButtonState initial = const AsyncButtonState.idle()})
      : _value = initial;

  AsyncButtonState _value;
  @override
  AsyncButtonState get value => _value;

  bool get isIdle => _value is AsyncButtonStateIdle;
  bool get isLoading => _value is AsyncButtonStateLoading;
  bool get isSuccess => _value is AsyncButtonStateSuccess;
  bool get isError => _value is AsyncButtonStateError;

  Object? get error => switch (_value) {
        AsyncButtonStateError(:final error) => error,
        _ => null,
      };

  StackTrace? get stackTrace => switch (_value) {
        AsyncButtonStateError(:final stackTrace) => stackTrace,
        _ => null,
      };

  bool get isInCooldown => _cooldownActive;

  /// True when [trigger] would actually run the attached callback.
  bool get canTrigger => isIdle && !_cooldownActive && _onPressed != null;

  // Widget-owned configuration. Refreshed on every build.
  Future<void> Function()? _onPressed;
  Duration _successDuration = Duration.zero;
  Duration _errorDuration = Duration.zero;
  Duration _cooldownDuration = Duration.zero;
  bool _rethrowErrors = false;

  Timer? _timer;
  bool _cooldownActive = false;
  bool _disposed = false;

  /// Internal: called by the widget on each build to keep config fresh.
  @internal
  void attach({
    required Future<void> Function()? onPressed,
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
    if (!canTrigger) return;
    _cancelTimer();
    _setValue(const AsyncButtonState.loading());
    try {
      await _onPressed!();
      // External resets (e.g. controller.reset()) may have moved us off
      // loading mid-await. Only continue the success cycle if we're still
      // the one driving.
      if (!_disposed && _value is AsyncButtonStateLoading) {
        _setValue(const AsyncButtonState.success());
        _scheduleReturnToIdle(_successDuration);
      }
    } catch (error, stack) {
      if (!_disposed && _value is AsyncButtonStateLoading) {
        _setValue(AsyncButtonState.error(error, stack));
        _scheduleReturnToIdle(_errorDuration);
      }
      if (_rethrowErrors) rethrow;
    }
  }

  /// Force the button back to idle. Cancels any pending display/cooldown.
  void reset() {
    _cancelTimer();
    _cooldownActive = false;
    _setValue(const AsyncButtonState.idle());
  }

  /// Force the error state from outside. Runs the same display/callback
  /// cycle as if `onPressed` had thrown.
  void invalidate(Object error, [StackTrace? stackTrace]) {
    _cancelTimer();
    _setValue(AsyncButtonState.error(error, stackTrace ?? StackTrace.current));
    _scheduleReturnToIdle(_errorDuration);
  }

  /// Force the success state from outside. Runs the same display cycle as
  /// a completed `onPressed`.
  void markSuccess() {
    _cancelTimer();
    _setValue(const AsyncButtonState.success());
    _scheduleReturnToIdle(_successDuration);
  }

  void _setValue(AsyncButtonState v) {
    if (_value == v) return;
    _value = v;
    notifyListeners();
  }

  void _cancelTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void _scheduleReturnToIdle(Duration displayDuration) {
    if (displayDuration <= Duration.zero) {
      _enterIdleThenCooldown();
      return;
    }
    _timer = Timer(displayDuration, _enterIdleThenCooldown);
  }

  void _enterIdleThenCooldown() {
    if (_disposed) return;
    _timer = null;
    _setValue(const AsyncButtonState.idle());
    if (_cooldownDuration > Duration.zero) {
      _cooldownActive = true;
      notifyListeners();
      _timer = Timer(_cooldownDuration, () {
        if (_disposed) return;
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
