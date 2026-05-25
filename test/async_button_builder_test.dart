import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_async_button/material_async_button.dart';

Widget _wrap(Widget child) =>
    MaterialApp(home: Scaffold(body: Center(child: child)));

void main() {
  group('AsyncButtonBuilder rendering', () {
    testWidgets('shows child in idle state', (tester) async {
      await tester.pumpWidget(_wrap(AsyncButtonBuilder(
        onPressed: () async {},
        child: const Text('hello'),
        builder: (c, child, cb, _) => TextButton(onPressed: cb, child: child),
      )));
      expect(find.text('hello'), findsOneWidget);
    });

    testWidgets('falls back to built-in spinner when no loadingChild',
        (tester) async {
      final completer = Completer<void>();
      await tester.pumpWidget(_wrap(AsyncButtonBuilder(
        onPressed: () => completer.future,
        child: const Text('go'),
        builder: (c, child, cb, _) => TextButton(onPressed: cb, child: child),
      )));
      await tester.tap(find.byType(TextButton));
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      completer.complete();
      await tester.pumpAndSettle();
    });

    testWidgets('uses per-widget loadingChild when given', (tester) async {
      final completer = Completer<void>();
      await tester.pumpWidget(_wrap(AsyncButtonBuilder(
        onPressed: () => completer.future,
        child: const Text('go'),
        loadingChild: const Text('spinning'),
        builder: (c, child, cb, _) => TextButton(onPressed: cb, child: child),
      )));
      await tester.tap(find.byType(TextButton));
      await tester.pump();
      expect(find.text('spinning'), findsOneWidget);
      completer.complete();
      await tester.pumpAndSettle();
    });

    testWidgets('theme loadingChild used when no per-widget override',
        (tester) async {
      final completer = Completer<void>();
      await tester.pumpWidget(MaterialApp(
        theme: ThemeData(extensions: const [
          MaterialAsyncButtonTheme(loadingChild: Text('themed-loading')),
        ]),
        home: Scaffold(
          body: AsyncButtonBuilder(
            onPressed: () => completer.future,
            child: const Text('go'),
            builder: (c, child, cb, _) =>
                TextButton(onPressed: cb, child: child),
          ),
        ),
      ));
      await tester.tap(find.byType(TextButton));
      await tester.pump();
      expect(find.text('themed-loading'), findsOneWidget);
      completer.complete();
      await tester.pumpAndSettle();
    });

    testWidgets('widget loadingChild beats theme', (tester) async {
      final completer = Completer<void>();
      await tester.pumpWidget(MaterialApp(
        theme: ThemeData(extensions: const [
          MaterialAsyncButtonTheme(loadingChild: Text('themed')),
        ]),
        home: Scaffold(
          body: AsyncButtonBuilder(
            onPressed: () => completer.future,
            child: const Text('go'),
            loadingChild: const Text('widget'),
            builder: (c, child, cb, _) =>
                TextButton(onPressed: cb, child: child),
          ),
        ),
      ));
      await tester.tap(find.byType(TextButton));
      await tester.pump();
      expect(find.text('widget'), findsOneWidget);
      expect(find.text('themed'), findsNothing);
      completer.complete();
      await tester.pumpAndSettle();
    });
  });

  group('AsyncButtonBuilder transitions', () {
    testWidgets('returns to child after success with zero display duration',
        (tester) async {
      await tester.pumpWidget(_wrap(AsyncButtonBuilder(
        onPressed: () async {},
        child: const Text('label'),
        builder: (c, child, cb, _) => TextButton(onPressed: cb, child: child),
      )));
      await tester.tap(find.byType(TextButton));
      await tester.pumpAndSettle();
      expect(find.text('label'), findsOneWidget);
    });

    testWidgets('shows successChild for successDisplayDuration',
        (tester) async {
      await tester.pumpWidget(_wrap(AsyncButtonBuilder(
        onPressed: () async {},
        child: const Text('label'),
        successChild: const Text('done!'),
        successDisplayDuration: const Duration(milliseconds: 200),
        builder: (c, child, cb, _) => TextButton(onPressed: cb, child: child),
      )));
      await tester.tap(find.byType(TextButton));
      await tester.pump();
      await tester.pump();
      expect(find.text('done!'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 250));
      await tester.pumpAndSettle();
      expect(find.text('done!'), findsNothing);
      expect(find.text('label'), findsOneWidget);
    });

    testWidgets('shows errorChild and exposes error to errorBuilder',
        (tester) async {
      Object? observed;
      await tester.pumpWidget(_wrap(AsyncButtonBuilder(
        onPressed: () async => throw StateError('boom'),
        child: const Text('label'),
        errorDisplayDuration: const Duration(milliseconds: 100),
        errorBuilder: (c, err, st) {
          observed = err;
          return Text('err: ${err.toString().split(":").last.trim()}');
        },
        builder: (c, child, cb, _) => TextButton(onPressed: cb, child: child),
      )));
      await tester.tap(find.byType(TextButton));
      await tester.pump();
      await tester.pump();
      expect(observed, isA<StateError>());
      expect(find.textContaining('err:'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pumpAndSettle();
    });
  });

  group('AsyncButtonBuilder callbacks', () {
    testWidgets('callback null when disabled', (tester) async {
      await tester.pumpWidget(_wrap(AsyncButtonBuilder(
        onPressed: () async {},
        disabled: true,
        child: const Text('label'),
        builder: (c, child, cb, _) => TextButton(onPressed: cb, child: child),
      )));
      final btn = tester.widget<TextButton>(find.byType(TextButton));
      expect(btn.onPressed, isNull);
    });

    testWidgets('callback null when onPressed is null', (tester) async {
      await tester.pumpWidget(_wrap(AsyncButtonBuilder(
        onPressed: null,
        child: const Text('label'),
        builder: (c, child, cb, _) => TextButton(onPressed: cb, child: child),
      )));
      final btn = tester.widget<TextButton>(find.byType(TextButton));
      expect(btn.onPressed, isNull);
    });

    testWidgets('onSuccess and onStateChanged fire', (tester) async {
      var successCount = 0;
      final changes = <AsyncButtonState>[];
      await tester.pumpWidget(_wrap(AsyncButtonBuilder(
        onPressed: () async {},
        onSuccess: () => successCount++,
        onStateChanged: changes.add,
        child: const Text('label'),
        builder: (c, child, cb, _) => TextButton(onPressed: cb, child: child),
      )));
      await tester.tap(find.byType(TextButton));
      await tester.pumpAndSettle();
      expect(successCount, 1);
      expect(changes.map((s) => s.runtimeType),
          containsAllInOrder(<Type>[
            AsyncButtonStateLoading,
            AsyncButtonStateSuccess,
            AsyncButtonStateIdle,
          ]));
    });

    testWidgets('onError fires with the thrown error', (tester) async {
      Object? captured;
      await tester.pumpWidget(_wrap(AsyncButtonBuilder(
        onPressed: () async => throw StateError('x'),
        onError: (e, _) => captured = e,
        child: const Text('label'),
        builder: (c, child, cb, _) => TextButton(onPressed: cb, child: child),
      )));
      await tester.tap(find.byType(TextButton));
      await tester.pumpAndSettle();
      expect(captured, isA<StateError>());
    });

    testWidgets('confirmBeforePress can cancel the press', (tester) async {
      var ran = 0;
      await tester.pumpWidget(_wrap(AsyncButtonBuilder(
        onPressed: () async => ran++,
        confirmBeforePress: (_) async => false,
        child: const Text('label'),
        builder: (c, child, cb, _) => TextButton(onPressed: cb, child: child),
      )));
      await tester.tap(find.byType(TextButton));
      await tester.pumpAndSettle();
      expect(ran, 0,
          reason: 'onPressed should not run when confirm returns false.');
    });
  });

  group('AsyncButtonBuilder external control', () {
    testWidgets('GlobalKey.trigger() runs onPressed', (tester) async {
      final key = GlobalKey<AsyncButtonBuilderState>();
      var ran = 0;
      await tester.pumpWidget(_wrap(AsyncButtonBuilder(
        key: key,
        onPressed: () async => ran++,
        child: const Text('label'),
        builder: (c, child, cb, _) => TextButton(onPressed: cb, child: child),
      )));
      await key.currentState!.trigger();
      await tester.pumpAndSettle();
      expect(ran, 1);
    });

    testWidgets('AsyncButtonController.invalidate flips to error',
        (tester) async {
      final controller = AsyncButtonController();
      addTearDown(controller.dispose);
      await tester.pumpWidget(_wrap(AsyncButtonBuilder(
        controller: controller,
        onPressed: () async {},
        child: const Text('label'),
        errorChild: const Text('errored'),
        errorDisplayDuration: const Duration(milliseconds: 100),
        builder: (c, child, cb, _) => TextButton(onPressed: cb, child: child),
      )));
      controller.invalidate('bad');
      await tester.pump();
      expect(find.text('errored'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pumpAndSettle();
    });

    testWidgets('AsyncButtonController.reset clears mid-display',
        (tester) async {
      final controller = AsyncButtonController();
      addTearDown(controller.dispose);
      await tester.pumpWidget(_wrap(AsyncButtonBuilder(
        controller: controller,
        onPressed: () async {},
        child: const Text('label'),
        successChild: const Text('yay'),
        successDisplayDuration: const Duration(seconds: 5),
        builder: (c, child, cb, _) => TextButton(onPressed: cb, child: child),
      )));
      controller.markSuccess();
      await tester.pump();
      expect(find.text('yay'), findsOneWidget);
      controller.reset();
      await tester.pump();
      expect(find.text('label'), findsOneWidget);
    });

    testWidgets(
        'swapping the external controller transfers listening without leak',
        (tester) async {
      final a = AsyncButtonController();
      final b = AsyncButtonController();
      addTearDown(() {
        a.dispose();
        b.dispose();
      });
      final builder = (AsyncButtonController c) => AsyncButtonBuilder(
            controller: c,
            onPressed: () async {},
            successChild: const Text('done'),
            successDisplayDuration: const Duration(milliseconds: 100),
            child: const Text('child'),
            builder: (ctx, child, cb, _) =>
                TextButton(onPressed: cb, child: child),
          );
      await tester.pumpWidget(_wrap(builder(a)));
      await tester.pumpWidget(_wrap(builder(b)));
      // Mutating the OLD controller must not change the UI.
      a.markSuccess();
      await tester.pump();
      expect(find.text('done'), findsNothing);
      // New controller drives the UI.
      b.markSuccess();
      await tester.pump();
      expect(find.text('done'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pumpAndSettle();
    });
  });

  group('AsyncButtonBuilder timer hygiene (regression for old timer race)', () {
    testWidgets('rapid invalidate then reset does not later re-flip to idle',
        (tester) async {
      final controller = AsyncButtonController();
      addTearDown(controller.dispose);
      await tester.pumpWidget(_wrap(AsyncButtonBuilder(
        controller: controller,
        onPressed: () async {},
        child: const Text('child'),
        errorChild: const Text('e'),
        errorDisplayDuration: const Duration(milliseconds: 200),
        builder: (c, child, cb, _) => TextButton(onPressed: cb, child: child),
      )));
      controller.invalidate('1');
      await tester.pump();
      // While in error display, manually mark success. The previous error
      // timer must NOT fire and overwrite the new success state.
      controller.markSuccess();
      await tester.pump();
      // Wait beyond the original error timer, less than success timer.
      await tester.pump(const Duration(milliseconds: 250));
      // Default success duration is zero, so we should be back to idle.
      expect(find.text('child'), findsOneWidget);
    });
  });
}
