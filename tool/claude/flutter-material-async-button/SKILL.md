---
name: flutter-material-async-button
description: Use this skill when working in a Flutter project that depends on
  the material_async_button package, or when the user wants to add a loading
  state to a Material button (ElevatedButton, FilledButton, OutlinedButton,
  TextButton, IconButton) whose onPressed is async. Triggers on "async button",
  "loading button", or any handler the user writes as `() async {}` and passes
  to a Material button.
---

# material_async_button

Replace a Material button with its async counterpart when `onPressed` is async —
it shows a spinner while the future runs. Every Material param is forwarded.

|Material|Async|Variants|
|--|--|--|
|`ElevatedButton`|`ElevatedAsyncButton`|`.icon`|
|`FilledButton`|`FilledAsyncButton`|`.tonal` `.icon` `.tonalIcon`|
|`OutlinedButton`|`OutlinedAsyncButton`|`.icon`|
|`TextButton`|`TextAsyncButton`|`.icon`|
|`IconButton`|`IconAsyncButton`|`.filled` `.filledTonal` `.outlined`|

```dart
ElevatedAsyncButton(onPressed: notifier.save, child: const Text('Save'))
```

Loading-only — no success/error state. Loading never disables the button;
`enabled: false` or `onPressed: null` does. A throw rethrows (reaches
`FlutterError.onError`) — handle failures in your state management, not the
button.

## Theme (once)

```dart
AsyncButtonTheme(loadingBuilder: (_) => const AsyncButtonSpinner(strokeWidth: 3))
```

Per-button props win. No styling knobs — that's `ButtonStyle`'s job. Animate the
swap with `transitionBuilder` (wrap `child` in `AnimatedSwitcher` + `AnimatedSize`).

## Controller — drive from outside

```dart
final controller = AsyncButtonController(); // dispose like a ChangeNotifier
ElevatedAsyncButton(controller: controller, onPressed: submit, child: ...)

controller.trigger(); // run onPressed externally (e.g. form "Done")
controller.reset();
```

`ValueListenable<bool>` (`isLoading`).

## Custom button — `AsyncButton`

Only when no wrapper fits:

```dart
AsyncButton(
  onPressed: doWork,
  child: const Text('Go'),
  builder: (context, child, callback, isLoading) =>
      MyButton(onTap: callback, child: child),
)
```

## Don't

- No nested `…AsyncButton`s.
- Disable with `enabled: false` or `onPressed: null` — no `disabled` flag.
- Don't show success/error in the button (loading-only; throws rethrow).
- Don't hand-roll a wrapper for a default spinner — that's `AsyncButtonTheme`.
