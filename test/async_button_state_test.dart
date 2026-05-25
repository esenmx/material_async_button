import 'package:flutter_test/flutter_test.dart';
import 'package:material_async_button/material_async_button.dart';

void main() {
  group('AsyncButtonState equality', () {
    test('idle equals idle', () {
      expect(const AsyncButtonState.idle(), const AsyncButtonState.idle());
      expect(const AsyncButtonState.idle().hashCode, const AsyncButtonState.idle().hashCode);
    });

    test('loading equals loading', () {
      expect(const AsyncButtonState.loading(), const AsyncButtonState.loading());
    });

    test('success equals success', () {
      expect(const AsyncButtonState.success(), const AsyncButtonState.success());
    });

    test('error equals error by error object', () {
      final e = Exception('boom');
      expect(AsyncButtonState.error(e), AsyncButtonState.error(e));
      // Different errors are not equal.
      expect(
        AsyncButtonState.error(Exception('a')) == AsyncButtonState.error(Exception('a')),
        isFalse,
        reason: 'Two distinct Exception instances are not equal in Dart.',
      );
    });

    test('different variants are not equal', () {
      expect(const AsyncButtonState.idle() == const AsyncButtonState.loading(), isFalse);
      expect(const AsyncButtonState.success() == const AsyncButtonState.idle(), isFalse);
    });
  });

  group('AsyncButtonState toString', () {
    test('readable identifiers', () {
      expect(const AsyncButtonState.idle().toString(), 'AsyncButtonState.idle()');
      expect(const AsyncButtonState.loading().toString(), 'AsyncButtonState.loading()');
      expect(const AsyncButtonState.success().toString(), 'AsyncButtonState.success()');
      expect(AsyncButtonState.error('boom').toString(), 'AsyncButtonState.error(boom)');
    });
  });

  group('AsyncButtonState pattern matching', () {
    test('exhaustive switch compiles and dispatches', () {
      String describe(AsyncButtonState s) => switch (s) {
        AsyncButtonStateIdle() => 'idle',
        AsyncButtonStateLoading() => 'loading',
        AsyncButtonStateSuccess() => 'success',
        AsyncButtonStateError() => 'error',
      };
      expect(describe(const AsyncButtonState.idle()), 'idle');
      expect(describe(const AsyncButtonState.loading()), 'loading');
      expect(describe(const AsyncButtonState.success()), 'success');
      expect(describe(AsyncButtonState.error('x')), 'error');
    });

    test('error variant exposes error and stack trace', () {
      final st = StackTrace.current;
      final s = AsyncButtonState.error('boom', st);
      expect(s.error, 'boom');
      expect(s.stackTrace, st);
    });
  });
}
