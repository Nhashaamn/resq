package com.example.res_q

import android.app.Activity
import android.content.Intent
import android.os.Bundle
import android.view.WindowManager
import android.widget.Button
import android.widget.TextView
import android.widget.ProgressBar

class EmergencyActivity : Activity() {
    private var countdownTimer: android.os.CountDownTimer? = null
    private var remainingSeconds = 10
    private var isCancelled = false
    private lateinit var countdownText: TextView
    private lateinit var confirmButton: Button
    private lateinit var declineButton: Button
    private lateinit var countdownProgress: ProgressBar
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // Set flags to show over lock screen and turn screen on
        window.addFlags(
            WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
            WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON or
            WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON or
            WindowManager.LayoutParams.FLAG_DISMISS_KEYGUARD or
            WindowManager.LayoutParams.FLAG_FULLSCREEN
        )
        
        // Make activity fullscreen
        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.R) {
            window.insetsController?.hide(android.view.WindowInsets.Type.statusBars())
        } else {
            @Suppress("DEPRECATION")
            window.decorView.systemUiVisibility = (
                android.view.View.SYSTEM_UI_FLAG_FULLSCREEN or
                android.view.View.SYSTEM_UI_FLAG_HIDE_NAVIGATION or
                android.view.View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY
            )
        }
        
        setContentView(R.layout.activity_emergency)
        
        // Initialize views
        countdownText = findViewById(R.id.countdownText)
        confirmButton = findViewById(R.id.confirmButton)
        declineButton = findViewById(R.id.declineButton)
        countdownProgress = findViewById(R.id.countdownProgress)
        
        setupUI()
        startCountdown()
    }
    
    private fun setupUI() {
        confirmButton.setOnClickListener {
            handleConfirm()
        }
        
        declineButton.setOnClickListener {
            handleDecline()
        }
    }
    
    private fun startCountdown() {
        countdownTimer = object : android.os.CountDownTimer(10000, 1000) {
            override fun onTick(millisUntilFinished: Long) {
                if (!isCancelled) {
                    remainingSeconds = (millisUntilFinished / 1000).toInt()
                    countdownText.text = remainingSeconds.toString()
                    countdownProgress.progress = remainingSeconds
                }
            }
            
            override fun onFinish() {
                if (!isCancelled) {
                    sendEmergencyMessage()
                    finish()
                }
            }
        }.start()
    }
    
    private fun handleConfirm() {
        isCancelled = true
        countdownTimer?.cancel()
        
        // Cancel emergency timer in background service
        ShakeService.stopService(this)
        
        finish()
    }
    
    private fun handleDecline() {
        isCancelled = true
        countdownTimer?.cancel()
        
        // Send emergency message immediately
        sendEmergencyMessage()
        finish()
    }
    
    private fun sendEmergencyMessage() {
        // Launch Flutter app to emergency alert page to send message
        // This will use the existing Flutter emergency message sending logic
        val intent = Intent(this, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or 
                    Intent.FLAG_ACTIVITY_CLEAR_TOP or
                    Intent.FLAG_ACTIVITY_SINGLE_TOP
            putExtra("emergency_triggered", true)
            putExtra("send_emergency", true)
        }
        startActivity(intent)
    }
    
    override fun onBackPressed() {
        // Prevent back button - user must choose an action
        // Do nothing
    }
    
    override fun onDestroy() {
        super.onDestroy()
        countdownTimer?.cancel()
    }
}

