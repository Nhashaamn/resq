import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:resq/features/func/domain/entities/safe_zone.dart';

class SafeZoneModel {
  final String id;
  final String userId;
  final String userName;
  final String name;
  final SafeZoneType type;
  final List<LatLng>? polygonPoints;
  final LatLng? center;
  final double? radius;
  final DateTime createdAt;
  final DateTime expiresAt;

  SafeZoneModel({
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
  });

  SafeZone toDomain() {
    return SafeZone(
      id: id,
      userId: userId,
      userName: userName,
      name: name,
      type: type,
      polygonPoints: polygonPoints,
      center: center,
      radius: radius,
      createdAt: createdAt,
      expiresAt: expiresAt,
    );
  }

  factory SafeZoneModel.fromDomain(SafeZone zone) {
    return SafeZoneModel(
      id: zone.id,
      userId: zone.userId,
      userName: zone.userName,
      name: zone.name,
      type: zone.type,
      polygonPoints: zone.polygonPoints,
      center: zone.center,
      radius: zone.radius,
      createdAt: zone.createdAt,
      expiresAt: zone.expiresAt,
    );
  }

  factory SafeZoneModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    final type = (data['type'] as String) == 'polygon' 
        ? SafeZoneType.polygon 
        : SafeZoneType.circle;
    
    List<LatLng>? polygonPoints;
    LatLng? center;
    double? radius;
    
    if (type == SafeZoneType.polygon) {
      final points = data['polygonPoints'] as List<dynamic>?;
      if (points != null) {
        polygonPoints = points.map((point) {
          final map = point as Map<String, dynamic>;
          return LatLng(
            map['latitude'] as double,
            map['longitude'] as double,
          );
        }).toList();
      }
    } else {
      final centerData = data['center'] as Map<String, dynamic>?;
      if (centerData != null) {
        center = LatLng(
          centerData['latitude'] as double,
          centerData['longitude'] as double,
        );
      }
      radius = (data['radius'] as num?)?.toDouble();
    }
    
    return SafeZoneModel(
      id: doc.id,
      userId: data['userId'] as String,
      userName: data['userName'] as String,
      name: data['name'] as String,
      type: type,
      polygonPoints: polygonPoints,
      center: center,
      radius: radius,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      expiresAt: (data['expiresAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    final map = <String, dynamic>{
      'userId': userId,
      'userName': userName,
      'name': name,
      'type': type == SafeZoneType.polygon ? 'polygon' : 'circle',
      'createdAt': Timestamp.fromDate(createdAt),
      'expiresAt': Timestamp.fromDate(expiresAt),
    };
    
    if (type == SafeZoneType.polygon && polygonPoints != null) {
      map['polygonPoints'] = polygonPoints!.map((point) => {
        'latitude': point.latitude,
        'longitude': point.longitude,
      }).toList();
    } else if (type == SafeZoneType.circle && center != null && radius != null) {
      map['center'] = {
        'latitude': center!.latitude,
        'longitude': center!.longitude,
      };
      map['radius'] = radius;
    }
    
    return map;
  }
}

