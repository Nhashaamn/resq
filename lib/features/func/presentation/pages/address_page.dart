import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:resq/core/theme/app_theme.dart';
import 'package:resq/features/func/presentation/providers/address_provider.dart';
import 'package:resq/features/auth/presentation/widgets/common_widgets/app_gradient_button.dart';
import 'package:resq/features/auth/presentation/widgets/common_widgets/app_error_text.dart';
import 'package:resq/features/auth/presentation/widgets/common_widgets/app_text_field.dart';
import 'package:resq/features/func/presentation/widgets/appbar.dart';

class AddressPage extends ConsumerStatefulWidget {
  const AddressPage({super.key});

  @override
  ConsumerState<AddressPage> createState() => _AddressPageState();
}

class _AddressPageState extends ConsumerState<AddressPage> {
  final _cityController = TextEditingController();
  final _countryController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  GoogleMapController? _mapController;
  Position? _currentPosition;
  bool _isLoadingLocation = true;
  LatLng? _selectedLocation;
  bool _isSaving = false;

  static const CameraPosition _defaultPosition = CameraPosition(
    target: LatLng(33.6844, 73.0479), // Islamabad, Pakistan
    zoom: 14.0,
  );

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _loadExistingAddress();
  }

  void _loadExistingAddress() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final address = ref.read(addressProvider).address;
      if (address != null) {
        _cityController.text = address.city;
        _countryController.text = address.country;
        if (address.latitude != null && address.longitude != null) {
          _selectedLocation = LatLng(address.latitude!, address.longitude!);
          _moveToLocation(_selectedLocation!);
        }
      }
    });
  }

  @override
  void dispose() {
    _cityController.dispose();
    _countryController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _isLoadingLocation = false;
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _isLoadingLocation = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _isLoadingLocation = false;
        });
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = position;
        _selectedLocation = LatLng(position.latitude, position.longitude);
        _isLoadingLocation = false;
      });

      if (_mapController != null) {
        _moveToLocation(_selectedLocation!);
      }
    } catch (e) {
      setState(() {
        _isLoadingLocation = false;
      });
    }
  }

  void _moveToLocation(LatLng location) {
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: location,
          zoom: 14.0,
        ),
      ),
    );
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final success = await ref.read(addressProvider.notifier).saveAddress(
      _cityController.text.trim(),
      _countryController.text.trim(),
      _selectedLocation?.latitude,
      _selectedLocation?.longitude,
    );

    setState(() {
      _isSaving = false;
    });

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Address saved successfully'),
          backgroundColor: AppTheme.successGreen,
        ),
      );
      context.go('/home');
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ref.read(addressProvider).error ?? 'Failed to save address',
          ),
          backgroundColor: AppTheme.errorRed,
        ),
      );
    }
  }

  CameraPosition get _initialCameraPosition {
    if (_selectedLocation != null) {
      return CameraPosition(
        target: _selectedLocation!,
        zoom: 14.0,
      );
    }
    if (_currentPosition != null) {
      return CameraPosition(
        target: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        zoom: 14.0,
      );
    }
    return _defaultPosition;
  }

  @override
  Widget build(BuildContext context) {
    final addressState = ref.watch(addressProvider);

    return Scaffold(
      appBar: AppbarWidget(title: "address",icon: Icons.close, onTap: () => context.go('/home')),
      body: Stack(
        children: [
          Column(
            children: [
              // Map Section
              Expanded(
                flex: 2,
                child: Stack(
                  children: [
                    GoogleMap(
                      initialCameraPosition: _initialCameraPosition,
                      onMapCreated: (GoogleMapController controller) {
                        _mapController = controller;
                        if (_selectedLocation != null) {
                          _moveToLocation(_selectedLocation!);
                        } else if (_currentPosition != null) {
                          _moveToLocation(
                            LatLng(
                              _currentPosition!.latitude,
                              _currentPosition!.longitude,
                            ),
                          );
                        }
                      },
                      onTap: (LatLng location) {
                        setState(() {
                          _selectedLocation = location;
                        });
                        _moveToLocation(location);
                      },
                      myLocationButtonEnabled: true,
                      myLocationEnabled: true,
                      mapType: MapType.normal,
                      markers: _selectedLocation != null
                          ? {
                              Marker(
                                markerId: const MarkerId('selected_location'),
                                position: _selectedLocation!,
                                infoWindow: const InfoWindow(
                                  title: 'Selected Location',
                                ),
                              ),
                            }
                          : {},
                    ),
                    if (_isLoadingLocation)
                      const Center(
                        child: CircularProgressIndicator(),
                      ),
                    Positioned(
                      bottom: 16,
                      right: 16,
                      child: FloatingActionButton(
                        onPressed: _getCurrentLocation,
                        backgroundColor: AppTheme.primary,
                        child: const Icon(
                          Icons.my_location,
                          color: AppTheme.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Form Section
              Expanded(
                flex: 1,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    color: AppTheme.backgroundWhite,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'Enter Your Address',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 24),
                          AppTextField(
                            controller: _cityController,
                            label: 'City',
                            hintText: 'Enter your city',
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'City is required';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          AppTextField(
                            controller: _countryController,
                            label: 'Country',
                            hintText: 'Enter your country',
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Country is required';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),
                          AppErrorText(error: addressState.error),
                          AppGradientButton(
                            text: 'Save Address',
                            isLoading: _isSaving || addressState.isLoading,
                            onPressed: _handleSave,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

