import 'package:checks/checks.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_async_button/material_async_button.dart';

import '_helpers.dart';

typedef _Build = Widget Function(AsyncCallback onPressed);
typedef _Host = Widget Function(Widget child, {ThemeData? theme});

const _label = Text('Save');
const _icon = Icon(Icons.save);

final _standard = find.bySubtype<ButtonStyleButton>();
final _iconButton = find.byType(IconButton);
final _fab = find.byType(FloatingActionButton);

/// Every wrapper constructor, keyed by name, with the finder for the Material
/// button it renders. The Material button is measured — never the spinner.
final Map<String, (_Build, Finder)> _cases = {
  'ElevatedAsyncButton.new': (
    (f) => ElevatedAsyncButton(onPressed: f, child: _label),
    _standard,
  ),
  'ElevatedAsyncButton.icon': (
    (f) => ElevatedAsyncButton.icon(onPressed: f, icon: _icon, label: _label),
    _standard,
  ),
  'FilledAsyncButton.new': (
    (f) => FilledAsyncButton(onPressed: f, child: _label),
    _standard,
  ),
  'FilledAsyncButton.tonal': (
    (f) => FilledAsyncButton.tonal(onPressed: f, child: _label),
    _standard,
  ),
  'FilledAsyncButton.icon': (
    (f) => FilledAsyncButton.icon(onPressed: f, icon: _icon, label: _label),
    _standard,
  ),
  'FilledAsyncButton.tonalIcon': (
    (f) =>
        FilledAsyncButton.tonalIcon(onPressed: f, icon: _icon, label: _label),
    _standard,
  ),
  'OutlinedAsyncButton.new': (
    (f) => OutlinedAsyncButton(onPressed: f, child: _label),
    _standard,
  ),
  'OutlinedAsyncButton.icon': (
    (f) => OutlinedAsyncButton.icon(onPressed: f, icon: _icon, label: _label),
    _standard,
  ),
  'TextAsyncButton.new': (
    (f) => TextAsyncButton(onPressed: f, child: _label),
    _standard,
  ),
  'TextAsyncButton.icon': (
    (f) => TextAsyncButton.icon(onPressed: f, icon: _icon, label: _label),
    _standard,
  ),
  'IconAsyncButton.new': (
    (f) => IconAsyncButton(onPressed: f, icon: _icon),
    _iconButton,
  ),
  'IconAsyncButton.filled': (
    (f) => IconAsyncButton.filled(onPressed: f, icon: _icon),
    _iconButton,
  ),
  'IconAsyncButton.filledTonal': (
    (f) => IconAsyncButton.filledTonal(onPressed: f, icon: _icon),
    _iconButton,
  ),
  'IconAsyncButton.outlined': (
    (f) => IconAsyncButton.outlined(onPressed: f, icon: _icon),
    _iconButton,
  ),
  'FloatingActionAsyncButton.new': (
    (f) => FloatingActionAsyncButton(onPressed: f, child: _icon),
    _fab,
  ),
  'FloatingActionAsyncButton.small': (
    (f) => FloatingActionAsyncButton.small(onPressed: f, child: _icon),
    _fab,
  ),
  'FloatingActionAsyncButton.large': (
    (f) => FloatingActionAsyncButton.large(onPressed: f, child: _icon),
    _fab,
  ),
  'FloatingActionAsyncButton.extended': (
    (f) => FloatingActionAsyncButton.extended(
      onPressed: f,
      icon: _icon,
      label: _label,
    ),
    _fab,
  ),
};

final Map<String, _Host> _hosts = {'Center': pumpHost, 'Column': columnHost};

Future<({Size idle, Size loading})> _idleVsLoading(
  WidgetTester tester,
  Widget button,
  Finder finder,
  _Host host, {
  ThemeData? theme,
}) async {
  await tester.pumpWidget(host(button, theme: theme));
  final idle = tester.getSize(finder);
  await tester.tap(finder);
  await tester.pump();
  final loading = tester.getSize(finder);
  return (idle: idle, loading: loading);
}

void main() {
  group('loading keeps the idle height and never grows', () {
    for (final MapEntry(key: host, value: pump) in _hosts.entries) {
      for (final MapEntry(key: name, value: (build, finder))
          in _cases.entries) {
        testWidgets('$name in $host', (tester) async {
          final (:onPressed, :completer) = pendingPress();
          final (:idle, :loading) = await _idleVsLoading(
            tester,
            build(onPressed),
            finder,
            pump,
          );
          completer.complete();
          await tester.pump();
          check(loading.height).equals(idle.height);
          check(loading.width).isLessOrEqual(idle.width);
        });
      }
    }

    testWidgets('IconAsyncButton in a body-level Row keeps its height', (
      tester,
    ) async {
      final (:onPressed, :completer) = pendingPress();
      await tester.pumpWidget(
        MaterialApp(
          theme: emptyAsyncButtonTheme,
          home: Scaffold(
            body: Row(
              children: [
                IconAsyncButton(
                  onPressed: onPressed,
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
          ),
        ),
      );
      final idle = tester.getSize(_iconButton);
      await tester.tap(_iconButton);
      await tester.pump();
      final loading = tester.getSize(_iconButton);
      completer.complete();
      await tester.pump();
      check(loading.height).equals(idle.height);
    });
  });
}
