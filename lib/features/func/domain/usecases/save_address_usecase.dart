import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:injectable/injectable.dart';
import 'package:resq/core/error/failures.dart';
import 'package:resq/features/func/domain/repositories/address_repository.dart';

@injectable
class SaveAddressUseCase {
  final AddressRepository repository;
  final firebase_auth.FirebaseAuth firebaseAuth;

  SaveAddressUseCase(this.repository, this.firebaseAuth);

  Future<Either<Failure, Unit>> call(
    String city,
    String country,
    double? latitude,
    double? longitude,
  ) async {
    if (city.isEmpty || country.isEmpty) {
      return const Left(Failure.validation('City and country are required'));
    }

    final user = firebaseAuth.currentUser;
    if (user == null) {
      return const Left(Failure.auth('User not authenticated'));
    }

    return await repository.saveAddress(
      user.uid,
      city,
      country,
      latitude,
      longitude,
    );
  }
}

