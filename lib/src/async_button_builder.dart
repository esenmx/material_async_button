import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';

import 'async_button_controller.dart';
import 'async_button_state.dart';
import 'material_async_button_theme.dart';

/// Signature for the [AsyncButtonBuilder.builder].
///
/// `callback` is `null` when the button should appear disabled (already
/// loading, in cooldown, or `onPressed`/`disabled` make it ineligible).
typedef AsyncButtonWidgetBuilder =
    Widget Function(
      BuildContext context,
      Widget child,
      AsyncCallback? callback,
      AsyncButtonState state,
    );

/// Signature for [AsyncButtonBuilder.errorBuilder].
typedef AsyncButtonErrorBuilder =
    Widget Function(BuildContext context, Object error, StackTrace? stackTrace);

/// Signature for the `onError` callback. Receives the thrown error plus the
/// captured stack trace.
typedef AsyncButtonErrorCallback = void Function(Object error, StackTrace stackTrace);

/// Builder for an arbitrary button with async loading/success/error states.
///
/// You almost always want one of the named Material wrappers (e.g.
/// [ElevatedAsyncButton], [FilledAsyncButton], [OutlinedAsyncButton],
/// [TextAsyncButton], [IconAsyncButton]). Reach for [AsyncButtonBuilder]
/// directly only when you need to render a non-Material button.
///
/// {@tool snippet}
/// ```dart
/// AsyncButtonBuilder(
///   onPressed: () async => doWork(),
///   child: const Text('Go'),
///   builder: (context, child, callback, state) => MyCustomButton(
///     onTap: callback,
///     child: child,
///   ),
/// )
/// ```
/// {@end-tool}
class AsyncButtonBuilder extends StatefulWidget {
  const AsyncButtonBuilder({
    super.key,
    required this.child,
    required this.onPressed,
    required this.builder,
    this.controller,
    this.onSuccess,
    this.onError,
    this.onStateChanged,
    this.confirmBeforePress,
    this.errorBuilder,
    this.loadingChild,
    this.successChild,
    this.errorChild,
    this.disabled = false,
    this.switchDuration,
    this.switchReverseDuration,
    this.switchCurve,
    this.switchInCurve,
    this.switchOutCurve,
    this.transitionBuilder,
    this.successDisplayDuration,
    this.errorDisplayDuration,
    this.cooldownDuration,
    this.animateSize,
    this.sizeCurve,
    this.sizeAlignment,
    this.sizeClipBehavior,
    this.hapticOn,
    this.announceSemantics,
    this.rethrowErrors,
  });

  final Widget child;
  final AsyncCallback? onPressed;
  final AsyncButtonWidgetBuilder builder;

  /// External controller. When null, the widget creates and owns its own.
  final AsyncButtonController? controller;

  /// Called after success display completes.
  final VoidCallback? onSuccess;

  /// Called after error display completes (or immediately if the display
  /// duration is zero). Receives the thrown error and stack trace.
  final AsyncButtonErrorCallback? onError;

  /// Fired on every state change.
  final ValueChanged<AsyncButtonState>? onStateChanged;

  /// If provided, runs before [onPressed]. If it returns `false`, the press
  /// is cancelled and no state change happens.
  final Future<bool> Function(BuildContext context)? confirmBeforePress;

  /// Renders the error state. When non-null, takes precedence over
  /// [errorChild] and the theme's `errorChild`.
  final AsyncButtonErrorBuilder? errorBuilder;

  final Widget? loadingChild;
  final Widget? successChild;
  final Widget? errorChild;

  /// Forces the button to appear disabled regardless of state.
  final bool disabled;

  // Per-widget overrides of the theme. Null means "use theme, then default".
  final Duration? switchDuration;
  final Duration? switchReverseDuration;
  final Curve? switchCurve;
  final Curve? switchInCurve;
  final Curve? switchOutCurve;
  final AnimatedSwitcherTransitionBuilder? transitionBuilder;
  final Duration? successDisplayDuration;
  final Duration? errorDisplayDuration;
  final Duration? cooldownDuration;
  final bool? animateSize;
  final Curve? sizeCurve;
  final AlignmentGeometry? sizeAlignment;
  final Clip? sizeClipBehavior;
  final HapticOn? hapticOn;
  final bool? announceSemantics;
  final bool? rethrowErrors;

  @override
  State<AsyncButtonBuilder> createState() => AsyncButtonBuilderState();
}

class AsyncButtonBuilderState extends State<AsyncButtonBuilder> {
  AsyncButtonController? _internalController;
  AsyncButtonController get _controller => widget.controller ?? _internalController!;

  AsyncButtonState _lastNotifiedState = const AsyncButtonState.idle();

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _internalController = AsyncButtonController();
    }
    _controller.addListener(_handleControllerChange);
    _lastNotifiedState = _controller.value;
  }

  @override
  void didUpdateWidget(covariant AsyncButtonBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      final previous = oldWidget.controller ?? _internalController;
      previous?.removeListener(_handleControllerChange);
      if (widget.controller != null) {
        _internalController?.dispose();
        _internalController = null;
      } else {
        _internalController = AsyncButtonController();
      }
      _controller.addListener(_handleControllerChange);
      _lastNotifiedState = _controller.value;
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_handleControllerChange);
    _internalController?.dispose();
    super.dispose();
  }

  void _handleControllerChange() {
    final newState = _controller.value;
    if (newState != _lastNotifiedState) {
      widget.onStateChanged?.call(newState);
      _fireHaptic(_lastNotifiedState, newState);
      _announceSemantics(newState);
      final wasSuccess = _lastNotifiedState is AsyncButtonStateSuccess;
      final wasError = _lastNotifiedState is AsyncButtonStateError;
      if (newState is AsyncButtonStateSuccess && !wasSuccess) {
        widget.onSuccess?.call();
      } else if (newState is AsyncButtonStateError && !wasError) {
        widget.onError?.call(newState.error, newState.stackTrace ?? StackTrace.empty);
      }
      _lastNotifiedState = newState;
    }
    if (mounted) setState(() {});
  }

  void _fireHaptic(AsyncButtonState from, AsyncButtonState to) {
    final theme = MaterialAsyncButtonTheme.of(context);
    final mode = widget.hapticOn ?? theme.hapticOn ?? HapticOn.none;
    if (mode == HapticOn.none) return;
    final wantSuccess = mode == HapticOn.success || mode == HapticOn.both;
    final wantError = mode == HapticOn.error || mode == HapticOn.both;
    if (to is AsyncButtonStateSuccess && wantSuccess) {
      HapticFeedback.lightImpact();
    } else if (to is AsyncButtonStateError && wantError) {
      HapticFeedback.mediumImpact();
    }
  }

  void _announceSemantics(AsyncButtonState state) {
    final theme = MaterialAsyncButtonTheme.of(context);
    final on = widget.announceSemantics ?? theme.announceSemantics ?? false;
    if (!on) return;
    final direction = Directionality.maybeOf(context) ?? TextDirection.ltr;
    final message = switch (state) {
      AsyncButtonStateIdle() => null,
      AsyncButtonStateLoading() => 'Loading',
      AsyncButtonStateSuccess() => 'Success',
      AsyncButtonStateError() => 'Error',
    };
    if (message != null) {
      final view = View.maybeOf(context);
      if (view != null) {
        SemanticsService.sendAnnouncement(view, message, direction);
      }
    }
  }

  /// Trigger the attached `onPressed` programmatically. Equivalent to
  /// [AsyncButtonController.trigger] on the active controller. Safe to call
  /// from outside the widget tree (e.g. via a [GlobalKey]).
  Future<void> trigger() => _controller.trigger();

  /// Force the button back to idle.
  void reset() => _controller.reset();

  /// Force the error state from outside.
  void invalidate(Object error, [StackTrace? stackTrace]) =>
      _controller.invalidate(error, stackTrace);

  /// Force the success state from outside.
  void markSuccess() => _controller.markSuccess();

  /// The current state. Exposed for callers using a [GlobalKey].
  AsyncButtonState get value => _controller.value;

  @override
  Widget build(BuildContext context) {
    final theme = MaterialAsyncButtonTheme.of(context);

    final successDuration =
        widget.successDisplayDuration ?? theme.successDisplayDuration ?? Duration.zero;
    final errorDuration =
        widget.errorDisplayDuration ?? theme.errorDisplayDuration ?? Duration.zero;
    final cooldown = widget.cooldownDuration ?? theme.cooldownDuration ?? Duration.zero;
    final rethrowErrors = widget.rethrowErrors ?? theme.rethrowErrors ?? false;

    _controller.attach(
      onPressed: _gatedOnPressed(),
      successDuration: successDuration,
      errorDuration: errorDuration,
      cooldownDuration: cooldown,
      rethrowErrors: rethrowErrors,
    );

    final state = _controller.value;

    final loadingChild = widget.loadingChild ?? theme.loadingChild ?? const _BuiltinLoadingChild();
    final successChild = widget.successChild ?? theme.successChild;
    final errorChild = widget.errorChild ?? theme.errorChild;
    final switchDuration =
        widget.switchDuration ?? theme.switchDuration ?? const Duration(milliseconds: 200);
    final switchReverseDuration = widget.switchReverseDuration ?? theme.switchReverseDuration;
    final fallbackCurve = widget.switchCurve ?? theme.switchCurve ?? Curves.linear;
    final switchInCurve = widget.switchInCurve ?? theme.switchInCurve ?? fallbackCurve;
    final switchOutCurve = widget.switchOutCurve ?? theme.switchOutCurve ?? fallbackCurve;
    final transitionBuilder =
        widget.transitionBuilder ??
        theme.transitionBuilder ??
        AnimatedSwitcher.defaultTransitionBuilder;
    final animateSize = widget.animateSize ?? theme.animateSize ?? false;

    final Widget visible = switch (state) {
      AsyncButtonStateIdle() => widget.child,
      AsyncButtonStateLoading() => loadingChild,
      AsyncButtonStateSuccess() => successChild ?? widget.child,
      AsyncButtonStateError(:final error, :final stackTrace) =>
        widget.errorBuilder?.call(context, error, stackTrace) ?? errorChild ?? widget.child,
    };

    Widget content = AnimatedSwitcher(
      duration: switchDuration,
      reverseDuration: switchReverseDuration,
      switchInCurve: switchInCurve,
      switchOutCurve: switchOutCurve,
      transitionBuilder: transitionBuilder,
      child: KeyedSubtree(key: ValueKey<Type>(state.runtimeType), child: visible),
    );

    if (animateSize) {
      content = AnimatedSize(
        duration: switchDuration,
        reverseDuration: switchReverseDuration,
        alignment: widget.sizeAlignment ?? theme.sizeAlignment ?? Alignment.center,
        clipBehavior: widget.sizeClipBehavior ?? theme.sizeClipBehavior ?? Clip.hardEdge,
        curve: widget.sizeCurve ?? theme.sizeCurve ?? Curves.linear,
        child: content,
      );
    }

    return widget.builder(context, content, _builderCallback(), state);
  }

  /// The callback passed back through the builder. Null when the button is
  /// in a state that should appear disabled.
  AsyncCallback? _builderCallback() {
    if (widget.disabled || widget.onPressed == null) return null;
    if (!_controller.canTrigger) return null;
    return _controller.trigger;
  }

  /// The `onPressed` that `controller.trigger` will actually run, wrapped
  /// with `confirmBeforePress` and only invoked when not disabled.
  AsyncCallback? _gatedOnPressed() {
    if (widget.disabled || widget.onPressed == null) return null;
    final confirm = widget.confirmBeforePress;
    final raw = widget.onPressed!;
    if (confirm == null) return raw;
    return () async {
      if (!mounted) return;
      final ok = await confirm(context);
      if (!mounted || !ok) return;
      await raw();
    };
  }
}

class _BuiltinLoadingChild extends StatelessWidget {
  const _BuiltinLoadingChild();

  @override
  Widget build(BuildContext context) =>
      const SizedBox.square(dimension: 16, child: CircularProgressIndicator(strokeWidth: 2));
}
