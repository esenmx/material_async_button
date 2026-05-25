import 'package:flutter/material.dart';

import '../async_button_builder.dart';
import '../async_button_controller.dart';
import '../async_button_state.dart';
import '../material_async_button_theme.dart';

enum _IconVariant { standard, filled, filledTonal, outlined }

/// Async-aware [IconButton]. Includes all four Material 3 flavors:
/// [IconAsyncButton.new], [IconAsyncButton.filled],
/// [IconAsyncButton.filledTonal], [IconAsyncButton.outlined].
///
/// The [icon] is swapped with [loadingChild]/[successChild]/[errorChild]
/// during the corresponding state.
class IconAsyncButton extends StatelessWidget {
  const IconAsyncButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.iconSize,
    this.visualDensity,
    this.padding,
    this.alignment,
    this.splashRadius,
    this.color,
    this.focusColor,
    this.hoverColor,
    this.highlightColor,
    this.splashColor,
    this.disabledColor,
    this.mouseCursor,
    this.focusNode,
    this.autofocus = false,
    this.tooltip,
    this.enableFeedback,
    this.constraints,
    this.style,
    this.isSelected,
    this.selectedIcon,
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
  }) : _variant = _IconVariant.standard;

  const IconAsyncButton.filled({
    super.key,
    required this.onPressed,
    required this.icon,
    this.iconSize,
    this.visualDensity,
    this.padding,
    this.alignment,
    this.splashRadius,
    this.color,
    this.focusColor,
    this.hoverColor,
    this.highlightColor,
    this.splashColor,
    this.disabledColor,
    this.mouseCursor,
    this.focusNode,
    this.autofocus = false,
    this.tooltip,
    this.enableFeedback,
    this.constraints,
    this.style,
    this.isSelected,
    this.selectedIcon,
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
  }) : _variant = _IconVariant.filled;

  const IconAsyncButton.filledTonal({
    super.key,
    required this.onPressed,
    required this.icon,
    this.iconSize,
    this.visualDensity,
    this.padding,
    this.alignment,
    this.splashRadius,
    this.color,
    this.focusColor,
    this.hoverColor,
    this.highlightColor,
    this.splashColor,
    this.disabledColor,
    this.mouseCursor,
    this.focusNode,
    this.autofocus = false,
    this.tooltip,
    this.enableFeedback,
    this.constraints,
    this.style,
    this.isSelected,
    this.selectedIcon,
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
  }) : _variant = _IconVariant.filledTonal;

  const IconAsyncButton.outlined({
    super.key,
    required this.onPressed,
    required this.icon,
    this.iconSize,
    this.visualDensity,
    this.padding,
    this.alignment,
    this.splashRadius,
    this.color,
    this.focusColor,
    this.hoverColor,
    this.highlightColor,
    this.splashColor,
    this.disabledColor,
    this.mouseCursor,
    this.focusNode,
    this.autofocus = false,
    this.tooltip,
    this.enableFeedback,
    this.constraints,
    this.style,
    this.isSelected,
    this.selectedIcon,
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
  }) : _variant = _IconVariant.outlined;

  final Future<void> Function()? onPressed;
  final Widget icon;
  final double? iconSize;
  final VisualDensity? visualDensity;
  final EdgeInsetsGeometry? padding;
  final AlignmentGeometry? alignment;
  final double? splashRadius;
  final Color? color;
  final Color? focusColor;
  final Color? hoverColor;
  final Color? highlightColor;
  final Color? splashColor;
  final Color? disabledColor;
  final MouseCursor? mouseCursor;
  final FocusNode? focusNode;
  final bool autofocus;
  final String? tooltip;
  final bool? enableFeedback;
  final BoxConstraints? constraints;
  final ButtonStyle? style;
  final bool? isSelected;
  final Widget? selectedIcon;
  final _IconVariant _variant;

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
    child: icon,
    builder: (context, animatedChild, callback, _) {
      return switch (_variant) {
        _IconVariant.standard => IconButton(
          onPressed: callback,
          icon: animatedChild,
          iconSize: iconSize,
          visualDensity: visualDensity,
          padding: padding,
          alignment: alignment,
          splashRadius: splashRadius,
          color: color,
          focusColor: focusColor,
          hoverColor: hoverColor,
          highlightColor: highlightColor,
          splashColor: splashColor,
          disabledColor: disabledColor,
          mouseCursor: mouseCursor,
          focusNode: focusNode,
          autofocus: autofocus,
          tooltip: tooltip,
          enableFeedback: enableFeedback,
          constraints: constraints,
          style: style,
          isSelected: isSelected,
          selectedIcon: selectedIcon,
        ),
        _IconVariant.filled => IconButton.filled(
          onPressed: callback,
          icon: animatedChild,
          iconSize: iconSize,
          visualDensity: visualDensity,
          padding: padding,
          alignment: alignment,
          splashRadius: splashRadius,
          color: color,
          focusColor: focusColor,
          hoverColor: hoverColor,
          highlightColor: highlightColor,
          splashColor: splashColor,
          disabledColor: disabledColor,
          mouseCursor: mouseCursor,
          focusNode: focusNode,
          autofocus: autofocus,
          tooltip: tooltip,
          enableFeedback: enableFeedback,
          constraints: constraints,
          style: style,
          isSelected: isSelected,
          selectedIcon: selectedIcon,
        ),
        _IconVariant.filledTonal => IconButton.filledTonal(
          onPressed: callback,
          icon: animatedChild,
          iconSize: iconSize,
          visualDensity: visualDensity,
          padding: padding,
          alignment: alignment,
          splashRadius: splashRadius,
          color: color,
          focusColor: focusColor,
          hoverColor: hoverColor,
          highlightColor: highlightColor,
          splashColor: splashColor,
          disabledColor: disabledColor,
          mouseCursor: mouseCursor,
          focusNode: focusNode,
          autofocus: autofocus,
          tooltip: tooltip,
          enableFeedback: enableFeedback,
          constraints: constraints,
          style: style,
          isSelected: isSelected,
          selectedIcon: selectedIcon,
        ),
        _IconVariant.outlined => IconButton.outlined(
          onPressed: callback,
          icon: animatedChild,
          iconSize: iconSize,
          visualDensity: visualDensity,
          padding: padding,
          alignment: alignment,
          splashRadius: splashRadius,
          color: color,
          focusColor: focusColor,
          hoverColor: hoverColor,
          highlightColor: highlightColor,
          splashColor: splashColor,
          disabledColor: disabledColor,
          mouseCursor: mouseCursor,
          focusNode: focusNode,
          autofocus: autofocus,
          tooltip: tooltip,
          enableFeedback: enableFeedback,
          constraints: constraints,
          style: style,
          isSelected: isSelected,
          selectedIcon: selectedIcon,
        ),
      };
    },
  );
}
