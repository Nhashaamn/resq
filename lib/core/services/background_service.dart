import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:sensors_plus/sensors_plus.dart';

class BackgroundShakeService {
  static const String notificationChannelId = 'shake_detection_channel';
  static const String notificationChannelName = 'Shake Detection';
  static const int notificationId = 888;

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

    // Create notification channel for Android
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      notificationChannelId,
      notificationChannelName,
      description: 'Notifications for shake detection',
      importance: Importance.high,
      playSound: true,
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

    // Shake detection variables
    DateTime? lastShakeTime;
    const Duration shakeCooldown = Duration(seconds: 3);
    const double shakeThreshold = 25.0; // Light shake threshold

    double lastX = 0.0;
    double lastY = 0.0;
    double lastZ = 0.0;

    // Initialize local notifications in background isolate
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

    // Create notification channel for Android
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      notificationChannelId,
      notificationChannelName,
      description: 'Notifications for shake detection',
      importance: Importance.high,
      playSound: true,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // Start listening to accelerometer
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

        // Update last values
        lastX = event.x;
        lastY = event.y;
        lastZ = event.z;

        // Check if shake threshold is exceeded and cooldown has passed
        if (accelerationChange > shakeThreshold) {
          final now = DateTime.now();
          if (lastShakeTime == null ||
              now.difference(lastShakeTime!) > shakeCooldown) {
            lastShakeTime = now;

            // Show notification
            flutterLocalNotificationsPlugin.show(
              notificationId,
              'Are you OK?',
              'We detected a sudden movement. Are you safe and okay?',
              const NotificationDetails(
                android: AndroidNotificationDetails(
                  notificationChannelId,
                  notificationChannelName,
                  channelDescription: 'Notifications for shake detection',
                  importance: Importance.high,
                  priority: Priority.high,
                  playSound: true,
                  icon: '@mipmap/ic_launcher',
                ),
                iOS: DarwinNotificationDetails(
                  presentAlert: true,
                  presentBadge: true,
                  presentSound: true,
                ),
              ),
            );
          }
        }
      },
      onError: (error) {
        // Handle error silently
      },
    );

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

