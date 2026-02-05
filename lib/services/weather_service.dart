
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:elderly_launcher/services/tts_service.dart';

class WeatherService {
  final TtsService _tts;
  
  // API gratuite OpenWeatherMap (nécessite une clé API)
  // Pour l'instant, on utilise des données mockées ou une API simple
  static const String _apiKey = "VOTRE_CLE_API"; // À remplacer par l'utilisateur
  static const String _baseUrl = "https://api.openweathermap.org/data/2.5/weather";
  
  String _lastTemperature = "22";
  String _lastCondition = "ensoleillé";
  String _city = "Paris";
  
  WeatherService(this._tts);
  
  Future<void> announceWeather(String langCode) async {
    try {
      // Pour l'instant, utiliser des données simulées
      // En production, remplacer par un vrai appel API
      await _fetchMockWeather(langCode);
      
      String announcement = _getWeatherAnnouncement(langCode);
      await _tts.speak(announcement);
    } catch (e) {
      print('Erreur météo: $e');
      // Message de secours
      if (langCode == "fr") {
        await _tts.speak("Il fait beau aujourd'hui. 22 degrés.");
      } else if (langCode == "pt") {
        await _tts.speak("Está bom tempo hoje. 22 graus.");
      } else if (langCode == "es") {
        await _tts.speak("Hace buen tiempo hoy. 22 grados.");
      } else {
        await _tts.speak("The weather is nice today. 22 degrees.");
      }
    }
  }
  
  Future<void> _fetchMockWeather(String langCode) async {
    // Simulation - dans la vraie app, appeler l'API ici
    // Exemple avec http:
    // final response = await http.get(Uri.parse(
    //   '$_baseUrl?q=$_city&appid=$_apiKey&units=metric&lang=$langCode'
    // ));
    // if (response.statusCode == 200) {
    //   final data = jsonDecode(response.body);
    //   _lastTemperature = data['main']['temp'].round().toString();
    //   _lastCondition = data['weather'][0]['description'];
    // }
    
    // Données mockées pour la démo
    _lastTemperature = "22";
    _lastCondition = langCode == "fr" ? "ensoleillé" : 
                    langCode == "pt" ? "ensolarado" :
                    langCode == "es" ? "soleado" : "sunny";
  }
  
  String _getWeatherAnnouncement(String langCode) {
    switch (langCode) {
      case "fr":
        return "Météo aujourd'hui. $_lastCondition. Il fait $_lastTemperature degrés.";
      case "pt":
        return "Tempo hoje. $_lastCondition. Estão $_lastTemperature graus.";
      case "es":
        return "Clima hoy. $_lastCondition. Hace $_lastTemperature grados.";
      case "en":
      default:
        return "Weather today. $_lastCondition. It's $_lastTemperature degrees.";
    }
  }
  
  String getTemperature() => _lastTemperature;
  String getCondition() => _lastCondition;
  
  void setCity(String city) {
    _city = city;
  }
}
