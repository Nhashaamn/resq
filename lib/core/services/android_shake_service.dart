import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;

class AndroidShakeService {
  static const MethodChannel _channel = MethodChannel('com.example.res_q/shake_service');
  
  /// Start the Android native shake detection service
  /// This will run in the background even when app is killed
  static Future<bool> startService() async {
    if (kIsWeb) {
      debugPrint('Shake service not supported on web');
      return false;
    }
    
    try {
      final result = await _channel.invokeMethod<bool>('startShakeService');
      debugPrint('Shake service started: $result');
      return result ?? false;
    } on PlatformException catch (e) {
      debugPrint('Failed to start shake service: ${e.message}');
      return false;
    } catch (e) {
      debugPrint('Error starting shake service: $e');
      return false;
    }
  }
  
  /// Stop the Android native shake detection service
  static Future<bool> stopService() async {
    if (kIsWeb) {
      return false;
    }
    
    try {
      final result = await _channel.invokeMethod<bool>('stopShakeService');
      debugPrint('Shake service stopped: $result');
      return result ?? false;
    } on PlatformException catch (e) {
      debugPrint('Failed to stop shake service: ${e.message}');
      return false;
    } catch (e) {
      debugPrint('Error stopping shake service: $e');
      return false;
    }
  }
}

