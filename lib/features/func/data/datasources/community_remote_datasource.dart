import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import 'package:resq/features/func/data/models/message_model.dart';

abstract class CommunityRemoteDataSource {
  Stream<List<MessageModel>> streamMessages();
  Future<void> sendMessage(MessageModel message);
  Future<void> deleteMessage(String messageId);
}

@LazySingleton(as: CommunityRemoteDataSource)
class CommunityRemoteDataSourceImpl implements CommunityRemoteDataSource {
  final FirebaseFirestore firestore;
  static const String _collectionName = 'community_messages';

  CommunityRemoteDataSourceImpl(this.firestore);

  @override
  Stream<List<MessageModel>> streamMessages() {
    try {
      return firestore
          .collection(_collectionName)
          .orderBy('timestamp', descending: true)
          .limit(100) // Limit to last 100 messages for performance
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => MessageModel.fromFirestore(doc))
            .toList();
      });
    } catch (e) {
      throw Exception('Failed to stream messages from Firestore: $e');
    }
  }

  @override
  Future<void> sendMessage(MessageModel message) async {
    try {
      await firestore.collection(_collectionName).add(message.toFirestore());
    } catch (e) {
      throw Exception('Failed to send message to Firestore: $e');
    }
  }

  @override
  Future<void> deleteMessage(String messageId) async {
    try {
      await firestore.collection(_collectionName).doc(messageId).delete();
    } catch (e) {
      throw Exception('Failed to delete message from Firestore: $e');
    }
  }
}

