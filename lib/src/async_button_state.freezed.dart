// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'async_button_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$AsyncButtonState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() idle,
    required TResult Function() loading,
    required TResult Function() success,
    required TResult Function(Object error) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? idle,
    TResult? Function()? loading,
    TResult? Function()? success,
    TResult? Function(Object error)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? idle,
    TResult Function()? loading,
    TResult Function()? success,
    TResult Function(Object error)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(AsyncButtonStateIdle value) idle,
    required TResult Function(AsyncButtonStateLoading value) loading,
    required TResult Function(AsyncButtonStateSuccess value) success,
    required TResult Function(AsyncButtonStateError value) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(AsyncButtonStateIdle value)? idle,
    TResult? Function(AsyncButtonStateLoading value)? loading,
    TResult? Function(AsyncButtonStateSuccess value)? success,
    TResult? Function(AsyncButtonStateError value)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(AsyncButtonStateIdle value)? idle,
    TResult Function(AsyncButtonStateLoading value)? loading,
    TResult Function(AsyncButtonStateSuccess value)? success,
    TResult Function(AsyncButtonStateError value)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AsyncButtonStateCopyWith<$Res> {
  factory $AsyncButtonStateCopyWith(
          AsyncButtonState value, $Res Function(AsyncButtonState) then) =
      _$AsyncButtonStateCopyWithImpl<$Res, AsyncButtonState>;
}

/// @nodoc
class _$AsyncButtonStateCopyWithImpl<$Res, $Val extends AsyncButtonState>
    implements $AsyncButtonStateCopyWith<$Res> {
  _$AsyncButtonStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;
}

/// @nodoc
abstract class _$$AsyncButtonStateIdleImplCopyWith<$Res> {
  factory _$$AsyncButtonStateIdleImplCopyWith(_$AsyncButtonStateIdleImpl value,
          $Res Function(_$AsyncButtonStateIdleImpl) then) =
      __$$AsyncButtonStateIdleImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$AsyncButtonStateIdleImplCopyWithImpl<$Res>
    extends _$AsyncButtonStateCopyWithImpl<$Res, _$AsyncButtonStateIdleImpl>
    implements _$$AsyncButtonStateIdleImplCopyWith<$Res> {
  __$$AsyncButtonStateIdleImplCopyWithImpl(_$AsyncButtonStateIdleImpl _value,
      $Res Function(_$AsyncButtonStateIdleImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$AsyncButtonStateIdleImpl implements AsyncButtonStateIdle {
  const _$AsyncButtonStateIdleImpl();

  @override
  String toString() {
    return 'AsyncButtonState.idle()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AsyncButtonStateIdleImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() idle,
    required TResult Function() loading,
    required TResult Function() success,
    required TResult Function(Object error) error,
  }) {
    return idle();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? idle,
    TResult? Function()? loading,
    TResult? Function()? success,
    TResult? Function(Object error)? error,
  }) {
    return idle?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? idle,
    TResult Function()? loading,
    TResult Function()? success,
    TResult Function(Object error)? error,
    required TResult orElse(),
  }) {
    if (idle != null) {
      return idle();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(AsyncButtonStateIdle value) idle,
    required TResult Function(AsyncButtonStateLoading value) loading,
    required TResult Function(AsyncButtonStateSuccess value) success,
    required TResult Function(AsyncButtonStateError value) error,
  }) {
    return idle(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(AsyncButtonStateIdle value)? idle,
    TResult? Function(AsyncButtonStateLoading value)? loading,
    TResult? Function(AsyncButtonStateSuccess value)? success,
    TResult? Function(AsyncButtonStateError value)? error,
  }) {
    return idle?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(AsyncButtonStateIdle value)? idle,
    TResult Function(AsyncButtonStateLoading value)? loading,
    TResult Function(AsyncButtonStateSuccess value)? success,
    TResult Function(AsyncButtonStateError value)? error,
    required TResult orElse(),
  }) {
    if (idle != null) {
      return idle(this);
    }
    return orElse();
  }
}

abstract class AsyncButtonStateIdle implements AsyncButtonState {
  const factory AsyncButtonStateIdle() = _$AsyncButtonStateIdleImpl;
}

/// @nodoc
abstract class _$$AsyncButtonStateLoadingImplCopyWith<$Res> {
  factory _$$AsyncButtonStateLoadingImplCopyWith(
          _$AsyncButtonStateLoadingImpl value,
          $Res Function(_$AsyncButtonStateLoadingImpl) then) =
      __$$AsyncButtonStateLoadingImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$AsyncButtonStateLoadingImplCopyWithImpl<$Res>
    extends _$AsyncButtonStateCopyWithImpl<$Res, _$AsyncButtonStateLoadingImpl>
    implements _$$AsyncButtonStateLoadingImplCopyWith<$Res> {
  __$$AsyncButtonStateLoadingImplCopyWithImpl(
      _$AsyncButtonStateLoadingImpl _value,
      $Res Function(_$AsyncButtonStateLoadingImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$AsyncButtonStateLoadingImpl implements AsyncButtonStateLoading {
  const _$AsyncButtonStateLoadingImpl();

  @override
  String toString() {
    return 'AsyncButtonState.loading()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AsyncButtonStateLoadingImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() idle,
    required TResult Function() loading,
    required TResult Function() success,
    required TResult Function(Object error) error,
  }) {
    return loading();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? idle,
    TResult? Function()? loading,
    TResult? Function()? success,
    TResult? Function(Object error)? error,
  }) {
    return loading?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? idle,
    TResult Function()? loading,
    TResult Function()? success,
    TResult Function(Object error)? error,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(AsyncButtonStateIdle value) idle,
    required TResult Function(AsyncButtonStateLoading value) loading,
    required TResult Function(AsyncButtonStateSuccess value) success,
    required TResult Function(AsyncButtonStateError value) error,
  }) {
    return loading(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(AsyncButtonStateIdle value)? idle,
    TResult? Function(AsyncButtonStateLoading value)? loading,
    TResult? Function(AsyncButtonStateSuccess value)? success,
    TResult? Function(AsyncButtonStateError value)? error,
  }) {
    return loading?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(AsyncButtonStateIdle value)? idle,
    TResult Function(AsyncButtonStateLoading value)? loading,
    TResult Function(AsyncButtonStateSuccess value)? success,
    TResult Function(AsyncButtonStateError value)? error,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading(this);
    }
    return orElse();
  }
}

abstract class AsyncButtonStateLoading implements AsyncButtonState {
  const factory AsyncButtonStateLoading() = _$AsyncButtonStateLoadingImpl;
}

/// @nodoc
abstract class _$$AsyncButtonStateSuccessImplCopyWith<$Res> {
  factory _$$AsyncButtonStateSuccessImplCopyWith(
          _$AsyncButtonStateSuccessImpl value,
          $Res Function(_$AsyncButtonStateSuccessImpl) then) =
      __$$AsyncButtonStateSuccessImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$AsyncButtonStateSuccessImplCopyWithImpl<$Res>
    extends _$AsyncButtonStateCopyWithImpl<$Res, _$AsyncButtonStateSuccessImpl>
    implements _$$AsyncButtonStateSuccessImplCopyWith<$Res> {
  __$$AsyncButtonStateSuccessImplCopyWithImpl(
      _$AsyncButtonStateSuccessImpl _value,
      $Res Function(_$AsyncButtonStateSuccessImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$AsyncButtonStateSuccessImpl implements AsyncButtonStateSuccess {
  const _$AsyncButtonStateSuccessImpl();

  @override
  String toString() {
    return 'AsyncButtonState.success()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AsyncButtonStateSuccessImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() idle,
    required TResult Function() loading,
    required TResult Function() success,
    required TResult Function(Object error) error,
  }) {
    return success();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? idle,
    TResult? Function()? loading,
    TResult? Function()? success,
    TResult? Function(Object error)? error,
  }) {
    return success?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? idle,
    TResult Function()? loading,
    TResult Function()? success,
    TResult Function(Object error)? error,
    required TResult orElse(),
  }) {
    if (success != null) {
      return success();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(AsyncButtonStateIdle value) idle,
    required TResult Function(AsyncButtonStateLoading value) loading,
    required TResult Function(AsyncButtonStateSuccess value) success,
    required TResult Function(AsyncButtonStateError value) error,
  }) {
    return success(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(AsyncButtonStateIdle value)? idle,
    TResult? Function(AsyncButtonStateLoading value)? loading,
    TResult? Function(AsyncButtonStateSuccess value)? success,
    TResult? Function(AsyncButtonStateError value)? error,
  }) {
    return success?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(AsyncButtonStateIdle value)? idle,
    TResult Function(AsyncButtonStateLoading value)? loading,
    TResult Function(AsyncButtonStateSuccess value)? success,
    TResult Function(AsyncButtonStateError value)? error,
    required TResult orElse(),
  }) {
    if (success != null) {
      return success(this);
    }
    return orElse();
  }
}

abstract class AsyncButtonStateSuccess implements AsyncButtonState {
  const factory AsyncButtonStateSuccess() = _$AsyncButtonStateSuccessImpl;
}

/// @nodoc
abstract class _$$AsyncButtonStateErrorImplCopyWith<$Res> {
  factory _$$AsyncButtonStateErrorImplCopyWith(
          _$AsyncButtonStateErrorImpl value,
          $Res Function(_$AsyncButtonStateErrorImpl) then) =
      __$$AsyncButtonStateErrorImplCopyWithImpl<$Res>;
  @useResult
  $Res call({Object error});
}

/// @nodoc
class __$$AsyncButtonStateErrorImplCopyWithImpl<$Res>
    extends _$AsyncButtonStateCopyWithImpl<$Res, _$AsyncButtonStateErrorImpl>
    implements _$$AsyncButtonStateErrorImplCopyWith<$Res> {
  __$$AsyncButtonStateErrorImplCopyWithImpl(_$AsyncButtonStateErrorImpl _value,
      $Res Function(_$AsyncButtonStateErrorImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? error = null,
  }) {
    return _then(_$AsyncButtonStateErrorImpl(
      null == error ? _value.error : error,
    ));
  }
}

/// @nodoc

class _$AsyncButtonStateErrorImpl implements AsyncButtonStateError {
  const _$AsyncButtonStateErrorImpl(this.error);

  @override
  final Object error;

  @override
  String toString() {
    return 'AsyncButtonState.error(error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AsyncButtonStateErrorImpl &&
            const DeepCollectionEquality().equals(other.error, error));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(error));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AsyncButtonStateErrorImplCopyWith<_$AsyncButtonStateErrorImpl>
      get copyWith => __$$AsyncButtonStateErrorImplCopyWithImpl<
          _$AsyncButtonStateErrorImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() idle,
    required TResult Function() loading,
    required TResult Function() success,
    required TResult Function(Object error) error,
  }) {
    return error(this.error);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? idle,
    TResult? Function()? loading,
    TResult? Function()? success,
    TResult? Function(Object error)? error,
  }) {
    return error?.call(this.error);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? idle,
    TResult Function()? loading,
    TResult Function()? success,
    TResult Function(Object error)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this.error);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(AsyncButtonStateIdle value) idle,
    required TResult Function(AsyncButtonStateLoading value) loading,
    required TResult Function(AsyncButtonStateSuccess value) success,
    required TResult Function(AsyncButtonStateError value) error,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(AsyncButtonStateIdle value)? idle,
    TResult? Function(AsyncButtonStateLoading value)? loading,
    TResult? Function(AsyncButtonStateSuccess value)? success,
    TResult? Function(AsyncButtonStateError value)? error,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(AsyncButtonStateIdle value)? idle,
    TResult Function(AsyncButtonStateLoading value)? loading,
    TResult Function(AsyncButtonStateSuccess value)? success,
    TResult Function(AsyncButtonStateError value)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class AsyncButtonStateError implements AsyncButtonState {
  const factory AsyncButtonStateError(final Object error) =
      _$AsyncButtonStateErrorImpl;

  Object get error;
  @JsonKey(ignore: true)
  _$$AsyncButtonStateErrorImplCopyWith<_$AsyncButtonStateErrorImpl>
      get copyWith => throw _privateConstructorUsedError;
}
