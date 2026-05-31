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
          FilledAsyncButton(onPressed: () async {}, child: const Text('go')),
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

    testWidgets('.icon shows the spinner while loading, restores after', (
      tester,
    ) async {
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
      // Loading drops the icon and shows the spinner alone.
      check(find.byType(CircularProgressIndicator)).findsOne();
      check(find.byIcon(Icons.save)).findsNone();
      completer.complete();
      await tester.pumpAndSettle();
      // Label and icon return once the work completes.
      check(find.text('save')).findsOne();
      check(find.byIcon(Icons.save)).findsOne();
    });
  });

  group('FilledAsyncButton loading foreground', () {
    testWidgets('spinner uses onPrimary, not the disabled grey', (
      tester,
    ) async {
      final (:onPressed, :completer) = pendingPress();
      final theme = ThemeData(extensions: const [AsyncButtonTheme.empty]);
      await tester.pumpWidget(
        pumpHost(
          FilledAsyncButton(onPressed: onPressed, child: const Text('go')),
          theme: theme,
        ),
      );
      await tester.tap(find.byType(FilledButton));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));
      check(spinnerColor(tester)).equals(theme.colorScheme.onPrimary);
      completer.complete();
      await tester.pumpAndSettle();
    });

    testWidgets('.tonal spinner uses onSecondaryContainer', (tester) async {
      final (:onPressed, :completer) = pendingPress();
      final theme = ThemeData(extensions: const [AsyncButtonTheme.empty]);
      await tester.pumpWidget(
        pumpHost(
          FilledAsyncButton.tonal(
            onPressed: onPressed,
            child: const Text('go'),
          ),
          theme: theme,
        ),
      );
      await tester.tap(find.byType(FilledButton));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));
      check(
        spinnerColor(tester),
      ).equals(theme.colorScheme.onSecondaryContainer);
      completer.complete();
      await tester.pumpAndSettle();
    });

    testWidgets('a custom spinner colour overrides the inherited one', (
      tester,
    ) async {
      final (:onPressed, :completer) = pendingPress();
      await tester.pumpWidget(
        pumpHost(
          FilledAsyncButton(
            onPressed: onPressed,
            loadingBuilder: (_) => const AsyncButtonSpinner(color: Colors.teal),
            child: const Text('go'),
          ),
        ),
      );
      await tester.tap(find.byType(FilledButton));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));
      check(spinnerColor(tester)).equals(Colors.teal);
      completer.complete();
      await tester.pumpAndSettle();
    });
  });
}
