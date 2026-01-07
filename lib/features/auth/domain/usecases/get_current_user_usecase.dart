import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:resq/core/error/failures.dart';
import 'package:resq/features/auth/domain/entities/user.dart' as domain;
import 'package:resq/features/auth/domain/repositories/auth_repository.dart';

@injectable
class GetCurrentUserUseCase {
  final AuthRepository repository;

  GetCurrentUserUseCase(this.repository);

  Future<Either<Failure, domain.User?>> call() => repository.getCurrentUser();
}

