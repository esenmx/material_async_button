import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_async_button/material_async_button.dart';

import '_helpers.dart';

typedef _IconBuild = IconAsyncButton Function(
  Future<void> Function() onPressed,
  WidgetStatesController states,
);

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

    testWidgets('each variant renders its IconButton flavor', (tester) async {
      final colors = emptyAsyncButtonTheme.colorScheme;
      // (button, expected Material background, expects an outline side)
      final cases = <(Widget, Color, bool)>[
        (
          IconAsyncButton(onPressed: () async {}, icon: const Icon(Icons.add)),
          Colors.transparent,
          false,
        ),
        (
          IconAsyncButton.filled(
            onPressed: () async {},
            icon: const Icon(Icons.add),
          ),
          colors.primary,
          false,
        ),
        (
          IconAsyncButton.filledTonal(
            onPressed: () async {},
            icon: const Icon(Icons.add),
          ),
          colors.secondaryContainer,
          false,
        ),
        (
          IconAsyncButton.outlined(
            onPressed: () async {},
            icon: const Icon(Icons.add),
          ),
          Colors.transparent,
          true,
        ),
      ];
      for (final (button, background, outlined) in cases) {
        await tester.pumpWidget(pumpHost(button));
        final material = tester.widget<Material>(
          find.descendant(
            of: find.byType(IconButton),
            matching: find.byType(Material),
          ),
        );
        check(material.color, because: '$button').equals(background);
        final side = (material.shape as OutlinedBorder?)?.side;
        check(
          side != null && side != .none,
          because: '$button',
        ).equals(outlined);
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

    testWidgets('forwards its parameters to the underlying IconButton', (
      tester,
    ) async {
      // Guards the centralized ~20-parameter forwarding block: a dropped
      // forward (e.g. tooltip: null) is invisible to the rendering tests.
      final style = IconButton.styleFrom(backgroundColor: Colors.teal);
      await tester.pumpWidget(
        pumpHost(
          IconAsyncButton(
            onPressed: () async {},
            icon: const Icon(Icons.save),
            tooltip: 'save',
            isSelected: true,
            selectedIcon: const Icon(Icons.check),
            style: style,
          ),
        ),
      );
      final button = tester.widget<IconButton>(find.byType(IconButton));
      check(button.tooltip).equals('save');
      check(button.isSelected).equals(true);
      check(button.selectedIcon).isNotNull();
      check(button.style).identicalTo(style);
    });

    testWidgets('every constructor forwards onHover, onLongPress and '
        'statesController; onLongPress is dropped while loading', (
      tester,
    ) async {
      final hovers = <bool>[];
      final onHover = hovers.add;
      void onLongPress() {}
      final constructors = <String, _IconBuild>{
        'new': (onPressed, states) => IconAsyncButton(
          onPressed: onPressed,
          onHover: onHover,
          onLongPress: onLongPress,
          statesController: states,
          icon: const Icon(Icons.add),
        ),
        'filled': (onPressed, states) => IconAsyncButton.filled(
          onPressed: onPressed,
          onHover: onHover,
          onLongPress: onLongPress,
          statesController: states,
          icon: const Icon(Icons.add),
        ),
        'filledTonal': (onPressed, states) => IconAsyncButton.filledTonal(
          onPressed: onPressed,
          onHover: onHover,
          onLongPress: onLongPress,
          statesController: states,
          icon: const Icon(Icons.add),
        ),
        'outlined': (onPressed, states) => IconAsyncButton.outlined(
          onPressed: onPressed,
          onHover: onHover,
          onLongPress: onLongPress,
          statesController: states,
          icon: const Icon(Icons.add),
        ),
      };
      for (final MapEntry(key: name, value: build) in constructors.entries) {
        final states = WidgetStatesController();
        addTearDown(states.dispose);
        final (:onPressed, :completer) = pendingPress();
        await tester.pumpWidget(
          pumpHost(
            KeyedSubtree(key: ValueKey(name), child: build(onPressed, states)),
          ),
        );
        var button = tester.widget<IconButton>(find.byType(IconButton));
        check(because: name, button.onHover).identicalTo(onHover);
        check(because: name, button.statesController).identicalTo(states);
        check(because: name, button.onLongPress).identicalTo(onLongPress);

        await tester.tap(find.byType(IconButton));
        await tester.pump();
        button = tester.widget<IconButton>(find.byType(IconButton));
        check(because: name, button.onLongPress).isNull();
        completer.complete();
        await tester.pumpAndSettle();
      }
    });

    testWidgets('a selected button shows the spinner, not selectedIcon', (
      tester,
    ) async {
      final (:onPressed, :completer) = pendingPress();
      await tester.pumpWidget(
        pumpHost(
          IconAsyncButton(
            onPressed: onPressed,
            isSelected: true,
            icon: const Icon(Icons.favorite_border),
            selectedIcon: const Icon(Icons.favorite),
          ),
        ),
      );
      check(find.byIcon(Icons.favorite)).findsOne();
      await tester.tap(find.byType(IconButton));
      await tester.pump();
      check(find.byType(CircularProgressIndicator)).findsOne();
      check(find.byIcon(Icons.favorite)).findsNone();
      completer.complete();
      await tester.pumpAndSettle();
      check(find.byIcon(Icons.favorite)).findsOne();
    });
  });

  group('IconAsyncButton loading foreground', () {
    testWidgets('.filled spinner uses onPrimary', (tester) async {
      final (:onPressed, :completer) = pendingPress();
      final theme = emptyAsyncButtonTheme;
      await tester.pumpWidget(
        pumpHost(
          IconAsyncButton.filled(
            onPressed: onPressed,
            icon: const Icon(Icons.add),
          ),
          theme: theme,
        ),
      );
      await tapIntoLoading(tester, find.byType(IconButton));
      check(spinnerColor(tester)).equals(theme.colorScheme.onPrimary);
      completer.complete();
      await tester.pumpAndSettle();
    });

    testWidgets('honours the color property', (tester) async {
      final (:onPressed, :completer) = pendingPress();
      await tester.pumpWidget(
        pumpHost(
          IconAsyncButton(
            onPressed: onPressed,
            color: Colors.purple,
            icon: const Icon(Icons.refresh),
          ),
        ),
      );
      await tapIntoLoading(tester, find.byType(IconButton));
      check(spinnerColor(tester)).equals(Colors.purple);
      completer.complete();
      await tester.pumpAndSettle();
    });
  });

  group('IconAsyncButton loading size', () {
    testWidgets('spinner matches the resolved icon size, not the font size', (
      tester,
    ) async {
      final (:onPressed, :completer) = pendingPress();
      await tester.pumpWidget(
        pumpHost(
          IconAsyncButton(
            onPressed: onPressed,
            icon: const Icon(Icons.refresh),
          ),
        ),
      );
      await tapIntoLoading(tester, find.byType(IconButton));
      final iconSize = spinnerIconThemeSize(tester);
      check(iconSize).isNotNull();
      check(loadingSpinnerSize(tester)).equals(iconSize);
      completer.complete();
      await tester.pump();
    });

    testWidgets('explicit iconSize flows through to the spinner', (
      tester,
    ) async {
      final (:onPressed, :completer) = pendingPress();
      await tester.pumpWidget(
        pumpHost(
          IconAsyncButton(
            onPressed: onPressed,
            iconSize: 40,
            icon: const Icon(Icons.refresh),
          ),
        ),
      );
      await tapIntoLoading(tester, find.byType(IconButton));
      check(loadingSpinnerSize(tester)).equals(40);
      completer.complete();
      await tester.pump();
    });
  });
}
