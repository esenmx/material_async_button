part of '../../material_async_button.dart';

/// Async-aware [TextButton].
class TextAsyncButton extends AsyncStandardMaterialButton {
  /// Mirrors [TextButton.new].
  const TextAsyncButton({
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

  /// Mirrors [TextButton.icon].
  const TextAsyncButton.icon({
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
  Widget buildButton(
    BuildContext context, {
    required VoidCallback? onPressed,
    required VoidCallback? onLongPress,
    required Widget child,
  }) {
    return TextButton(
      onPressed: onPressed,
      onLongPress: onLongPress,
      onHover: onHover,
      onFocusChange: onFocusChange,
      style: style,
      focusNode: focusNode,
      autofocus: autofocus,
      clipBehavior: clipBehavior,
      statesController: statesController,
      child: child,
    );
  }

  @override
  Widget buildIconButton(
    BuildContext context, {
    required VoidCallback? onPressed,
    required VoidCallback? onLongPress,
    required Widget? icon,
    required Widget label,
  }) {
    return TextButton.icon(
      onPressed: onPressed,
      onLongPress: onLongPress,
      onHover: onHover,
      onFocusChange: onFocusChange,
      style: style,
      focusNode: focusNode,
      autofocus: autofocus,
      clipBehavior: clipBehavior,
      statesController: statesController,
      iconAlignment: _iconAlignment,
      icon: icon,
      label: label,
    );
  }
}
