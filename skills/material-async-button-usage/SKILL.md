---
name: material-async-button-usage
description: Add a loading state to a Material button (ElevatedButton, FilledButton, OutlinedButton, TextButton, IconButton, FloatingActionButton) whose onPressed is async, via the material_async_button package. Triggers on "async button", "loading button", or any `() async {}` handler passed to a Material button.
license: MIT
---

# material-async-button-usage

Replace a Material button (`package:material_ui/material_ui.dart`) with its
async counterpart when `onPressed` is async — it shows a spinner while the
future runs. Every Material param is forwarded, except that the `.icon`
constructors require `icon` and the FAB's default `heroTag` is a package
sentinel.

| Material | Async | Variants |
| --- | --- | --- |
| `ElevatedButton` | `ElevatedAsyncButton` | `.icon` |
| `FilledButton` | `FilledAsyncButton` | `.tonal` `.icon` `.tonalIcon` |
| `OutlinedButton` | `OutlinedAsyncButton` | `.icon` |
| `TextButton` | `TextAsyncButton` | `.icon` |
| `IconButton` | `IconAsyncButton` | `.filled` `.filledTonal` `.outlined` |
| `FloatingActionButton` | `FloatingActionAsyncButton` | `.small` `.large` `.extended` |

```dart
Widget saveButton(AsyncCallback save) =>
    ElevatedAsyncButton(onPressed: save, child: const Text('Save'));
```

Loading-only — no success/error state. Loading never disables the button;
`enabled: false` or `onPressed: null` does (a label button with an `onLongPress`
stays enabled for long-press, as in Flutter; `IconAsyncButton` does not). A
throw rethrows: a tap's error reaches your zone /
`PlatformDispatcher.instance.onError`, and `controller.trigger()` callers get a
rejected Future — handle failures in your state management, not the button.

## Theme (once)

```dart
Widget thickSpinner(BuildContext _) => const AsyncButtonSpinner(
  strokeWidth: 3,
  semanticsLabel: 'Please wait', // screen readers (defaults to 'Loading')
);

final theme = AsyncButtonTheme(
  loadingBuilder: thickSpinner, // a tear-off, never an inline closure
  maintainSize: true, // keep the idle footprint — no width jump
  minLoadingDuration: const Duration(milliseconds: 300), // anti-flicker floor
);
```

Theme builders must be top-level or static functions: an inline closure makes
each rebuilt `ThemeData` unequal, so `MaterialApp` re-animates the theme on
every rebuild.

Per-button props win. No styling knobs — that's `ButtonStyle`'s job. Animate the
swap with `transitionBuilder` (wrap `child` in `AnimatedSwitcher` +
`AnimatedSize`).

## Controller — drive from outside

```dart
final controller = AsyncButtonController(); // dispose like a ChangeNotifier
Widget submitButton(AsyncCallback submit) => ElevatedAsyncButton(
  controller: controller,
  onPressed: submit,
  child: const Text('Submit'),
);

controller.trigger(); // run onPressed externally (e.g. form "Done")
```

Read-only `ValueListenable<bool>` — observe `value` (true while loading); gate
UI with `canTrigger`. One controller per mounted button (a second mounted button
throws `StateError`); `reset()` abandons the run (idle and re-armed at once).
`trigger()`'s Future fails with `StateError` when no button is bound or after
`dispose()` (`reset()` throws after `dispose()`); a disabled button makes it a
no-op; while busy it returns the in-flight run's Future (await waits for the
run, never starts a second). A run stays with the controller that started it —
unmounting or switching the button's controller doesn't end it.

## Custom button — `AsyncButton`

Only when no wrapper fits:

```dart
Widget goButton(AsyncCallback doWork) => AsyncButton(
  onPressed: doWork,
  child: const Text('Go'),
  builder: (context, child, callback, isLoading) =>
      InkWell(onTap: callback, child: child),
);
```

## Don't

- No nested `…AsyncButton`s.
- Disable with `enabled: false` or `onPressed: null` — no `disabled` flag.
- Don't show success/error in the button (loading-only; throws rethrow).
- Don't hand-roll a wrapper for a default spinner — that's `AsyncButtonTheme`.
