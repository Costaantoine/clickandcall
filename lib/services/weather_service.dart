
import 'package:elderly_launcher/services/tts_service.dart';

class WeatherService {
  final TtsService _tts;
  
  String _lastTemperature = "22";
  String _lastCondition = "ensolarado";
  String _city = "Paris";
  
  WeatherService(this._tts);
  
  // Modèles d'annonce par langue
  static const Map<String, String> _announcementPatterns = {
    "fr": "Météo aujourd'hui. {condition}. {temperature} degrés.",
    "pt": "Tempo hoje. {condition}. {temperature} graus.",
    "es": "Clima hoy. {condition}. {temperature} grados.",
    "en": "Weather today. {condition}. {temperature} degrees.",
  };
  
  // Messages de secours par langue
  static const Map<String, String> _fallbacks = {
    "fr": "Il fait beau aujourd'hui. 22 degrés.",
    "pt": "Está bom tempo hoje. 22 graus.",
    "es": "Hace buen tiempo hoy. 22 grados.",
    "en": "The weather is nice today. 22 degrees.",
  };
  
  // Conditions météo par langue
  static const Map<String, String> _conditions = {
    "fr": "ensoleillé",
    "pt": "ensolarado",
    "es": "soleado",
    "en": "sunny",
  };
  
  Future<void> announceWeather(String langCode) async {
    try {
      await _fetchMockWeather(langCode);
      String announcement = _getWeatherAnnouncement(langCode);
      await _tts.speak(announcement);
    } catch (e) {
      await _tts.speak(_fallbacks[langCode] ?? _fallbacks["en"]!);
    }
  }
  
  Future<void> _fetchMockWeather(String langCode) async {
    _lastTemperature = "22";
    _lastCondition = _conditions[langCode] ?? _conditions["en"]!;
  }
  
  String _getWeatherAnnouncement(String langCode) {
    String pattern = _announcementPatterns[langCode] ?? _announcementPatterns["en"]!;
    return pattern
        .replaceAll("{condition}", _lastCondition)
        .replaceAll("{temperature}", _lastTemperature);
  }
  
  String getTemperature() => _lastTemperature;
  String getCondition() => _lastCondition;
  
  void setCity(String city) {
    _city = city;
  }
}
