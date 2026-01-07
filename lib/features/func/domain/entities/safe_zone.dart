import 'package:google_maps_flutter/google_maps_flutter.dart';

enum SafeZoneType { polygon, circle }

class SafeZone {
  final String id;
  final String userId;
  final String userName;
  final String name;
  final SafeZoneType type;
  final List<LatLng>? polygonPoints; // For polygon type
  final LatLng? center; // For circle type
  final double? radius; // For circle type (in meters)
  final DateTime createdAt;
  final DateTime expiresAt; // Auto-delete after this time

  SafeZone({
    required this.id,
    required this.userId,
    required this.userName,
    required this.name,
    required this.type,
    this.polygonPoints,
    this.center,
    this.radius,
    required this.createdAt,
    required this.expiresAt,
  }) : assert(
          (type == SafeZoneType.polygon && polygonPoints != null && polygonPoints.isNotEmpty) ||
          (type == SafeZoneType.circle && center != null && radius != null),
          'Polygon must have points, circle must have center and radius',
        );

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}

