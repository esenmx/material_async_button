part of '../../material_async_button.dart';

enum _FilledButtonVariant { primary, tonal }

/// Async-aware [FilledButton] with all four Material 3 flavors:
/// [FilledAsyncButton.new], [FilledAsyncButton.tonal],
/// [FilledAsyncButton.icon], [FilledAsyncButton.tonalIcon].
class FilledAsyncButton extends AsyncStandardMaterialButton {
  /// Mirrors [FilledButton.new].
  const FilledAsyncButton({
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
  }) : _variant = .primary;

  /// Mirrors [FilledButton.tonal].
  const FilledAsyncButton.tonal({
    required super.child,
    required super.onPressed,
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
  }) : _variant = .tonal;

  /// Mirrors [FilledButton.icon].
  const FilledAsyncButton.icon({
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
  }) : _variant = .primary,
       super(child: label);

  /// Mirrors [FilledButton.tonalIcon].
  const FilledAsyncButton.tonalIcon({
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
  }) : _variant = .tonal,
       super(child: label);

  final _FilledButtonVariant _variant;

  @override
  Widget _buildButton({
    required VoidCallback? onPressed,
    required VoidCallback? onLongPress,
    required Widget child,
  }) {
    return switch (_variant) {
      .primary => FilledButton(
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
      ),
      .tonal => FilledButton.tonal(
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
      ),
    };
  }

  @override
  Widget _buildIconButton({
    required VoidCallback? onPressed,
    required VoidCallback? onLongPress,
    required Widget? icon,
    required Widget label,
  }) {
    return switch (_variant) {
      .primary => FilledButton.icon(
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
      ),
      .tonal => FilledButton.tonalIcon(
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
      ),
    };
  }
}
