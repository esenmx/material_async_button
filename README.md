# material_async_button

Drop-in async wrappers for Flutter Material buttons. Adds a **loading** state to
`ElevatedButton`, `FilledButton`, `OutlinedButton`, `TextButton`, and
`IconButton` — without forcing you to build a project-wide wrapper widget.

```dart
ElevatedAsyncButton(
  onPressed: api.save,
  child: const Text('Save'),
)
```

That's it. The button shows a spinner while `save()` runs and returns to its
label when it completes.

## Install

```yaml
dependencies:
  material_async_button: ^2.0.0
```

Requires Dart `^3.10.0` and Flutter `>=3.38.0`.

## Why

Most apps end up writing their own `DefaultAsyncButton` wrapper to share a
loading widget and its transition across screens. This package gives you that
wrapper as a [`ThemeExtension`][th] — configure once, every `*AsyncButton` picks
it up; override per button when you need to.

[th]: https://api.flutter.dev/flutter/material/ThemeExtension-class.html

## Material wrappers

| Material         | Async counterpart      | Variants                                            |
| ---------------- | ---------------------- | --------------------------------------------------- |
| `ElevatedButton` | `ElevatedAsyncButton`  | `.icon`                                             |
| `FilledButton`   | `FilledAsyncButton`    | `.tonal`, `.icon`, `.tonalIcon`                     |
| `OutlinedButton` | `OutlinedAsyncButton`  | `.icon`                                             |
| `TextButton`     | `TextAsyncButton`      | `.icon`                                             |
| `IconButton`     | `IconAsyncButton`      | `.filled`, `.filledTonal`, `.outlined`              |

Every Material constructor is mirrored. All Material parameters (`style`,
`focusNode`, `autofocus`, `clipBehavior`, `statesController`, etc.) are
forwarded verbatim. `AsyncButtonTheme` complements `ButtonStyle` /
`ButtonThemeData` — it carries only the loading view, never styling.

## Loading only — by design

The button does one job: show a spinner while `onPressed` is in flight. It has
no success or error state.

- **No error state.** An in-button error view is a Material anti-pattern, and
  error handling belongs to your state management. When `onPressed` throws, the
  button returns to idle and **re-throws** — the error reaches
  `FlutterError.onError` / your `runZonedGuarded` zone, like any other uncaught
  error. Handle it where it belongs:

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
    ),
  ],
)
```

With no extension registered, `AsyncButtonTheme.of` falls back to
`AsyncButtonTheme.empty` — the default spinner and nothing else.

The default spinner sizes itself from the ambient font size, not `IconTheme.size`,
so inside an `IconAsyncButton` pass `loadingBuilder: (_) => AsyncButtonSpinner(size: ...)`
to match the icon's footprint.

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
controller.reset();      // force back to idle
controller.isLoading;    // bool
controller.canTrigger;   // bool — true when trigger() would run (not loading, callback attached)
```

## Defaults

| State    | UI                                          |
| -------- | ------------------------------------------- |
| idle     | your `child`                                |
| loading  | `AsyncButtonSpinner` (sized to the label)   |

The label-button `.icon` constructors (`ElevatedAsyncButton.icon`,
`FilledAsyncButton.icon`, etc.) drop the icon while loading and show the spinner
alone. (`IconAsyncButton` has no `.icon` variant — it swaps its sole icon for the
spinner.)

**Loading never disables the button.** Being loading and being *disabled* are
different things — the spinner is the indicator, the button keeps its themed
enabled colours, and taps that can't run are silently swallowed (`onLongPress`
is gated off while busy). The button shows the disabled look **only** when you
disable it explicitly — pass `enabled: false` (defaults to `true`) or
`onPressed: null`. Either path also no-ops an external `controller.trigger()`.

**The swap is instant; the button resizes to fit the loading widget.** The
button does no animation of its own. To smooth the swap — and the size change
when the spinner differs from the child — pass a `transitionBuilder`. The child
is already keyed by loading state, so an `AnimatedSwitcher` inside an
`AnimatedSize` is all it takes:

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

## Claude Code skill

A Claude Code skill that teaches Claude to use this package idiomatically
lives in the GitHub repo at
[`tool/claude/flutter-material-async-button/SKILL.md`](https://github.com/esenmx/material_async_button/blob/main/tool/claude/flutter-material-async-button/SKILL.md).
Copy it into `.claude/skills/` in your project.

## License

MIT
