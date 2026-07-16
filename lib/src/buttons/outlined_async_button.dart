part of '../../material_async_button.dart';

/// Async-aware [OutlinedButton].
class OutlinedAsyncButton extends AsyncStandardMaterialButton {
  /// Mirrors [OutlinedButton.new].
  const OutlinedAsyncButton({
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
    super.key,
  });

  /// Mirrors [OutlinedButton.icon].
  const OutlinedAsyncButton.icon({
    required super.onPressed,
    required super.icon,
    required Widget label,
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
    super.key,
  }) : super(child: label);

  @override
  Widget build(BuildContext context) {
    return AsyncButton(
      onPressed: onPressed,
      enabled: enabled,
      controller: controller,
      loadingBuilder: _resolveLoadingBuilder(context, _loadingSizing),
      transitionBuilder: transitionBuilder,
      builder: (context, animatedChild, callback, isLoading) {
        final longPress = (callback != null && !isLoading) ? onLongPress : null;
        if (_icon != null) {
          return OutlinedButton.icon(
            onPressed: callback,
            onLongPress: longPress,
            onHover: onHover,
            onFocusChange: onFocusChange,
            style: style,
            focusNode: focusNode,
            autofocus: autofocus,
            clipBehavior: clipBehavior,
            statesController: statesController,
            iconAlignment: _iconAlignment,
            icon: isLoading ? null : _icon,
            label: animatedChild,
          );
        }
        return OutlinedButton(
          onPressed: callback,
          onLongPress: longPress,
          onHover: onHover,
          onFocusChange: onFocusChange,
          style: style,
          focusNode: focusNode,
          autofocus: autofocus,
          clipBehavior: clipBehavior,
          statesController: statesController,
          child: animatedChild,
        );
      },
      child: child,
    );
  }
}
