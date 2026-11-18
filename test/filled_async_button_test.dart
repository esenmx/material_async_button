import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_async_button/material_async_button.dart';
import 'package:material_ui/material_ui.dart';

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
      await tapIntoLoading(tester, find.byType(FilledButton));
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
      final theme = emptyAsyncButtonTheme;
      await tester.pumpWidget(
        pumpHost(
          FilledAsyncButton(onPressed: onPressed, child: const Text('go')),
          theme: theme,
        ),
      );
      await tapIntoLoading(tester, find.byType(FilledButton));
      check(spinnerColor(tester)).equals(theme.colorScheme.onPrimary);
      completer.complete();
      await tester.pumpAndSettle();
    });

    testWidgets('.tonal spinner uses onSecondaryContainer', (tester) async {
      final (:onPressed, :completer) = pendingPress();
      final theme = emptyAsyncButtonTheme;
      await tester.pumpWidget(
        pumpHost(
          FilledAsyncButton.tonal(
            onPressed: onPressed,
            child: const Text('go'),
          ),
          theme: theme,
        ),
      );
      await tapIntoLoading(tester, find.byType(FilledButton));
      final expected = theme.colorScheme.onSecondaryContainer;
      check(spinnerColor(tester)).equals(expected);
      completer.complete();
      await tester.pumpAndSettle();
    });

    testWidgets('.tonalIcon spinner uses onSecondaryContainer', (tester) async {
      final (:onPressed, :completer) = pendingPress();
      final theme = emptyAsyncButtonTheme;
      await tester.pumpWidget(
        pumpHost(
          FilledAsyncButton.tonalIcon(
            onPressed: onPressed,
            icon: const Icon(Icons.save),
            label: const Text('save'),
          ),
          theme: theme,
        ),
      );
      await tapIntoLoading(tester, find.byType(FilledButton));
      // Pins .tonal -> FilledButton.tonalIcon in the icon build: the primary
      // FilledButton.icon would paint the spinner onPrimary instead.
      final expected = theme.colorScheme.onSecondaryContainer;
      check(spinnerColor(tester)).equals(expected);
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
      await tapIntoLoading(tester, find.byType(FilledButton));
      check(spinnerColor(tester)).equals(Colors.teal);
      completer.complete();
      await tester.pumpAndSettle();
    });
  });

  group('FilledAsyncButton disableWhileLoading', () {
    Color? buttonMaterialColor(WidgetTester tester, Finder button) {
      return tester
          .widget<Material>(
            find.descendant(of: button, matching: find.byType(Material)),
          )
          .color;
    }

    testWidgets(
      'theme flag disables the inner FilledButton mid-run, paints the same '
      'colours as FilledButton(onPressed: null) of the same style, and '
      're-enables after',
      (tester) async {
        final (:onPressed, :completer) = pendingPress();
        final style = FilledButton.styleFrom(
          backgroundColor: const Color(0xFF112233),
          foregroundColor: const Color(0xFFEEEEEE),
          disabledBackgroundColor: const Color(0xFF445566),
          disabledForegroundColor: const Color(0xFF99AABB),
        );
        const asyncKey = ValueKey('async');
        const disabledKey = ValueKey('disabled');
        await tester.pumpWidget(
          pumpHost(
            Column(
              mainAxisSize: .min,
              children: [
                FilledAsyncButton(
                  key: asyncKey,
                  onPressed: onPressed,
                  style: style,
                  child: const Text('go'),
                ),
                FilledButton(
                  key: disabledKey,
                  onPressed: null,
                  style: style,
                  child: const Text('ref'),
                ),
              ],
            ),
            theme: asyncButtonTheme(disableWhileLoading: true),
          ),
        );
        final asyncButton = find.descendant(
          of: find.byKey(asyncKey),
          matching: find.byType(FilledButton),
        );
        final disabledButton = find.byKey(disabledKey);

        await tapIntoLoading(tester, asyncButton);
        check(tester.widget<FilledButton>(asyncButton).onPressed).isNull();
        check(buttonMaterialColor(tester, asyncButton))
            .equals(buttonMaterialColor(tester, disabledButton));
        final expectedForeground = tester
            .widget<RichText>(
              find.descendant(
                of: disabledButton,
                matching: find.byType(RichText),
              ),
            )
            .text
            .style
            ?.color;
        check(spinnerColor(tester)).equals(expectedForeground);

        completer.complete();
        await tester.pumpAndSettle();
        check(tester.widget<FilledButton>(asyncButton).onPressed).isNotNull();
        check(buttonMaterialColor(tester, asyncButton))
            .equals(const Color(0xFF112233));
      },
    );

    testWidgets('per-widget false overrides theme true', (tester) async {
      final (:onPressed, :completer) = pendingPress();
      final theme = asyncButtonTheme(disableWhileLoading: true);
      await tester.pumpWidget(
        pumpHost(
          FilledAsyncButton(
            onPressed: onPressed,
            disableWhileLoading: false,
            child: const Text('go'),
          ),
          theme: theme,
        ),
      );
      await tapIntoLoading(tester, find.byType(FilledButton));
      check(tester.widget<FilledButton>(find.byType(FilledButton)).onPressed)
          .isNotNull();
      check(spinnerColor(tester)).equals(theme.colorScheme.onPrimary);
      completer.complete();
      await tester.pumpAndSettle();
    });
  });
}
