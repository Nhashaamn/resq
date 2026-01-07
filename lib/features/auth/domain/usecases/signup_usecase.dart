import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:resq/core/error/failures.dart';
import 'package:resq/features/auth/domain/entities/user.dart' as domain;
import 'package:resq/features/auth/domain/repositories/auth_repository.dart';

@injectable
class SignupUseCase {
  final AuthRepository repository;

  SignupUseCase(this.repository);

  Future<Either<Failure, domain.User>> call(String name, String email, String password) async {
    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      return const Left(Failure.validation('All fields are required'));
    }
    if (!email.contains('@')) {
      return const Left(Failure.validation('Please enter a valid email'));
    }
    if (password.length < 6) {
      return const Left(Failure.validation('Password must be at least 6 characters'));
    }
    
    // Check if email already exists
    final emailCheck = await repository.checkEmailExists(email);
    return emailCheck.fold(
      (failure) => Left(failure),
      (exists) async {
        if (exists) {
          return const Left(Failure.validation('This email is already registered'));
        }
        return await repository.signup(name, email, password);
      },
    );
  }
}

