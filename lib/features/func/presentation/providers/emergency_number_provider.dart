import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resq/core/di/injection.dart';
import 'package:resq/core/error/failures.dart';
import 'package:resq/features/auth/presentation/providers/auth_provider.dart';
import 'package:resq/features/func/domain/entities/emergency_number.dart';
import 'package:resq/features/func/domain/usecases/clear_emergency_number_usecase.dart';
import 'package:resq/features/func/domain/usecases/get_emergency_number_usecase.dart';
import 'package:resq/features/func/domain/usecases/set_emergency_number_usecase.dart';

final getEmergencyNumberUseCaseProvider = Provider((ref) => getIt<GetEmergencyNumberUseCase>());
final setEmergencyNumberUseCaseProvider = Provider((ref) => getIt<SetEmergencyNumberUseCase>());
final clearEmergencyNumberUseCaseProvider = Provider((ref) => getIt<ClearEmergencyNumberUseCase>());

final emergencyNumberProvider =
    StateNotifierProvider<EmergencyNumberNotifier, EmergencyNumberState>(
  (ref) {
    final notifier = EmergencyNumberNotifier(
      ref,
      ref.read(getEmergencyNumberUseCaseProvider),
      ref.read(setEmergencyNumberUseCaseProvider),
      ref.read(clearEmergencyNumberUseCaseProvider),
    );
    
    // Reload emergency number when auth state changes (user login/logout)
    ref.listen<AuthState>(authStateProvider, (previous, next) {
      if (previous?.user?.id != next.user?.id) {
        notifier._loadEmergencyNumber();
      }
    });
    
    return notifier;
  },
);

class EmergencyNumberState {
  final EmergencyNumber? emergencyNumber;
  final bool isLoading;
  final Failure? error;

  EmergencyNumberState({
    this.emergencyNumber,
    this.isLoading = false,
    this.error,
  });

  EmergencyNumberState copyWith({
    EmergencyNumber? emergencyNumber,
    bool? isLoading,
    Failure? error,
  }) {
    return EmergencyNumberState(
      emergencyNumber: emergencyNumber ?? this.emergencyNumber,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class EmergencyNumberNotifier extends StateNotifier<EmergencyNumberState> {
  final Ref ref;
  final GetEmergencyNumberUseCase getEmergencyNumberUseCase;
  final SetEmergencyNumberUseCase setEmergencyNumberUseCase;
  final ClearEmergencyNumberUseCase clearEmergencyNumberUseCase;

  EmergencyNumberNotifier(
    this.ref,
    this.getEmergencyNumberUseCase,
    this.setEmergencyNumberUseCase,
    this.clearEmergencyNumberUseCase,
  ) : super(EmergencyNumberState()) {
    _loadEmergencyNumber();
  }

  String? get _userId {
    final authState = ref.read(authStateProvider);
    return authState.user?.id;
  }

  void _loadEmergencyNumber() {
    Future.microtask(() async {
      final userId = _userId;
      if (userId == null) {
        state = state.copyWith(
          emergencyNumber: null,
          isLoading: false,
          error: null,
        );
        return;
      }

      state = state.copyWith(isLoading: true, error: null);

      final result = await getEmergencyNumberUseCase(userId);

      result.fold(
        (failure) {
          state = state.copyWith(
            isLoading: false,
            error: failure,
          );
        },
        (emergencyNumber) {
          state = state.copyWith(
            emergencyNumber: emergencyNumber,
            isLoading: false,
            error: null,
          );
        },
      );
    });
  }

  Future<bool> setEmergencyNumber(String phoneNumber, String email) async {
    final userId = _userId;
    if (userId == null) {
      state = state.copyWith(
        error: const Failure.auth('User not authenticated'),
      );
      return false;
    }

    state = state.copyWith(isLoading: true, error: null);

    final result = await setEmergencyNumberUseCase(
      userId: userId,
      phoneNumber: phoneNumber,
      email: email,
    );

    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure,
        );
        return false;
      },
      (_) {
        _loadEmergencyNumber(); // Reload to get updated number
        return true;
      },
    );
  }

  Future<bool> clearEmergencyNumber() async {
    final userId = _userId;
    if (userId == null) {
      state = state.copyWith(
        error: const Failure.auth('User not authenticated'),
      );
      return false;
    }

    state = state.copyWith(isLoading: true, error: null);

    final result = await clearEmergencyNumberUseCase(userId);

    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure,
        );
        return false;
      },
      (_) {
        state = state.copyWith(
          emergencyNumber: null,
          isLoading: false,
          error: null,
        );
        return true;
      },
    );
  }
}

