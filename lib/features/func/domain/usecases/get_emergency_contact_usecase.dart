import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:resq/core/error/failures.dart';
import 'package:resq/features/func/domain/entities/emergency_contact.dart';
import 'package:resq/features/func/domain/repositories/emergency_contact_repository.dart';

@injectable
class GetEmergencyContactsUseCase {
  final EmergencyContactRepository repository;

  GetEmergencyContactsUseCase(this.repository);

  Future<Either<Failure, List<EmergencyContact>>> call(String userId) async {
    return await repository.getEmergencyContacts(userId);
  }
}

