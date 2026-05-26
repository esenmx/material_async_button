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
  /// Subclass-only constructor. Forwards every field to [AsyncButton]. See
  /// [AsyncButton] for the semantics of each parameter.
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

  /// See [AsyncButton.child].
  final Widget child;

  /// See [AsyncButton.onPressed].
  final AsyncCallback? onPressed;

  /// See [AsyncButton.controller].
  final AsyncButtonController? controller;

  /// See [AsyncButton.onSuccess].
  final VoidCallback? onSuccess;

  /// See [AsyncButton.onError].
  final AsyncButtonErrorCallback? onError;

  /// See [AsyncButton.onStateChanged].
  final ValueChanged<AsyncButtonStatus>? onStateChanged;

  /// See [AsyncButton.confirmBeforePress].
  final Future<bool> Function(BuildContext context)? confirmBeforePress;

  /// See [AsyncButton.loadingChild].
  final Widget? loadingChild;

  /// See [AsyncButton.successChild].
  final Widget? successChild;

  /// See [AsyncButton.errorChild].
  final Widget? errorChild;

  /// See [AsyncButton.disabled].
  final bool disabled;

  /// See [AsyncButton.switchDuration].
  final Duration? switchDuration;

  /// See [AsyncButton.transitionBuilder].
  final AnimatedSwitcherTransitionBuilder? transitionBuilder;

  /// See [AsyncButton.successDisplayDuration].
  final Duration? successDisplayDuration;

  /// See [AsyncButton.errorDisplayDuration].
  final Duration? errorDisplayDuration;

  /// See [AsyncButton.cooldownDuration].
  final Duration? cooldownDuration;

  /// See [AsyncButton.animateSize].
  final bool? animateSize;

  /// See [AsyncButton.hapticOn].
  final HapticOn? hapticOn;

  /// See [AsyncButton.announceSemantics].
  final bool? announceSemantics;

  /// See [AsyncButton.rethrowErrors].
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
  /// Subclass-only constructor. Adds Material parameters common to
  /// [ElevatedButton]/[FilledButton]/[OutlinedButton]/[TextButton].
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
  final Clip? clipBehavior;

  /// Forwarded to the underlying Material button.
  final WidgetStatesController? statesController;

  final Widget? _icon;
  final IconAlignment? _iconAlignment;
}
