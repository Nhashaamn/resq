import 'package:dartz/dartz.dart';
import 'package:resq/core/error/failures.dart';
import 'package:resq/features/func/domain/entities/address.dart';

abstract class AddressRepository {
  Future<Either<Failure, Address?>> getAddress(String userId);
  Future<Either<Failure, Unit>> saveAddress(
    String userId,
    String city,
    String country,
    double? latitude,
    double? longitude,
  );
}

