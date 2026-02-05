package com.example.elderly_launcher

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.provider.Telephony
import android.telephony.SmsMessage
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class SmsReceiver : BroadcastReceiver() {
    companion object {
        var flutterEngine: FlutterEngine? = null
        const val SMS_CHANNEL = "com.example.elderly_launcher/sms"
    }
    
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == Telephony.Sms.Intents.SMS_RECEIVED_ACTION) {
            val messages = Telephony.Sms.Intents.getMessagesFromIntent(intent)
            
            messages?.forEach { smsMessage ->
                val sender = smsMessage.displayOriginatingAddress
                val message = smsMessage.displayMessageBody
                val timestamp = smsMessage.timestampMillis
                
                // Envoyer à Flutter via MethodChannel
                flutterEngine?.dartExecutor?.binaryMessenger?.let { messenger ->
                    val channel = MethodChannel(messenger, SMS_CHANNEL)
                    channel.invokeMethod("onSmsReceived", mapOf(
                        "sender" to sender,
                        "message" to message,
                        "timestamp" to timestamp
                    ))
                }
            }
        }
    }
}
