import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:resq/core/error/failures.dart';
import 'package:resq/features/func/domain/entities/group.dart';
import 'package:resq/features/func/domain/repositories/group_repository.dart';

@injectable
class GetUserGroupsUseCase {
  final GroupRepository repository;

  GetUserGroupsUseCase(this.repository);

  Stream<Either<Failure, List<Group>>> call(String userId) {
    if (userId.isEmpty) {
      return Stream.value(const Left(Failure.validation('User ID cannot be empty')));
    }
    return repository.getUserGroups(userId);
  }
}

