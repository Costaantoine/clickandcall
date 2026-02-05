package com.example.elderly_launcher

import android.app.Activity
import android.app.admin.DevicePolicyManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.media.AudioManager
import android.os.Build
import android.os.Bundle
import android.os.Vibrator
import android.view.KeyEvent
import android.view.WindowManager
import android.hardware.camera2.CameraManager
import android.telephony.PhoneStateListener
import android.telephony.TelephonyManager
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "elderly_launcher/kiosk"
    private var isKioskModeEnabled = false
    private var cameraManager: CameraManager? = null
    private var cameraId: String? = null
    private var isFlashlightOn = false
    private var telephonyManager: TelephonyManager? = null
    private var phoneStateListener: PhoneStateListener? = null
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // Gardien l'écran allumé
        window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
        
        // Initialiser la caméra pour la lampe torche
        cameraManager = getSystemService(Context.CAMERA_SERVICE) as CameraManager
        cameraId = cameraManager?.cameraIdList?.get(0)
        
        // Initialiser le PhoneStateListener pour détecter la fin d'appel
        telephonyManager = getSystemService(Context.TELEPHONY_SERVICE) as TelephonyManager
    }
    
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // Connecter le récepteur SMS au moteur Flutter
        SmsReceiver.flutterEngine = flutterEngine
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "enableKioskMode" -> {
                    isKioskModeEnabled = true
                    hideSystemUI()
                    result.success(null)
                }
                "disableKioskMode" -> {
                    isKioskModeEnabled = false
                    showSystemUI()
                    result.success(null)
                }
                "setDefaultLauncher" -> {
                    setAsDefaultLauncher()
                    result.success(null)
                }
                "lockDevice" -> {
                    lockDevice()
                    result.success(null)
                }
                "toggleFlashlight" -> {
                    toggleFlashlight()
                    result.success(null)
                }
                "vibrate" -> {
                    val duration = call.argument<Int>("duration") ?: 100
                    vibrate(duration)
                    result.success(null)
                }
                "setMaxVolume" -> {
                    setMaxVolume()
                    result.success(null)
                }
                "makeCall" -> {
                    val phoneNumber = call.argument<String>("phoneNumber")
                    if (phoneNumber != null) {
                        makeCall(phoneNumber)
                        result.success(null)
                    } else {
                        result.error("INVALID_ARGUMENT", "Phone number is required", null)
                    }
                }
                "setupCallListener" -> {
                    setupCallListener()
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }
    
    private fun hideSystemUI() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            window.setDecorFitsSystemWindows(false)
            window.insetsController?.hide(android.view.WindowInsets.Type.systemBars())
        } else {
            @Suppress("DEPRECATION")
            window.decorView.systemUiVisibility = (
                android.view.View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY
                or android.view.View.SYSTEM_UI_FLAG_HIDE_NAVIGATION
                or android.view.View.SYSTEM_UI_FLAG_FULLSCREEN
                or android.view.View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION
                or android.view.View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN
            )
        }
    }
    
    private fun showSystemUI() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            window.setDecorFitsSystemWindows(true)
            window.insetsController?.show(android.view.WindowInsets.Type.systemBars())
        } else {
            @Suppress("DEPRECATION")
            window.decorView.systemUiVisibility = android.view.View.SYSTEM_UI_FLAG_VISIBLE
        }
    }
    
    private fun setAsDefaultLauncher() {
        // Cette fonction nécessite des permissions spéciales (Device Owner)
        // qui ne sont pas disponibles en mode debug standard
        // Pour la production, il faudrait configurer le Device Owner via ADB
        val packageName = packageName
        val componentName = ComponentName(packageName, "$packageName.MainActivity")
        val devicePolicyManager = getSystemService(Context.DEVICE_POLICY_SERVICE) as DevicePolicyManager
        
        if (devicePolicyManager.isDeviceOwnerApp(packageName)) {
            // La méthode setDefaultLauncher est deprecated ou non disponible
            // dans les versions récentes d'Android
            // Utiliser une approche alternative ou des permissions de système
        }
    }
    
    private fun lockDevice() {
        val devicePolicyManager = getSystemService(Context.DEVICE_POLICY_SERVICE) as DevicePolicyManager
        devicePolicyManager.lockNow()
    }
    
    private fun toggleFlashlight() {
        cameraId?.let { id ->
            try {
                isFlashlightOn = !isFlashlightOn
                cameraManager?.setTorchMode(id, isFlashlightOn)
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }
    }
    
    private fun vibrate(duration: Int) {
        val vibrator = getSystemService(Context.VIBRATOR_SERVICE) as Vibrator
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            vibrator.vibrate(android.os.VibrationEffect.createOneShot(duration.toLong(), android.os.VibrationEffect.DEFAULT_AMPLITUDE))
        } else {
            @Suppress("DEPRECATION")
            vibrator.vibrate(duration.toLong())
        }
    }
    
    private fun setMaxVolume() {
        val audioManager = getSystemService(Context.AUDIO_SERVICE) as AudioManager
        val maxVolume = audioManager.getStreamMaxVolume(AudioManager.STREAM_MUSIC)
        audioManager.setStreamVolume(AudioManager.STREAM_MUSIC, maxVolume, 0)
    }
    
    private fun makeCall(phoneNumber: String) {
        val callIntent = Intent(Intent.ACTION_CALL, android.net.Uri.parse("tel:$phoneNumber"))
        callIntent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
        startActivity(callIntent)
    }
    
    private fun setupCallListener() {
        phoneStateListener = object : PhoneStateListener() {
            override fun onCallStateChanged(state: Int, phoneNumber: String?) {
                when (state) {
                    TelephonyManager.CALL_STATE_IDLE -> {
                        // Appel terminé, fermer l'app si pas en mode kiosque
                        if (!isKioskModeEnabled) {
                            finish()
                        }
                    }
                }
            }
        }
        telephonyManager?.listen(phoneStateListener, PhoneStateListener.LISTEN_CALL_STATE)
    }
    
    // Bloquer le bouton retour
    override fun onBackPressed() {
        if (!isKioskModeEnabled) {
            super.onBackPressed()
        }
        // Sinon, ne rien faire (bloquer)
    }
    
    // Bloquer les boutons physiques
    override fun onKeyDown(keyCode: Int, event: KeyEvent?): Boolean {
        if (isKioskModeEnabled) {
            return when (keyCode) {
                KeyEvent.KEYCODE_BACK,
                KeyEvent.KEYCODE_HOME,
                KeyEvent.KEYCODE_APP_SWITCH,
                KeyEvent.KEYCODE_MENU -> true
                else -> super.onKeyDown(keyCode, event)
            }
        }
        return super.onKeyDown(keyCode, event)
    }
    
    override fun onWindowFocusChanged(hasFocus: Boolean) {
        super.onWindowFocusChanged(hasFocus)
        if (hasFocus && isKioskModeEnabled) {
            hideSystemUI()
        }
    }
    
    override fun onResume() {
        super.onResume()
        if (isKioskModeEnabled) {
            hideSystemUI()
        }
    }
}
