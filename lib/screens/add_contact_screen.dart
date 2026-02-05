
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:elderly_launcher/services/tts_service.dart';
import 'package:elderly_launcher/services/database_service.dart';
import 'package:elderly_launcher/screens/home_screen.dart'; // For navigation back
import 'package:elderly_launcher/services/settings_service.dart';
import 'package:elderly_launcher/service_locator.dart';

class AddContactScreen extends StatefulWidget {
  const AddContactScreen({super.key});

  @override
  State<AddContactScreen> createState() => _AddContactScreenState();
}

class _AddContactScreenState extends State<AddContactScreen> {
  final TtsService _tts = getIt<TtsService>();
  final DatabaseService _db = getIt<DatabaseService>();
  final stt.SpeechToText _speech = stt.SpeechToText(); // Keeping this local for now
  final ImagePicker _picker = ImagePicker(); // Also local

  int _step = 0; // 0: Photo, 1: Name, 2: Number, 3: Confirm
  String? _imagePath;
  String _name = "";
  String _number = "";
  bool _isListening = false;
  String _langCode = "fr";

  final Map<String, Map<String, String>> _translations = {
    "fr": {
      "step0_speak": "Étape 1. Touchez le bouton jaune pour prendre la photo.",
      "step1_speak": "Étape 2. Touchez le micro et dites le nom.",
      "step2_speak": "Étape 3. Tapez le numéro avec les gros boutons.",
      "step3_speak": "Confirmer. Touchez le vert pour enregistrer ou le rouge pour annuler.",
      "photo_ok": "Photo capturée.",
      "photo_err": "Erreur caméra.",
      "stt_err": "Reconnaissance vocale non disponible.",
      "name_recorded": "Nom enregistré: ",
      "no_hear": "Je n'ai rien entendu. Réessayez.",
      "save_ok": "Contact enregistré avec succès.",
      "data_err": "Données incomplètes.",
      "header_photo": "PHOTOPROCHE",
      "header_name": "DIRE LE NOM",
      "header_number": "NUMÉRO",
      "header_confirm": "VALIDER ?",
      "btn_cancel": "ANNULER",
      "btn_del": "EFFACER",
      "btn_no": "NON",
      "btn_yes": "OUI",
      "tap_to_talk": "Maintenez pour parler",
      "digit_del": "Effacer"
    },
    "pt": {
      "step0_speak": "Passo 1. Prima o botão amarelo para tirar a fotografia.",
      "step1_speak": "Passo 2. Escreva ou prima o microfone e diga o nome.",
      "step2_speak": "Passo 3. Digite o número com os botões grandes.",
      "step3_speak": "Confirmar. Prima o verde para guardar ou o vermelho para cancelar.",
      "photo_ok": "Fotografia tirada.",
      "photo_err": "Erro na câmara.",
      "stt_err": "Reconhecimento de voz indisponível.",
      "name_recorded": "Nome registado: ",
      "no_hear": "Não percebi. Tente outra vez.",
      "save_ok": "Contacto guardado.",
      "data_err": "Dados incompletos.",
      "header_photo": "FOTO",
      "header_name": "NOME",
      "header_number": "NÚMERO",
      "header_confirm": "GUARDAR?",
      "btn_cancel": "CANCELAR",
      "btn_del": "APAGAR",
      "btn_no": "NÃO",
      "btn_yes": "SIM",
      "tap_to_talk": "Segure para falar",
      "digit_del": "Apagar"
    },
    "es": {
      "step0_speak": "Paso 1. Toque el botón amarillo para hacer la foto.",
      "step1_speak": "Paso 2. Toque el micrófono y diga el nombre.",
      "step2_speak": "Paso 3. Escriba el número con los botones grandes.",
      "step3_speak": "Confirmar. Toque el verde para guardar o el rojo para cancelar.",
      "photo_ok": "Foto capturada.",
      "photo_err": "Error de cámara.",
      "stt_err": "Reconocimiento de voz no disponible.",
      "name_recorded": "Nombre grabado: ",
      "no_hear": "No he oído nada. Inténtelo de nuevo.",
      "save_ok": "Contacto guardado con éxito.",
      "data_err": "Datos incompletos.",
      "header_photo": "HACER FOTO",
      "header_name": "DECIR NOMBRE",
      "header_number": "NÚMERO",
      "header_confirm": "¿VALIDAR?",
      "btn_cancel": "CANCELAR",
      "btn_del": "BORRAR",
      "btn_no": "NO",
      "btn_yes": "SÍ",
      "tap_to_talk": "Mantenga para hablar",
      "digit_del": "Borrar"
    },
    "en": {
      "step0_speak": "Step 1. Tap the yellow button to take a photo.",
      "step1_speak": "Step 2. Tap the microphone and say the name.",
      "step2_speak": "Step 3. Type the number using the large buttons.",
      "step3_speak": "Confirm. Tap green to save or red to cancel.",
      "photo_ok": "Photo captured.",
      "photo_err": "Camera error.",
      "stt_err": "Speech recognition unavailable.",
      "name_recorded": "Name recorded: ",
      "no_hear": "I didn't hear anything. Try again.",
      "save_ok": "Contact saved successfully.",
      "data_err": "Incomplete data.",
      "header_photo": "TAKE PHOTO",
      "header_name": "SAY NAME",
      "header_number": "NUMBER",
      "header_confirm": "CONFIRM?",
      "btn_cancel": "CANCEL",
      "btn_del": "DELETE",
      "btn_no": "NO",
      "btn_yes": "YES",
      "tap_to_talk": "Hold to talk",
      "digit_del": "Delete"
    }
  };

  @override
  void initState() {
    super.initState();
    _loadLang().then((_) => _startStep(0));
  }

  Future<void> _loadLang() async {
    final lang = await getIt<SettingsService>().getLanguage();
    setState(() => _langCode = lang);
  }

  void _startStep(int step) {
    setState(() => _step = step);
    final t = _translations[_langCode]!;
    if (step == 0) {
      _tts.speak(t["step0_speak"]!);
    } else if (step == 1) {
      _tts.speak(t["step1_speak"]!);
    } else if (step == 2) {
      _tts.speak(t["step2_speak"]!);
    } else if (step == 3) {
      _tts.speak(t["step3_speak"]!);
    }
  }

  Future<void> _takePhoto() async {
    final t = _translations[_langCode]!;
    try {
      final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
      if (photo != null) {
        setState(() => _imagePath = photo.path);
        _tts.speak(t["photo_ok"]!);
        Future.delayed(const Duration(seconds: 1), () => _startStep(1));
      }
    } catch (e) {
      _tts.speak(t["photo_err"]!);
    }
  }

  Future<void> _listenName() async {
    final t = _translations[_langCode]!;
    bool available = await _speech.initialize();
    if (available) {
      setState(() => _isListening = true);
      _tts.stop();
      String sttLocale;
      switch (_langCode) {
        case "es": sttLocale = "es-ES"; break;
        case "en": sttLocale = "en-US"; break;
        case "pt": sttLocale = "pt-PT"; break;
        default: sttLocale = "fr-FR";
      }
      _speech.listen(
        onResult: (val) {
          setState(() {
            _name = val.recognizedWords;
          });
        },
        localeId: sttLocale,
      );
    } else {
      _tts.speak(t["stt_err"]!);
    }
  }
  
  void _stopListening() {
    final t = _translations[_langCode]!;
    _speech.stop();
    setState(() => _isListening = false);
    if (_name.isNotEmpty) {
      _tts.speak("${t["name_recorded"]!}$_name");
      Future.delayed(const Duration(seconds: 2), () => _startStep(2));
    } else {
      _tts.speak(t["no_hear"]!);
    }
  }

  void _addDigit(String digit) {
    setState(() => _number += digit);
    _tts.speak(digit);
  }

  Future<void> _saveContact() async {
    final t = _translations[_langCode]!;
    if (_name.isNotEmpty && _number.isNotEmpty) {
      await _db.addContact(_name, _imagePath ?? "", _number);
      _tts.speak(t["save_ok"]!);
      if (mounted) Navigator.pop(context);
    } else {
      _tts.speak(t["data_err"]!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = _translations[_langCode]!;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Container(
            height: 100,
            color: Colors.black,
            alignment: Alignment.center,
            child: Text(
              _getHeaderText(t),
              style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: _buildBody(t)),
          if (_step != 3)
            Container(
              height: 100,
              width: double.infinity,
              color: Colors.red[900],
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(t["btn_cancel"]!, style: const TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.bold)),
              ),
            ),
        ],
      ),
    );
  }

  String _getHeaderText(Map<String, String> t) {
    switch (_step) {
      case 0: return t["header_photo"]!;
      case 1: return t["header_name"]!;
      case 2: return t["header_number"]!;
      case 3: return t["header_confirm"]!;
      default: return "";
    }
  }

  Widget _buildBody(Map<String, String> t) {
    switch (_step) {
      case 0:
        return Center(
          child: GestureDetector(
            onTap: _takePhoto,
            child: Container(
              width: 300,
              height: 300,
              decoration: const BoxDecoration(color: Colors.yellow, shape: BoxShape.circle),
              child: const Icon(Icons.camera_alt, size: 120, color: Colors.black),
            ),
          ),
        );
      case 1:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_name, style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold)),
              const SizedBox(height: 30),
              // Champ texte pour écrire le nom
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: TextField(
                  style: const TextStyle(color: Colors.white, fontSize: 28),
                  decoration: InputDecoration(
                    hintText: _langCode == "pt" ? "Digite o nome" : 
                               _langCode == "es" ? "Escriba el nombre" :
                               _langCode == "en" ? "Type the name" : "Écrivez le nom",
                    hintStyle: const TextStyle(color: Colors.white54, fontSize: 24),
                    filled: true,
                    fillColor: Colors.grey[800],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: const BorderSide(color: Colors.blue, width: 2),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: const BorderSide(color: Colors.white30, width: 2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: const BorderSide(color: Colors.blue, width: 3),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() => _name = value);
                  },
                ),
              ),
              const SizedBox(height: 40),
              // OU séparateur
              Text(
                _langCode == "pt" ? "OU" : 
                _langCode == "es" ? "O" :
                _langCode == "en" ? "OR" : "OU",
                style: const TextStyle(color: Colors.white54, fontSize: 20),
              ),
              const SizedBox(height: 40),
              // Bouton micro
              GestureDetector(
                onTapDown: (_) => _listenName(),
                onTapUp: (_) => _stopListening(),
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    color: _isListening ? Colors.red : Colors.blue, 
                    shape: BoxShape.circle
                  ),
                  child: const Icon(Icons.mic, size: 100, color: Colors.white),
                ),
              ),
              const SizedBox(height: 20),
              Text(t["tap_to_talk"]!, style: const TextStyle(color: Colors.white70, fontSize: 24)),
              const SizedBox(height: 30),
              // Bouton continuer
              ElevatedButton(
                onPressed: _name.isNotEmpty ? () => _startStep(2) : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: Text(
                  _langCode == "pt" ? "CONTINUAR" : 
                  _langCode == "es" ? "CONTINUAR" :
                  _langCode == "en" ? "CONTINUE" : "CONTINUER",
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        );
      case 2:
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(_number, style: const TextStyle(color: Colors.white, fontSize: 60, letterSpacing: 5, fontWeight: FontWeight.bold)),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(10),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 1.2),
                itemCount: 12,
                itemBuilder: (context, index) {
                  if (index == 9) return _buildNumpadBtn(t["btn_del"]!, Colors.red[700]!, () {
                    if (_number.isNotEmpty) setState(() => _number = _number.substring(0, _number.length - 1));
                    _tts.speak(t["digit_del"]!);
                  });
                  if (index == 10) return _buildNumpadBtn("0", Colors.grey[800]!, () => _addDigit("0"));
                  if (index == 11) return _buildNumpadBtn("OK", Colors.green[700]!, () => _startStep(3));
                  return _buildNumpadBtn("${index + 1}", Colors.grey[800]!, () => _addDigit("${index + 1}"));
                },
              ),
            ),
          ],
        );
      case 3:
        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            if (_imagePath != null) 
              CircleAvatar(radius: 100, backgroundImage: FileImage(File(_imagePath!))),
            Text(_name, style: const TextStyle(color: Colors.white, fontSize: 46, fontWeight: FontWeight.bold)),
            Text(_number, style: const TextStyle(color: Colors.white, fontSize: 46)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildBigBtn(t["btn_no"]!, Colors.red, () => Navigator.pop(context)),
                _buildBigBtn(t["btn_yes"]!, Colors.green, _saveContact),
              ],
            )
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildNumpadBtn(String label, Color color, VoidCallback onTap) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        onTap: onTap,
        child: Center(child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold))),
      ),
    );
  }

  Widget _buildBigBtn(String label, Color color, VoidCallback onTap) {
    return SizedBox(
      width: 160,
      height: 160,
      child: Material(
        color: color,
        borderRadius: BorderRadius.circular(30),
        child: InkWell(
          onTap: onTap,
          child: Center(child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold))),
        ),
      ),
    );
  }
}
