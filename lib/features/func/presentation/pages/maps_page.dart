import 'dart:async';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:resq/core/constants/api_constants.dart';
import 'package:resq/core/di/injection.dart';
import 'package:resq/core/theme/app_theme.dart';
import 'package:resq/features/func/domain/entities/dangerous_zone.dart';
import 'package:resq/features/func/domain/repositories/dangerous_zone_repository.dart';
import 'package:resq/features/func/domain/entities/safe_zone.dart';
import 'package:resq/features/func/domain/repositories/safe_zone_repository.dart';
import 'package:resq/features/func/presentation/widgets/appbar.dart';

class MapsPage extends StatefulWidget {
  final String? targetSafeZoneId;
  final LatLng? targetSafeZoneLocation;
  final String? targetSafeZoneName;
  
  const MapsPage({
    super.key,
    this.targetSafeZoneId,
    this.targetSafeZoneLocation,
    this.targetSafeZoneName,
  });

  @override
  State<MapsPage> createState() => _MapsPageState();
}


class _MapsPageState extends State<MapsPage> {
  GoogleMapController? _mapController;
  Position? _currentPosition;
  bool _isLoadingLocation = true;
  final TextEditingController _locationController = TextEditingController();
  bool _isSearching = false;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  Set<Polygon> _polygons = {};
  Set<Circle> _circles = {};
  LatLng? _nearestHospitalLocation;
  final Dio _dio = Dio();
  
  // Zone drawing state
  bool _isDrawingMode = false;
  bool _isDrawingSafeZone = false; // false = dangerous, true = safe
  ZoneType _drawingType = ZoneType.polygon;
  SafeZoneType _drawingSafeZoneType = SafeZoneType.polygon;
  List<LatLng> _polygonPoints = [];
  LatLng? _circleCenter;
  double _circleRadius = 0.0;
  StreamSubscription? _zonesSubscription;
  StreamSubscription? _safeZonesSubscription;
  final DangerousZoneRepository _zoneRepository = getIt<DangerousZoneRepository>();
  final SafeZoneRepository _safeZoneRepository = getIt<SafeZoneRepository>();
  final firebase_auth.FirebaseAuth _auth = getIt<firebase_auth.FirebaseAuth>();
  Map<String, DangerousZone> _dangerousZones = {};
  Map<String, SafeZone> _safeZones = {};
  
  // Default location (fallback if location is not available)
  static const CameraPosition _defaultPosition = CameraPosition(
    target: LatLng(33.6844, 73.0479), // Islamabad, Pakistan
    zoom: 14.0,
  );

  @override
  void initState() {
    super.initState();
    _getCurrentLocation().then((_) {
      // If target safe zone is provided, draw route after location is loaded
      if (widget.targetSafeZoneLocation != null && mounted) {
        _drawRouteToSafeZone();
      }
    });
    _loadDangerousZones();
    _loadSafeZones();
    _scheduleExpiredZoneCleanup();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    _locationController.dispose();
    _zonesSubscription?.cancel();
    _safeZonesSubscription?.cancel();
    super.dispose();
  }
  
  void _loadDangerousZones() {
    _zonesSubscription = _zoneRepository.streamZones().listen(
      (result) {
        result.fold(
          (failure) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error loading zones: ${failure.message}')),
              );
            }
          },
          (zones) {
            setState(() {
              _dangerousZones = {for (var zone in zones) zone.id: zone};
              _updateZoneOverlays();
            });
          },
        );
      },
      onError: (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $error')),
          );
        }
      },
    );
  }
  
  void _loadSafeZones() {
    _safeZonesSubscription = _safeZoneRepository.streamZones().listen(
      (result) {
        result.fold(
          (failure) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error loading safe zones: ${failure.message}')),
              );
            }
          },
          (zones) {
            setState(() {
              _safeZones = {for (var zone in zones) zone.id: zone};
              _updateZoneOverlays();
            });
          },
        );
      },
      onError: (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $error')),
          );
        }
      },
    );
  }
  
  void _updateZoneOverlays() {
    final polygons = <Polygon>{};
    final circles = <Circle>{};
    
    // Add dangerous zones (red)
    for (var zone in _dangerousZones.values) {
      if (zone.isExpired) continue;
      
      if (zone.type == ZoneType.polygon && zone.polygonPoints != null) {
        polygons.add(
          Polygon(
            polygonId: PolygonId('dangerous_${zone.id}'),
            points: zone.polygonPoints!,
            strokeColor: Colors.red,
            fillColor: Colors.red.withOpacity(0.2),
            strokeWidth: 2,
            onTap: () => _showDangerousZoneInfo(zone),
          ),
        );
      } else if (zone.type == ZoneType.circle && zone.center != null && zone.radius != null) {
        circles.add(
          Circle(
            circleId: CircleId('dangerous_${zone.id}'),
            center: zone.center!,
            radius: zone.radius!,
            strokeColor: Colors.red,
            fillColor: Colors.red.withOpacity(0.2),
            strokeWidth: 2,
            onTap: () => _showDangerousZoneInfo(zone),
          ),
        );
      }
    }
    
    // Add safe zones (green)
    for (var zone in _safeZones.values) {
      if (zone.isExpired) continue;
      
      if (zone.type == SafeZoneType.polygon && zone.polygonPoints != null) {
        polygons.add(
          Polygon(
            polygonId: PolygonId('safe_${zone.id}'),
            points: zone.polygonPoints!,
            strokeColor: Colors.green,
            fillColor: Colors.green.withOpacity(0.2),
            strokeWidth: 2,
            onTap: () => _showSafeZoneInfo(zone),
          ),
        );
      } else if (zone.type == SafeZoneType.circle && zone.center != null && zone.radius != null) {
        circles.add(
          Circle(
            circleId: CircleId('safe_${zone.id}'),
            center: zone.center!,
            radius: zone.radius!,
            strokeColor: Colors.green,
            fillColor: Colors.green.withOpacity(0.2),
            strokeWidth: 2,
            onTap: () => _showSafeZoneInfo(zone),
          ),
        );
      }
    }
    
    // Add drawing polygon preview if in drawing mode
    if (_isDrawingMode && _polygonPoints.length >= 2) {
      final color = _isDrawingSafeZone ? Colors.green : Colors.orange;
      final previewPoints = List<LatLng>.from(_polygonPoints);
      // Close the polygon for preview
      if (previewPoints.length >= 3 && previewPoints.first != previewPoints.last) {
        previewPoints.add(previewPoints.first);
      }
      polygons.add(
        Polygon(
          polygonId: const PolygonId('drawing_polygon'),
          points: previewPoints,
          strokeColor: color,
          fillColor: color.withOpacity(0.2),
          strokeWidth: 3,
        ),
      );
    }
    
    setState(() {
      _polygons = polygons;
      _circles = circles;
    });
  }
  
  void _scheduleExpiredZoneCleanup() {
    // Clean up expired zones every hour
    Timer.periodic(const Duration(hours: 1), (timer) {
      _zoneRepository.deleteExpiredZones();
      _safeZoneRepository.deleteExpiredZones();
    });
  }

  Future<void> _getCurrentLocation() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location services are disabled. Please enable them.'),
            ),
          );
        }
        setState(() {
          _isLoadingLocation = false;
        });
        return;
      }

      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Location permissions are denied.'),
              ),
            );
          }
          setState(() {
            _isLoadingLocation = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location permissions are permanently denied. Please enable them in settings.'),
            ),
          );
        }
        setState(() {
          _isLoadingLocation = false;
        });
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = position;
        _isLoadingLocation = false;
      });

      // Move camera to current location
      if (_mapController != null && _currentPosition != null) {
        await _mapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
              zoom: 14.0,
            ),
          ),
        );
        
        // Find nearby hospitals for current location
        await _findNearbyHospitals(
          LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error getting location: $e'),
          ),
        );
      }
      setState(() {
        _isLoadingLocation = false;
      });
    }
  }

  CameraPosition get _initialCameraPosition {
    if (_currentPosition != null) {
      return CameraPosition(
        target: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        zoom: 14.0,
      );
    }
    return _defaultPosition;
  }

  Future<void> _searchLocation() async {
    final query = _locationController.text.trim();
    if (query.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a location'),
        ),
      );
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      List<Location> locations = await locationFromAddress(query);
      
      if (locations.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location not found. Please try a different search.'),
            ),
          );
        }
        setState(() {
          _isSearching = false;
        });
        return;
      }

      final location = locations.first;
      final latLng = LatLng(location.latitude, location.longitude);

      setState(() {
        _markers = {
          Marker(
            markerId: const MarkerId('searched_location'),
            position: latLng,
            infoWindow: InfoWindow(
              title: query,
              snippet: 'Searched Location',
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          ),
        };
        _polylines = {}; // Clear previous polylines
        _isSearching = false;
      });

      // Move camera to searched location
      if (_mapController != null) {
        await _mapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: latLng,
              zoom: 14.0,
            ),
          ),
        );
      }

      // Find nearby hospitals
      await _findNearbyHospitals(latLng);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error searching location: $e'),
          ),
        );
      }
      setState(() {
        _isSearching = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppbarWidget(title: 'Maps', leadingIcon: Icons.map),
      body: Stack(
      children: [
        GoogleMap(
          initialCameraPosition: _initialCameraPosition,
          onMapCreated: (GoogleMapController controller) {
            _mapController = controller;
            // Move to current location after map is created if we have it
            if (_currentPosition != null) {
              _mapController!.animateCamera(
                CameraUpdate.newCameraPosition(
                  CameraPosition(
                    target: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                    zoom: 14.0,
                  ),
                ),
              );
            }
          },
          myLocationButtonEnabled: true,
          myLocationEnabled: true,
          mapType: MapType.normal,
          zoomControlsEnabled: true,
          zoomGesturesEnabled: true,
          scrollGesturesEnabled: true,
          tiltGesturesEnabled: true,
          rotateGesturesEnabled: true,
          compassEnabled: true,
          mapToolbarEnabled: false,
          markers: _markers,
          polylines: _polylines,
          polygons: _polygons,
          circles: _circles,
          onTap: _isDrawingMode ? _onMapTapped : null,
          onLongPress: _isDrawingMode && 
              ((!_isDrawingSafeZone && _drawingType == ZoneType.circle) ||
               (_isDrawingSafeZone && _drawingSafeZoneType == SafeZoneType.circle))
              ? _onMapLongPressed 
              : null,
        ),
        // Loading indicator
        if (_isLoadingLocation)
          const Center(
            child: CircularProgressIndicator(),
          ),
        // Drawing mode indicator
        if (_isDrawingMode)
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (_isDrawingSafeZone ? Colors.green : Colors.red).withOpacity(0.9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    _isDrawingSafeZone ? Icons.check_circle : Icons.warning,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _isDrawingSafeZone
                          ? (_drawingSafeZoneType == SafeZoneType.polygon
                              ? 'Drawing SAFE zone: Tap on map to draw polygon. Tap "Finish" when done.'
                              : 'Drawing SAFE zone: Tap on map to set circle center, then drag to set radius.')
                          : (_drawingType == ZoneType.polygon
                              ? 'Drawing DANGEROUS zone: Tap on map to draw polygon. Tap "Finish" when done.'
                              : 'Drawing DANGEROUS zone: Tap on map to set circle center, then drag to set radius.'),
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.white),
                    onPressed: _cancelDrawing,
                  ),
                ],
              ),
            ),
          ),
        // Zone type selector (top left when in drawing mode) - smaller buttons
        if (_isDrawingMode)
          Positioned(
            top: 80,
            left: 20,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton.small(
                  onPressed: () => setState(() {
                    if (_isDrawingSafeZone) {
                      _drawingSafeZoneType = SafeZoneType.polygon;
                    } else {
                      _drawingType = ZoneType.polygon;
                    }
                  }),
                  backgroundColor: ((_isDrawingSafeZone && _drawingSafeZoneType == SafeZoneType.polygon) ||
                      (!_isDrawingSafeZone && _drawingType == ZoneType.polygon))
                      ? AppTheme.primary 
                      : Colors.grey,
                  child: const Icon(Icons.polyline, color: Colors.white, size: 20),
                ),
                const SizedBox(height: 12),
                FloatingActionButton.small(
                  onPressed: () => setState(() {
                    if (_isDrawingSafeZone) {
                      _drawingSafeZoneType = SafeZoneType.circle;
                    } else {
                      _drawingType = ZoneType.circle;
                    }
                  }),
                  backgroundColor: ((_isDrawingSafeZone && _drawingSafeZoneType == SafeZoneType.circle) ||
                      (!_isDrawingSafeZone && _drawingType == ZoneType.circle))
                      ? AppTheme.primary 
                      : Colors.grey,
                  child: const Icon(Icons.radio_button_unchecked, color: Colors.white, size: 20),
                ),
              ],
            ),
          ),
        // Drawing controls (bottom left when in drawing mode) - smaller buttons
        if (_isDrawingMode)
          Positioned(
            bottom: 120,
            left: 20,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if ((!_isDrawingSafeZone && _drawingType == ZoneType.polygon && _polygonPoints.isNotEmpty) ||
                    (_isDrawingSafeZone && _drawingSafeZoneType == SafeZoneType.polygon && _polygonPoints.isNotEmpty))
                  FloatingActionButton.small(
                    onPressed: _finishPolygon,
                    backgroundColor: Colors.green,
                    child: const Icon(Icons.check, color: Colors.white, size: 20),
                  ),
                if ((!_isDrawingSafeZone && _drawingType == ZoneType.circle && _circleCenter != null && _circleRadius > 0) ||
                    (_isDrawingSafeZone && _drawingSafeZoneType == SafeZoneType.circle && _circleCenter != null && _circleRadius > 0))
                  FloatingActionButton.small(
                    onPressed: _saveZone,
                    backgroundColor: Colors.green,
                    child: const Icon(Icons.check, color: Colors.white, size: 20),
                  ),
                if (((!_isDrawingSafeZone && _drawingType == ZoneType.polygon && _polygonPoints.isNotEmpty) ||
                    (_isDrawingSafeZone && _drawingSafeZoneType == SafeZoneType.polygon && _polygonPoints.isNotEmpty)) ||
                    ((!_isDrawingSafeZone && _drawingType == ZoneType.circle && _circleCenter != null) ||
                    (_isDrawingSafeZone && _drawingSafeZoneType == SafeZoneType.circle && _circleCenter != null)))
                  const SizedBox(height: 12),
                FloatingActionButton.small(
                  onPressed: _cancelDrawing,
                  backgroundColor: Colors.red,
                  child: const Icon(Icons.close, color: Colors.white, size: 20),
                ),
              ],
            ),
          ),
        // Custom floating action button for current location (right side)
        Positioned(
          bottom: 120,
          right: 20,
          child: FloatingActionButton(
            onPressed: _goToCurrentLocation,
            backgroundColor: AppTheme.primary,
            child: const Icon(
              Icons.my_location,
              color: AppTheme.white,
            ),
          ),
        ),
        // Toggle drawing mode button (right side)
        Positioned(
          bottom: 180,
          right: 20,
          child: FloatingActionButton(
            onPressed: _toggleDrawingMode,
            backgroundColor: _isDrawingMode ? Colors.orange : AppTheme.primary,
            child: Icon(
              _isDrawingMode ? Icons.edit_off : Icons.edit_location,
              color: AppTheme.white,
            ),
          ),
        ),
        // Toggle between dangerous and safe zone (right side, above drawing toggle)
        if (_isDrawingMode)
          Positioned(
            bottom: 240,
            right: 20,
            child: FloatingActionButton(
              onPressed: () {
                setState(() {
                  _isDrawingSafeZone = !_isDrawingSafeZone;
                  _cancelDrawing(); // Reset drawing state when switching
                });
              },
              backgroundColor: _isDrawingSafeZone ? Colors.green : Colors.red,
              child: Icon(
                _isDrawingSafeZone ? Icons.check_circle : Icons.warning,
                color: AppTheme.white,
              ),
            ),
          ),
          // Location search field and hospitals list at bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.backgroundWhite,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Search field
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _locationController,
                              decoration: InputDecoration(
                                hintText: 'Enter location...',
                                prefixIcon: const Icon(Icons.search),
                                filled: true,
                                fillColor: AppTheme.backgroundLight,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: AppTheme.borderLight,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: AppTheme.borderLight,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: AppTheme.primary,
                                    width: 2,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                              onSubmitted: (_) => _searchLocation(),
                            ),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: _isSearching ? null : _searchLocation,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primary,
                              foregroundColor: AppTheme.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                            child: _isSearching
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        AppTheme.white,
                                      ),
                                    ),
                                  )
                                : const Text(
                                    'Search',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _findNearbyHospitals(LatLng location) async {
    try {
      final url = 'https://maps.googleapis.com/maps/api/place/nearbysearch/json';
      final params = {
        'location': '${location.latitude},${location.longitude}',
        'radius': '5000', // 5km radius
        'type': 'hospital',
        'key': ApiConstants.googleMapsApiKey,
      };

      final response = await _dio.get(url, queryParameters: params);

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['status'] == 'OK' && data['results'] != null) {
          final results = data['results'] as List;
          Set<Marker> hospitalMarkers = {};
          
          // Keep existing markers (like searched location marker) if any
          if (_markers.isNotEmpty) {
            hospitalMarkers = Set.from(_markers);
          }

          // Store hospitals with distances to find nearest
          List<Map<String, dynamic>> hospitalsWithDistance = [];

          // Create markers for hospitals
          for (int i = 0; i < results.length; i++) {
            final result = results[i];
            final geometry = result['geometry'];
            final locationData = geometry['location'];
            final hospitalLat = locationData['lat'] as double;
            final hospitalLng = locationData['lng'] as double;

            // Calculate distance
            final distance = Geolocator.distanceBetween(
              location.latitude,
              location.longitude,
              hospitalLat,
              hospitalLng,
            ) / 1000; // Convert to kilometers

            hospitalsWithDistance.add({
              'lat': hospitalLat,
              'lng': hospitalLng,
              'name': result['name'] ?? 'Unknown Hospital',
              'distance': distance,
            });

            hospitalMarkers.add(
              Marker(
                markerId: MarkerId('hospital_$i'),
                position: LatLng(hospitalLat, hospitalLng),
                infoWindow: InfoWindow(
                  title: result['name'] ?? 'Unknown Hospital',
                  snippet: '${distance.toStringAsFixed(1)} km away',
                ),
                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
              ),
            );
          }

          // Find nearest hospital and draw path from user's current location
          if (hospitalsWithDistance.isNotEmpty && _currentPosition != null) {
            hospitalsWithDistance.sort((a, b) => 
              (a['distance'] as double).compareTo(b['distance'] as double));
            
            final nearest = hospitalsWithDistance.first;
            _nearestHospitalLocation = LatLng(nearest['lat'], nearest['lng']);
            
            // Draw path to nearest hospital from user's current location
            await _drawPathToNearestHospital(
              LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
              _nearestHospitalLocation!,
            );
          }

          setState(() {
            _markers = hospitalMarkers;
          });
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('No hospitals found nearby. Status: ${data['status']}'),
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error finding hospitals: $e'),
          ),
        );
      }
    }
  }

  Future<void> _drawPathToNearestHospital(LatLng origin, LatLng destination) async {
    try {
      final url = 'https://maps.googleapis.com/maps/api/directions/json';
      final params = {
        'origin': '${origin.latitude},${origin.longitude}',
        'destination': '${destination.latitude},${destination.longitude}',
        'key': ApiConstants.googleMapsApiKey,
      };

      final response = await _dio.get(url, queryParameters: params);

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['status'] == 'OK' && data['routes'] != null && data['routes'].isNotEmpty) {
          final route = data['routes'][0];
          final polylinePoints = route['overview_polyline']['points'];
          
          // Decode polyline points
          List<LatLng> points = _decodePolyline(polylinePoints);

          setState(() {
            _polylines = {
              Polyline(
                polylineId: const PolylineId('route_to_nearest_hospital'),
                points: points,
                color: AppTheme.primary,
                width: 5,
                patterns: [],
              ),
            };
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error drawing path: $e'),
          ),
        );
      }
    }
  }

  Future<void> _drawRouteToSafeZone() async {
    if (widget.targetSafeZoneLocation == null || _currentPosition == null) {
      // Wait for location if not available yet
      if (_currentPosition == null) {
        await _getCurrentLocation();
      }
      if (_currentPosition == null || widget.targetSafeZoneLocation == null) {
        return;
      }
    }

    final origin = LatLng(_currentPosition!.latitude, _currentPosition!.longitude);
    final destination = widget.targetSafeZoneLocation!;

    try {
      final url = 'https://maps.googleapis.com/maps/api/directions/json';
      final params = {
        'origin': '${origin.latitude},${origin.longitude}',
        'destination': '${destination.latitude},${destination.longitude}',
        'key': ApiConstants.googleMapsApiKey,
      };

      final response = await _dio.get(url, queryParameters: params);

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['status'] == 'OK' && data['routes'] != null && data['routes'].isNotEmpty) {
          final route = data['routes'][0];
          final polylinePoints = route['overview_polyline']['points'];
          
          // Decode polyline points
          List<LatLng> points = _decodePolyline(polylinePoints);

          // Add marker for safe zone
          final safeZoneMarker = Marker(
            markerId: const MarkerId('target_safe_zone'),
            position: destination,
            infoWindow: InfoWindow(
              title: widget.targetSafeZoneName ?? 'Safe Zone',
              snippet: 'Destination',
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          );

          setState(() {
            // Keep existing markers but add safe zone marker
            final existingMarkers = Set<Marker>.from(_markers);
            existingMarkers.removeWhere((m) => m.markerId.value == 'target_safe_zone');
            existingMarkers.add(safeZoneMarker);
            _markers = existingMarkers;
            
            // Keep existing polylines but add/update safe zone route
            final existingPolylines = Set<Polyline>.from(_polylines);
            existingPolylines.removeWhere((p) => p.polylineId.value == 'route_to_safe_zone');
            existingPolylines.add(
              Polyline(
                polylineId: const PolylineId('route_to_safe_zone'),
                points: points,
                color: Colors.green,
                width: 5,
                patterns: [],
              ),
            );
            _polylines = existingPolylines;
          });

          // Move camera to show both origin and destination
          if (_mapController != null) {
            final bounds = _calculateBounds([origin, destination]);
            await _mapController!.animateCamera(
              CameraUpdate.newLatLngBounds(bounds, 100),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error drawing route to safe zone: $e'),
          ),
        );
      }
    }
  }

  LatLngBounds _calculateBounds(List<LatLng> points) {
    double minLat = points[0].latitude;
    double maxLat = points[0].latitude;
    double minLng = points[0].longitude;
    double maxLng = points[0].longitude;

    for (var point in points) {
      minLat = minLat < point.latitude ? minLat : point.latitude;
      maxLat = maxLat > point.latitude ? maxLat : point.latitude;
      minLng = minLng < point.longitude ? minLng : point.longitude;
      maxLng = maxLng > point.longitude ? maxLng : point.longitude;
    }

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0;
    int len = encoded.length;
    int lat = 0;
    int lng = 0;

    while (index < len) {
      int shift = 0;
      int result = 0;
      int b;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0) ? ~(result >> 1) : (result >> 1);
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0) ? ~(result >> 1) : (result >> 1);
      lng += dlng;

      points.add(LatLng(lat / 1e5, lng / 1e5));
    }
    return points;
  }

  Future<void> _goToCurrentLocation() async {
    if (_isLoadingLocation) {
      await _getCurrentLocation();
      return;
    }

    if (_currentPosition != null && _mapController != null) {
      await _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
            zoom: 14.0,
          ),
        ),
      );
      
      // Refresh nearby hospitals
      await _findNearbyHospitals(
        LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
      );
    } else {
      // If we don't have current location, try to get it
      await _getCurrentLocation();
    }
  }
  
  void _toggleDrawingMode() {
    setState(() {
      _isDrawingMode = !_isDrawingMode;
      if (!_isDrawingMode) {
        _cancelDrawing();
      }
    });
  }
  
  void _onMapTapped(LatLng position) {
    if (!_isDrawingMode) return;
    
    setState(() {
      if (_isDrawingSafeZone) {
        if (_drawingSafeZoneType == SafeZoneType.polygon) {
          _polygonPoints.add(position);
          _updateZoneOverlays(); // Update to show polygon preview
        } else {
          if (_circleCenter == null) {
            _circleCenter = position;
            _updateCircleOverlay();
          } else {
            // Calculate radius from center to tapped point
            _circleRadius = _calculateDistance(_circleCenter!, position);
            _updateCircleOverlay();
          }
        }
      } else {
        if (_drawingType == ZoneType.polygon) {
          _polygonPoints.add(position);
          _updateZoneOverlays(); // Update to show polygon preview
        } else {
          if (_circleCenter == null) {
            _circleCenter = position;
            _updateCircleOverlay();
          } else {
            // Calculate radius from center to tapped point
            _circleRadius = _calculateDistance(_circleCenter!, position);
            _updateCircleOverlay();
          }
        }
      }
    });
  }
  
  void _onMapLongPressed(LatLng position) {
    if (!_isDrawingMode) return;
    
    bool isCircleType = _isDrawingSafeZone 
        ? _drawingSafeZoneType == SafeZoneType.circle
        : _drawingType == ZoneType.circle;
    
    if (!isCircleType) return;
    
    if (_circleCenter == null) {
      setState(() {
        _circleCenter = position;
        _updateCircleOverlay();
      });
    } else if (_circleRadius > 0) {
      // Finish circle drawing
      _saveZone();
    }
  }
  
  void _updateCircleOverlay() {
    if (_circleCenter == null) return;
    
    final color = _isDrawingSafeZone ? Colors.green : Colors.orange;
    
    setState(() {
      _circles = {
        Circle(
          circleId: const CircleId('drawing_circle'),
          center: _circleCenter!,
          radius: _circleRadius,
          strokeColor: color,
          fillColor: color.withOpacity(0.2),
          strokeWidth: 3,
        ),
        ..._circles.where((c) => c.circleId.value != 'drawing_circle'),
      };
    });
  }
  
  double _calculateDistance(LatLng point1, LatLng point2) {
    return Geolocator.distanceBetween(
      point1.latitude,
      point1.longitude,
      point2.latitude,
      point2.longitude,
    );
  }
  
  void _cancelDrawing() {
    setState(() {
      _polygonPoints.clear();
      _circleCenter = null;
      _circleRadius = 0.0;
      _circles = _circles.where((c) => c.circleId.value != 'drawing_circle').toSet();
      _polygons = _polygons.where((p) => p.polygonId.value != 'drawing_polygon').toSet();
    });
  }
  
  Future<void> _finishPolygon() async {
    if (_polygonPoints.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least 3 points to create a polygon'),
        ),
      );
      return;
    }
    
    // Close the polygon by adding the first point at the end
    if (_polygonPoints.first != _polygonPoints.last) {
      _polygonPoints.add(_polygonPoints.first);
    }
    
    await _saveZone();
  }
  
  Future<void> _saveZone() async {
    // Validate circle
    bool isCircleType = _isDrawingSafeZone 
        ? _drawingSafeZoneType == SafeZoneType.circle
        : _drawingType == ZoneType.circle;
    
    if (isCircleType) {
      if (_circleCenter == null || _circleRadius <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please set circle center and radius'),
          ),
        );
        return;
      }
    }
    
    final user = _auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to mark zones')),
      );
      return;
    }
    
    // Show dialog to get zone name
    final nameController = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_isDrawingSafeZone ? 'Name the Safe Zone' : 'Name the Dangerous Zone'),
        content: TextField(
          controller: nameController,
          decoration: InputDecoration(
            hintText: _isDrawingSafeZone 
                ? 'Enter zone name (e.g., Safe Shelter, Evacuation Center)'
                : 'Enter zone name (e.g., Flood Area, Fire Zone)',
            border: const OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                Navigator.pop(context, true);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
    
    if (result != true || nameController.text.trim().isEmpty) {
      _cancelDrawing();
      return;
    }
    
    try {
      if (_isDrawingSafeZone) {
        final result = await _safeZoneRepository.saveZone(
          userId: user.uid,
          userName: user.displayName ?? user.email ?? 'Unknown User',
          name: nameController.text.trim(),
          type: _drawingSafeZoneType,
          polygonPoints: _drawingSafeZoneType == SafeZoneType.polygon ? _polygonPoints : null,
          center: _drawingSafeZoneType == SafeZoneType.circle ? _circleCenter : null,
          radius: _drawingSafeZoneType == SafeZoneType.circle ? _circleRadius : null,
        );
        
        result.fold(
          (failure) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error saving safe zone: ${failure.message}')),
              );
            }
          },
          (_) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Safe zone saved successfully')),
              );
              _cancelDrawing();
              setState(() => _isDrawingMode = false);
            }
          },
        );
      } else {
        final result = await _zoneRepository.saveZone(
          userId: user.uid,
          userName: user.displayName ?? user.email ?? 'Unknown User',
          name: nameController.text.trim(),
          type: _drawingType,
          polygonPoints: _drawingType == ZoneType.polygon ? _polygonPoints : null,
          center: _drawingType == ZoneType.circle ? _circleCenter : null,
          radius: _drawingType == ZoneType.circle ? _circleRadius : null,
        );
        
        result.fold(
          (failure) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error saving dangerous zone: ${failure.message}')),
              );
            }
          },
          (_) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Dangerous zone saved successfully')),
              );
              _cancelDrawing();
              setState(() => _isDrawingMode = false);
            }
          },
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }
  
  void _showDangerousZoneInfo(DangerousZone zone) {
    final user = _auth.currentUser;
    final canDelete = user != null && user.uid == zone.userId;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(zone.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Created by: ${zone.userName}'),
            const SizedBox(height: 8),
            Text('Created: ${_formatDate(zone.createdAt)}'),
            Text('Expires: ${_formatDate(zone.expiresAt)}'),
            const SizedBox(height: 8),
            Text('Type: ${zone.type == ZoneType.polygon ? "Polygon" : "Circle"}'),
            if (zone.type == ZoneType.circle && zone.radius != null)
              Text('Radius: ${(zone.radius! / 1000).toStringAsFixed(2)} km'),
          ],
        ),
        actions: [
          if (canDelete)
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await _deleteDangerousZone(zone.id);
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
  
  void _showSafeZoneInfo(SafeZone zone) {
    final user = _auth.currentUser;
    final canDelete = user != null && user.uid == zone.userId;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(zone.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Created by: ${zone.userName}'),
            const SizedBox(height: 8),
            Text('Created: ${_formatDate(zone.createdAt)}'),
            Text('Expires: ${_formatDate(zone.expiresAt)}'),
            const SizedBox(height: 8),
            Text('Type: ${zone.type == SafeZoneType.polygon ? "Polygon" : "Circle"}'),
            if (zone.type == SafeZoneType.circle && zone.radius != null)
              Text('Radius: ${(zone.radius! / 1000).toStringAsFixed(2)} km'),
          ],
        ),
        actions: [
          if (canDelete)
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await _deleteSafeZone(zone.id);
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
  
  Future<void> _deleteDangerousZone(String zoneId) async {
    try {
      final result = await _zoneRepository.deleteZone(zoneId);
      result.fold(
        (failure) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error deleting zone: ${failure.message}')),
            );
          }
        },
        (_) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Zone deleted successfully')),
            );
          }
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }
  
  Future<void> _deleteSafeZone(String zoneId) async {
    try {
      final result = await _safeZoneRepository.deleteZone(zoneId);
      result.fold(
        (failure) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error deleting zone: ${failure.message}')),
            );
          }
        },
        (_) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Zone deleted successfully')),
            );
          }
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }
  
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}

