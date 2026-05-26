part of '../material_async_button.dart';

/// Which haptic event, if any, to fire on state transitions.
enum HapticOn { none, success, error, both }

/// App-wide defaults for `material_async_button` widgets, attached as a
/// [ThemeExtension] on [ThemeData].
///
/// Resolution order for any field: per-widget value, then theme value, then
/// the hard-coded fallback documented on each field.
///
/// Use [AsyncButtonTheme.material] for an opinionated baseline that
/// mirrors what most apps want; otherwise build the extension yourself with
/// only the fields you care about.
///
/// ```dart
/// MaterialApp(
///   theme: ThemeData(extensions: [AsyncButtonTheme.material()]),
/// )
/// ```
@immutable
class AsyncButtonTheme extends ThemeExtension<AsyncButtonTheme> {
  const AsyncButtonTheme({
    this.loadingChild,
    this.successChild,
    this.errorChild,
    this.switchDuration,
    this.switchReverseDuration,
    this.switchCurve,
    this.switchInCurve,
    this.switchOutCurve,
    this.transitionBuilder,
    this.successDisplayDuration,
    this.errorDisplayDuration,
    this.cooldownDuration,
    this.animateSize,
    this.sizeCurve,
    this.sizeAlignment,
    this.sizeClipBehavior,
    this.hapticOn,
    this.announceSemantics,
    this.rethrowErrors,
  });

  /// Convenience: an opinionated baseline.
  ///
  ///   - 16x16 indeterminate spinner during loading
  ///   - check icon for 800ms after success
  ///   - error icon for 800ms after error
  ///   - 200ms cross-fade between states
  ///   - light haptic on success and error
  ///   - announces state changes to assistive tech
  factory AsyncButtonTheme.material({
    Color? loadingColor,
    Color? successColor,
    Color? errorColor,
  }) {
    return AsyncButtonTheme(
      loadingChild: _DefaultLoadingChild(color: loadingColor),
      successChild: _DefaultSuccessIcon(color: successColor),
      errorChild: _DefaultErrorIcon(color: errorColor),
      switchDuration: const Duration(milliseconds: 200),
      switchReverseDuration: const Duration(milliseconds: 200),
      successDisplayDuration: const Duration(milliseconds: 800),
      errorDisplayDuration: const Duration(milliseconds: 800),
      animateSize: true,
      hapticOn: .both,
      announceSemantics: true,
    );
  }

  /// Shown in place of the button's child while the future is in flight.
  /// Falls back to a 16x16 [CircularProgressIndicator] when null.
  final Widget? loadingChild;

  /// Shown after success for [successDisplayDuration]. Null = keep the
  /// original child visible (no visual swap, only the idle delay applies).
  final Widget? successChild;

  /// Shown after error for [errorDisplayDuration]. Null = keep the
  /// original child visible.
  final Widget? errorChild;

  /// Cross-fade duration between state widgets.
  /// Falls back to 200ms when null.
  final Duration? switchDuration;
  final Duration? switchReverseDuration;

  /// Convenience: applied to both [switchInCurve] and [switchOutCurve]
  /// unless one of those is set explicitly.
  final Curve? switchCurve;
  final Curve? switchInCurve;
  final Curve? switchOutCurve;

  final AnimatedSwitcherTransitionBuilder? transitionBuilder;

  /// How long [successChild] is shown before returning to idle. Defaults to
  /// [.zero] (immediate return).
  final Duration? successDisplayDuration;

  /// How long [errorChild] is shown before returning to idle. Defaults to
  /// [.zero].
  final Duration? errorDisplayDuration;

  /// After a success/error display, keep the button disabled for this long
  /// to prevent accidental double-submits. Defaults to [.zero].
  final Duration? cooldownDuration;

  /// Whether to animate the implicit size between state widgets of differing
  /// dimensions. Falls back to `false`.
  final bool? animateSize;
  final Curve? sizeCurve;
  final AlignmentGeometry? sizeAlignment;
  final Clip? sizeClipBehavior;

  /// Whether to fire a [HapticFeedback] on success / error transitions.
  /// Defaults to [HapticOn.none].
  final HapticOn? hapticOn;

  /// Whether to announce state changes via
  /// [SemanticsService.sendAnnouncement]. Defaults to `false`.
  final bool? announceSemantics;

  /// If true, errors from `onPressed` are rethrown after the error state is
  /// displayed. Useful when a caller awaits the future. Defaults to `false`.
  final bool? rethrowErrors;

  /// An extension with every field left null. Use this to opt out of the
  /// opinionated [AsyncButtonTheme.material] baseline returned by [of] when
  /// no extension is registered on the surrounding [ThemeData].
  static const AsyncButtonTheme empty = AsyncButtonTheme();

  static final AsyncButtonTheme _materialDefaults = AsyncButtonTheme.material();

  /// Resolves the [AsyncButtonTheme] visible at [context]. Returns the
  /// extension registered on the surrounding [ThemeData] when one exists;
  /// otherwise falls back to [AsyncButtonTheme.material] so that apps
  /// without explicit theming still get the spinner / check / error UX
  /// out of the box. Pass [empty] to opt out.
  static AsyncButtonTheme of(BuildContext context) {
    return Theme.of(context).extension<AsyncButtonTheme>() ?? _materialDefaults;
  }

  @override
  AsyncButtonTheme copyWith({
    Widget? loadingChild,
    Widget? successChild,
    Widget? errorChild,
    Duration? switchDuration,
    Duration? switchReverseDuration,
    Curve? switchCurve,
    Curve? switchInCurve,
    Curve? switchOutCurve,
    AnimatedSwitcherTransitionBuilder? transitionBuilder,
    Duration? successDisplayDuration,
    Duration? errorDisplayDuration,
    Duration? cooldownDuration,
    bool? animateSize,
    Curve? sizeCurve,
    AlignmentGeometry? sizeAlignment,
    Clip? sizeClipBehavior,
    HapticOn? hapticOn,
    bool? announceSemantics,
    bool? rethrowErrors,
  }) {
    return AsyncButtonTheme(
      loadingChild: loadingChild ?? this.loadingChild,
      successChild: successChild ?? this.successChild,
      errorChild: errorChild ?? this.errorChild,
      switchDuration: switchDuration ?? this.switchDuration,
      switchReverseDuration:
          switchReverseDuration ?? this.switchReverseDuration,
      switchCurve: switchCurve ?? this.switchCurve,
      switchInCurve: switchInCurve ?? this.switchInCurve,
      switchOutCurve: switchOutCurve ?? this.switchOutCurve,
      transitionBuilder: transitionBuilder ?? this.transitionBuilder,
      successDisplayDuration:
          successDisplayDuration ?? this.successDisplayDuration,
      errorDisplayDuration: errorDisplayDuration ?? this.errorDisplayDuration,
      cooldownDuration: cooldownDuration ?? this.cooldownDuration,
      animateSize: animateSize ?? this.animateSize,
      sizeCurve: sizeCurve ?? this.sizeCurve,
      sizeAlignment: sizeAlignment ?? this.sizeAlignment,
      sizeClipBehavior: sizeClipBehavior ?? this.sizeClipBehavior,
      hapticOn: hapticOn ?? this.hapticOn,
      announceSemantics: announceSemantics ?? this.announceSemantics,
      rethrowErrors: rethrowErrors ?? this.rethrowErrors,
    );
  }

  @override
  AsyncButtonTheme lerp(
    covariant ThemeExtension<AsyncButtonTheme>? other,
    double t,
  ) {
    if (other is! AsyncButtonTheme) {
      return this;
    }
    // Widgets and enums don't lerp meaningfully; snap at the halfway point.
    final snap = t < 0.5;
    return AsyncButtonTheme(
      loadingChild: snap ? loadingChild : other.loadingChild,
      successChild: snap ? successChild : other.successChild,
      errorChild: snap ? errorChild : other.errorChild,
      switchDuration: _lerpDuration(
        switchDuration,
        other.switchDuration,
        t,
      ),
      switchReverseDuration: _lerpDuration(
        switchReverseDuration,
        other.switchReverseDuration,
        t,
      ),
      switchCurve: snap ? switchCurve : other.switchCurve,
      switchInCurve: snap ? switchInCurve : other.switchInCurve,
      switchOutCurve: snap ? switchOutCurve : other.switchOutCurve,
      transitionBuilder: snap ? transitionBuilder : other.transitionBuilder,
      successDisplayDuration: _lerpDuration(
        successDisplayDuration,
        other.successDisplayDuration,
        t,
      ),
      errorDisplayDuration: _lerpDuration(
        errorDisplayDuration,
        other.errorDisplayDuration,
        t,
      ),
      cooldownDuration: _lerpDuration(
        cooldownDuration,
        other.cooldownDuration,
        t,
      ),
      animateSize: snap ? animateSize : other.animateSize,
      sizeCurve: snap ? sizeCurve : other.sizeCurve,
      sizeAlignment: .lerp(
        sizeAlignment,
        other.sizeAlignment,
        t,
      ),
      sizeClipBehavior: snap ? sizeClipBehavior : other.sizeClipBehavior,
      hapticOn: snap ? hapticOn : other.hapticOn,
      announceSemantics: snap ? announceSemantics : other.announceSemantics,
      rethrowErrors: snap ? rethrowErrors : other.rethrowErrors,
    );
  }

  static Duration? _lerpDuration(Duration? a, Duration? b, double t) {
    if (a == null && b == null) {
      return null;
    }
    final aMs = (a ?? .zero).inMicroseconds;
    final bMs = (b ?? .zero).inMicroseconds;
    return Duration(microseconds: (aMs + (bMs - aMs) * t).round());
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is AsyncButtonTheme &&
            loadingChild == other.loadingChild &&
            successChild == other.successChild &&
            errorChild == other.errorChild &&
            switchDuration == other.switchDuration &&
            switchReverseDuration == other.switchReverseDuration &&
            switchCurve == other.switchCurve &&
            switchInCurve == other.switchInCurve &&
            switchOutCurve == other.switchOutCurve &&
            transitionBuilder == other.transitionBuilder &&
            successDisplayDuration == other.successDisplayDuration &&
            errorDisplayDuration == other.errorDisplayDuration &&
            cooldownDuration == other.cooldownDuration &&
            animateSize == other.animateSize &&
            sizeCurve == other.sizeCurve &&
            sizeAlignment == other.sizeAlignment &&
            sizeClipBehavior == other.sizeClipBehavior &&
            hapticOn == other.hapticOn &&
            announceSemantics == other.announceSemantics &&
            rethrowErrors == other.rethrowErrors;
  }

  @override
  int get hashCode {
    return Object.hashAll([
      loadingChild,
      successChild,
      errorChild,
      switchDuration,
      switchReverseDuration,
      switchCurve,
      switchInCurve,
      switchOutCurve,
      transitionBuilder,
      successDisplayDuration,
      errorDisplayDuration,
      cooldownDuration,
      animateSize,
      sizeCurve,
      sizeAlignment,
      sizeClipBehavior,
      hapticOn,
      announceSemantics,
      rethrowErrors,
    ]);
  }
}

class _DefaultLoadingChild extends StatelessWidget {
  const _DefaultLoadingChild({this.color});

  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 16,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: color == null
            ? null
            : AlwaysStoppedAnimation<Color>(color!),
      ),
    );
  }
}

class _DefaultSuccessIcon extends StatelessWidget {
  const _DefaultSuccessIcon({this.color});

  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.check,
      color: color ?? Theme.of(context).colorScheme.primary,
    );
  }
}

class _DefaultErrorIcon extends StatelessWidget {
  const _DefaultErrorIcon({this.color});

  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.error,
      color: color ?? Theme.of(context).colorScheme.error,
    );
  }
}
