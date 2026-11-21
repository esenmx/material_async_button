import 'dart:async';

import 'package:checks/checks.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_async_button/material_async_button.dart';
import 'package:material_ui/material_ui.dart';

import '_helpers.dart';

/// Subscribes a loading-recording listener to [c]; returns the recorded list.
List<bool> recordStates(AsyncButtonController c) {
  final out = <bool>[];
  c.addListener(() => out.add(c.value));
  return out;
}

void main() {
  group('AsyncButtonController basics', () {
    test('starts idle by default with no onPressed', () {
      final c = newController();
      check(c)
        ..isIdle
        ..has('canTrigger', (it) => it.canTrigger).isFalse;
    });

    test('trigger() with no bound button throws StateError', () async {
      final c = newController();
      await check(c.trigger()).throws<StateError>();
      check(c).isIdle;
    });

    testWidgets('trigger() after dispose() never runs onPressed', (
      tester,
    ) async {
      var ran = 0;
      Object? err;
      final c = await boundController(
        tester,
        c: AsyncButtonController(),
        onPressed: () async => ran++,
      );
      c.dispose();
      check(c.canTrigger).isFalse;
      await c.trigger().then<void>((_) {}, onError: (Object e) => err = e);
      check(ran).equals(0);
      check(err).isA<StateError>();
    });

    test('reset() after dispose() throws StateError', () {
      final c = AsyncButtonController()..dispose();
      check(c.reset).throws<StateError>();
    });

    testWidgets('reset returns to idle', (tester) async {
      final completer = Completer<void>();
      final c = await boundController(
        tester,
        onPressed: () => completer.future,
      );
      c.trigger();
      check(c).isLoading;
      c.reset();
      check(c).isIdle;
      completer.complete();
    });
  });

  group('AsyncButtonController.trigger', () {
    testWidgets('successful run traces loading -> idle', (tester) async {
      const delay = Duration(milliseconds: 20);
      final c = await boundController(
        tester,
        onPressed: () => Future<void>.delayed(delay),
      );
      final states = recordStates(c);
      final run = c.trigger();
      await tester.pump(delay);
      await run;
      check(states).deepEquals([true, false]);
      check(c).isIdle;
    });

    testWidgets('failing run resets to idle and rethrows', (tester) async {
      final c = await boundController(
        tester,
        onPressed: () async => throw StateError('oops'),
      );
      final states = recordStates(c);
      await check(c.trigger()).throws<StateError>();
      check(states).deepEquals([true, false]);
      check(c).isIdle;
    });
  });

  group('AsyncButtonController concurrency', () {
    testWidgets('trigger while loading joins the run instead of running '
        'again', (tester) async {
      var calls = 0;
      final completer = Completer<void>();
      final c = await boundController(
        tester,
        onPressed: () async {
          calls++;
          await completer.future;
        },
      );
      final first = c.trigger();
      var joinedDone = false;
      final joined = c.trigger().then((_) => joinedDone = true);
      await tester.pump();
      check(c).isLoading;
      check(because: 'the joiner waits for the run', joinedDone).isFalse;
      completer.complete();
      await Future.wait<void>([first, joined]);
      check(joinedDone).isTrue;
      check(calls).equals(1);
    });

    testWidgets('a joined trigger completes with the run error', (
      tester,
    ) async {
      final completer = Completer<void>();
      final c = await boundController(
        tester,
        onPressed: () => completer.future,
      );
      final first = c.trigger();
      final joined = c.trigger();
      completer.completeError(StateError('boom'));
      await check(first).throws<StateError>();
      await check(joined).throws<StateError>();
      check(c).isIdle;
    });

    testWidgets('after reset a joiner still waits for the abandoned run, and a '
        'new trigger starts a new run', (tester) async {
      var calls = 0;
      final abandoned = Completer<void>();
      final c = await boundController(
        tester,
        onPressed: () {
          calls++;
          return calls == 1 ? abandoned.future : Future<void>.value();
        },
      );
      final first = c.trigger();
      var joinedDone = false;
      final joined = c.trigger().then((_) => joinedDone = true);
      c.reset();
      await c.trigger();
      check(calls).equals(2);
      check(c).isIdle;
      await tester.pump();
      check(joinedDone).isFalse;
      abandoned.complete();
      await Future.wait<void>([first, joined]);
      check(joinedDone).isTrue;
    });

    testWidgets('reset mid-onPressed leaves the button idle', (tester) async {
      final completer = Completer<void>();
      final c = await boundController(
        tester,
        onPressed: () => completer.future,
      );
      final f = c.trigger();
      check(c).isLoading;
      c.reset();
      completer.complete();
      await f;
      check(c).isIdle;
    });

    testWidgets('disposing during onPressed does not throw on completion', (
      tester,
    ) async {
      final completer = Completer<void>();
      final c = await boundController(
        tester,
        c: AsyncButtonController(),
        onPressed: () => completer.future,
      );
      final f = c.trigger();
      check(c).isLoading;
      c.dispose();
      completer.complete();
      await f;
    });
  });

  group('AsyncButtonController publishes a run before onPressed starts', () {
    testWidgets('reset in the synchronous prefix leaves the button re-armed', (
      tester,
    ) async {
      final c = newController();
      var calls = 0;
      await boundController(
        tester,
        c: c,
        onPressed: () async {
          if (++calls == 1) {
            c.reset();
          }
        },
      );
      await c.trigger();
      check(c).isIdle;
      check(c.canTrigger).isTrue;
      await c.trigger();
      check(calls).equals(2);
    });

    testWidgets('trigger in the synchronous prefix joins the run', (
      tester,
    ) async {
      final c = newController();
      final finish = Completer<void>();
      final joined = <Future<void>>[];
      var calls = 0;
      await boundController(
        tester,
        c: c,
        onPressed: () {
          calls++;
          joined.add(c.trigger());
          return finish.future;
        },
      );
      final first = c.trigger();
      var joinedDone = false;
      final joiner = joined.single.then((_) => joinedDone = true);
      await tester.pump();
      check(because: 'the joiner waits for the run', joinedDone).isFalse;
      finish.complete();
      await Future.wait<void>([first, joiner]);
      check(joinedDone).isTrue;
      check(calls).equals(1);
    });

    testWidgets('trigger from a loading listener joins the run', (
      tester,
    ) async {
      final c = newController();
      final finish = Completer<void>();
      final joined = <Future<void>>[];
      await boundController(tester, c: c, onPressed: () => finish.future);
      c.addListener(() {
        if (c.value && joined.isEmpty) {
          joined.add(c.trigger());
        }
      });
      final first = c.trigger();
      var joinedDone = false;
      final joiner = joined.single.then((_) => joinedDone = true);
      await tester.pump();
      check(because: 'the joiner waits for the run', joinedDone).isFalse;
      finish.complete();
      await Future.wait<void>([first, joiner]);
      check(joinedDone).isTrue;
    });

    testWidgets('reset from a loading listener abandons the run', (
      tester,
    ) async {
      final c = newController();
      var calls = 0;
      await boundController(tester, c: c, onPressed: () async => calls++);
      var resets = 0;
      c.addListener(() {
        if (c.value && resets == 0) {
          resets++;
          c.reset();
        }
      });
      await c.trigger();
      check(calls).equals(0);
      check(c).isIdle;
      await c.trigger();
      check(calls).equals(1);
    });

    testWidgets(
      'reset then trigger from a loading listener runs onPressed once',
      (tester) async {
        final c = newController();
        var calls = 0;
        await boundController(tester, c: c, onPressed: () async => calls++);
        var retriggered = false;
        late final Future<void> joined;
        c.addListener(() {
          if (c.value && !retriggered) {
            retriggered = true;
            joined = c.trigger();
            c
              ..reset()
              ..trigger();
          }
        });
        await c.trigger();
        await joined;
        check(calls).equals(1);
        check(c).isIdle;
      },
    );

    testWidgets('reset in the synchronous prefix cancels the floor', (
      tester,
    ) async {
      final c = newController();
      await tester.pumpWidget(
        pumpHost(
          AsyncButton(
            controller: c,
            minLoadingDuration: const Duration(seconds: 1),
            onPressed: () async => c.reset(),
            builder: textBuilder,
            child: const Text('go'),
          ),
        ),
      );
      var done = false;
      final run = c.trigger().then((_) => done = true);
      await tester.pump();
      check(because: 'reset releases the abandoned floor', done).isTrue;
      await run;
    });

    testWidgets('dispose in the synchronous prefix cancels the floor', (
      tester,
    ) async {
      final c = AsyncButtonController();
      await tester.pumpWidget(
        pumpHost(
          AsyncButton(
            controller: c,
            minLoadingDuration: const Duration(seconds: 1),
            onPressed: () async => c.dispose(),
            builder: textBuilder,
            child: const Text('go'),
          ),
        ),
      );
      var done = false;
      final run = c.trigger().then((_) => done = true);
      await tester.pump();
      check(because: 'dispose releases the floor', done).isTrue;
      await run;
    });
  });

  group('AsyncButtonController.canTrigger notifies', () {
    Widget gated(AsyncButtonController c, Widget? button) {
      return pumpHost(
        ListenableBuilder(
          listenable: c,
          builder: (context, child) => Column(
            mainAxisSize: .min,
            children: [Text(c.canTrigger ? 'can' : 'cannot'), ?child],
          ),
          child: button,
        ),
      );
    }

    testWidgets('a gate above the button sees the bind', (tester) async {
      final c = newController();
      await tester.pumpWidget(gated(c, boundButton(c, () async {})));
      await tester.pump();
      check(find.text('can')).findsOne;
    });

    testWidgets('a gate above the button sees enabled flip both ways', (
      tester,
    ) async {
      final c = newController();
      Widget button({required bool enabled}) => AsyncButton(
        controller: c,
        enabled: enabled,
        onPressed: () async {},
        builder: textBuilder,
        child: const Text('go'),
      );
      await tester.pumpWidget(gated(c, button(enabled: false)));
      await tester.pump();
      check(find.text('cannot')).findsOne;

      await tester.pumpWidget(gated(c, button(enabled: true)));
      await tester.pump();
      check(find.text('can')).findsOne;

      await tester.pumpWidget(gated(c, button(enabled: false)));
      await tester.pump();
      check(find.text('cannot')).findsOne;
    });

    testWidgets('a gate above the button sees onPressed go null', (
      tester,
    ) async {
      final c = newController();
      Widget button(AsyncCallback? onPressed) => AsyncButton(
        controller: c,
        onPressed: onPressed,
        builder: textBuilder,
        child: const Text('go'),
      );
      await tester.pumpWidget(gated(c, button(() async {})));
      await tester.pump();
      check(find.text('can')).findsOne;

      await tester.pumpWidget(gated(c, button(null)));
      await tester.pump();
      check(find.text('cannot')).findsOne;
    });

    testWidgets('a gate above the button sees the unmount', (tester) async {
      final c = newController();
      await tester.pumpWidget(gated(c, boundButton(c, () async {})));
      await tester.pump();
      check(find.text('can')).findsOne;

      await tester.pumpWidget(gated(c, null));
      await tester.pump();
      check(find.text('cannot')).findsOne;
    });

    testWidgets('the controller a button leaves notifies', (tester) async {
      final a = newController();
      final b = newController();
      await tester.pumpWidget(pumpHost(boundButton(a, () async {})));
      var aNotified = 0;
      a.addListener(() => aNotified++);
      var bNotified = 0;
      b.addListener(() => bNotified++);

      await tester.pumpWidget(pumpHost(boundButton(b, () async {})));
      check(aNotified).equals(1);
      check(a.canTrigger).isFalse;
      check(bNotified).equals(1);
      check(b.canTrigger).isTrue;
    });

    testWidgets('a listener from before the mount hears the bind, then the '
        'run', (tester) async {
      final c = newController();
      final (:onPressed, :completer) = pendingPress();
      final trace = <(bool, bool)>[];
      c.addListener(() => trace.add((c.value, c.canTrigger)));
      await tester.pumpWidget(pumpHost(boundButton(c, onPressed)));
      check(trace).deepEquals([(false, true)]);
      c.trigger();
      completer.complete();
      await tester.pump();
      check(trace).deepEquals([(false, true), (true, false), (false, true)]);
    });

    testWidgets('a new onPressed closure notifies nothing', (tester) async {
      final c = newController();
      await tester.pumpWidget(pumpHost(boundButton(c, () async {})));
      var notified = 0;
      c.addListener(() => notified++);
      await tester.pumpWidget(pumpHost(boundButton(c, () async {})));
      await tester.pump();
      check(notified).equals(0);
    });

    testWidgets('a replacement button in the same frame notifies nothing', (
      tester,
    ) async {
      final c = newController();
      Widget keyed(String key) =>
          KeyedSubtree(key: ValueKey(key), child: boundButton(c, () async {}));
      await tester.pumpWidget(pumpHost(keyed('old')));
      var notified = 0;
      c.addListener(() => notified++);
      await tester.pumpWidget(pumpHost(keyed('new')));
      await tester.pump();
      check(notified).equals(0);
      check(c.canTrigger).isTrue;
    });

    testWidgets('disabling mid-run notifies only the run transitions', (
      tester,
    ) async {
      final c = newController();
      final (:onPressed, :completer) = pendingPress();
      Widget button({required bool enabled}) => AsyncButton(
        controller: c,
        enabled: enabled,
        onPressed: onPressed,
        builder: textBuilder,
        child: const Text('go'),
      );
      await tester.pumpWidget(pumpHost(button(enabled: true)));
      final states = recordStates(c);
      c.trigger();
      await tester.pumpWidget(pumpHost(button(enabled: false)));
      await tester.pump();
      check(states).deepEquals([true]);
      await tester.pumpWidget(pumpHost(button(enabled: true)));
      completer.complete();
      await tester.pump();
      check(states).deepEquals([true, false]);
      check(c.canTrigger).isTrue;
    });

    testWidgets('a controller disposed with its button stays silent', (
      tester,
    ) async {
      final c = AsyncButtonController();
      await tester.pumpWidget(
        pumpHost(_DisposesOnUnmount(c, child: boundButton(c, () async {}))),
      );
      await tester.pumpWidget(pumpHost(const SizedBox()));
      check(tester.takeException()).isNull;
      check(c.canTrigger).isFalse;
    });

    testWidgets('a button does not rebuild for a canTrigger change', (
      tester,
    ) async {
      var builds = 0;
      await tester.pumpWidget(
        pumpHost(
          AsyncButton(
            onPressed: () async {},
            builder: (context, child, callback, isLoading) {
              builds++;
              return TextButton(onPressed: callback, child: child);
            },
            child: const Text('go'),
          ),
        ),
      );
      await tester.pump();
      check(builds).equals(1);
    });
  });

  group('AsyncButtonController interop', () {
    testWidgets('exposes a ValueListenable<bool>', (tester) async {
      final completer = Completer<void>();
      final c = newController();

      await tester.pumpWidget(
        pumpHost(
          Column(
            children: [
              boundButton(c, () => completer.future),
              ValueListenableBuilder<bool>(
                valueListenable: c,
                builder: (context, isLoading, child) =>
                    Text(isLoading ? 'loading' : 'idle'),
              ),
            ],
          ),
        ),
      );
      check(find.text('idle')).findsOne;

      c.trigger();
      await tester.pump();
      check(find.text('loading')).findsOne;

      completer.complete();
      await tester.pump(); // drain the completion microtask
      await tester.pump(); // rebuild with the idle state
      check(find.text('idle')).findsOne;
    });
  });
}

final class _DisposesOnUnmount extends StatefulWidget {
  const new(this.controller, {required this.child});

  final AsyncButtonController controller;
  final Widget child;

  @override
  State<_DisposesOnUnmount> createState() => _DisposesOnUnmountState();
}

final class _DisposesOnUnmountState extends State<_DisposesOnUnmount> {
  @override
  void dispose() {
    widget.controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
