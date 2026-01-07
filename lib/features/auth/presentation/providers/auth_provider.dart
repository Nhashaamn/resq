import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resq/core/di/injection.dart';
import 'package:resq/features/auth/domain/entities/user.dart' as domain;
import 'package:resq/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:resq/features/auth/domain/usecases/google_sign_in_usecase.dart';
import 'package:resq/features/auth/domain/usecases/login_usecase.dart';
import 'package:resq/features/auth/domain/usecases/logout_usecase.dart';
import 'package:resq/features/auth/domain/usecases/send_phone_otp_usecase.dart';
import 'package:resq/features/auth/domain/usecases/signup_usecase.dart';
import 'package:resq/features/auth/domain/usecases/verify_phone_otp_usecase.dart';

final loginUseCaseProvider = Provider((ref) => getIt<LoginUseCase>());
final signupUseCaseProvider = Provider((ref) => getIt<SignupUseCase>());
final sendPhoneOtpUseCaseProvider = Provider((ref) => getIt<SendPhoneOtpUseCase>());
final verifyPhoneOtpUseCaseProvider = Provider((ref) => getIt<VerifyPhoneOtpUseCase>());
final googleSignInUseCaseProvider = Provider((ref) => getIt<GoogleSignInUseCase>());
final getCurrentUserUseCaseProvider = Provider((ref) => getIt<GetCurrentUserUseCase>());
final logoutUseCaseProvider = Provider((ref) => getIt<LogoutUseCase>());

final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    ref.read(getCurrentUserUseCaseProvider),
    ref.read(logoutUseCaseProvider),
  );
});

class AuthState {
  final domain.User? user;
  final bool isLoading;
  final String? error;

  AuthState({
    this.user,
    this.isLoading = false,
    this.error,
  });

  bool get isAuthenticated => user != null;
}

class AuthNotifier extends StateNotifier<AuthState> {
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final LogoutUseCase _logoutUseCase;

  AuthNotifier(this._getCurrentUserUseCase, this._logoutUseCase)
      : super(AuthState()) {
    // Use postFrameCallback to avoid modifying provider during build
    Future.microtask(() => checkAuth());
  }

  Future<void> checkAuth() async {
    state = AuthState(isLoading: true);
    final result = await _getCurrentUserUseCase();
    result.fold(
      (failure) => state = AuthState(error: failure.when(
        server: (msg) => msg,
        network: (msg) => msg,
        cache: (msg) => msg,
        validation: (msg) => msg,
        auth: (msg) => msg,
      )),
      (user) => state = AuthState(user: user),
    );
  }

  Future<void> logout() async {
    state = AuthState(isLoading: true);
    final result = await _logoutUseCase();
    result.fold(
      (failure) => state = AuthState(error: failure.when(
        server: (msg) => msg,
        network: (msg) => msg,
        cache: (msg) => msg,
        validation: (msg) => msg,
        auth: (msg) => msg,
      )),
      (_) => state = AuthState(),
    );
  }
}// Login Form Provider
final loginFormProvider =
    StateNotifierProvider<LoginFormNotifier, LoginFormState>(
  (ref) => LoginFormNotifier(ref),
);

class LoginFormNotifier extends StateNotifier<LoginFormState> {
  final Ref ref;

  LoginFormNotifier(this.ref) : super(const LoginFormState());

  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    final loginUseCase = ref.read(loginUseCaseProvider);
    final result = await loginUseCase(email, password);

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.when(
            server: (msg) => msg,
            network: (msg) => msg,
            cache: (msg) => msg,
            validation: (msg) => msg,
            auth: (msg) => msg,
          ),
        );
      },
      (_) async {
        await ref.read(authStateProvider.notifier).checkAuth();
        state = state.copyWith(isLoading: false, success: true);
      },
    );
  }
}

class LoginFormState {
  final bool isLoading;
  final bool success;
  final String? error;

  const LoginFormState({
    this.isLoading = false,
    this.success = false,
    this.error,
  });

  LoginFormState copyWith({
    bool? isLoading,
    bool? success,
    String? error,
  }) {
    return LoginFormState(
      isLoading: isLoading ?? this.isLoading,
      success: success ?? this.success,
      error: error,
    );
  }
}

