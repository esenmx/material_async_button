part of '../../material_async_button.dart';

enum _FilledVariant { primary, tonal }

/// Async-aware [FilledButton] with all four Material 3 flavors:
/// [FilledAsyncButton.new], [FilledAsyncButton.tonal],
/// [FilledAsyncButton.icon], [FilledAsyncButton.tonalIcon].
class FilledAsyncButton extends AsyncStandardMaterialButton {
  /// Mirrors [FilledButton.new].
  const FilledAsyncButton({
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
  }) : _variant = .primary;

  /// Mirrors [FilledButton.tonal].
  const FilledAsyncButton.tonal({
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
    super.enabled,
    super.controller,
    super.loadingBuilder,
    super.transitionBuilder,
    required super.child,
  }) : _variant = .tonal;

  /// Mirrors [FilledButton.icon].
  const FilledAsyncButton.icon({
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
  }) : _variant = .primary,
       super(child: label);

  /// Mirrors [FilledButton.tonalIcon].
  const FilledAsyncButton.tonalIcon({
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
  }) : _variant = .tonal,
       super(child: label);

  final _FilledVariant _variant;

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
          return switch (_variant) {
            .primary => FilledButton.icon(
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
            ),
            .tonal => FilledButton.tonalIcon(
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
            ),
          };
        }
        return switch (_variant) {
          .primary => FilledButton(
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
          ),
          .tonal => FilledButton.tonal(
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
          ),
        };
      },
      child: child,
    );
  }
}
