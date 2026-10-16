# material_async_button

[![pub package](https://img.shields.io/pub/v/material_async_button.svg)](https://pub.dev/packages/material_async_button)
[![pub points](https://img.shields.io/pub/points/material_async_button)](https://pub.dev/packages/material_async_button/score)
[![CI](https://github.com/esenmx/material_async_button/actions/workflows/ci.yaml/badge.svg)](https://github.com/esenmx/material_async_button/actions/workflows/ci.yaml)
[![license: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

Async versions of Flutter's Material buttons: `ElevatedButton`, `FilledButton`,
`OutlinedButton`, `TextButton`, `IconButton` and `FloatingActionButton`. Give
`onPressed` an async function, and the button shows a spinner until its `Future`
completes.

**Why?** By hand, every async button needs its own `StatefulWidget`: an
`isLoading` flag, `setState` before and after the `await`, a `try`/`finally` so
an error can't leave the spinner stuck, a `mounted` check, and a guard against a
second tap. This package does all of that for you, with the same parameters as
the Material button you would use anyway. The default spinner takes the colour
and height of the label or icon it replaces, and one theme extension changes it
for the whole app.

## Quick start

```sh
flutter pub add material_async_button
```

```dart
import 'package:material_async_button/material_async_button.dart';
import 'package:material_ui/material_ui.dart';

Widget saveButton(Future<void> Function() save) {
  return ElevatedAsyncButton(
    onPressed: save, // shows a spinner until save() completes
    child: const Text('Save'),
  );
}
```

That's it: no state, no flags. A tap while `save()` runs starts nothing, and if
it throws, the button goes back to idle and passes the error on (see
[Errors and success](#errors-and-success-loading-only)).

> **Note:** Version 4.x targets `package:material_ui/material_ui.dart`. Your app
> must also import `package:material_ui/material_ui.dart` (migrate with
> `dart fix --apply --code=migrate_design_widgets`); with
> `package:flutter/material.dart`, the buttons ignore your app's `ThemeData`.

The snippets below write `Future<void> Function()` as `AsyncCallback`, from
`package:flutter/foundation.dart`.

## Buttons

| Material | Async counterpart | Variants |
| --- | --- | --- |
| `ElevatedButton` | `ElevatedAsyncButton` | `.icon` |
| `FilledButton` | `FilledAsyncButton` | `.tonal`, `.icon`, `.tonalIcon` |
| `OutlinedButton` | `OutlinedAsyncButton` | `.icon` |
| `TextButton` | `TextAsyncButton` | `.icon` |
| `IconButton` | `IconAsyncButton` | `.filled`, `.filledTonal`, `.outlined` |
| `FloatingActionButton` | `FloatingActionAsyncButton` | `.small`, `.large`, `.extended` |

Every Material constructor is mirrored, and every Material parameter (`style`,
`focusNode`, `autofocus`, `clipBehavior`, `statesController`, etc.) is forwarded
verbatim, with these exceptions:

- `onLongPress` is dropped while loading.
- The `.icon` constructors of the four label buttons require `icon` (it stays
  nullable); Material's is optional.
- The FAB's default `heroTag` is a package sentinel rather than Flutter's, so no
  hero flight runs between a plain and an async FAB.

## How it behaves

| State | UI |
| --- | --- |
| idle | your `child` |
| loading | `AsyncButtonSpinner` (sized to the label or icon it replaces) |

The label-button `.icon` constructors (`ElevatedAsyncButton.icon`,
`FilledAsyncButton.icon`, etc.) drop the icon while loading and show the spinner
alone, unless `maintainSize` is set — then the icon stays. (`IconAsyncButton`
has no `.icon` variant — it swaps its sole icon for the spinner.)

### Loading never disables the button

Being loading and being _disabled_ are different things — the spinner is the
indicator, the button keeps its themed enabled colours, and taps that can't run
are silently swallowed (`onLongPress` is gated off while busy). The button shows
the disabled look **only** when you disable it explicitly — pass
`enabled: false` (defaults to `true`) or `onPressed: null`. As in Flutter, a
label button with `onPressed: null` and an `onLongPress` stays enabled for
long-press; `IconAsyncButton`, like `IconButton`, ignores `onLongPress` without
`onPressed`. Either path also no-ops an external `controller.trigger()`.

### Size and animation

The swap is instant, and the button resizes to fit the loading widget. To keep
the idle size instead, set `maintainSize: true`. The button does no animation of
its own. To smooth the swap — and the size change when the spinner differs from
the child — pass a `transitionBuilder`. The child is already keyed by loading
state, so an `AnimatedSwitcher` inside an `AnimatedSize` is all it takes:

```dart
Widget saveButton(AsyncCallback save) => ElevatedAsyncButton(
  onPressed: save,
  transitionBuilder: (context, child, isLoading) => AnimatedSize(
    duration: const Duration(milliseconds: 200),
    child: AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: child,
    ),
  ),
  child: const Text('Save'),
);
```

Set `transitionBuilder` on `AsyncButtonTheme` to animate every button at once.
`AsyncButtonSpinner` is public and inherits the button's foreground — customise
its `color` / `strokeWidth` / `size` and return it from `loadingBuilder`.

## Errors and success: loading only

The button does one job: show a spinner while `onPressed` is in flight. It has
no success or error state, by design.

**Errors** belong to your state management; an in-button error view is a
Material anti-pattern. When `onPressed` throws, the button returns to idle and
**re-throws**: a tap's error reaches the surrounding zone (your
`runZonedGuarded`, else `PlatformDispatcher.instance.onError`) like any other
uncaught async error, and a `controller.trigger()` caller gets a rejected
Future. Typically your notifier or repository absorbs the failure internally
(for example with Riverpod's `AsyncValue.guard`), so `onPressed` never throws.
Or handle it inline and surface it your way:

```dart
Widget submitButton(BuildContext context, AsyncCallback submit) {
  return ElevatedAsyncButton(
    onPressed: () async {
      final messenger = ScaffoldMessenger.of(context);
      try {
        await submit();
      } on Exception catch (error) {
        messenger.showSnackBar(SnackBar(content: Text('$error')));
      }
    },
    child: const Text('Submit'),
  );
}
```

**Success** is handled by what your action already does — navigate away, flip
the label (Save → Unsave), update a list. An in-button "Saved ✓" is usually
redundant. Surface it the same way you surface any state change.

## Theming

Most apps end up writing their own `DefaultAsyncButton` wrapper to share a
loading widget and its transition across screens. This package gives you that
wrapper as a [`ThemeExtension`][th] — configure once, every `*AsyncButton` picks
it up; override per button when you need to. `AsyncButtonTheme` complements
`ButtonStyle` / `ButtonThemeData` — it carries only async behaviour, never
styling.

[th]:
  https://pub.dev/documentation/material_ui/latest/material_ui/ThemeExtension-class.html

Resolution order for any field is **per-widget value → theme value → built-in
fallback**.

```dart
Widget thickSpinner(BuildContext _) => const AsyncButtonSpinner(strokeWidth: 3);

final theme = ThemeData(
  extensions: [
    AsyncButtonTheme(
      loadingBuilder: thickSpinner,
      // transitionBuilder: animate every button's swap (see above).
      maintainSize: true, // keep the idle footprint while loading
      minLoadingDuration: const Duration(milliseconds: 300), // anti-flicker
    ),
  ],
);
```

Pass `loadingBuilder` and `transitionBuilder` as top-level or static functions,
not inline closures. Two closures are never equal, so a `ThemeData` built in
`build()` with an inline closure differs on every rebuild, and `MaterialApp`
restarts its 200 ms theme animation each time. Per-widget builders aren't
affected.

- `maintainSize` (default `false`) overlays the loading view on the invisible
  idle child, so the button keeps its idle size — no width jump. `.icon`
  constructors keep their icon visible beside the spinner.
- `minLoadingDuration` (default `Duration.zero`) holds the loading view at least
  that long from the tap or `controller.trigger()`, so a fast future doesn't
  flash a spinner. An error rethrows once the floor has elapsed.

Both are also per-widget parameters on every button and on `AsyncButton`.

With no extension registered, `AsyncButtonTheme.of` falls back to
`AsyncButtonTheme.empty` — the default spinner and nothing else.

`copyWith` can't reset a field to null — build a new `AsyncButtonTheme` instead.

## External control: `AsyncButtonController`

`AsyncButtonController` is a `ValueListenable<bool>` (loading) plus imperative
methods. Use it for **form keyboard "Done"**, parent-owned state, cross-widget
reactions, and tests. Dispose it like any `ChangeNotifier`.

```dart
final controller = AsyncButtonController();

Widget form(AsyncCallback submit) => Column(
  children: [
    TextField(textInputAction: .done, onSubmitted: (_) => controller.trigger()),
    ElevatedAsyncButton(
      controller: controller,
      onPressed: submit,
      child: const Text('Submit'),
    ),
  ],
);
```

- `controller.trigger()` runs `onPressed` from outside; its Future fails if
  `onPressed` throws. While a run is in flight, it starts nothing and returns
  that run's Future, so `await controller.trigger()` waits for the real run and
  sees its error.
- `controller.reset()` forces the button back to idle and abandons the in-flight
  run: the button is re-armed at once (an escape hatch for a hung future), and
  the abandoned run's completion is ignored.
- `controller.value` is `true` while loading.
- `controller.canTrigger` is `true` when `trigger()` would run: not loading, and
  bound to an enabled button.

One controller drives one mounted button — binding it to a second throws a
`StateError` once the frame settles. When no button is bound (never passed to
one, or its button unmounted or switched to another controller), `trigger()`
returns a Future that fails with a `StateError`; gate on `canTrigger`. After
`dispose()`, `reset()` throws a `StateError` and `trigger()` returns a Future
that fails with one.

A run belongs to the controller that started it: unmounting the button or
switching it to another controller leaves the run, and its `minLoadingDuration`,
on that controller until it settles, or until you `reset()` or `dispose()` it.

## Custom buttons: `AsyncButton`

`AsyncButton` is the low-level escape hatch. Use it when none of the Material
wrappers fit. The builder receives whether the button is loading:

```dart
Widget goButton(AsyncCallback doWork) => AsyncButton(
  onPressed: doWork,
  child: const Text('Go'),
  builder: (context, child, callback, isLoading) => InkWell(
    onTap: callback,
    child: Ink(color: isLoading ? Colors.grey : Colors.indigo, child: child),
  ),
);
```

## Agent skill

This package ships an agent skill in `skills/material-async-button-usage/`.
Install it into your project's agent config with:

```sh
dart run skills@ get --package material_async_button --all
```

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

MIT — see [LICENSE](LICENSE).
