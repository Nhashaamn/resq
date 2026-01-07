import 'package:freezed_annotation/freezed_annotation.dart';

part 'emergency_contact.freezed.dart';

@freezed
class EmergencyContact with _$EmergencyContact {
  const factory EmergencyContact({
    required String name,
    required String phoneNumber,
  }) = _EmergencyContact;
}

