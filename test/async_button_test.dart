import 'dart:async';

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

    testWidgets('falls back to built-in spinner when no loadingBuilder', (
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

    testWidgets('stays enabled while loading (taps are no-ops)', (
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
      // Loading never disables the button — the callback stays wired; the
      // controller swallows the tap (still loading), so it doesn't re-run.
      final btn = tester.widget<TextButton>(find.byType(TextButton));
      check(btn.onPressed).isNotNull();
      completer.complete();
      await tester.pumpAndSettle();
    });

    testWidgets('uses per-widget loadingBuilder when given', (tester) async {
      final (:onPressed, :completer) = pendingPress();
      await tester.pumpWidget(
        pumpHost(
          AsyncButton(
            onPressed: onPressed,
            loadingBuilder: (_) => const Text('spinning'),
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

    testWidgets('theme loadingBuilder used when no per-widget override', (
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
          theme: asyncButtonTheme(
            loadingBuilder: (_) => const Text('themed-loading'),
          ),
        ),
      );
      await tester.tap(find.byType(TextButton));
      await tester.pump();
      check(find.text('themed-loading')).findsOne();
      completer.complete();
      await tester.pumpAndSettle();
    });

    testWidgets('widget loadingBuilder beats theme', (tester) async {
      final (:onPressed, :completer) = pendingPress();
      await tester.pumpWidget(
        pumpHost(
          AsyncButton(
            onPressed: onPressed,
            loadingBuilder: (_) => const Text('widget'),
            builder: textBuilder,
            child: const Text('go'),
          ),
          theme: asyncButtonTheme(loadingBuilder: (_) => const Text('themed')),
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
    testWidgets('returns to its child after onPressed completes', (
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

    testWidgets('a throwing onPressed returns to idle and rethrows', (
      tester,
    ) async {
      final controller = newController();
      await tester.pumpWidget(
        pumpHost(
          AsyncButton(
            controller: controller,
            onPressed: () async => throw StateError('boom'),
            builder: textBuilder,
            child: const Text('label'),
          ),
        ),
      );
      // The error is not swallowed — trigger() rethrows so the caller (state
      // management / the surrounding zone) sees it.
      await check(controller.trigger()).throws<StateError>();
      await tester.pump();
      // The button is back to its idle child — there is no error view.
      check(find.text('label')).findsOne();
    });
  });

  group('AsyncButton callbacks', () {
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

    testWidgets('callback null when enabled is false', (tester) async {
      await tester.pumpWidget(
        pumpHost(
          AsyncButton(
            onPressed: () async {},
            enabled: false,
            builder: textBuilder,
            child: const Text('label'),
          ),
        ),
      );
      final btn = tester.widget<TextButton>(find.byType(TextButton));
      check(btn.onPressed).isNull();
    });

    testWidgets('enabled:false no-ops external controller.trigger', (
      tester,
    ) async {
      var ran = 0;
      final controller = newController();
      await tester.pumpWidget(
        pumpHost(
          AsyncButton(
            controller: controller,
            onPressed: () async => ran++,
            enabled: false,
            builder: textBuilder,
            child: const Text('label'),
          ),
        ),
      );
      // enabled:false collapses to onPressed:null at the controller seam, so an
      // external trigger can't run either.
      await controller.trigger();
      await tester.pump();
      check(ran).equals(0);
      check(controller).isIdle();
      check(find.byType(CircularProgressIndicator)).findsNone();
    });
  });

  group('AsyncButton external control', () {
    testWidgets('controller.trigger drives loading; stays enabled', (
      tester,
    ) async {
      final controller = newController();
      final completer = Completer<void>();
      await tester.pumpWidget(
        pumpHost(
          AsyncButton(
            controller: controller,
            onPressed: () => completer.future,
            builder: textBuilder,
            child: const Text('label'),
          ),
        ),
      );
      // Idle: interactive.
      check(
        tester.widget<TextButton>(find.byType(TextButton)).onPressed,
      ).isNotNull();

      unawaited(controller.trigger());
      await tester.pump();
      // Loading: spinner shows and the button keeps its enabled look.
      check(find.byType(CircularProgressIndicator)).findsOne();
      check(
        tester.widget<TextButton>(find.byType(TextButton)).onPressed,
      ).isNotNull();

      completer.complete();
      await tester.pumpAndSettle();
      check(find.text('label')).findsOne();
    });

    testWidgets('controller.reset clears the loading state', (tester) async {
      final controller = newController();
      final completer = Completer<void>();
      await tester.pumpWidget(
        pumpHost(
          AsyncButton(
            controller: controller,
            onPressed: () => completer.future,
            builder: textBuilder,
            child: const Text('label'),
          ),
        ),
      );
      unawaited(controller.trigger());
      await tester.pump();
      check(find.byType(CircularProgressIndicator)).findsOne();
      controller.reset();
      await tester.pump();
      check(find.text('label')).findsOne();
      completer.complete();
    });

    testWidgets(
      'swapping from internal to external controller disposes internal and uses new',
      (tester) async {
        final externalController = newController();
        final completer = Completer<void>();
        AsyncButton button(AsyncButtonController? c) => AsyncButton(
              controller: c,
              onPressed: () => completer.future,
              builder: textBuilder,
              child: const Text('child'),
            );

        // 1. Pump with internal controller (null)
        await tester.pumpWidget(pumpHost(button(null)));

        // 2. Pump with external controller
        await tester.pumpWidget(pumpHost(button(externalController)));

        // The widget now listens to externalController: driving it must show loading.
        unawaited(externalController.trigger());
        await tester.pump();
        check(find.byType(CircularProgressIndicator)).findsOne();

        completer.complete();
        await tester.pumpAndSettle();
      },
    );

    testWidgets(
      'swapping from external to internal controller',
      (tester) async {
        final externalController = newController();
        final completer = Completer<void>();
        AsyncButton button(AsyncButtonController? c) => AsyncButton(
              controller: c,
              onPressed: () => completer.future,
              builder: textBuilder,
              child: const Text('child'),
            );

        // 1. Pump with external controller
        await tester.pumpWidget(pumpHost(button(externalController)));

        // 2. Pump with internal controller (null)
        await tester.pumpWidget(pumpHost(button(null)));

        // Driving externalController should NOT show loading because it's detached
        unawaited(externalController.trigger());
        await tester.pump();
        check(find.byType(CircularProgressIndicator)).findsNone();

        completer.complete();
        await tester.pumpAndSettle();
      },
    );

    testWidgets(
      'swapping the external controller transfers listening without leak',
      (tester) async {
        final a = newController();
        final b = newController();
        final aCompleter = Completer<void>();
        final bCompleter = Completer<void>();
        AsyncButton button(AsyncButtonController c, Completer<void> done) =>
            AsyncButton(
              controller: c,
              onPressed: () => done.future,
              builder: textBuilder,
              child: const Text('child'),
            );
        await tester.pumpWidget(pumpHost(button(a, aCompleter)));
        await tester.pumpWidget(pumpHost(button(b, bCompleter)));
        // The widget now listens to b: driving a must not show loading.
        unawaited(a.trigger());
        await tester.pump();
        check(find.byType(CircularProgressIndicator)).findsNone();
        // Driving b does.
        unawaited(b.trigger());
        await tester.pump();
        check(find.byType(CircularProgressIndicator)).findsOne();
        aCompleter.complete();
        bCompleter.complete();
        await tester.pumpAndSettle();
      },
    );
  });

  group('AsyncButton transition builder', () {
    testWidgets('no transition by default — the swap is instant', (
      tester,
    ) async {
      final (:onPressed, :completer) = pendingPress();
      await tester.pumpWidget(
        pumpHost(
          FilledAsyncButton(onPressed: onPressed, child: const Text('go')),
        ),
      );
      await tester.tap(find.byType(FilledButton));
      await tester.pump();
      // No AnimatedSwitcher/AnimatedSize is inserted by the package.
      check(find.byType(AnimatedSwitcher)).findsNone();
      check(find.byType(CircularProgressIndicator)).findsOne();
      completer.complete();
      await tester.pumpAndSettle();
    });

    testWidgets('wraps the keyed state child with the supplied builder', (
      tester,
    ) async {
      final (:onPressed, :completer) = pendingPress();
      final seenLoading = <bool>[];
      await tester.pumpWidget(
        pumpHost(
          FilledAsyncButton(
            onPressed: onPressed,
            transitionBuilder: (context, child, isLoading) {
              seenLoading.add(isLoading);
              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 100),
                child: child,
              );
            },
            child: const Text('go'),
          ),
        ),
      );
      await tester.tap(find.byType(FilledButton));
      await tester.pump();
      check(find.byType(AnimatedSwitcher)).findsOne();
      check(seenLoading).contains(true);
      completer.complete();
      await tester.pumpAndSettle();
    });
  });
}
