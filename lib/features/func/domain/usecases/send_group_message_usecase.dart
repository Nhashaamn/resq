import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:resq/core/error/failures.dart';
import 'package:resq/features/func/domain/repositories/group_repository.dart';

@injectable
class SendGroupMessageUseCase {
  final GroupRepository repository;

  SendGroupMessageUseCase(this.repository);

  Future<Either<Failure, Unit>> call({
    required String groupId,
    required String userId,
    required String userName,
    required String text,
    String? replyToMessageId,
    String? replyToUserName,
    String? replyToText,
  }) async {
    if (text.trim().isEmpty) {
      return const Left(Failure.validation('Message cannot be empty'));
    }
    return await repository.sendGroupMessage(
      groupId: groupId,
      userId: userId,
      userName: userName,
      text: text.trim(),
      replyToMessageId: replyToMessageId,
      replyToUserName: replyToUserName,
      replyToText: replyToText,
    );
  }
}

