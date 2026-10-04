import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_async_button/material_async_button.dart';

import '_helpers.dart';

void main() {
  Future<void> noop() async {}
  const icon = Icon(Icons.send);
  const label = Text('Send');
  final cases = <String, Widget>{
    'ElevatedAsyncButton.icon': ElevatedAsyncButton.icon(
      enabled: false,
      onPressed: noop,
      icon: icon,
      label: label,
    ),
    'FilledAsyncButton.icon': FilledAsyncButton.icon(
      enabled: false,
      onPressed: noop,
      icon: icon,
      label: label,
    ),
    'FilledAsyncButton.tonalIcon': FilledAsyncButton.tonalIcon(
      enabled: false,
      onPressed: noop,
      icon: icon,
      label: label,
    ),
    'OutlinedAsyncButton.icon': OutlinedAsyncButton.icon(
      enabled: false,
      onPressed: noop,
      icon: icon,
      label: label,
    ),
    'TextAsyncButton.icon': TextAsyncButton.icon(
      enabled: false,
      onPressed: noop,
      icon: icon,
      label: label,
    ),
  };

  for (final MapEntry(key: name, value: button) in cases.entries) {
    testWidgets('$name honours enabled: false', (tester) async {
      await tester.pumpWidget(pumpHost(button));
      check(
        tester
            .widget<ButtonStyleButton>(find.bySubtype<ButtonStyleButton>())
            .enabled,
      ).isFalse();
    });
  }
}
