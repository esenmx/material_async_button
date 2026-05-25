import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_async_button/material_async_button.dart';

Widget _wrap(Widget child) =>
    MaterialApp(home: Scaffold(body: Center(child: child)));

void main() {
  group('OutlinedAsyncButton', () {
    testWidgets('renders OutlinedButton', (tester) async {
      await tester.pumpWidget(_wrap(OutlinedAsyncButton(
        onPressed: () async {},
        child: const Text('go'),
      )));
      expect(find.byType(OutlinedButton), findsOneWidget);
    });

    testWidgets('.icon variant renders with icon + label', (tester) async {
      await tester.pumpWidget(_wrap(OutlinedAsyncButton.icon(
        onPressed: () async {},
        icon: const Icon(Icons.share),
        label: const Text('share'),
      )));
      expect(find.byType(OutlinedButton), findsOneWidget);
      expect(find.byIcon(Icons.share), findsOneWidget);
      expect(find.text('share'), findsOneWidget);
    });

    testWidgets('cycles through loading', (tester) async {
      final completer = Completer<void>();
      await tester.pumpWidget(_wrap(OutlinedAsyncButton(
        onPressed: () => completer.future,
        child: const Text('go'),
      )));
      await tester.tap(find.byType(OutlinedButton));
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      completer.complete();
      await tester.pumpAndSettle();
    });
  });
}
