import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import 'package:resq/features/func/data/models/group_member_model.dart';
import 'package:resq/features/func/data/models/group_message_model.dart';
import 'package:resq/features/func/data/models/group_model.dart';
import 'package:uuid/uuid.dart';

abstract class GroupRemoteDataSource {
  Future<GroupModel> createGroup(GroupModel group);
  Future<GroupModel> joinGroup(String inviteCode, String userId, String userName, String userEmail);
  Stream<List<GroupModel>> getUserGroups(String userId);
  Future<GroupModel> getGroup(String groupId);
  Future<void> addMemberToGroup(String groupId, String userId, String userName, String userEmail);
  Future<void> removeMemberFromGroup(String groupId, String userId);
  Stream<List<GroupMessageModel>> streamGroupMessages(String groupId);
  Future<void> sendGroupMessage(GroupMessageModel message);
  Future<void> deleteGroupMessage(String groupId, String messageId);
  Future<void> leaveGroup(String groupId, String userId);
}

@LazySingleton(as: GroupRemoteDataSource)
class GroupRemoteDataSourceImpl implements GroupRemoteDataSource {
  final FirebaseFirestore firestore;
  static const String _groupsCollection = 'groups';
  static const String _messagesCollection = 'messages';
  static const String _membersCollection = 'members';
  final _uuid = const Uuid();

  GroupRemoteDataSourceImpl(this.firestore);

  String _generateInviteCode() {
    // Generate a unique 8-character invite code
    return _uuid.v4().substring(0, 8).toUpperCase();
  }

  @override
  Future<GroupModel> createGroup(GroupModel group) async {
    try {
      final inviteCode = _generateInviteCode();
      final groupData = group.toFirestore();
      groupData['inviteCode'] = inviteCode;

      final docRef = await firestore.collection(_groupsCollection).add(groupData);
      
      // Add creator as admin member
      await firestore
          .collection(_groupsCollection)
          .doc(docRef.id)
          .collection(_membersCollection)
          .doc(group.createdBy)
          .set(GroupMemberModel(
            userId: group.createdBy,
            userName: group.createdByName,
            userEmail: '', // Will be set when user joins
            joinedAt: DateTime.now(),
            role: 'admin',
          ).toFirestore());

      return GroupModel(
        id: docRef.id,
        name: group.name,
        createdBy: group.createdBy,
        createdByName: group.createdByName,
        createdAt: group.createdAt,
        memberIds: group.memberIds,
        inviteCode: inviteCode,
        description: group.description,
        imageUrl: group.imageUrl,
      );
    } catch (e) {
      throw Exception('Failed to create group: $e');
    }
  }

  @override
  Future<GroupModel> joinGroup(String inviteCode, String userId, String userName, String userEmail) async {
    try {
      // Find group by invite code
      final querySnapshot = await firestore
          .collection(_groupsCollection)
          .where('inviteCode', isEqualTo: inviteCode)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        throw Exception('Group not found with invite code: $inviteCode');
      }

      final groupDoc = querySnapshot.docs.first;
      final groupId = groupDoc.id;
      final groupData = groupDoc.data();

      // Check if user is already a member
      final memberDoc = await firestore
          .collection(_groupsCollection)
          .doc(groupId)
          .collection(_membersCollection)
          .doc(userId)
          .get();

      if (memberDoc.exists) {
        throw Exception('User is already a member of this group');
      }

      // Add user as member
      await firestore
          .collection(_groupsCollection)
          .doc(groupId)
          .collection(_membersCollection)
          .doc(userId)
          .set(GroupMemberModel(
            userId: userId,
            userName: userName,
            userEmail: userEmail,
            joinedAt: DateTime.now(),
            role: 'member',
          ).toFirestore());

      // Update group memberIds
      final memberIds = List<String>.from(groupData['memberIds'] ?? []);
      if (!memberIds.contains(userId)) {
        memberIds.add(userId);
        await firestore.collection(_groupsCollection).doc(groupId).update({
          'memberIds': memberIds,
        });
      }

      return GroupModel.fromFirestore(groupDoc);
    } catch (e) {
      throw Exception('Failed to join group: $e');
    }
  }

  @override
  Stream<List<GroupModel>> getUserGroups(String userId) {
    try {
      return firestore
          .collection(_groupsCollection)
          .where('memberIds', arrayContains: userId)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => GroupModel.fromFirestore(doc))
            .toList();
      });
    } catch (e) {
      throw Exception('Failed to stream user groups: $e');
    }
  }

  @override
  Future<GroupModel> getGroup(String groupId) async {
    try {
      final doc = await firestore.collection(_groupsCollection).doc(groupId).get();
      if (!doc.exists) {
        throw Exception('Group not found');
      }
      return GroupModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('Failed to get group: $e');
    }
  }

  @override
  Future<void> addMemberToGroup(String groupId, String userId, String userName, String userEmail) async {
    try {
      // Check if user is already a member
      final memberDoc = await firestore
          .collection(_groupsCollection)
          .doc(groupId)
          .collection(_membersCollection)
          .doc(userId)
          .get();

      if (memberDoc.exists) {
        throw Exception('User is already a member');
      }

      // Add member
      await firestore
          .collection(_groupsCollection)
          .doc(groupId)
          .collection(_membersCollection)
          .doc(userId)
          .set(GroupMemberModel(
            userId: userId,
            userName: userName,
            userEmail: userEmail,
            joinedAt: DateTime.now(),
            role: 'member',
          ).toFirestore());

      // Update group memberIds
      final groupDoc = await firestore.collection(_groupsCollection).doc(groupId).get();
      final groupData = groupDoc.data()!;
      final memberIds = List<String>.from(groupData['memberIds'] ?? []);
      if (!memberIds.contains(userId)) {
        memberIds.add(userId);
        await firestore.collection(_groupsCollection).doc(groupId).update({
          'memberIds': memberIds,
        });
      }
    } catch (e) {
      throw Exception('Failed to add member to group: $e');
    }
  }

  @override
  Future<void> removeMemberFromGroup(String groupId, String userId) async {
    try {
      // Remove member document
      await firestore
          .collection(_groupsCollection)
          .doc(groupId)
          .collection(_membersCollection)
          .doc(userId)
          .delete();

      // Update group memberIds
      final groupDoc = await firestore.collection(_groupsCollection).doc(groupId).get();
      final groupData = groupDoc.data()!;
      final memberIds = List<String>.from(groupData['memberIds'] ?? []);
      memberIds.remove(userId);
      await firestore.collection(_groupsCollection).doc(groupId).update({
        'memberIds': memberIds,
      });
    } catch (e) {
      throw Exception('Failed to remove member from group: $e');
    }
  }

  @override
  Stream<List<GroupMessageModel>> streamGroupMessages(String groupId) {
    try {
      return firestore
          .collection(_groupsCollection)
          .doc(groupId)
          .collection(_messagesCollection)
          .orderBy('timestamp', descending: true)
          .limit(100)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => GroupMessageModel.fromFirestore(doc))
            .toList();
      });
    } catch (e) {
      throw Exception('Failed to stream group messages: $e');
    }
  }

  @override
  Future<void> sendGroupMessage(GroupMessageModel message) async {
    try {
      await firestore
          .collection(_groupsCollection)
          .doc(message.groupId)
          .collection(_messagesCollection)
          .add(message.toFirestore());
    } catch (e) {
      throw Exception('Failed to send group message: $e');
    }
  }

  @override
  Future<void> deleteGroupMessage(String groupId, String messageId) async {
    try {
      await firestore
          .collection(_groupsCollection)
          .doc(groupId)
          .collection(_messagesCollection)
          .doc(messageId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete group message: $e');
    }
  }

  @override
  Future<void> leaveGroup(String groupId, String userId) async {
    await removeMemberFromGroup(groupId, userId);
  }
}

