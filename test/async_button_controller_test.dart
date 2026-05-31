import 'dart:async';

import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_async_button/material_async_button.dart';

import '_helpers.dart';

/// Subscribes a loading-recording listener to [c]; returns the recording list.
List<bool> recordStates(AsyncButtonController c) {
  final out = <bool>[];
  c.addListener(() => out.add(c.value));
  return out;
}

void main() {
  group('AsyncButtonController basics', () {
    test('starts idle by default with no onPressed', () {
      final c = AsyncButtonController();
      addTearDown(c.dispose);
      check(c)
        ..isIdle()
        ..has((it) => it.canTrigger, 'canTrigger').isFalse();
    });

    test('trigger no-ops when no onPressed is attached', () async {
      final c = AsyncButtonController();
      addTearDown(c.dispose);
      await c.trigger();
      check(c).isIdle();
    });

    test('reset returns to idle', () async {
      final completer = Completer<void>();
      final c = attachedController(onPressed: () => completer.future);
      unawaited(c.trigger());
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
    test('trigger is a no-op while already loading', () async {
      var calls = 0;
      final completer = Completer<void>();
      final c = attachedController(
        onPressed: () async {
          calls++;
          await completer.future;
        },
      );
      final f1 = c.trigger();
      final f2 = c.trigger();
      check(c).isLoading();
      completer.complete();
      await Future.wait<void>([f1, f2]);
      check(calls).equals(1);
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
  });

  group('AsyncButtonController interop', () {
    testWidgets('exposes a ValueListenable<bool>', (tester) async {
      final completer = Completer<void>();
      final c = attachedController(onPressed: () => completer.future);

      await tester.pumpWidget(
        MaterialApp(
          home: ValueListenableBuilder<bool>(
            valueListenable: c,
            builder: (context, isLoading, child) => Text(
              isLoading ? 'loading' : 'idle',
              textDirection: .ltr,
            ),
          ),
        ),
      );
      check(find.text('idle')).findsOne();

      unawaited(c.trigger());
      await tester.pump();
      check(find.text('loading')).findsOne();

      completer.complete();
      await tester.pump(); // drain the completion microtask
      await tester.pump(); // rebuild with the idle state
      check(find.text('idle')).findsOne();
    });
  });
}
