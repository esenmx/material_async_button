import 'package:checks/checks.dart';
import 'package:example/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_async_button/material_async_button.dart';
import 'package:material_ui/material_ui.dart';

extension on Subject<Finder> {
  void get findsOne => has('matches', (f) => f.evaluate().length).equals(1);
  void get findsNone => has('matches', (f) => f.evaluate()).isEmpty;
  void findsMany([int min = 1]) =>
      has('matches', (f) => f.evaluate().length).isGreaterOrEqual(min);
}

void main() {
  testWidgets('builds and shows the Material wrappers section', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    check(find.text('Material wrappers')).findsOne;
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

    check(find.byType(CircularProgressIndicator)).findsOne;

    await tester.pumpAndSettle();
    check(find.byType(CircularProgressIndicator)).findsNone;
  });

  testWidgets('failing action returns to idle and shows the error SnackBar', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    final button = find.text('OutlinedAsyncButton (handles failure)');
    await tester.ensureVisible(button);
    await tester.tap(button);
    await tester.pump();
    check(find.byType(CircularProgressIndicator)).findsOne;

    await tester.pumpAndSettle();
    check(find.byType(CircularProgressIndicator)).findsNone;
    check(find.text('Failed: Exception: simulated failure')).findsOne;
  });
}
