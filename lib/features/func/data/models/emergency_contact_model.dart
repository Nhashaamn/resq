import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import 'package:resq/features/func/domain/entities/emergency_contact.dart';

part 'emergency_contact_model.g.dart';

@HiveType(typeId: 0)
class EmergencyContactModel extends HiveObject {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final String phoneNumber;

  // Firestore document ID (not stored in Hive)
  final String? id;

  EmergencyContactModel({
    required this.name,
    required this.phoneNumber,
    this.id,
  });

  EmergencyContact toDomain() {
    return EmergencyContact(
      name: name,
      phoneNumber: phoneNumber,
    );
  }

  factory EmergencyContactModel.fromDomain(EmergencyContact contact, {String? id}) {
    return EmergencyContactModel(
      name: contact.name,
      phoneNumber: contact.phoneNumber,
      id: id,
    );
  }

  // Create from Firestore document
  factory EmergencyContactModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return EmergencyContactModel(
      id: doc.id,
      name: data['name'] as String,
      phoneNumber: data['phoneNumber'] as String,
    );
  }

  // Convert to Firestore map (excluding id)
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'phoneNumber': phoneNumber,
    };
  }
}
