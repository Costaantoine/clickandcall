
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:elderly_launcher/screens/home_screen.dart';
import 'package:elderly_launcher/service_locator.dart';
import 'package:elderly_launcher/services/kiosk_mode_service.dart';
import 'package:elderly_launcher/services/kiosk_channel_service.dart';
import 'package:elderly_launcher/services/sms_service.dart';
import 'package:elderly_launcher/globals.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupLocator();
  
  // 🔒 ACTIVER LE MODE KIOSK IMMÉDIATEMENT
  try {
    final kioskService = KioskModeService();
    kioskService.enableKioskMode();
  } catch (e) {
    print('Failed to enable kiosk mode: $e');
  }

  // 🚀 Configurer comme launcher par défaut (Android natif)
  try {
    await KioskChannelService.setAsDefaultLauncher();
  } catch (e) {
    print('Failed to set default launcher: $e');
  }

  // Activer le kiosk natif Android (bloque boutons physiques)
  try {
    await KioskChannelService.enableNativeKiosk();
  } catch (e) {
    print('Failed to enable native kiosk: $e');
  }

  runApp(const ElderlyLauncherApp());
}

class ElderlyLauncherApp extends StatelessWidget {
  const ElderlyLauncherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ClickAndCall',
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey, // Clé pour la navigation globale
      theme: ThemeData(
        brightness: Brightness.dark, // High contrast preference (white on black)
        scaffoldBackgroundColor: Colors.black,
        primaryColor: Colors.blue,
        useMaterial3: true,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          bodyMedium: TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
