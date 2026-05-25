import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_async_button/material_async_button.dart';

Widget _wrap(Widget child) =>
    MaterialApp(home: Scaffold(body: Center(child: child)));

void main() {
  group('ElevatedAsyncButton', () {
    testWidgets('renders an ElevatedButton with the child', (tester) async {
      await tester.pumpWidget(_wrap(ElevatedAsyncButton(
        onPressed: () async {},
        child: const Text('go'),
      )));
      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.text('go'), findsOneWidget);
    });

    testWidgets('shows loading then returns to idle', (tester) async {
      final completer = Completer<void>();
      await tester.pumpWidget(_wrap(ElevatedAsyncButton(
        onPressed: () => completer.future,
        child: const Text('go'),
      )));
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      completer.complete();
      await tester.pumpAndSettle();
      expect(find.text('go'), findsOneWidget);
    });

    testWidgets('is disabled when onPressed is null', (tester) async {
      await tester.pumpWidget(_wrap(const ElevatedAsyncButton(
        onPressed: null,
        child: Text('go'),
      )));
      final btn = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(btn.onPressed, isNull);
    });

    testWidgets('is disabled when disabled=true', (tester) async {
      await tester.pumpWidget(_wrap(ElevatedAsyncButton(
        onPressed: () async {},
        disabled: true,
        child: const Text('go'),
      )));
      final btn = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(btn.onPressed, isNull);
    });
  });

  group('ElevatedAsyncButton.icon', () {
    testWidgets('icon stays put while the label animates', (tester) async {
      final completer = Completer<void>();
      await tester.pumpWidget(_wrap(ElevatedAsyncButton.icon(
        onPressed: () => completer.future,
        icon: const Icon(Icons.send),
        label: const Text('send'),
      )));
      // Idle: icon + label.
      expect(find.byIcon(Icons.send), findsOneWidget);
      expect(find.text('send'), findsOneWidget);
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      // Loading: icon stays, label gone, spinner present.
      expect(find.byIcon(Icons.send), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      completer.complete();
      await tester.pumpAndSettle();
      expect(find.text('send'), findsOneWidget);
    });
  });
}
