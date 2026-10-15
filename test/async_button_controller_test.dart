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
      check(c.canTrigger).isFalse();
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
      check(c).isLoading();
      c.reset();
      check(c).isIdle();
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
      check(c).isIdle();
    });

    testWidgets('failing run resets to idle and rethrows', (tester) async {
      final c = await boundController(
        tester,
        onPressed: () async => throw StateError('oops'),
      );
      final states = recordStates(c);
      await check(c.trigger()).throws<StateError>();
      check(states).deepEquals([true, false]);
      check(c).isIdle();
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
      check(c).isLoading();
      check(because: 'the joiner waits for the run', joinedDone).isFalse();
      completer.complete();
      await Future.wait<void>([first, joined]);
      check(joinedDone).isTrue();
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
      check(c).isIdle();
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
      check(c).isIdle();
      await tester.pump();
      check(joinedDone).isFalse();
      abandoned.complete();
      await Future.wait<void>([first, joined]);
      check(joinedDone).isTrue();
    });

    testWidgets('reset mid-onPressed leaves the button idle', (tester) async {
      final completer = Completer<void>();
      final c = await boundController(
        tester,
        onPressed: () => completer.future,
      );
      final f = c.trigger();
      check(c).isLoading();
      c.reset();
      completer.complete();
      await f;
      check(c).isIdle();
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
      check(c).isLoading();
      c.dispose();
      completer.complete();
      await f;
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
