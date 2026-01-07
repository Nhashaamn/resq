import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import 'package:resq/features/func/data/models/emergency_number_model.dart';

abstract class EmergencyNumberRemoteDataSource {
  Future<EmergencyNumberModel?> getEmergencyNumber(String userId);
  Future<void> setEmergencyNumber(String userId, EmergencyNumberModel emergencyNumber);
  Future<void> clearEmergencyNumber(String userId);
}

@LazySingleton(as: EmergencyNumberRemoteDataSource)
class EmergencyNumberRemoteDataSourceImpl implements EmergencyNumberRemoteDataSource {
  final FirebaseFirestore firestore;
  static const String _usersCollection = 'users';

  EmergencyNumberRemoteDataSourceImpl(this.firestore);

  @override
  Future<EmergencyNumberModel?> getEmergencyNumber(String userId) async {
    try {
      final doc = await firestore.collection(_usersCollection).doc(userId).get();
      
      if (!doc.exists) {
        return null;
      }
      
      final data = doc.data();
      if (data == null || data['emergencyNumber'] == null || data['emergencyEmail'] == null) {
        return null;
      }
      
      final model = EmergencyNumberModel.fromFirestore(doc);
      // Return null if phone number or email is empty (not set)
      if (model.phoneNumber.isEmpty || model.email.isEmpty) {
        return null;
      }
      return model;
    } catch (e) {
      throw Exception('Failed to get emergency number from Firestore: $e');
    }
  }

  @override
  Future<void> setEmergencyNumber(String userId, EmergencyNumberModel emergencyNumber) async {
    try {
      await firestore.collection(_usersCollection).doc(userId).set(
        emergencyNumber.toFirestore(),
        SetOptions(merge: true),
      );
    } catch (e) {
      throw Exception('Failed to set emergency number in Firestore: $e');
    }
  }

  @override
  Future<void> clearEmergencyNumber(String userId) async {
    try {
      await firestore.collection(_usersCollection).doc(userId).update({
        'emergencyNumber': FieldValue.delete(),
        'emergencyEmail': FieldValue.delete(),
        'emergencyNumberUpdatedAt': FieldValue.delete(),
      });
    } catch (e) {
      throw Exception('Failed to clear emergency number from Firestore: $e');
    }
  }
}

