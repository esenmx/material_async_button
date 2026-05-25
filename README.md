# material_async_button

Drop-in async wrappers for Flutter Material buttons. Adds **loading**,
**success**, and **error** states to `ElevatedButton`, `FilledButton`,
`OutlinedButton`, `TextButton`, and `IconButton` — without forcing you to
build a project-wide wrapper widget.

```dart
ElevatedAsyncButton(
  onPressed: () async => await api.save(),
  child: const Text('Save'),
)
```

That's it. The button shows a spinner while `save()` runs and re-enables when
it returns or throws.

## Install

```yaml
dependencies:
  material_async_button: ^1.0.0
```

Requires Dart `^3.10.0` (any Flutter SDK shipping Dart 3.10+).

## Why

Most apps end up writing their own `DefaultAsyncButton` wrapper to share
loading-spinner widgets, durations, and transition curves across screens.
This package gives you that wrapper as a [`ThemeExtension`][th]:

```dart
MaterialApp(
  theme: ThemeData(
    extensions: [MaterialAsyncButtonTheme.material()],
  ),
)
```

Configure once, every `*AsyncButton` in the app picks it up. Override per
button when you need to.

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
forwarded verbatim.

## Theming

`MaterialAsyncButtonTheme` is a `ThemeExtension`. Resolution order for any
field is **per-widget value → theme value → built-in fallback**.

```dart
ThemeData(
  extensions: [
    MaterialAsyncButtonTheme(
      switchDuration: const Duration(milliseconds: 200),
      successDisplayDuration: const Duration(milliseconds: 800),
      errorDisplayDuration: const Duration(milliseconds: 800),
      successChild: const Icon(Icons.check),
      errorChild: const Icon(Icons.error_outline),
      animateSize: true,
      hapticOn: HapticOn.both,
      announceSemantics: true,
    ),
  ],
)
```

Or grab the opinionated baseline:

```dart
ThemeData(extensions: [MaterialAsyncButtonTheme.material()])
```

## Unopinionated defaults

Without any theme set:

| State      | Default UI                                  |
| ---------- | ------------------------------------------- |
| idle       | your `child`                                |
| loading    | 16×16 `CircularProgressIndicator`           |
| success    | your `child` (no swap), display duration 0  |
| error      | your `child` (no swap), display duration 0  |

Most apps want a flash of green check / red error. Either set the theme
extension once, or pass `successChild` / `errorChild` per button.

## External control

### `AsyncButtonController` — recommended

The Material wrappers expose state through an `AsyncButtonController`. This is
the pattern to use for **form keyboard "Done"**, parent-owned state,
cross-widget reactions, and tests.

```dart
final controller = AsyncButtonController();   // dispose like any ChangeNotifier

TextField(
  textInputAction: TextInputAction.done,
  onSubmitted: (_) => controller.trigger(),
)
ElevatedAsyncButton(
  controller: controller,
  onPressed: submit,
  child: const Text('Submit'),
)

// any time:
controller.trigger();                          // run onPressed from outside
controller.invalidate('server rejected');      // force error
controller.markSuccess();                      // force success
controller.reset();                            // back to idle
```

### `GlobalKey<AsyncButtonBuilderState>` — for the low-level builder only

If you're using `AsyncButtonBuilder` directly (custom non-Material button),
the same operations are exposed on its `State`:

```dart
final key = GlobalKey<AsyncButtonBuilderState>();

AsyncButtonBuilder(
  key: key,
  onPressed: submit,
  child: const Text('Submit'),
  builder: (c, child, cb, _) => MyButton(onTap: cb, child: child),
)

key.currentState?.trigger();
```

The controller is a `ValueListenable<AsyncButtonState>`. Pipe it to a
`ValueListenableBuilder` for cross-widget UI reactions. Dispose like any
`ChangeNotifier`.

## State pattern matching

```dart
AsyncButtonBuilder(
  onPressed: doWork,
  child: const Text('Go'),
  builder: (context, child, callback, state) => MyButton(
    onTap: callback,
    color: switch (state) {
      AsyncButtonStateIdle()    => Colors.blue,
      AsyncButtonStateLoading() => Colors.grey,
      AsyncButtonStateSuccess() => Colors.green,
      AsyncButtonStateError()   => Colors.red,
    },
    child: child,
  ),
)
```

`AsyncButtonBuilder` is the low-level escape hatch. Use it when none of the
Material wrappers fit.

## Features

- `confirmBeforePress` — gate `onPressed` behind a confirmation `Future<bool>`
- `errorBuilder` — render the thrown error with full context
- `onSuccess` / `onError` / `onStateChanged` — fire-and-forget callbacks
- `cooldownDuration` — disable the button briefly after success to prevent
  double-submit
- `hapticOn` — light haptic on success/error
- `announceSemantics` — `SemanticsService.announce` for screen readers
- `rethrowErrors` — rethrow from `controller.trigger()` so callers can
  `try/catch` while the UI also shows the error

## Migrating from `async_button_builder`

This package is a renamed continuation of `async_button_builder`. The
low-level `AsyncButtonBuilder` and `AsyncButtonState` types are preserved
(`error` now carries a `StackTrace`). Most v3 code keeps working after:

1. `dependencies: async_button_builder: ^3.0.0` → `material_async_button: ^1.0.0`
2. `import 'package:async_button_builder/async_button_builder.dart'`
   → `import 'package:material_async_button/material_async_button.dart'`

The opinionated `notifications` flag and `AsyncButtonNotification` are gone;
use `AsyncButtonController` or `onStateChanged` instead.

## Claude Code skill

A skill that teaches Claude Code to use this package idiomatically ships at
`claude_code_skill/flutter-material-async-button/SKILL.md`. Copy it into
`.claude/skills/` in your project.

## License

MIT
