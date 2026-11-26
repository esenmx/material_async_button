# Theming and animations

The snippets below write `Future<void> Function()` as `AsyncCallback`, from
`package:flutter/foundation.dart`.

## Size and animation

By default, the swap between idle child and spinner is instant and the button
resizes to fit the loading widget.

- Pass `maintainSize: true` to keep the button's idle width while loading.
- Pass `transitionBuilder` to animate the swap and size change. The child is
  already keyed by loading state, so `AnimatedSwitcher` inside `AnimatedSize` is
  all it takes:

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

`AsyncButtonSpinner` is public and inherits the button's foreground colour and
text/icon height. Customize its `color`, `strokeWidth`, or `size` and return it
from `loadingBuilder`.

## App-wide defaults: `AsyncButtonTheme`

Instead of wrapping every button in a custom `DefaultAsyncButton`, register
`AsyncButtonTheme` as a [`ThemeExtension`][th]. Configure once and every
`*AsyncButton` picks it up; override per button whenever needed.
`AsyncButtonTheme` complements `ButtonStyle` / `ButtonThemeData` — it carries
only async behavior, never visual button styling.

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
      disableWhileLoading: true, // draw busy buttons in their disabled style
    ),
  ],
);
```

Pass `loadingBuilder` and `transitionBuilder` as top-level or static functions,
not inline closures. Two closures are never equal, so a `ThemeData` built in
`build()` with an inline closure differs on every rebuild, and `MaterialApp`
restarts its 200 ms theme animation each time. Per-widget builders aren't
affected.

### Theme and per-widget flags

- **`maintainSize`** (default `false`): overlays the loading view on the
  invisible idle child so the button keeps its idle size with no width jump.
  `.icon` constructors keep their icon visible beside the spinner.
- **`minLoadingDuration`** (default `Duration.zero`): holds the loading view at
  least that long from the tap or `controller.trigger()`, so a fast future
  doesn't flash a spinner. An error rethrows once the floor has elapsed. A
  negative duration throws an `ArgumentError` when a button using it builds.
- **`disableWhileLoading`** (default `false`): passes `onPressed: null` while
  the future is in flight, so the button paints its disabled style (and
  `AsyncButtonSpinner` inherits the disabled foreground), then re-enables when
  the run settles.

All three are also per-widget parameters on every `*AsyncButton` and on
`AsyncButton`.

With no extension registered, `AsyncButtonTheme.of` falls back to
`AsyncButtonTheme.empty` — the default spinner and nothing else. `copyWith`
can't reset a field to `null`; build a new `AsyncButtonTheme` instead.
