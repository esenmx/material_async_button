import 'package:checks/checks.dart';
import 'package:example/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_async_button/material_async_button.dart';

extension on Subject<Finder> {
  void findsOne() => has((f) => f.evaluate().length, 'matches').equals(1);
  void findsNone() => has((f) => f.evaluate(), 'matches').isEmpty();
  void findsMany([int min = 1]) =>
      has((f) => f.evaluate().length, 'matches').isGreaterOrEqual(min);
}

void main() {
  testWidgets('builds and shows the Material wrappers section', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    check(find.text('Material wrappers')).findsOne();
    check(find.byType(ElevatedAsyncButton)).findsMany();
    check(find.byType(FilledAsyncButton)).findsMany();
  });

  testWidgets('tapping an ElevatedAsyncButton shows the loading spinner', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('ElevatedAsyncButton'));
    await tester.pump();

    check(find.byType(CircularProgressIndicator)).findsOne();

    await tester.pumpAndSettle();
    check(find.byType(CircularProgressIndicator)).findsNone();
  });
}
