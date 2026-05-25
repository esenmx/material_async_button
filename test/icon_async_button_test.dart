import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_async_button/material_async_button.dart';

Widget _wrap(Widget child) => MaterialApp(
  home: Scaffold(body: Center(child: child)),
);

void main() {
  group('IconAsyncButton', () {
    testWidgets('renders IconButton with the icon', (tester) async {
      await tester.pumpWidget(
        _wrap(IconAsyncButton(onPressed: () async {}, icon: const Icon(Icons.refresh))),
      );
      expect(find.byIcon(Icons.refresh), findsOneWidget);
      expect(find.byType(IconButton), findsOneWidget);
    });

    testWidgets('filled, filledTonal, outlined variants all render', (tester) async {
      for (final ctor in <Widget Function()>[
        () => IconAsyncButton.filled(onPressed: () async {}, icon: const Icon(Icons.add)),
        () => IconAsyncButton.filledTonal(onPressed: () async {}, icon: const Icon(Icons.add)),
        () => IconAsyncButton.outlined(onPressed: () async {}, icon: const Icon(Icons.add)),
      ]) {
        await tester.pumpWidget(_wrap(ctor()));
        expect(find.byType(IconButton), findsOneWidget);
      }
    });

    testWidgets('swaps icon for loading widget during press', (tester) async {
      final completer = Completer<void>();
      await tester.pumpWidget(
        _wrap(IconAsyncButton(onPressed: () => completer.future, icon: const Icon(Icons.refresh))),
      );
      await tester.tap(find.byType(IconButton));
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      // Icon may animate out via AnimatedSwitcher; allow both possibilities.
      completer.complete();
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });
  });
}
