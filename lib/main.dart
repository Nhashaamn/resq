import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:resq/core/constants/api_constants.dart';
import 'package:resq/core/di/injection.dart';
import 'package:resq/core/routes/app_router.dart';
import 'package:resq/core/theme/app_theme.dart';
import 'package:resq/core/services/android_shake_service.dart';
import 'package:resq/core/services/notification_services.dart';
import 'package:resq/features/func/data/models/emergency_contact_model.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:go_router/go_router.dart';
import 'firebase_options.dart';

// Global router reference for emergency navigation
GoRouter? globalRouter;

// Global variable to track if we need to navigate to emergency alert
bool shouldNavigateToEmergency = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Initialize Gemini (may fail if API key is invalid, but shouldn't crash app)
    try {
      Gemini.init(apiKey: ApiConstants.geminiApiKey);
    } catch (e) {
      debugPrint('Warning: Failed to initialize Gemini: $e');
    }

    // Initialize Firebase
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } catch (e) {
      debugPrint('Error: Failed to initialize Firebase: $e');
      // Continue anyway - some features may not work but app should still load
    }

    // Initialize Hive (works on both web and mobile)
    // On web, Hive uses IndexedDB; on mobile, it uses native storage
    try {
      await Hive.initFlutter();
      Hive.registerAdapter(EmergencyContactModelAdapter());
    } catch (e) {
      debugPrint('Warning: Failed to initialize Hive: $e');
      // Continue - app can work without local storage
    }

    // Configure dependency injection
    try {
      configureDependencies();
    } catch (e) {
      debugPrint('Error: Failed to configure dependencies: $e');
      // This is critical, but let's try to continue
    }

    // Initialize Android native shake service only on Android
    if (!kIsWeb) {
      try {
        // Start Android native shake detection service
        // This works even when app is killed
        await AndroidShakeService.startService();
        
        // Initialize notification action handler
        final FlutterLocalNotificationsPlugin localNotifications =
            FlutterLocalNotificationsPlugin();
        
        await localNotifications.initialize(
          const InitializationSettings(
            android: AndroidInitializationSettings('@mipmap/ic_launcher'),
          ),
          onDidReceiveNotificationResponse: (NotificationResponse response) {
            debugPrint('Notification tapped: payload=${response.payload}, actionId=${response.actionId}');
            
            // Handle notification tap - navigate to emergency alert page
            if (response.payload == '/emergency-alert') {
              // Set flag to navigate when router is ready
              shouldNavigateToEmergency = true;
              
              // Navigate to emergency alert page when notification is tapped
              // Use multiple callbacks to ensure navigation happens
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Future.delayed(const Duration(milliseconds: 500), () {
                  if (globalRouter != null) {
                    debugPrint('Navigating to /emergency-alert');
                    globalRouter!.go('/emergency-alert');
                    shouldNavigateToEmergency = false;
                  } else {
                    debugPrint('Router not available yet, will retry');
                    // Retry after a delay
                    Future.delayed(const Duration(seconds: 1), () {
                      if (globalRouter != null) {
                        globalRouter!.go('/emergency-alert');
                        shouldNavigateToEmergency = false;
                      }
                    });
                  }
                });
              });
            }
            // Handle notification action tap
            if (response.actionId == 'ok_action') {
              // User pressed "I'm OK" - cancel emergency timer
              FlutterBackgroundService().invoke('cancel_emergency_timer');
            }
          },
        );
      } catch (e) {
        debugPrint('Warning: Failed to initialize background service: $e');
        // Background service is not critical for app to run
      }
      
      // Request notification permissions
      try {
        final notificationServices = NotificationServices();
        await notificationServices.requestPermission();
      } catch (e) {
        debugPrint('Warning: Failed to request notification permissions: $e');
      }
    }
  } catch (e, stackTrace) {
    debugPrint('Critical error during initialization: $e');
    debugPrint('Stack trace: $stackTrace');
    // Continue anyway - show error in UI if needed
  }

  // Set up error handling
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('Flutter Error: ${details.exception}');
    debugPrint('Stack trace: ${details.stack}');
  };

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();
    // Check for emergency navigation after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForEmergencyNavigation();
    });
  }

  void _checkForEmergencyNavigation() {
    // Check if we need to navigate to emergency alert
    if (shouldNavigateToEmergency && globalRouter != null) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted && globalRouter != null) {
          debugPrint('Auto-navigating to /emergency-alert on app start');
          globalRouter!.go('/emergency-alert');
          shouldNavigateToEmergency = false;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);
    // Store router reference globally for emergency navigation
    globalRouter = router;
    
    // Check for emergency navigation when router changes
    if (shouldNavigateToEmergency && router.routerDelegate.currentConfiguration.uri.path != '/emergency-alert') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted && globalRouter != null) {
            globalRouter!.go('/emergency-alert');
            shouldNavigateToEmergency = false;
          }
        });
      });
    }
    
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'ResQ',
      theme: AppTheme.lightTheme,
      routerConfig: router,
    );
  }
}
