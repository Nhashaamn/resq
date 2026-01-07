import 'package:freezed_annotation/freezed_annotation.dart';

part 'group.freezed.dart';

@freezed
class Group with _$Group {
  const factory Group({
    required String id,
    required String name,
    required String createdBy,
    required String createdByName,
    required DateTime createdAt,
    required List<String> memberIds,
    required String inviteCode,
    String? description,
    String? imageUrl,
  }) = _Group;
}

