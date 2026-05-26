import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_async_button/material_async_button.dart';

void main() {
  group('AsyncButtonTheme', () {
    test('empty default has all null fields', () {
      const t = AsyncButtonTheme.empty;
      check(t)
        ..has((it) => it.loadingChild, 'loadingChild').isNull()
        ..has((it) => it.successChild, 'successChild').isNull()
        ..has((it) => it.errorChild, 'errorChild').isNull()
        ..has((it) => it.switchDuration, 'switchDuration').isNull()
        ..has((it) => it.hapticOn, 'hapticOn').isNull();
    });

    test('material() supplies opinionated baseline', () {
      final t = AsyncButtonTheme.material();
      check(t)
        ..has((it) => it.loadingChild, 'loadingChild').isNotNull()
        ..has((it) => it.successChild, 'successChild').isNotNull()
        ..has((it) => it.errorChild, 'errorChild').isNotNull()
        ..has(
          (it) => it.switchDuration,
          'switchDuration',
        ).equals(const Duration(milliseconds: 200))
        ..has(
          (it) => it.successDisplayDuration,
          'successDisplayDuration',
        ).equals(const Duration(milliseconds: 800))
        ..has(
          (it) => it.errorDisplayDuration,
          'errorDisplayDuration',
        ).equals(const Duration(milliseconds: 800))
        ..has((it) => it.animateSize, 'animateSize').equals(true)
        ..has((it) => it.hapticOn, 'hapticOn').equals(HapticOn.both)
        ..has((it) => it.announceSemantics, 'announceSemantics').equals(true);
    });

    test('copyWith overrides only specified fields', () {
      final base = AsyncButtonTheme.material();
      final overridden = base.copyWith(
        switchDuration: const Duration(milliseconds: 500),
      );
      check(overridden)
        ..has(
          (it) => it.switchDuration,
          'switchDuration',
        ).equals(const Duration(milliseconds: 500))
        ..has(
          (it) => it.successDisplayDuration,
          'successDisplayDuration',
        ).equals(base.successDisplayDuration)
        ..has((it) => it.hapticOn, 'hapticOn').equals(base.hapticOn);
    });

    test('lerp snaps non-numeric fields and interpolates durations', () {
      const a = AsyncButtonTheme(
        switchDuration: Duration(milliseconds: 100),
        successDisplayDuration: Duration(milliseconds: 200),
        hapticOn: HapticOn.success,
      );
      const b = AsyncButtonTheme(
        switchDuration: Duration(milliseconds: 300),
        successDisplayDuration: Duration(milliseconds: 600),
        hapticOn: HapticOn.error,
      );
      final mid = a.lerp(b, 0.5);
      check(mid)
        ..has(
          (it) => it.switchDuration,
          'switchDuration',
        ).equals(const Duration(milliseconds: 200))
        ..has(
          (it) => it.successDisplayDuration,
          'successDisplayDuration',
        ).equals(const Duration(milliseconds: 400))
        ..has((it) => it.hapticOn, 'hapticOn').equals(HapticOn.error);
    });

    test('lerp with non-AsyncButtonTheme returns self', () {
      const a = AsyncButtonTheme(
        switchDuration: Duration(milliseconds: 100),
      );
      check(a.lerp(null, 0.5))
          .has((it) => it.switchDuration, 'switchDuration')
          .equals(a.switchDuration);
    });

    testWidgets('of(context) returns the registered extension', (tester) async {
      const ext = AsyncButtonTheme(
        switchDuration: Duration(milliseconds: 123),
      );
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
          .has((it) => it.switchDuration, 'switchDuration')
          .equals(const Duration(milliseconds: 123));
    });

    testWidgets('of(context) falls back to material defaults when absent', (
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
      check(captured)
          .isNotNull()
          .has((it) => it.switchDuration, 'switchDuration')
          .equals(const Duration(milliseconds: 200));
    });

    testWidgets(
      'of(context) returns registered empty extension when explicitly set',
      (tester) async {
        AsyncButtonTheme? captured;
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(extensions: const [AsyncButtonTheme.empty]),
            home: Builder(
              builder: (ctx) {
                captured = AsyncButtonTheme.of(ctx);
                return const SizedBox.shrink();
              },
            ),
          ),
        );
        check(
          captured,
        ).isNotNull().has((it) => it.switchDuration, 'switchDuration').isNull();
      },
    );

    test('equality is value-based', () {
      const a = AsyncButtonTheme(
        switchDuration: Duration(milliseconds: 100),
        hapticOn: HapticOn.both,
      );
      const b = AsyncButtonTheme(
        switchDuration: Duration(milliseconds: 100),
        hapticOn: HapticOn.both,
      );
      check(a).equals(b);
      check(a.hashCode).equals(b.hashCode);
    });
  });
}
