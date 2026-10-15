part of '../material_async_button.dart';

/// App-wide defaults for `material_async_button` widgets, attached as a
/// [ThemeExtension] on [ThemeData]. Complements [ButtonStyle] / `ButtonThemeData`
/// — it carries only async behaviour (the loading view, its transition, its
/// footprint and minimum duration), never styling knobs.
///
/// Resolution order for any field: per-widget value, then theme value, then
/// the hard-coded fallback. With no extension registered the zero-config
/// fallback ([empty]) shows the default spinner and nothing else.
///
/// ```dart
/// Widget thickSpinner(BuildContext _) =>
///     const AsyncButtonSpinner(strokeWidth: 3);
///
/// MaterialApp(
///   theme: ThemeData(
///     extensions: [AsyncButtonTheme(loadingBuilder: thickSpinner)],
///   ),
/// )
/// ```
///
/// Pass [loadingBuilder] and [transitionBuilder] as top-level or static
/// functions. Closures compare by identity, so an inline closure makes every
/// [ThemeData] built in `build()` unequal and `MaterialApp` restarts its theme
/// animation on every rebuild.
@immutable
final class const AsyncButtonTheme({
  /// Builds the widget shown in place of the button's child while the future is
  /// in flight. Falls back to an [AsyncButtonSpinner] when null. The spinner
  /// inherits the button's foreground; return `AsyncButtonSpinner(color: ...)`
  /// to recolour it.
  ///
  /// Pass a top-level or static function: an inline closure is unequal to the
  /// one built on the next rebuild, which restarts the app's theme animation.
  final WidgetBuilder? loadingBuilder,

  /// Wraps the state widget to animate the idle ⇄ loading swap. `null` by
  /// default — the button performs no animation of its own. See
  /// [AsyncButtonTransitionBuilder] for plugging in an [AnimatedSwitcher] /
  /// [AnimatedSize].
  ///
  /// Pass a top-level or static function: an inline closure is unequal to the
  /// one built on the next rebuild, which restarts the app's theme animation.
  final AsyncButtonTransitionBuilder? transitionBuilder,

  /// Whether the loading view overlays the invisible idle child instead of
  /// replacing it, so the button keeps its idle footprint (no width jump).
  /// Defaults to `false`.
  final bool? maintainSize,

  /// The shortest time a run shows the loading view, measured from the tap or
  /// [AsyncButtonController.trigger] — an anti-flicker floor for fast futures.
  /// An error rethrows once the floor has elapsed. Defaults to [Duration.zero].
  final Duration? minLoadingDuration,
}) extends ThemeExtension<AsyncButtonTheme> {
  /// Builds an [AsyncButtonTheme]. Every field is nullable so callers only
  /// set the ones they want.
  this;

  /// An extension with every field left null — also the zero-config fallback
  /// returned by [of] when no extension is registered. Renders the default
  /// spinner on loading and nothing else.
  static const AsyncButtonTheme empty = AsyncButtonTheme();

  /// Resolves the [AsyncButtonTheme] visible at [context]. Returns the
  /// extension registered on the surrounding [ThemeData] when one exists;
  /// otherwise falls back to [empty] — apps without explicit theming still get
  /// the loading spinner (via the built-in fallback).
  static AsyncButtonTheme of(BuildContext context) {
    return Theme.of(context).extension<AsyncButtonTheme>() ?? empty;
  }

  @override
  AsyncButtonTheme copyWith({
    WidgetBuilder? loadingBuilder,
    AsyncButtonTransitionBuilder? transitionBuilder,
    bool? maintainSize,
    Duration? minLoadingDuration,
  }) {
    return AsyncButtonTheme(
      loadingBuilder: loadingBuilder ?? this.loadingBuilder,
      transitionBuilder: transitionBuilder ?? this.transitionBuilder,
      maintainSize: maintainSize ?? this.maintainSize,
      minLoadingDuration: minLoadingDuration ?? this.minLoadingDuration,
    );
  }

  @override
  AsyncButtonTheme lerp(covariant AsyncButtonTheme? other, double t) {
    if (other == null) {
      return this;
    }
    // Widgets, callbacks and behaviour flags don't lerp; snap at the halfway
    // point.
    final snap = t < 0.5;
    return AsyncButtonTheme(
      loadingBuilder: snap ? loadingBuilder : other.loadingBuilder,
      transitionBuilder: snap ? transitionBuilder : other.transitionBuilder,
      maintainSize: snap ? maintainSize : other.maintainSize,
      minLoadingDuration: snap ? minLoadingDuration : other.minLoadingDuration,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is AsyncButtonTheme &&
            loadingBuilder == other.loadingBuilder &&
            transitionBuilder == other.transitionBuilder &&
            maintainSize == other.maintainSize &&
            minLoadingDuration == other.minLoadingDuration;
  }

  @override
  int get hashCode {
    return Object.hash(
      loadingBuilder,
      transitionBuilder,
      maintainSize,
      minLoadingDuration,
    );
  }
}

/// The default loading indicator — a sized, indeterminate
/// [CircularProgressIndicator]. Used as the fallback loading view, and exposed
/// so you can tweak it and return it from a `loadingBuilder`:
///
/// ```dart
/// FilledAsyncButton(
///   onPressed: api.save,
///   loadingBuilder: (_) => const AsyncButtonSpinner(strokeWidth: 3),
///   child: const Text('Save'),
/// )
/// ```
final class const AsyncButtonSpinner({
  /// Indicator colour. When null, inherits the button's foreground (its
  /// enabled foreground while loading), falling back to [ColorScheme.primary]
  /// outside any button.
  final Color? color,

  /// Stroke width of the [CircularProgressIndicator].
  final double strokeWidth = 2,

  /// Side length of the square the indicator is laid out in. When null it
  /// tracks the ambient label's line-box height (the vertical extent of a
  /// one-line [Text] in the surrounding [DefaultTextStyle]), so the spinner
  /// fills the same height the label did and the button doesn't shrink.
  /// [IconThemeData.size] is intentionally not read here — it is typically 24
  /// and would oversize the spinner on text buttons.
  final double? size,

  /// Accessibility label read by screen readers. Defaults to `'Loading'`.
  final String? semanticsLabel = 'Loading',
  super.key,
}) extends StatelessWidget {
  /// Creates a spinner. [color] defaults to the button's foreground and
  /// otherwise the primary colour; [strokeWidth] sets the line weight; [size]
  /// sets the square the indicator occupies — when null it tracks the ambient
  /// label line box so the spinner matches the button's label; [semanticsLabel]
  /// sets the accessibility label read by screen readers.
  this;

  @override
  Widget build(BuildContext context) {
    final resolved =
        color ??
        IconTheme.of(context).color ??
        Theme.of(context).colorScheme.primary;
    final dimension = size ?? ambientTextLineBox(context);
    return Center(
      widthFactor: 1,
      heightFactor: 1,
      child: SizedBox.square(
        dimension: dimension,
        child: CircularProgressIndicator(
          strokeWidth: strokeWidth,
          valueColor: AlwaysStoppedAnimation<Color>(resolved),
          semanticsLabel: semanticsLabel,
        ),
      ),
    );
  }
}
