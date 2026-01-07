import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:resq/features/func/domain/entities/group.dart';

class GroupModel {
  final String id;
  final String name;
  final String createdBy;
  final String createdByName;
  final DateTime createdAt;
  final List<String> memberIds;
  final String inviteCode;
  final String? description;
  final String? imageUrl;

  GroupModel({
    required this.id,
    required this.name,
    required this.createdBy,
    required this.createdByName,
    required this.createdAt,
    required this.memberIds,
    required this.inviteCode,
    this.description,
    this.imageUrl,
  });

  Group toDomain() {
    return Group(
      id: id,
      name: name,
      createdBy: createdBy,
      createdByName: createdByName,
      createdAt: createdAt,
      memberIds: memberIds,
      inviteCode: inviteCode,
      description: description,
      imageUrl: imageUrl,
    );
  }

  factory GroupModel.fromDomain(Group group) {
    return GroupModel(
      id: group.id,
      name: group.name,
      createdBy: group.createdBy,
      createdByName: group.createdByName,
      createdAt: group.createdAt,
      memberIds: group.memberIds,
      inviteCode: group.inviteCode,
      description: group.description,
      imageUrl: group.imageUrl,
    );
  }

  factory GroupModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return GroupModel(
      id: doc.id,
      name: data['name'] as String,
      createdBy: data['createdBy'] as String,
      createdByName: data['createdByName'] as String,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      memberIds: List<String>.from(data['memberIds'] as List),
      inviteCode: data['inviteCode'] as String,
      description: data['description'] as String?,
      imageUrl: data['imageUrl'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    final map = <String, dynamic>{
      'name': name,
      'createdBy': createdBy,
      'createdByName': createdByName,
      'createdAt': Timestamp.fromDate(createdAt),
      'memberIds': memberIds,
      'inviteCode': inviteCode,
    };

    if (description != null) {
      map['description'] = description!;
    }
    if (imageUrl != null) {
      map['imageUrl'] = imageUrl!;
    }

    return map;
  }
}

