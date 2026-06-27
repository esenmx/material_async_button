part of '../../material_async_button.dart';

enum _FloatingActionButtonVariant { standard, small, large, extended }

class _DefaultHeroTag {
  const _DefaultHeroTag();
}

const Object _defaultHeroTag = _DefaultHeroTag();

/// Async-aware [FloatingActionButton]. While `onPressed` is running the child
/// (or label, for `.extended`) is swapped for the loading widget.
class FloatingActionAsyncButton extends AsyncMaterialButton {
  /// Mirrors [FloatingActionButton.new].
  const FloatingActionAsyncButton({
    super.key,
    required super.onPressed,
    Widget? child,
    super.enabled,
    super.controller,
    super.loadingBuilder,
    super.transitionBuilder,
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
  }) : _variant = .standard,
       _icon = null,
       _extendedIconLabelSpacing = null,
       _extendedPadding = null,
       _extendedTextStyle = null,
       super(child: child ?? const SizedBox.shrink());

  /// Mirrors [FloatingActionButton.small].
  const FloatingActionAsyncButton.small({
    super.key,
    required super.onPressed,
    Widget? child,
    super.enabled,
    super.controller,
    super.loadingBuilder,
    super.transitionBuilder,
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
  }) : _variant = .small,
       mini = false,
       isExtended = false,
       _icon = null,
       _extendedIconLabelSpacing = null,
       _extendedPadding = null,
       _extendedTextStyle = null,
       super(child: child ?? const SizedBox.shrink());

  /// Mirrors [FloatingActionButton.large].
  const FloatingActionAsyncButton.large({
    super.key,
    required super.onPressed,
    Widget? child,
    super.enabled,
    super.controller,
    super.loadingBuilder,
    super.transitionBuilder,
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
  }) : _variant = .large,
       mini = false,
       isExtended = false,
       _icon = null,
       _extendedIconLabelSpacing = null,
       _extendedPadding = null,
       _extendedTextStyle = null,
       super(child: child ?? const SizedBox.shrink());

  /// Mirrors [FloatingActionButton.extended].
  const FloatingActionAsyncButton.extended({
    super.key,
    required super.onPressed,
    required Widget label,
    Widget? icon,
    super.enabled,
    super.controller,
    super.loadingBuilder,
    super.transitionBuilder,
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
    double? extendedIconLabelSpacing,
    EdgeInsetsGeometry? extendedPadding,
    TextStyle? extendedTextStyle,
  }) : _variant = .extended,
       mini = false,
       _icon = icon,
       _extendedIconLabelSpacing = extendedIconLabelSpacing,
       _extendedPadding = extendedPadding,
       _extendedTextStyle = extendedTextStyle,
       super(child: label);

  /// Forwarded to the underlying [FloatingActionButton].
  final String? tooltip;

  /// Forwarded to the underlying [FloatingActionButton].
  final Color? foregroundColor;

  /// Forwarded to the underlying [FloatingActionButton].
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

  /// Forwarded to the underlying [FloatingActionButton].
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

  /// Forwarded to the underlying [FloatingActionButton].
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
    return AsyncButton(
      onPressed: onPressed,
      enabled: enabled,
      controller: controller,
      loadingBuilder: _resolveLoadingBuilder(
        context,
        _variant == .extended ? .max : .iconSize,
      ),
      transitionBuilder: transitionBuilder,
      builder: (context, animatedChild, callback, isLoading) {
        final hasHeroTag = heroTag != _defaultHeroTag;
        return switch (_variant) {
          .standard => FloatingActionButton(
            onPressed: callback,
            tooltip: tooltip,
            foregroundColor: foregroundColor,
            backgroundColor: backgroundColor,
            focusColor: focusColor,
            hoverColor: hoverColor,
            splashColor: splashColor,
            elevation: elevation,
            focusElevation: focusElevation,
            hoverElevation: hoverElevation,
            highlightElevation: highlightElevation,
            disabledElevation: disabledElevation,
            mouseCursor: mouseCursor,
            shape: shape,
            clipBehavior: clipBehavior,
            focusNode: focusNode,
            autofocus: autofocus,
            materialTapTargetSize: materialTapTargetSize,
            isExtended: isExtended,
            heroTag: hasHeroTag ? heroTag : const _DefaultHeroTag(),
            enableFeedback: enableFeedback,
            mini: mini,
            child: animatedChild,
          ),
          .small => FloatingActionButton.small(
            onPressed: callback,
            tooltip: tooltip,
            foregroundColor: foregroundColor,
            backgroundColor: backgroundColor,
            focusColor: focusColor,
            hoverColor: hoverColor,
            splashColor: splashColor,
            elevation: elevation,
            focusElevation: focusElevation,
            hoverElevation: hoverElevation,
            highlightElevation: highlightElevation,
            disabledElevation: disabledElevation,
            mouseCursor: mouseCursor,
            shape: shape,
            clipBehavior: clipBehavior,
            focusNode: focusNode,
            autofocus: autofocus,
            materialTapTargetSize: materialTapTargetSize,
            heroTag: hasHeroTag ? heroTag : const _DefaultHeroTag(),
            enableFeedback: enableFeedback,
            child: animatedChild,
          ),
          .large => FloatingActionButton.large(
            onPressed: callback,
            tooltip: tooltip,
            foregroundColor: foregroundColor,
            backgroundColor: backgroundColor,
            focusColor: focusColor,
            hoverColor: hoverColor,
            splashColor: splashColor,
            elevation: elevation,
            focusElevation: focusElevation,
            hoverElevation: hoverElevation,
            highlightElevation: highlightElevation,
            disabledElevation: disabledElevation,
            mouseCursor: mouseCursor,
            shape: shape,
            clipBehavior: clipBehavior,
            focusNode: focusNode,
            autofocus: autofocus,
            materialTapTargetSize: materialTapTargetSize,
            heroTag: hasHeroTag ? heroTag : const _DefaultHeroTag(),
            enableFeedback: enableFeedback,
            child: animatedChild,
          ),
          .extended => FloatingActionButton.extended(
            onPressed: callback,
            label: animatedChild,
            icon: isLoading ? null : _icon,
            tooltip: tooltip,
            foregroundColor: foregroundColor,
            backgroundColor: backgroundColor,
            focusColor: focusColor,
            hoverColor: hoverColor,
            splashColor: splashColor,
            elevation: elevation,
            focusElevation: focusElevation,
            hoverElevation: hoverElevation,
            highlightElevation: highlightElevation,
            disabledElevation: disabledElevation,
            mouseCursor: mouseCursor,
            shape: shape,
            clipBehavior: clipBehavior,
            focusNode: focusNode,
            autofocus: autofocus,
            materialTapTargetSize: materialTapTargetSize,
            isExtended: isExtended,
            heroTag: hasHeroTag ? heroTag : const _DefaultHeroTag(),
            enableFeedback: enableFeedback,
            extendedIconLabelSpacing: _extendedIconLabelSpacing,
            extendedPadding: _extendedPadding,
            extendedTextStyle: _extendedTextStyle,
          ),
        };
      },
      child: child,
    );
  }
}
