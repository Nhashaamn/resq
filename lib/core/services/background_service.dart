import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:sensors_plus/sensors_plus.dart';

class BackgroundShakeService {
  static const String notificationChannelId = 'shake_detection_channel';
  static const String notificationChannelName = 'Shake Detection';
  static const int notificationId = 888; // Foreground service notification ID
  static const int emergencyNotificationId = 999; // Emergency notification ID (different from foreground)

  static Future<void> initializeService() async {
    // Background service is not supported on web
    if (kIsWeb) {
      return;
    }
    final service = FlutterBackgroundService();

    // Initialize local notifications
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
    );

    // Create notification channel for Android with maximum importance
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      notificationChannelId,
      notificationChannelName,
      description: 'Notifications for shake detection',
      importance: Importance.max, // Changed to max for emergency notifications
      playSound: true,
      enableVibration: true,
      showBadge: true,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // Configure Android foreground service
    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: false,
        isForegroundMode: true,
        notificationChannelId: notificationChannelId,
        initialNotificationTitle: 'ResQ',
        initialNotificationContent: 'Shake detection is active',
        foregroundServiceNotificationId: notificationId,
      ),
      iosConfiguration: IosConfiguration(
        autoStart: false,
        onForeground: onStart,
        onBackground: onIosBackground,
      ),
    );
  }

  @pragma('vm:entry-point')
  static Future<bool> onIosBackground(ServiceInstance service) async {
    return true;
  }

  @pragma('vm:entry-point')
  static void onStart(ServiceInstance service) async {
    if (service is AndroidServiceInstance) {
      service.on('setAsForeground').listen((event) {
        service.setAsForegroundService();
      });

      service.on('setAsBackground').listen((event) {
        service.setAsBackgroundService();
      });
    }

    service.on('stopService').listen((event) {
      service.stopSelf();
    });

    // Initialize local notifications in background isolate first
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    // Handle emergency timer cancellation
    // Use a Map to store active timers by notification ID
    final Map<int, Timer> activeEmergencyTimers = {};
    final Map<int, bool> emergencyTimerCancelled = {};
    
    service.on('cancel_emergency_timer').listen((event) {
      final timerId = event?['notificationId'] as int? ?? emergencyNotificationId;
      emergencyTimerCancelled[timerId] = true;
      activeEmergencyTimers[timerId]?.cancel();
      activeEmergencyTimers.remove(timerId);
      flutterLocalNotificationsPlugin.cancel(timerId);
      debugPrint('Emergency timer cancelled for notification ID: $timerId');
    });

    // Shake detection variables
    DateTime? lastShakeTime;
    const Duration shakeCooldown = Duration(seconds: 3);
    const double shakeThreshold = 25.0; // Light shake threshold

    double lastX = 0.0;
    double lastY = 0.0;
    double lastZ = 0.0;

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification action tap in background service
        if (response.actionId == 'ok_action') {
          // User pressed "I'm OK" - cancel emergency timer
          service.invoke('cancel_emergency_timer');
        }
      },
    );

    // Create notification channel for Android with maximum importance for full-screen intents
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      notificationChannelId,
      notificationChannelName,
      description: 'Notifications for shake detection',
      importance: Importance.max, // Maximum importance for full-screen intents
      playSound: true,
      enableVibration: true,
      showBadge: true,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // Start listening to accelerometer
    debugPrint('Starting accelerometer listener in background service...');
    accelerometerEventStream().listen(
      (AccelerometerEvent event) {
        // Calculate the change in acceleration
        final double deltaX = (event.x - lastX).abs();
        final double deltaY = (event.y - lastY).abs();
        final double deltaZ = (event.z - lastZ).abs();

        // Calculate total acceleration change
        final double accelerationChange = sqrt(
          deltaX * deltaX + deltaY * deltaY + deltaZ * deltaZ,
        );

        // Update last values (only if we have previous values)
        if (lastX != 0.0 || lastY != 0.0 || lastZ != 0.0) {
          lastX = event.x;
          lastY = event.y;
          lastZ = event.z;
        } else {
          // Initialize first values
          lastX = event.x;
          lastY = event.y;
          lastZ = event.z;
          return; // Skip first reading
        }

        // Check if shake threshold is exceeded and cooldown has passed
        if (accelerationChange > shakeThreshold) {
          final now = DateTime.now();
          if (lastShakeTime == null ||
              now.difference(lastShakeTime!) > shakeCooldown) {
            lastShakeTime = now;
            
            debugPrint('🚨 SHAKE DETECTED! Acceleration change: $accelerationChange (threshold: $shakeThreshold)');

            // Cancel any existing emergency timer
            activeEmergencyTimers[emergencyNotificationId]?.cancel();
            activeEmergencyTimers.remove(emergencyNotificationId);
            emergencyTimerCancelled[emergencyNotificationId] = false;

            // Show notification with actions and start 10-second timer
            _showEmergencyNotificationWithTimer(
              flutterLocalNotificationsPlugin,
              service,
              activeEmergencyTimers,
              emergencyTimerCancelled,
            );
          } else {
            debugPrint('Shake detected but cooldown active. Remaining: ${shakeCooldown.inSeconds - now.difference(lastShakeTime!).inSeconds}s');
          }
        }
      },
      onError: (error) {
        debugPrint('Accelerometer error in background service: $error');
      },
    );
    debugPrint('Accelerometer listener started successfully');

    // Keep service alive
    Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (service is AndroidServiceInstance) {
        if (await service.isForegroundService()) {
          service.setForegroundNotificationInfo(
            title: "ResQ",
            content: "Shake detection is active",
          );
        }
      }
    });
  }

  static Future<void> _showEmergencyNotificationWithTimer(
    FlutterLocalNotificationsPlugin notificationsPlugin,
    ServiceInstance service,
    Map<int, Timer> activeEmergencyTimers,
    Map<int, bool> emergencyTimerCancelled,
  ) async {
    const int countdownSeconds = 10;
    int remainingSeconds = countdownSeconds;

    // Get current user
    final firebaseUser = firebase_auth.FirebaseAuth.instance.currentUser;
    debugPrint('Launching emergency alert screen. User: ${firebaseUser?.uid ?? "null"}');
    
    // Get emergency number from Firestore
    EmergencyContact? emergencyContact;
    if (firebaseUser != null) {
      final firestore = FirebaseFirestore.instance;
      try {
        final userDoc = await firestore.collection('users').doc(firebaseUser.uid).get();
        if (userDoc.exists) {
          final data = userDoc.data();
          if (data != null && 
              data['emergencyNumber'] != null && 
              data['emergencyEmail'] != null &&
              (data['emergencyNumber'] as String).isNotEmpty &&
              (data['emergencyEmail'] as String).isNotEmpty) {
            emergencyContact = EmergencyContact(
              phoneNumber: data['emergencyNumber'] as String,
              email: data['emergencyEmail'] as String,
            );
          }
        }
      } catch (e) {
        debugPrint('Failed to get emergency contact: $e');
      }
    }

    // Show full-screen intent notification to launch the app
    // This will automatically launch the app even when killed
    final androidDetails = AndroidNotificationDetails(
      notificationChannelId,
      notificationChannelName,
      channelDescription: 'Notifications for shake detection',
      importance: Importance.max,
      priority: Priority.max,
      playSound: true,
      enableVibration: true,
      icon: '@mipmap/ic_launcher',
      fullScreenIntent: true, // This will launch the app in full screen even when killed
      category: AndroidNotificationCategory.alarm,
      autoCancel: false,
      ongoing: true, // Keep notification active
      visibility: NotificationVisibility.public,
      // Use intent to launch app
      channelShowBadge: true,
    );

    await notificationsPlugin.show(
      emergencyNotificationId,
      'Panic mode triggered',
      'Alert will be sent automatically when timer runs out.',
      NotificationDetails(
        android: androidDetails,
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          categoryIdentifier: 'shake_detection',
          interruptionLevel: InterruptionLevel.critical,
        ),
      ),
      payload: '/emergency-alert', // Pass route as payload
    );
    
    // Also try to launch the app directly using platform channel if available
    // The fullScreenIntent should handle this, but we can also use service.invoke
    try {
      if (service is AndroidServiceInstance) {
        // Bring app to foreground
        service.setForegroundNotificationInfo(
          title: 'Panic mode triggered',
          content: 'Emergency alert screen',
        );
      }
    } catch (e) {
      debugPrint('Error setting foreground notification: $e');
    }

    // Start countdown timer
    final timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (emergencyTimerCancelled[emergencyNotificationId] == true) {
        timer.cancel();
        activeEmergencyTimers.remove(emergencyNotificationId);
        await notificationsPlugin.cancel(emergencyNotificationId);
        debugPrint('Emergency timer cancelled by user');
        return;
      }

      remainingSeconds--;
      
      if (remainingSeconds <= 0) {
        // Timer expired - send emergency message
        timer.cancel();
        activeEmergencyTimers.remove(emergencyNotificationId);
        await notificationsPlugin.cancel(emergencyNotificationId);
        debugPrint('Emergency timer expired. Sending emergency message...');
        
        if (firebaseUser != null && 
            emergencyContact != null && 
            emergencyTimerCancelled[emergencyNotificationId] != true) {
          await _sendEmergencyMessage(
            firebaseUser.uid,
            firebaseUser.displayName ?? firebaseUser.email ?? 'Unknown User',
            emergencyContact.phoneNumber,
            emergencyContact.email,
          );
          debugPrint('Emergency message sent successfully');
        } else {
          debugPrint('No emergency contact found or timer was cancelled');
        }
      }
    });
    
    // Store the timer
    activeEmergencyTimers[emergencyNotificationId] = timer;
    debugPrint('Emergency alert screen launched');
  }


  static Future<void> _sendEmergencyMessage(
    String userId,
    String userName,
    String toPhoneNumber,
    String toEmail,
  ) async {
    try {
      final firestore = FirebaseFirestore.instance;
      
      // Create emergency message
      final emergencyMessage = '🚨 EMERGENCY ALERT 🚨\n\n'
          'User: $userName\n'
          'Time: ${DateTime.now().toString()}\n\n'
          'Shake detected and user did not respond. Please check on this person immediately.';

      // Note: Getting location in background service requires additional setup
      // For now, we'll send without location

      // Send to Firestore
      await firestore.collection('private_emergency_messages').add({
        'fromUserId': userId,
        'fromUserName': userName,
        'toEmail': toEmail,
        'toPhoneNumber': toPhoneNumber,
        'message': emergencyMessage,
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
      });
    } catch (e) {
      // Silently fail - emergency message sending shouldn't crash the service
      debugPrint('Error sending emergency message: $e');
    }
  }

  static Future<void> startService() async {
    if (kIsWeb) return;
    final service = FlutterBackgroundService();
    await service.startService();
  }

  static Future<void> stopService() async {
    if (kIsWeb) return;
    final service = FlutterBackgroundService();
    service.invoke("stopService");
  }

  static Future<bool> isServiceRunning() async {
    if (kIsWeb) return false;
    final service = FlutterBackgroundService();
    return await service.isRunning();
  }
}

// Helper class to hold emergency contact info
class EmergencyContact {
  final String phoneNumber;
  final String email;

  EmergencyContact({
    required this.phoneNumber,
    required this.email,
  });
}

