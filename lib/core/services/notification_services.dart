import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform;
import 'package:flutter/material.dart' show TargetPlatform;

class NotificationServices {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  /// Initialize local notifications plugin
  Future<void> initialize() async {
    if (kIsWeb || _isInitialized) return;

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _localNotifications.initialize(initializationSettings);
    _isInitialized = true;
  }

  Future<bool> requestPermission() async {
    if (kIsWeb) return false;
    
    // Request Firebase Cloud Messaging permissions (for push notifications)
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: true,
      criticalAlert: true,
      provisional: true,
      sound: true,
    );
    
    // Request local notification permissions (for Android 13+)
    bool? localPermissionGranted;
    if (defaultTargetPlatform == TargetPlatform.android) {
      final androidImplementation = _localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      if (androidImplementation != null) {
        localPermissionGranted = await androidImplementation.requestNotificationsPermission();
      }
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      final iosImplementation = _localNotifications
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
      if (iosImplementation != null) {
        localPermissionGranted = await iosImplementation.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
      }
    }
    
    final isAuthorized = settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
    final hasLocalPermission = localPermissionGranted ?? true; // Default to true for older Android versions
    
    if (isAuthorized && hasLocalPermission) {
      print('User granted notification permissions');
      return true;
    } else {
      print('User denied or partially granted notification permissions');
      return false;
    }
  }

  /// Show a test notification (for experimentation)
  Future<void> showTestNotification() async {
    if (kIsWeb) return;

    // Ensure notifications are initialized
    if (!_isInitialized) {
      await initialize();
    }

    // Create notification channel for Android
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'test_channel',
      'Test Notifications',
      description: 'Test notifications for experimentation',
      importance: Importance.high,
      playSound: true,
    );

    final androidImplementation = _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await androidImplementation?.createNotificationChannel(channel);

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'test_channel',
      'Test Notifications',
      channelDescription: 'Test notifications for experimentation',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      playSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await _localNotifications.show(
      999,
      'Test Notification',
      'This is a test notification from ResQ!',
      notificationDetails,
    );
  }
}