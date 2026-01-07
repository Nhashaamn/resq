import 'package:dartz/dartz.dart';
import 'package:resq/core/error/failures.dart';
import 'package:resq/features/func/domain/entities/emergency_number.dart';

abstract class EmergencyNumberRepository {
  Future<Either<Failure, EmergencyNumber?>> getEmergencyNumber(String userId);
  Future<Either<Failure, Unit>> setEmergencyNumber(String userId, String phoneNumber, String email);
  Future<Either<Failure, Unit>> clearEmergencyNumber(String userId);
}

