// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'group_message.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$GroupMessage {
  String get id => throw _privateConstructorUsedError;
  String get groupId => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get userName => throw _privateConstructorUsedError;
  String get text => throw _privateConstructorUsedError;
  DateTime get timestamp => throw _privateConstructorUsedError;
  String? get replyToMessageId => throw _privateConstructorUsedError;
  String? get replyToUserName => throw _privateConstructorUsedError;
  String? get replyToText => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $GroupMessageCopyWith<GroupMessage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GroupMessageCopyWith<$Res> {
  factory $GroupMessageCopyWith(
          GroupMessage value, $Res Function(GroupMessage) then) =
      _$GroupMessageCopyWithImpl<$Res, GroupMessage>;
  @useResult
  $Res call(
      {String id,
      String groupId,
      String userId,
      String userName,
      String text,
      DateTime timestamp,
      String? replyToMessageId,
      String? replyToUserName,
      String? replyToText});
}

/// @nodoc
class _$GroupMessageCopyWithImpl<$Res, $Val extends GroupMessage>
    implements $GroupMessageCopyWith<$Res> {
  _$GroupMessageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? groupId = null,
    Object? userId = null,
    Object? userName = null,
    Object? text = null,
    Object? timestamp = null,
    Object? replyToMessageId = freezed,
    Object? replyToUserName = freezed,
    Object? replyToText = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      groupId: null == groupId
          ? _value.groupId
          : groupId // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      userName: null == userName
          ? _value.userName
          : userName // ignore: cast_nullable_to_non_nullable
              as String,
      text: null == text
          ? _value.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      replyToMessageId: freezed == replyToMessageId
          ? _value.replyToMessageId
          : replyToMessageId // ignore: cast_nullable_to_non_nullable
              as String?,
      replyToUserName: freezed == replyToUserName
          ? _value.replyToUserName
          : replyToUserName // ignore: cast_nullable_to_non_nullable
              as String?,
      replyToText: freezed == replyToText
          ? _value.replyToText
          : replyToText // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$GroupMessageImplCopyWith<$Res>
    implements $GroupMessageCopyWith<$Res> {
  factory _$$GroupMessageImplCopyWith(
          _$GroupMessageImpl value, $Res Function(_$GroupMessageImpl) then) =
      __$$GroupMessageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String groupId,
      String userId,
      String userName,
      String text,
      DateTime timestamp,
      String? replyToMessageId,
      String? replyToUserName,
      String? replyToText});
}

/// @nodoc
class __$$GroupMessageImplCopyWithImpl<$Res>
    extends _$GroupMessageCopyWithImpl<$Res, _$GroupMessageImpl>
    implements _$$GroupMessageImplCopyWith<$Res> {
  __$$GroupMessageImplCopyWithImpl(
      _$GroupMessageImpl _value, $Res Function(_$GroupMessageImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? groupId = null,
    Object? userId = null,
    Object? userName = null,
    Object? text = null,
    Object? timestamp = null,
    Object? replyToMessageId = freezed,
    Object? replyToUserName = freezed,
    Object? replyToText = freezed,
  }) {
    return _then(_$GroupMessageImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      groupId: null == groupId
          ? _value.groupId
          : groupId // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      userName: null == userName
          ? _value.userName
          : userName // ignore: cast_nullable_to_non_nullable
              as String,
      text: null == text
          ? _value.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      replyToMessageId: freezed == replyToMessageId
          ? _value.replyToMessageId
          : replyToMessageId // ignore: cast_nullable_to_non_nullable
              as String?,
      replyToUserName: freezed == replyToUserName
          ? _value.replyToUserName
          : replyToUserName // ignore: cast_nullable_to_non_nullable
              as String?,
      replyToText: freezed == replyToText
          ? _value.replyToText
          : replyToText // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$GroupMessageImpl implements _GroupMessage {
  const _$GroupMessageImpl(
      {required this.id,
      required this.groupId,
      required this.userId,
      required this.userName,
      required this.text,
      required this.timestamp,
      this.replyToMessageId,
      this.replyToUserName,
      this.replyToText});

  @override
  final String id;
  @override
  final String groupId;
  @override
  final String userId;
  @override
  final String userName;
  @override
  final String text;
  @override
  final DateTime timestamp;
  @override
  final String? replyToMessageId;
  @override
  final String? replyToUserName;
  @override
  final String? replyToText;

  @override
  String toString() {
    return 'GroupMessage(id: $id, groupId: $groupId, userId: $userId, userName: $userName, text: $text, timestamp: $timestamp, replyToMessageId: $replyToMessageId, replyToUserName: $replyToUserName, replyToText: $replyToText)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GroupMessageImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.groupId, groupId) || other.groupId == groupId) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.userName, userName) ||
                other.userName == userName) &&
            (identical(other.text, text) || other.text == text) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.replyToMessageId, replyToMessageId) ||
                other.replyToMessageId == replyToMessageId) &&
            (identical(other.replyToUserName, replyToUserName) ||
                other.replyToUserName == replyToUserName) &&
            (identical(other.replyToText, replyToText) ||
                other.replyToText == replyToText));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, groupId, userId, userName,
      text, timestamp, replyToMessageId, replyToUserName, replyToText);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$GroupMessageImplCopyWith<_$GroupMessageImpl> get copyWith =>
      __$$GroupMessageImplCopyWithImpl<_$GroupMessageImpl>(this, _$identity);
}

abstract class _GroupMessage implements GroupMessage {
  const factory _GroupMessage(
      {required final String id,
      required final String groupId,
      required final String userId,
      required final String userName,
      required final String text,
      required final DateTime timestamp,
      final String? replyToMessageId,
      final String? replyToUserName,
      final String? replyToText}) = _$GroupMessageImpl;

  @override
  String get id;
  @override
  String get groupId;
  @override
  String get userId;
  @override
  String get userName;
  @override
  String get text;
  @override
  DateTime get timestamp;
  @override
  String? get replyToMessageId;
  @override
  String? get replyToUserName;
  @override
  String? get replyToText;
  @override
  @JsonKey(ignore: true)
  _$$GroupMessageImplCopyWith<_$GroupMessageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
