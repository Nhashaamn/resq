import 'package:freezed_annotation/freezed_annotation.dart';

part 'emergency_number.freezed.dart';

@freezed
class EmergencyNumber with _$EmergencyNumber {
  const factory EmergencyNumber({
    required String phoneNumber,
    required String email,
    required DateTime updatedAt,
  }) = _EmergencyNumber;
}

