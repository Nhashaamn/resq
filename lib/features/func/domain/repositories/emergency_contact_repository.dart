import 'package:dartz/dartz.dart';
import 'package:resq/core/error/failures.dart';
import 'package:resq/features/func/domain/entities/emergency_contact.dart';

abstract class EmergencyContactRepository {
  Future<Either<Failure, List<EmergencyContact>>> getEmergencyContacts(String userId);
  Future<Either<Failure, Unit>> addEmergencyContact(
    String userId,
    String name,
    String phoneNumber,
  );
  Future<Either<Failure, Unit>> deleteEmergencyContact(String userId, int index);
}

