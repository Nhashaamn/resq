import 'package:dartz/dartz.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:resq/core/error/failures.dart';
import 'package:resq/features/func/domain/entities/safe_zone.dart';

abstract class SafeZoneRepository {
  /// Stream safe zones in real-time
  Stream<Either<Failure, List<SafeZone>>> streamZones();
  
  /// Save a safe zone
  Future<Either<Failure, Unit>> saveZone({
    required String userId,
    required String userName,
    required String name,
    required SafeZoneType type,
    List<LatLng>? polygonPoints,
    LatLng? center,
    double? radius,
  });

  /// Delete a safe zone
  Future<Either<Failure, Unit>> deleteZone(String zoneId);
  
  /// Delete expired zones (called periodically)
  Future<Either<Failure, Unit>> deleteExpiredZones();
}

