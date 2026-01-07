import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:resq/features/func/domain/entities/message.dart';

class MessageModel {
  final String id;
  final String userId;
  final String userName;
  final String text;
  final DateTime timestamp;
  final String? replyToMessageId;
  final String? replyToUserName;
  final String? replyToText;

  MessageModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.text,
    required this.timestamp,
    this.replyToMessageId,
    this.replyToUserName,
    this.replyToText,
  });

  Message toDomain() {
    return Message(
      id: id,
      userId: userId,
      userName: userName,
      text: text,
      timestamp: timestamp,
      replyToMessageId: replyToMessageId,
      replyToUserName: replyToUserName,
      replyToText: replyToText,
    );
  }

  factory MessageModel.fromDomain(Message message) {
    return MessageModel(
      id: message.id,
      userId: message.userId,
      userName: message.userName,
      text: message.text,
      timestamp: message.timestamp,
      replyToMessageId: message.replyToMessageId,
      replyToUserName: message.replyToUserName,
      replyToText: message.replyToText,
    );
  }

  factory MessageModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MessageModel(
      id: doc.id,
      userId: data['userId'] as String,
      userName: data['userName'] as String,
      text: data['text'] as String,
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      replyToMessageId: data['replyToMessageId'] as String?,
      replyToUserName: data['replyToUserName'] as String?,
      replyToText: data['replyToText'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    final map = <String, dynamic>{
      'userId': userId,
      'userName': userName,
      'text': text,
      'timestamp': Timestamp.fromDate(timestamp),
    };
    
    if (replyToMessageId != null) {
      map['replyToMessageId'] = replyToMessageId!;
    }
    if (replyToUserName != null) {
      map['replyToUserName'] = replyToUserName!;
    }
    if (replyToText != null) {
      map['replyToText'] = replyToText!;
    }
    
    return map;
  }
}

