import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:resq/core/error/failures.dart';
import 'package:resq/features/func/domain/repositories/emergency_number_repository.dart';

@injectable
class SetEmergencyNumberUseCase {
  final EmergencyNumberRepository repository;

  SetEmergencyNumberUseCase(this.repository);

  Future<Either<Failure, Unit>> call({
    required String userId,
    required String phoneNumber,
    required String email,
  }) async {
    if (userId.isEmpty) {
      return const Left(Failure.validation('User ID cannot be empty'));
    }
    if (phoneNumber.trim().isEmpty) {
      return const Left(Failure.validation('Phone number cannot be empty'));
    }
    if (email.trim().isEmpty) {
      return const Left(Failure.validation('Email cannot be empty'));
    }
    return await repository.setEmergencyNumber(userId, phoneNumber, email);
  }
}

