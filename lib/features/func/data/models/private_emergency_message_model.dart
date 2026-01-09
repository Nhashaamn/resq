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
  final double? latitude;
  final double? longitude;

  PrivateEmergencyMessageModel({
    required this.id,
    required this.fromUserId,
    required this.fromUserName,
    required this.toEmail,
    required this.toPhoneNumber,
    required this.message,
    required this.timestamp,
    this.isRead = false,
    this.latitude,
    this.longitude,
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
      latitude: latitude,
      longitude: longitude,
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
      latitude: message.latitude,
      longitude: message.longitude,
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
      latitude: (data['latitude'] as num?)?.toDouble(),
      longitude: (data['longitude'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toFirestore() {
    final map = <String, dynamic>{
      'fromUserId': fromUserId,
      'fromUserName': fromUserName,
      'toEmail': toEmail,
      'toPhoneNumber': toPhoneNumber,
      'message': message,
      'timestamp': Timestamp.fromDate(timestamp),
      'isRead': isRead,
    };
    if (latitude != null) {
      map['latitude'] = latitude!;
    }
    if (longitude != null) {
      map['longitude'] = longitude!;
    }
    return map;
  }
}

