
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static final SettingsService _instance = SettingsService._internal();
  factory SettingsService() => _instance;
  SettingsService._internal();

  static const String KEY_WIFI_ONLY = "wifi_only";
  static const String KEY_VIDEO_URL = "video_url";
  static const String KEY_EMERGENCY_NUM = "emergency_num";
  static const String KEY_EMERGENCY_NUMBERS = "emergency_numbers";
  static const String KEY_SOS_DELAY = "sos_delay";
  static const String KEY_LANGUAGE = "language";

  Future<bool> getWifiOnly() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(KEY_WIFI_ONLY) ?? true; // Default true
  }

  Future<void> setWifiOnly(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(KEY_WIFI_ONLY, value);
  }

  Future<String> getVideoUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(KEY_VIDEO_URL) ?? "https://meet.jit.si/FamilleAineLink";
  }

  Future<void> setVideoUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(KEY_VIDEO_URL, url);
  }

  Future<String> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(KEY_LANGUAGE) ?? "pt"; // Default to Portuguese (pt)
  }

  Future<void> setLanguage(String lang) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(KEY_LANGUAGE, lang);
  }

  Future<List<String>> getEmergencyNumbers() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? numbers = prefs.getStringList(KEY_EMERGENCY_NUMBERS);
    if (numbers == null || numbers.isEmpty) {
      return ["112"];
    }
    return numbers;
  }

  Future<void> setEmergencyNumbers(List<String> numbers) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(KEY_EMERGENCY_NUMBERS, numbers);
  }

  Future<int> getSosDelay() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(KEY_SOS_DELAY) ?? 3;
  }

  Future<void> setSosDelay(int delay) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(KEY_SOS_DELAY, delay);
  }
}
