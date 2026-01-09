import 'package:freezed_annotation/freezed_annotation.dart';

part 'private_emergency_message.freezed.dart';

@freezed
class PrivateEmergencyMessage with _$PrivateEmergencyMessage {
  const factory PrivateEmergencyMessage({
    required String id,
    required String fromUserId,
    required String fromUserName,
    required String toEmail,
    required String toPhoneNumber,
    required String message,
    required DateTime timestamp,
    @Default(false) bool isRead,
    double? latitude,
    double? longitude,
  }) = _PrivateEmergencyMessage;
}

