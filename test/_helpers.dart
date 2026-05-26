import 'dart:async';

import 'package:checks/checks.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_async_button/material_async_button.dart';

/// Wraps a widget in a minimal MaterialApp + Scaffold for testing.
///
/// Defaults to a [ThemeData] carrying [AsyncButtonTheme.empty] so the tests
/// see the per-widget / hard-coded fallbacks instead of the opinionated
/// [AsyncButtonTheme.material] baseline that `AsyncButtonTheme.of` returns
/// when no extension is registered.
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

/// Controller pre-attached with `onPressed`/durations. Auto-disposes.
AsyncButtonController attachedController({
  AsyncCallback? onPressed,
  Duration successDuration = .zero,
  Duration errorDuration = .zero,
  Duration cooldownDuration = .zero,
  bool rethrowErrors = false,
}) {
  final c = AsyncButtonController()
    ..attach(
      onPressed: onPressed,
      successDuration: successDuration,
      errorDuration: errorDuration,
      cooldownDuration: cooldownDuration,
      rethrowErrors: rethrowErrors,
    );
  addTearDown(c.dispose);
  return c;
}

/// Builder that renders a [TextButton] driven by the AsyncButton callback.
Widget textBuilder(_, Widget child, AsyncCallback? cb, _) {
  return TextButton(onPressed: cb, child: child);
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
  void hasStatus(AsyncButtonStatus expected) =>
      has((c) => c.value, 'value').equals(expected);
  void isIdle() => hasStatus(const .idle());
  void isLoading() => hasStatus(const .loading());
  void isSuccess() => hasStatus(const .success());
}
