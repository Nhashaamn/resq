import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:resq/core/error/failures.dart';
import 'package:resq/features/auth/domain/repositories/auth_repository.dart';

@injectable
class ForgotPasswordUseCase {
  final AuthRepository repository;

  ForgotPasswordUseCase(this.repository);

  Future<Either<Failure, Unit>> call(String email) async {
    if (email.isEmpty) {
      return const Left(Failure.validation('Email is required'));
    }
    if (!email.contains('@')) {
      return const Left(Failure.validation('Please enter a valid email'));
    }
    return await repository.sendPasswordResetEmail(email);
  }
}

