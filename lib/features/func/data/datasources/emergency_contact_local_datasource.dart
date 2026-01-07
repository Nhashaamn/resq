import 'package:hive_flutter/hive_flutter.dart';
import 'package:injectable/injectable.dart';
import 'package:resq/features/func/data/models/emergency_contact_model.dart';

abstract class EmergencyContactLocalDataSource {
  Future<List<EmergencyContactModel>> getEmergencyContacts(String userId);
  Future<void> addEmergencyContact(String userId, EmergencyContactModel contact);
  Future<void> deleteEmergencyContact(String userId, int index);
  Future<void> deleteAllEmergencyContacts(String userId);
}

@LazySingleton(as: EmergencyContactLocalDataSource)
class EmergencyContactLocalDataSourceImpl
    implements EmergencyContactLocalDataSource {
  static const String _boxName = 'emergency_contacts_box';

  String _getListKey(String userId) {
    return 'emergency_contacts_list_${userId.replaceAll(RegExp(r'[^\w]'), '_')}';
  }

  Future<Box> get _box async {
    if (!Hive.isBoxOpen(_boxName)) {
      return await Hive.openBox(_boxName);
    }
    return Hive.box(_boxName);
  }

  @override
  Future<List<EmergencyContactModel>> getEmergencyContacts(String userId) async {
    try {
      final box = await _box;
      final listKey = _getListKey(userId);
      final List<dynamic>? contactsList = box.get(listKey);
      if (contactsList == null) {
        return [];
      }
      return contactsList.cast<EmergencyContactModel>().toList();
    } catch (e) {
      throw Exception('Failed to get emergency contacts: $e');
    }
  }

  @override
  Future<void> addEmergencyContact(String userId, EmergencyContactModel contact) async {
    try {
      final box = await _box;
      final listKey = _getListKey(userId);
      final List<dynamic>? contactsList = box.get(listKey);
      final List<EmergencyContactModel> contacts =
          contactsList?.cast<EmergencyContactModel>().toList() ?? [];
      
      // Add new contact at the beginning
      contacts.insert(0, contact);
      
      // Keep only the latest 5 contacts
      if (contacts.length > 5) {
        contacts.removeRange(5, contacts.length);
      }
      
      await box.put(listKey, contacts);
    } catch (e) {
      throw Exception('Failed to add emergency contact: $e');
    }
  }

  @override
  Future<void> deleteEmergencyContact(String userId, int index) async {
    try {
      final box = await _box;
      final listKey = _getListKey(userId);
      final List<dynamic>? contactsList = box.get(listKey);
      if (contactsList == null || index < 0 || index >= contactsList.length) {
        return;
      }
      final List<EmergencyContactModel> contacts =
          contactsList.cast<EmergencyContactModel>().toList();
      contacts.removeAt(index);
      await box.put(listKey, contacts);
    } catch (e) {
      throw Exception('Failed to delete emergency contact: $e');
    }
  }

  @override
  Future<void> deleteAllEmergencyContacts(String userId) async {
    try {
      final box = await _box;
      final listKey = _getListKey(userId);
      await box.delete(listKey);
    } catch (e) {
      throw Exception('Failed to delete all emergency contacts: $e');
    }
  }
}

