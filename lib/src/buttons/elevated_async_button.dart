part of '../../material_async_button.dart';

/// Async-aware [ElevatedButton]. While `onPressed` is running the label is
/// swapped for a loading widget; success/error are shown afterwards if
/// configured via prop or theme.
class ElevatedAsyncButton extends AsyncStandardMaterialButton {
  const ElevatedAsyncButton({
    super.key,
    required super.onPressed,
    required super.child,
    super.onLongPress,
    super.onHover,
    super.onFocusChange,
    super.style,
    super.focusNode,
    super.autofocus,
    super.clipBehavior,
    super.statesController,
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
  });

  /// Mirrors [ElevatedButton.icon]. The loading/success/error children
  /// replace `label` while `icon` stays put.
  const ElevatedAsyncButton.icon({
    super.key,
    required super.onPressed,
    super.onLongPress,
    super.onHover,
    super.onFocusChange,
    super.style,
    super.focusNode,
    super.autofocus,
    super.clipBehavior,
    super.statesController,
    super.iconAlignment,
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
    required Widget icon,
    required Widget label,
  }) : super(icon: icon, child: label);

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
      builder: (context, animatedChild, callback, status) {
        final clip = clipBehavior ?? .none;
        final longPress = callback == null ? null : onLongPress;
        if (_icon != null) {
          return ElevatedButton.icon(
            onPressed: callback,
            onLongPress: longPress,
            onHover: onHover,
            onFocusChange: onFocusChange,
            style: style,
            focusNode: focusNode,
            autofocus: autofocus,
            clipBehavior: clip,
            statesController: statesController,
            iconAlignment: _iconAlignment,
            icon: _icon,
            label: animatedChild,
          );
        }
        return ElevatedButton(
          onPressed: callback,
          onLongPress: longPress,
          onHover: onHover,
          onFocusChange: onFocusChange,
          style: style,
          focusNode: focusNode,
          autofocus: autofocus,
          clipBehavior: clip,
          statesController: statesController,
          child: animatedChild,
        );
      },
      child: child,
    );
  }
}
