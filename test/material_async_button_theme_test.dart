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
  });

  group('AsyncButtonSpinner line box cache', () {
    testWidgets(
      'caps at 16 entries, evicts the least recently used, promotes hits',
      (tester) async {
        debugLineBoxCache.clear();
        addTearDown(debugLineBoxCache.clear);

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

        // Fill the cache to its capacity of 16 with distinct styles.
        for (var i = 1; i <= 16; i++) {
          await pumpSpinnerWithFontSize(i.toDouble());
        }
        check(debugLineBoxCache.length).equals(16);
        final firstKey = debugLineBoxCache.keys.first;
        check(firstKey.$1.fontSize).equals(1);

        // A 17th style evicts the oldest entry.
        await pumpSpinnerWithFontSize(17);
        check(debugLineBoxCache.length).equals(16);
        check(debugLineBoxCache.containsKey(firstKey)).isFalse();

        // A hit on the now-oldest entry moves it to the MRU end without
        // growing or evicting.
        final secondKey = debugLineBoxCache.keys.first;
        check(secondKey.$1.fontSize).equals(2);
        final valueBeforePromotion = debugLineBoxCache[secondKey];
        await pumpSpinnerWithFontSize(2);
        check(debugLineBoxCache.length).equals(16);
        check(debugLineBoxCache.keys.last).equals(secondKey);
        // Promotion must re-insert the cached measurement unchanged — a
        // structural pass with a corrupted value would go unnoticed otherwise.
        check(debugLineBoxCache[secondKey]).equals(valueBeforePromotion);
      },
    );
  });
}
