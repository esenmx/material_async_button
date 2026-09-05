part of '../../material_async_button.dart';

/// Async-aware [OutlinedButton].
class OutlinedAsyncButton extends AsyncStandardMaterialButton {
  /// Mirrors [OutlinedButton.new].
  const new({
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
  const new icon({
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
  Widget _buildButton({
    required VoidCallback? onPressed,
    required VoidCallback? onLongPress,
    required Widget child,
  }) {
    return OutlinedButton(
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
  Widget _buildIconButton({
    required VoidCallback? onPressed,
    required VoidCallback? onLongPress,
    required Widget? icon,
    required Widget label,
  }) {
    return OutlinedButton.icon(
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
