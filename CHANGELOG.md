# 1.0.0

Initial release. Renamed from `async_button_builder` to `material_async_button`
with a redesigned, theme-aware API.

### Added

- Material wrapper widgets: `ElevatedAsyncButton`, `FilledAsyncButton`
  (`+.tonal/.icon/.tonalIcon`), `OutlinedAsyncButton`, `TextAsyncButton`,
  `IconAsyncButton` (`+.filled/.filledTonal/.outlined`). Each mirrors its
  Material counterpart constructor-for-constructor.
- `MaterialAsyncButtonTheme` — a `ThemeExtension` for app-wide defaults
  (loading/success/error widgets, durations, curves, haptics, semantics).
  Includes `MaterialAsyncButtonTheme.material()` opinionated factory.
- `AsyncButtonController` — `ValueListenable<AsyncButtonState>` for
  external state control. Methods: `trigger()`, `reset()`,
  `invalidate(error)`, `markSuccess()`.
- `confirmBeforePress`, `errorBuilder`, `onStateChanged`, `cooldownDuration`,
  `hapticOn`, `announceSemantics`, `rethrowErrors` parameters.
- `AsyncButtonBuilderState.trigger()`/`reset()`/`invalidate()`/`markSuccess()`
  for `GlobalKey`-driven control (e.g. form keyboard "Done").

### Changed

- `AsyncButtonState.error` now carries an optional `StackTrace`.
- `onSuccess` / `onError` fire on **entry** to their state, not after the
  display duration elapses.
- Defaults are unopinionated: zero `successDisplayDuration`,
  zero `errorDisplayDuration`, no success/error widget swap unless asked.
  Use `MaterialAsyncButtonTheme.material()` for the v3-style baseline.
- Minimum Dart SDK is `^3.10.0`; minimum Flutter is `>=3.40.0`.

### Fixed

- Stale-timer race: timers from a previous success/error cycle no longer
  overwrite a subsequent state set externally.
- `AsyncButtonState` variants now implement `==`/`hashCode`.
- `KeyedSubtree` switch key is `ValueKey<Type>(stateType)` instead of a
  fresh `UniqueKey()` per state change.

### Removed

- `AsyncButtonNotification` and the `notifications: bool` flag. Use
  `AsyncButtonController` or `onStateChanged` instead.
- `errorPadding` / `successPadding` convenience props — wrap your widgets
  in `Padding` explicitly.
- Per-state transition curves and per-state transition builders. Use a
  single `transitionBuilder` and `switchCurve`, override only when needed.
