import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:resq/core/error/failures.dart';
import 'package:resq/features/func/domain/repositories/group_repository.dart';

@injectable
class AddMemberToGroupUseCase {
  final GroupRepository repository;

  AddMemberToGroupUseCase(this.repository);

  Future<Either<Failure, Unit>> call({
    required String groupId,
    required String userId,
    required String userName,
    required String userEmail,
  }) async {
    if (groupId.isEmpty || userId.isEmpty || userName.isEmpty || userEmail.isEmpty) {
      return const Left(Failure.validation('All fields are required'));
    }
    return await repository.addMemberToGroup(
      groupId: groupId,
      userId: userId,
      userName: userName,
      userEmail: userEmail,
    );
  }
}

