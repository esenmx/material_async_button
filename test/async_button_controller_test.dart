import 'dart:async';

import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_async_button/material_async_button.dart';

import '_helpers.dart';

/// Subscribes a status-recording listener to [c]; returns the recording list.
List<AsyncButtonStatus> recordStatuses(AsyncButtonController c) {
  final out = <AsyncButtonStatus>[];
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

    test('honors initial status', () {
      final c = AsyncButtonController(const .loading());
      addTearDown(c.dispose);
      check(c).isLoading();
    });

    test('trigger no-ops when no onPressed is attached', () async {
      final c = AsyncButtonController();
      addTearDown(c.dispose);
      await c.trigger();
      check(c).isIdle();
    });
  });

  group('AsyncButtonController forced transitions', () {
    test('reset returns to idle and cancels pending display', () async {
      final c = attachedController(
        onPressed: () async {},
        successDuration: const Duration(seconds: 5),
      );
      await c.trigger();
      check(c).isSuccess();
      c.reset();
      check(c).isIdle();
    });

    test('invalidate with zero duration returns straight to idle', () {
      final c = attachedController()..invalidate('bad');
      check(c).isIdle();
    });

    test('invalidate holds error until errorDuration elapses', () async {
      final c = attachedController(
        errorDuration: const Duration(milliseconds: 50),
      )..invalidate('bad');
      check(c.value)
          .isA<AsyncButtonStatusError>()
          .has((f) => f.error, 'error')
          .equals('bad');
      await Future<void>.delayed(const Duration(milliseconds: 70));
      check(c).isIdle();
    });

    test('markSuccess forces success', () {
      final c = attachedController(
        successDuration: const Duration(seconds: 5),
      )..markSuccess();
      check(c).isSuccess();
    });
  });

  group('AsyncButtonController.trigger', () {
    test('successful run traces loading -> success -> idle', () async {
      final c = attachedController(
        onPressed: () => Future<void>.delayed(const Duration(milliseconds: 20)),
        successDuration: const Duration(milliseconds: 20),
      );
      final transitions = recordStatuses(c);
      await c.trigger();
      await Future<void>.delayed(const Duration(milliseconds: 50));
      check(transitions.map((s) => s.runtimeType).toList())
        ..contains(AsyncButtonStatusLoading)
        ..contains(AsyncButtonStatusSuccess)
        ..contains(AsyncButtonStatusIdle);
    });

    test('failing run traces loading -> error -> idle', () async {
      final c = attachedController(
        onPressed: () async => throw StateError('oops'),
        errorDuration: const Duration(milliseconds: 20),
      );
      final transitions = recordStatuses(c);
      await c.trigger();
      await Future<void>.delayed(const Duration(milliseconds: 50));
      check(transitions.map((s) => s.runtimeType).toList())
        ..contains(AsyncButtonStatusLoading)
        ..contains(AsyncButtonStatusError)
        ..contains(AsyncButtonStatusIdle);
    });

    test('error variant carries the thrown error and stack trace', () async {
      final c = attachedController(
        onPressed: () async => throw StateError('oops'),
        errorDuration: const Duration(milliseconds: 50),
      );
      await c.trigger();
      check(c.value)
          .isA<AsyncButtonStatusError>()
          .has((f) => f.error, 'error')
          .isA<StateError>();
      check(c.value)
          .isA<AsyncButtonStatusError>()
          .has((f) => f.stackTrace, 'stackTrace')
          .isNotNull();
      await Future<void>.delayed(const Duration(milliseconds: 70));
      check(c).isIdle();
    });

    test('rethrowErrors=true bubbles the error to the caller', () async {
      final c = attachedController(
        onPressed: () async => throw StateError('oops'),
        rethrowErrors: true,
      );
      await check(c.trigger()).throws<StateError>();
    });

    test('cooldown keeps canTrigger false after returning to idle', () async {
      final c = attachedController(
        onPressed: () async {},
        cooldownDuration: const Duration(milliseconds: 40),
      );
      await c.trigger();
      check(c)
        ..isIdle()
        ..has((it) => it.isInCooldown, 'isInCooldown').isTrue()
        ..has((it) => it.canTrigger, 'canTrigger').isFalse();
      await Future<void>.delayed(const Duration(milliseconds: 60));
      check(c)
        ..has((it) => it.isInCooldown, 'isInCooldown').isFalse()
        ..has((it) => it.canTrigger, 'canTrigger').isTrue();
    });

    test('dispose does not throw for pending timers', () async {
      AsyncButtonController()
        ..attach(
          onPressed: null,
          successDuration: const Duration(seconds: 5),
          errorDuration: .zero,
          cooldownDuration: .zero,
          rethrowErrors: false,
        )
        ..markSuccess()
        ..dispose();
      await Future<void>.delayed(const Duration(milliseconds: 10));
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

    test('reset mid-onPressed stops the success transition', () async {
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
    testWidgets('exposes a ValueListenable<AsyncButtonStatus>', (tester) async {
      final c = attachedController(
        successDuration: const Duration(seconds: 5),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ValueListenableBuilder<AsyncButtonStatus>(
            valueListenable: c,
            builder: (context, status, child) => Text(
              switch (status) {
                AsyncButtonStatusIdle() => 'idle',
                AsyncButtonStatusLoading() => 'loading',
                AsyncButtonStatusSuccess() => 'success',
                AsyncButtonStatusError() => 'error',
              },
              textDirection: .ltr,
            ),
          ),
        ),
      );
      check(find.text('idle')).findsOne();

      c.markSuccess();
      await tester.pump();
      check(find.text('success')).findsOne();
      c.reset();
    });
  });
}
