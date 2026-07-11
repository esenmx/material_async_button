part of '../material_async_button.dart';

/// App-wide defaults for `material_async_button` widgets, attached as a
/// [ThemeExtension] on [ThemeData]. Complements [ButtonStyle] / `ButtonThemeData`
/// — it carries only async behaviour (the loading view and its transition),
/// never styling knobs.
///
/// Resolution order for any field: per-widget value, then theme value, then
/// the hard-coded fallback. With no extension registered the zero-config
/// fallback ([empty]) shows the default spinner and nothing else.
///
/// ```dart
/// MaterialApp(
///   theme: ThemeData(
///     extensions: [
///       AsyncButtonTheme(
///         loadingBuilder: (_) => const AsyncButtonSpinner(strokeWidth: 3),
///       ),
///     ],
///   ),
/// )
/// ```
@immutable
class AsyncButtonTheme extends ThemeExtension<AsyncButtonTheme> {
  /// Builds an [AsyncButtonTheme]. Every field is nullable so callers only
  /// set the ones they want.
  const AsyncButtonTheme({this.loadingBuilder, this.transitionBuilder});

  /// Builds the widget shown in place of the button's child while the future is
  /// in flight. Falls back to an [AsyncButtonSpinner] when null. The spinner
  /// inherits the button's foreground; return `AsyncButtonSpinner(color: ...)`
  /// to recolour it.
  final WidgetBuilder? loadingBuilder;

  /// Wraps the state widget to animate the idle ⇄ loading swap. `null` by
  /// default — the button performs no animation of its own. See
  /// [AsyncButtonTransitionBuilder] for plugging in an [AnimatedSwitcher] /
  /// [AnimatedSize].
  final AsyncButtonTransitionBuilder? transitionBuilder;

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
  }) {
    return AsyncButtonTheme(
      loadingBuilder: loadingBuilder ?? this.loadingBuilder,
      transitionBuilder: transitionBuilder ?? this.transitionBuilder,
    );
  }

  @override
  AsyncButtonTheme lerp(
    covariant AsyncButtonTheme? other,
    double t,
  ) {
    if (other == null) {
      return this;
    }
    // Widgets and callbacks don't lerp; snap at the halfway point.
    final snap = t < 0.5;
    return AsyncButtonTheme(
      loadingBuilder: snap ? loadingBuilder : other.loadingBuilder,
      transitionBuilder: snap ? transitionBuilder : other.transitionBuilder,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is AsyncButtonTheme &&
            loadingBuilder == other.loadingBuilder &&
            transitionBuilder == other.transitionBuilder;
  }

  @override
  int get hashCode {
    return Object.hash(loadingBuilder, transitionBuilder);
  }
}

// Bounded cache to prevent thrashing between multiple button styles on screen,
// while avoiding unbounded memory growth in apps with dynamic text styles.
typedef _LineBoxKey = (TextStyle, TextDirection, TextScaler);
final _lineBoxCache = <_LineBoxKey, double>{};

/// The single-line height of the ambient label style at [context] — the
/// vertical extent a one-line [Text] occupies here. The default spinner sizes
/// to this (the idle content's *line box*, which is taller than the raw
/// `fontSize`) so the button keeps its idle height while loading instead of
/// shrinking. Honours the ambient [TextScaler], matching how the label scales.
double _ambientTextLineBox(BuildContext context) {
  final style = DefaultTextStyle.of(context).style;
  final textDirection = Directionality.of(context);
  final textScaler = MediaQuery.textScalerOf(context);
  final key = (style, textDirection, textScaler);

  final cached = _lineBoxCache[key];
  if (cached != null) {
    return cached;
  }

  if (_lineBoxCache.length >= 16) {
    _lineBoxCache.clear();
  }

  final painter = TextPainter(
    text: TextSpan(text: '', style: style),
    textDirection: textDirection,
    textScaler: textScaler,
  )..layout();

  return _lineBoxCache[key] = painter.preferredLineHeight;
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
class AsyncButtonSpinner extends StatelessWidget {
  /// Creates a spinner. [color] defaults to the button's foreground and
  /// otherwise the primary colour; [strokeWidth] sets the line weight; [size]
  /// sets the square the indicator occupies — when null it tracks the ambient
  /// font size so the spinner matches the button's label; [semanticsLabel]
  /// sets the accessibility label read by screen readers.
  const AsyncButtonSpinner({
    super.key,
    this.color,
    this.strokeWidth = 2,
    this.size,
    this.semanticsLabel = 'Loading',
  });

  /// Indicator colour. When null, inherits the button's foreground (its
  /// enabled foreground while loading), falling back to [ColorScheme.primary]
  /// outside any button.
  final Color? color;

  /// Stroke width of the [CircularProgressIndicator].
  final double strokeWidth;

  /// Side length of the square the indicator is laid out in. When null it
  /// tracks the ambient label's line-box height (the vertical extent of a
  /// one-line [Text] in the surrounding [DefaultTextStyle]), so the spinner
  /// fills the same height the label did and the button doesn't shrink.
  /// [IconThemeData.size] is intentionally not read here — it is typically 24
  /// and would oversize the spinner on text buttons.
  final double? size;

  /// Accessibility label read by screen readers. Defaults to `'Loading'`.
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final resolved =
        color ??
        IconTheme.of(context).color ??
        Theme.of(context).colorScheme.primary;
    final dimension = size ?? _ambientTextLineBox(context);
    return Center(
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
