part of '../../material_async_button.dart';

/// Async-aware [ElevatedButton]. While `onPressed` is running the label is
/// swapped for a loading widget; an optional success view is shown afterwards
/// if configured via prop or theme.
class ElevatedAsyncButton extends AsyncStandardMaterialButton {
  /// Mirrors [ElevatedButton.new].
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
    super.enabled,
    super.controller,
    super.loadingBuilder,
    super.transitionBuilder,
  });

  /// Mirrors [ElevatedButton.icon]. The loading/success children replace
  /// `label` while `icon` stays put.
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
            icon: isLoading ? null : _icon,
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
