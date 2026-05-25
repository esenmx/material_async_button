import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_async_button/material_async_button.dart';

void main() {
  group('AsyncButtonController', () {
    test('starts in idle by default', () {
      final c = AsyncButtonController();
      expect(c.value, const AsyncButtonState.idle());
      expect(c.isIdle, isTrue);
      expect(c.isLoading, isFalse);
      expect(c.canTrigger, isFalse,
          reason: 'No onPressed attached yet, cannot trigger.');
      c.dispose();
    });

    test('honors initial state', () {
      final c = AsyncButtonController(initial: const AsyncButtonState.loading());
      expect(c.isLoading, isTrue);
      c.dispose();
    });

    test('trigger no-ops when no onPressed is attached', () async {
      final c = AsyncButtonController();
      await c.trigger();
      expect(c.isIdle, isTrue);
      c.dispose();
    });

    test('reset moves to idle and cancels timer', () async {
      final c = AsyncButtonController()
        ..attach(
          onPressed: () async {},
          successDuration: const Duration(seconds: 5),
          errorDuration: Duration.zero,
          cooldownDuration: Duration.zero,
          rethrowErrors: false,
        );
      await c.trigger();
      // We're now in success state for 5s. Reset short-circuits.
      expect(c.isSuccess, isTrue);
      c.reset();
      expect(c.isIdle, isTrue);
      c.dispose();
    });

    test('invalidate forces error and reaches idle when duration zero',
        () async {
      final c = AsyncButtonController()
        ..attach(
          onPressed: null,
          successDuration: Duration.zero,
          errorDuration: Duration.zero,
          cooldownDuration: Duration.zero,
          rethrowErrors: false,
        );
      c.invalidate('bad');
      expect(c.value, const AsyncButtonState.idle(),
          reason: 'Zero error duration returns straight to idle.');
      c.dispose();
    });

    test('invalidate forces error and stays there for errorDuration',
        () async {
      final c = AsyncButtonController()
        ..attach(
          onPressed: null,
          successDuration: Duration.zero,
          errorDuration: const Duration(milliseconds: 50),
          cooldownDuration: Duration.zero,
          rethrowErrors: false,
        );
      c.invalidate('bad');
      expect(c.isError, isTrue);
      expect(c.error, 'bad');
      await Future<void>.delayed(const Duration(milliseconds: 70));
      expect(c.isIdle, isTrue);
      c.dispose();
    });

    test('markSuccess forces success state', () {
      final c = AsyncButtonController()
        ..attach(
          onPressed: null,
          successDuration: const Duration(seconds: 5),
          errorDuration: Duration.zero,
          cooldownDuration: Duration.zero,
          rethrowErrors: false,
        );
      c.markSuccess();
      expect(c.isSuccess, isTrue);
      c.dispose();
    });

    test('successful trigger transitions idle -> loading -> success -> idle',
        () async {
      final transitions = <AsyncButtonState>[];
      final c = AsyncButtonController()
        ..attach(
          onPressed: () async => Future<void>.delayed(
              const Duration(milliseconds: 20)),
          successDuration: const Duration(milliseconds: 20),
          errorDuration: Duration.zero,
          cooldownDuration: Duration.zero,
          rethrowErrors: false,
        );
      c.addListener(() => transitions.add(c.value));
      await c.trigger();
      // trigger awaited onPressed. Success has fired; idle is scheduled in 20ms.
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(
          transitions.map((s) => s.runtimeType).toList(),
          containsAllInOrder(<Type>[
            AsyncButtonStateLoading,
            AsyncButtonStateSuccess,
            AsyncButtonStateIdle,
          ]));
      c.dispose();
    });

    test('failing trigger transitions idle -> loading -> error -> idle',
        () async {
      final transitions = <AsyncButtonState>[];
      final c = AsyncButtonController()
        ..attach(
          onPressed: () async => throw StateError('oops'),
          successDuration: Duration.zero,
          errorDuration: const Duration(milliseconds: 20),
          cooldownDuration: Duration.zero,
          rethrowErrors: false,
        );
      c.addListener(() => transitions.add(c.value));
      await c.trigger();
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(
          transitions.map((s) => s.runtimeType).toList(),
          containsAllInOrder(<Type>[
            AsyncButtonStateLoading,
            AsyncButtonStateError,
            AsyncButtonStateIdle,
          ]));
      c.dispose();
    });

    test('rethrowErrors=true bubbles the error to the caller', () async {
      final c = AsyncButtonController()
        ..attach(
          onPressed: () async => throw StateError('oops'),
          successDuration: Duration.zero,
          errorDuration: Duration.zero,
          cooldownDuration: Duration.zero,
          rethrowErrors: true,
        );
      await expectLater(c.trigger(), throwsA(isA<StateError>()));
      c.dispose();
    });

    test('cooldown keeps canTrigger false after idle returns', () async {
      final c = AsyncButtonController()
        ..attach(
          onPressed: () async {},
          successDuration: Duration.zero,
          errorDuration: Duration.zero,
          cooldownDuration: const Duration(milliseconds: 40),
          rethrowErrors: false,
        );
      await c.trigger();
      expect(c.isIdle, isTrue);
      expect(c.isInCooldown, isTrue);
      expect(c.canTrigger, isFalse);
      await Future<void>.delayed(const Duration(milliseconds: 60));
      expect(c.isInCooldown, isFalse);
      expect(c.canTrigger, isTrue);
      c.dispose();
    });

    test('disposes cleanly without throwing for pending timers', () async {
      final c = AsyncButtonController()
        ..attach(
          onPressed: null,
          successDuration: const Duration(seconds: 5),
          errorDuration: Duration.zero,
          cooldownDuration: Duration.zero,
          rethrowErrors: false,
        );
      c.markSuccess();
      c.dispose();
      // Wait beyond the timer schedule; the disposed flag should suppress
      // notifyListeners on the post-dispose callback.
      await Future<void>.delayed(const Duration(milliseconds: 10));
    });
  });

  group('AsyncButtonController concurrent calls', () {
    test('trigger is a no-op while already loading', () async {
      var calls = 0;
      final completer = Completer<void>();
      final c = AsyncButtonController()
        ..attach(
          onPressed: () async {
            calls++;
            await completer.future;
          },
          successDuration: Duration.zero,
          errorDuration: Duration.zero,
          cooldownDuration: Duration.zero,
          rethrowErrors: false,
        );
      // First trigger starts loading.
      final f1 = c.trigger();
      // Second trigger should no-op because state is loading.
      final f2 = c.trigger();
      expect(c.isLoading, isTrue);
      completer.complete();
      await Future.wait<void>([f1, f2]);
      expect(calls, 1);
      c.dispose();
    });

    test('reset mid-onPressed stops the success transition', () async {
      final completer = Completer<void>();
      final c = AsyncButtonController()
        ..attach(
          onPressed: () async => completer.future,
          successDuration: Duration.zero,
          errorDuration: Duration.zero,
          cooldownDuration: Duration.zero,
          rethrowErrors: false,
        );
      final f = c.trigger();
      expect(c.isLoading, isTrue);
      c.reset();
      completer.complete();
      await f;
      // Should remain idle; trigger's post-await branch sees non-loading and bails.
      expect(c.isIdle, isTrue);
      c.dispose();
    });
  });

  group('AsyncButtonController utility getters', () {
    test('error/stackTrace getters return null off-error', () {
      final c = AsyncButtonController();
      expect(c.error, isNull);
      expect(c.stackTrace, isNull);
      c.dispose();
    });

    test('error/stackTrace getters expose the error variant payload', () {
      final st = StackTrace.current;
      final c = AsyncButtonController(
          initial: AsyncButtonState.error('boom', st));
      expect(c.error, 'boom');
      expect(c.stackTrace, st);
      c.dispose();
    });
  });

  testWidgets('value listenable interop with ValueListenableBuilder',
      (tester) async {
    final c = AsyncButtonController();
    addTearDown(c.dispose);

    String label(AsyncButtonState s) => switch (s) {
          AsyncButtonStateIdle() => 'idle',
          AsyncButtonStateLoading() => 'loading',
          AsyncButtonStateSuccess() => 'success',
          AsyncButtonStateError() => 'error',
        };

    await tester.pumpWidget(MaterialApp(
      home: ValueListenableBuilder<AsyncButtonState>(
        valueListenable: c,
        builder: (_, state, __) => Text(label(state),
            textDirection: TextDirection.ltr),
      ),
    ));
    expect(find.text('idle'), findsOneWidget);

    c.markSuccess();
    await tester.pump();
    expect(find.text('success'), findsOneWidget);
  });
}
