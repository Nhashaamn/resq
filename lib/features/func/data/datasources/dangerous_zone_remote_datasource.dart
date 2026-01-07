import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import 'package:resq/features/func/data/models/dangerous_zone_model.dart';

abstract class DangerousZoneRemoteDataSource {
  Stream<List<DangerousZoneModel>> streamZones();
  Future<void> saveZone(DangerousZoneModel zone);
  Future<void> deleteZone(String zoneId);
  Future<void> deleteExpiredZones();
}

@LazySingleton(as: DangerousZoneRemoteDataSource)
class DangerousZoneRemoteDataSourceImpl implements DangerousZoneRemoteDataSource {
  final FirebaseFirestore firestore;
  static const String _collectionName = 'dangerous_zones';

  DangerousZoneRemoteDataSourceImpl(this.firestore);

  @override
  Stream<List<DangerousZoneModel>> streamZones() {
    try {
      return firestore
          .collection(_collectionName)
          .where('expiresAt', isGreaterThan: Timestamp.now())
          .orderBy('expiresAt')
          .snapshots()
          .map((snapshot) {
        final zones = snapshot.docs
            .map((doc) => DangerousZoneModel.fromFirestore(doc))
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
  Future<void> saveZone(DangerousZoneModel zone) async {
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

