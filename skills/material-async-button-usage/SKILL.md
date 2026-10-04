---
name: material-async-button-usage
description: Add a loading state to a Material button (ElevatedButton, FilledButton, OutlinedButton, TextButton, IconButton, FloatingActionButton) whose onPressed is async, via the material_async_button package. Triggers on "async button", "loading button", or any `() async {}` handler passed to a Material button.
license: MIT
---

# material-async-button-usage

Replace a Material button with its async counterpart when `onPressed` is async —
it shows a spinner while the future runs. Every Material param is forwarded,
except that FAB `onPressed` is required.

|Material|Async|Variants|
|--|--|--|
|`ElevatedButton`|`ElevatedAsyncButton`|`.icon`|
|`FilledButton`|`FilledAsyncButton`|`.tonal` `.icon` `.tonalIcon`|
|`OutlinedButton`|`OutlinedAsyncButton`|`.icon`|
|`TextButton`|`TextAsyncButton`|`.icon`|
|`IconButton`|`IconAsyncButton`|`.filled` `.filledTonal` `.outlined`|
|`FloatingActionButton`|`FloatingActionAsyncButton`|`.small` `.large` `.extended`|

```dart
ElevatedAsyncButton(onPressed: notifier.save, child: const Text('Save'))
```

Loading-only — no success/error state. Loading never disables the button;
`enabled: false` or `onPressed: null` does. A throw rethrows: a tap's error
reaches your zone / `PlatformDispatcher.instance.onError`, and
`controller.trigger()` callers get a rejected Future — handle failures in your
state management, not the button.

## Theme (once)

```dart
AsyncButtonTheme(
  loadingBuilder: (_) => const AsyncButtonSpinner(
    strokeWidth: 3,
    semanticsLabel: 'Loading', // screen readers (defaults to 'Loading')
  ),
  maintainSize: true, // keep the idle footprint — no width jump
  minLoadingDuration: const Duration(milliseconds: 300), // anti-flicker floor
)
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

Read-only `ValueListenable<bool>` — observe `value` (true while loading); gate UI with `canTrigger`.
One controller per mounted button; `reset()` abandons the run (idle and re-armed at once).

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
