import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_async_button/material_async_button.dart';

import '_helpers.dart';

void main() {
  group('TextAsyncButton', () {
    testWidgets('renders TextButton', (tester) async {
      await tester.pumpWidget(
        pumpHost(
          TextAsyncButton(onPressed: () async {}, child: const Text('go')),
        ),
      );
      check(find.byType(TextButton)).findsOne();
    });

    testWidgets('.icon renders with icon + label', (tester) async {
      await tester.pumpWidget(
        pumpHost(
          TextAsyncButton.icon(
            onPressed: () async {},
            icon: const Icon(Icons.copy),
            label: const Text('copy'),
          ),
        ),
      );
      check(find.byType(TextButton)).findsOne();
      check(find.byIcon(Icons.copy)).findsOne();
      check(find.text('copy')).findsOne();
    });

    testWidgets('plain loading spinner tracks the label line box', (
      tester,
    ) async {
      final (:onPressed, :completer) = pendingPress();
      await tester.pumpWidget(
        pumpHost(
          TextAsyncButton(onPressed: onPressed, child: const Text('go')),
        ),
      );
      await tapIntoLoading(tester, find.byType(TextButton));
      // The spinner fills the label's line box, so a text button keeps its idle
      // height while loading. (In the test font the line box equals the font
      // size; the line-box basis is exercised explicitly in the OutlinedButton
      // regression test, where an explicit `height` makes them differ.)
      check(loadingSpinnerSize(tester)).equals(spinnerTextLineBox(tester));
      completer.complete();
      await tester.pump();
    });
  });
}
