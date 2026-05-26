part of '../material_async_button.dart';

/// Signature for [AsyncButton.builder].
///
/// `callback` is `null` when the button should appear disabled (already
/// loading, in cooldown, or `onPressed`/`disabled` make it ineligible).
typedef AsyncButtonWidgetBuilder =
    Widget Function(
      BuildContext context,
      Widget child,
      AsyncCallback? callback,
      AsyncButtonStatus status,
    );

/// Signature for `onError`. Receives the thrown error plus the captured
/// stack trace. The error is delivered informationally — the button itself
/// only reacts to [AsyncButtonStatus].
typedef AsyncButtonErrorCallback =
    void Function(
      Object error,
      StackTrace stackTrace,
    );

/// Low-level async-status shell for arbitrary buttons.
///
/// Prefer the named Material wrappers ([ElevatedAsyncButton],
/// [FilledAsyncButton], [OutlinedAsyncButton], [TextAsyncButton],
/// [IconAsyncButton]). Reach for [AsyncButton] directly only when you need
/// to render a non-Material button.
///
/// The builder receives the current [AsyncButtonStatus] — destructure the
/// error variant to render the error inline:
///
/// ```dart
/// builder: (context, child, callback, status) => switch (status) {
///   AsyncButtonStatusError(:final error) => Text('failed: $error'),
///   _ => MyButton(onTap: callback, child: child),
/// }
/// ```
///
/// ```dart
/// AsyncButton(
///   onPressed: () async => doWork(),
///   child: const Text('Go'),
///   builder: (context, child, callback, status) => MyCustomButton(
///     onTap: callback,
///     child: child,
///   ),
/// )
/// ```
class AsyncButton extends StatefulWidget {
  /// Creates an [AsyncButton]. See the class doc for usage.
  const AsyncButton({
    super.key,
    required this.child,
    required this.onPressed,
    required this.builder,
    this.controller,
    this.onSuccess,
    this.onError,
    this.onStateChanged,
    this.confirmBeforePress,
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

  /// Idle widget. Replaced by [loadingChild] / [successChild] / [errorChild]
  /// during the matching [AsyncButtonStatus].
  final Widget child;

  /// Async callback. `null` makes the button appear disabled.
  final AsyncCallback? onPressed;

  /// Renders the button chrome. See [AsyncButtonWidgetBuilder].
  final AsyncButtonWidgetBuilder builder;

  /// External controller. When null, the widget creates and owns its own.
  final AsyncButtonController? controller;

  /// Called when the button enters [.success].
  final VoidCallback? onSuccess;

  /// Called when the button enters [.error].
  final AsyncButtonErrorCallback? onError;

  /// Fired on every status change. Use [onError] or read [controller] when
  /// you also need the error payload.
  final ValueChanged<AsyncButtonStatus>? onStateChanged;

  /// Runs before [onPressed]. If it returns `false` the press is cancelled
  /// and no status change happens.
  final Future<bool> Function(BuildContext context)? confirmBeforePress;

  /// Widget shown while loading. Falls back to [AsyncButtonTheme.loadingChild].
  final Widget? loadingChild;

  /// Widget shown briefly after success. Falls back to
  /// [AsyncButtonTheme.successChild].
  final Widget? successChild;

  /// Widget shown briefly after error. Falls back to
  /// [AsyncButtonTheme.errorChild].
  final Widget? errorChild;

  /// Forces the button to appear disabled regardless of status.
  final bool disabled;

  /// Per-widget override of [AsyncButtonTheme.switchDuration].
  final Duration? switchDuration;

  /// Per-widget override of [AsyncButtonTheme.switchReverseDuration].
  final Duration? switchReverseDuration;

  /// Per-widget override of [AsyncButtonTheme.switchCurve].
  final Curve? switchCurve;

  /// Per-widget override of [AsyncButtonTheme.switchInCurve].
  final Curve? switchInCurve;

  /// Per-widget override of [AsyncButtonTheme.switchOutCurve].
  final Curve? switchOutCurve;

  /// Per-widget override of [AsyncButtonTheme.transitionBuilder].
  final AnimatedSwitcherTransitionBuilder? transitionBuilder;

  /// Per-widget override of [AsyncButtonTheme.successDisplayDuration].
  final Duration? successDisplayDuration;

  /// Per-widget override of [AsyncButtonTheme.errorDisplayDuration].
  final Duration? errorDisplayDuration;

  /// Per-widget override of [AsyncButtonTheme.cooldownDuration].
  final Duration? cooldownDuration;

  /// Per-widget override of [AsyncButtonTheme.animateSize].
  final bool? animateSize;

  /// Per-widget override of [AsyncButtonTheme.sizeCurve].
  final Curve? sizeCurve;

  /// Per-widget override of [AsyncButtonTheme.sizeAlignment].
  final AlignmentGeometry? sizeAlignment;

  /// Per-widget override of [AsyncButtonTheme.sizeClipBehavior].
  final Clip? sizeClipBehavior;

  /// Per-widget override of [AsyncButtonTheme.hapticOn].
  final HapticOn? hapticOn;

  /// Per-widget override of [AsyncButtonTheme.announceSemantics].
  final bool? announceSemantics;

  /// Per-widget override of [AsyncButtonTheme.rethrowErrors].
  final bool? rethrowErrors;

  @override
  State<AsyncButton> createState() {
    return _AsyncButtonState();
  }
}

class _AsyncButtonState extends State<AsyncButton> {
  AsyncButtonController? _internalController;
  AsyncButtonController get _controller =>
      widget.controller ?? _internalController!;

  AsyncButtonStatus _lastStatus = const .idle();

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _internalController = AsyncButtonController();
    }
    _controller.addListener(_handleControllerChange);
    _lastStatus = _controller.value;
  }

  @override
  void didUpdateWidget(covariant AsyncButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller == oldWidget.controller) {
      return;
    }
    final previous = oldWidget.controller ?? _internalController;
    previous?.removeListener(_handleControllerChange);
    if (widget.controller != null) {
      _internalController?.dispose();
      _internalController = null;
    } else {
      _internalController = AsyncButtonController();
    }
    _controller.addListener(_handleControllerChange);
    _lastStatus = _controller.value;
  }

  @override
  void dispose() {
    _controller.removeListener(_handleControllerChange);
    _internalController?.dispose();
    super.dispose();
  }

  void _handleControllerChange() {
    final newStatus = _controller.value;
    if (newStatus != _lastStatus) {
      widget.onStateChanged?.call(newStatus);
      _fireHaptic(newStatus);
      _announceSemantics(newStatus);
      if (newStatus is AsyncButtonStatusSuccess &&
          _lastStatus is! AsyncButtonStatusSuccess) {
        widget.onSuccess?.call();
      } else if (newStatus is AsyncButtonStatusError &&
          _lastStatus is! AsyncButtonStatusError) {
        widget.onError?.call(
          newStatus.error,
          newStatus.stackTrace ?? StackTrace.empty,
        );
      }
      _lastStatus = newStatus;
    }
    if (mounted) {
      setState(() {});
    }
  }

  void _fireHaptic(AsyncButtonStatus to) {
    final mode =
        widget.hapticOn ?? AsyncButtonTheme.of(context).hapticOn ?? .none;
    if (mode == .none) {
      return;
    }
    final wantSuccess = mode == .success || mode == .both;
    final wantError = mode == .error || mode == .both;
    if (to is AsyncButtonStatusSuccess && wantSuccess) {
      unawaited(HapticFeedback.lightImpact());
    } else if (to is AsyncButtonStatusError && wantError) {
      unawaited(HapticFeedback.mediumImpact());
    }
  }

  void _announceSemantics(AsyncButtonStatus status) {
    final on =
        widget.announceSemantics ??
        AsyncButtonTheme.of(context).announceSemantics ??
        false;
    if (!on) {
      return;
    }
    final message = switch (status) {
      AsyncButtonStatusIdle() => null,
      AsyncButtonStatusLoading() => 'Loading',
      AsyncButtonStatusSuccess() => 'Success',
      AsyncButtonStatusError() => 'Error',
    };
    if (message == null) {
      return;
    }
    final view = View.maybeOf(context);
    if (view == null) {
      return;
    }
    final direction = Directionality.maybeOf(context) ?? .ltr;
    unawaited(SemanticsService.sendAnnouncement(view, message, direction));
  }

  @override
  Widget build(BuildContext context) {
    final config = _resolveConfig(AsyncButtonTheme.of(context));

    _controller.attach(
      onPressed: _gatedOnPressed(),
      successDuration: config.successDisplayDuration,
      errorDuration: config.errorDisplayDuration,
      cooldownDuration: config.cooldownDuration,
      rethrowErrors: config.rethrowErrors,
    );

    final status = _controller.value;
    final visible = switch (status) {
      AsyncButtonStatusIdle() => widget.child,
      AsyncButtonStatusLoading() => config.loadingChild,
      AsyncButtonStatusSuccess() => config.successChild ?? widget.child,
      AsyncButtonStatusError() => config.errorChild ?? widget.child,
    };

    Widget content = AnimatedSwitcher(
      duration: config.switchDuration,
      reverseDuration: config.switchReverseDuration,
      switchInCurve: config.switchInCurve,
      switchOutCurve: config.switchOutCurve,
      transitionBuilder: config.transitionBuilder,
      child: KeyedSubtree(
        key: ValueKey<AsyncButtonStatus>(status),
        child: visible,
      ),
    );

    if (config.animateSize) {
      content = AnimatedSize(
        duration: config.switchDuration,
        reverseDuration: config.switchReverseDuration,
        alignment: config.sizeAlignment,
        clipBehavior: config.sizeClipBehavior,
        curve: config.sizeCurve,
        child: content,
      );
    }

    return widget.builder(context, content, _builderCallback(), status);
  }

  /// Callback passed back through the builder. Null when the button is in a
  /// status that should appear disabled.
  AsyncCallback? _builderCallback() {
    if (widget.disabled || widget.onPressed == null) {
      return null;
    }
    if (!_controller.canTrigger) {
      return null;
    }
    return _controller.trigger;
  }

  /// The `onPressed` that `controller.trigger` will actually run, wrapped
  /// with `confirmBeforePress` and only invoked when not disabled.
  AsyncCallback? _gatedOnPressed() {
    if (widget.disabled || widget.onPressed == null) {
      return null;
    }
    final confirm = widget.confirmBeforePress;
    final raw = widget.onPressed!;
    if (confirm == null) {
      return raw;
    }
    return () async {
      if (!mounted) {
        return;
      }
      final ok = await confirm(context);
      if (!mounted || !ok) {
        return;
      }
      await raw();
    };
  }

  _ResolvedConfig _resolveConfig(AsyncButtonTheme t) {
    final w = widget;
    final fallbackCurve = w.switchCurve ?? t.switchCurve ?? Curves.linear;
    return _ResolvedConfig(
      loadingChild: w.loadingChild ?? t.loadingChild ?? _defaultLoadingChild,
      successChild: w.successChild ?? t.successChild,
      errorChild: w.errorChild ?? t.errorChild,
      switchDuration:
          w.switchDuration ??
          t.switchDuration ??
          const Duration(milliseconds: 200),
      switchReverseDuration: w.switchReverseDuration ?? t.switchReverseDuration,
      switchInCurve: w.switchInCurve ?? t.switchInCurve ?? fallbackCurve,
      switchOutCurve: w.switchOutCurve ?? t.switchOutCurve ?? fallbackCurve,
      transitionBuilder:
          w.transitionBuilder ??
          t.transitionBuilder ??
          AnimatedSwitcher.defaultTransitionBuilder,
      successDisplayDuration:
          w.successDisplayDuration ?? t.successDisplayDuration ?? .zero,
      errorDisplayDuration:
          w.errorDisplayDuration ?? t.errorDisplayDuration ?? .zero,
      cooldownDuration: w.cooldownDuration ?? t.cooldownDuration ?? .zero,
      animateSize: w.animateSize ?? t.animateSize ?? false,
      sizeCurve: w.sizeCurve ?? t.sizeCurve ?? Curves.linear,
      sizeAlignment: w.sizeAlignment ?? t.sizeAlignment ?? .center,
      sizeClipBehavior: w.sizeClipBehavior ?? t.sizeClipBehavior ?? .hardEdge,
      rethrowErrors: w.rethrowErrors ?? t.rethrowErrors ?? false,
    );
  }
}

/// Per-build resolution of widget props ▶ theme ▶ defaults.
@immutable
class _ResolvedConfig {
  const _ResolvedConfig({
    required this.loadingChild,
    required this.successChild,
    required this.errorChild,
    required this.switchDuration,
    required this.switchReverseDuration,
    required this.switchInCurve,
    required this.switchOutCurve,
    required this.transitionBuilder,
    required this.successDisplayDuration,
    required this.errorDisplayDuration,
    required this.cooldownDuration,
    required this.animateSize,
    required this.sizeCurve,
    required this.sizeAlignment,
    required this.sizeClipBehavior,
    required this.rethrowErrors,
  });

  final Widget loadingChild;
  final Widget? successChild;
  final Widget? errorChild;
  final Duration switchDuration;
  final Duration? switchReverseDuration;
  final Curve switchInCurve;
  final Curve switchOutCurve;
  final AnimatedSwitcherTransitionBuilder transitionBuilder;
  final Duration successDisplayDuration;
  final Duration errorDisplayDuration;
  final Duration cooldownDuration;
  final bool animateSize;
  final Curve sizeCurve;
  final AlignmentGeometry sizeAlignment;
  final Clip sizeClipBehavior;
  final bool rethrowErrors;
}

const _defaultLoadingChild = SizedBox.square(
  dimension: 16,
  child: CircularProgressIndicator(strokeWidth: 2),
);
