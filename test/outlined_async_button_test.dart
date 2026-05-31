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

    testWidgets('.icon spinner tracks the line box, not the raw font size', (
      tester,
    ) async {
      final (:onPressed, :completer) = pendingPress();
      // An explicit `height: 2` makes the label's line box (fontSize * 2)
      // exceed both the raw font size and the default icon size — the same way
      // a real font's rendered line is taller than its fontSize. The default
      // spinner must size to that line box so the button keeps its idle height
      // while loading (the old behaviour sized to the raw fontSize and shrank).
      final theme = ThemeData(
        extensions: const [AsyncButtonTheme.empty],
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            textStyle: const TextStyle(fontSize: 15, height: 2),
          ),
        ),
      );
      await tester.pumpWidget(
        pumpHost(
          OutlinedAsyncButton.icon(
            onPressed: onPressed,
            icon: const Icon(Icons.delete),
            label: const Text('Delete account'),
          ),
          theme: theme,
        ),
      );
      await tapIntoLoading(tester, find.byType(OutlinedButton));
      final lineBox = spinnerTextLineBox(tester); // 15 * 2 = 30
      check(lineBox).isGreaterThan(spinnerFontSize(tester)!); // 30 > 15
      check(loadingSpinnerSize(tester)).equals(lineBox);
      completer.complete();
      await tester.pumpAndSettle();
    });
  });
}
