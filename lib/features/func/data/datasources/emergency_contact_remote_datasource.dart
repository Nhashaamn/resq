import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import 'package:resq/features/func/data/models/emergency_contact_model.dart';

abstract class EmergencyContactRemoteDataSource {
  Future<List<EmergencyContactModel>> getEmergencyContacts(String userId);
  Future<void> addEmergencyContact(String userId, EmergencyContactModel contact);
  Future<void> updateEmergencyContact(String userId, String contactId, EmergencyContactModel contact);
  Future<void> deleteEmergencyContact(String userId, String contactId);
  Future<void> deleteAllEmergencyContacts(String userId);
}

@LazySingleton(as: EmergencyContactRemoteDataSource)
class EmergencyContactRemoteDataSourceImpl
    implements EmergencyContactRemoteDataSource {
  final FirebaseFirestore firestore;
  static const String _collectionName = 'emergency_contacts';

  EmergencyContactRemoteDataSourceImpl(this.firestore);

  String _getUserContactsPath(String userId) {
    return 'users/$userId/$_collectionName';
  }

  @override
  Future<List<EmergencyContactModel>> getEmergencyContacts(String userId) async {
    try {
      final snapshot = await firestore
          .collection(_getUserContactsPath(userId))
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => EmergencyContactModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get emergency contacts from Firestore: $e');
    }
  }

  @override
  Future<void> addEmergencyContact(String userId, EmergencyContactModel contact) async {
    try {
      final contactsRef = firestore.collection(_getUserContactsPath(userId));
      
      // Check if user already has 5 contacts
      final snapshot = await contactsRef.get();
      if (snapshot.docs.length >= 5) {
        throw Exception('Maximum 5 emergency contacts allowed');
      }

      await contactsRef.add({
        'name': contact.name,
        'phoneNumber': contact.phoneNumber,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to add emergency contact to Firestore: $e');
    }
  }

  @override
  Future<void> updateEmergencyContact(
    String userId,
    String contactId,
    EmergencyContactModel contact,
  ) async {
    try {
      await firestore
          .collection(_getUserContactsPath(userId))
          .doc(contactId)
          .update({
        'name': contact.name,
        'phoneNumber': contact.phoneNumber,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update emergency contact in Firestore: $e');
    }
  }

  @override
  Future<void> deleteEmergencyContact(String userId, String contactId) async {
    try {
      await firestore
          .collection(_getUserContactsPath(userId))
          .doc(contactId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete emergency contact from Firestore: $e');
    }
  }

  @override
  Future<void> deleteAllEmergencyContacts(String userId) async {
    try {
      final batch = firestore.batch();
      final snapshot = await firestore
          .collection(_getUserContactsPath(userId))
          .get();

      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to delete all emergency contacts from Firestore: $e');
    }
  }
}

