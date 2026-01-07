import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:resq/core/error/failures.dart';
import 'package:resq/features/func/domain/entities/group.dart';
import 'package:resq/features/func/domain/repositories/group_repository.dart';

@injectable
class CreateGroupUseCase {
  final GroupRepository repository;

  CreateGroupUseCase(this.repository);

  Future<Either<Failure, Group>> call({
    required String name,
    required String createdBy,
    required String createdByName,
    String? description,
  }) async {
    if (name.trim().isEmpty) {
      return const Left(Failure.validation('Group name cannot be empty'));
    }
    if (name.trim().length < 3) {
      return const Left(Failure.validation('Group name must be at least 3 characters'));
    }
    return await repository.createGroup(
      name: name.trim(),
      createdBy: createdBy,
      createdByName: createdByName,
      description: description?.trim(),
    );
  }
}

