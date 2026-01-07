import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:resq/core/error/failures.dart';
import 'package:resq/features/func/domain/entities/group_message.dart';
import 'package:resq/features/func/domain/repositories/group_repository.dart';

@injectable
class StreamGroupMessagesUseCase {
  final GroupRepository repository;

  StreamGroupMessagesUseCase(this.repository);

  Stream<Either<Failure, List<GroupMessage>>> call(String groupId) {
    if (groupId.isEmpty) {
      return Stream.value(const Left(Failure.validation('Group ID cannot be empty')));
    }
    return repository.streamGroupMessages(groupId);
  }
}

