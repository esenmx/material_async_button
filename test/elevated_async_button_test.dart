import 'dart:async';

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
          ElevatedAsyncButton(onPressed: () async {}, child: const Text('go')),
        ),
      );
      check(find.byType(ElevatedButton)).findsOne();
      check(find.text('go')).findsOne();
    });

    testWidgets('loading spinner uses primary, not the disabled grey', (
      tester,
    ) async {
      final (:onPressed, :completer) = pendingPress();
      final theme = emptyAsyncButtonTheme;
      await tester.pumpWidget(
        pumpHost(
          ElevatedAsyncButton(onPressed: onPressed, child: const Text('go')),
          theme: theme,
        ),
      );
      await tapIntoLoading(tester, find.byType(ElevatedButton));
      check(spinnerColor(tester)).equals(theme.colorScheme.primary);
      completer.complete();
      await tester.pumpAndSettle();
    });

    testWidgets('enabled: false disables the underlying button', (
      tester,
    ) async {
      await tester.pumpWidget(
        pumpHost(
          ElevatedAsyncButton(
            enabled: false,
            onPressed: () async {},
            child: const Text('go'),
          ),
        ),
      );
      // The wrapper must forward `enabled` into AsyncButton; if it does not,
      // the underlying button stays tappable with a live onPressed.
      check(
        tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
      ).isNull();
    });

    testWidgets('an external controller drives the loading state', (
      tester,
    ) async {
      final controller = newController();
      final (:onPressed, :completer) = pendingPress();
      await tester.pumpWidget(
        pumpHost(
          ElevatedAsyncButton(
            controller: controller,
            onPressed: onPressed,
            child: const Text('go'),
          ),
        ),
      );
      check(find.byType(CircularProgressIndicator)).findsNone();
      // Trigger from outside the widget: only works if the wrapper forwarded
      // the external controller into AsyncButton (which attaches onPressed).
      unawaited(controller.trigger());
      await tester.pump();
      check(controller).isLoading();
      check(find.byType(CircularProgressIndicator)).findsOne();
      completer.complete();
      await tester.pumpAndSettle();
      check(find.byType(CircularProgressIndicator)).findsNone();
    });

    testWidgets('onLongPress is gated off while loading', (tester) async {
      final (:onPressed, :completer) = pendingPress();
      await tester.pumpWidget(
        pumpHost(
          ElevatedAsyncButton(
            onPressed: onPressed,
            onLongPress: () {},
            child: const Text('go'),
          ),
        ),
      );
      // Idle: long-press is wired.
      check(
        tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onLongPress,
      ).isNotNull();

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      // Loading: the button looks enabled, but long-press is gated off.
      check(
        tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onLongPress,
      ).isNull();

      completer.complete();
      await tester.pumpAndSettle();
    });
  });

  group('ElevatedAsyncButton.icon', () {
    testWidgets('spinner replaces icon and label, both restored after', (
      tester,
    ) async {
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
      await tapIntoLoading(tester, find.byType(ElevatedButton));
      // Loading drops the icon and shows the spinner alone.
      check(find.byType(CircularProgressIndicator)).findsOne();
      check(find.byIcon(Icons.send)).findsNone();
      completer.complete();
      await tester.pumpAndSettle();
      // Icon and label both return once the work completes.
      check(find.byIcon(Icons.send)).findsOne();
      check(find.text('send')).findsOne();
    });

    testWidgets('loading spinner is sized to the taller of icon and line box', (
      tester,
    ) async {
      final (:onPressed, :completer) = pendingPress();
      await tester.pumpWidget(
        pumpHost(
          ElevatedAsyncButton.icon(
            onPressed: onPressed,
            // Push the resolved icon size above the ~20px label line box so
            // the icon dominates the row. Must go through the style: an
            // ambient IconTheme would be overridden by ButtonStyleButton's
            // resolved iconSize.
            style: ElevatedButton.styleFrom(iconSize: 32),
            icon: const Icon(Icons.send),
            label: const Text('send'),
          ),
        ),
      );
      await tapIntoLoading(tester, find.byType(ElevatedButton));
      final iconSize = spinnerIconThemeSize(tester);
      final fontSize = spinnerFontSize(tester);
      final lineBox = spinnerTextLineBox(tester);
      check(iconSize).equals(32);
      check(fontSize).isNotNull();
      // The .icon row height is max(icon, lineBox); with the icon (32) taller
      // than the line box (~20), the spinner must take the icon's size — a
      // line-box-sized spinner is the old, shrinking behaviour.
      check(iconSize!).isGreaterThan(lineBox);
      check(loadingSpinnerSize(tester)).equals(iconSize);
      check(loadingSpinnerSize(tester)!).isGreaterThan(fontSize!);
      completer.complete();
      await tester.pump();
    });
  });
}
