import 'package:checks/checks.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_async_button/material_async_button.dart';
import 'package:material_ui/material_ui.dart';

import '_helpers.dart';

typedef _Build = Widget Function(AsyncCallback onPressed);
typedef _Host = Widget Function(Widget child, {ThemeData? theme});

const _label = Text('Save');
const _icon = Icon(Icons.save);

final Finder _standard = find.bySubtype<ButtonStyleButton>();
final Finder _iconButton = find.byType(IconButton);
final Finder _fab = find.byType(FloatingActionButton);

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

/// The cases whose idle content is the icon alone — there is no label to hide.
const _iconOnly = {
  'IconAsyncButton.new',
  'IconAsyncButton.filled',
  'IconAsyncButton.filledTonal',
  'IconAsyncButton.outlined',
  'FloatingActionAsyncButton.new',
  'FloatingActionAsyncButton.small',
  'FloatingActionAsyncButton.large',
};

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

/// Every wrapper constructor whose idle row shows an icon beside a label.
final Map<String, _Build> _iconRows = {
  'ElevatedAsyncButton.icon': (f) => ElevatedAsyncButton.icon(
    onPressed: f,
    transitionBuilder: _crossFade,
    icon: _icon,
    label: _label,
  ),
  'FilledAsyncButton.icon': (f) => FilledAsyncButton.icon(
    onPressed: f,
    transitionBuilder: _crossFade,
    icon: _icon,
    label: _label,
  ),
  'FilledAsyncButton.tonalIcon': (f) => FilledAsyncButton.tonalIcon(
    onPressed: f,
    transitionBuilder: _crossFade,
    icon: _icon,
    label: _label,
  ),
  'OutlinedAsyncButton.icon': (f) => OutlinedAsyncButton.icon(
    onPressed: f,
    transitionBuilder: _crossFade,
    icon: _icon,
    label: _label,
  ),
  'TextAsyncButton.icon': (f) => TextAsyncButton.icon(
    onPressed: f,
    transitionBuilder: _crossFade,
    icon: _icon,
    label: _label,
  ),
  'FloatingActionAsyncButton.extended': (f) =>
      FloatingActionAsyncButton.extended(
        onPressed: f,
        transitionBuilder: _crossFade,
        icon: _icon,
        label: _label,
      ),
};

const _fadeTime = Duration(milliseconds: 200);

Widget _crossFade(BuildContext _, Widget child, bool _) => AnimatedSize(
  duration: _fadeTime,
  child: AnimatedSwitcher(duration: _fadeTime, child: child),
);

void main() {
  group('a transitionBuilder animates the swap on icon rows', () {
    for (final MapEntry(key: name, value: build) in _iconRows.entries) {
      testWidgets('$name cross-fades and drops the icon', (tester) async {
        final (:onPressed, :completer) = pendingPress();
        await tester.pumpWidget(pumpHost(build(onPressed)));
        final switcher = tester.state(find.byType(AnimatedSwitcher));

        await tester.tap(find.text('Save'));
        await tester.pump();
        await tester.pump(_fadeTime ~/ 2);

        check(
          because: 'the transition must survive the swap',
          tester.state(find.byType(AnimatedSwitcher)),
        ).identicalTo(switcher);
        check(find.text('Save')).findsOne;
        check(find.byType(CircularProgressIndicator)).findsOne;
        check(find.byIcon(Icons.save)).findsNone;

        completer.complete();
        await tester.pumpAndSettle();
        check(tester.state(find.byType(AnimatedSwitcher)))
            .identicalTo(switcher);
        check(find.byIcon(Icons.save)).findsOne;
      });
    }
  });

  testWidgets('a transitionBuilder from the theme also animates the swap', (
    tester,
  ) async {
    final (:onPressed, :completer) = pendingPress();
    await tester.pumpWidget(
      pumpHost(
        ElevatedAsyncButton.icon(
          onPressed: onPressed,
          icon: _icon,
          label: _label,
        ),
        theme: ThemeData(
          extensions: const [AsyncButtonTheme(transitionBuilder: _crossFade)],
        ),
      ),
    );
    final switcher = tester.state(find.byType(AnimatedSwitcher));

    await tester.tap(find.text('Save'));
    await tester.pump();

    check(tester.state(find.byType(AnimatedSwitcher))).identicalTo(switcher);

    completer.complete();
    await tester.pumpAndSettle();
  });

  group('without a transitionBuilder the spinner stays centered', () {
    final rows = <String, Widget Function(AsyncCallback, IconAlignment)>{
      'ElevatedAsyncButton.icon': (f, alignment) => ElevatedAsyncButton.icon(
        onPressed: f,
        iconAlignment: alignment,
        icon: _icon,
        label: _label,
      ),
      'FilledAsyncButton.icon': (f, alignment) => FilledAsyncButton.icon(
        onPressed: f,
        iconAlignment: alignment,
        icon: _icon,
        label: _label,
      ),
      'FilledAsyncButton.tonalIcon': (f, alignment) =>
          FilledAsyncButton.tonalIcon(
            onPressed: f,
            iconAlignment: alignment,
            icon: _icon,
            label: _label,
          ),
      'OutlinedAsyncButton.icon': (f, alignment) => OutlinedAsyncButton.icon(
        onPressed: f,
        iconAlignment: alignment,
        icon: _icon,
        label: _label,
      ),
      'TextAsyncButton.icon': (f, alignment) => TextAsyncButton.icon(
        onPressed: f,
        iconAlignment: alignment,
        icon: _icon,
        label: _label,
      ),
    };
    for (final MapEntry(key: name, value: build) in rows.entries) {
      for (final alignment in IconAlignment.values) {
        testWidgets('$name with iconAlignment ${alignment.name}', (
          tester,
        ) async {
          final (:onPressed, :completer) = pendingPress();
          await tester.pumpWidget(pumpHost(build(onPressed, alignment)));

          await tester.tap(find.text('Save'));
          await tester.pump();

          final spinner = tester.getCenter(
            find.byType(CircularProgressIndicator),
          );
          check(spinner.dx).isCloseTo(tester.getCenter(_standard).dx, 0.5);

          completer.complete();
          await tester.pumpAndSettle();
        });
      }
    }
  });

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

  group('maintainSize keeps the idle footprint and hides the child', () {
    final theme = asyncButtonTheme(maintainSize: true);
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
            theme: theme,
          );
          final hidden = _iconOnly.contains(name)
              ? find.byIcon(Icons.save)
              : find.text('Save');
          // Kept in the tree for its footprint, but not interactive.
          check(hidden).findsOne;
          check(hidden.hitTestable()).findsNone;
          check(find.byType(CircularProgressIndicator)).findsOne;
          completer.complete();
          await tester.pump();
          check(loading).equals(idle);
        });
      }
    }

    testWidgets('widget maintainSize: false beats the theme', (tester) async {
      final (:onPressed, :completer) = pendingPress();
      final (:idle, :loading) = await _idleVsLoading(
        tester,
        ElevatedAsyncButton(
          onPressed: onPressed,
          maintainSize: false,
          child: _label,
        ),
        _standard,
        pumpHost,
        theme: theme,
      );
      completer.complete();
      await tester.pump();
      check(loading.width).isLessThan(idle.width);
    });

    testWidgets(
      'selected IconAsyncButton with larger selectedIcon keeps selected '
      'footprint',
      (tester) async {
        final (:onPressed, :completer) = pendingPress();
        final (:idle, :loading) = await _idleVsLoading(
          tester,
          IconAsyncButton(
            onPressed: onPressed,
            isSelected: true,
            maintainSize: true,
            icon: const SizedBox.square(dimension: 16),
            selectedIcon: const SizedBox.square(dimension: 40),
          ),
          _iconButton,
          pumpHost,
        );
        completer.complete();
        await tester.pump();
        check(idle.width).isGreaterThan(48);
        check(loading).equals(idle);
      },
    );
  });
}
