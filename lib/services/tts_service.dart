
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/foundation.dart';

class TtsService {
  static final TtsService _instance = TtsService._internal();
  factory TtsService() => _instance;
  
  late FlutterTts _flutterTts;
  bool _isSpeaking = false;

  TtsService._internal() {
    _flutterTts = FlutterTts();
    _initDaults();
  }

  Future<void> _initDaults() async {
    // Default language from settings (via a manual call from UI init)
    await setLocale("fr-FR"); 
    await _flutterTts.setSpeechRate(0.4); 
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
    
    _flutterTts.setStartHandler(() {
      _isSpeaking = true;
    });

    _flutterTts.setCompletionHandler(() {
      _isSpeaking = false;
    });

    _flutterTts.setErrorHandler((msg) {
      _isSpeaking = false;
      if (kDebugMode) print("TTS Error: $msg");
    });
  }

  Future<void> setLocale(String locale) async {
    await _flutterTts.setLanguage(locale);
  }

  Future<void> speak(String text) async {
    if (text.isEmpty) return;
    // Stop previous speech to prioritize new action
    await _flutterTts.stop(); 
    await _flutterTts.speak(text);
  }

  Future<void> stop() async {
    await _flutterTts.stop();
  }
}
