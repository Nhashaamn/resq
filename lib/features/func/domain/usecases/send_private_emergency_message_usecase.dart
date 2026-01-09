import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:resq/core/error/failures.dart';
import 'package:resq/features/func/domain/repositories/private_emergency_message_repository.dart';

@injectable
class SendPrivateEmergencyMessageUseCase {
  final PrivateEmergencyMessageRepository repository;

  SendPrivateEmergencyMessageUseCase(this.repository);

  Future<Either<Failure, Unit>> call({
    required String fromUserId,
    required String fromUserName,
    required String toEmail,
    required String toPhoneNumber,
    required String message,
    double? latitude,
    double? longitude,
  }) async {
    if (fromUserId.isEmpty) {
      return const Left(Failure.validation('User ID cannot be empty'));
    }
    if (toEmail.trim().isEmpty) {
      return const Left(Failure.validation('Recipient email cannot be empty'));
    }
    if (toPhoneNumber.trim().isEmpty) {
      return const Left(Failure.validation('Recipient phone number cannot be empty'));
    }
    if (message.trim().isEmpty) {
      return const Left(Failure.validation('Message cannot be empty'));
    }

    return await repository.sendPrivateEmergencyMessage(
      fromUserId: fromUserId,
      fromUserName: fromUserName,
      toEmail: toEmail.trim(),
      toPhoneNumber: toPhoneNumber.trim(),
      message: message.trim(),
      latitude: latitude,
      longitude: longitude,
    );
  }
}

