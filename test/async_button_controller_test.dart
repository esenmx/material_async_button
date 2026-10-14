import 'dart:async';

import 'package:checks/checks.dart';
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
        ..isIdle()
        ..has((it) => it.canTrigger, 'canTrigger').isFalse();
    });

    test('trigger() with no bound button throws StateError', () async {
      final c = newController();
      await check(c.trigger()).throws<StateError>();
      check(c).isIdle();
    });

    test('trigger() after dispose() never runs onPressed', () async {
      var ran = 0;
      Object? err;
      final c = AsyncButtonController()
        ..attach(onPressed: () async => ran++)
        ..dispose();
      check(c.canTrigger).isFalse();
      await c.trigger().then<void>((_) {}, onError: (Object e) => err = e);
      check(ran).equals(0);
      check(err).isA<StateError>();
    });

    test('reset() after dispose() throws StateError', () {
      final c = AsyncButtonController()..dispose();
      check(c.reset).throws<StateError>();
    });

    test('attach() after dispose() throws StateError', () {
      final c = AsyncButtonController()..dispose();
      check(() => c.attach(onPressed: () async {})).throws<StateError>();
    });

    test('reset returns to idle', () async {
      final completer = Completer<void>();
      final c = attachedController(onPressed: () => completer.future)
        ..trigger();
      check(c).isLoading();
      c.reset();
      check(c).isIdle();
      completer.complete();
    });
  });

  group('AsyncButtonController.trigger', () {
    test('successful run traces loading -> idle', () async {
      final c = attachedController(
        onPressed: () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
      final states = recordStates(c);
      await c.trigger();
      check(states).deepEquals([true, false]);
      check(c).isIdle();
    });

    test('failing run resets to idle and rethrows', () async {
      final c = attachedController(
        onPressed: () async => throw StateError('oops'),
      );
      final states = recordStates(c);
      await check(c.trigger()).throws<StateError>();
      check(states).deepEquals([true, false]);
      check(c).isIdle();
    });
  });

  group('AsyncButtonController concurrency', () {
    test(
      'trigger while loading joins the run instead of running again',
      () async {
        var calls = 0;
        final completer = Completer<void>();
        final c = attachedController(
          onPressed: () async {
            calls++;
            await completer.future;
          },
        );
        final first = c.trigger();
        var joinedDone = false;
        final joined = c.trigger().then((_) => joinedDone = true);
        await pumpEventQueue();
        check(c).isLoading();
        check(because: 'the joiner waits for the run', joinedDone).isFalse();
        completer.complete();
        await Future.wait<void>([first, joined]);
        check(joinedDone).isTrue();
        check(calls).equals(1);
      },
    );

    test('a joined trigger completes with the run error', () async {
      final completer = Completer<void>();
      final c = attachedController(onPressed: () => completer.future);
      final first = c.trigger();
      final joined = c.trigger();
      completer.completeError(StateError('boom'));
      await check(first).throws<StateError>();
      await check(joined).throws<StateError>();
      check(c).isIdle();
    });

    test('after reset a joiner still waits for the abandoned run, and a new '
        'trigger starts a new run', () async {
      var calls = 0;
      final abandoned = Completer<void>();
      final c = attachedController(
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
      check(c).isIdle();
      await pumpEventQueue();
      check(joinedDone).isFalse();
      abandoned.complete();
      await Future.wait<void>([first, joined]);
      check(joinedDone).isTrue();
    });

    test('reset mid-onPressed leaves the button idle', () async {
      final completer = Completer<void>();
      final c = attachedController(onPressed: () => completer.future);
      final f = c.trigger();
      check(c).isLoading();
      c.reset();
      completer.complete();
      await f;
      check(c).isIdle();
    });

    test('disposing during onPressed does not throw on completion', () async {
      final completer = Completer<void>();
      final c = AsyncButtonController()
        ..attach(onPressed: () => completer.future);
      final f = c.trigger();
      check(c).isLoading();
      c.dispose();
      completer.complete();
      await f;
      // Should complete without FlutterError/AssertionError from notifyListeners
    });
  });

  group('AsyncButtonController interop', () {
    testWidgets('exposes a ValueListenable<bool>', (tester) async {
      final completer = Completer<void>();
      final c = attachedController(onPressed: () => completer.future);

      await tester.pumpWidget(
        MaterialApp(
          home: ValueListenableBuilder<bool>(
            valueListenable: c,
            builder: (context, isLoading, child) =>
                Text(isLoading ? 'loading' : 'idle', textDirection: .ltr),
          ),
        ),
      );
      check(find.text('idle')).findsOne();

      c.trigger();
      await tester.pump();
      check(find.text('loading')).findsOne();

      completer.complete();
      await tester.pump(); // drain the completion microtask
      await tester.pump(); // rebuild with the idle state
      check(find.text('idle')).findsOne();
    });
  });
}
