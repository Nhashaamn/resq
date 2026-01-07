import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:resq/core/di/injection.dart';
import 'package:resq/features/func/domain/entities/dangerous_zone.dart';
import 'package:resq/features/func/domain/repositories/dangerous_zone_repository.dart';

class NearbyZone {
  final DangerousZone zone;
  final double distanceInKm; // Distance in kilometers
  final DateTime createdAt;

  NearbyZone({
    required this.zone,
    required this.distanceInKm,
    required this.createdAt,
  });
}

class NearbyZonesState {
  final List<NearbyZone> nearbyZones;
  final bool isLoading;
  final String? error;
  final Position? userLocation;

  NearbyZonesState({
    this.nearbyZones = const [],
    this.isLoading = false,
    this.error,
    this.userLocation,
  });

  NearbyZonesState copyWith({
    List<NearbyZone>? nearbyZones,
    bool? isLoading,
    String? error,
    Position? userLocation,
  }) {
    return NearbyZonesState(
      nearbyZones: nearbyZones ?? this.nearbyZones,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      userLocation: userLocation ?? this.userLocation,
    );
  }

  NearbyZone? get nearestZone {
    if (nearbyZones.isEmpty) return null;
    return nearbyZones.reduce((a, b) => 
      a.distanceInKm < b.distanceInKm ? a : b);
  }
}

class NearbyZonesNotifier extends StateNotifier<NearbyZonesState> {
  final DangerousZoneRepository _zoneRepository;
  StreamSubscription? _zonesSubscription;
  StreamSubscription<Position>? _positionSubscription;
  List<DangerousZone> _allZones = [];
  static const double _radiusKm = 50.0; // 50km radius

  NearbyZonesNotifier(this._zoneRepository) : super(NearbyZonesState()) {
    _initialize();
  }

  Future<void> _initialize() async {
    state = state.copyWith(isLoading: true);
    await _getUserLocation();
    _startMonitoringZones();
  }

  Future<void> _getUserLocation() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        state = state.copyWith(
          error: 'Location services are disabled',
          isLoading: false,
        );
        return;
      }

      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          state = state.copyWith(
            error: 'Location permissions are denied',
            isLoading: false,
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        state = state.copyWith(
          error: 'Location permissions are permanently denied',
          isLoading: false,
        );
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      state = state.copyWith(
        userLocation: position,
        isLoading: false,
      );

      // Check nearby zones with initial location
      _checkNearbyZones(position);

      // Start listening to position updates
      _positionSubscription = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 100, // Update every 100 meters
        ),
      ).listen((position) {
        state = state.copyWith(userLocation: position);
        _checkNearbyZones(position);
      });
    } catch (e) {
      state = state.copyWith(
        error: 'Error getting location: $e',
        isLoading: false,
      );
    }
  }

  void _startMonitoringZones() {
    _zonesSubscription?.cancel();
    _zonesSubscription = _zoneRepository.streamZones().listen(
      (result) {
        result.fold(
          (failure) {
            state = state.copyWith(
              error: failure.message,
              isLoading: false,
            );
          },
          (zones) {
            _allZones = zones;
            if (state.userLocation != null) {
              _checkNearbyZones(state.userLocation);
            }
          },
        );
      },
      onError: (error) {
        state = state.copyWith(
          error: 'Error monitoring zones: $error',
          isLoading: false,
        );
      },
    );
  }

  void _checkNearbyZones(Position? userLocation) {
    if (userLocation == null) return;

    final nearbyZones = <NearbyZone>[];

    for (var zone in _allZones) {
      if (zone.isExpired) continue;

      double? distanceInKm;

      if (zone.type == ZoneType.circle && zone.center != null && zone.radius != null) {
        // For circle: calculate distance from user to center, then subtract radius
        final distanceToCenter = Geolocator.distanceBetween(
          userLocation.latitude,
          userLocation.longitude,
          zone.center!.latitude,
          zone.center!.longitude,
        ) / 1000; // Convert to km

        final zoneRadiusKm = zone.radius! / 1000; // Convert to km
        
        // If user is inside the circle, distance is 0
        if (distanceToCenter <= zoneRadiusKm) {
          distanceInKm = 0;
        } else {
          // Distance from user to nearest edge of circle
          distanceInKm = distanceToCenter - zoneRadiusKm;
        }

        // Check if within 50km radius
        if (distanceInKm <= _radiusKm) {
          nearbyZones.add(NearbyZone(
            zone: zone,
            distanceInKm: distanceInKm,
            createdAt: zone.createdAt,
          ));
        }
      } else if (zone.type == ZoneType.polygon && zone.polygonPoints != null && zone.polygonPoints!.isNotEmpty) {
        // For polygon: find minimum distance to any point in polygon
        double minDistance = double.infinity;
        
        for (var point in zone.polygonPoints!) {
          final distance = Geolocator.distanceBetween(
            userLocation.latitude,
            userLocation.longitude,
            point.latitude,
            point.longitude,
          ) / 1000; // Convert to km
          
          if (distance < minDistance) {
            minDistance = distance;
          }
        }

        // Check if within 50km radius
        if (minDistance <= _radiusKm) {
          nearbyZones.add(NearbyZone(
            zone: zone,
            distanceInKm: minDistance,
            createdAt: zone.createdAt,
          ));
        }
      }
    }

    // Sort by distance (nearest first)
    nearbyZones.sort((a, b) => a.distanceInKm.compareTo(b.distanceInKm));

    state = state.copyWith(
      nearbyZones: nearbyZones,
      isLoading: false,
      error: null,
    );
  }

  @override
  void dispose() {
    _zonesSubscription?.cancel();
    _positionSubscription?.cancel();
    super.dispose();
  }
}

final nearbyZonesProvider = StateNotifierProvider<NearbyZonesNotifier, NearbyZonesState>((ref) {
  final zoneRepository = getIt<DangerousZoneRepository>();
  return NearbyZonesNotifier(zoneRepository);
});

