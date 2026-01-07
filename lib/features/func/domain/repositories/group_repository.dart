import 'package:dartz/dartz.dart';
import 'package:resq/core/error/failures.dart';
import 'package:resq/features/func/domain/entities/group.dart';
import 'package:resq/features/func/domain/entities/group_message.dart';

abstract class GroupRepository {
  /// Create a new group
  Future<Either<Failure, Group>> createGroup({
    required String name,
    required String createdBy,
    required String createdByName,
    String? description,
  });

  /// Join a group using invite code
  Future<Either<Failure, Group>> joinGroup({
    required String inviteCode,
    required String userId,
    required String userName,
    required String userEmail,
  });

  /// Get all groups for a user
  Stream<Either<Failure, List<Group>>> getUserGroups(String userId);

  /// Get a specific group by ID
  Future<Either<Failure, Group>> getGroup(String groupId);

  /// Add a member to a group
  Future<Either<Failure, Unit>> addMemberToGroup({
    required String groupId,
    required String userId,
    required String userName,
    required String userEmail,
  });

  /// Remove a member from a group
  Future<Either<Failure, Unit>> removeMemberFromGroup({
    required String groupId,
    required String userId,
  });

  /// Stream messages for a group
  Stream<Either<Failure, List<GroupMessage>>> streamGroupMessages(String groupId);

  /// Send a message to a group
  Future<Either<Failure, Unit>> sendGroupMessage({
    required String groupId,
    required String userId,
    required String userName,
    required String text,
    String? replyToMessageId,
    String? replyToUserName,
    String? replyToText,
  });

  /// Delete a group message
  Future<Either<Failure, Unit>> deleteGroupMessage({
    required String groupId,
    required String messageId,
    required String userId,
  });

  /// Leave a group
  Future<Either<Failure, Unit>> leaveGroup({
    required String groupId,
    required String userId,
  });
}

