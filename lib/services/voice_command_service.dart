
import 'package:speech_to_text/speech_to_text.dart';
import 'package:string_similarity/string_similarity.dart';
import 'package:elderly_launcher/services/tts_service.dart';
import 'package:elderly_launcher/services/database_service.dart';
import 'package:url_launcher/url_launcher.dart';

class VoiceCommandService {
  final SpeechToText _speech = SpeechToText();
  final TtsService _tts = TtsService();
  final DatabaseService _db = DatabaseService();
  
  bool _isAvailable = false;
  String _locale = "fr-FR";

  final Map<String, Map<String, String>> _translations = {
    "fr-FR": {
      "status_unavailable": "Voix non disponible",
      "status_listening": "À l'écoute...",
      "status_heard": "Entendu: ",
      "cmd_camera": "Ouverture de l'appareil photo pour ajouter un contact.",
      "cmd_emergency": "Appel des urgences en cours.",
      "cmd_retry": "Je n'ai pas compris. Dites Appeler, Photo ou Urgence.",
      "call_to": "Appel de ",
      "not_found": "Contact non trouvé.",
      "keyword_call": "appeler",
      "keyword_phone": "téléphone",
      "keyword_photo": "photo",
      "keyword_add": "ajouter",
      "keyword_help": "aider",
      "keyword_sos": "secours",
      "keyword_emergency": "urgence",
      "keyword_video": "vidéo",
      "keyword_flashlight": "lampe",
      "keyword_weather": "météo",
      "keyword_battery": "batterie",
    },
    "pt-PT": {
      "status_unavailable": "Voz indisponível",
      "status_listening": "A ouvir...",
      "status_heard": "Ouvi: ",
      "cmd_camera": "A abrir a câmara para adicionar contacto.",
      "cmd_emergency": "A ligar para a emergência.",
      "cmd_retry": "Não percebi. Diga Ligar, Foto ou Ajuda.",
      "call_to": "A ligar para ",
      "not_found": "Contacto não encontrado.",
      "keyword_call": "ligar",
      "keyword_phone": "chamar",
      "keyword_photo": "foto",
      "keyword_add": "adicionar",
      "keyword_help": "ajuda",
      "keyword_sos": "socorro",
      "keyword_emergency": "emergência",
      "keyword_video": "vídeo",
      "keyword_flashlight": "luz",
      "keyword_weather": "tempo",
      "keyword_battery": "bateria",
    },
    "es-ES": {
      "status_unavailable": "Voz no disponible",
      "status_listening": "Escuchando...",
      "status_heard": "He oído: ",
      "cmd_camera": "Abriendo la cámara para añadir un contacto.",
      "cmd_emergency": "Llamando a emergencias.",
      "cmd_retry": "No he entendido. Diga Llamar, Foto o Ayuda.",
      "call_to": "Llamando a ",
      "not_found": "Contacto no encontrado.",
      "keyword_call": "llamar",
      "keyword_phone": "teléfono",
      "keyword_photo": "foto",
      "keyword_add": "añadir",
      "keyword_help": "ayuda",
      "keyword_sos": "socorro",
      "keyword_emergency": "emergencia",
      "keyword_video": "vídeo",
      "keyword_flashlight": "linterna",
      "keyword_weather": "tiempo",
      "keyword_battery": "batería",
    },
    "en-US": {
      "status_unavailable": "Voice unavailable",
      "status_listening": "Listening...",
      "status_heard": "Heard: ",
      "cmd_camera": "Opening camera to add a contact.",
      "cmd_emergency": "Calling emergency services.",
      "cmd_retry": "I didn't understand. Say Call, Photo, or Help.",
      "call_to": "Calling ",
      "not_found": "Contact not found.",
      "keyword_call": "call",
      "keyword_phone": "phone",
      "keyword_photo": "photo",
      "keyword_add": "add",
      "keyword_help": "help",
      "keyword_sos": "sos",
      "keyword_emergency": "emergency",
      "keyword_video": "video",
      "keyword_flashlight": "flashlight",
      "keyword_weather": "weather",
      "keyword_battery": "battery",
    }
  };

  Future<void> init() async {
    _isAvailable = await _speech.initialize();
  }

  void setLocale(String locale) {
    _locale = locale;
  }

  Future<void> listenAndProcess(Function(String) onStatusChange) async {
    if (!_isAvailable) {
      await init();
      if (!_isAvailable) {
        onStatusChange(_translations[_locale]!["status_unavailable"]!);
        return;
      }
    }

    onStatusChange(_translations[_locale]!["status_listening"]!);
    await _speech.listen(
      localeId: _locale,
      onResult: (result) async {
        if (result.finalResult) {
          String command = result.recognizedWords.toLowerCase();
          onStatusChange("${_translations[_locale]!["status_heard"]!}$command");
          await _processCommand(command);
        }
      },
    );
  }

  Future<void> _processCommand(String command) async {
    final t = _translations[_locale]!;
    
    if (command.contains(t["keyword_call"]!) || command.contains(t["keyword_phone"]!)) {
      await _handleCallCommand(command);
    } else if (command.contains(t["keyword_photo"]!) || command.contains(t["keyword_add"]!)) {
      _tts.speak(t["cmd_camera"]!);
    } else if (command.contains(t["keyword_help"]!) || command.contains(t["keyword_sos"]!) || command.contains(t["keyword_emergency"]!)) {
      _tts.speak(t["cmd_emergency"]!);
      launchUrl(Uri.parse("tel:112"));
    } else {
      _tts.speak(t["cmd_retry"]!);
    }
  }

  Future<void> _handleCallCommand(String command) async {
    final t = _translations[_locale]!;
    final contacts = await _db.getContacts();
    Map<String, dynamic>? bestMatch;
    double bestScore = 0.0;

    for (var contact in contacts) {
      String name = contact['name'].toString().toLowerCase();
      double score = name.similarityTo(command);
      if (score > bestScore) {
        bestScore = score;
        bestMatch = contact;
      }
      if (command.contains(name)) {
        bestScore = 1.0;
        bestMatch = contact;
      }
    }

    if (bestMatch != null && bestScore > 0.25) {
      _tts.speak("${t["call_to"]!}${bestMatch['name']}");
      launchUrl(Uri.parse("tel:${bestMatch['phoneNumber']}"));
    } else {
      _tts.speak(t["not_found"]!);
    }
  }
}
