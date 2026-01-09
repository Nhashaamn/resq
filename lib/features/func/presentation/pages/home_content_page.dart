import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:resq/core/services/android_shake_service.dart';
import 'package:resq/core/services/notification_services.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:resq/core/theme/app_theme.dart';
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

    NotificationServices notificationServices = NotificationServices();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Start listening to accelerometer for in-app shake detection
    _startShakeDetection();
    // Start background service for when app is closed
    _startBackgroundService();
    // Request notification permissions (already requested in main.dart, but ensure it's done)
    notificationServices.requestPermission();
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
      // App is in foreground - stop Android native service, use in-app detection
      _isAppInForeground = true;
      AndroidShakeService.stopService();
      _startShakeDetection();
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      // App is in background - stop in-app detection, start Android native service
      _isAppInForeground = false;
      _accelerometerSubscription?.cancel();
      AndroidShakeService.startService();
    }
  }

  Future<void> _startBackgroundService() async {
    // Use Android native shake service for better reliability
    // This works even when app is killed
    await AndroidShakeService.startService();
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
            // Emergency Message Notification
            Consumer(
              builder: (context, ref, child) {
                final privateMessagesState = ref.watch(privateEmergencyMessageProvider);
                final unreadCount = privateMessagesState.messages.where((m) => !m.isRead).length;
                
                if (unreadCount == 0) {
                  return const SizedBox.shrink();
                }
                
                return GestureDetector(
                  onTap: () => context.go('/community/private-messages'),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.errorRed.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppTheme.errorRed.withOpacity(0.3),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.errorRed.withOpacity(0.2),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppTheme.errorRed.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.emergency_rounded,
                            color: AppTheme.errorRed,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      'You have received $unreadCount emergency message${unreadCount > 1 ? 's' : ''}',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: AppTheme.errorRed,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppTheme.errorRed,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      '$unreadCount',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: AppTheme.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Tap to view emergency messages',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: AppTheme.errorRed,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 16),
            WarningCard(),
            SizedBox(height: 16),
            SafeZoneCard(),
            SizedBox(height: 16),
            EmergencyCard(),
            SizedBox(height: 16,),
            const GuideWidgets(),
            SizedBox(height: 16),
            // Test Notification Button (for experimentation)
          
            SizedBox(height: 16),
          ],
        ),
      ),
      )
    );
  }
}
