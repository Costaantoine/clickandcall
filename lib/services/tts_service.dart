
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/foundation.dart';

class TtsService {
  static final TtsService _instance = TtsService._internal();
  factory TtsService() => _instance;
  
  late FlutterTts _flutterTts;
  bool _isSpeaking = false;
  bool _initialized = false;
  String _currentLocale = 'fr-FR';

  TtsService._internal() {
    _flutterTts = FlutterTts();
  }

  /// Initialize TTS with the correct locale (call AFTER reading user preferences)
  Future<void> init(String locale) async {
    _currentLocale = locale;
    
    await _flutterTts.setSpeechRate(0.35);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(0.8);
    
    // Try Google TTS engine first (better voice quality)
    try {
      await _flutterTts.setEngine("com.google.android.tts");
    } catch (_) {}
    
    // Set language and check if available
    final bool available = await _flutterTts.setLanguage(locale);
    if (!available) {
      debugPrint("TTS: Language $locale not available, trying fallbacks");
      // Try fallback languages in order
      for (final fallback in ['pt-PT', 'fr-FR', 'en-US', 'es-ES']) {
        if (fallback == locale) continue;
        final ok = await _flutterTts.setLanguage(fallback);
        if (ok) {
          _currentLocale = fallback;
          debugPrint("TTS: Fallback to $fallback");
          break;
        }
      }
    }
    
    _flutterTts.setStartHandler(() {
      _isSpeaking = true;
    });

    _flutterTts.setCompletionHandler(() {
      _isSpeaking = false;
    });

    _flutterTts.setErrorHandler((msg) {
      _isSpeaking = false;
      if (kDebugMode) debugPrint("TTS Error: $msg");
    });
    
    _initialized = true;
  }

  Future<void> setLocale(String locale) async {
    _currentLocale = locale;
    if (!_initialized) {
      await init(locale);
      return;
    }
    final bool available = await _flutterTts.setLanguage(locale);
    if (!available) {
      debugPrint("TTS: Language $locale not available, keeping $_currentLocale");
    }
  }

  Future<void> speak(String text) async {
    if (text.isEmpty) return;
    await _flutterTts.stop(); 
    await _flutterTts.speak(text);
  }

  Future<void> stop() async {
    await _flutterTts.stop();
  }
}
