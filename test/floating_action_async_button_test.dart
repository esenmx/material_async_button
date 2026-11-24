import 'package:checks/checks.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_async_button/material_async_button.dart';
import 'package:material_ui/material_ui.dart';

import '_helpers.dart';

void main() {
  group('FloatingActionAsyncButton', () {
    testWidgets('renders a FloatingActionButton with the child', (
      tester,
    ) async {
      await tester.pumpWidget(
        pumpHost(
          FloatingActionAsyncButton(
            onPressed: () async {},
            child: const Text('go'),
          ),
        ),
      );
      check(find.byType(FloatingActionButton)).findsOne;
      check(find.text('go')).findsOne;
      // Pins the .standard -> FloatingActionButton.new mapping: the standard
      // FAB is 56x56 (small pads to 48x48, large is 96x96).
      check(tester.getSize(find.byType(FloatingActionButton)))
          .equals(const Size(56, 56));
    });

    testWidgets('mini is forwarded to the FloatingActionButton', (
      tester,
    ) async {
      await tester.pumpWidget(
        pumpHost(
          FloatingActionAsyncButton(
            mini: true,
            onPressed: () async {},
            child: const Icon(Icons.add),
          ),
        ),
      );
      // A mini FAB is 40x40 inside a 48x48 padded tap target.
      check(tester.getSize(find.byType(FloatingActionButton)))
          .equals(const Size(48, 48));
    });

    testWidgets('a custom heroTag is forwarded for every variant', (
      tester,
    ) async {
      final variants = <Widget>[
        FloatingActionAsyncButton(
          heroTag: 'custom-tag',
          onPressed: () async {},
          child: const Icon(Icons.add),
        ),
        FloatingActionAsyncButton.small(
          heroTag: 'custom-tag',
          onPressed: () async {},
          child: const Icon(Icons.add),
        ),
        FloatingActionAsyncButton.large(
          heroTag: 'custom-tag',
          onPressed: () async {},
          child: const Icon(Icons.add),
        ),
        FloatingActionAsyncButton.extended(
          heroTag: 'custom-tag',
          onPressed: () async {},
          label: const Text('go'),
        ),
      ];
      for (final fab in variants) {
        await tester.pumpWidget(pumpHost(fab));
        check(
          tester
              .widget<FloatingActionButton>(find.byType(FloatingActionButton))
              .heroTag,
          because: '$fab',
        ).equals('custom-tag');
      }
    });

    testWidgets('two default-tag FABs collide in the Hero scan on push', (
      tester,
    ) async {
      final navigatorKey = GlobalKey<NavigatorState>();
      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: navigatorKey,
          theme: emptyAsyncButtonTheme,
          home: Scaffold(
            body: Column(
              children: [
                FloatingActionAsyncButton(
                  onPressed: () async {},
                  child: const Icon(Icons.add),
                ),
                FloatingActionAsyncButton(
                  onPressed: () async {},
                  child: const Icon(Icons.remove),
                ),
              ],
            ),
          ),
        ),
      );
      // The duplicate-Hero scan only runs during a route transition — without
      // the push this test would pass vacuously even on correct code. Two
      // default-tag FABs sharing the const default tag must trip it, proving
      // the default heroTag actually reaches the Hero wrapper.
      tester
          .state<NavigatorState>(find.byKey(navigatorKey))
          .push(MaterialPageRoute<void>(builder: (_) => const Scaffold()));
      await tester.pump();
      await tester.pump();
      check(tester.takeException()).isA<FlutterError>();
    });

    testWidgets('small and large variants render FloatingActionButton', (
      tester,
    ) async {
      await tester.pumpWidget(
        pumpHost(
          Column(
            children: [
              FloatingActionAsyncButton.small(
                onPressed: () async {},
                child: const Icon(Icons.add),
              ),
              FloatingActionAsyncButton.large(
                onPressed: () async {},
                child: const Icon(Icons.add),
              ),
            ],
          ),
        ),
      );
      final fabs = find.byType(FloatingActionButton);
      check(fabs.evaluate().length).equals(2);
      // Pins the variant -> constructor mapping. `.small` is 40x40 inside a
      // 48x48 padded tap target (ThemeData default on the test platform).
      check(tester.getSize(fabs.first)).equals(const Size(48, 48));
      check(tester.getSize(fabs.last)).equals(const Size(96, 96));
    });

    testWidgets(
      'loading spinner uses onPrimaryContainer, not the disabled grey',
      (tester) async {
        final (:onPressed, :completer) = pendingPress();
        final theme = emptyAsyncButtonTheme;
        await tester.pumpWidget(
          pumpHost(
            FloatingActionAsyncButton(
              onPressed: onPressed,
              child: const Text('go'),
            ),
            theme: theme,
          ),
        );
        await tapIntoLoading(tester, find.byType(FloatingActionButton));
        final expected = theme.colorScheme.onPrimaryContainer;
        check(spinnerColor(tester)).equals(expected);
        completer.complete();
        await tester.pumpAndSettle();
      },
    );
  });

  group('FloatingActionAsyncButton.extended', () {
    testWidgets('spinner replaces icon and label, both restored after', (
      tester,
    ) async {
      final (:onPressed, :completer) = pendingPress();
      await tester.pumpWidget(
        pumpHost(
          FloatingActionAsyncButton.extended(
            onPressed: onPressed,
            icon: const Icon(Icons.send),
            label: const Text('send'),
          ),
        ),
      );
      check(find.byIcon(Icons.send)).findsOne;
      check(find.text('send')).findsOne;
      await tapIntoLoading(tester, find.byType(FloatingActionButton));
      // Loading drops the icon and shows the spinner alone.
      check(find.byType(CircularProgressIndicator)).findsOne;
      check(find.byIcon(Icons.send)).findsNone;
      completer.complete();
      await tester.pumpAndSettle();
      // Icon and label both return once the work completes.
      check(find.byIcon(Icons.send)).findsOne;
      check(find.text('send')).findsOne;
    });

    testWidgets('loading spinner is sized to the taller of icon and line box '
        'when IconTheme is present', (tester) async {
      final (:onPressed, :completer) = pendingPress();
      await tester.pumpWidget(
        pumpHost(
          IconTheme(
            data: const IconThemeData(size: 32),
            child: FloatingActionAsyncButton.extended(
              onPressed: onPressed,
              icon: const Icon(Icons.send),
              label: const Text('send'),
            ),
          ),
        ),
      );
      final lineBox = tester.getSize(find.text('send')).height;
      await tapIntoLoading(tester, find.byType(FloatingActionButton));
      final expected = 32.0 > lineBox ? 32.0 : lineBox;
      check(loadingSpinnerSize(tester)).equals(expected);
      completer.complete();
      await tester.pump();
    });

    testWidgets('collapsed (isExtended: false) shows the spinner', (
      tester,
    ) async {
      final (:onPressed, :completer) = pendingPress();
      await tester.pumpWidget(
        pumpHost(
          FloatingActionAsyncButton.extended(
            onPressed: onPressed,
            isExtended: false,
            icon: const Icon(Icons.add),
            label: const Text('Create'),
          ),
        ),
      );
      check(find.byIcon(Icons.add)).findsOne;
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pump();
      check(find.byType(CircularProgressIndicator)).findsOne;
      check(find.byIcon(Icons.add)).findsNone;
      completer.complete();
      await tester.pumpAndSettle();
      check(find.byIcon(Icons.add)).findsOne;
    });

    testWidgets(
      'collapsed (isExtended: false) without icon shows a non-zero-width '
      'spinner',
      (tester) async {
        final (:onPressed, :completer) = pendingPress();
        await tester.pumpWidget(
          pumpHost(
            FloatingActionAsyncButton.extended(
              onPressed: onPressed,
              isExtended: false,
              label: const Text('Create'),
            ),
          ),
        );
        await tester.tap(find.byType(FloatingActionButton));
        await tester.pump();
        check(find.byType(CircularProgressIndicator)).findsOne;
        check(loadingSpinnerSize(tester)).equals(24);
        check(tester.getSize(find.byType(CircularProgressIndicator)).width)
            .isGreaterThan(0);
        completer.complete();
        await tester.pumpAndSettle();
      },
    );
  });

  group('FloatingActionAsyncButton disabled look', () {
    Material fabMaterial(WidgetTester tester) => tester.widget<Material>(
      find
          .descendant(
            of: find.byType(FloatingActionButton),
            matching: find.byType(Material),
          )
          .first,
    );

    final variants =
        <String, Widget Function(AsyncCallback onPressed, bool disable)>{
          'new': (onPressed, disable) => FloatingActionAsyncButton(
            onPressed: onPressed,
            disableWhileLoading: disable,
            child: const Icon(Icons.add),
          ),
          'small': (onPressed, disable) => FloatingActionAsyncButton.small(
            onPressed: onPressed,
            disableWhileLoading: disable,
            child: const Icon(Icons.add),
          ),
          'large': (onPressed, disable) => FloatingActionAsyncButton.large(
            onPressed: onPressed,
            disableWhileLoading: disable,
            child: const Icon(Icons.add),
          ),
          'extended': (onPressed, disable) =>
              FloatingActionAsyncButton.extended(
                onPressed: onPressed,
                disableWhileLoading: disable,
                icon: const Icon(Icons.add),
                label: const Text('go'),
              ),
          'extended collapsed': (onPressed, disable) =>
              FloatingActionAsyncButton.extended(
                onPressed: onPressed,
                disableWhileLoading: disable,
                isExtended: false,
                icon: const Icon(Icons.add),
                label: const Text('go'),
              ),
        };

    for (final MapEntry(key: name, value: build) in variants.entries) {
      testWidgets('.$name greys out while busy', (tester) async {
        final theme = emptyAsyncButtonTheme;
        final scheme = theme.colorScheme;
        final (:onPressed, :completer) = pendingPress();
        await tester.pumpWidget(pumpHost(build(onPressed, true), theme: theme));
        final idle = fabMaterial(tester);
        check(idle.color).equals(scheme.primaryContainer);
        await tapIntoLoading(tester, find.byType(FloatingActionButton));
        final busy = fabMaterial(tester);
        check(busy.color).equals(scheme.onSurface.withAlpha(0x1F));
        check(busy.elevation).equals(0);
        check(spinnerColor(tester)).equals(scheme.onSurface.withAlpha(0x61));
        completer.complete();
        await tester.pumpAndSettle();
        check(fabMaterial(tester).color).equals(idle.color);
        check(fabMaterial(tester).elevation).equals(idle.elevation);
      });
    }

    testWidgets('matches a disabled FilledButton', (tester) async {
      final (:onPressed, :completer) = pendingPress();
      await tester.pumpWidget(
        pumpHost(
          Column(
            mainAxisSize: .min,
            children: [
              FloatingActionAsyncButton(
                onPressed: onPressed,
                disableWhileLoading: true,
                child: const Icon(Icons.add),
              ),
              const FilledButton(onPressed: null, child: Text('off')),
            ],
          ),
        ),
      );
      await tapIntoLoading(tester, find.byType(FloatingActionButton));
      final filled = tester.widget<Material>(
        find.descendant(
          of: find.byType(FilledButton),
          matching: find.byType(Material),
        ),
      );
      check(fabMaterial(tester).color).equals(filled.color);
      check(fabMaterial(tester).elevation).equals(filled.elevation);
      check(spinnerColor(tester)).equals(filled.textStyle?.color);
      completer.complete();
      await tester.pumpAndSettle();
    });

    testWidgets('caller disabledElevation wins', (tester) async {
      final scheme = emptyAsyncButtonTheme.colorScheme;
      final (:onPressed, :completer) = pendingPress();
      await tester.pumpWidget(
        pumpHost(
          FloatingActionAsyncButton(
            onPressed: onPressed,
            disableWhileLoading: true,
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            disabledElevation: 2,
            child: const Icon(Icons.add),
          ),
        ),
      );
      await tapIntoLoading(tester, find.byType(FloatingActionButton));
      check(fabMaterial(tester).color).equals(scheme.onSurface.withAlpha(0x1F));
      check(fabMaterial(tester).elevation).equals(2);
      check(spinnerColor(tester)).equals(scheme.onSurface.withAlpha(0x61));
      completer.complete();
      await tester.pumpAndSettle();
      check(fabMaterial(tester).color).equals(Colors.red);
    });

    testWidgets('theme disabledElevation wins', (tester) async {
      final (:onPressed, :completer) = pendingPress();
      await tester.pumpWidget(
        pumpHost(
          FloatingActionButtonTheme(
            data: const FloatingActionButtonThemeData(disabledElevation: 3),
            child: FloatingActionAsyncButton(
              onPressed: onPressed,
              disableWhileLoading: true,
              child: const Icon(Icons.add),
            ),
          ),
        ),
      );
      await tapIntoLoading(tester, find.byType(FloatingActionButton));
      check(fabMaterial(tester).elevation).equals(3);
      completer.complete();
      await tester.pumpAndSettle();
    });

    testWidgets('off keeps the enabled look', (tester) async {
      final (:onPressed, :completer) = pendingPress();
      await tester.pumpWidget(
        pumpHost(
          FloatingActionAsyncButton(
            onPressed: onPressed,
            child: const Icon(Icons.add),
          ),
        ),
      );
      final idle = fabMaterial(tester);
      await tapIntoLoading(tester, find.byType(FloatingActionButton));
      check(fabMaterial(tester).color).equals(idle.color);
      check(fabMaterial(tester).elevation).equals(idle.elevation);
      completer.complete();
      await tester.pumpAndSettle();
    });

    testWidgets('theme flag greys out while busy', (tester) async {
      final theme = asyncButtonTheme(disableWhileLoading: true);
      final (:onPressed, :completer) = pendingPress();
      await tester.pumpWidget(
        pumpHost(
          FloatingActionAsyncButton(
            onPressed: onPressed,
            child: const Icon(Icons.add),
          ),
          theme: theme,
        ),
      );
      await tapIntoLoading(tester, find.byType(FloatingActionButton));
      check(fabMaterial(tester).color)
          .equals(theme.colorScheme.onSurface.withAlpha(0x1F));
      completer.complete();
      await tester.pumpAndSettle();
    });

    testWidgets('disabling mid-run greys out without the flag', (tester) async {
      final scheme = emptyAsyncButtonTheme.colorScheme;
      final (:onPressed, :completer) = pendingPress();
      Widget fab({required bool enabled}) => FloatingActionAsyncButton(
        onPressed: onPressed,
        enabled: enabled,
        child: const Icon(Icons.add),
      );
      await tester.pumpWidget(pumpHost(fab(enabled: true)));
      await tapIntoLoading(tester, find.byType(FloatingActionButton));
      await tester.pumpWidget(pumpHost(fab(enabled: false)));
      check(fabMaterial(tester).color).equals(scheme.onSurface.withAlpha(0x1F));
      check(spinnerColor(tester)).equals(scheme.onSurface.withAlpha(0x61));
      completer.complete();
      await tester.pumpAndSettle();
    });

    final idleDisabled = <String, Widget>{
      'enabled: false': FloatingActionAsyncButton(
        onPressed: () async {},
        enabled: false,
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
      'onPressed: null': const FloatingActionAsyncButton(
        onPressed: null,
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        child: Icon(Icons.add),
      ),
    };
    for (final MapEntry(key: name, value: fab) in idleDisabled.entries) {
      testWidgets('idle $name greys out', (tester) async {
        final scheme = emptyAsyncButtonTheme.colorScheme;
        await tester.pumpWidget(pumpHost(fab));
        check(fabMaterial(tester).color)
            .equals(scheme.onSurface.withAlpha(0x1F));
        check(fabMaterial(tester).elevation).equals(0);
        check(IconTheme.of(tester.element(find.byIcon(Icons.add))).color)
            .equals(scheme.onSurface.withAlpha(0x61));
      });
    }
  });

  group('AsyncButtonSpinner', () {
    testWidgets('custom strokeWidth flows to CircularProgressIndicator', (
      tester,
    ) async {
      final (:onPressed, :completer) = pendingPress();
      await tester.pumpWidget(
        pumpHost(
          FloatingActionAsyncButton(
            onPressed: onPressed,
            loadingBuilder: (context) =>
                const AsyncButtonSpinner(strokeWidth: 4.5),
            child: const Text('go'),
          ),
        ),
      );
      await tapIntoLoading(tester, find.byType(FloatingActionButton));
      final cpi = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator),
      );
      check(cpi.strokeWidth).equals(4.5);
      completer.complete();
      await tester.pumpAndSettle();
    });

    testWidgets(
      'spinner exposes semanticsLabel for screen readers by default',
      (tester) async {
        final (:onPressed, :completer) = pendingPress();
        await tester.pumpWidget(
          pumpHost(
            FloatingActionAsyncButton(
              onPressed: onPressed,
              child: const Text('go'),
            ),
          ),
        );
        await tapIntoLoading(tester, find.byType(FloatingActionButton));
        final cpi = tester.widget<CircularProgressIndicator>(
          find.byType(CircularProgressIndicator),
        );
        check(cpi.semanticsLabel).equals('Loading');
        completer.complete();
        await tester.pumpAndSettle();
      },
    );

    testWidgets('custom semanticsLabel flows to CircularProgressIndicator', (
      tester,
    ) async {
      final (:onPressed, :completer) = pendingPress();
      await tester.pumpWidget(
        pumpHost(
          FloatingActionAsyncButton(
            onPressed: onPressed,
            loadingBuilder: (context) =>
                const AsyncButtonSpinner(semanticsLabel: 'Submitting'),
            child: const Text('go'),
          ),
        ),
      );
      await tapIntoLoading(tester, find.byType(FloatingActionButton));
      final cpi = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator),
      );
      check(cpi.semanticsLabel).equals('Submitting');
      completer.complete();
      await tester.pumpAndSettle();
    });
  });
}
