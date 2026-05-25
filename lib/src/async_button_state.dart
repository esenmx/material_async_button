/// State of an async button.
///
/// Pattern-match with `switch` to react to each state:
///
/// ```dart
/// final color = switch (state) {
///   AsyncButtonStateIdle()    => Colors.blue,
///   AsyncButtonStateLoading() => Colors.grey,
///   AsyncButtonStateSuccess() => Colors.green,
///   AsyncButtonStateError()   => Colors.red,
/// };
/// ```
sealed class AsyncButtonState {
  const AsyncButtonState();

  const factory AsyncButtonState.idle() = AsyncButtonStateIdle;
  const factory AsyncButtonState.loading() = AsyncButtonStateLoading;
  const factory AsyncButtonState.success() = AsyncButtonStateSuccess;
  const factory AsyncButtonState.error(Object error, [StackTrace? stackTrace]) =
      AsyncButtonStateError;
}

final class AsyncButtonStateIdle extends AsyncButtonState {
  const AsyncButtonStateIdle();

  @override
  bool operator ==(Object other) => other is AsyncButtonStateIdle;

  @override
  int get hashCode => (AsyncButtonStateIdle).hashCode;

  @override
  String toString() => 'AsyncButtonState.idle()';
}

final class AsyncButtonStateLoading extends AsyncButtonState {
  const AsyncButtonStateLoading();

  @override
  bool operator ==(Object other) => other is AsyncButtonStateLoading;

  @override
  int get hashCode => (AsyncButtonStateLoading).hashCode;

  @override
  String toString() => 'AsyncButtonState.loading()';
}

final class AsyncButtonStateSuccess extends AsyncButtonState {
  const AsyncButtonStateSuccess();

  @override
  bool operator ==(Object other) => other is AsyncButtonStateSuccess;

  @override
  int get hashCode => (AsyncButtonStateSuccess).hashCode;

  @override
  String toString() => 'AsyncButtonState.success()';
}

final class AsyncButtonStateError extends AsyncButtonState {
  const AsyncButtonStateError(this.error, [this.stackTrace]);

  final Object error;
  final StackTrace? stackTrace;

  @override
  bool operator ==(Object other) =>
      other is AsyncButtonStateError && other.error == error;

  @override
  int get hashCode => Object.hash(AsyncButtonStateError, error);

  @override
  String toString() => 'AsyncButtonState.error($error)';
}
