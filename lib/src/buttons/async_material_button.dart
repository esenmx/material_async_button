part of '../../material_async_button.dart';

/// Abstract base for the Material wrapper widgets shipped with this package
/// ([ElevatedAsyncButton], [FilledAsyncButton], [OutlinedAsyncButton],
/// [TextAsyncButton], [IconAsyncButton]).
///
/// Owns the shared async surface — [onPressed], [controller], and the
/// theme-override knobs. Subclasses implement [build] and forward these fields
/// to an [AsyncButton]. For custom non-Material buttons reach for [AsyncButton]
/// directly.
abstract class AsyncMaterialButton extends StatelessWidget {
  /// Subclass-only constructor. Forwards every field to [AsyncButton]. See
  /// [AsyncButton] for the semantics of each parameter.
  const AsyncMaterialButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.enabled = true,
    this.controller,
    this.loadingBuilder,
    this.transitionBuilder,
  });

  /// See [AsyncButton.child].
  final Widget child;

  /// See [AsyncButton.onPressed].
  final AsyncCallback? onPressed;

  /// See [AsyncButton.enabled].
  final bool enabled;

  /// See [AsyncButton.controller].
  final AsyncButtonController? controller;

  /// See [AsyncButton.loadingBuilder].
  final WidgetBuilder? loadingBuilder;

  /// See [AsyncButton.transitionBuilder].
  final AsyncButtonTransitionBuilder? transitionBuilder;
}

/// Sub-base for the four [AsyncMaterialButton]s that share the standard
/// [ButtonStyleButton] surface ([ElevatedAsyncButton], [FilledAsyncButton],
/// [OutlinedAsyncButton], [TextAsyncButton]). Centralises the common
/// Material parameters and the `.icon` constructor pieces so each concrete
/// subclass only has to render its specific button widget.
///
/// [IconAsyncButton] does not extend this — it carries a different field
/// set ([IconButton]'s API).
abstract class AsyncStandardMaterialButton extends AsyncMaterialButton {
  /// Subclass-only constructor. Adds Material parameters common to
  /// [ElevatedButton]/[FilledButton]/[OutlinedButton]/[TextButton].
  const AsyncStandardMaterialButton({
    super.key,
    required super.child,
    required super.onPressed,
    super.enabled,
    super.controller,
    super.loadingBuilder,
    super.transitionBuilder,
    this.onLongPress,
    this.onHover,
    this.onFocusChange,
    this.style,
    this.focusNode,
    this.autofocus = false,
    this.clipBehavior = .none,
    this.statesController,
    Widget? icon,
    IconAlignment? iconAlignment,
  }) : _icon = icon,
       _iconAlignment = iconAlignment;

  /// Forwarded to the underlying Material button.
  final VoidCallback? onLongPress;

  /// Forwarded to the underlying Material button.
  final ValueChanged<bool>? onHover;

  /// Forwarded to the underlying Material button.
  final ValueChanged<bool>? onFocusChange;

  /// Forwarded to the underlying Material button.
  final ButtonStyle? style;

  /// Forwarded to the underlying Material button.
  final FocusNode? focusNode;

  /// Forwarded to the underlying Material button.
  final bool autofocus;

  /// Forwarded to the underlying Material button.
  final Clip clipBehavior;

  /// Forwarded to the underlying Material button.
  final WidgetStatesController? statesController;

  final Widget? _icon;
  final IconAlignment? _iconAlignment;
}
