part of '../../material_async_button.dart';

enum _IconVariant { standard, filled, filledTonal, outlined }

/// Async-aware [IconButton]. Includes all four Material 3 flavors:
/// [IconAsyncButton.new], [IconAsyncButton.filled],
/// [IconAsyncButton.filledTonal], [IconAsyncButton.outlined].
///
/// The [icon] is swapped with `loadingChild`/`successChild`/`errorChild`
/// during the corresponding state.
class IconAsyncButton extends AsyncMaterialButton {
  /// Mirrors [IconButton.new].
  const IconAsyncButton({
    super.key,
    required super.onPressed,
    super.controller,
    super.onSuccess,
    super.onError,
    super.onStateChanged,
    super.confirmBeforePress,
    super.loadingChild,
    super.successChild,
    super.errorChild,
    super.disabled,
    super.switchDuration,
    super.transitionBuilder,
    super.successDisplayDuration,
    super.errorDisplayDuration,
    super.cooldownDuration,
    super.animateSize,
    super.hapticOn,
    super.announceSemantics,
    super.rethrowErrors,
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
  }) : _variant = .standard,
       super(child: icon);

  /// Mirrors [IconButton.filled].
  const IconAsyncButton.filled({
    super.key,
    required super.onPressed,
    super.controller,
    super.onSuccess,
    super.onError,
    super.onStateChanged,
    super.confirmBeforePress,
    super.loadingChild,
    super.successChild,
    super.errorChild,
    super.disabled,
    super.switchDuration,
    super.transitionBuilder,
    super.successDisplayDuration,
    super.errorDisplayDuration,
    super.cooldownDuration,
    super.animateSize,
    super.hapticOn,
    super.announceSemantics,
    super.rethrowErrors,
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
  }) : _variant = .filled,
       super(child: icon);

  /// Mirrors [IconButton.filledTonal].
  const IconAsyncButton.filledTonal({
    super.key,
    required super.onPressed,
    super.controller,
    super.onSuccess,
    super.onError,
    super.onStateChanged,
    super.confirmBeforePress,
    super.loadingChild,
    super.successChild,
    super.errorChild,
    super.disabled,
    super.switchDuration,
    super.transitionBuilder,
    super.successDisplayDuration,
    super.errorDisplayDuration,
    super.cooldownDuration,
    super.animateSize,
    super.hapticOn,
    super.announceSemantics,
    super.rethrowErrors,
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
  }) : _variant = .filledTonal,
       super(child: icon);

  /// Mirrors [IconButton.outlined].
  const IconAsyncButton.outlined({
    super.key,
    required super.onPressed,
    super.controller,
    super.onSuccess,
    super.onError,
    super.onStateChanged,
    super.confirmBeforePress,
    super.loadingChild,
    super.successChild,
    super.errorChild,
    super.disabled,
    super.switchDuration,
    super.transitionBuilder,
    super.successDisplayDuration,
    super.errorDisplayDuration,
    super.cooldownDuration,
    super.animateSize,
    super.hapticOn,
    super.announceSemantics,
    super.rethrowErrors,
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
  }) : _variant = .outlined,
       super(child: icon);

  /// Idle icon. Swapped with `loadingChild`/`successChild`/`errorChild`.
  final Widget icon;

  /// Forwarded to the underlying [IconButton].
  final double? iconSize;

  /// Forwarded to the underlying [IconButton].
  final VisualDensity? visualDensity;

  /// Forwarded to the underlying [IconButton].
  final EdgeInsetsGeometry? padding;

  /// Forwarded to the underlying [IconButton].
  final AlignmentGeometry? alignment;

  /// Forwarded to the underlying [IconButton].
  final double? splashRadius;

  /// Forwarded to the underlying [IconButton].
  final Color? color;

  /// Forwarded to the underlying [IconButton].
  final Color? focusColor;

  /// Forwarded to the underlying [IconButton].
  final Color? hoverColor;

  /// Forwarded to the underlying [IconButton].
  final Color? highlightColor;

  /// Forwarded to the underlying [IconButton].
  final Color? splashColor;

  /// Forwarded to the underlying [IconButton].
  final Color? disabledColor;

  /// Forwarded to the underlying [IconButton].
  final MouseCursor? mouseCursor;

  /// Forwarded to the underlying [IconButton].
  final FocusNode? focusNode;

  /// Forwarded to the underlying [IconButton].
  final bool autofocus;

  /// Forwarded to the underlying [IconButton].
  final String? tooltip;

  /// Forwarded to the underlying [IconButton].
  final bool? enableFeedback;

  /// Forwarded to the underlying [IconButton].
  final BoxConstraints? constraints;

  /// Forwarded to the underlying [IconButton].
  final ButtonStyle? style;

  /// Forwarded to the underlying [IconButton].
  final bool? isSelected;

  /// Forwarded to the underlying [IconButton].
  final Widget? selectedIcon;

  final _IconVariant _variant;

  @override
  Widget build(BuildContext context) {
    return AsyncButton(
      onPressed: onPressed,
      controller: controller,
      onSuccess: onSuccess,
      onError: onError,
      onStateChanged: onStateChanged,
      confirmBeforePress: confirmBeforePress,
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
      builder: (context, child, callback, status) {
        return switch (_variant) {
          .standard => IconButton(
            onPressed: callback,
            icon: child,
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
          .filled => IconButton.filled(
            onPressed: callback,
            icon: child,
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
          .filledTonal => IconButton.filledTonal(
            onPressed: callback,
            icon: child,
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
          .outlined => IconButton.outlined(
            onPressed: callback,
            icon: child,
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
      child: icon,
    );
  }
}
