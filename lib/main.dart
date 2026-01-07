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
import 'package:resq/core/services/background_service.dart';
import 'package:resq/features/func/data/models/emergency_contact_model.dart';
import 'firebase_options.dart';

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

    // Initialize background service only on mobile platforms
    if (!kIsWeb) {
      try {
        await BackgroundShakeService.initializeService();
      } catch (e) {
        debugPrint('Warning: Failed to initialize background service: $e');
        // Background service is not critical for app to run
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

class MyApp extends ConsumerWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'ResQ',
      theme: AppTheme.lightTheme,
      routerConfig: router,
    );
  }
}
