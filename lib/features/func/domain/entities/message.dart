import 'package:freezed_annotation/freezed_annotation.dart';

part 'message.freezed.dart';

@freezed
class Message with _$Message {
  const factory Message({
    required String id,
    required String userId,
    required String userName,
    required String text,
    required DateTime timestamp,
    String? replyToMessageId,
    String? replyToUserName,
    String? replyToText,
  }) = _Message;
}

