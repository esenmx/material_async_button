// MAB-B8: _ambientTextLineBox() built a TextPainter for every cache miss and
// never disposed it. TextPainter is leak-tracked (FlutterMemoryAllocations).
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:leak_tracker_flutter_testing/leak_tracker_flutter_testing.dart';
import 'package:material_async_button/material_async_button.dart';

import '../_helpers.dart';

void main() {
  testWidgets(
    'default spinner does not leak TextPainters',
    experimentalLeakTesting: LeakTesting.settings.withTrackedAll(),
    (tester) async {
      debugLineBoxCache.clear();
      final (:onPressed, :completer) = pendingPress();
      await tester.pumpWidget(
        pumpHost(
          ElevatedAsyncButton(
            onPressed: onPressed,
            // Unique style → guaranteed cache miss → new TextPainter.
            style: ElevatedButton.styleFrom(
              textStyle: const TextStyle(fontSize: 17.25),
            ),
            child: const Text('Go'),
          ),
        ),
      );
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      completer.complete();
      await tester.pumpAndSettle();
    },
  );
}
