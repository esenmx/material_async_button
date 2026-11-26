# Controller and custom buttons

The snippets below write `Future<void> Function()` as `AsyncCallback`, from
`package:flutter/foundation.dart`.

## External control: `AsyncButtonController`

`AsyncButtonController` is a `ValueListenable<bool>` (loading) plus imperative
methods. Use it for **form keyboard "Done"**, parent-owned state, cross-widget
reactions, and tests. Dispose it like any `ChangeNotifier`.

```dart
final controller = AsyncButtonController();

Widget form(AsyncCallback submit) => Column(
  children: [
    TextField(textInputAction: .done, onSubmitted: (_) => controller.trigger()),
    ElevatedAsyncButton(
      controller: controller,
      onPressed: submit,
      child: const Text('Submit'),
    ),
  ],
);
```

### API

- `controller.trigger()` runs `onPressed` from outside; its `Future` fails if
  `onPressed` throws. While a run is in flight, it starts nothing and returns
  that run's `Future`, so `await controller.trigger()` waits for the real run
  and sees its error.
- `controller.reset()` forces the button back to idle and abandons the in-flight
  run: the button is re-armed at once (an escape hatch for a hung future), and
  the abandoned run's completion is ignored.
- `controller.value` is `true` while loading.
- `controller.canTrigger` is `true` when `trigger()` would run: not loading, and
  bound to an enabled button. The controller notifies listeners when it changes,
  so a `ListenableBuilder` can gate surrounding UI on it. Listeners hear a
  change from a run at once, and one from the button (mounting, unmounting,
  `enabled`, `onPressed`) after that frame, so a listener can fire with `value`
  unchanged.

### Ownership and lifecycle

One controller drives one mounted button — binding it to a second throws a
`StateError` once the frame settles. When no button is bound (never passed to
one, or its button unmounted or switched to another controller), `trigger()`
returns a `Future` that fails with a `StateError`; gate on `canTrigger`. After
`dispose()`, `reset()` throws a `StateError` and `trigger()` returns a `Future`
that fails with one.

A run belongs to the controller that started it: unmounting the button or
switching it to another controller leaves the run, and its `minLoadingDuration`,
on that controller until it settles, or until you `reset()` or `dispose()` it.

## Custom buttons: `AsyncButton`

`AsyncButton` is the low-level escape hatch when none of the Material wrappers
fit. The builder receives the current child, the gated callback, and whether the
button is loading:

```dart
Widget goButton(AsyncCallback doWork) => AsyncButton(
  onPressed: doWork,
  child: const Text('Go'),
  builder: (context, child, callback, isLoading) => InkWell(
    onTap: callback,
    child: Ink(color: isLoading ? Colors.grey : Colors.indigo, child: child),
  ),
);
```
