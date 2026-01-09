import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:resq/core/di/injection.dart';
import 'package:resq/core/error/failures.dart';
import 'package:resq/features/auth/presentation/providers/auth_provider.dart';
import 'package:resq/features/func/domain/entities/private_emergency_message.dart';
import 'package:resq/features/func/domain/usecases/mark_private_message_read_usecase.dart';
import 'package:resq/features/func/domain/usecases/send_private_emergency_message_usecase.dart';
import 'package:resq/features/func/domain/usecases/stream_private_emergency_messages_usecase.dart';

final sendPrivateEmergencyMessageUseCaseProvider =
    Provider((ref) => getIt<SendPrivateEmergencyMessageUseCase>());
final streamPrivateEmergencyMessagesUseCaseProvider =
    Provider((ref) => getIt<StreamPrivateEmergencyMessagesUseCase>());
final markPrivateMessageReadUseCaseProvider =
    Provider((ref) => getIt<MarkPrivateMessageReadUseCase>());

final privateEmergencyMessageProvider =
    StateNotifierProvider<PrivateEmergencyMessageNotifier, PrivateEmergencyMessageState>(
  (ref) {
    final notifier = PrivateEmergencyMessageNotifier(
      ref,
      ref.read(sendPrivateEmergencyMessageUseCaseProvider),
      ref.read(streamPrivateEmergencyMessagesUseCaseProvider),
      ref.read(markPrivateMessageReadUseCaseProvider),
    );
    return notifier;
  },
);

class PrivateEmergencyMessageState {
  final List<PrivateEmergencyMessage> messages;
  final bool isLoading;
  final Failure? error;
  final bool isSending;

  PrivateEmergencyMessageState({
    this.messages = const [],
    this.isLoading = false,
    this.error,
    this.isSending = false,
  });

  PrivateEmergencyMessageState copyWith({
    List<PrivateEmergencyMessage>? messages,
    bool? isLoading,
    Failure? error,
    bool? isSending,
  }) {
    return PrivateEmergencyMessageState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isSending: isSending ?? this.isSending,
    );
  }
}

class PrivateEmergencyMessageNotifier
    extends StateNotifier<PrivateEmergencyMessageState> {
  final Ref ref;
  final SendPrivateEmergencyMessageUseCase sendPrivateEmergencyMessageUseCase;
  final StreamPrivateEmergencyMessagesUseCase streamPrivateEmergencyMessagesUseCase;
  final MarkPrivateMessageReadUseCase markPrivateMessageReadUseCase;

  PrivateEmergencyMessageNotifier(
    this.ref,
    this.sendPrivateEmergencyMessageUseCase,
    this.streamPrivateEmergencyMessagesUseCase,
    this.markPrivateMessageReadUseCase,
  ) : super(PrivateEmergencyMessageState()) {
    _listenToMessages();
    // Reload messages when auth state changes
    ref.listen<AuthState>(authStateProvider, (previous, next) {
      if (previous?.user?.email != next.user?.email) {
        _listenToMessages();
      }
    });
  }

  String? get _userEmail {
    final authState = ref.read(authStateProvider);
    return authState.user?.email;
  }

  void _listenToMessages() {
    final userEmail = _userEmail;
    if (userEmail == null) {
      state = state.copyWith(
        messages: [],
        isLoading: false,
        error: null,
      );
      return;
    }

    state = state.copyWith(isLoading: true);
    final previousMessages = Set<String>.from(state.messages.map((m) => m.id));
    
    streamPrivateEmergencyMessagesUseCase(userEmail).listen(
      (result) {
        result.fold(
          (failure) {
            state = state.copyWith(
              isLoading: false,
              error: failure,
            );
          },
          (messages) {
            // Update previous messages set
            previousMessages.clear();
            previousMessages.addAll(messages.map((m) => m.id));
            
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

  Future<bool> sendPrivateEmergencyMessage({
    required String toEmail,
    required String toPhoneNumber,
    required String message,
  }) async {
    final authState = ref.read(authStateProvider);
    final userId = authState.user?.id;
    final userName = authState.user?.name ?? authState.user?.email ?? 'Unknown User';

    if (userId == null) {
      state = state.copyWith(
        error: const Failure.auth('User not authenticated'),
      );
      return false;
    }

    state = state.copyWith(isSending: true, error: null);

    // Get current location
    double? latitude;
    double? longitude;
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (serviceEnabled) {
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }
        if (permission == LocationPermission.whileInUse || 
            permission == LocationPermission.always) {
          Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
          );
          latitude = position.latitude;
          longitude = position.longitude;
        }
      }
    } catch (e) {
      // Location is optional, continue without it
    }

    final result = await sendPrivateEmergencyMessageUseCase(
      fromUserId: userId,
      fromUserName: userName,
      toEmail: toEmail,
      toPhoneNumber: toPhoneNumber,
      message: message,
      latitude: latitude,
      longitude: longitude,
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
        state = state.copyWith(isSending: false);
        return true;
      },
    );
  }

  Future<bool> markAsRead(String messageId) async {
    final result = await markPrivateMessageReadUseCase(messageId);
    return result.fold(
      (failure) {
        state = state.copyWith(error: failure);
        return false;
      },
      (_) {
        // Update local state
        final updatedMessages = state.messages.map((msg) {
          if (msg.id == messageId) {
            return msg.copyWith(isRead: true);
          }
          return msg;
        }).toList();
        state = state.copyWith(messages: updatedMessages);
        return true;
      },
    );
  }
}

