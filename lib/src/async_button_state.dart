import 'package:freezed_annotation/freezed_annotation.dart';

part 'async_button_state.freezed.dart';

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
@freezed
class AsyncButtonState with _$AsyncButtonState {
  const factory AsyncButtonState.idle() = AsyncButtonStateIdle;
  const factory AsyncButtonState.loading() = AsyncButtonStateLoading;
  const factory AsyncButtonState.success() = AsyncButtonStateSuccess;
  const factory AsyncButtonState.error(Object error) = AsyncButtonStateError;
}
