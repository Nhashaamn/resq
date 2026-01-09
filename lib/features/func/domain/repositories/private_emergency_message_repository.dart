import 'package:dartz/dartz.dart';
import 'package:resq/core/error/failures.dart';
import 'package:resq/features/func/domain/entities/private_emergency_message.dart';

abstract class PrivateEmergencyMessageRepository {
  Future<Either<Failure, Unit>> sendPrivateEmergencyMessage({
    required String fromUserId,
    required String fromUserName,
    required String toEmail,
    required String toPhoneNumber,
    required String message,
    double? latitude,
    double? longitude,
  });
  Stream<Either<Failure, List<PrivateEmergencyMessage>>> streamPrivateEmergencyMessages(String userEmail);
  Future<Either<Failure, Unit>> markAsRead(String messageId);
}

