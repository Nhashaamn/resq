import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import 'package:resq/features/func/data/models/safe_zone_model.dart';

abstract class SafeZoneRemoteDataSource {
  Stream<List<SafeZoneModel>> streamZones();
  Future<void> saveZone(SafeZoneModel zone);
  Future<void> deleteZone(String zoneId);
  Future<void> deleteExpiredZones();
}

@LazySingleton(as: SafeZoneRemoteDataSource)
class SafeZoneRemoteDataSourceImpl implements SafeZoneRemoteDataSource {
  final FirebaseFirestore firestore;
  static const String _collectionName = 'safe_zones';

  SafeZoneRemoteDataSourceImpl(this.firestore);

  @override
  Stream<List<SafeZoneModel>> streamZones() {
    try {
      return firestore
          .collection(_collectionName)
          .where('expiresAt', isGreaterThan: Timestamp.now())
          .orderBy('expiresAt')
          .snapshots()
          .map((snapshot) {
        final zones = snapshot.docs
            .map((doc) => SafeZoneModel.fromFirestore(doc))
            .toList();
        // Sort by createdAt descending in memory to avoid composite index
        zones.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return zones;
      });
    } catch (e) {
      throw Exception('Failed to stream zones from Firestore: $e');
    }
  }

  @override
  Future<void> saveZone(SafeZoneModel zone) async {
    try {
      await firestore.collection(_collectionName).add(zone.toFirestore());
    } catch (e) {
      throw Exception('Failed to save zone to Firestore: $e');
    }
  }

  @override
  Future<void> deleteZone(String zoneId) async {
    try {
      await firestore.collection(_collectionName).doc(zoneId).delete();
    } catch (e) {
      throw Exception('Failed to delete zone from Firestore: $e');
    }
  }

  @override
  Future<void> deleteExpiredZones() async {
    try {
      final now = Timestamp.now();
      final expiredZones = await firestore
          .collection(_collectionName)
          .where('expiresAt', isLessThanOrEqualTo: now)
          .get();
      
      final batch = firestore.batch();
      for (var doc in expiredZones.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to delete expired zones: $e');
    }
  }
}

