import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_async_button/material_async_button.dart';

// A no-op transition builder for theme-field tests.
Widget _noopTransition(BuildContext context, Widget child, bool isLoading) {
  return child;
}

void main() {
  group('AsyncButtonTheme', () {
    test('empty default has all null fields', () {
      const t = AsyncButtonTheme.empty;
      check(t)
        ..has((it) => it.loadingBuilder, 'loadingBuilder').isNull()
        ..has((it) => it.transitionBuilder, 'transitionBuilder').isNull();
    });

    test('copyWith overrides only specified fields, preserving the rest', () {
      Widget loadingA(BuildContext _) => const SizedBox.shrink();
      Widget loadingB(BuildContext _) => const SizedBox.shrink();
      final base = AsyncButtonTheme(
        loadingBuilder: loadingA,
        transitionBuilder: _noopTransition,
      );
      final overridden = base.copyWith(loadingBuilder: loadingB);
      check(overridden)
        ..has((it) => it.loadingBuilder, 'loadingBuilder').equals(loadingB)
        ..has(
          (it) => it.transitionBuilder,
          'transitionBuilder',
        ).equals(_noopTransition);
    });

    test('lerp snaps fields at the halfway point', () {
      Widget loadingA(BuildContext _) => const SizedBox.shrink();
      Widget loadingB(BuildContext _) => const SizedBox.shrink();
      final from = AsyncButtonTheme(loadingBuilder: loadingA);
      final to = AsyncButtonTheme(loadingBuilder: loadingB);
      check(
        from.lerp(to, 0.4),
      ).has((it) => it.loadingBuilder, 'loadingBuilder').equals(loadingA);
      check(
        from.lerp(to, 0.6),
      ).has((it) => it.loadingBuilder, 'loadingBuilder').equals(loadingB);
    });

    test('lerp with non-AsyncButtonTheme returns self', () {
      Widget loadingA(BuildContext _) => const SizedBox.shrink();
      final a = AsyncButtonTheme(loadingBuilder: loadingA);
      check(
        a.lerp(null, 0.5),
      ).has((it) => it.loadingBuilder, 'loadingBuilder').equals(loadingA);
    });

    testWidgets('of(context) returns the registered extension', (tester) async {
      Widget loadingA(BuildContext _) => const SizedBox.shrink();
      final ext = AsyncButtonTheme(loadingBuilder: loadingA);
      AsyncButtonTheme? captured;
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: [ext]),
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
          .equals(loadingA);
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
      Widget loadingA(BuildContext _) => const SizedBox.shrink();
      final a = AsyncButtonTheme(
        loadingBuilder: loadingA,
        transitionBuilder: _noopTransition,
      );
      final b = AsyncButtonTheme(
        loadingBuilder: loadingA,
        transitionBuilder: _noopTransition,
      );
      check(a).equals(b);
      check(a.hashCode).equals(b.hashCode);
    });
  });
}
