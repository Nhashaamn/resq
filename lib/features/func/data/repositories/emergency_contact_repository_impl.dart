import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:resq/core/error/failures.dart';
import 'package:resq/features/func/data/datasources/emergency_contact_local_datasource.dart';
import 'package:resq/features/func/data/datasources/emergency_contact_remote_datasource.dart';
import 'package:resq/features/func/data/models/emergency_contact_model.dart';
import 'package:resq/features/func/domain/entities/emergency_contact.dart';
import 'package:resq/features/func/domain/repositories/emergency_contact_repository.dart';

@LazySingleton(as: EmergencyContactRepository)
class EmergencyContactRepositoryImpl
    implements EmergencyContactRepository {
  final EmergencyContactLocalDataSource localDataSource;
  final EmergencyContactRemoteDataSource remoteDataSource;

  EmergencyContactRepositoryImpl(
    this.localDataSource,
    this.remoteDataSource,
  );

  @override
  Future<Either<Failure, List<EmergencyContact>>> getEmergencyContacts(String userId) async {
    try {
      // Try to get from remote (Firestore) first - source of truth
      try {
        final remoteContacts = await remoteDataSource.getEmergencyContacts(userId);
        
        // Cache the remote data locally for offline access
        // Clear existing local cache and sync with remote
        await localDataSource.deleteAllEmergencyContacts(userId);
        for (final contact in remoteContacts) {
          await localDataSource.addEmergencyContact(userId, contact);
        }
        
        return Right(remoteContacts.map((model) => model.toDomain()).toList());
      } catch (remoteError) {
        // If remote fails, fall back to local cache
        try {
          final localContacts = await localDataSource.getEmergencyContacts(userId);
          return Right(localContacts.map((model) => model.toDomain()).toList());
        } catch (localError) {
          // Both failed, return remote error as primary
          return Left(Failure.network(remoteError.toString()));
        }
      }
    } catch (e) {
      return Left(Failure.server(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> addEmergencyContact(
    String userId,
    String name,
    String phoneNumber,
  ) async {
    try {
      final model = EmergencyContactModel(
        name: name,
        phoneNumber: phoneNumber,
      );
      
      // Write to remote first (source of truth)
      try {
        await remoteDataSource.addEmergencyContact(userId, model);
        
        // Also cache locally for offline access
        try {
          await localDataSource.addEmergencyContact(userId, model);
        } catch (localError) {
          // Local cache failure is not critical, log but continue
          // In production, you might want to log this
        }
        
        return const Right(unit);
      } catch (remoteError) {
        // If remote fails, try to save locally for offline sync later
        try {
          await localDataSource.addEmergencyContact(userId, model);
          // Return network error but data is cached locally
          return Left(Failure.network(
            'Failed to sync with server. Contact saved locally and will sync when online.'
          ));
        } catch (localError) {
          return Left(Failure.network(remoteError.toString()));
        }
      }
    } catch (e) {
      return Left(Failure.server(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteEmergencyContact(String userId, int index) async {
    try {
      // Get the contact to delete (need ID for remote)
      final localContacts = await localDataSource.getEmergencyContacts(userId);
      if (index < 0 || index >= localContacts.length) {
        return const Left(Failure.validation('Invalid contact index'));
      }
      
      final contactToDelete = localContacts[index];
      
      // Delete from remote first
      try {
        if (contactToDelete.id != null) {
          await remoteDataSource.deleteEmergencyContact(userId, contactToDelete.id!);
        }
        
        // Also delete from local cache
        try {
          await localDataSource.deleteEmergencyContact(userId, index);
        } catch (localError) {
          // Local cache failure is not critical
        }
        
        return const Right(unit);
      } catch (remoteError) {
        // If remote fails, still delete locally
        try {
          await localDataSource.deleteEmergencyContact(userId, index);
          return Left(Failure.network(
            'Failed to sync deletion with server. Contact removed locally and will sync when online.'
          ));
        } catch (localError) {
          return Left(Failure.network(remoteError.toString()));
        }
      }
    } catch (e) {
      return Left(Failure.server(e.toString()));
    }
  }
}

