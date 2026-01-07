import 'package:freezed_annotation/freezed_annotation.dart';

part 'group_message.freezed.dart';

@freezed
class GroupMessage with _$GroupMessage {
  const factory GroupMessage({
    required String id,
    required String groupId,
    required String userId,
    required String userName,
    required String text,
    required DateTime timestamp,
    String? replyToMessageId,
    String? replyToUserName,
    String? replyToText,
  }) = _GroupMessage;
}

