import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_async_button/material_async_button.dart';
import 'package:material_ui/material_ui.dart';

import '_helpers.dart';

const _label = Text('Save');
const _icon = Icon(Icons.save);

Future<void> _noop() async {}

Widget _background(
  BuildContext context,
  Set<WidgetState> states,
  Widget? child,
) => ColoredBox(color: const Color(0xFF00FF00), child: child);

const _builderStyle = ButtonStyle(backgroundBuilder: _background);

typedef _Pair = ({
  Widget Function(ButtonStyle?, {required Clip clip}) explicit,
  Widget Function(ButtonStyle?) omitted,
  Widget Function(ButtonStyle?) material,
});

final Map<String, _Pair> _constructors = {
  'ElevatedAsyncButton.new': (
    explicit: (style, {required clip}) => ElevatedAsyncButton(
      onPressed: _noop,
      style: style,
      clipBehavior: clip,
      child: _label,
    ),
    omitted: (style) =>
        ElevatedAsyncButton(onPressed: _noop, style: style, child: _label),
    material: (style) =>
        ElevatedButton(onPressed: _noop, style: style, child: _label),
  ),
  'ElevatedAsyncButton.icon': (
    explicit: (style, {required clip}) => ElevatedAsyncButton.icon(
      onPressed: _noop,
      style: style,
      clipBehavior: clip,
      icon: _icon,
      label: _label,
    ),
    omitted: (style) => ElevatedAsyncButton.icon(
      onPressed: _noop,
      style: style,
      icon: _icon,
      label: _label,
    ),
    material: (style) => ElevatedButton.icon(
      onPressed: _noop,
      style: style,
      icon: _icon,
      label: _label,
    ),
  ),
  'FilledAsyncButton.new': (
    explicit: (style, {required clip}) => FilledAsyncButton(
      onPressed: _noop,
      style: style,
      clipBehavior: clip,
      child: _label,
    ),
    omitted: (style) =>
        FilledAsyncButton(onPressed: _noop, style: style, child: _label),
    material: (style) =>
        FilledButton(onPressed: _noop, style: style, child: _label),
  ),
  'FilledAsyncButton.tonal': (
    explicit: (style, {required clip}) => FilledAsyncButton.tonal(
      onPressed: _noop,
      style: style,
      clipBehavior: clip,
      child: _label,
    ),
    omitted: (style) =>
        FilledAsyncButton.tonal(onPressed: _noop, style: style, child: _label),
    material: (style) =>
        FilledButton.tonal(onPressed: _noop, style: style, child: _label),
  ),
  'FilledAsyncButton.icon': (
    explicit: (style, {required clip}) => FilledAsyncButton.icon(
      onPressed: _noop,
      style: style,
      clipBehavior: clip,
      icon: _icon,
      label: _label,
    ),
    omitted: (style) => FilledAsyncButton.icon(
      onPressed: _noop,
      style: style,
      icon: _icon,
      label: _label,
    ),
    material: (style) => FilledButton.icon(
      onPressed: _noop,
      style: style,
      icon: _icon,
      label: _label,
    ),
  ),
  'FilledAsyncButton.tonalIcon': (
    explicit: (style, {required clip}) => FilledAsyncButton.tonalIcon(
      onPressed: _noop,
      style: style,
      clipBehavior: clip,
      icon: _icon,
      label: _label,
    ),
    omitted: (style) => FilledAsyncButton.tonalIcon(
      onPressed: _noop,
      style: style,
      icon: _icon,
      label: _label,
    ),
    material: (style) => FilledButton.tonalIcon(
      onPressed: _noop,
      style: style,
      icon: _icon,
      label: _label,
    ),
  ),
  'OutlinedAsyncButton.new': (
    explicit: (style, {required clip}) => OutlinedAsyncButton(
      onPressed: _noop,
      style: style,
      clipBehavior: clip,
      child: _label,
    ),
    omitted: (style) =>
        OutlinedAsyncButton(onPressed: _noop, style: style, child: _label),
    material: (style) =>
        OutlinedButton(onPressed: _noop, style: style, child: _label),
  ),
  'OutlinedAsyncButton.icon': (
    explicit: (style, {required clip}) => OutlinedAsyncButton.icon(
      onPressed: _noop,
      style: style,
      clipBehavior: clip,
      icon: _icon,
      label: _label,
    ),
    omitted: (style) => OutlinedAsyncButton.icon(
      onPressed: _noop,
      style: style,
      icon: _icon,
      label: _label,
    ),
    material: (style) => OutlinedButton.icon(
      onPressed: _noop,
      style: style,
      icon: _icon,
      label: _label,
    ),
  ),
  'TextAsyncButton.new': (
    explicit: (style, {required clip}) => TextAsyncButton(
      onPressed: _noop,
      style: style,
      clipBehavior: clip,
      child: _label,
    ),
    omitted: (style) =>
        TextAsyncButton(onPressed: _noop, style: style, child: _label),
    material: (style) =>
        TextButton(onPressed: _noop, style: style, child: _label),
  ),
  'TextAsyncButton.icon': (
    explicit: (style, {required clip}) => TextAsyncButton.icon(
      onPressed: _noop,
      style: style,
      clipBehavior: clip,
      icon: _icon,
      label: _label,
    ),
    omitted: (style) => TextAsyncButton.icon(
      onPressed: _noop,
      style: style,
      icon: _icon,
      label: _label,
    ),
    material: (style) => TextButton.icon(
      onPressed: _noop,
      style: style,
      icon: _icon,
      label: _label,
    ),
  ),
};

Future<Clip> _renderedClip(WidgetTester tester, Widget button) async {
  await tester.pumpWidget(pumpHost(button));
  return tester
      .widget<Material>(
        find
            .descendant(
              of: find.bySubtype<ButtonStyleButton>(),
              matching: find.byType(Material),
            )
            .first,
      )
      .clipBehavior;
}

void main() {
  group('clipBehavior matches the Material constructor', () {
    for (final MapEntry(key: name, value: pair) in _constructors.entries) {
      testWidgets('$name with no style', (tester) async {
        final want = await _renderedClip(tester, pair.material(null));
        check(await _renderedClip(tester, pair.omitted(null))).equals(want);
      });

      testWidgets('$name with style.backgroundBuilder', (tester) async {
        final want = await _renderedClip(tester, pair.material(_builderStyle));
        check(await _renderedClip(tester, pair.omitted(_builderStyle)))
            .equals(want);
      });

      testWidgets('$name forwards an explicit value', (tester) async {
        check(await _renderedClip(tester, pair.explicit(null, clip: .hardEdge)))
            .equals(.hardEdge);
      });
    }

    testWidgets('ElevatedAsyncButton.new clips a background builder', (
      tester,
    ) async {
      check(
        await _renderedClip(
          tester,
          const ElevatedAsyncButton(
            onPressed: _noop,
            style: _builderStyle,
            child: _label,
          ),
        ),
      ).equals(.antiAlias);
    });
  });
}
