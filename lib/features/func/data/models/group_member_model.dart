import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:resq/features/func/domain/entities/group_member.dart';

class GroupMemberModel {
  final String userId;
  final String userName;
  final String userEmail;
  final DateTime joinedAt;
  final String? role;

  GroupMemberModel({
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.joinedAt,
    this.role,
  });

  GroupMember toDomain() {
    return GroupMember(
      userId: userId,
      userName: userName,
      userEmail: userEmail,
      joinedAt: joinedAt,
      role: role,
    );
  }

  factory GroupMemberModel.fromDomain(GroupMember member) {
    return GroupMemberModel(
      userId: member.userId,
      userName: member.userName,
      userEmail: member.userEmail,
      joinedAt: member.joinedAt,
      role: member.role,
    );
  }

  factory GroupMemberModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return GroupMemberModel(
      userId: doc.id,
      userName: data['userName'] as String,
      userEmail: data['userEmail'] as String,
      joinedAt: (data['joinedAt'] as Timestamp).toDate(),
      role: data['role'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    final map = <String, dynamic>{
      'userName': userName,
      'userEmail': userEmail,
      'joinedAt': Timestamp.fromDate(joinedAt),
    };

    if (role != null) {
      map['role'] = role!;
    }

    return map;
  }
}

