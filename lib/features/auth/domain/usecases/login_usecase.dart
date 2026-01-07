import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:resq/core/error/failures.dart';
import 'package:resq/features/auth/domain/entities/user.dart' as domain;
import 'package:resq/features/auth/domain/repositories/auth_repository.dart';

@injectable
class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<Either<Failure, domain.User>> call(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      return const Left(Failure.validation('Email and password are required'));
    }
    if (!email.contains('@')) {
      return const Left(Failure.validation('Please enter a valid email'));
    }
    return await repository.login(email, password);
  }
}

