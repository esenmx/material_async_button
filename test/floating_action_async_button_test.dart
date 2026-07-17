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
      check(find.byType(FloatingActionButton).evaluate().length).equals(2);
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
        check(
          spinnerColor(tester),
        ).equals(theme.colorScheme.onPrimaryContainer);
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
            loadingBuilder: (context) => const AsyncButtonSpinner(
              strokeWidth: 4.5,
            ),
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
