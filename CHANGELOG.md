# CHANGELOG

## 2.0.2

### Fixed

- **Buttons no longer shrink by a sub-pixel while loading.** The default spinner
  now sizes to the label's **line-box height** (the idle content's vertical
  extent) rather than the raw `fontSize`, which is shorter than the rendered
  line. `.icon` buttons take `max(iconSize, lineBox)`, text-only buttons take the
  line box, icon-only buttons keep `iconSize` (unchanged). The line box is
  measured with the ambient `TextScaler`, so the loading view also tracks text
  scaling.

## 2.0.1

### Fixed

- **Icon-bearing buttons no longer shrink vertically while loading.** The
  default spinner sizes to the button's shape instead of always to the font
  size: `iconSize` for `IconAsyncButton`, `max(iconSize, fontSize)` for the
  `.icon` constructors (the idle row height), and `fontSize` for text-only
  buttons (unchanged). Sizes are read from the button's resolved `IconTheme` /
  `DefaultTextStyle`, so a per-widget `iconSize` and theme overrides flow
  through.

## 2.0.0

Breaking redesign. The button now does exactly one job — show a spinner while
`onPressed` is in flight — and stays out of error handling, success feedback,
and styling. State collapses to a single `bool` (loading), and the theme becomes
a pure complement to `ButtonStyle`.

### Breaking

- **Loading-only: no success or error state.** Removed `AsyncButtonStatus`
  entirely (the state is now a plain `bool isLoading`), along with `onSuccess`,
  `onError`, `successBuilder`, `errorBuilder`, `feedbackDuration`,
  `cooldownDuration`, `markSuccess`, `markError`, `haptic` / `HapticOn`, and
  `announce` / `AsyncButtonAnnouncer` / `defaultAsyncButtonAnnouncer`. An
  in-button error view is a Material anti-pattern; success is handled by what
  your action already does (navigate away, flip the label). Both belong to your
  state management, not the button.
- **`onPressed` throws now re-propagate.** When `onPressed` throws, the button
  returns to idle and **re-throws** so the error reaches `FlutterError.onError`
  / your `runZonedGuarded` zone. `controller.trigger()` rethrows instead of
  completing normally.
- **`AsyncButtonController` is now a read-only `ValueListenable<bool>`**
  (`ChangeNotifier implements ValueListenable<bool>`). There is no public
  `value` setter — drive it with `trigger()` / `reset()` and observe with
  `addListener` / `ValueListenableBuilder<bool>`. Builders receive `bool
  isLoading` instead of an `AsyncButtonStatus`.
- **`AsyncButtonTheme` carries only `loadingBuilder` + `transitionBuilder`.**
  `AsyncButtonTheme.empty` (spinner-only) is the sole baseline; removed
  `AsyncButtonTheme.material()`. It complements `ButtonStyle` — no styling.
- **`disabled` flag → `enabled` (defaults to `true`).** Affirmative naming that
  pairs with a tear-off `onPressed`. Either `enabled: false` or `onPressed: null`
  disables — both also no-op an external `controller.trigger()`.
- **`loadingChild` (a `Widget`) → `loadingBuilder` (a `WidgetBuilder`)** on both
  the widgets and `AsyncButtonTheme`.
- **Removed the loading-colour knobs** (`loadingForegroundColor`,
  `material(loadingColor:)`). The spinner inherits each button variant's
  foreground; recolour a single button via `AsyncButtonSpinner(color: ...)`.

### Fixed

- **Loading never disables the button.** It keeps the button's themed enabled
  colours — being loading and being *disabled* are different things. The spinner
  inherits the enabled foreground for free (no more greyed indicator); taps that
  can't run are silently swallowed, and `onLongPress` is gated off while busy.
  The button shows the disabled look **only** when explicitly disabled via
  `onPressed: null`.
- **`.icon` buttons drop the icon while loading**, rendering the spinner alone.

### Improved

- The default `AsyncButtonSpinner` derives its size from the ambient font size,
  so it matches the button's label instead of a fixed 16px.
- Guarded against state changes on an unmounted button.
- Corrected the `flutter` SDK constraint.

## 1.0.1

- Docs: use tear-off form (`onPressed: api.save`) in README examples.
- CI: split workflow into format/analyze/test/pana/example, add
  tag-triggered pub.dev publish via OIDC trusted publishing.

## 1.0.0

Initial release. Renamed from `async_button_builder` to `material_async_button`
with a redesigned, theme-aware API.
