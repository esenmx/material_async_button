import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_async_button/material_async_button.dart';

import '_helpers.dart';

void main() {
  group('AsyncButton rendering', () {
    testWidgets('shows child in idle state', (tester) async {
      await tester.pumpWidget(
        pumpHost(
          AsyncButton(
            onPressed: () async {},
            builder: textBuilder,
            child: const Text('hello'),
          ),
        ),
      );
      check(find.text('hello')).findsOne();
    });

    testWidgets('falls back to built-in spinner when no loadingChild', (
      tester,
    ) async {
      final (:onPressed, :completer) = pendingPress();
      await tester.pumpWidget(
        pumpHost(
          AsyncButton(
            onPressed: onPressed,
            builder: textBuilder,
            child: const Text('go'),
          ),
        ),
      );
      await tester.tap(find.byType(TextButton));
      await tester.pump();
      check(find.byType(CircularProgressIndicator)).findsOne();
      completer.complete();
      await tester.pumpAndSettle();
    });

    testWidgets('uses per-widget loadingChild when given', (tester) async {
      final (:onPressed, :completer) = pendingPress();
      await tester.pumpWidget(
        pumpHost(
          AsyncButton(
            onPressed: onPressed,
            loadingChild: const Text('spinning'),
            builder: textBuilder,
            child: const Text('go'),
          ),
        ),
      );
      await tester.tap(find.byType(TextButton));
      await tester.pump();
      check(find.text('spinning')).findsOne();
      completer.complete();
      await tester.pumpAndSettle();
    });

    testWidgets('theme loadingChild used when no per-widget override', (
      tester,
    ) async {
      final (:onPressed, :completer) = pendingPress();
      await tester.pumpWidget(
        pumpHost(
          AsyncButton(
            onPressed: onPressed,
            builder: textBuilder,
            child: const Text('go'),
          ),
          theme: ThemeData(
            extensions: const [
              AsyncButtonTheme(loadingChild: Text('themed-loading')),
            ],
          ),
        ),
      );
      await tester.tap(find.byType(TextButton));
      await tester.pump();
      check(find.text('themed-loading')).findsOne();
      completer.complete();
      await tester.pumpAndSettle();
    });

    testWidgets('widget loadingChild beats theme', (tester) async {
      final (:onPressed, :completer) = pendingPress();
      await tester.pumpWidget(
        pumpHost(
          AsyncButton(
            onPressed: onPressed,
            loadingChild: const Text('widget'),
            builder: textBuilder,
            child: const Text('go'),
          ),
          theme: ThemeData(
            extensions: const [
              AsyncButtonTheme(loadingChild: Text('themed')),
            ],
          ),
        ),
      );
      await tester.tap(find.byType(TextButton));
      await tester.pump();
      check(find.text('widget')).findsOne();
      check(find.text('themed')).findsNone();
      completer.complete();
      await tester.pumpAndSettle();
    });
  });

  group('AsyncButton transitions', () {
    testWidgets('returns to child after success with zero display duration', (
      tester,
    ) async {
      await tester.pumpWidget(
        pumpHost(
          AsyncButton(
            onPressed: () async {},
            builder: textBuilder,
            child: const Text('label'),
          ),
        ),
      );
      await tester.tap(find.byType(TextButton));
      await tester.pumpAndSettle();
      check(find.text('label')).findsOne();
    });

    testWidgets('shows successChild for successDisplayDuration', (
      tester,
    ) async {
      await tester.pumpWidget(
        pumpHost(
          AsyncButton(
            onPressed: () async {},
            successChild: const Text('done!'),
            successDisplayDuration: const Duration(milliseconds: 200),
            builder: textBuilder,
            child: const Text('label'),
          ),
        ),
      );
      await tester.tap(find.byType(TextButton));
      await tester.pump();
      await tester.pump();
      check(find.text('done!')).findsOne();
      await tester.pump(const Duration(milliseconds: 250));
      await tester.pumpAndSettle();
      check(find.text('done!')).findsNone();
      check(find.text('label')).findsOne();
    });

    testWidgets('shows errorChild during error status', (tester) async {
      await tester.pumpWidget(
        pumpHost(
          AsyncButton(
            onPressed: () async => throw StateError('boom'),
            errorChild: const Text('errored'),
            errorDisplayDuration: const Duration(milliseconds: 100),
            builder: textBuilder,
            child: const Text('label'),
          ),
        ),
      );
      await tester.tap(find.byType(TextButton));
      await tester.pump();
      await tester.pump();
      check(find.text('errored')).findsOne();
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pumpAndSettle();
    });

    testWidgets('onError carries the thrown error payload', (tester) async {
      Object? captured;
      await tester.pumpWidget(
        pumpHost(
          AsyncButton(
            onPressed: () async => throw StateError('x'),
            onError: (e, _) => captured = e,
            builder: textBuilder,
            child: const Text('label'),
          ),
        ),
      );
      await tester.tap(find.byType(TextButton));
      await tester.pumpAndSettle();
      check(captured).isA<StateError>();
    });
  });

  group('AsyncButton callbacks', () {
    testWidgets('callback null when disabled', (tester) async {
      await tester.pumpWidget(
        pumpHost(
          AsyncButton(
            onPressed: () async {},
            disabled: true,
            builder: textBuilder,
            child: const Text('label'),
          ),
        ),
      );
      final btn = tester.widget<TextButton>(find.byType(TextButton));
      check(btn.onPressed).isNull();
    });

    testWidgets('callback null when onPressed is null', (tester) async {
      await tester.pumpWidget(
        pumpHost(
          const AsyncButton(
            onPressed: null,
            builder: textBuilder,
            child: Text('label'),
          ),
        ),
      );
      final btn = tester.widget<TextButton>(find.byType(TextButton));
      check(btn.onPressed).isNull();
    });

    testWidgets('onSuccess and onStateChanged fire', (tester) async {
      var successCount = 0;
      final statuses = <AsyncButtonStatus>[];
      await tester.pumpWidget(
        pumpHost(
          AsyncButton(
            onPressed: () async {},
            onSuccess: () => successCount++,
            onStateChanged: statuses.add,
            builder: textBuilder,
            child: const Text('label'),
          ),
        ),
      );
      await tester.tap(find.byType(TextButton));
      await tester.pumpAndSettle();
      check(successCount).equals(1);
      check(statuses.map((s) => s.runtimeType).toList())
        ..contains(AsyncButtonStatusLoading)
        ..contains(AsyncButtonStatusSuccess)
        ..contains(AsyncButtonStatusIdle);
    });

    testWidgets('onError fires with the thrown error', (tester) async {
      Object? captured;
      await tester.pumpWidget(
        pumpHost(
          AsyncButton(
            onPressed: () async => throw StateError('x'),
            onError: (e, _) => captured = e,
            builder: textBuilder,
            child: const Text('label'),
          ),
        ),
      );
      await tester.tap(find.byType(TextButton));
      await tester.pumpAndSettle();
      check(captured).isA<StateError>();
    });

    testWidgets('confirmBeforePress can cancel the press', (tester) async {
      var ran = 0;
      await tester.pumpWidget(
        pumpHost(
          AsyncButton(
            onPressed: () async => ran++,
            confirmBeforePress: (_) async => false,
            builder: textBuilder,
            child: const Text('label'),
          ),
        ),
      );
      await tester.tap(find.byType(TextButton));
      await tester.pumpAndSettle();
      check(ran).equals(0);
    });
  });

  group('AsyncButton external control', () {
    testWidgets('controller.trigger() runs onPressed', (tester) async {
      final controller = AsyncButtonController();
      addTearDown(controller.dispose);
      var ran = 0;
      await tester.pumpWidget(
        pumpHost(
          AsyncButton(
            controller: controller,
            onPressed: () async => ran++,
            builder: textBuilder,
            child: const Text('label'),
          ),
        ),
      );
      await controller.trigger();
      await tester.pumpAndSettle();
      check(ran).equals(1);
    });

    testWidgets('controller.invalidate flips to error', (tester) async {
      final controller = AsyncButtonController();
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        pumpHost(
          AsyncButton(
            controller: controller,
            onPressed: () async {},
            errorChild: const Text('errored'),
            errorDisplayDuration: const Duration(milliseconds: 100),
            builder: textBuilder,
            child: const Text('label'),
          ),
        ),
      );
      controller.invalidate('bad');
      await tester.pump();
      check(find.text('errored')).findsOne();
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pumpAndSettle();
    });

    testWidgets('controller.reset clears mid-display', (tester) async {
      final controller = AsyncButtonController();
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        pumpHost(
          AsyncButton(
            controller: controller,
            onPressed: () async {},
            successChild: const Text('yay'),
            successDisplayDuration: const Duration(seconds: 5),
            builder: textBuilder,
            child: const Text('label'),
          ),
        ),
      );
      controller.markSuccess();
      await tester.pump();
      check(find.text('yay')).findsOne();
      controller.reset();
      await tester.pump();
      check(find.text('label')).findsOne();
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
        AsyncButton button(AsyncButtonController c) => AsyncButton(
          controller: c,
          onPressed: () async {},
          successChild: const Text('done'),
          successDisplayDuration: const Duration(milliseconds: 100),
          builder: textBuilder,
          child: const Text('child'),
        );
        await tester.pumpWidget(pumpHost(button(a)));
        await tester.pumpWidget(pumpHost(button(b)));
        a.markSuccess();
        await tester.pump();
        check(find.text('done')).findsNone();
        b.markSuccess();
        await tester.pump();
        check(find.text('done')).findsOne();
        await tester.pump(const Duration(milliseconds: 200));
        await tester.pumpAndSettle();
      },
    );
  });

  group('AsyncButton timer hygiene', () {
    testWidgets('invalidate then markSuccess does not race', (tester) async {
      final controller = AsyncButtonController();
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        pumpHost(
          AsyncButton(
            controller: controller,
            onPressed: () async {},
            errorChild: const Text('e'),
            errorDisplayDuration: const Duration(milliseconds: 200),
            builder: textBuilder,
            child: const Text('child'),
          ),
        ),
      );
      controller.invalidate('1');
      await tester.pump();
      controller.markSuccess();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));
      check(find.text('child')).findsOne();
    });
  });
}
