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
    covariant ThemeExtension<AsyncButtonTheme>? other,
    double t,
  ) {
    if (other is! AsyncButtonTheme) {
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
  /// font size so the spinner matches the button's label.
  const AsyncButtonSpinner({
    super.key,
    this.color,
    this.strokeWidth = 2,
    this.size,
  });

  /// Indicator colour. When null, inherits the button's foreground (its
  /// enabled foreground while loading), falling back to [ColorScheme.primary]
  /// outside any button.
  final Color? color;

  /// Stroke width of the [CircularProgressIndicator].
  final double strokeWidth;

  /// Side length of the square the indicator is laid out in. When null it is
  /// derived from the ambient [DefaultTextStyle] font size (matching a text
  /// button's label), falling back to `16`. [IconThemeData.size] is
  /// intentionally not used — it is typically 24 and would oversize the spinner
  /// on text buttons.
  final double? size;

  @override
  Widget build(BuildContext context) {
    final resolved =
        color ??
        IconTheme.of(context).color ??
        Theme.of(context).colorScheme.primary;
    final dimension = size ?? DefaultTextStyle.of(context).style.fontSize ?? 16;
    return Center(
      child: SizedBox.square(
        dimension: dimension,
        child: CircularProgressIndicator(
          strokeWidth: strokeWidth,
          valueColor: AlwaysStoppedAnimation<Color>(resolved),
        ),
      ),
    );
  }
}
