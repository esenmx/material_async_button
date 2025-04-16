import 'dart:async';

import 'package:async_button_builder/async_button_builder.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

typedef AsyncButtonBuilderCallback = Widget Function(
  BuildContext context,
  Widget child,
  AsyncCallback? callback,
  AsyncButtonState buttonState,
);

/// A `builder` that wraps a button providing disabled, loading, success and
/// error states while retaining almost full access to the original Button's
/// API. This is useful for any long running operations and helps better
/// improve UX.
///
/// {@tool dartpad --template=stateful_widget_material}
///
/// ```dart
///
/// @override
/// Widget build(BuildContext context) {
///   return AsyncButtonBuilder(
///     child: Text('Click Me'),
///     loadingWidget: Text('Loading...'),
///     onPressed: () async {
///       await Future.delayed(Duration(seconds: 1));
///
///       throw 'yikes';
///     },
///     builder: (context, child, callback, buttonState) {
///       final buttonColor = buttonState.when(
///         idle: () => Colors.yellow[200],
///         loading: () => Colors.grey,
///         success: () => Colors.orangeAccent,
///         error: () => Colors.orange,
///       );
///
///       return OutlinedButton(
///         child: child,
///         onPressed: callback,
///         style: OutlinedButton.styleFrom(
///           primary: Colors.black,
///           backgroundColor: buttonColor,
///         ),
///       );
///     },
///   ),
/// }
/// ```
/// {@end-tool}
class AsyncButtonBuilder extends StatefulWidget {
  const AsyncButtonBuilder({
    super.key,
    required this.child,
    required this.onPressed,
    required this.builder,
    this.onSuccess,
    this.onError,
    this.loadingWidget = const SizedBox.square(
      dimension: 16.0,
      child: CircularProgressIndicator(),
    ),
    this.successWidget,
    this.errorWidget,
    this.showSuccess = true,
    this.showError = true,
    this.errorPadding,
    this.successPadding,
    this.buttonState = const AsyncButtonState.idle(),
    this.duration = const Duration(milliseconds: 250),
    this.reverseDuration = const Duration(milliseconds: 200),
    this.disabled = false,
    this.successDuration = const Duration(seconds: 1),
    this.errorDuration = const Duration(seconds: 1),
    this.loadingTransitionBuilder = AnimatedSwitcher.defaultTransitionBuilder,
    this.idleTransitionBuilder = AnimatedSwitcher.defaultTransitionBuilder,
    this.successTransitionBuilder = AnimatedSwitcher.defaultTransitionBuilder,
    this.errorTransitionBuilder = AnimatedSwitcher.defaultTransitionBuilder,
    this.idleSwitchInCurve = Curves.linear,
    this.loadingSwitchInCurve = Curves.linear,
    this.successSwitchInCurve = Curves.linear,
    this.errorSwitchInCurve = Curves.linear,
    this.idleSwitchOutCurve = Curves.linear,
    this.loadingSwitchOutCurve = Curves.linear,
    this.successSwitchOutCurve = Curves.linear,
    this.errorSwitchOutCurve = Curves.linear,
    this.sizeCurve = Curves.linear,
    this.sizeClipBehavior = Clip.hardEdge,
    this.sizeAlignment = Alignment.center,
    this.animateSize = true,
    this.notifications = false,
  });

  /// This builder provides the widget's [BuildContext], the variable [child]
  /// based on button state as well as the [callback] that should be passed to
  /// the button and the current [ButtonState]
  final AsyncButtonBuilderCallback builder;

  /// The child of the button. In the case of an [IconButton], this can be a an
  /// [Icon]. For a [TextButton], a [Text].
  ///
  /// This child will be animated between for the [loadingWidget] or default
  /// [CircularProgressIndicator] when the asynchronous [onPressed] is called.
  /// The animation will take place over [duration].
  final Widget child;

  /// The animation's duration between [child], [loadingWidget],
  /// [successWidget] and [errorWidget]. This same value is used for both the
  /// internal [AnimatedSize] and [TransitionBuilder].
  final Duration duration;

  /// The animation's reverse duration between [child], [loadingWidget],
  /// [successWidget] and [errorWidget]. This same value is used for both the
  /// internal [AnimatedSize] and [TransitionBuilder].
  final Duration reverseDuration;

  /// A callback that runs the async task. This is wrapped in order to begin
  /// the button's internal `isLoading` before and after the operation
  /// completes.
  final AsyncCallback? onPressed;

  /// A callback that runs [buttonState] changes to [AsyncButtonState.success]
  final VoidCallback? onSuccess;

  /// A callback that runs [buttonState] changes to [AsyncButtonState.error]
  final VoidCallback? onError;

  /// This is used to manually drive the state of the loading button thus
  /// initiating the corresponding animation and showing the correct button
  /// child.
  final AsyncButtonState buttonState;

  /// This is used to manually drive the disabled state of the button.
  final bool disabled;

  /// The widget replaces the [child] when the button is in the loading state.
  /// If this is null the default widget is:
  ///
  /// SizedBox(
  ///   height: 16.0,
  ///   width: 16.0,
  ///   child: CircularProgressIndicator(),
  /// )
  final Widget loadingWidget;

  /// The widget used to replace the [child] when the button is in a success
  /// state. If this is null the default widget is:
  ///
  /// Icon(
  ///   Icons.check,
  ///   color: Theme.of(context).accentColor,
  /// );
  final Widget? successWidget;

  /// The widget used to replace the [child] when the button is in a error
  /// state. If this is null the default widget is:
  ///
  /// Icon(
  ///   Icons.error,
  ///   color: Theme.of(context).errorColor,
  /// )
  final Widget? errorWidget;

  /// Whether to show the [successWidget] on success.
  final bool showSuccess;

  /// Whether to show the [errorWidget] on error.
  final bool showError;

  /// Optional [EdgeInsets] that will wrap around the [errorWidget]. This is a
  /// convenience field that can be replaced by defining your own [errorWidget]
  /// and wrapping it in a [Padding].
  final EdgeInsets? errorPadding;

  /// Optional [EdgeInsets] that will wrap around the [successWidget]. This is a
  /// convenience field that can be replaced by defining your own
  /// [successWidget] and wrapping it in a [Padding].
  final EdgeInsets? successPadding;

  /// Defines a custom transition when animating between any state and `idle`
  final AnimatedSwitcherTransitionBuilder idleTransitionBuilder;

  /// Defines a custom transition when animating between any state and `loading`
  final AnimatedSwitcherTransitionBuilder loadingTransitionBuilder;

  /// Defines a custom transition when animating between any state and `success`
  final AnimatedSwitcherTransitionBuilder successTransitionBuilder;

  /// Defines a custom transition when animating between any state and `error`
  final AnimatedSwitcherTransitionBuilder errorTransitionBuilder;

  /// The amount of idle time the [successWidget] shows
  final Duration successDuration;

  /// The amount of idle time the [errorWidget] shows
  final Duration errorDuration;

  /// Defines a curve for the custom transition. This used in in an
  /// [AnimatedSwitcher] and only takes effect when animating to `idle`
  final Curve idleSwitchInCurve;

  /// Defines a curve for the custom transition. This used in in an
  /// [AnimatedSwitcher] and only takes effect when animating to `loading`
  final Curve loadingSwitchInCurve;

  /// Defines a curve for the custom transition. This used in in an
  /// [AnimatedSwitcher] and only takes effect when animating to `success`
  final Curve successSwitchInCurve;

  /// Defines a curve for the custom transition. This used in in an
  /// [AnimatedSwitcher] and only takes effect when animating to `error`
  final Curve errorSwitchInCurve;

  /// Defines a curve for the custom transition. This used in in an
  /// [AnimatedSwitcher] and only takes effect when animating out of `idle`
  final Curve idleSwitchOutCurve;

  /// Defines a curve for the custom transition. This used in in an
  /// [AnimatedSwitcher] and only takes effect when animating out of `loading`
  final Curve loadingSwitchOutCurve;

  /// Defines a curve for the custom transition. This used in in an
  /// [AnimatedSwitcher] and only takes effect when animating out of `success`
  final Curve successSwitchOutCurve;

  /// Defines a curve for the custom transition. This used in in an
  /// [AnimatedSwitcher] and only takes effect when animating out of `error`
  final Curve errorSwitchOutCurve;

  /// Defines a curve for the internal [AnimatedSize]
  final Curve sizeCurve;

  /// Defines the [Clip] for the internal [AnimatedSize]
  final Clip sizeClipBehavior;

  /// Defines the [Alignment] for the internal [AnimatedSize]
  final Alignment sizeAlignment;

  /// Whether to animate the [Size] of the widget implicitly.
  final bool animateSize;

  /// Whether we should bubble up [AsyncButtonNotification]s up the widget tree.
  /// This is useful if you want to listen to the state of the button from a
  /// parent widget.
  final bool notifications;

  @override
  State<AsyncButtonBuilder> createState() => AsyncButtonBuilderState();
}

class AsyncButtonBuilderState extends State<AsyncButtonBuilder>
    with SingleTickerProviderStateMixin {
  late AsyncButtonState _buttonState = widget.buttonState;
  Key _switchKey = UniqueKey();
  Timer? timer;

  @override
  void didUpdateWidget(covariant AsyncButtonBuilder oldWidget) {
    if (widget.buttonState != oldWidget.buttonState) {
      _setButtonState(widget.buttonState);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Widget successWidget = widget.successWidget ??
        Icon(Icons.check, color: theme.colorScheme.secondary);
    Widget errorWidget =
        widget.errorWidget ?? Icon(Icons.error, color: theme.colorScheme.error);
    if (widget.successPadding != null) {
      successWidget = Padding(
        padding: widget.successPadding!,
        child: successWidget,
      );
    }

    if (widget.errorPadding != null) {
      errorWidget = Padding(
        padding: widget.errorPadding!,
        child: errorWidget,
      );
    }

    Widget content = AnimatedSwitcher(
      // TODO: This duration is same as size's duration. That's okay right?
      duration: widget.duration,
      reverseDuration: widget.reverseDuration,
      switchInCurve: switch (_buttonState) {
        AsyncButtonStateIdle() => widget.idleSwitchInCurve,
        AsyncButtonStateLoading() => widget.loadingSwitchInCurve,
        AsyncButtonStateSuccess() => widget.successSwitchInCurve,
        AsyncButtonStateError() => widget.errorSwitchInCurve,
      },
      switchOutCurve: switch (_buttonState) {
        AsyncButtonStateIdle() => widget.idleSwitchOutCurve,
        AsyncButtonStateLoading() => widget.loadingSwitchOutCurve,
        AsyncButtonStateSuccess() => widget.successSwitchOutCurve,
        AsyncButtonStateError() => widget.errorSwitchOutCurve,
      },
      transitionBuilder: switch (_buttonState) {
        AsyncButtonStateIdle() => widget.idleTransitionBuilder,
        AsyncButtonStateLoading() => widget.loadingTransitionBuilder,
        AsyncButtonStateSuccess() => widget.successTransitionBuilder,
        AsyncButtonStateError() => widget.errorTransitionBuilder,
      },
      child: KeyedSubtree(
        key: _switchKey,
        child: switch (_buttonState) {
          AsyncButtonStateIdle() => widget.child,
          AsyncButtonStateLoading() => widget.loadingWidget,
          AsyncButtonStateSuccess() => successWidget,
          AsyncButtonStateError() => errorWidget,
        },
      ),
    );

    if (widget.animateSize) {
      // TODO: I really just wanted an AnimatedSwitcher and the default
      // transitionBuilder to be a SizedTransition but it was impossible
      // to figure out how to reproduce the exact behaviour of AnimatedSize
      content = AnimatedSize(
        duration: widget.duration,
        reverseDuration: widget.reverseDuration,
        alignment: widget.sizeAlignment,
        clipBehavior: widget.sizeClipBehavior,
        curve: widget.sizeCurve,
        child: content,
      );
    }

    return widget.builder(context, content, pressCallback, _buttonState);
  }

  AsyncCallback? get pressCallback {
    if (widget.disabled || widget.onPressed == null) {
      return null;
    }
    return switch (_buttonState) {
      AsyncButtonStateIdle() => () {
          final completer = Completer<void>();

          // I might not want to set buttonState if we're being
          // driven by widget.buttonState...
          _setButtonState(const AsyncButtonState.loading());
          timer?.cancel();

          widget.onPressed!().then((_) {
            completer.complete();

            if (mounted) {
              if (widget.showSuccess) {
                _setButtonState(const AsyncButtonState.success());
                _setTimer(widget.successDuration, widget.onSuccess);
              } else {
                _setButtonState(const AsyncButtonState.idle());
              }
            }
          }).onError((Object error, StackTrace stackTrace) {
            completer.completeError(error, stackTrace);

            if (mounted) {
              if (widget.showError) {
                _setButtonState(AsyncButtonState.error(error));
                _setTimer(widget.errorDuration, widget.onError);
              } else {
                _setButtonState(const AsyncButtonState.idle());
              }
            }
          });

          return completer.future;
        },
      _ => null,
    };
  }

  void _setButtonState(AsyncButtonState buttonState) {
    setState(() {
      _switchKey = UniqueKey();
      _buttonState = buttonState;
    });

    if (widget.notifications) {
      AsyncButtonNotification(buttonState: buttonState).dispatch(context);
    }
  }

  void _setTimer(Duration duration, [VoidCallback? then]) {
    timer = Timer(
      duration,
      () {
        timer?.cancel();
        then?.call();
        if (mounted) {
          _setButtonState(const AsyncButtonState.idle());
        }
      },
    );
  }
}
