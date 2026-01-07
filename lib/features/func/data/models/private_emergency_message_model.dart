import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:resq/features/func/domain/entities/private_emergency_message.dart';

class PrivateEmergencyMessageModel {
  final String id;
  final String fromUserId;
  final String fromUserName;
  final String toEmail;
  final String toPhoneNumber;
  final String message;
  final DateTime timestamp;
  final bool isRead;

  PrivateEmergencyMessageModel({
    required this.id,
    required this.fromUserId,
    required this.fromUserName,
    required this.toEmail,
    required this.toPhoneNumber,
    required this.message,
    required this.timestamp,
    this.isRead = false,
  });

  PrivateEmergencyMessage toDomain() {
    return PrivateEmergencyMessage(
      id: id,
      fromUserId: fromUserId,
      fromUserName: fromUserName,
      toEmail: toEmail,
      toPhoneNumber: toPhoneNumber,
      message: message,
      timestamp: timestamp,
      isRead: isRead,
    );
  }

  factory PrivateEmergencyMessageModel.fromDomain(PrivateEmergencyMessage message) {
    return PrivateEmergencyMessageModel(
      id: message.id,
      fromUserId: message.fromUserId,
      fromUserName: message.fromUserName,
      toEmail: message.toEmail,
      toPhoneNumber: message.toPhoneNumber,
      message: message.message,
      timestamp: message.timestamp,
      isRead: message.isRead,
    );
  }

  factory PrivateEmergencyMessageModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PrivateEmergencyMessageModel(
      id: doc.id,
      fromUserId: data['fromUserId'] as String,
      fromUserName: data['fromUserName'] as String,
      toEmail: data['toEmail'] as String,
      toPhoneNumber: data['toPhoneNumber'] as String,
      message: data['message'] as String,
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      isRead: (data['isRead'] as bool?) ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'fromUserId': fromUserId,
      'fromUserName': fromUserName,
      'toEmail': toEmail,
      'toPhoneNumber': toPhoneNumber,
      'message': message,
      'timestamp': Timestamp.fromDate(timestamp),
      'isRead': isRead,
    };
  }
}

