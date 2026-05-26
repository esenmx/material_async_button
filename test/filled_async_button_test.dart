import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_async_button/material_async_button.dart';

import '_helpers.dart';

void main() {
  group('FilledAsyncButton', () {
    testWidgets('renders FilledButton', (tester) async {
      await tester.pumpWidget(
        pumpHost(
          FilledAsyncButton(
            onPressed: () async {},
            child: const Text('go'),
          ),
        ),
      );
      check(find.byType(FilledButton)).findsOne();
    });

    testWidgets('.tonal renders FilledButton in tonal style', (tester) async {
      await tester.pumpWidget(
        pumpHost(
          FilledAsyncButton.tonal(
            onPressed: () async {},
            child: const Text('go'),
          ),
        ),
      );
      check(find.byType(FilledButton)).findsOne();
    });

    testWidgets('.icon swaps label during loading', (tester) async {
      final (:onPressed, :completer) = pendingPress();
      await tester.pumpWidget(
        pumpHost(
          FilledAsyncButton.icon(
            onPressed: onPressed,
            icon: const Icon(Icons.save),
            label: const Text('save'),
          ),
        ),
      );
      await tester.tap(find.byType(FilledButton));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));
      check(find.byIcon(Icons.save)).findsOne();
      check(find.text('save')).findsNone();
      check(find.byType(CircularProgressIndicator)).findsOne();
      completer.complete();
      await tester.pumpAndSettle();
    });

    testWidgets('.tonalIcon renders', (tester) async {
      await tester.pumpWidget(
        pumpHost(
          FilledAsyncButton.tonalIcon(
            onPressed: () async {},
            icon: const Icon(Icons.save),
            label: const Text('save'),
          ),
        ),
      );
      check(find.byType(FilledButton)).findsOne();
    });
  });
}
