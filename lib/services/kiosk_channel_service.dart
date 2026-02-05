
import 'package:flutter/services.dart';

class KioskChannelService {
  static const MethodChannel _channel = MethodChannel('elderly_launcher/kiosk');
  
  // Activer le mode kiosk natif Android
  static Future<void> enableNativeKiosk() async {
    try {
      await _channel.invokeMethod('enableKioskMode');
    } catch (e) {
      print('Erreur activation kiosk natif: $e');
    }
  }
  
  // Désactiver le mode kiosk
  static Future<void> disableNativeKiosk() async {
    try {
      await _channel.invokeMethod('disableKioskMode');
    } catch (e) {
      print('Erreur désactivation kiosk natif: $e');
    }
  }
  
  // Configurer comme launcher par défaut
  static Future<void> setAsDefaultLauncher() async {
    try {
      await _channel.invokeMethod('setDefaultLauncher');
    } catch (e) {
      print('Erreur configuration launcher: $e');
    }
  }
  
  // Verrouiller l'appareil dans l'app (device owner)
  static Future<void> lockDevice() async {
    try {
      await _channel.invokeMethod('lockDevice');
    } catch (e) {
      print('Erreur verrouillage appareil: $e');
    }
  }
  
  // Activer la lampe torche
  static Future<void> toggleFlashlight() async {
    try {
      await _channel.invokeMethod('toggleFlashlight');
    } catch (e) {
      print('Erreur lampe torche: $e');
    }
  }
  
  // Vibration tactile
  static Future<void> vibrate({int duration = 100}) async {
    try {
      await _channel.invokeMethod('vibrate', {'duration': duration});
    } catch (e) {
      print('Erreur vibration: $e');
    }
  }
  
  // Volume au maximum
  static Future<void> setMaxVolume() async {
    try {
      await _channel.invokeMethod('setMaxVolume');
    } catch (e) {
      print('Erreur volume: $e');
    }
  }
}
