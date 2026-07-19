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
    required this.child,
    required this.onPressed,
    this.enabled = true,
    this.controller,
    this.loadingBuilder,
    this.transitionBuilder,
    super.key,
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

  /// Resolves the loading builder this button hands to its [AsyncButton]: the
  /// per-widget [loadingBuilder] wins, then [AsyncButtonTheme.loadingBuilder],
  /// then a default spinner sized for the button's shape (see [_SpinnerSize]).
  ///
  /// The shape-aware default exists because the bare [AsyncButtonSpinner] sizes
  /// to the ambient label line box — right for a text label, but an
  /// icon-bearing button's idle height can be driven by the icon (taller than
  /// the line box), so it would shrink while loading unless the icon is taken
  /// into account.
  WidgetBuilder _resolveLoadingBuilder(
    BuildContext context,
    _SpinnerSize sizing,
  ) {
    return loadingBuilder ??
        AsyncButtonTheme.of(context).loadingBuilder ??
        (context) => _DefaultLoadingSpinner(sizing);
  }
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
    super.key,
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

  /// The default spinner sizing for this button's current shape: an `.icon`
  /// constructor lays out an icon beside the label, so its idle row height is
  /// `max(iconSize, lineBox)`; a plain constructor shows only the label, so it
  /// tracks the label's line box.
  _SpinnerSize get _loadingSizing => _icon != null ? .max : .fontSize;
}

/// How [_DefaultLoadingSpinner] derives its dimension from the ambient theme,
/// chosen per button shape so the loading view keeps the idle footprint.
enum _SpinnerSize {
  /// Text-only buttons — match the label's line-box height (its idle extent,
  /// taller than the raw `fontSize`).
  fontSize,

  /// Icon-only buttons ([IconAsyncButton]) — match the icon size.
  iconSize,

  /// Icon + label buttons (the `.icon` constructors) — match the taller of the
  /// icon size and the label line box, i.e. the idle row height.
  max,
}

double? _largest(double? a, double? b) => a == null
    ? b
    : b == null
    ? a
    : (a > b ? a : b);

/// The shape-aware default loading view. Reads the resolved [IconTheme] /
/// [DefaultTextStyle] set by the surrounding Material button (the same scope
/// [AsyncButtonSpinner] reads for its colour) and sizes the spinner so the
/// button holds its idle height while loading.
class _DefaultLoadingSpinner extends StatelessWidget {
  const _DefaultLoadingSpinner(this.sizing);

  final _SpinnerSize sizing;

  @override
  Widget build(BuildContext context) {
    final iconSize = IconTheme.of(context).size;
    final dimension = switch (sizing) {
      .fontSize => _ambientTextLineBox(context),
      .iconSize => iconSize,
      .max => _largest(iconSize, _ambientTextLineBox(context)),
    };
    // A null dimension (icon-only with an unset icon size) lets
    // AsyncButtonSpinner fall back to the ambient line box.
    return AsyncButtonSpinner(size: dimension);
  }
}
