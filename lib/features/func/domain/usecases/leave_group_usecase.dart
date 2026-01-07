import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:resq/core/error/failures.dart';
import 'package:resq/features/func/domain/repositories/group_repository.dart';

@injectable
class LeaveGroupUseCase {
  final GroupRepository repository;

  LeaveGroupUseCase(this.repository);

  Future<Either<Failure, Unit>> call({
    required String groupId,
    required String userId,
  }) async {
    if (groupId.isEmpty || userId.isEmpty) {
      return const Left(Failure.validation('Group ID and User ID are required'));
    }
    return await repository.leaveGroup(
      groupId: groupId,
      userId: userId,
    );
  }
}

