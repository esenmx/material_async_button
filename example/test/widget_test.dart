import 'package:example/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_async_button/material_async_button.dart';

void main() {
  testWidgets('example app builds and shows the Material wrappers section',
      (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
    expect(find.text('Material wrappers'), findsOneWidget);
    expect(find.byType(ElevatedAsyncButton), findsWidgets);
    expect(find.byType(FilledAsyncButton), findsWidgets);
  });
}
