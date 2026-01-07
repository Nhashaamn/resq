import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:resq/features/func/domain/entities/emergency_number.dart';

class EmergencyNumberModel {
  final String phoneNumber;
  final String email;
  final DateTime updatedAt;

  EmergencyNumberModel({
    required this.phoneNumber,
    required this.email,
    required this.updatedAt,
  });

  EmergencyNumber toDomain() {
    return EmergencyNumber(
      phoneNumber: phoneNumber,
      email: email,
      updatedAt: updatedAt,
    );
  }

  factory EmergencyNumberModel.fromDomain(EmergencyNumber emergencyNumber) {
    return EmergencyNumberModel(
      phoneNumber: emergencyNumber.phoneNumber,
      email: emergencyNumber.email,
      updatedAt: emergencyNumber.updatedAt,
    );
  }

  factory EmergencyNumberModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null || data['emergencyNumber'] == null || data['emergencyEmail'] == null) {
      // Return a model with empty values - caller should check
      return EmergencyNumberModel(
        phoneNumber: '',
        email: '',
        updatedAt: DateTime.now(),
      );
    }
    
    return EmergencyNumberModel(
      phoneNumber: data['emergencyNumber'] as String,
      email: data['emergencyEmail'] as String,
      updatedAt: (data['emergencyNumberUpdatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'emergencyNumber': phoneNumber,
      'emergencyEmail': email,
      'emergencyNumberUpdatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}

