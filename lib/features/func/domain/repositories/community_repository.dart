import 'package:dartz/dartz.dart';
import 'package:resq/core/error/failures.dart';
import 'package:resq/features/func/domain/entities/message.dart';

abstract class CommunityRepository {
  /// Stream messages in real-time
  Stream<Either<Failure, List<Message>>> streamMessages();
  
  /// Send a message
  Future<Either<Failure, Unit>> sendMessage({
    required String userId,
    required String userName,
    required String text,
    String? replyToMessageId,
    String? replyToUserName,
    String? replyToText,
  });

  /// Delete a message
  Future<Either<Failure, Unit>> deleteMessage(String messageId);
}

