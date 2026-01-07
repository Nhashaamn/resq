import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:resq/core/error/failures.dart';
import 'package:resq/features/func/domain/repositories/emergency_number_repository.dart';

@injectable
class ClearEmergencyNumberUseCase {
  final EmergencyNumberRepository repository;

  ClearEmergencyNumberUseCase(this.repository);

  Future<Either<Failure, Unit>> call(String userId) async {
    if (userId.isEmpty) {
      return const Left(Failure.validation('User ID cannot be empty'));
    }
    return await repository.clearEmergencyNumber(userId);
  }
}

