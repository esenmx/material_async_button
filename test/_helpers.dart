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
    theme: theme ?? ThemeData(extensions: const [AsyncButtonTheme.empty]),
    home: Scaffold(
      body: Center(child: child),
    ),
  );
}

/// Returns an `(onPressed, completer)` pair. Caller drives the button into
/// loading and decides when to complete or fail.
({AsyncCallback onPressed, Completer<void> completer}) pendingPress() {
  final completer = Completer<void>();
  return (onPressed: () => completer.future, completer: completer);
}

/// Controller pre-attached with `onPressed`. Auto-disposes.
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

/// `checks`-style assertions for [Finder].
extension FinderChecks on Subject<Finder> {
  void findsOne() => has((f) => f.evaluate().length, 'matches').equals(1);
  void findsNone() => has((f) => f.evaluate(), 'matches').isEmpty();
  void findsMany([int min = 1]) =>
      has((f) => f.evaluate().length, 'matches').isGreaterOrEqual(min);
}

/// `checks`-style assertions for [AsyncButtonController].
extension AsyncButtonControllerChecks on Subject<AsyncButtonController> {
  void isIdle() => has((c) => c.value, 'isLoading').isFalse();
  void isLoading() => has((c) => c.value, 'isLoading').isTrue();
}
