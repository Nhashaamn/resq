import 'package:dartz/dartz.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:resq/core/error/failures.dart';
import 'package:resq/features/func/domain/entities/dangerous_zone.dart';

abstract class DangerousZoneRepository {
  /// Stream dangerous zones in real-time
  Stream<Either<Failure, List<DangerousZone>>> streamZones();
  
  /// Save a dangerous zone
  Future<Either<Failure, Unit>> saveZone({
    required String userId,
    required String userName,
    required String name,
    required ZoneType type,
    List<LatLng>? polygonPoints,
    LatLng? center,
    double? radius,
  });

  /// Delete a dangerous zone
  Future<Either<Failure, Unit>> deleteZone(String zoneId);
  
  /// Delete expired zones (called periodically)
  Future<Either<Failure, Unit>> deleteExpiredZones();
}

