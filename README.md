# material_async_button

Drop-in async wrappers for Flutter Material buttons. Adds **loading**,
**success**, and **error** statuses to `ElevatedButton`, `FilledButton`,
`OutlinedButton`, `TextButton`, and `IconButton` — without forcing you to
build a project-wide wrapper widget.

```dart
ElevatedAsyncButton(
  onPressed: () async => api.save(),
  child: const Text('Save'),
)
```

That's it. The button shows a spinner while `save()` runs and re-enables
when it returns or throws.

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
    extensions: [AsyncButtonTheme.material()],
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

`AsyncButtonTheme` is a `ThemeExtension`. Resolution order for any
field is **per-widget value → theme value → built-in fallback**.

```dart
ThemeData(
  extensions: [
    AsyncButtonTheme(
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
ThemeData(extensions: [AsyncButtonTheme.material()])
```

## Status pattern matching

`AsyncButtonStatus` is sealed. The error variant carries the error and
stack trace as fields — destructure them inline:

```dart
AsyncButton(
  onPressed: doWork,
  child: const Text('Go'),
  builder: (context, child, callback, status) => MyButton(
    onTap: callback,
    color: switch (status) {
      AsyncButtonStatusIdle()    => Colors.blue,
      AsyncButtonStatusLoading() => Colors.grey,
      AsyncButtonStatusSuccess() => Colors.green,
      AsyncButtonStatusError() => Colors.red,
    },
    child: child,
  ),
)
```

`AsyncButton` is the low-level escape hatch. Use it when none of the
Material wrappers fit.

## Error payload

The error variant owns its thrown payload. Render it inline in the builder:

```dart
AsyncButton(
  onPressed: () async => repo.submit(),
  builder: (context, child, callback, status) => switch (status) {
    AsyncButtonStatusError(:final error) =>
      Text('failed: $error'),
    _ => MyButton(onTap: callback, child: child),
  },
  child: const Text('Submit'),
)
```

Or react externally:

```dart
ValueListenableBuilder<AsyncButtonStatus>(
  valueListenable: controller,
  builder: (_, status, _) => switch (status) {
    AsyncButtonStatusError(:final error) => Text('$error'),
    _ => const SizedBox.shrink(),
  },
)
```

For one-shot notifications (snackbar, log), `onError`:

```dart
ElevatedAsyncButton(
  onPressed: () async => repo.submit(),
  onError: (error, stackTrace) => log.warn('$error'),
  errorChild: const Icon(Icons.error_outline),
  child: const Text('Submit'),
)
```

## External control

`AsyncButtonController` is a `ValueListenable<AsyncButtonStatus>` plus
imperative methods. Use it for **form keyboard "Done"**, parent-owned
state, cross-widget reactions, and tests.

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

// inspect:
controller.value;                              // AsyncButtonStatus (sealed)
// Pattern-match value for the error payload:
if (controller.value case AsyncButtonStatusError(:final error)) {
  log.warn('$error');
}
```

## Defaults

When no `AsyncButtonTheme` extension is registered, `AsyncButtonTheme.of`
falls back to `AsyncButtonTheme.material()`:

| Status     | Default UI                                              |
| ---------- | ------------------------------------------------------- |
| idle       | your `child`                                            |
| loading    | 16×16 `CircularProgressIndicator`                       |
| success    | `Icons.check`, displayed for 800ms                      |
| error      | `Icons.error`, displayed for 800ms                      |

Opt out of the baseline by registering `AsyncButtonTheme.empty` on the
theme, then set only the fields you care about. Per-widget overrides
(e.g. `successChild:` on a single button) always win.

## Features

- `confirmBeforePress` — gate `onPressed` behind a confirmation `Future<bool>`
- `onSuccess` / `onError` / `onStateChanged` — fire-and-forget callbacks
- `errorChild` — static widget shown during error status
- `cooldownDuration` — disable the button briefly after success to prevent
  double-submit
- `hapticOn` — light haptic on success/error
- `announceSemantics` — `SemanticsService.sendAnnouncement` for screen readers
- `rethrowErrors` — rethrow from `controller.trigger()` so callers can
  `try/catch` while the UI also shows the error

## Claude Code skill

A Claude Code skill that teaches Claude to use this package idiomatically
lives in the GitHub repo at
[`tool/claude/flutter-material-async-button/SKILL.md`](https://github.com/esenmx/material_async_button/blob/main/tool/claude/flutter-material-async-button/SKILL.md).
Copy it into `.claude/skills/` in your project.

## License

MIT
