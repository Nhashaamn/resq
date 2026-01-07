import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resq/core/di/injection.dart';
import 'package:resq/core/error/failures.dart';
import 'package:resq/features/auth/presentation/providers/auth_provider.dart';
import 'package:resq/features/func/domain/entities/emergency_contact.dart';
import 'package:resq/features/func/domain/usecases/delete_emergency_contact_usecase.dart';
import 'package:resq/features/func/domain/usecases/get_emergency_contact_usecase.dart';
import 'package:resq/features/func/domain/usecases/save_emergency_contact_usecase.dart';

final emergencyContactsProvider =
    StateNotifierProvider<EmergencyContactsNotifier, EmergencyContactsState>(
  (ref) {
    final notifier = EmergencyContactsNotifier(
      ref,
      getIt<GetEmergencyContactsUseCase>(),
      getIt<AddEmergencyContactUseCase>(),
      getIt<DeleteEmergencyContactUseCase>(),
    );
    
    // Reload contacts when auth state changes (user login/logout)
    ref.listen<AuthState>(authStateProvider, (previous, next) {
      if (previous?.user?.email != next.user?.email) {
        notifier.loadEmergencyContacts();
      }
    });
    
    return notifier;
  },
);

class EmergencyContactsState {
  final List<EmergencyContact> contacts;
  final bool isLoading;
  final Failure? error;

  EmergencyContactsState({
    this.contacts = const [],
    this.isLoading = false,
    this.error,
  });

  EmergencyContactsState copyWith({
    List<EmergencyContact>? contacts,
    bool? isLoading,
    Failure? error,
  }) {
    return EmergencyContactsState(
      contacts: contacts ?? this.contacts,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class EmergencyContactsNotifier extends StateNotifier<EmergencyContactsState> {
  final Ref ref;
  final GetEmergencyContactsUseCase getEmergencyContactsUseCase;
  final AddEmergencyContactUseCase addEmergencyContactUseCase;
  final DeleteEmergencyContactUseCase deleteEmergencyContactUseCase;

  EmergencyContactsNotifier(
    this.ref,
    this.getEmergencyContactsUseCase,
    this.addEmergencyContactUseCase,
    this.deleteEmergencyContactUseCase,
  ) : super(EmergencyContactsState()) {
    loadEmergencyContacts();
  }

  String? get _userEmail {
    final authState = ref.read(authStateProvider);
    return authState.user?.email;
  }

  String? get _userId {
    final authState = ref.read(authStateProvider);
    return authState.user?.id;
  }

  Future<void> loadEmergencyContacts() async {
    final userId = _userId;
    final userEmail = _userEmail;
    if (userId == null || userId.isEmpty || userEmail == null || userEmail.isEmpty) {
      state = state.copyWith(
        contacts: [],
        isLoading: false,
        error: null,
      );
      return;
    }

    state = state.copyWith(isLoading: true, error: null);
    final result = await getEmergencyContactsUseCase(userId);
    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure,
      ),
      (contacts) => state = state.copyWith(
        contacts: contacts,
        isLoading: false,
        error: null,
      ),
    );
  }

  Future<bool> addEmergencyContact(String name, String phoneNumber) async {
    final userId = _userId;
    final userEmail = _userEmail;
    if (userId == null || userId.isEmpty || userEmail == null || userEmail.isEmpty) {
      state = state.copyWith(
        isLoading: false,
        error: const Failure.auth('User not authenticated'),
      );
      return false;
    }

    state = state.copyWith(isLoading: true, error: null);
    final result = await addEmergencyContactUseCase(userId, name, phoneNumber);
    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure);
        return false;
      },
      (_) {
        loadEmergencyContacts(); // Reload to get all contacts
        return true;
      },
    );
  }

  Future<bool> deleteEmergencyContact(int index) async {
    final userId = _userId;
    final userEmail = _userEmail;
    if (userId == null || userId.isEmpty || userEmail == null || userEmail.isEmpty) {
      state = state.copyWith(
        isLoading: false,
        error: const Failure.auth('User not authenticated'),
      );
      return false;
    }

    state = state.copyWith(isLoading: true, error: null);
    final result = await deleteEmergencyContactUseCase(userId, index);
    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure);
        return false;
      },
      (_) {
        loadEmergencyContacts(); // Reload to get updated list
        return true;
      },
    );
  }
}

