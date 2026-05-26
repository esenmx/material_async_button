---
name: flutter-material-async-button
description: Use this skill when working in a Flutter project that depends on
  the material_async_button package, or when the user wants to add
  loading/success/error UI to a Material button (ElevatedButton, FilledButton,
  OutlinedButton, TextButton, IconButton) whose onPressed is async. Triggers on
  "async button", "loading button", or any handler the user writes as
  `() async {}` and passes to a Material button.
---

# material_async_button

## Default mapping

Replace the Material button with its async counterpart whenever `onPressed`
is async. The wrapper handles loading state, the post-press display, and
disables the button while running.

|Material|Use|Variants|
|--|--|--|
|`ElevatedButton`|`ElevatedAsyncButton`|`.icon`|
|`FilledButton`|`FilledAsyncButton`|`.tonal` `.icon` `.tonalIcon`|
|`OutlinedButton`|`OutlinedAsyncButton`|`.icon`|
|`TextButton`|`TextAsyncButton`|`.icon`|
|`IconButton`|`IconAsyncButton`|`.filled` `.filledTonal` `.outlined`|

## Minimal use

```dart
ElevatedAsyncButton(
  onPressed: notifier.save,
  child: const Text('Save'),
)
```

## Theming — do this once

```dart
ThemeData(extensions: [AsyncButtonTheme.material()])
```

Or, with overrides:

```dart
ThemeData(
  extensions: [
    AsyncButtonTheme(
      successChild: const Icon(Icons.check),
      errorChild:   const Icon(Icons.error_outline),
      switchDuration:        const Duration(milliseconds: 200),
      successDisplayDuration:const Duration(milliseconds: 800),
      errorDisplayDuration:  const Duration(milliseconds: 800),
      animateSize: true,
      hapticOn: HapticOn.both,
    ),
  ],
])
```

Per-button props always win over the theme.

## External control — `AsyncButtonController`

Use this for form "Done" keyboard action, parent-owned state, and
cross-widget reactions:

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

controller.trigger();                          // run onPressed from outside
controller.invalidate('server rejected');      // force error from outside
controller.markSuccess();                      // force success from outside
controller.reset();                            // back to idle
```

It's a `ValueListenable<AsyncButtonStatus>` — pipe into
`ValueListenableBuilder` for cross-widget reactions.

## Custom buttons — `AsyncButton`

Only when no Material wrapper fits:

```dart
AsyncButton(
  onPressed: doWork,
  child: const Text('Go'),
  builder: (context, child, callback, status) => MyButton(
    onTap: callback,
    color: switch (status) {
      AsyncButtonStatusLoading() => Colors.grey,
      AsyncButtonStatusError()   => Colors.red,
      _ => Colors.indigo,
    },
    child: child,
  ),
)
```

## Don't

- Don't wrap an already-async-aware button (no nested `…AsyncButton`s).
- Don't pass `disabled: true` to "pause" — pass `null` to `onPressed` instead.
- Don't call `setState` in `onSuccess` / `onError` for state the button
  already reflects.
- Don't create a project-wide wrapper widget for default loading/success
  spinners — that's exactly what `AsyncButtonTheme` is for.
