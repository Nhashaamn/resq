import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:resq/core/error/failures.dart';
import 'package:resq/features/func/data/datasources/emergency_number_remote_datasource.dart';
import 'package:resq/features/func/data/models/emergency_number_model.dart';
import 'package:resq/features/func/domain/entities/emergency_number.dart';
import 'package:resq/features/func/domain/repositories/emergency_number_repository.dart';

@LazySingleton(as: EmergencyNumberRepository)
class EmergencyNumberRepositoryImpl implements EmergencyNumberRepository {
  final EmergencyNumberRemoteDataSource remoteDataSource;

  EmergencyNumberRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, EmergencyNumber?>> getEmergencyNumber(String userId) async {
    try {
      final model = await remoteDataSource.getEmergencyNumber(userId);
      return Right(model?.toDomain());
    } catch (e) {
      return Left(Failure.network(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> setEmergencyNumber(String userId, String phoneNumber, String email) async {
    try {
      if (phoneNumber.trim().isEmpty) {
        return const Left(Failure.validation('Phone number cannot be empty'));
      }
      if (email.trim().isEmpty) {
        return const Left(Failure.validation('Email cannot be empty'));
      }

      final model = EmergencyNumberModel(
        phoneNumber: phoneNumber.trim(),
        email: email.trim(),
        updatedAt: DateTime.now(),
      );

      await remoteDataSource.setEmergencyNumber(userId, model);
      return const Right(unit);
    } catch (e) {
      return Left(Failure.network(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> clearEmergencyNumber(String userId) async {
    try {
      await remoteDataSource.clearEmergencyNumber(userId);
      return const Right(unit);
    } catch (e) {
      return Left(Failure.network(e.toString()));
    }
  }
}

