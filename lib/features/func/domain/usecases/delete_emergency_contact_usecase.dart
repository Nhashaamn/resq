import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:resq/core/error/failures.dart';
import 'package:resq/features/func/domain/repositories/emergency_contact_repository.dart';

@injectable
class DeleteEmergencyContactUseCase {
  final EmergencyContactRepository repository;

  DeleteEmergencyContactUseCase(this.repository);

  Future<Either<Failure, Unit>> call(String userId, int index) async {
    return await repository.deleteEmergencyContact(userId, index);
  }
}

