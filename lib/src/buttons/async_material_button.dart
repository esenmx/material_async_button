part of '../../material_async_button.dart';

/// Abstract base for the Material wrapper widgets shipped with this package
/// ([ElevatedAsyncButton], [FilledAsyncButton], [OutlinedAsyncButton],
/// [TextAsyncButton], [IconAsyncButton]).
///
/// Owns the shared async surface — [onPressed], [controller], and the
/// theme-override knobs. Direct subclasses ([IconAsyncButton],
/// [FloatingActionAsyncButton]) implement [build] and forward these fields to
/// an [AsyncButton]; [AsyncStandardMaterialButton] provides it. For custom
/// non-Material buttons reach for [AsyncButton] directly.
abstract class const AsyncMaterialButton({
  /// See [AsyncButton.child].
  required final Widget child,

  /// See [AsyncButton.onPressed].
  required final AsyncCallback? onPressed,

  /// See [AsyncButton.enabled].
  final bool enabled = true,

  /// See [AsyncButton.controller].
  final AsyncButtonController? controller,

  /// See [AsyncButton.loadingBuilder].
  final WidgetBuilder? loadingBuilder,

  /// See [AsyncButton.transitionBuilder].
  final AsyncButtonTransitionBuilder? transitionBuilder,
  super.key,
}) extends StatelessWidget {
  /// Subclass-only constructor. Forwards every field to [AsyncButton]. See
  /// [AsyncButton] for the semantics of each parameter.
  this;

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
/// subclass only has to render its specific button widget via `_buildButton` /
/// `_buildIconButton`.
///
/// [IconAsyncButton] does not extend this — it carries a different field
/// set ([IconButton]'s API).
///
/// Sealed: the four concrete buttons are the whole hierarchy and the build
/// hooks are library-private. To build a custom async button, compose
/// [AsyncButton] directly.
sealed class const AsyncStandardMaterialButton({
  required super.child,
  required super.onPressed,
  super.enabled,
  super.controller,
  super.loadingBuilder,
  super.transitionBuilder,

  /// Forwarded to the underlying Material button.
  final VoidCallback? onLongPress,

  /// Forwarded to the underlying Material button.
  final ValueChanged<bool>? onHover,

  /// Forwarded to the underlying Material button.
  final ValueChanged<bool>? onFocusChange,

  /// Forwarded to the underlying Material button.
  final ButtonStyle? style,

  /// Forwarded to the underlying Material button.
  final FocusNode? focusNode,

  /// Forwarded to the underlying Material button.
  final bool autofocus = false,

  /// Forwarded to the underlying Material button.
  final Clip clipBehavior = .none,

  /// Forwarded to the underlying Material button.
  final WidgetStatesController? statesController,
  final Widget? _icon,
  final IconAlignment? _iconAlignment,
  super.key,
}) extends AsyncMaterialButton {
  /// Subclass-only constructor. Adds Material parameters common to
  /// [ElevatedButton]/[FilledButton]/[OutlinedButton]/[TextButton].
  this;

  /// The default spinner sizing for this button's current shape: an `.icon`
  /// constructor lays out an icon beside the label, so its idle row height is
  /// `max(iconSize, lineBox)`; a plain constructor shows only the label, so it
  /// tracks the label's line box.
  _SpinnerSize get _loadingSizing => _icon != null ? .max : .fontSize;

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
          return _buildIconButton(
            onPressed: callback,
            onLongPress: longPress,
            icon: isLoading ? null : _icon,
            label: animatedChild,
          );
        }
        return _buildButton(
          onPressed: callback,
          onLongPress: longPress,
          child: animatedChild,
        );
      },
      child: child,
    );
  }

  /// Builds the non-icon Material button widget.
  Widget _buildButton({
    required VoidCallback? onPressed,
    required VoidCallback? onLongPress,
    required Widget child,
  });

  /// Builds the icon Material button widget.
  Widget _buildIconButton({
    required VoidCallback? onPressed,
    required VoidCallback? onLongPress,
    required Widget? icon,
    required Widget label,
  });
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
class const _DefaultLoadingSpinner(final _SpinnerSize sizing)
    extends StatelessWidget {
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
