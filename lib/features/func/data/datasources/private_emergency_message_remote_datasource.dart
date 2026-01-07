import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import 'package:resq/features/func/data/models/private_emergency_message_model.dart';

abstract class PrivateEmergencyMessageRemoteDataSource {
  Future<void> sendPrivateEmergencyMessage(PrivateEmergencyMessageModel message);
  Stream<List<PrivateEmergencyMessageModel>> streamPrivateEmergencyMessages(String userEmail);
  Future<void> markAsRead(String messageId);
}

@LazySingleton(as: PrivateEmergencyMessageRemoteDataSource)
class PrivateEmergencyMessageRemoteDataSourceImpl
    implements PrivateEmergencyMessageRemoteDataSource {
  final FirebaseFirestore firestore;
  static const String _collectionName = 'private_emergency_messages';

  PrivateEmergencyMessageRemoteDataSourceImpl(this.firestore);

  @override
  Future<void> sendPrivateEmergencyMessage(PrivateEmergencyMessageModel message) async {
    try {
      await firestore.collection(_collectionName).add(message.toFirestore());
    } catch (e) {
      throw Exception('Failed to send private emergency message: $e');
    }
  }

  @override
  Stream<List<PrivateEmergencyMessageModel>> streamPrivateEmergencyMessages(String userEmail) {
    try {
      return firestore
          .collection(_collectionName)
          .where('toEmail', isEqualTo: userEmail)
          .orderBy('timestamp', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => PrivateEmergencyMessageModel.fromFirestore(doc))
            .toList();
      });
    } catch (e) {
      throw Exception('Failed to stream private emergency messages: $e');
    }
  }

  @override
  Future<void> markAsRead(String messageId) async {
    try {
      await firestore.collection(_collectionName).doc(messageId).update({
        'isRead': true,
      });
    } catch (e) {
      throw Exception('Failed to mark message as read: $e');
    }
  }
}

