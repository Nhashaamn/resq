import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:resq/core/error/failures.dart';
import 'package:resq/features/func/domain/repositories/community_repository.dart';

@injectable
class SendMessageUseCase {
  final CommunityRepository repository;

  SendMessageUseCase(this.repository);

  Future<Either<Failure, Unit>> call({
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
    return await repository.sendMessage(
      userId: userId,
      userName: userName,
      text: text.trim(),
      replyToMessageId: replyToMessageId,
      replyToUserName: replyToUserName,
      replyToText: replyToText,
    );
  }
}

