import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:resq/core/error/failures.dart';
import 'package:resq/features/func/domain/entities/group.dart';
import 'package:resq/features/func/domain/repositories/group_repository.dart';

@injectable
class JoinGroupUseCase {
  final GroupRepository repository;

  JoinGroupUseCase(this.repository);

  Future<Either<Failure, Group>> call({
    required String inviteCode,
    required String userId,
    required String userName,
    required String userEmail,
  }) async {
    if (inviteCode.trim().isEmpty) {
      return const Left(Failure.validation('Invite code cannot be empty'));
    }
    if (inviteCode.trim().length != 8) {
      return const Left(Failure.validation('Invalid invite code format'));
    }
    return await repository.joinGroup(
      inviteCode: inviteCode.trim().toUpperCase(),
      userId: userId,
      userName: userName,
      userEmail: userEmail,
    );
  }
}

