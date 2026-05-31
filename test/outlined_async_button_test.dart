import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_async_button/material_async_button.dart';

import '_helpers.dart';

void main() {
  group('OutlinedAsyncButton', () {
    testWidgets('renders OutlinedButton', (tester) async {
      await tester.pumpWidget(
        pumpHost(
          OutlinedAsyncButton(onPressed: () async {}, child: const Text('go')),
        ),
      );
      check(find.byType(OutlinedButton)).findsOne();
    });

    testWidgets('.icon renders with icon + label', (tester) async {
      await tester.pumpWidget(
        pumpHost(
          OutlinedAsyncButton.icon(
            onPressed: () async {},
            icon: const Icon(Icons.share),
            label: const Text('share'),
          ),
        ),
      );
      check(find.byType(OutlinedButton)).findsOne();
      check(find.byIcon(Icons.share)).findsOne();
      check(find.text('share')).findsOne();
    });

    testWidgets('loading spinner honours style.foregroundColor', (
      tester,
    ) async {
      final (:onPressed, :completer) = pendingPress();
      await tester.pumpWidget(
        pumpHost(
          OutlinedAsyncButton(
            onPressed: onPressed,
            style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('delete'),
          ),
        ),
      );
      await tapIntoLoading(tester, find.byType(OutlinedButton));
      check(spinnerColor(tester)).equals(Colors.red);
      check(spinnerIconThemeColor(tester)).equals(Colors.red);
      completer.complete();
      await tester.pumpAndSettle();
    });
  });
}
