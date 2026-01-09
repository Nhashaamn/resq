import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resq/core/theme/app_theme.dart';
import 'package:resq/features/auth/presentation/providers/auth_provider.dart';
import 'package:resq/features/func/presentation/providers/emergency_number_provider.dart';
import 'package:resq/features/func/presentation/providers/private_emergency_message_provider.dart';

class EmergencyAlertPage extends ConsumerStatefulWidget {
  const EmergencyAlertPage({super.key});

  @override
  ConsumerState<EmergencyAlertPage> createState() => _EmergencyAlertPageState();
}

class _EmergencyAlertPageState extends ConsumerState<EmergencyAlertPage>
    with SingleTickerProviderStateMixin {
  Timer? _countdownTimer;
  int _remainingSeconds = 10;
  bool _isCancelled = false;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    // Keep screen on
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    // Prevent back button
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    
    // Pulse animation for the timer
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    
    _startCountdown();
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || _isCancelled) {
        timer.cancel();
        return;
      }

      setState(() {
        _remainingSeconds--;
      });

      if (_remainingSeconds <= 0) {
        timer.cancel();
        _sendEmergencyMessage();
      }
    });
  }

  Future<void> _sendEmergencyMessage() async {
    if (_isCancelled) return;
    
    try {
      // Cancel emergency timer in background service
      FlutterBackgroundService().invoke('cancel_emergency_timer');
      
      // Reload emergency number to get latest value
      final emergencyNumberState = ref.read(emergencyNumberProvider);
      final emergencyNumber = emergencyNumberState.emergencyNumber;
      
      if (emergencyNumber != null && 
          emergencyNumber.phoneNumber.isNotEmpty && 
          emergencyNumber.email.isNotEmpty) {
        final authState = ref.read(authStateProvider);
        final userName = authState.user?.name ?? 
                         authState.user?.email ?? 
                         'Unknown User';
        
        // Create emergency message
        final emergencyMessage = '🚨 EMERGENCY ALERT 🚨\n\n'
            'User: $userName\n'
            'Time: ${DateTime.now().toString()}\n\n'
            'Panic mode was triggered and user did not respond. Please check on this person immediately.';

        // Send private emergency message
        await ref.read(privateEmergencyMessageProvider.notifier).sendPrivateEmergencyMessage(
          toEmail: emergencyNumber.email,
          toPhoneNumber: emergencyNumber.phoneNumber,
          message: emergencyMessage,
        );
      }
      
      // Close the screen
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      debugPrint('Error sending emergency message: $e');
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  void _handleConfirm() {
    _isCancelled = true;
    _countdownTimer?.cancel();
    _pulseController.stop();
    
    // Cancel emergency timer in background service
    FlutterBackgroundService().invoke('cancel_emergency_timer');
    
    // Close the screen
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  void _handleDecline() {
    // Decline means send emergency immediately
    _isCancelled = true;
    _countdownTimer?.cancel();
    _pulseController.stop();
    _sendEmergencyMessage();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _pulseController.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // Prevent back button
      child: Scaffold(
        backgroundColor: AppTheme.errorRed,
        body: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    const Icon(
                      Icons.notifications_active,
                      color: Colors.white,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Panic mode triggered',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: Colors.white,
                      ),
                      onPressed: _handleConfirm,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  'Alert will be sent automatically when timer runs out.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ),
              const Spacer(),
              
              // Circular Countdown Timer
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.1 + (_pulseController.value * 0.1)),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Progress indicator
                        SizedBox(
                          width: 200,
                          height: 200,
                          child: CircularProgressIndicator(
                            value: _remainingSeconds / 10,
                            strokeWidth: 8,
                            backgroundColor: Colors.white.withOpacity(0.3),
                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        // Countdown number
                        Text(
                          '$_remainingSeconds',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 72,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              
              const Spacer(),
              
              // Action Buttons
              Padding(
                padding: const EdgeInsets.all(40.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Confirm Button (Green)
                    Column(
                      children: [
                        GestureDetector(
                          onTap: _handleConfirm,
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: const BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 40,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Confirm',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    
                    // Decline Button (Red)
                    Column(
                      children: [
                        GestureDetector(
                          onTap: _handleDecline,
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: AppTheme.errorRed,
                              size: 40,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Decline',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

