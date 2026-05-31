part of '../material_async_button.dart';

/// Signature for [AsyncButton.builder].
///
/// `callback` is `null` **only** when the button is explicitly disabled
/// (`enabled: false` or `onPressed == null`). Loading never disables the
/// button: while loading, `callback` stays non-null so the button keeps its
/// enabled look (the spinner is the state indicator). Taps that can't run are
/// silently swallowed by the controller, so they never double-submit.
typedef AsyncButtonWidgetBuilder =
    Widget Function(
      BuildContext context,
      Widget child,
      AsyncCallback? callback,
      // Builder callbacks are positional by Flutter convention (cf.
      // ValueWidgetBuilder<bool>); a named bool here would be un-idiomatic.
      // ignore: avoid_positional_boolean_parameters
      bool isLoading,
    );

/// Signature for [AsyncButton.transitionBuilder].
///
/// Wraps the current state's [child] (already keyed by loading state) to
/// animate the idle ⇄ loading swap — e.g. an [AnimatedSwitcher] inside an
/// [AnimatedSize]. The button does no animation of its own; return [child]
/// unchanged for an instant swap. See the README for a worked example.
typedef AsyncButtonTransitionBuilder =
    Widget Function(
      BuildContext context,
      Widget child,
      // Builder callbacks are positional by Flutter convention (cf.
      // ValueWidgetBuilder<bool>); a named bool here would be un-idiomatic.
      // ignore: avoid_positional_boolean_parameters
      bool isLoading,
    );

/// Low-level async-loading shell for arbitrary buttons.
///
/// Prefer the named Material wrappers ([ElevatedAsyncButton],
/// [FilledAsyncButton], [OutlinedAsyncButton], [TextAsyncButton],
/// [IconAsyncButton]). Reach for [AsyncButton] directly only when you need
/// to render a non-Material button.
///
/// The builder receives whether the button is loading — switch the chrome on
/// it:
///
/// ```dart
/// AsyncButton(
///   onPressed: () async => doWork(),
///   child: const Text('Go'),
///   builder: (context, child, callback, isLoading) => MyCustomButton(
///     onTap: callback,
///     color: isLoading ? Colors.grey : Colors.indigo,
///     child: child,
///   ),
/// )
/// ```
class AsyncButton extends StatefulWidget {
  /// Creates an [AsyncButton]. See the class doc for usage.
  const AsyncButton({
    super.key,
    required this.child,
    required this.onPressed,
    required this.builder,
    this.enabled = true,
    this.controller,
    this.loadingBuilder,
    this.transitionBuilder,
  });

  /// Idle widget. Replaced by [loadingBuilder] while loading.
  final Widget child;

  /// Async callback. `null` makes the button appear disabled.
  final AsyncCallback? onPressed;

  /// Whether the button is interactive. When `false` it renders the disabled
  /// look, ignores taps, and no-ops an external [AsyncButtonController.trigger]
  /// — same as `onPressed: null`, but the affirmative form that pairs with a
  /// tear-off `onPressed`. Defaults to `true`.
  final bool enabled;

  /// Renders the button chrome. See [AsyncButtonWidgetBuilder].
  final AsyncButtonWidgetBuilder builder;

  /// External controller. When null, the widget creates and owns its own.
  final AsyncButtonController? controller;

  /// Builds the widget shown while loading, with the [AsyncButton]'s own
  /// [BuildContext]. Falls back to [AsyncButtonTheme.loadingBuilder], then to
  /// an [AsyncButtonSpinner]. The spinner inherits the button's foreground
  /// colour automatically — to recolour it, return
  /// `AsyncButtonSpinner(color: ...)`.
  final WidgetBuilder? loadingBuilder;

  /// Per-widget override of [AsyncButtonTheme.transitionBuilder]. The button
  /// performs no animation unless this (or the theme's) builder adds one.
  final AsyncButtonTransitionBuilder? transitionBuilder;

  @override
  State<AsyncButton> createState() => _AsyncButtonState();
}

class _AsyncButtonState extends State<AsyncButton> {
  late AsyncButtonController controller;

  /// The widget's `onPressed` once [AsyncButton.enabled] is applied — `null`
  /// (disabled) when `enabled: false` or `onPressed == null`. Both disable
  /// paths collapse here, so the controller and the builder callback stay in
  /// agreement.
  AsyncCallback? get effectiveOnPressed =>
      widget.enabled ? widget.onPressed : null;

  /// Handed to the builder. `null` when disabled (see [effectiveOnPressed]);
  /// otherwise [AsyncButtonController.trigger]. Loading never disables the
  /// button — trigger just no-ops while busy, so taps that can't run are
  /// swallowed and the button keeps its enabled look.
  AsyncCallback? get callback =>
      effectiveOnPressed == null ? null : controller.trigger;

  @override
  void initState() {
    super.initState();
    controller = widget.controller ?? AsyncButtonController();
    controller
      ..addListener(listener)
      ..attach(onPressed: effectiveOnPressed);
  }

  @override
  void didUpdateWidget(covariant AsyncButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      controller.removeListener(listener);
      // Dispose only a controller we created ourselves — never one the caller
      // owns.
      if (oldWidget.controller == null) {
        controller.dispose();
      }
      controller = widget.controller ?? AsyncButtonController();
      controller.addListener(listener);
    }
    // onPressed (and enabled) can change on every parent rebuild — keep the
    // controller's copy current.
    controller.attach(onPressed: effectiveOnPressed);
  }

  @override
  void dispose() {
    controller.removeListener(listener);
    // Dispose only an internally-owned controller.
    if (widget.controller == null) {
      controller.dispose();
    }
    super.dispose();
  }

  void listener() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = AsyncButtonTheme.of(context);
    final loadingBuilder =
        widget.loadingBuilder ?? theme.loadingBuilder ?? _defaultLoadingBuilder;
    final transitionBuilder =
        widget.transitionBuilder ?? theme.transitionBuilder;

    final isLoading = controller.value;
    // The idle child is replaced outright by the loading widget; the button
    // may resize to fit it (wrap a transitionBuilder in AnimatedSize to smooth
    // that).
    var content = isLoading ? loadingBuilder(context) : widget.child;

    // Keyed by loading state so a user-supplied transitionBuilder can animate
    // the swap (e.g. via AnimatedSwitcher / AnimatedSize). With no builder it
    // is an instant swap.
    content = KeyedSubtree(key: ValueKey<bool>(isLoading), child: content);
    if (transitionBuilder != null) {
      content = transitionBuilder(context, content, isLoading);
    }

    return widget.builder(context, content, callback, isLoading);
  }
}

/// The loading view used when neither the widget nor the theme supplies a
/// [AsyncButton.loadingBuilder]: the default [AsyncButtonSpinner].
Widget _defaultLoadingBuilder(BuildContext context) {
  return const AsyncButtonSpinner();
}
