import 'package:get_it/get_it.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:elderly_launcher/services/tts_service.dart';
import 'package:elderly_launcher/services/database_service.dart';
import 'package:elderly_launcher/services/connectivity_service.dart';
import 'package:elderly_launcher/services/voice_command_service.dart';
import 'package:elderly_launcher/services/settings_service.dart';
import 'package:elderly_launcher/services/kiosk_mode_service.dart';
import 'package:elderly_launcher/services/call_service.dart';
import 'package:elderly_launcher/services/sms_service.dart';

final getIt = GetIt.instance;

void setupLocator() {
  // Services
  getIt.registerLazySingleton<TtsService>(() => TtsService());
  getIt.registerLazySingleton<DatabaseService>(() => DatabaseService());
  getIt.registerLazySingleton<ConnectivityService>(() => ConnectivityService());
  getIt.registerLazySingleton<VoiceCommandService>(() => VoiceCommandService());
  getIt.registerLazySingleton<SettingsService>(() => SettingsService());
  getIt.registerLazySingleton<KioskModeService>(() => KioskModeService());
  getIt.registerLazySingleton<CallService>(() => CallService());
  getIt.registerLazySingleton<SmsService>(() => SmsService());
  
  // External Packages
  getIt.registerLazySingleton<Battery>(() => Battery());
}
