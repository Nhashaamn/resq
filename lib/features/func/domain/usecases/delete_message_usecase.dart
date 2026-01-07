import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:resq/core/error/failures.dart';
import 'package:resq/features/func/domain/repositories/community_repository.dart';

@injectable
class DeleteMessageUseCase {
  final CommunityRepository repository;

  DeleteMessageUseCase(this.repository);

  Future<Either<Failure, Unit>> call(String messageId) async {
    if (messageId.isEmpty) {
      return const Left(Failure.validation('Message ID cannot be empty'));
    }
    return await repository.deleteMessage(messageId);
  }
}

