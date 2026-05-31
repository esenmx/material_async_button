import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_async_button/material_async_button.dart';

import '_helpers.dart';

void main() {
  group('ElevatedAsyncButton', () {
    testWidgets('renders an ElevatedButton with the child', (tester) async {
      await tester.pumpWidget(
        pumpHost(
          ElevatedAsyncButton(onPressed: () async {}, child: const Text('go')),
        ),
      );
      check(find.byType(ElevatedButton)).findsOne();
      check(find.text('go')).findsOne();
    });

    testWidgets('loading spinner uses primary, not the disabled grey', (
      tester,
    ) async {
      final (:onPressed, :completer) = pendingPress();
      final theme = emptyAsyncButtonTheme;
      await tester.pumpWidget(
        pumpHost(
          ElevatedAsyncButton(onPressed: onPressed, child: const Text('go')),
          theme: theme,
        ),
      );
      await tapIntoLoading(tester, find.byType(ElevatedButton));
      check(spinnerColor(tester)).equals(theme.colorScheme.primary);
      completer.complete();
      await tester.pumpAndSettle();
    });

    testWidgets('onLongPress is gated off while loading', (tester) async {
      final (:onPressed, :completer) = pendingPress();
      await tester.pumpWidget(
        pumpHost(
          ElevatedAsyncButton(
            onPressed: onPressed,
            onLongPress: () {},
            child: const Text('go'),
          ),
        ),
      );
      // Idle: long-press is wired.
      check(
        tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onLongPress,
      ).isNotNull();

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      // Loading: the button looks enabled, but long-press is gated off.
      check(
        tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onLongPress,
      ).isNull();

      completer.complete();
      await tester.pumpAndSettle();
    });
  });

  group('ElevatedAsyncButton.icon', () {
    testWidgets('spinner replaces icon and label, both restored after', (
      tester,
    ) async {
      final (:onPressed, :completer) = pendingPress();
      await tester.pumpWidget(
        pumpHost(
          ElevatedAsyncButton.icon(
            onPressed: onPressed,
            icon: const Icon(Icons.send),
            label: const Text('send'),
          ),
        ),
      );
      check(find.byIcon(Icons.send)).findsOne();
      check(find.text('send')).findsOne();
      await tapIntoLoading(tester, find.byType(ElevatedButton));
      // Loading drops the icon and shows the spinner alone.
      check(find.byType(CircularProgressIndicator)).findsOne();
      check(find.byIcon(Icons.send)).findsNone();
      completer.complete();
      await tester.pumpAndSettle();
      // Icon and label both return once the work completes.
      check(find.byIcon(Icons.send)).findsOne();
      check(find.text('send')).findsOne();
    });
  });
}
