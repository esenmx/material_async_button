/// This union class represents the state of the button in either a [Idling],
/// [AsyncButtonStateLoading], [AsyncButtonStateSuccess] or [AsyncButtonStateError] state.
/// This can be considered a enum with extra utilities for ease of use.
///
/// {@tool snippet}
///
/// ```dart
/// final buttonColor = AsyncbuttonState.when(
///   idle: () => Colors.pink,
///   loading: () => Colors.blue,
///   success: () => Colors.green,
///   error: () => Colors.red,
/// );
/// ```
/// {@end-tool}
///
/// You can also disregard other states and handle only those you'd like using
/// the `.maybeWhen` syntax.
///
/// {@tool snippet}
///
/// ```dart
/// final buttonColor = AsyncbuttonState.maybeWhen(
///   idle: () => Colors.pink,
///   orElse: () => Colors.red,
/// );
/// ```
/// {@end-tool}
sealed class AsyncButtonState {
  const AsyncButtonState();

  const factory AsyncButtonState.idle() = AsyncButtonStateIdle;
  const factory AsyncButtonState.loading() = AsyncButtonStateLoading;
  const factory AsyncButtonState.success() = AsyncButtonStateSuccess;
  const factory AsyncButtonState.error(Object error) = AsyncButtonStateError;
}

class AsyncButtonStateIdle extends AsyncButtonState {
  const AsyncButtonStateIdle();

  @override
  String toString() {
    return 'AsyncButtonState.idle()';
  }
}

class AsyncButtonStateLoading extends AsyncButtonState {
  const AsyncButtonStateLoading();

  @override
  String toString() {
    return 'AsyncButtonState.loading()';
  }
}

class AsyncButtonStateSuccess extends AsyncButtonState {
  const AsyncButtonStateSuccess();

  @override
  String toString() {
    return 'AsyncButtonState.success()';
  }
}

class AsyncButtonStateError extends AsyncButtonState {
  const AsyncButtonStateError(this.error);

  final Object error;

  @override
  String toString() {
    return 'AsyncButtonState.error(error: $error)';
  }
}
