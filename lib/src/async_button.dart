part of '../material_async_button.dart';

/// Signature for [AsyncButton.builder].
///
/// `callback` is `null` **only** when the button is explicitly disabled
/// (`enabled: false` or `onPressed == null`). Loading never disables the
/// button: while loading, `callback` stays non-null so the button keeps its
/// enabled look (the spinner is the state indicator). Taps that can't run are
/// silently swallowed by the controller, so they never double-submit.
// Formatter generations disagree on splitting a generalized typedef header
// (`=` break vs `= Widget Function(`); pin one form so local dart format,
// CI, and pana's package-config-free dart_style all leave it untouched.
// dart format off
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
// dart format on

/// Low-level async-loading shell for arbitrary buttons.
///
/// Prefer the named Material wrappers ([ElevatedAsyncButton],
/// [FilledAsyncButton], [OutlinedAsyncButton], [TextAsyncButton],
/// [IconAsyncButton], [FloatingActionAsyncButton]). Reach for [AsyncButton]
/// directly only when you need to render a non-Material button.
///
/// The builder receives whether the button is loading — switch the chrome on
/// it:
///
/// ```dart
/// AsyncButton(
///   onPressed: doWork,
///   child: const Text('Go'),
///   builder: (context, child, callback, isLoading) => MyCustomButton(
///     onTap: callback,
///     color: isLoading ? Colors.grey : Colors.indigo,
///     child: child,
///   ),
/// )
/// ```
class const AsyncButton({
  /// Idle widget. Replaced by [loadingBuilder] while loading.
  required final Widget child,

  /// Async callback. `null` makes the button appear disabled.
  required final AsyncCallback? onPressed,

  /// Renders the button chrome. See [AsyncButtonWidgetBuilder].
  required final AsyncButtonWidgetBuilder builder,

  /// Whether the button is interactive. When `false` it renders the disabled
  /// look, ignores taps, and no-ops an external [AsyncButtonController.trigger]
  /// — same as `onPressed: null`, but the affirmative form that pairs with a
  /// tear-off `onPressed`. Defaults to `true`.
  final bool enabled = true,

  /// External controller. When null, the widget creates and owns its own.
  final AsyncButtonController? controller,

  /// Builds the widget shown while loading, with the [AsyncButton]'s own
  /// [BuildContext]. Falls back to [AsyncButtonTheme.loadingBuilder], then to
  /// an [AsyncButtonSpinner]. The spinner inherits the button's foreground
  /// colour automatically — to recolour it, return
  /// `AsyncButtonSpinner(color: ...)`.
  final WidgetBuilder? loadingBuilder,

  /// Per-widget override of [AsyncButtonTheme.transitionBuilder]. The button
  /// performs no animation unless this (or the theme's) builder adds one.
  final AsyncButtonTransitionBuilder? transitionBuilder,

  /// Per-widget override of [AsyncButtonTheme.maintainSize]. When `true` the
  /// loading view overlays the invisible [child], so the button keeps its idle
  /// footprint (the larger of the two). Defaults to `false`.
  final bool? maintainSize,

  /// Per-widget override of [AsyncButtonTheme.minLoadingDuration]: the
  /// shortest time a run shows the loading view. Defaults to [Duration.zero].
  final Duration? minLoadingDuration,
  super.key,
}) extends StatefulWidget {
  /// Creates an [AsyncButton]. See the class doc for usage.
  this;

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

  // Per-rebuild refresh of the bound onPressed / enabled.
  void _bind() {
    controller._bind(this, onPressed: effectiveOnPressed);
  }

  // Binding is last-binder-wins (see AsyncButtonController._bind). When this
  // button takes the controller from another one, it checks once the frame
  // settles that the displaced button is gone or drives another controller;
  // otherwise two mounted buttons share it. Only the displacing side checks,
  // so a double mount is reported once.
  void _bindAndCheck() {
    final displaced = controller._bind(this, onPressed: effectiveOnPressed);
    assert(() {
      if (displaced is _AsyncButtonState) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          assert(
            !(mounted &&
                displaced.mounted &&
                identical(displaced.controller, controller)),
            'An AsyncButtonController can drive only one mounted AsyncButton.',
          );
        });
      }
      return true;
    }(), 'schedules the debug-only double-mount check');
  }

  @override
  void initState() {
    super.initState();
    controller = (widget.controller ?? AsyncButtonController())
      ..addListener(listener);
    _bindAndCheck();
  }

  @override
  void didUpdateWidget(covariant AsyncButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      final previous = controller;
      final inFlight = previous._inFlight;
      previous
        ..removeListener(listener)
        .._unbind(this);
      // Dispose only a controller we created ourselves — never one the caller
      // owns.
      if (oldWidget.controller == null) {
        previous.dispose();
      }
      controller = (widget.controller ?? AsyncButtonController())
        ..addListener(listener);
      if (inFlight != null && !controller.value) {
        controller._adopt(inFlight);
      }
      _bindAndCheck();
    } else {
      // onPressed (and enabled) can change on every parent rebuild — keep the
      // controller's copy current.
      _bind();
    }
  }

  // Unbind on deactivate, not dispose, and only if still the owner: a
  // replacement button may already have bound (a multi-child parent inflates
  // it before deactivating the old child), and the old dispose runs later
  // still.
  @override
  void activate() {
    super.activate();
    _bindAndCheck();
  }

  @override
  void deactivate() {
    controller._unbind(this);
    super.deactivate();
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
    controller._minLoadingDuration =
        widget.minLoadingDuration ?? theme.minLoadingDuration ?? Duration.zero;

    final isLoading = controller.value;
    // Without maintainSize the idle child is replaced outright and the button
    // may resize to fit the loading view; with it the loading view overlays
    // the invisible child.
    final keepFootprint = widget.maintainSize ?? theme.maintainSize ?? false;
    var content = switch ((isLoading, keepFootprint)) {
      (false, _) => widget.child,
      (true, false) => loadingBuilder(context),
      (true, true) => Stack(
        alignment: .center,
        children: [
          // maintainSemantics stays false: screen readers hear only the
          // loading view.
          Visibility(
            visible: false,
            maintainState: true,
            maintainAnimation: true,
            maintainSize: true,
            child: widget.child,
          ),
          loadingBuilder(context),
        ],
      ),
    };

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
