import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:resq/core/theme/app_theme.dart';
import 'package:resq/features/func/domain/entities/safe_zone.dart';
import 'package:resq/features/func/presentation/providers/nearby_safe_zones_provider.dart';

class SafeZoneCard extends ConsumerWidget {
  const SafeZoneCard({super.key});

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    }
  }

  String _formatDistance(double distanceInKm) {
    if (distanceInKm < 1) {
      return '${(distanceInKm * 1000).toStringAsFixed(0)}m away';
    } else {
      return '${distanceInKm.toStringAsFixed(1)}km away';
    }
  }

  Future<void> _openNativeMapApp(BuildContext context, LatLng destination, String destinationName) async {
    try {
      // Get user's current location
      Position? currentPosition;
      try {
        bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (serviceEnabled) {
          LocationPermission permission = await Geolocator.checkPermission();
          if (permission == LocationPermission.denied) {
            permission = await Geolocator.requestPermission();
          }
          if (permission == LocationPermission.whileInUse || 
              permission == LocationPermission.always) {
            currentPosition = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.high,
            );
          }
        }
      } catch (e) {
        // If we can't get location, we'll still open map without origin
        debugPrint('Error getting current location: $e');
      }

      Uri mapUrl;
      
      if (Platform.isAndroid) {
        // Android: Use Google Maps navigation
        if (currentPosition != null) {
          // With origin and destination
          mapUrl = Uri.parse(
            'google.navigation:q=${destination.latitude},${destination.longitude}'
          );
        } else {
          // Without origin, just show destination
          mapUrl = Uri.parse(
            'geo:${destination.latitude},${destination.longitude}?q=${destination.latitude},${destination.longitude}(${Uri.encodeComponent(destinationName)})'
          );
        }
      } else if (Platform.isIOS) {
        // iOS: Use Apple Maps
        if (currentPosition != null) {
          // With origin and destination
          mapUrl = Uri.parse(
            'http://maps.apple.com/?saddr=${currentPosition.latitude},${currentPosition.longitude}&daddr=${destination.latitude},${destination.longitude}&dirflg=d'
          );
        } else {
          // Without origin, just show destination
          mapUrl = Uri.parse(
            'http://maps.apple.com/?daddr=${destination.latitude},${destination.longitude}&dirflg=d'
          );
        }
      } else {
        // Fallback for other platforms
        mapUrl = Uri.parse(
          'https://www.google.com/maps/dir/?api=1&destination=${destination.latitude},${destination.longitude}'
        );
      }

      if (await canLaunchUrl(mapUrl)) {
        await launchUrl(
          mapUrl,
          mode: LaunchMode.externalApplication,
        );
      } else {
        // Fallback to web-based Google Maps
        final webUrl = Uri.parse(
          'https://www.google.com/maps/dir/?api=1&destination=${destination.latitude},${destination.longitude}'
        );
        if (await canLaunchUrl(webUrl)) {
          await launchUrl(webUrl, mode: LaunchMode.externalApplication);
        } else {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Unable to open map application'),
                backgroundColor: AppTheme.errorRed,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening map: $e'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nearbyZonesState = ref.watch(nearbySafeZonesProvider);
    final nearestZone = nearbyZonesState.nearestZone;

    // If no nearby zones, show default/empty state or hide the card
    if (nearestZone == null) {
      return const SizedBox.shrink();
    }
    
    // Get safe zone location
    LatLng? safeZoneLocation;
    if (nearestZone.zone.type == SafeZoneType.circle && nearestZone.zone.center != null) {
      safeZoneLocation = nearestZone.zone.center;
    } else if (nearestZone.zone.polygonPoints != null && 
               nearestZone.zone.polygonPoints!.isNotEmpty) {
      // For polygon, use the first point as the location
      safeZoneLocation = nearestZone.zone.polygonPoints!.first;
    }
    
    return InkWell(
      onTap: safeZoneLocation != null
          ? () => _openNativeMapApp(context, safeZoneLocation!, nearestZone.zone.name)
          : null,
      borderRadius: BorderRadius.circular(20),
      child: Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.backgroundWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.green.withOpacity(0.5),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.2),
            blurRadius: 16,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: Colors.green,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Safe Zone Nearby',
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.green.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: AppTheme.textPrimary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _formatTimeAgo(nearestZone.createdAt),
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${_formatDistance(nearestZone.distanceInKm)} from your location there is a safe zone: ${nearestZone.zone.name}',
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          height: 1.4,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }
}

