# Behavior and errors

The snippets below write `Future<void> Function()` as `AsyncCallback`, from
`package:flutter/foundation.dart`.

## States

| State | UI |
| --- | --- |
| idle | your `child` |
| loading | `AsyncButtonSpinner` (sized to the label or icon it replaces) |

### Loading never disables the button by default

Being loading and being _disabled_ are different things — by default, the
spinner is the indicator, the button keeps its themed enabled colours, and taps
that can't run are silently swallowed (`onLongPress` is gated off while busy).

The button shows the disabled look **only** when you disable it explicitly —
pass `enabled: false` (defaults to `true`) or `onPressed: null` — or when you
opt into `disableWhileLoading: true` (per button or on `AsyncButtonTheme`).

As in Flutter, a label button with `onPressed: null` and an `onLongPress` stays
enabled for long-press when idle; `IconAsyncButton`, like `IconButton`, ignores
`onLongPress` without `onPressed`. Explicit `enabled: false` or `onPressed:
null` also no-ops an external `controller.trigger()`.

## Errors and success: loading only

The button does one job: show a spinner while `onPressed` is in flight. It has
no success or error state, by design.

**Errors** belong to your state management; an in-button error view is a Material
anti-pattern. When `onPressed` throws, the button returns to idle and
**re-throws**: a tap's error reaches the surrounding zone (your
`runZonedGuarded`, else `PlatformDispatcher.instance.onError`) like any other
uncaught async error, and a `controller.trigger()` caller gets a rejected
`Future`. Typically your notifier or repository absorbs the failure internally
(for example with Riverpod's `AsyncValue.guard`), so `onPressed` never throws.
Or handle it inline and surface it your way:

```dart
Widget submitButton(BuildContext context, AsyncCallback submit) {
  return ElevatedAsyncButton(
    onPressed: () async {
      final messenger = ScaffoldMessenger.of(context);
      try {
        await submit();
      } on Exception catch (error) {
        messenger.showSnackBar(SnackBar(content: Text('$error')));
      }
    },
    child: const Text('Submit'),
  );
}
```

**Success** is handled by what your action already does — navigate away, flip
the label (Save → Unsave), update a list. An in-button "Saved ✓" is usually
redundant. Surface it the same way you surface any state change.

## Material parameter differences

Every Material constructor is mirrored and every Material parameter is forwarded
verbatim, with these exceptions:

- `onLongPress` is dropped while loading.
- The `.icon` constructors of the four label buttons require `icon` (it stays
  nullable); Material's is optional.
- The label-button `.icon` constructors (`ElevatedAsyncButton.icon`,
  `FilledAsyncButton.icon`, etc.) drop the icon while loading and show the
  spinner alone, unless `maintainSize` is set — then the icon stays.
  (`IconAsyncButton` has no `.icon` variant; it swaps its sole icon for the
  spinner.) With a `transitionBuilder` and no `maintainSize`, the button keeps
  Material's icon-row padding and gap while loading so the swap can animate, and
  the spinner sits slightly off center wherever those are uneven, such as
  `iconAlignment: .end`.
- The FAB's default `heroTag` is a package sentinel rather than Flutter's, so no
  hero flight runs between a plain and an async FAB.
