import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_async_button/material_async_button.dart';

import '_helpers.dart';

void main() {
  group('TextAsyncButton', () {
    testWidgets('renders TextButton', (tester) async {
      await tester.pumpWidget(
        pumpHost(
          TextAsyncButton(
            onPressed: () async {},
            child: const Text('go'),
          ),
        ),
      );
      check(find.byType(TextButton)).findsOne();
    });

    testWidgets('.icon renders with icon + label', (tester) async {
      await tester.pumpWidget(
        pumpHost(
          TextAsyncButton.icon(
            onPressed: () async {},
            icon: const Icon(Icons.copy),
            label: const Text('copy'),
          ),
        ),
      );
      check(find.byType(TextButton)).findsOne();
      check(find.byIcon(Icons.copy)).findsOne();
    });

    testWidgets('controller.trigger() works for "Done" keyboard pattern', (
      tester,
    ) async {
      final controller = AsyncButtonController();
      addTearDown(controller.dispose);
      var ran = 0;
      await tester.pumpWidget(
        pumpHost(
          TextAsyncButton(
            controller: controller,
            onPressed: () async => ran++,
            child: const Text('go'),
          ),
        ),
      );
      await controller.trigger();
      await tester.pumpAndSettle();
      check(ran).equals(1);
    });
  });
}
