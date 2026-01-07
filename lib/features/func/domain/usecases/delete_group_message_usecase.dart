import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:resq/core/error/failures.dart';
import 'package:resq/features/func/domain/repositories/group_repository.dart';

@injectable
class DeleteGroupMessageUseCase {
  final GroupRepository repository;

  DeleteGroupMessageUseCase(this.repository);

  Future<Either<Failure, Unit>> call({
    required String groupId,
    required String messageId,
    required String userId,
  }) async {
    if (groupId.isEmpty || messageId.isEmpty || userId.isEmpty) {
      return const Left(Failure.validation('Group ID, Message ID, and User ID are required'));
    }
    return await repository.deleteGroupMessage(
      groupId: groupId,
      messageId: messageId,
      userId: userId,
    );
  }
}

