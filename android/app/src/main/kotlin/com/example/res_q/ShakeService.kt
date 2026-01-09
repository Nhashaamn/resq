package com.example.res_q

import android.app.*
import android.content.Context
import android.content.Intent
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import android.os.Build
import android.os.IBinder
import android.os.PowerManager
import androidx.core.app.NotificationCompat
import kotlin.math.sqrt

class ShakeService : Service(), SensorEventListener {
    private var sensorManager: SensorManager? = null
    private var accelerometer: Sensor? = null
    private var powerManager: PowerManager? = null
    private var wakeLock: PowerManager.WakeLock? = null
    
    // Shake detection variables
    private var lastShakeTime: Long = 0
    private val shakeCooldown: Long = 5000 // 5 seconds cooldown
    private val shakeThreshold = 18.0 // m/s² threshold for strong shake
    
    // Previous acceleration values
    private var lastX = 0.0f
    private var lastY = 0.0f
    private var lastZ = 0.0f
    private var isInitialized = false
    
    private val CHANNEL_ID = "shake_detection_channel"
    private val NOTIFICATION_ID = 888
    
    override fun onCreate() {
        super.onCreate()
        
        sensorManager = getSystemService(Context.SENSOR_SERVICE) as SensorManager
        accelerometer = sensorManager?.getDefaultSensor(Sensor.TYPE_ACCELEROMETER)
        powerManager = getSystemService(Context.POWER_SERVICE) as PowerManager
        
        createNotificationChannel()
        startForeground(NOTIFICATION_ID, createNotification())
        
        // Acquire wake lock to keep service running
        wakeLock = powerManager?.newWakeLock(
            PowerManager.PARTIAL_WAKE_LOCK,
            "ShakeService::WakeLock"
        )
        wakeLock?.acquire(10 * 60 * 1000L) // 10 minutes
        
        // Start listening to accelerometer
        accelerometer?.let {
            sensorManager?.registerListener(this, it, SensorManager.SENSOR_DELAY_UI)
        }
    }
    
    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        return START_STICKY // Restart service if killed
    }
    
    override fun onBind(intent: Intent?): IBinder? {
        return null
    }
    
    override fun onDestroy() {
        super.onDestroy()
        sensorManager?.unregisterListener(this)
        wakeLock?.release()
    }
    
    override fun onSensorChanged(event: SensorEvent?) {
        if (event?.sensor?.type == Sensor.TYPE_ACCELEROMETER) {
            val x = event.values[0]
            val y = event.values[1]
            val z = event.values[2]
            
            // Initialize on first reading
            if (!isInitialized) {
                lastX = x
                lastY = y
                lastZ = z
                isInitialized = true
                return
            }
            
            // Calculate acceleration change
            val deltaX = kotlin.math.abs(x - lastX)
            val deltaY = kotlin.math.abs(y - lastY)
            val deltaZ = kotlin.math.abs(z - lastZ)
            
            // Calculate magnitude of acceleration change
            val accelerationChange = sqrt(
                (deltaX * deltaX + deltaY * deltaY + deltaZ * deltaZ).toDouble()
            )
            
            // Update last values
            lastX = x
            lastY = y
            lastZ = z
            
            // Check if shake threshold is exceeded
            if (accelerationChange > shakeThreshold) {
                val currentTime = System.currentTimeMillis()
                if (currentTime - lastShakeTime > shakeCooldown) {
                    lastShakeTime = currentTime
                    handleShakeDetected()
                }
            }
        }
    }
    
    override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {
        // Not used
    }
    
    private fun handleShakeDetected() {
        // Launch emergency activity
        val intent = Intent(this, EmergencyActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or
                    Intent.FLAG_ACTIVITY_CLEAR_TOP or
                    Intent.FLAG_ACTIVITY_SINGLE_TOP
        }
        startActivity(intent)
    }
    
    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "Shake Detection",
                NotificationManager.IMPORTANCE_LOW // Silent, minimal notification
            ).apply {
                description = "Background shake detection service"
                setShowBadge(false)
                enableVibration(false)
                enableLights(false)
                setSound(null, null)
            }
            
            val notificationManager = getSystemService(NotificationManager::class.java)
            notificationManager.createNotificationChannel(channel)
        }
    }
    
    private fun createNotification(): Notification {
        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("ResQ")
            .setContentText("Shake detection active")
            .setSmallIcon(android.R.drawable.ic_dialog_info)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setOngoing(true)
            .setSilent(true)
            .setShowWhen(false)
            .build()
    }
    
    companion object {
        fun startService(context: Context) {
            val intent = Intent(context, ShakeService::class.java)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                context.startForegroundService(intent)
            } else {
                context.startService(intent)
            }
        }
        
        fun stopService(context: Context) {
            val intent = Intent(context, ShakeService::class.java)
            context.stopService(intent)
        }
    }
}

