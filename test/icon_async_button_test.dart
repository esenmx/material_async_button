import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_async_button/material_async_button.dart';

import '_helpers.dart';

void main() {
  group('IconAsyncButton', () {
    testWidgets('renders IconButton with the icon', (tester) async {
      await tester.pumpWidget(
        pumpHost(
          IconAsyncButton(
            onPressed: () async {},
            icon: const Icon(Icons.refresh),
          ),
        ),
      );
      check(find.byIcon(Icons.refresh)).findsOne();
      check(find.byType(IconButton)).findsOne();
    });

    testWidgets('filled, filledTonal, outlined variants all render', (
      tester,
    ) async {
      final ctors = <Widget Function()>[
        () => IconAsyncButton.filled(
          onPressed: () async {},
          icon: const Icon(Icons.add),
        ),
        () => IconAsyncButton.filledTonal(
          onPressed: () async {},
          icon: const Icon(Icons.add),
        ),
        () => IconAsyncButton.outlined(
          onPressed: () async {},
          icon: const Icon(Icons.add),
        ),
      ];
      for (final ctor in ctors) {
        await tester.pumpWidget(pumpHost(ctor()));
        check(find.byType(IconButton)).findsOne();
      }
    });

    testWidgets('swaps icon for loading widget during press', (tester) async {
      final (:onPressed, :completer) = pendingPress();
      await tester.pumpWidget(
        pumpHost(
          IconAsyncButton(
            onPressed: onPressed,
            icon: const Icon(Icons.refresh),
          ),
        ),
      );
      await tester.tap(find.byType(IconButton));
      await tester.pump();
      check(find.byType(CircularProgressIndicator)).findsOne();
      completer.complete();
      await tester.pumpAndSettle();
      check(find.byIcon(Icons.refresh)).findsOne();
    });
  });
}
