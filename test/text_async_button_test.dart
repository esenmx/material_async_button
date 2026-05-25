import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_async_button/material_async_button.dart';

Widget _wrap(Widget child) => MaterialApp(
  home: Scaffold(body: Center(child: child)),
);

void main() {
  group('TextAsyncButton', () {
    testWidgets('renders TextButton', (tester) async {
      await tester.pumpWidget(
        _wrap(TextAsyncButton(onPressed: () async {}, child: const Text('go'))),
      );
      expect(find.byType(TextButton), findsOneWidget);
    });

    testWidgets('.icon variant renders with icon + label', (tester) async {
      await tester.pumpWidget(
        _wrap(
          TextAsyncButton.icon(
            onPressed: () async {},
            icon: const Icon(Icons.copy),
            label: const Text('copy'),
          ),
        ),
      );
      expect(find.byType(TextButton), findsOneWidget);
      expect(find.byIcon(Icons.copy), findsOneWidget);
    });

    testWidgets('state.trigger() works for "Done" keyboard pattern', (tester) async {
      var ran = 0;
      await tester.pumpWidget(
        _wrap(TextAsyncButton(onPressed: () async => ran++, child: const Text('go'))),
      );
      final state = tester.state<AsyncButtonBuilderState>(find.byType(AsyncButtonBuilder));
      await state.trigger();
      await tester.pumpAndSettle();
      expect(ran, 1);
    });
  });
}
