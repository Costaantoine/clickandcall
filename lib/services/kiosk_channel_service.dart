
import 'package:flutter/services.dart';

class KioskChannelService {
  static const MethodChannel _channel = MethodChannel('elderly_launcher/kiosk');
  
  // Activer le mode kiosk natif Android
  static Future<bool> enableNativeKiosk() async {
    try {
      await _channel.invokeMethod('enableKioskMode');
      return true;
    } catch (e) {
      print('Erreur activation kiosk natif: $e');
      return false;
    }
  }

  // Désactiver le mode kiosk
  static Future<bool> disableNativeKiosk() async {
    try {
      await _channel.invokeMethod('disableKioskMode');
      return true;
    } catch (e) {
      print('Erreur désactivation kiosk natif: $e');
      return false;
    }
  }

  // Configurer comme launcher par défaut
  static Future<bool> setAsDefaultLauncher() async {
    try {
      await _channel.invokeMethod('setDefaultLauncher');
      return true;
    } catch (e) {
      print('Erreur configuration launcher: $e');
      return false;
    }
  }

  // Verrouiller l'appareil dans l'app (device owner)
  static Future<bool> lockDevice() async {
    try {
      await _channel.invokeMethod('lockDevice');
      return true;
    } catch (e) {
      print('Erreur verrouillage appareil: $e');
      return false;
    }
  }

  // Activer la lampe torche
  static Future<bool> toggleFlashlight() async {
    try {
      await _channel.invokeMethod('toggleFlashlight');
      return true;
    } catch (e) {
      print('Erreur lampe torche: $e');
      return false;
    }
  }

  // Vibration tactile
  static Future<bool> vibrate({int duration = 100}) async {
    try {
      await _channel.invokeMethod('vibrate', {'duration': duration});
      return true;
    } catch (e) {
      print('Erreur vibration: $e');
      return false;
    }
  }

  // Volume au maximum
  static Future<bool> setMaxVolume() async {
    try {
      await _channel.invokeMethod('setMaxVolume');
      return true;
    } catch (e) {
      print('Erreur volume: $e');
      return false;
    }
  }
}
