part of '../../material_async_button.dart';

enum _FloatingActionButtonVariant { standard, small, large, extended }

class const _DefaultHeroTag();

const Object _defaultHeroTag = _DefaultHeroTag();

typedef _FabPaint = ({
  Color? foreground,
  Color? background,
  double? disabledElevation,
});

/// Async-aware [FloatingActionButton]. While `onPressed` is running the child
/// (or label, for `.extended`) is swapped for the loading widget.
///
/// [FloatingActionButton] has no disabled look of its own, so whenever this
/// button is disabled (`enabled: false`, `onPressed: null`, or busy under
/// `disableWhileLoading`) it paints Material's disabled button tokens:
/// `onSurface` at 12% for the fill and 38% for the foreground (overriding
/// [backgroundColor] and [foregroundColor]), and an elevation of
/// [disabledElevation], then [FloatingActionButtonThemeData.disabledElevation],
/// then 0.
final class FloatingActionAsyncButton extends AsyncMaterialButton {
  /// Mirrors [FloatingActionButton.new].
  const new({
    required super.onPressed,
    Widget? child,
    super.enabled,
    super.controller,
    super.loadingBuilder,
    super.transitionBuilder,
    super.maintainSize,
    super.minLoadingDuration,
    super.disableWhileLoading,
    this.tooltip,
    this.foregroundColor,
    this.backgroundColor,
    this.focusColor,
    this.hoverColor,
    this.splashColor,
    this.elevation,
    this.focusElevation,
    this.hoverElevation,
    this.highlightElevation,
    this.disabledElevation,
    this.mouseCursor,
    this.shape,
    this.clipBehavior = .none,
    this.focusNode,
    this.autofocus = false,
    this.materialTapTargetSize,
    this.isExtended = false,
    this.heroTag = _defaultHeroTag,
    this.enableFeedback,
    this.mini = false,
    super.key,
  }) : _variant = .standard,
       _icon = null,
       _extendedIconLabelSpacing = null,
       _extendedPadding = null,
       _extendedTextStyle = null,
       super(child: child ?? const SizedBox.shrink());

  /// Mirrors [FloatingActionButton.small].
  const new small({
    required super.onPressed,
    Widget? child,
    super.enabled,
    super.controller,
    super.loadingBuilder,
    super.transitionBuilder,
    super.maintainSize,
    super.minLoadingDuration,
    super.disableWhileLoading,
    this.tooltip,
    this.foregroundColor,
    this.backgroundColor,
    this.focusColor,
    this.hoverColor,
    this.splashColor,
    this.elevation,
    this.focusElevation,
    this.hoverElevation,
    this.highlightElevation,
    this.disabledElevation,
    this.mouseCursor,
    this.shape,
    this.clipBehavior = .none,
    this.focusNode,
    this.autofocus = false,
    this.materialTapTargetSize,
    this.heroTag = _defaultHeroTag,
    this.enableFeedback,
    super.key,
  }) : _variant = .small,
       mini = false,
       isExtended = false,
       _icon = null,
       _extendedIconLabelSpacing = null,
       _extendedPadding = null,
       _extendedTextStyle = null,
       super(child: child ?? const SizedBox.shrink());

  /// Mirrors [FloatingActionButton.large].
  const new large({
    required super.onPressed,
    Widget? child,
    super.enabled,
    super.controller,
    super.loadingBuilder,
    super.transitionBuilder,
    super.maintainSize,
    super.minLoadingDuration,
    super.disableWhileLoading,
    this.tooltip,
    this.foregroundColor,
    this.backgroundColor,
    this.focusColor,
    this.hoverColor,
    this.splashColor,
    this.elevation,
    this.focusElevation,
    this.hoverElevation,
    this.highlightElevation,
    this.disabledElevation,
    this.mouseCursor,
    this.shape,
    this.clipBehavior = .none,
    this.focusNode,
    this.autofocus = false,
    this.materialTapTargetSize,
    this.heroTag = _defaultHeroTag,
    this.enableFeedback,
    super.key,
  }) : _variant = .large,
       mini = false,
       isExtended = false,
       _icon = null,
       _extendedIconLabelSpacing = null,
       _extendedPadding = null,
       _extendedTextStyle = null,
       super(child: child ?? const SizedBox.shrink());

  /// Mirrors [FloatingActionButton.extended].
  const new extended({
    required super.onPressed,
    required Widget label,
    this._icon,
    super.enabled,
    super.controller,
    super.loadingBuilder,
    super.transitionBuilder,
    super.maintainSize,
    super.minLoadingDuration,
    super.disableWhileLoading,
    this.tooltip,
    this.foregroundColor,
    this.backgroundColor,
    this.focusColor,
    this.hoverColor,
    this.splashColor,
    this.elevation,
    this.focusElevation,
    this.hoverElevation,
    this.highlightElevation,
    this.disabledElevation,
    this.mouseCursor,
    this.shape,
    this.clipBehavior = .none,
    this.focusNode,
    this.autofocus = false,
    this.materialTapTargetSize,
    this.isExtended = true,
    this.heroTag = _defaultHeroTag,
    this.enableFeedback,
    this._extendedIconLabelSpacing,
    this._extendedPadding,
    this._extendedTextStyle,
    super.key,
  }) : _variant = .extended,
       mini = false,
       super(child: label);

  /// Forwarded to the underlying [FloatingActionButton].
  final String? tooltip;

  /// Forwarded to the underlying [FloatingActionButton], except while
  /// disabled; see the class doc.
  final Color? foregroundColor;

  /// Forwarded to the underlying [FloatingActionButton], except while
  /// disabled; see the class doc.
  final Color? backgroundColor;

  /// Forwarded to the underlying [FloatingActionButton].
  final Color? focusColor;

  /// Forwarded to the underlying [FloatingActionButton].
  final Color? hoverColor;

  /// Forwarded to the underlying [FloatingActionButton].
  final Color? splashColor;

  /// Forwarded to the underlying [FloatingActionButton].
  final double? elevation;

  /// Forwarded to the underlying [FloatingActionButton].
  final double? focusElevation;

  /// Forwarded to the underlying [FloatingActionButton].
  final double? hoverElevation;

  /// Forwarded to the underlying [FloatingActionButton].
  final double? highlightElevation;

  /// Forwarded to the underlying [FloatingActionButton]. When null, a
  /// disabled button uses [FloatingActionButtonThemeData.disabledElevation],
  /// then 0, not [elevation]; see the class doc.
  final double? disabledElevation;

  /// Forwarded to the underlying [FloatingActionButton].
  final MouseCursor? mouseCursor;

  /// Forwarded to the underlying [FloatingActionButton].
  final ShapeBorder? shape;

  /// Forwarded to the underlying [FloatingActionButton].
  final Clip clipBehavior;

  /// Forwarded to the underlying [FloatingActionButton].
  final FocusNode? focusNode;

  /// Forwarded to the underlying [FloatingActionButton].
  final bool autofocus;

  /// Forwarded to the underlying [FloatingActionButton].
  final MaterialTapTargetSize? materialTapTargetSize;

  /// Forwarded to the underlying [FloatingActionButton].
  final bool isExtended;

  /// Forwarded to the underlying [FloatingActionButton]. The default is a
  /// package sentinel, not Flutter's default tag, so no hero flight runs
  /// between a plain [FloatingActionButton] and an async one.
  final Object? heroTag;

  /// Forwarded to the underlying [FloatingActionButton].
  final bool? enableFeedback;

  /// Forwarded to the underlying [FloatingActionButton].
  final bool mini;

  final Widget? _icon;
  final double? _extendedIconLabelSpacing;
  final EdgeInsetsGeometry? _extendedPadding;
  final TextStyle? _extendedTextStyle;

  final _FloatingActionButtonVariant _variant;

  @override
  Widget build(BuildContext context) {
    // A collapsed extended FAB renders only its icon slot, so the loading view
    // must occupy the icon slot rather than the hidden label.
    final collapsed = _variant == .extended && !isExtended;
    final keepFootprint = _resolveMaintainSize(context);
    return AsyncButton(
      onPressed: onPressed,
      enabled: enabled,
      controller: controller,
      loadingBuilder: _resolveLoadingBuilder(
        context,
        _variant != .extended || collapsed
            ? .iconSize
            : (keepFootprint && _icon != null ? .fontSize : .max),
      ),
      transitionBuilder: transitionBuilder,
      maintainSize: keepFootprint,
      minLoadingDuration: minLoadingDuration,
      disableWhileLoading: disableWhileLoading,
      builder: (context, animatedChild, callback, isLoading) {
        final paint = _paint(context, disabled: callback == null);
        return switch (_variant) {
          .standard => _buildStandard(callback, animatedChild, paint),
          .small ||
          .large => _buildSmallOrLarge(callback, animatedChild, paint),
          .extended => _buildExtended(
            callback,
            animatedChild,
            paint,
            isLoading: isLoading,
            collapsed: collapsed,
            keepFootprint: keepFootprint,
          ),
        };
      },
      child: collapsed ? (_icon ?? const SizedBox.shrink()) : child,
    );
  }

  _FabPaint _paint(BuildContext context, {required bool disabled}) {
    if (!disabled) {
      return (
        foreground: foregroundColor,
        background: backgroundColor,
        disabledElevation: disabledElevation,
      );
    }
    final onSurface = Theme.of(context).colorScheme.onSurface;
    // Material's buttons quantize onSurface(0.38) and onSurface(0.12) to 8-bit
    // alpha; match them exactly.
    return (
      foreground: onSurface.withAlpha(0x61),
      background: onSurface.withAlpha(0x1F),
      disabledElevation:
          disabledElevation ??
          FloatingActionButtonTheme.of(context).disabledElevation ??
          0,
    );
  }

  Widget _buildStandard(
    VoidCallback? callback,
    Widget animatedChild,
    _FabPaint paint,
  ) {
    return FloatingActionButton(
      onPressed: callback,
      tooltip: tooltip,
      foregroundColor: paint.foreground,
      backgroundColor: paint.background,
      focusColor: focusColor,
      hoverColor: hoverColor,
      splashColor: splashColor,
      elevation: elevation,
      focusElevation: focusElevation,
      hoverElevation: hoverElevation,
      highlightElevation: highlightElevation,
      disabledElevation: paint.disabledElevation,
      mouseCursor: mouseCursor,
      shape: shape,
      clipBehavior: clipBehavior,
      focusNode: focusNode,
      autofocus: autofocus,
      materialTapTargetSize: materialTapTargetSize,
      isExtended: isExtended,
      heroTag: heroTag,
      enableFeedback: enableFeedback,
      mini: mini,
      child: animatedChild,
    );
  }

  Widget _buildSmallOrLarge(
    VoidCallback? callback,
    Widget animatedChild,
    _FabPaint paint,
  ) {
    final constructor = switch (_variant) {
      .small => FloatingActionButton.small,
      _ => FloatingActionButton.large,
    };
    return constructor(
      onPressed: callback,
      tooltip: tooltip,
      foregroundColor: paint.foreground,
      backgroundColor: paint.background,
      focusColor: focusColor,
      hoverColor: hoverColor,
      splashColor: splashColor,
      elevation: elevation,
      focusElevation: focusElevation,
      hoverElevation: hoverElevation,
      highlightElevation: highlightElevation,
      disabledElevation: paint.disabledElevation,
      mouseCursor: mouseCursor,
      shape: shape,
      clipBehavior: clipBehavior,
      focusNode: focusNode,
      autofocus: autofocus,
      materialTapTargetSize: materialTapTargetSize,
      heroTag: heroTag,
      enableFeedback: enableFeedback,
      child: animatedChild,
    );
  }

  Widget _buildExtended(
    VoidCallback? callback,
    Widget animatedChild,
    _FabPaint paint, {
    required bool isLoading,
    required bool collapsed,
    required bool keepFootprint,
  }) {
    return FloatingActionButton.extended(
      onPressed: callback,
      label: collapsed ? child : animatedChild,
      icon: collapsed
          ? animatedChild
          : (isLoading && !keepFootprint ? null : _icon),
      tooltip: tooltip,
      foregroundColor: paint.foreground,
      backgroundColor: paint.background,
      focusColor: focusColor,
      hoverColor: hoverColor,
      splashColor: splashColor,
      elevation: elevation,
      focusElevation: focusElevation,
      hoverElevation: hoverElevation,
      highlightElevation: highlightElevation,
      disabledElevation: paint.disabledElevation,
      mouseCursor: mouseCursor,
      shape: shape,
      clipBehavior: clipBehavior,
      focusNode: focusNode,
      autofocus: autofocus,
      materialTapTargetSize: materialTapTargetSize,
      isExtended: isExtended,
      heroTag: heroTag,
      enableFeedback: enableFeedback,
      extendedIconLabelSpacing: _extendedIconLabelSpacing,
      extendedPadding: _extendedPadding,
      extendedTextStyle: _extendedTextStyle,
    );
  }
}
