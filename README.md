# material_async_button

[![pub package](https://img.shields.io/pub/v/material_async_button.svg)](https://pub.dev/packages/material_async_button) [![pub points](https://img.shields.io/pub/points/material_async_button)](https://pub.dev/packages/material_async_button/score) [![CI](https://github.com/esenmx/material_async_button/actions/workflows/ci.yaml/badge.svg)](https://github.com/esenmx/material_async_button/actions/workflows/ci.yaml) [![license: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

Drop-in async wrappers for Flutter Material buttons. Adds a **loading** state to
`ElevatedButton`, `FilledButton`, `OutlinedButton`, `TextButton`, `IconButton`,
and `FloatingActionButton` — without forcing you to build a project-wide wrapper
widget.

```dart
ElevatedAsyncButton(
  onPressed: api.save,
  child: const Text('Save'),
)
```

That's it. The button shows a spinner while `save()` runs and returns to its
label when it completes.

## Install

```sh
flutter pub add material_async_button
```

## Why

Most apps end up writing their own `DefaultAsyncButton` wrapper to share a
loading widget and its transition across screens. This package gives you that
wrapper as a [`ThemeExtension`][th] — configure once, every `*AsyncButton` picks
it up; override per button when you need to.

[th]: https://api.flutter.dev/flutter/material/ThemeExtension-class.html

## Material wrappers

| Material               | Async counterpart           | Variants                               |
| ---------------------- | --------------------------- | -------------------------------------- |
| `ElevatedButton`       | `ElevatedAsyncButton`       | `.icon`                                |
| `FilledButton`         | `FilledAsyncButton`         | `.tonal`, `.icon`, `.tonalIcon`        |
| `OutlinedButton`       | `OutlinedAsyncButton`       | `.icon`                                |
| `TextButton`           | `TextAsyncButton`           | `.icon`                                |
| `IconButton`           | `IconAsyncButton`           | `.filled`, `.filledTonal`, `.outlined` |
| `FloatingActionButton` | `FloatingActionAsyncButton` | `.small`, `.large`, `.extended`        |

Every Material constructor is mirrored. All Material parameters (`style`,
`focusNode`, `autofocus`, `clipBehavior`, `statesController`, etc.) are
forwarded verbatim, with two FAB exceptions: `onPressed` is required, and the
default `heroTag` is a package sentinel rather than Flutter's, so no hero flight
runs between a plain and an async FAB. `AsyncButtonTheme` complements
`ButtonStyle` / `ButtonThemeData` — it carries only async behaviour, never
styling.

## Loading only — by design

The button does one job: show a spinner while `onPressed` is in flight. It has
no success or error state.

- **No error state.** An in-button error view is a Material anti-pattern, and
  error handling belongs to your state management. When `onPressed` throws, the
  button returns to idle and **re-throws**: a tap's error reaches the
  surrounding zone (your `runZonedGuarded`, else
  `PlatformDispatcher.instance.onError`) like any other uncaught async error,
  and a `controller.trigger()` caller gets a rejected Future. Handle it where it
  belongs:

  ```dart
  // Typical: your notifier/repository absorbs the failure internally
  // (e.g. AsyncValue.guard), so onPressed never throws.
  ElevatedAsyncButton(
    onPressed: () => ref.read(saveProvider.notifier).save(),
    child: const Text('Save'),
  )

  // Or handle it inline and surface it your way:
  ElevatedAsyncButton(
    onPressed: () async {
      try {
        await repo.submit();
      } on Exception catch (error) {
        messenger.showSnackBar(SnackBar(content: Text('$error')));
      }
    },
    child: const Text('Submit'),
  )
  ```

- **No success state.** Success is handled by what your action already does —
  navigate away, flip the label (Save → Unsave), update a list. An in-button
  "Saved ✓" is usually redundant. Surface it the same way you surface any state
  change.

## Theming

`AsyncButtonTheme` is a `ThemeExtension`. Resolution order for any field is
**per-widget value → theme value → built-in fallback**.

```dart
ThemeData(
  extensions: [
    AsyncButtonTheme(
      loadingBuilder: (_) => const AsyncButtonSpinner(strokeWidth: 3),
      // transitionBuilder: animate every button's swap — see Defaults below.
      maintainSize: true, // keep the idle footprint while loading
      minLoadingDuration: const Duration(milliseconds: 300), // anti-flicker
    ),
  ],
)
```

- `maintainSize` (default `false`) overlays the loading view on the invisible
  idle child, so the button keeps its idle size — no width jump. `.icon`
  constructors keep their icon visible beside the spinner.
- `minLoadingDuration` (default `Duration.zero`) holds the loading view at
  least that long from the tap or `controller.trigger()`, so a fast future
  doesn't flash a spinner. An error rethrows once the floor has elapsed.

Both are also per-widget parameters on every button and on `AsyncButton`.

With no extension registered, `AsyncButtonTheme.of` falls back to
`AsyncButtonTheme.empty` — the default spinner and nothing else.

`copyWith` can't reset a field to null — build a new `AsyncButtonTheme`
instead.

## Custom buttons — `AsyncButton`

`AsyncButton` is the low-level escape hatch. Use it when none of the Material
wrappers fit. The builder receives whether the button is loading:

```dart
AsyncButton(
  onPressed: doWork,
  child: const Text('Go'),
  builder: (context, child, callback, isLoading) => MyButton(
    onTap: callback,
    color: isLoading ? Colors.grey : Colors.indigo,
    child: child,
  ),
)
```

## External control

`AsyncButtonController` is a `ValueListenable<bool>` (loading) plus imperative
methods. Use it for **form keyboard "Done"**, parent-owned state, cross-widget
reactions, and tests.

```dart
final controller = AsyncButtonController();   // dispose like any ChangeNotifier

TextField(
  textInputAction: .done,
  onSubmitted: (_) => controller.trigger(),
)
ElevatedAsyncButton(
  controller: controller,
  onPressed: submit,
  child: const Text('Submit'),
)

controller.trigger();    // run onPressed from outside (rethrows on failure)
controller.reset();      // force back to idle, abandoning the in-flight run
controller.value;        // bool — true while loading (ValueListenable<bool>)
controller.canTrigger;   // bool — true when trigger() would run (not loading, callback attached)
```

`reset()` abandons the in-flight run: the button is idle and re-armed at once
(an escape hatch for a hung future), and the abandoned run's completion is
ignored. One controller drives one mounted button — binding it to a second
fails a debug assertion.

## Defaults

| State    | UI                                          |
| -------- | ------------------------------------------- |
| idle     | your `child`                                |
| loading  | `AsyncButtonSpinner` (sized to the label)   |

The label-button `.icon` constructors (`ElevatedAsyncButton.icon`,
`FilledAsyncButton.icon`, etc.) drop the icon while loading and show the spinner
alone, unless `maintainSize` is set — then the icon stays. (`IconAsyncButton`
has no `.icon` variant — it swaps its sole icon for the spinner.)

**Loading never disables the button.** Being loading and being *disabled* are
different things — the spinner is the indicator, the button keeps its themed
enabled colours, and taps that can't run are silently swallowed (`onLongPress`
is gated off while busy). The button shows the disabled look **only** when you
disable it explicitly — pass `enabled: false` (defaults to `true`) or
`onPressed: null` (without an `onLongPress`, as in Flutter). Either path also
no-ops an external `controller.trigger()`.

**The swap is instant; the button resizes to fit the loading widget.** To keep
the idle size instead, set `maintainSize: true`. The button does no animation of
its own. To smooth the swap — and the size change when the spinner differs from
the child — pass a `transitionBuilder`. The child is already keyed by loading
state, so an `AnimatedSwitcher` inside an `AnimatedSize` is all it takes:

```dart
ElevatedAsyncButton(
  onPressed: api.save,
  transitionBuilder: (context, child, isLoading) => AnimatedSize(
    duration: const Duration(milliseconds: 200),
    child: AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: child,
    ),
  ),
  child: const Text('Save'),
)
```

Set `transitionBuilder` on `AsyncButtonTheme` to animate every button at once.
`AsyncButtonSpinner` is public and inherits the button's foreground — customise
its `color` / `strokeWidth` / `size` and return it from `loadingBuilder`.

## Agent skill

This package ships an agent skill in `skills/material-async-button-usage/`. Install it into your project's agent config with:

```sh
dart run skills@ get --package material_async_button --all
```

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

MIT — see [LICENSE](LICENSE).
