part of '../../material_async_button.dart';

/// Async-aware [TextButton].
class TextAsyncButton extends AsyncStandardMaterialButton {
  /// Mirrors [TextButton.new].
  const TextAsyncButton({
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
    super.enabled,
    super.controller,
    super.loadingBuilder,
    super.transitionBuilder,
  });

  /// Mirrors [TextButton.icon].
  const TextAsyncButton.icon({
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
    super.loadingBuilder,
    super.transitionBuilder,
    required super.icon,
    required Widget label,
  }) : super(child: label);

  @override
  Widget build(BuildContext context) {
    final clip = clipBehavior ?? .none;
    return AsyncButton(
      onPressed: onPressed,
      enabled: enabled,
      controller: controller,
      loadingBuilder: loadingBuilder,
      transitionBuilder: transitionBuilder,
      builder: (context, animatedChild, callback, isLoading) {
        final longPress = (callback != null && !isLoading) ? onLongPress : null;
        if (_icon != null) {
          return TextButton.icon(
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
            icon: isLoading ? null : _icon,
            label: animatedChild,
          );
        }
        return TextButton(
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
