// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'emergency_number.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$EmergencyNumber {
  String get phoneNumber => throw _privateConstructorUsedError;
  String get email => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $EmergencyNumberCopyWith<EmergencyNumber> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EmergencyNumberCopyWith<$Res> {
  factory $EmergencyNumberCopyWith(
          EmergencyNumber value, $Res Function(EmergencyNumber) then) =
      _$EmergencyNumberCopyWithImpl<$Res, EmergencyNumber>;
  @useResult
  $Res call({String phoneNumber, String email, DateTime updatedAt});
}

/// @nodoc
class _$EmergencyNumberCopyWithImpl<$Res, $Val extends EmergencyNumber>
    implements $EmergencyNumberCopyWith<$Res> {
  _$EmergencyNumberCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? phoneNumber = null,
    Object? email = null,
    Object? updatedAt = null,
  }) {
    return _then(_value.copyWith(
      phoneNumber: null == phoneNumber
          ? _value.phoneNumber
          : phoneNumber // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$EmergencyNumberImplCopyWith<$Res>
    implements $EmergencyNumberCopyWith<$Res> {
  factory _$$EmergencyNumberImplCopyWith(_$EmergencyNumberImpl value,
          $Res Function(_$EmergencyNumberImpl) then) =
      __$$EmergencyNumberImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String phoneNumber, String email, DateTime updatedAt});
}

/// @nodoc
class __$$EmergencyNumberImplCopyWithImpl<$Res>
    extends _$EmergencyNumberCopyWithImpl<$Res, _$EmergencyNumberImpl>
    implements _$$EmergencyNumberImplCopyWith<$Res> {
  __$$EmergencyNumberImplCopyWithImpl(
      _$EmergencyNumberImpl _value, $Res Function(_$EmergencyNumberImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? phoneNumber = null,
    Object? email = null,
    Object? updatedAt = null,
  }) {
    return _then(_$EmergencyNumberImpl(
      phoneNumber: null == phoneNumber
          ? _value.phoneNumber
          : phoneNumber // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc

class _$EmergencyNumberImpl implements _EmergencyNumber {
  const _$EmergencyNumberImpl(
      {required this.phoneNumber,
      required this.email,
      required this.updatedAt});

  @override
  final String phoneNumber;
  @override
  final String email;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'EmergencyNumber(phoneNumber: $phoneNumber, email: $email, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EmergencyNumberImpl &&
            (identical(other.phoneNumber, phoneNumber) ||
                other.phoneNumber == phoneNumber) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @override
  int get hashCode => Object.hash(runtimeType, phoneNumber, email, updatedAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$EmergencyNumberImplCopyWith<_$EmergencyNumberImpl> get copyWith =>
      __$$EmergencyNumberImplCopyWithImpl<_$EmergencyNumberImpl>(
          this, _$identity);
}

abstract class _EmergencyNumber implements EmergencyNumber {
  const factory _EmergencyNumber(
      {required final String phoneNumber,
      required final String email,
      required final DateTime updatedAt}) = _$EmergencyNumberImpl;

  @override
  String get phoneNumber;
  @override
  String get email;
  @override
  DateTime get updatedAt;
  @override
  @JsonKey(ignore: true)
  _$$EmergencyNumberImplCopyWith<_$EmergencyNumberImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
