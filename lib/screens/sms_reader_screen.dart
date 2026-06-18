import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:elderly_launcher/services/tts_service.dart';
import 'package:elderly_launcher/services/database_service.dart';
import 'package:elderly_launcher/service_locator.dart';

class SmsReaderScreen extends StatefulWidget {
  final String sender;
  final String message;
  final DateTime timestamp;
  
  const SmsReaderScreen({
    super.key,
    required this.sender,
    required this.message,
    required this.timestamp,
  });

  @override
  State<SmsReaderScreen> createState() => _SmsReaderScreenState();
}

class _SmsReaderScreenState extends State<SmsReaderScreen> {
  final TtsService _tts = getIt<TtsService>();
  final DatabaseService _db = getIt<DatabaseService>();
  String _langCode = "pt";
  bool _isReading = false;
  
  final Map<String, Map<String, String>> _translations = {
    "fr": {
      "from": "De",
      "message": "Message",
      "save": "SAUVEGARDER",
      "delete": "EFFACER",
      "saved": "Message sauvegardé",
      "deleted": "Message effacé",
      "reading": "Lecture du message",
    },
    "pt": {
      "from": "De",
      "message": "Mensagem",
      "save": "GUARDAR",
      "delete": "APAGAR",
      "saved": "Mensagem guardada",
      "deleted": "Mensagem apagada",
      "reading": "A ler a mensagem",
    },
    "es": {
      "from": "De",
      "message": "Mensaje",
      "save": "GUARDAR",
      "delete": "BORRAR",
      "saved": "Mensaje guardado",
      "deleted": "Mensaje borrado",
      "reading": "Leyendo el mensaje",
    },
    "en": {
      "from": "From",
      "message": "Message",
      "save": "SAVE",
      "delete": "DELETE",
      "saved": "Message saved",
      "deleted": "Message deleted",
      "reading": "Reading message",
    },
  };
  
  @override
  void initState() {
    super.initState();
    _loadLang();
    // Lecture automatique au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _readMessage();
    });
  }
  
  Future<void> _loadLang() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) setState(() => _langCode = prefs.getString('language') ?? "pt");
  }
  
  String get t {
    return _langCode;
  }
  
  String _getText(String key) {
    return _translations[_langCode]?[key] ?? _translations["en"]![key]!;
  }
  
  Future<void> _readMessage() async {
    setState(() => _isReading = true);
    
    // Lire "De [expéditeur]"
    await _tts.speak("${_getText('from')} ${widget.sender}");
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Lire le message
    await _tts.speak(widget.message);
    
    setState(() => _isReading = false);
  }
  
  Future<void> _saveMessage() async {
    // Sauvegarder dans la base de données
    await _db.saveSms(
      sender: widget.sender,
      message: widget.message,
      timestamp: widget.timestamp.toIso8601String(),
    );
    
    await _tts.speak(_getText('saved'));
    
    // Fermer l'écran
    if (mounted) {
      Navigator.pop(context, 'saved');
    }
  }
  
  Future<void> _deleteMessage() async {
    await _tts.speak(_getText('deleted'));
    
    // Fermer l'écran sans sauvegarder
    if (mounted) {
      Navigator.pop(context, 'deleted');
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Header avec info expéditeur
            Container(
              padding: const EdgeInsets.all(20),
              color: Colors.blue[900],
              width: double.infinity,
              child: Column(
                children: [
                  Icon(
                    Icons.message,
                    size: 60,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "${_getText('from')}: ${widget.sender}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "${widget.timestamp.day}/${widget.timestamp.month} ${widget.timestamp.hour}:${widget.timestamp.minute.toString().padLeft(2, '0')}",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
            
            // Message
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(30),
                child: SingleChildScrollView(
                  child: Text(
                    widget.message,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            
            // Indicateur de lecture
            if (_isReading)
              Container(
                padding: const EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 30,
                      height: 30,
                      child: CircularProgressIndicator(
                        color: Colors.blue,
                        strokeWidth: 3,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Text(
                      _getText('reading'),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              ),
            
            // Boutons Vert (Sauvegarder) et Rouge (Effacer)
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  // Bouton VERT - Sauvegarder
                  Expanded(
                    child: GestureDetector(
                      onTap: _isReading ? null : _saveMessage,
                      child: Container(
                        height: 120,
                        margin: const EdgeInsets.only(right: 10),
                        decoration: BoxDecoration(
                          color: Colors.green[700],
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.green.withOpacity(0.5),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.save,
                              color: Colors.white,
                              size: 50,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              _getText('save'),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  // Bouton ROUGE - Effacer
                  Expanded(
                    child: GestureDetector(
                      onTap: _isReading ? null : _deleteMessage,
                      child: Container(
                        height: 120,
                        margin: const EdgeInsets.only(left: 10),
                        decoration: BoxDecoration(
                          color: Colors.red[700],
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.withOpacity(0.5),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.delete,
                              color: Colors.white,
                              size: 50,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              _getText('delete'),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Bouton pour relire
            Container(
              padding: const EdgeInsets.only(bottom: 20),
              child: ElevatedButton.icon(
                onPressed: _isReading ? null : _readMessage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                icon: const Icon(Icons.volume_up, size: 30),
                label: Text(
                  _langCode == 'pt' ? 'LER NOVAMENTE' :
                  _langCode == 'es' ? 'LEER DE NUEVO' :
                  _langCode == 'en' ? 'READ AGAIN' : 'RELIRE',
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
