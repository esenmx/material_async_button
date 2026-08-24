import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_async_button/material_async_button.dart';

import '_helpers.dart';

void main() {
  group('FloatingActionAsyncButton', () {
    testWidgets('renders a FloatingActionButton with the child', (
      tester,
    ) async {
      await tester.pumpWidget(
        pumpHost(
          FloatingActionAsyncButton(
            onPressed: () async {},
            child: const Text('go'),
          ),
        ),
      );
      check(find.byType(FloatingActionButton)).findsOne();
      check(find.text('go')).findsOne();
      // Pins the .standard -> FloatingActionButton.new mapping: the standard
      // FAB is 56x56 (small pads to 48x48, large is 96x96).
      check(
        tester.getSize(find.byType(FloatingActionButton)),
      ).equals(const Size(56, 56));
    });

    testWidgets('mini is forwarded to the FloatingActionButton', (
      tester,
    ) async {
      await tester.pumpWidget(
        pumpHost(
          FloatingActionAsyncButton(
            mini: true,
            onPressed: () async {},
            child: const Icon(Icons.add),
          ),
        ),
      );
      // A mini FAB is 40x40 inside a 48x48 padded tap target.
      check(
        tester.getSize(find.byType(FloatingActionButton)),
      ).equals(const Size(48, 48));
    });

    testWidgets('a custom heroTag is forwarded for every variant', (
      tester,
    ) async {
      final variants = <Widget>[
        FloatingActionAsyncButton(
          heroTag: 'custom-tag',
          onPressed: () async {},
          child: const Icon(Icons.add),
        ),
        FloatingActionAsyncButton.small(
          heroTag: 'custom-tag',
          onPressed: () async {},
          child: const Icon(Icons.add),
        ),
        FloatingActionAsyncButton.large(
          heroTag: 'custom-tag',
          onPressed: () async {},
          child: const Icon(Icons.add),
        ),
        FloatingActionAsyncButton.extended(
          heroTag: 'custom-tag',
          onPressed: () async {},
          label: const Text('go'),
        ),
      ];
      for (final fab in variants) {
        await tester.pumpWidget(pumpHost(fab));
        check(
          tester
              .widget<FloatingActionButton>(find.byType(FloatingActionButton))
              .heroTag,
          because: '$fab',
        ).equals('custom-tag');
      }
    });

    testWidgets('two default-tag FABs collide in the Hero scan on push', (
      tester,
    ) async {
      final navigatorKey = GlobalKey<NavigatorState>();
      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: navigatorKey,
          theme: emptyAsyncButtonTheme,
          home: Scaffold(
            body: Column(
              children: [
                FloatingActionAsyncButton(
                  onPressed: () async {},
                  child: const Icon(Icons.add),
                ),
                FloatingActionAsyncButton(
                  onPressed: () async {},
                  child: const Icon(Icons.remove),
                ),
              ],
            ),
          ),
        ),
      );
      // The duplicate-Hero scan only runs during a route transition — without
      // the push this test would pass vacuously even on correct code. Two
      // default-tag FABs sharing the const default tag must trip it, proving
      // the default heroTag actually reaches the Hero wrapper.
      // .ignore(), not unawaited(): pre-3.47 analyzers flag the bare future
      // (unawaited_futures) while 3.47+ flags unawaited() on the
      // @awaitNotRequired push (unnecessary_unawaited).
      navigatorKey.currentState!
          .push(MaterialPageRoute<void>(builder: (_) => const Scaffold()))
          .ignore();
      await tester.pump();
      await tester.pump();
      check(tester.takeException()).isA<FlutterError>();
    });

    testWidgets('small and large variants render FloatingActionButton', (
      tester,
    ) async {
      await tester.pumpWidget(
        pumpHost(
          Column(
            children: [
              FloatingActionAsyncButton.small(
                onPressed: () async {},
                child: const Icon(Icons.add),
              ),
              FloatingActionAsyncButton.large(
                onPressed: () async {},
                child: const Icon(Icons.add),
              ),
            ],
          ),
        ),
      );
      final fabs = find.byType(FloatingActionButton);
      check(fabs.evaluate().length).equals(2);
      // Pins the variant -> constructor mapping. `.small` is 40x40 inside a
      // 48x48 padded tap target (ThemeData default on the test platform).
      check(tester.getSize(fabs.first)).equals(const Size(48, 48));
      check(tester.getSize(fabs.last)).equals(const Size(96, 96));
    });

    testWidgets(
      'loading spinner uses onPrimaryContainer, not the disabled grey',
      (tester) async {
        final (:onPressed, :completer) = pendingPress();
        final theme = emptyAsyncButtonTheme;
        await tester.pumpWidget(
          pumpHost(
            FloatingActionAsyncButton(
              onPressed: onPressed,
              child: const Text('go'),
            ),
            theme: theme,
          ),
        );
        await tapIntoLoading(tester, find.byType(FloatingActionButton));
        final expected = theme.colorScheme.onPrimaryContainer;
        check(spinnerColor(tester)).equals(expected);
        completer.complete();
        await tester.pumpAndSettle();
      },
    );
  });

  group('FloatingActionAsyncButton.extended', () {
    testWidgets('spinner replaces icon and label, both restored after', (
      tester,
    ) async {
      final (:onPressed, :completer) = pendingPress();
      await tester.pumpWidget(
        pumpHost(
          FloatingActionAsyncButton.extended(
            onPressed: onPressed,
            icon: const Icon(Icons.send),
            label: const Text('send'),
          ),
        ),
      );
      check(find.byIcon(Icons.send)).findsOne();
      check(find.text('send')).findsOne();
      await tapIntoLoading(tester, find.byType(FloatingActionButton));
      // Loading drops the icon and shows the spinner alone.
      check(find.byType(CircularProgressIndicator)).findsOne();
      check(find.byIcon(Icons.send)).findsNone();
      completer.complete();
      await tester.pumpAndSettle();
      // Icon and label both return once the work completes.
      check(find.byIcon(Icons.send)).findsOne();
      check(find.text('send')).findsOne();
    });

    testWidgets('loading spinner is sized to the taller of icon and line box '
        'when IconTheme is present', (tester) async {
      final (:onPressed, :completer) = pendingPress();
      await tester.pumpWidget(
        pumpHost(
          IconTheme(
            data: const IconThemeData(size: 32),
            child: FloatingActionAsyncButton.extended(
              onPressed: onPressed,
              icon: const Icon(Icons.send),
              label: const Text('send'),
            ),
          ),
        ),
      );
      await tapIntoLoading(tester, find.byType(FloatingActionButton));
      final lineBox = spinnerTextLineBox(tester);
      final expected = 32.0 > lineBox ? 32.0 : lineBox;
      check(loadingSpinnerSize(tester)).equals(expected);
      completer.complete();
      await tester.pump();
    });
  });

  group('AsyncButtonSpinner', () {
    testWidgets('custom strokeWidth flows to CircularProgressIndicator', (
      tester,
    ) async {
      final (:onPressed, :completer) = pendingPress();
      await tester.pumpWidget(
        pumpHost(
          FloatingActionAsyncButton(
            onPressed: onPressed,
            loadingBuilder: (context) =>
                const AsyncButtonSpinner(strokeWidth: 4.5),
            child: const Text('go'),
          ),
        ),
      );
      await tapIntoLoading(tester, find.byType(FloatingActionButton));
      final cpi = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator),
      );
      check(cpi.strokeWidth).equals(4.5);
      completer.complete();
      await tester.pumpAndSettle();
    });

    testWidgets(
      'spinner exposes semanticsLabel for screen readers by default',
      (tester) async {
        final (:onPressed, :completer) = pendingPress();
        await tester.pumpWidget(
          pumpHost(
            FloatingActionAsyncButton(
              onPressed: onPressed,
              child: const Text('go'),
            ),
          ),
        );
        await tapIntoLoading(tester, find.byType(FloatingActionButton));
        final cpi = tester.widget<CircularProgressIndicator>(
          find.byType(CircularProgressIndicator),
        );
        check(cpi.semanticsLabel).equals('Loading');
        completer.complete();
        await tester.pumpAndSettle();
      },
    );

    testWidgets('custom semanticsLabel flows to CircularProgressIndicator', (
      tester,
    ) async {
      final (:onPressed, :completer) = pendingPress();
      await tester.pumpWidget(
        pumpHost(
          FloatingActionAsyncButton(
            onPressed: onPressed,
            loadingBuilder: (context) =>
                const AsyncButtonSpinner(semanticsLabel: 'Submitting'),
            child: const Text('go'),
          ),
        ),
      );
      await tapIntoLoading(tester, find.byType(FloatingActionButton));
      final cpi = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator),
      );
      check(cpi.semanticsLabel).equals('Submitting');
      completer.complete();
      await tester.pumpAndSettle();
    });
  });
}
