---
name: material-async-button-usage
description: Add a loading state to a Material button (ElevatedButton, FilledButton, OutlinedButton, TextButton, IconButton, FloatingActionButton) whose onPressed is async, via the material_async_button package. Triggers on "async button", "loading button", or any `() async {}` handler passed to a Material button.
license: MIT
---

# material-async-button-usage

Drop-in async wrappers for `package:material_ui/material_ui.dart` buttons — show spinner while `onPressed` future runs. All Material params forward (except `.icon` requires `icon`, FAB default `heroTag` is package sentinel; a disabled FAB paints Material's disabled colours over `foregroundColor`/`backgroundColor`).

|Material|Async|Variants|
|-|-|-|
|`ElevatedButton`|`ElevatedAsyncButton`|`.icon`|
|`FilledButton`|`FilledAsyncButton`|`.tonal` `.icon` `.tonalIcon`|
|`OutlinedButton`|`OutlinedAsyncButton`|`.icon`|
|`TextButton`|`TextAsyncButton`|`.icon`|
|`IconButton`|`IconAsyncButton`|`.filled` `.filledTonal` `.outlined`|
|`FloatingActionButton`|`FloatingActionAsyncButton`|`.small` `.large` `.extended`|

```dart
Widget saveButton(AsyncCallback save) =>
    ElevatedAsyncButton(onPressed: save, child: const Text('Save'));
```

- Loading-only (no success/error UI). Does not disable while loading by default (`disableWhileLoading: true` opts in). `enabled: false` or `onPressed: null` disables at idle (label buttons with `onLongPress` keep long-press at idle; `IconAsyncButton` does not). Throws rethrow (tap -> zone/`PlatformDispatcher.instance.onError`; `controller.trigger()` -> rejected Future).

## Theme (once)

```dart
Widget thickSpinner(BuildContext _) => const AsyncButtonSpinner(
  strokeWidth: 3,
  semanticsLabel: 'Please wait', // default 'Loading'
);
final theme = AsyncButtonTheme(
  loadingBuilder: thickSpinner, // top-level/static tear-off, never inline
  maintainSize: true, // keep idle size, no width jump
  minLoadingDuration: const Duration(milliseconds: 300), // anti-flicker floor
  disableWhileLoading: true, // opt-in: disabled look while busy
);
```

- Negative `minLoadingDuration` throws `ArgumentError` on build. Theme `loadingBuilder`/`transitionBuilder` must be top-level/static: an inline closure breaks `ThemeData` equality -> re-animates `MaterialApp` every rebuild. Per-button props win; styling stays in `ButtonStyle`; swap animation via `transitionBuilder` (`AnimatedSwitcher`+`AnimatedSize`).

## Controller (external trigger)

```dart
final controller = AsyncButtonController(); // dispose like ChangeNotifier
Widget submitButton(AsyncCallback submit) => ElevatedAsyncButton(
  controller: controller,
  onPressed: submit,
  child: const Text('Submit'),
);
controller.trigger();
```

- Read-only `ValueListenable<bool>` (`value` = loading); gate UI via `canTrigger` in `ListenableBuilder` (also notifies post-frame when `canTrigger` changes on mount/unmount/`enabled`/`onPressed`).
- One mounted button per controller (2nd throws `StateError`). `reset()` abandons run and re-arms immediately (throws after `dispose()`). `trigger()` rejects with `StateError` if unbound/disposed; no-ops if disabled; returns in-flight Future if busy (never double-runs). Unmounting or swapping controller never cancels an active run.

## Custom button & don'ts

Escape hatch when no wrapper fits:

```dart
Widget goButton(AsyncCallback doWork) => AsyncButton(
  onPressed: doWork,
  builder: (context, child, callback, isLoading) =>
      InkWell(onTap: callback, child: child),
  child: const Text('Go'),
);
```

- Don't nest `…AsyncButton`s; disable with `enabled: false`/`onPressed: null` (no `disabled` flag); don't put success/error UI inside button; don't wrap for a default spinner (use `AsyncButtonTheme`).
