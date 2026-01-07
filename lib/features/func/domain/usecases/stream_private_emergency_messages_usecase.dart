import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:resq/core/error/failures.dart';
import 'package:resq/features/func/domain/entities/private_emergency_message.dart';
import 'package:resq/features/func/domain/repositories/private_emergency_message_repository.dart';

@injectable
class StreamPrivateEmergencyMessagesUseCase {
  final PrivateEmergencyMessageRepository repository;

  StreamPrivateEmergencyMessagesUseCase(this.repository);

  Stream<Either<Failure, List<PrivateEmergencyMessage>>> call(String userEmail) {
    if (userEmail.trim().isEmpty) {
      return Stream.value(
        const Left(Failure.validation('User email cannot be empty')),
      );
    }
    return repository.streamPrivateEmergencyMessages(userEmail.trim());
  }
}

