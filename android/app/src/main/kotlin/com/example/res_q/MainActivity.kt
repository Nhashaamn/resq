package com.example.res_q

import android.content.Intent
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.res_q/shake_service"
    
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "startShakeService" -> {
                    try {
                        ShakeService.startService(this)
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("SERVICE_ERROR", "Failed to start service: ${e.message}", null)
                    }
                }
                "stopShakeService" -> {
                    try {
                        ShakeService.stopService(this)
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("SERVICE_ERROR", "Failed to stop service: ${e.message}", null)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // Check if launched from emergency activity
        val emergencyTriggered = intent.getBooleanExtra("emergency_triggered", false)
        val sendEmergency = intent.getBooleanExtra("send_emergency", false)
        
        if (emergencyTriggered || sendEmergency) {
            // Store flag to navigate to emergency alert page
            // This will be handled after Flutter engine is ready
        }
    }
    
    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        
        // Handle emergency intent
        val emergencyTriggered = intent.getBooleanExtra("emergency_triggered", false)
        val sendEmergency = intent.getBooleanExtra("send_emergency", false)
        
        if (emergencyTriggered || sendEmergency) {
            // Navigate to emergency alert page
            // This will be handled by Flutter router
        }
    }
}
