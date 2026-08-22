import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_async_button/material_async_button.dart';

// Two distinct no-op transition builders — as with the loading builders
// below, their separate references are the point.
Widget _noopTransition(BuildContext context, Widget child, bool isLoading) {
  return child;
}

Widget _otherTransition(BuildContext context, Widget child, bool isLoading) {
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
      const from = AsyncButtonTheme(
        loadingBuilder: _loadingA,
        transitionBuilder: _noopTransition,
      );
      const to = AsyncButtonTheme(
        loadingBuilder: _loadingB,
        transitionBuilder: _otherTransition,
      );

      // `t < 0.5` keeps `this`; the boundary itself already takes `other`.
      for (final (t, expected) in [(0.4, from), (0.5, to), (0.6, to)]) {
        check(from.lerp(to, t), because: 't=$t')
          ..has(
            (it) => it.loadingBuilder,
            'loadingBuilder',
          ).equals(expected.loadingBuilder)
          ..has(
            (it) => it.transitionBuilder,
            'transitionBuilder',
          ).equals(expected.transitionBuilder);
      }
    });

    test('lerp with non-AsyncButtonTheme returns self', () {
      const a = AsyncButtonTheme(loadingBuilder: _loadingA);
      check(a.lerp(null, 0.5).loadingBuilder).equals(_loadingA);
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

    test('empty leaves every field at its default', () {
      // `empty` is itself `const AsyncButtonTheme()`, so the equality below is
      // satisfied by const canonicalization alone. The field checks are what
      // actually pin the invariant: `empty` must never grow a set field.
      // ignore: use_named_constants
      const b = AsyncButtonTheme();
      check(AsyncButtonTheme.empty).equals(b);
      check(AsyncButtonTheme.empty.loadingBuilder).isNull();
      check(AsyncButtonTheme.empty.transitionBuilder).isNull();
    });

    testWidgets('AsyncButtonSpinner line box cache evicts oldest entry when '
        'capacity exceeds 16', (tester) async {
      debugLineBoxCache.clear();

      Future<void> pumpSpinnerWithFontSize(double fontSize) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: DefaultTextStyle(
                style: TextStyle(fontSize: fontSize),
                child: const AsyncButtonSpinner(),
              ),
            ),
          ),
        );
      }

      // Pump 16 distinct text styles to fill cache to its max capacity of 16.
      for (var i = 1; i <= 16; i++) {
        await pumpSpinnerWithFontSize(i.toDouble());
      }

      check(debugLineBoxCache.length).equals(16);

      // Identify the key for fontSize 1 (the first inserted entry).
      final firstKey = debugLineBoxCache.keys.first;
      check(debugLineBoxCache.containsKey(firstKey)).isTrue();

      // Pump 17th distinct text style. This should evict oldest entry.
      await pumpSpinnerWithFontSize(17);

      check(debugLineBoxCache.length).equals(16);
      check(debugLineBoxCache.containsKey(firstKey)).isFalse();

      // Re-querying an existing cached style (e.g. fontSize 2) promotes it
      // and does not expand cache length or evict any entry.
      final secondKey = debugLineBoxCache.keys.first; // fontSize 2
      await pumpSpinnerWithFontSize(2);

      check(debugLineBoxCache.length).equals(16);
      check(debugLineBoxCache.containsKey(secondKey)).isTrue();
      // secondKey was re-inserted at the end of LRU cache, so it is no
      // longer the first key.
      check(debugLineBoxCache.keys.first).not((it) => it.equals(secondKey));

      debugLineBoxCache.clear();
    });
  });
}
