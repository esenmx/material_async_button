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
          ElevatedAsyncButton(
            onPressed: () async {},
            child: const Text('go'),
          ),
        ),
      );
      check(find.byType(ElevatedButton)).findsOne();
      check(find.text('go')).findsOne();
    });

    testWidgets('shows loading then returns to idle', (tester) async {
      final (:onPressed, :completer) = pendingPress();
      await tester.pumpWidget(
        pumpHost(
          ElevatedAsyncButton(
            onPressed: onPressed,
            child: const Text('go'),
          ),
        ),
      );
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      check(find.byType(CircularProgressIndicator)).findsOne();
      completer.complete();
      await tester.pumpAndSettle();
      check(find.text('go')).findsOne();
    });

    testWidgets('is disabled when onPressed is null', (tester) async {
      await tester.pumpWidget(
        pumpHost(
          const ElevatedAsyncButton(onPressed: null, child: Text('go')),
        ),
      );
      final btn = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      check(btn.onPressed).isNull();
    });

    testWidgets('is disabled when disabled=true', (tester) async {
      await tester.pumpWidget(
        pumpHost(
          ElevatedAsyncButton(
            onPressed: () async {},
            disabled: true,
            child: const Text('go'),
          ),
        ),
      );
      final btn = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      check(btn.onPressed).isNull();
    });
  });

  group('ElevatedAsyncButton.icon', () {
    testWidgets('icon stays put while the label animates', (tester) async {
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
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      check(find.byIcon(Icons.send)).findsOne();
      check(find.byType(CircularProgressIndicator)).findsOne();
      completer.complete();
      await tester.pumpAndSettle();
      check(find.text('send')).findsOne();
    });
  });
}
