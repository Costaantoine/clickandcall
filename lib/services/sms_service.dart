import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:elderly_launcher/screens/sms_reader_screen.dart';
import 'package:elderly_launcher/globals.dart';

class SmsService {
  static final SmsService _instance = SmsService._internal();
  factory SmsService() => _instance;
  SmsService._internal();

  static const MethodChannel _channel = MethodChannel('com.example.elderly_launcher/sms');
  static final StreamController<Map<String, dynamic>> _smsStreamController = StreamController<Map<String, dynamic>>.broadcast();
  
  Stream<Map<String, dynamic>> get onSmsReceived => _smsStreamController.stream;

  void initialize(GlobalKey<NavigatorState> navigatorKey) {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onSmsReceived') {
        final Map<dynamic, dynamic> data = call.arguments;
        // Sanitisation et troncature des données
        String sender = data['sender']?.toString() ?? '';
        String message = data['message']?.toString() ?? '';
        // Valider sender : uniquement chiffres et +
        final senderRegex = RegExp(r'^[0-9+]+$');
        if (sender.length > 20 || !senderRegex.hasMatch(sender)) {
          sender = 'Inconnu';
        }
        if (message.length > 500) {
          message = message.substring(0, 500);
        }
        final int timestamp = data['timestamp'] ?? DateTime.now().millisecondsSinceEpoch;
        final smsData = {
          'sender': sender,
          'message': message,
          'timestamp': DateTime.fromMillisecondsSinceEpoch(timestamp),
        };
        
        _smsStreamController.add(smsData);
        
        // Afficher une boîte de dialogue de confirmation au lieu d'une navigation automatique
        if (navigatorKey.currentContext != null) {
          Navigator.of(navigatorKey.currentContext!).push(
            MaterialPageRoute(
              builder: (context) => SmsReaderScreen(
                sender: smsData['sender'] as String,
                message: smsData['message'] as String,
                timestamp: smsData['timestamp'] as DateTime,
              ),
            ),
          );
        }
      }
      return null;
    });
  }

  void dispose() {
    _smsStreamController.close();
  }
}
