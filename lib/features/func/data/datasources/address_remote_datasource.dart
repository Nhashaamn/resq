import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import 'package:resq/features/func/data/models/address_model.dart';

abstract class AddressRemoteDataSource {
  Future<AddressModel?> getAddress(String userId);
  Future<void> saveAddress(String userId, AddressModel address);
}

@LazySingleton(as: AddressRemoteDataSource)
class AddressRemoteDataSourceImpl implements AddressRemoteDataSource {
  final FirebaseFirestore firestore;

  AddressRemoteDataSourceImpl(this.firestore);

  @override
  Future<AddressModel?> getAddress(String userId) async {
    try {
      final doc = await firestore.collection('users').doc(userId).get();
      if (!doc.exists) {
        return null;
      }
      final data = doc.data();
      if (data == null || !data.containsKey('address')) {
        return null;
      }
      return AddressModel.fromFirestore(data['address'] as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to get address: $e');
    }
  }

  @override
  Future<void> saveAddress(String userId, AddressModel address) async {
    try {
      await firestore.collection('users').doc(userId).set(
        {
          'address': address.toFirestore(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    } catch (e) {
      throw Exception('Failed to save address: $e');
    }
  }
}

