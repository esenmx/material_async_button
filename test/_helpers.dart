import 'dart:async';

import 'package:checks/checks.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_async_button/material_async_button.dart';

/// Wraps a widget in a minimal MaterialApp + Scaffold for testing.
///
/// Defaults to a [ThemeData] carrying [AsyncButtonTheme.empty] so the tests
/// see the per-widget / hard-coded fallbacks.
Widget pumpHost(Widget child, {ThemeData? theme}) {
  return MaterialApp(
    theme: theme ?? emptyAsyncButtonTheme,
    home: Scaffold(body: Center(child: child)),
  );
}

/// A [ThemeData] whose only extension is [AsyncButtonTheme.empty] — the
/// zero-config baseline, used to assert the per-widget / hard-coded fallbacks.
final ThemeData emptyAsyncButtonTheme = ThemeData(
  extensions: const [AsyncButtonTheme.empty],
);

/// A [ThemeData] carrying an [AsyncButtonTheme] from the given fields — for
/// asserting that theme values flow through when no per-widget override is set.
ThemeData asyncButtonTheme({
  WidgetBuilder? loadingBuilder,
  AsyncButtonTransitionBuilder? transitionBuilder,
}) {
  return ThemeData(
    extensions: [
      AsyncButtonTheme(
        loadingBuilder: loadingBuilder,
        transitionBuilder: transitionBuilder,
      ),
    ],
  );
}

/// Returns an `(onPressed, completer)` pair. Caller drives the button into
/// loading and decides when to complete or fail.
({AsyncCallback onPressed, Completer<void> completer}) pendingPress() {
  final completer = Completer<void>();
  return (onPressed: () => completer.future, completer: completer);
}

/// Taps [finder] and pumps into the loading frame: the spinner is mounted and
/// its indeterminate animation has advanced far enough for `valueColor` to
/// resolve (so [spinnerColor] reads the inherited foreground, not a null
/// first-frame value).
Future<void> tapIntoLoading(WidgetTester tester, Finder finder) async {
  await tester.tap(finder);
  await tester.pump(); // kick off the future → first loading frame
  await tester.pump(const Duration(milliseconds: 250)); // advance the spinner
}

/// A fresh [AsyncButtonController] that auto-disposes at test teardown — for
/// tests that hand the controller to a widget (which attaches `onPressed`
/// itself). Use [attachedController] when driving a detached controller.
AsyncButtonController newController() {
  final c = AsyncButtonController();
  addTearDown(c.dispose);
  return c;
}

/// Controller pre-attached with `onPressed`, for driving it detached from any
/// widget. Auto-disposes.
AsyncButtonController attachedController({AsyncCallback? onPressed}) {
  final c = AsyncButtonController()..attach(onPressed: onPressed);
  addTearDown(c.dispose);
  return c;
}

/// Builder that renders a [TextButton] driven by the AsyncButton callback.
Widget textBuilder(_, Widget child, AsyncCallback? cb, _) {
  return TextButton(onPressed: cb, child: child);
}

/// The colour the loading [CircularProgressIndicator] resolved to — i.e. the
/// spinner foreground inherited from the enabled button while loading.
Color? spinnerColor(WidgetTester tester) {
  final cpi = tester.widget<CircularProgressIndicator>(
    find.byType(CircularProgressIndicator),
  );
  return cpi.valueColor?.value;
}

/// The colour of the nearest [IconTheme] above the spinner — the scope any
/// `Icon` / spinner loading child inherits.
Color? spinnerIconThemeColor(WidgetTester tester) {
  final iconTheme = tester.widget<IconTheme>(
    find
        .ancestor(
          of: find.byType(CircularProgressIndicator),
          matching: find.byType(IconTheme),
        )
        .first,
  );
  return iconTheme.data.color;
}

/// Side length the loading spinner is laid out in — the `width` of the nearest
/// [SizedBox] above the [CircularProgressIndicator] ([AsyncButtonSpinner] uses
/// [SizedBox.square], so width == height == the resolved dimension).
double? loadingSpinnerSize(WidgetTester tester) {
  final box = tester.widget<SizedBox>(
    find
        .ancestor(
          of: find.byType(CircularProgressIndicator),
          matching: find.byType(SizedBox),
        )
        .first,
  );
  return box.width;
}

/// The size of the nearest [IconTheme] above the spinner — the button's
/// resolved icon size, the scope an icon loading child inherits.
double? spinnerIconThemeSize(WidgetTester tester) {
  final iconTheme = tester.widget<IconTheme>(
    find
        .ancestor(
          of: find.byType(CircularProgressIndicator),
          matching: find.byType(IconTheme),
        )
        .first,
  );
  return iconTheme.data.size;
}

/// The font size of the nearest [DefaultTextStyle] above the spinner — the
/// button's resolved label size.
double? spinnerFontSize(WidgetTester tester) {
  final style = tester.widget<DefaultTextStyle>(
    find
        .ancestor(
          of: find.byType(CircularProgressIndicator),
          matching: find.byType(DefaultTextStyle),
        )
        .first,
  );
  return style.style.fontSize;
}

/// The single-line *line-box* height of the label style resolved at the spinner
/// — the height the default spinner is meant to match (taller than the raw
/// font size for real fonts / explicit `height`). Mirrors the package's own
/// `_ambientTextLineBox` measurement so tests assert the same number.
double spinnerTextLineBox(WidgetTester tester) {
  final style = tester
      .widget<DefaultTextStyle>(
        find
            .ancestor(
              of: find.byType(CircularProgressIndicator),
              matching: find.byType(DefaultTextStyle),
            )
            .first,
      )
      .style;
  final painter = TextPainter(
    text: TextSpan(text: '', style: style),
    textDirection: TextDirection.ltr,
  )..layout();
  return painter.preferredLineHeight;
}

/// `checks`-style assertions for [Finder].
extension FinderChecks on Subject<Finder> {
  void findsOne() => has((f) => f.evaluate().length, 'matches').equals(1);
  void findsNone() => has((f) => f.evaluate(), 'matches').isEmpty();
}

/// `checks`-style assertions for [AsyncButtonController].
extension AsyncButtonControllerChecks on Subject<AsyncButtonController> {
  void isIdle() => has((c) => c.value, 'isLoading').isFalse();
  void isLoading() => has((c) => c.value, 'isLoading').isTrue();
}
