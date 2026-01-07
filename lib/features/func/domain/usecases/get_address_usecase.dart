import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:injectable/injectable.dart';
import 'package:resq/core/error/failures.dart';
import 'package:resq/features/func/domain/entities/address.dart';
import 'package:resq/features/func/domain/repositories/address_repository.dart';

@injectable
class GetAddressUseCase {
  final AddressRepository repository;
  final firebase_auth.FirebaseAuth firebaseAuth;

  GetAddressUseCase(this.repository, this.firebaseAuth);

  Future<Either<Failure, Address?>> call() async {
    final user = firebaseAuth.currentUser;
    if (user == null) {
      return const Left(Failure.auth('User not authenticated'));
    }
    return await repository.getAddress(user.uid);
  }
}

