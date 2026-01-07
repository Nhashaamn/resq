import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resq/core/di/injection.dart';
import 'package:resq/core/error/failures.dart';
import 'package:resq/features/auth/presentation/providers/auth_provider.dart';
import 'package:resq/features/func/domain/entities/group.dart';
import 'package:resq/features/func/domain/entities/group_message.dart';
import 'package:resq/features/func/domain/usecases/add_member_to_group_usecase.dart';
import 'package:resq/features/func/domain/usecases/create_group_usecase.dart';
import 'package:resq/features/func/domain/usecases/delete_group_message_usecase.dart';
import 'package:resq/features/func/domain/usecases/get_user_groups_usecase.dart';
import 'package:resq/features/func/domain/usecases/join_group_usecase.dart';
import 'package:resq/features/func/domain/usecases/leave_group_usecase.dart';
import 'package:resq/features/func/domain/usecases/send_group_message_usecase.dart';
import 'package:resq/features/func/domain/usecases/stream_group_messages_usecase.dart';

final createGroupUseCaseProvider = Provider((ref) => getIt<CreateGroupUseCase>());
final joinGroupUseCaseProvider = Provider((ref) => getIt<JoinGroupUseCase>());
final getUserGroupsUseCaseProvider = Provider((ref) => getIt<GetUserGroupsUseCase>());
final sendGroupMessageUseCaseProvider = Provider((ref) => getIt<SendGroupMessageUseCase>());
final streamGroupMessagesUseCaseProvider = Provider((ref) => getIt<StreamGroupMessagesUseCase>());
final deleteGroupMessageUseCaseProvider = Provider((ref) => getIt<DeleteGroupMessageUseCase>());
final addMemberToGroupUseCaseProvider = Provider((ref) => getIt<AddMemberToGroupUseCase>());
final leaveGroupUseCaseProvider = Provider((ref) => getIt<LeaveGroupUseCase>());

final groupProvider = StateNotifierProvider<GroupNotifier, GroupState>(
  (ref) {
    final notifier = GroupNotifier(
      ref,
      ref.read(createGroupUseCaseProvider),
      ref.read(joinGroupUseCaseProvider),
      ref.read(getUserGroupsUseCaseProvider),
      ref.read(sendGroupMessageUseCaseProvider),
      ref.read(streamGroupMessagesUseCaseProvider),
      ref.read(deleteGroupMessageUseCaseProvider),
      ref.read(addMemberToGroupUseCaseProvider),
      ref.read(leaveGroupUseCaseProvider),
    );
    return notifier;
  },
);

class GroupState {
  final List<Group> groups;
  final List<GroupMessage> messages;
  final bool isLoading;
  final Failure? error;
  final bool isCreating;
  final bool isJoining;
  final bool isSending;
  final GroupMessage? replyingToMessage;
  final String? selectedGroupId;

  GroupState({
    this.groups = const [],
    this.messages = const [],
    this.isLoading = false,
    this.error,
    this.isCreating = false,
    this.isJoining = false,
    this.isSending = false,
    this.replyingToMessage,
    this.selectedGroupId,
  });

  GroupState copyWith({
    List<Group>? groups,
    List<GroupMessage>? messages,
    bool? isLoading,
    Failure? error,
    bool? isCreating,
    bool? isJoining,
    bool? isSending,
    GroupMessage? replyingToMessage,
    String? selectedGroupId,
  }) {
    return GroupState(
      groups: groups ?? this.groups,
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isCreating: isCreating ?? this.isCreating,
      isJoining: isJoining ?? this.isJoining,
      isSending: isSending ?? this.isSending,
      replyingToMessage: replyingToMessage,
      selectedGroupId: selectedGroupId ?? this.selectedGroupId,
    );
  }
}

class GroupNotifier extends StateNotifier<GroupState> {
  final Ref ref;
  final CreateGroupUseCase createGroupUseCase;
  final JoinGroupUseCase joinGroupUseCase;
  final GetUserGroupsUseCase getUserGroupsUseCase;
  final SendGroupMessageUseCase sendGroupMessageUseCase;
  final StreamGroupMessagesUseCase streamGroupMessagesUseCase;
  final DeleteGroupMessageUseCase deleteGroupMessageUseCase;
  final AddMemberToGroupUseCase addMemberToGroupUseCase;
  final LeaveGroupUseCase leaveGroupUseCase;

  GroupNotifier(
    this.ref,
    this.createGroupUseCase,
    this.joinGroupUseCase,
    this.getUserGroupsUseCase,
    this.sendGroupMessageUseCase,
    this.streamGroupMessagesUseCase,
    this.deleteGroupMessageUseCase,
    this.addMemberToGroupUseCase,
    this.leaveGroupUseCase,
  ) : super(GroupState()) {
    _listenToGroups();
  }

  String? get _userId {
    final authState = ref.read(authStateProvider);
    return authState.user?.id;
  }

  String? get _userName {
    final authState = ref.read(authStateProvider);
    return authState.user?.name ?? authState.user?.email ?? 'Anonymous';
  }

  String get _userEmail {
    final authState = ref.read(authStateProvider);
    return authState.user?.email ?? '';
  }

  void _listenToGroups() {
    final userId = _userId;
    if (userId == null) return;

    state = state.copyWith(isLoading: true);
    getUserGroupsUseCase(userId).listen(
      (result) {
        result.fold(
          (failure) {
            state = state.copyWith(
              isLoading: false,
              error: failure,
            );
          },
          (groups) {
            state = state.copyWith(
              groups: groups,
              isLoading: false,
              error: null,
            );
          },
        );
      },
      onError: (error) {
        state = state.copyWith(
          isLoading: false,
          error: Failure.server(error.toString()),
        );
      },
    );
  }

  void listenToGroupMessages(String groupId) {
    state = state.copyWith(selectedGroupId: groupId);
    streamGroupMessagesUseCase(groupId).listen(
      (result) {
        result.fold(
          (failure) {
            state = state.copyWith(error: failure);
          },
          (messages) {
            state = state.copyWith(
              messages: messages,
              error: null,
            );
          },
        );
      },
      onError: (error) {
        state = state.copyWith(
          error: Failure.server(error.toString()),
        );
      },
    );
  }

  void setReplyingToMessage(GroupMessage? message) {
    state = state.copyWith(replyingToMessage: message);
  }

  void clearReply() {
    state = state.copyWith(replyingToMessage: null);
  }

  Future<bool> createGroup({
    required String name,
    String? description,
  }) async {
    final userId = _userId;
    final userName = _userName;

    if (userId == null || userId.isEmpty || userName == null || userName.isEmpty) {
      state = state.copyWith(
        error: const Failure.auth('User not authenticated'),
      );
      return false;
    }

    state = state.copyWith(isCreating: true, error: null);

    final result = await createGroupUseCase(
      name: name,
      createdBy: userId,
      createdByName: userName,
      description: description,
    );

    return result.fold(
      (failure) {
        state = state.copyWith(
          isCreating: false,
          error: failure,
        );
        return false;
      },
      (_) {
        state = state.copyWith(isCreating: false);
        return true;
      },
    );
  }

  Future<bool> joinGroup(String inviteCode) async {
    final userId = _userId;
    final userName = _userName;
    final userEmail = _userEmail;

    if (userId == null || userId.isEmpty || userName == null || userName.isEmpty) {
      state = state.copyWith(
        error: const Failure.auth('User not authenticated'),
      );
      return false;
    }

    state = state.copyWith(isJoining: true, error: null);

    final result = await joinGroupUseCase(
      inviteCode: inviteCode,
      userId: userId,
      userName: userName,
      userEmail: userEmail,
    );

    return result.fold(
      (failure) {
        state = state.copyWith(
          isJoining: false,
          error: failure,
        );
        return false;
      },
      (_) {
        state = state.copyWith(isJoining: false);
        return true;
      },
    );
  }

  Future<bool> sendGroupMessage(String groupId, String text) async {
    final userId = _userId;
    final userName = _userName;

    if (userId == null || userId.isEmpty || userName == null || userName.isEmpty) {
      state = state.copyWith(
        error: const Failure.auth('User not authenticated'),
      );
      return false;
    }

    state = state.copyWith(isSending: true, error: null);

    final replyToMessageId = state.replyingToMessage?.id;
    final replyToUserName = state.replyingToMessage?.userName;
    final replyToText = state.replyingToMessage?.text;

    final result = await sendGroupMessageUseCase(
      groupId: groupId,
      userId: userId,
      userName: userName,
      text: text,
      replyToMessageId: replyToMessageId,
      replyToUserName: replyToUserName,
      replyToText: replyToText,
    );

    return result.fold(
      (failure) {
        state = state.copyWith(
          isSending: false,
          error: failure,
        );
        return false;
      },
      (_) {
        state = state.copyWith(
          isSending: false,
          replyingToMessage: null,
        );
        return true;
      },
    );
  }

  Future<bool> deleteGroupMessage(String groupId, String messageId) async {
    final userId = _userId;

    if (userId == null || userId.isEmpty) {
      state = state.copyWith(
        error: const Failure.auth('User not authenticated'),
      );
      return false;
    }

    state = state.copyWith(error: null);

    final result = await deleteGroupMessageUseCase(
      groupId: groupId,
      messageId: messageId,
      userId: userId,
    );

    return result.fold(
      (failure) {
        state = state.copyWith(error: failure);
        return false;
      },
      (_) {
        return true;
      },
    );
  }

  Future<bool> leaveGroup(String groupId) async {
    final userId = _userId;

    if (userId == null || userId.isEmpty) {
      state = state.copyWith(
        error: const Failure.auth('User not authenticated'),
      );
      return false;
    }

    state = state.copyWith(error: null);

    final result = await leaveGroupUseCase(
      groupId: groupId,
      userId: userId,
    );

    return result.fold(
      (failure) {
        state = state.copyWith(error: failure);
        return false;
      },
      (_) {
        return true;
      },
    );
  }
}

