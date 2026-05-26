part of '../../material_async_button.dart';

/// Abstract base for the Material wrapper widgets shipped with this package
/// ([ElevatedAsyncButton], [FilledAsyncButton], [OutlinedAsyncButton],
/// [TextAsyncButton], [IconAsyncButton]).
///
/// Owns the shared async-status surface — [onPressed], [controller], and
/// the theme-override knobs. Subclasses implement [build] and forward these
/// fields to an [AsyncButton]. For custom non-Material buttons reach for
/// [AsyncButton] directly.
abstract class AsyncMaterialButton extends StatelessWidget {
  const AsyncMaterialButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.controller,
    this.onSuccess,
    this.onError,
    this.onStateChanged,
    this.confirmBeforePress,
    this.loadingChild,
    this.successChild,
    this.errorChild,
    this.disabled = false,
    this.switchDuration,
    this.transitionBuilder,
    this.successDisplayDuration,
    this.errorDisplayDuration,
    this.cooldownDuration,
    this.animateSize,
    this.hapticOn,
    this.announceSemantics,
    this.rethrowErrors,
  });

  final Widget child;
  final AsyncCallback? onPressed;
  final AsyncButtonController? controller;
  final VoidCallback? onSuccess;
  final AsyncButtonErrorCallback? onError;
  final ValueChanged<AsyncButtonStatus>? onStateChanged;
  final Future<bool> Function(BuildContext context)? confirmBeforePress;
  final Widget? loadingChild;
  final Widget? successChild;
  final Widget? errorChild;
  final bool disabled;
  final Duration? switchDuration;
  final AnimatedSwitcherTransitionBuilder? transitionBuilder;
  final Duration? successDisplayDuration;
  final Duration? errorDisplayDuration;
  final Duration? cooldownDuration;
  final bool? animateSize;
  final HapticOn? hapticOn;
  final bool? announceSemantics;
  final bool? rethrowErrors;
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
  const AsyncStandardMaterialButton({
    super.key,
    required super.child,
    required super.onPressed,
    super.controller,
    super.onSuccess,
    super.onError,
    super.onStateChanged,
    super.confirmBeforePress,
    super.loadingChild,
    super.successChild,
    super.errorChild,
    super.disabled,
    super.switchDuration,
    super.transitionBuilder,
    super.successDisplayDuration,
    super.errorDisplayDuration,
    super.cooldownDuration,
    super.animateSize,
    super.hapticOn,
    super.announceSemantics,
    super.rethrowErrors,
    this.onLongPress,
    this.onHover,
    this.onFocusChange,
    this.style,
    this.focusNode,
    this.autofocus = false,
    this.clipBehavior,
    this.statesController,
    Widget? icon,
    IconAlignment? iconAlignment,
  }) : _icon = icon,
       _iconAlignment = iconAlignment;

  final VoidCallback? onLongPress;
  final ValueChanged<bool>? onHover;
  final ValueChanged<bool>? onFocusChange;
  final ButtonStyle? style;
  final FocusNode? focusNode;
  final bool autofocus;
  final Clip? clipBehavior;
  final WidgetStatesController? statesController;
  final Widget? _icon;
  final IconAlignment? _iconAlignment;
}
