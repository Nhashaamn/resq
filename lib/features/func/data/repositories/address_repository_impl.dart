import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:resq/core/error/failures.dart';
import 'package:resq/features/func/data/datasources/address_remote_datasource.dart';
import 'package:resq/features/func/data/models/address_model.dart';
import 'package:resq/features/func/domain/entities/address.dart' as domain;
import 'package:resq/features/func/domain/repositories/address_repository.dart';

@LazySingleton(as: AddressRepository)
class AddressRepositoryImpl implements AddressRepository {
  final AddressRemoteDataSource remoteDataSource;

  AddressRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, domain.Address?>> getAddress(String userId) async {
    try {
      final addressModel = await remoteDataSource.getAddress(userId);
      if (addressModel == null) {
        return const Right(null);
      }
      return Right(addressModel.toDomain());
    } catch (e) {
      return Left(Failure.server(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> saveAddress(
    String userId,
    String city,
    String country,
    double? latitude,
    double? longitude,
  ) async {
    try {
      final addressModel = AddressModel(
        city: city,
        country: country,
        latitude: latitude,
        longitude: longitude,
      );
      await remoteDataSource.saveAddress(userId, addressModel);
      return const Right(unit);
    } catch (e) {
      return Left(Failure.server(e.toString()));
    }
  }
}

