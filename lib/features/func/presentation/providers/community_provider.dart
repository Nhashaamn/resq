import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resq/core/di/injection.dart';
import 'package:resq/core/error/failures.dart';
import 'package:resq/features/auth/presentation/providers/auth_provider.dart';
import 'package:resq/features/func/domain/entities/message.dart';
import 'package:resq/features/func/domain/usecases/send_message_usecase.dart';
import 'package:resq/features/func/domain/usecases/stream_messages_usecase.dart';
import 'package:resq/features/func/domain/usecases/delete_message_usecase.dart';

final sendMessageUseCaseProvider = Provider((ref) => getIt<SendMessageUseCase>());
final streamMessagesUseCaseProvider = Provider((ref) => getIt<StreamMessagesUseCase>());
final deleteMessageUseCaseProvider = Provider((ref) => getIt<DeleteMessageUseCase>());

final communityProvider =
    StateNotifierProvider<CommunityNotifier, CommunityState>(
  (ref) {
    final notifier = CommunityNotifier(
      ref,
      ref.read(sendMessageUseCaseProvider),
      ref.read(streamMessagesUseCaseProvider),
      ref.read(deleteMessageUseCaseProvider),
    );
    return notifier;
  },
);

class CommunityState {
  final List<Message> messages;
  final bool isLoading;
  final Failure? error;
  final bool isSending;
  final Message? replyingToMessage;

  CommunityState({
    this.messages = const [],
    this.isLoading = false,
    this.error,
    this.isSending = false,
    this.replyingToMessage,
  });

  CommunityState copyWith({
    List<Message>? messages,
    bool? isLoading,
    Failure? error,
    bool? isSending,
    Message? replyingToMessage,
  }) {
    return CommunityState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isSending: isSending ?? this.isSending,
      replyingToMessage: replyingToMessage,
    );
  }
}

class CommunityNotifier extends StateNotifier<CommunityState> {
  final Ref ref;
  final SendMessageUseCase sendMessageUseCase;
  final StreamMessagesUseCase streamMessagesUseCase;
  final DeleteMessageUseCase deleteMessageUseCase;

  CommunityNotifier(
    this.ref,
    this.sendMessageUseCase,
    this.streamMessagesUseCase,
    this.deleteMessageUseCase,
  ) : super(CommunityState()) {
    _listenToMessages();
  }

  String? get _userId {
    final authState = ref.read(authStateProvider);
    return authState.user?.id;
  }

  String? get _userName {
    final authState = ref.read(authStateProvider);
    return authState.user?.name ?? authState.user?.email ?? 'Anonymous';
  }

  void _listenToMessages() {
    state = state.copyWith(isLoading: true);
    streamMessagesUseCase().listen(
      (result) {
        result.fold(
          (failure) {
            state = state.copyWith(
              isLoading: false,
              error: failure,
            );
          },
          (messages) {
            state = state.copyWith(
              messages: messages,
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

  void setReplyingToMessage(Message? message) {
    state = state.copyWith(replyingToMessage: message);
  }

  void clearReply() {
    state = state.copyWith(replyingToMessage: null);
  }

  Future<bool> sendMessage(String text) async {
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
    
    final result = await sendMessageUseCase(
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
          replyingToMessage: null, // Clear reply after sending
        );
        return true;
      },
    );
  }

  Future<bool> deleteMessage(String messageId) async {
    final userId = _userId;
    
    if (userId == null || userId.isEmpty) {
      state = state.copyWith(
        error: const Failure.auth('User not authenticated'),
      );
      return false;
    }

    // Verify the message belongs to the current user
    try {
      final message = state.messages.firstWhere(
        (msg) => msg.id == messageId,
      );

      if (message.userId != userId) {
        state = state.copyWith(
          error: const Failure.auth('You can only delete your own messages'),
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        error: Failure.validation('Message not found'),
      );
      return false;
    }

    state = state.copyWith(error: null);
    
    final result = await deleteMessageUseCase(messageId);

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

