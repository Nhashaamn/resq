import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:resq/core/services/background_service.dart';
import 'package:resq/features/func/presentation/providers/emergency_number_provider.dart';
import 'package:resq/features/func/presentation/widgets/appbar.dart';
import 'package:resq/features/func/presentation/widgets/guide_widgets.dart';
import 'package:resq/features/func/presentation/widgets/homepage_widgets/emergency_card.dart';
import 'package:resq/features/func/presentation/widgets/homepage_widgets/homepage_card.dart';
import 'package:resq/features/func/presentation/widgets/homepage_widgets/warning_card.dart';
import 'package:resq/features/func/presentation/widgets/homepage_widgets/safe_zone_card.dart';
import 'package:resq/features/func/presentation/widgets/shake_detection_popup.dart';
import 'package:resq/features/func/presentation/providers/address_provider.dart';
import 'package:resq/features/func/presentation/providers/private_emergency_message_provider.dart';
import 'package:resq/features/auth/presentation/providers/auth_provider.dart';

class HomeContentPage extends ConsumerStatefulWidget {
  const HomeContentPage({super.key});

  @override
  ConsumerState<HomeContentPage> createState() => _HomeContentPageState();
}

class _HomeContentPageState extends ConsumerState<HomeContentPage>
    with WidgetsBindingObserver {
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  DateTime? _lastShakeTime;
  static const Duration _shakeCooldown = Duration(seconds: 3);
  static const double _shakeThreshold = 25.0; // Light shake threshold

  // Previous acceleration values for calculating change
  double _lastX = 0.0;
  double _lastY = 0.0;
  double _lastZ = 0.0;

  bool _addressLoaded = false;
  bool _isAppInForeground = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Start listening to accelerometer for in-app shake detection
    _startShakeDetection();
    // Start background service for when app is closed
    _startBackgroundService();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Load address after dependencies are available (only once)
    if (!_addressLoaded) {
      _addressLoaded = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ref.read(addressProvider.notifier).loadAddress();
        }
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // App is in foreground - stop background service, use in-app detection
      _isAppInForeground = true;
      BackgroundShakeService.stopService();
      _startShakeDetection();
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      // App is in background - stop in-app detection, start background service
      _isAppInForeground = false;
      _accelerometerSubscription?.cancel();
      BackgroundShakeService.startService();
    }
  }

  Future<void> _startBackgroundService() async {
    // Background service will handle shake detection when app is closed
    await BackgroundShakeService.startService();
  }

  void _startShakeDetection() {
    _accelerometerSubscription?.cancel();
    _accelerometerSubscription = accelerometerEventStream().listen(
      (AccelerometerEvent event) {
        if (_isAppInForeground) {
          _detectShake(event.x, event.y, event.z);
        }
      },
      onError: (error) {
        // Handle error silently or log it
        print('Accelerometer error: $error');
      },
    );
  }

  void _detectShake(double x, double y, double z) {
    // Calculate the change in acceleration
    final double deltaX = (x - _lastX).abs();
    final double deltaY = (y - _lastY).abs();
    final double deltaZ = (z - _lastZ).abs();
    
    // Calculate total acceleration change
    final double accelerationChange = sqrt(
      deltaX * deltaX + deltaY * deltaY + deltaZ * deltaZ,
    );
    
    // Update last values
    _lastX = x;
    _lastY = y;
    _lastZ = z;
    
    // Check if shake threshold is exceeded and cooldown has passed
    if (accelerationChange > _shakeThreshold) {
      final now = DateTime.now();
      if (_lastShakeTime == null || 
          now.difference(_lastShakeTime!) > _shakeCooldown) {
        _lastShakeTime = now;
        _showShakeDialog();
      }
    }
  }

  Future<void> _sendEmergencyMessage() async {
    try {
      // Reload emergency number to get latest value
      final emergencyNumberState = ref.read(emergencyNumberProvider);
      final emergencyNumber = emergencyNumberState.emergencyNumber;
      
      if (emergencyNumber == null || 
          emergencyNumber.phoneNumber.isEmpty || 
          emergencyNumber.email.isEmpty) {
        // No emergency contact set, don't send message
        return;
      }

      final authState = ref.read(authStateProvider);
      final userName = authState.user?.name ?? 
                       authState.user?.email ?? 
                       'Unknown User';
      
      // Create emergency message
      final emergencyMessage = '🚨 EMERGENCY ALERT 🚨\n\n'
          'User: $userName\n'
          'Time: ${DateTime.now().toString()}\n\n'
          'Shake detected and user did not respond. Please check on this person immediately.';

      // Send private emergency message
      await ref.read(privateEmergencyMessageProvider.notifier).sendPrivateEmergencyMessage(
        toEmail: emergencyNumber.email,
        toPhoneNumber: emergencyNumber.phoneNumber,
        message: emergencyMessage,
      );
    } catch (e) {
      // Silently fail - emergency message sending shouldn't crash the app
      debugPrint('Error sending emergency message: $e');
    }
  }

  void _showShakeDialog() {
    if (!mounted || !_isAppInForeground) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ShakeDetectionPopup(
        onOkPressed: () {
          Navigator.of(context).pop();
        },
        onNeedHelpPressed: () {
          Navigator.of(context).pop();
        },
        onAutoClose: () {
          // Send emergency message when auto-closing
          _sendEmergencyMessage();
        },
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _accelerometerSubscription?.cancel();
    // Don't stop background service on dispose - let it continue when app closes
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:  AppbarWidget(title: 'Res Q', icon: Icons.settings, onTap: () {
        context.go('/setting');
      }),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
          children: [
            HomepageCard(
              title: 'Every thing looks normal.Have a Great Day!',
            ),
            SizedBox(height: 16),
            WarningCard(),
            SizedBox(height: 16),
            SafeZoneCard(),
            SizedBox(height: 16),
            EmergencyCard(),
            SizedBox(height: 16,),
            const GuideWidgets(),
          ],
        ),
      ),
      )
    );
  }
}
