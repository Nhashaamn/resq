import 'package:freezed_annotation/freezed_annotation.dart';

part 'group_member.freezed.dart';

@freezed
class GroupMember with _$GroupMember {
  const factory GroupMember({
    required String userId,
    required String userName,
    required String userEmail,
    required DateTime joinedAt,
    String? role, // 'admin' or 'member'
  }) = _GroupMember;
}

