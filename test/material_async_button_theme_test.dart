import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_async_button/material_async_button.dart';

void main() {
  group('MaterialAsyncButtonTheme', () {
    test('empty default has all null fields', () {
      const t = MaterialAsyncButtonTheme.empty;
      expect(t.loadingChild, isNull);
      expect(t.successChild, isNull);
      expect(t.errorChild, isNull);
      expect(t.switchDuration, isNull);
      expect(t.hapticOn, isNull);
    });

    test('material() supplies opinionated baseline', () {
      final t = MaterialAsyncButtonTheme.material();
      expect(t.loadingChild, isNotNull);
      expect(t.successChild, isNotNull);
      expect(t.errorChild, isNotNull);
      expect(t.switchDuration, const Duration(milliseconds: 200));
      expect(t.successDisplayDuration, const Duration(milliseconds: 800));
      expect(t.errorDisplayDuration, const Duration(milliseconds: 800));
      expect(t.animateSize, isTrue);
      expect(t.hapticOn, HapticOn.both);
      expect(t.announceSemantics, isTrue);
    });

    test('copyWith overrides only specified fields', () {
      final base = MaterialAsyncButtonTheme.material();
      final overridden = base.copyWith(switchDuration: const Duration(milliseconds: 500));
      expect(overridden.switchDuration, const Duration(milliseconds: 500));
      expect(overridden.successDisplayDuration, base.successDisplayDuration);
      expect(overridden.hapticOn, base.hapticOn);
    });

    test('lerp snaps non-numeric fields and interpolates durations', () {
      const a = MaterialAsyncButtonTheme(
        switchDuration: Duration(milliseconds: 100),
        successDisplayDuration: Duration(milliseconds: 200),
        hapticOn: HapticOn.success,
      );
      const b = MaterialAsyncButtonTheme(
        switchDuration: Duration(milliseconds: 300),
        successDisplayDuration: Duration(milliseconds: 600),
        hapticOn: HapticOn.error,
      );
      final mid = a.lerp(b, 0.5);
      expect(mid.switchDuration, const Duration(milliseconds: 200));
      expect(mid.successDisplayDuration, const Duration(milliseconds: 400));
      // Non-interpolable fields snap at 0.5 to the second value.
      expect(mid.hapticOn, HapticOn.error);
    });

    test('lerp with non-MaterialAsyncButtonTheme returns self', () {
      const a = MaterialAsyncButtonTheme(switchDuration: Duration(milliseconds: 100));
      final result = a.lerp(null, 0.5);
      expect(result.switchDuration, a.switchDuration);
    });

    testWidgets('of(context) returns the registered extension', (tester) async {
      const ext = MaterialAsyncButtonTheme(switchDuration: Duration(milliseconds: 123));
      MaterialAsyncButtonTheme? captured;
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: const [ext]),
          home: Builder(
            builder: (ctx) {
              captured = MaterialAsyncButtonTheme.of(ctx);
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      expect(captured?.switchDuration, const Duration(milliseconds: 123));
    });

    testWidgets('of(context) returns empty when extension absent', (tester) async {
      MaterialAsyncButtonTheme? captured;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (ctx) {
              captured = MaterialAsyncButtonTheme.of(ctx);
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      expect(captured?.switchDuration, isNull);
    });

    test('equality is value-based', () {
      const a = MaterialAsyncButtonTheme(
        switchDuration: Duration(milliseconds: 100),
        hapticOn: HapticOn.both,
      );
      const b = MaterialAsyncButtonTheme(
        switchDuration: Duration(milliseconds: 100),
        hapticOn: HapticOn.both,
      );
      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });
  });
}
