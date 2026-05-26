part of '../material_async_button.dart';

/// Status of an async button. Sealed — pattern-match exhaustively, and pull
/// the [AsyncButtonStatusError.error] / [AsyncButtonStatusError.stackTrace]
/// payload directly from the error variant.
///
/// ```dart
/// final color = switch (status) {
///   AsyncButtonStatusIdle()    => Colors.blue,
///   AsyncButtonStatusLoading() => Colors.grey,
///   AsyncButtonStatusSuccess() => Colors.green,
///   AsyncButtonStatusError()   => Colors.red,
/// };
/// ```
///
/// The three singleton variants rely on `const` canonicalisation for
/// equality — always construct them via `const` or the factory ctors.
@immutable
sealed class AsyncButtonStatus {
  const AsyncButtonStatus();

  const factory AsyncButtonStatus.idle() = AsyncButtonStatusIdle;
  const factory AsyncButtonStatus.loading() = AsyncButtonStatusLoading;
  const factory AsyncButtonStatus.success() = AsyncButtonStatusSuccess;
  const factory AsyncButtonStatus.error(
    Object error, [
    StackTrace? stackTrace,
  ]) = AsyncButtonStatusError;
}

final class AsyncButtonStatusIdle extends AsyncButtonStatus {
  const AsyncButtonStatusIdle();

  @override
  String toString() {
    return '.idle()';
  }
}

final class AsyncButtonStatusLoading extends AsyncButtonStatus {
  const AsyncButtonStatusLoading();

  @override
  String toString() {
    return '.loading()';
  }
}

final class AsyncButtonStatusSuccess extends AsyncButtonStatus {
  const AsyncButtonStatusSuccess();

  @override
  String toString() {
    return '.success()';
  }
}

final class AsyncButtonStatusError extends AsyncButtonStatus {
  const AsyncButtonStatusError(this.error, [this.stackTrace]);

  final Object error;
  final StackTrace? stackTrace;

  /// Equality compares [error] by runtime type and `toString()` payload —
  /// most thrown errors (Exceptions, Errors, custom error objects) do not
  /// override `operator ==`, so a raw `error == other.error` collapses to
  /// identity. Two `invalidate('bad')` calls or two `StateError('oops')`
  /// throws are treated as the same error for listener-dedup purposes.
  /// [stackTrace] is informational and excluded from equality.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! AsyncButtonStatusError) {
      return false;
    }
    return error.runtimeType == other.error.runtimeType &&
        error.toString() == other.error.toString();
  }

  @override
  int get hashCode {
    return Object.hash(
      AsyncButtonStatusError,
      error.runtimeType,
      error.toString(),
    );
  }

  @override
  String toString() {
    return '.error($error)';
  }
}
