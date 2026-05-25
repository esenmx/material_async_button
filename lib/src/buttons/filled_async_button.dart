import 'package:flutter/material.dart';

import '../async_button_builder.dart';
import '../async_button_controller.dart';
import '../async_button_state.dart';
import '../material_async_button_theme.dart';

enum _FilledVariant { primary, tonal }

/// Async-aware [FilledButton] with all four Material 3 flavors:
/// [FilledAsyncButton.new], [FilledAsyncButton.tonal],
/// [FilledAsyncButton.icon], [FilledAsyncButton.tonalIcon].
class FilledAsyncButton extends StatelessWidget {
  const FilledAsyncButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.onLongPress,
    this.onHover,
    this.onFocusChange,
    this.style,
    this.focusNode,
    this.autofocus = false,
    this.clipBehavior,
    this.statesController,
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
    this.transitionBuilder,
    this.successDisplayDuration,
    this.errorDisplayDuration,
    this.cooldownDuration,
    this.animateSize,
    this.hapticOn,
    this.announceSemantics,
    this.rethrowErrors,
  }) : _variant = _FilledVariant.primary,
       _icon = null,
       _iconAlignment = null;

  const FilledAsyncButton.tonal({
    super.key,
    required this.onPressed,
    required this.child,
    this.onLongPress,
    this.onHover,
    this.onFocusChange,
    this.style,
    this.focusNode,
    this.autofocus = false,
    this.clipBehavior,
    this.statesController,
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
    this.transitionBuilder,
    this.successDisplayDuration,
    this.errorDisplayDuration,
    this.cooldownDuration,
    this.animateSize,
    this.hapticOn,
    this.announceSemantics,
    this.rethrowErrors,
  }) : _variant = _FilledVariant.tonal,
       _icon = null,
       _iconAlignment = null;

  const FilledAsyncButton.icon({
    super.key,
    required this.onPressed,
    required Widget icon,
    required Widget label,
    this.onLongPress,
    this.onHover,
    this.onFocusChange,
    this.style,
    this.focusNode,
    this.autofocus = false,
    this.clipBehavior,
    this.statesController,
    IconAlignment? iconAlignment,
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
    this.transitionBuilder,
    this.successDisplayDuration,
    this.errorDisplayDuration,
    this.cooldownDuration,
    this.animateSize,
    this.hapticOn,
    this.announceSemantics,
    this.rethrowErrors,
  }) : _variant = _FilledVariant.primary,
       _icon = icon,
       _iconAlignment = iconAlignment,
       child = label;

  const FilledAsyncButton.tonalIcon({
    super.key,
    required this.onPressed,
    required Widget icon,
    required Widget label,
    this.onLongPress,
    this.onHover,
    this.onFocusChange,
    this.style,
    this.focusNode,
    this.autofocus = false,
    this.clipBehavior,
    this.statesController,
    IconAlignment? iconAlignment,
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
    this.transitionBuilder,
    this.successDisplayDuration,
    this.errorDisplayDuration,
    this.cooldownDuration,
    this.animateSize,
    this.hapticOn,
    this.announceSemantics,
    this.rethrowErrors,
  }) : _variant = _FilledVariant.tonal,
       _icon = icon,
       _iconAlignment = iconAlignment,
       child = label;

  final Future<void> Function()? onPressed;
  final Widget child;
  final VoidCallback? onLongPress;
  final ValueChanged<bool>? onHover;
  final ValueChanged<bool>? onFocusChange;
  final ButtonStyle? style;
  final FocusNode? focusNode;
  final bool autofocus;
  final Clip? clipBehavior;
  final WidgetStatesController? statesController;
  final _FilledVariant _variant;
  final Widget? _icon;
  final IconAlignment? _iconAlignment;

  final AsyncButtonController? controller;
  final VoidCallback? onSuccess;
  final AsyncButtonErrorCallback? onError;
  final ValueChanged<AsyncButtonState>? onStateChanged;
  final Future<bool> Function(BuildContext context)? confirmBeforePress;
  final AsyncButtonErrorBuilder? errorBuilder;
  final Widget? loadingChild;
  final Widget? successChild;
  final Widget? errorChild;
  final bool disabled;
  final Duration? switchDuration;
  final AnimatedSwitcherTransitionBuilder? transitionBuilder;
  final Duration? successDisplayDuration;
  final Duration? errorDisplayDuration;
  final Duration? cooldownDuration;
  final bool? animateSize;
  final HapticOn? hapticOn;
  final bool? announceSemantics;
  final bool? rethrowErrors;

  @override
  Widget build(BuildContext context) => AsyncButtonBuilder(
    onPressed: onPressed,
    controller: controller,
    onSuccess: onSuccess,
    onError: onError,
    onStateChanged: onStateChanged,
    confirmBeforePress: confirmBeforePress,
    errorBuilder: errorBuilder,
    loadingChild: loadingChild,
    successChild: successChild,
    errorChild: errorChild,
    disabled: disabled,
    switchDuration: switchDuration,
    transitionBuilder: transitionBuilder,
    successDisplayDuration: successDisplayDuration,
    errorDisplayDuration: errorDisplayDuration,
    cooldownDuration: cooldownDuration,
    animateSize: animateSize,
    hapticOn: hapticOn,
    announceSemantics: announceSemantics,
    rethrowErrors: rethrowErrors,
    child: child,
    builder: (context, animatedChild, callback, _) {
      if (_icon != null) {
        return switch (_variant) {
          _FilledVariant.primary => FilledButton.icon(
            onPressed: callback,
            onLongPress: callback == null ? null : onLongPress,
            onHover: onHover,
            onFocusChange: onFocusChange,
            style: style,
            focusNode: focusNode,
            autofocus: autofocus,
            clipBehavior: clipBehavior ?? Clip.none,
            statesController: statesController,
            iconAlignment: _iconAlignment,
            icon: _icon,
            label: animatedChild,
          ),
          _FilledVariant.tonal => FilledButton.tonalIcon(
            onPressed: callback,
            onLongPress: callback == null ? null : onLongPress,
            onHover: onHover,
            onFocusChange: onFocusChange,
            style: style,
            focusNode: focusNode,
            autofocus: autofocus,
            clipBehavior: clipBehavior ?? Clip.none,
            statesController: statesController,
            iconAlignment: _iconAlignment,
            icon: _icon,
            label: animatedChild,
          ),
        };
      }
      return switch (_variant) {
        _FilledVariant.primary => FilledButton(
          onPressed: callback,
          onLongPress: callback == null ? null : onLongPress,
          onHover: onHover,
          onFocusChange: onFocusChange,
          style: style,
          focusNode: focusNode,
          autofocus: autofocus,
          clipBehavior: clipBehavior ?? Clip.none,
          statesController: statesController,
          child: animatedChild,
        ),
        _FilledVariant.tonal => FilledButton.tonal(
          onPressed: callback,
          onLongPress: callback == null ? null : onLongPress,
          onHover: onHover,
          onFocusChange: onFocusChange,
          style: style,
          focusNode: focusNode,
          autofocus: autofocus,
          clipBehavior: clipBehavior ?? Clip.none,
          statesController: statesController,
          child: animatedChild,
        ),
      };
    },
  );
}
