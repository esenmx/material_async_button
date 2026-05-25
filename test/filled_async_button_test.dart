import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_async_button/material_async_button.dart';

Widget _wrap(Widget child) => MaterialApp(
  home: Scaffold(body: Center(child: child)),
);

void main() {
  group('FilledAsyncButton', () {
    testWidgets('renders FilledButton', (tester) async {
      await tester.pumpWidget(
        _wrap(FilledAsyncButton(onPressed: () async {}, child: const Text('go'))),
      );
      expect(find.byType(FilledButton), findsOneWidget);
    });

    testWidgets('FilledAsyncButton.tonal renders FilledButton in tonal style', (tester) async {
      await tester.pumpWidget(
        _wrap(FilledAsyncButton.tonal(onPressed: () async {}, child: const Text('go'))),
      );
      expect(find.byType(FilledButton), findsOneWidget);
    });

    testWidgets('FilledAsyncButton.icon swaps label during loading', (tester) async {
      final completer = Completer<void>();
      await tester.pumpWidget(
        _wrap(
          FilledAsyncButton.icon(
            onPressed: () => completer.future,
            icon: const Icon(Icons.save),
            label: const Text('save'),
          ),
        ),
      );
      await tester.tap(find.byType(FilledButton));
      await tester.pump();
      expect(find.byIcon(Icons.save), findsOneWidget);
      expect(find.text('save'), findsNothing);
      completer.complete();
      await tester.pumpAndSettle();
    });

    testWidgets('FilledAsyncButton.tonalIcon renders', (tester) async {
      await tester.pumpWidget(
        _wrap(
          FilledAsyncButton.tonalIcon(
            onPressed: () async {},
            icon: const Icon(Icons.save),
            label: const Text('save'),
          ),
        ),
      );
      expect(find.byType(FilledButton), findsOneWidget);
    });
  });
}
