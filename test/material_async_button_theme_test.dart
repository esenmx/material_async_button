import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_async_button/material_async_button.dart';

// A no-op transition builder for theme-field tests.
Widget _noopTransition(BuildContext context, Widget child, bool isLoading) {
  return child;
}

// Two distinct loading builders — reused across tests that assert field
// identity (copyWith / lerp / equality). Their separate references are the
// point, so they live at top level rather than being redeclared per test.
Widget _loadingA(BuildContext _) => const SizedBox.shrink();
Widget _loadingB(BuildContext _) => const SizedBox.shrink();

void main() {
  group('AsyncButtonTheme', () {
    test('empty default has all null fields', () {
      const t = AsyncButtonTheme.empty;
      check(t)
        ..has((it) => it.loadingBuilder, 'loadingBuilder').isNull()
        ..has((it) => it.transitionBuilder, 'transitionBuilder').isNull();
    });

    test('copyWith with no arguments returns an identical theme', () {
      const base = AsyncButtonTheme(
        loadingBuilder: _loadingA,
        transitionBuilder: _noopTransition,
      );
      check(base.copyWith()).equals(base);
    });

    test('copyWith overrides only specified fields, preserving the rest', () {
      const base = AsyncButtonTheme(
        loadingBuilder: _loadingA,
        transitionBuilder: _noopTransition,
      );
      final overridden = base.copyWith(loadingBuilder: _loadingB);
      check(overridden)
        ..has((it) => it.loadingBuilder, 'loadingBuilder').equals(_loadingB)
        ..has(
          (it) => it.transitionBuilder,
          'transitionBuilder',
        ).equals(_noopTransition);
    });

    test('lerp snaps fields at the halfway point', () {
      const from = AsyncButtonTheme(loadingBuilder: _loadingA);
      const to = AsyncButtonTheme(loadingBuilder: _loadingB);
      check(
        from.lerp(to, 0.4),
      ).has((it) => it.loadingBuilder, 'loadingBuilder').equals(_loadingA);
      check(
        from.lerp(to, 0.6),
      ).has((it) => it.loadingBuilder, 'loadingBuilder').equals(_loadingB);
    });

    test('lerp with non-AsyncButtonTheme returns self', () {
      const a = AsyncButtonTheme(loadingBuilder: _loadingA);
      check(
        a.lerp(null, 0.5),
      ).has((it) => it.loadingBuilder, 'loadingBuilder').equals(_loadingA);
    });

    testWidgets('of(context) returns the registered extension', (tester) async {
      const ext = AsyncButtonTheme(loadingBuilder: _loadingA);
      AsyncButtonTheme? captured;
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: const [ext]),
          home: Builder(
            builder: (ctx) {
              captured = AsyncButtonTheme.of(ctx);
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      check(captured)
          .isNotNull()
          .has((it) => it.loadingBuilder, 'loadingBuilder')
          .equals(_loadingA);
    });

    testWidgets('of(context) falls back to empty when no extension is set', (
      tester,
    ) async {
      AsyncButtonTheme? captured;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (ctx) {
              captured = AsyncButtonTheme.of(ctx);
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      check(captured).isNotNull()
        ..has((it) => it.loadingBuilder, 'loadingBuilder').isNull()
        ..has((it) => it.transitionBuilder, 'transitionBuilder').isNull();
    });

    test('equality is value-based', () {
      const a = AsyncButtonTheme(
        loadingBuilder: _loadingA,
        transitionBuilder: _noopTransition,
      );
      const b = AsyncButtonTheme(
        loadingBuilder: _loadingA,
        transitionBuilder: _noopTransition,
      );
      check(a).equals(b);
      check(a.hashCode).equals(b.hashCode);
    });
  });
}
