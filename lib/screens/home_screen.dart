
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:elderly_launcher/services/tts_service.dart';
import 'package:elderly_launcher/services/database_service.dart';
import 'package:elderly_launcher/utils/extensions.dart';
import 'package:elderly_launcher/screens/add_contact_screen.dart';
import 'package:elderly_launcher/services/connectivity_service.dart';
import 'package:elderly_launcher/services/voice_command_service.dart';
import 'package:elderly_launcher/services/settings_service.dart';
import 'package:elderly_launcher/screens/admin_settings_screen.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:elderly_launcher/service_locator.dart';
import 'package:elderly_launcher/services/kiosk_mode_service.dart';
import 'package:elderly_launcher/services/kiosk_channel_service.dart';
import 'package:vibration/vibration.dart';
import 'package:torch_light/torch_light.dart';
import 'package:elderly_launcher/services/weather_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:elderly_launcher/services/call_service.dart';
import 'package:elderly_launcher/services/sms_service.dart';
import 'package:elderly_launcher/globals.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TtsService _tts = getIt<TtsService>();
  final Battery _battery = getIt<Battery>();
  final DatabaseService _db = getIt<DatabaseService>();
  final ConnectivityService _connectivity = getIt<ConnectivityService>();
  final VoiceCommandService _voiceParams = getIt<VoiceCommandService>();
  final SettingsService _settings = getIt<SettingsService>();
  final KioskModeService _kiosk = getIt<KioskModeService>();
  final CallService _callService = getIt<CallService>();
  final SmsService _smsService = getIt<SmsService>();
  WeatherService? _weather;
  
  String _timeString = "";
  String _dateString = "";
  int _batteryLevel = 100;
  List<Map<String, dynamic>> _contacts = [];
  Timer? _timer;
  String _langCode = "fr";
  bool _isFlashlightOn = false;
  
  // Tap counter for secret admin access
  int _clockTapCount = 0;
  Timer? _tapResetTimer;
  
  // Timer pour les gestes de contact
  Timer? _contactTapTimer;
  Timer? _deleteContactTimer;
  bool _isContactHeld = false;
  Map<String, dynamic>? _heldContact;
  
  // SOS variables
  List<String> _sosNumbers = [];
  int _sosDelay = 3;
  int _currentSosIndex = 0;

  final Map<String, Map<String, String>> _uiTranslations = {
    "fr": {
      "welcome": "Bienvenue. Touchez un contact pour entendre son nom. Maintenez pour appeler.",
      "listening": "À l'écoute... Dites Appeler, Photo ou Vidéo.",
      "video_start": "Démarrage de l'appel vidéo.",
      "no_wifi": "Pas de Wi-Fi. Appel impossible.",
      "calling": "Appel de ",
      "call_fail": "Appel impossible.",
      "add_contact": "Ajouter un contact.",
      "empty_contacts": "Aucun contact.\nTouchez FOTO pour ajouter.",
      "manual_voice": "VOIX",
      "manual_photo": "FOTO",
      "sos_msg": "Urgence. Maintenez pour appeler.",
      "emergency_calling": "Appel d'urgence en cours",
      "sos_label": "SOS",
      "sos_hold": "Maintenir pour appeler",
      "flashlight_on": "Lampe allumée",
      "flashlight_off": "Lampe éteinte",
      "flashlight_unavailable": "Lampe non disponible",
      "video_call_family": "Appel vidéo famille",
      "battery_level": "Batterie à {level} pour cent",
      "weather": "Météo aujourd'hui. {condition}. {temperature} degrés."
    },
    "pt": {
      "welcome": "Bem-vindo. Toque num contacto para ouvir o nome. Mantenha premido para ligar.",
      "listening": "À escuta... Diga Liga, Foto ou Vídeo.",
      "video_start": "A iniciar chamada de vídeo.",
      "no_wifi": "Sem Wi-Fi. Chamada impossível.",
      "calling": "A ligar para ",
      "call_fail": "Não foi possível ligar.",
      "add_contact": "Adicionar contacto.",
      "empty_contacts": "Sem contactos.\nToque em FOTO para adicionar.",
      "manual_voice": "VOZ",
      "manual_photo": "FOTO",
      "sos_msg": "Emergência. Mantenha premido para ligar.",
      "emergency_calling": "A ligar para a emergência",
      "sos_label": "SOS",
      "sos_hold": "Mantenha premido para ligar",
      "flashlight_on": "Lanterna ligada",
      "flashlight_off": "Lanterna desligada",
      "flashlight_unavailable": "Lanterna não disponível",
      "video_call_family": "Chamada de vídeo família",
      "battery_level": "Bateria com {level} por cento",
      "weather": "Tempo hoje. {condition}. {temperature} graus."
    },
    "es": {
      "welcome": "Bienvenido. Toque un contacto para oír su nombre. Mantenga presionado para llamar.",
      "listening": "Escuchando... Diga Llamar, Foto o Vídeo.",
      "video_start": "Iniciando llamada de vídeo.",
      "no_wifi": "Sin Wi-Fi. Llamada imposible.",
      "calling": "Llamando a ",
      "call_fail": "No se pudo realizar la llamada.",
      "add_contact": "Añadir contacto.",
      "empty_contacts": "Sin contactos.\nToque FOTO para añadir.",
      "manual_voice": "VOZ",
      "manual_photo": "FOTO",
      "sos_msg": "Emergencia. Mantenga para llamar.",
      "emergency_calling": "Llamando a emergencia",
      "sos_label": "SOS",
      "sos_hold": "Mantenga para llamar",
      "flashlight_on": "Linterna encendida",
      "flashlight_off": "Linterna apagada",
      "flashlight_unavailable": "Linterna no disponible",
      "video_call_family": "Llamada de vídeo familia",
      "battery_level": "Batería al {level} por ciento",
      "weather": "Clima hoy. {condition}. {temperature} grados."
    },
    "en": {
      "welcome": "Welcome. Tap a contact to hear their name. Hold to call.",
      "listening": "Listening... Say Call, Photo, or Video.",
      "video_start": "Starting video call.",
      "no_wifi": "No Wi-Fi. Call impossible.",
      "calling": "Calling ",
      "call_fail": "Could not place call.",
      "add_contact": "Add contact.",
      "empty_contacts": "No contacts.\nTap PHOTO to add.",
      "manual_voice": "VOICE",
      "manual_photo": "PHOTO",
      "sos_msg": "SOS. Hold to call.",
      "emergency_calling": "Calling emergency services",
      "sos_label": "SOS",
      "sos_hold": "Hold to call",
      "flashlight_on": "Flashlight on",
      "flashlight_off": "Flashlight off",
      "flashlight_unavailable": "Flashlight unavailable",
      "video_call_family": "Family video call",
      "battery_level": "Battery at {level} percent",
      "weather": "Weather today. {condition}. {temperature} degrees."
    }
  };

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _initBattery();
    _loadContacts();
    _checkPermissions();
    _checkFirstLaunch(); // Vérifier si c'est la première ouverture
    _setupCallListener(); // Initialiser le listener d'appel
    _setupSmsListener(); // Initialiser le listener SMS
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) => _updateTime());
  }

  Future<void> _loadInitialData() async {
    final lang = await _settings.getLanguage();
    _langCode = lang;
    
    // Initialiser le service météo
    _weather = WeatherService(_tts);
    
    String locale;
    switch (lang) {
      case "es": locale = "es_ES"; break;
      case "en": locale = "en_US"; break;
      case "pt": locale = "pt_PT"; break;
      default: locale = "fr_FR";
    }
    await initializeDateFormatting(locale, null);
    _updateTime();
    await _applyLanguageToServices();
    
    // Charger les numéros SOS et le délai
    _sosNumbers = await _settings.getEmergencyNumbers();
    _sosDelay = await _settings.getSosDelay();
    
    // Announce welcome (dans la bonne langue, TTS déjà initialisé)
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _tts.speak(_uiTranslations[_langCode]!["welcome"]!);
        _initVoice();
      });
    }
  }

  Future<void> _applyLanguageToServices() async {
    String ttsLocale;
    switch (_langCode) {
      case "es": ttsLocale = "es-ES"; break;
      case "en": ttsLocale = "en-US"; break;
      case "pt": ttsLocale = "pt-PT"; break;
      default: ttsLocale = "fr-FR";
    }
    await _tts.init(ttsLocale);
    _voiceParams.setLocale(ttsLocale);
  }

  Future<void> _checkPermissions() async {
    await [
      Permission.camera,
      Permission.microphone,
      Permission.phone,
      Permission.contacts,
    ].request();
  }

  Future<void> _initVoice() async {
    await _voiceParams.init();
  }

  Future<void> _setupCallListener() async {
    try {
      await _callService.setupCallListener();
    } catch (e) {
      print('Error setting up call listener: $e');
    }
  }

  Future<void> _setupSmsListener() async {
    _smsService.initialize(navigatorKey);
  }

  Future<void> _checkWifiAndVideoCall() async {
    bool wifiRequired = await _settings.getWifiOnly();
    bool isWifi = await _connectivity.isWifiConnected();
    String videoUrl = await _settings.getVideoUrl();

    if (!wifiRequired || isWifi) {
       _tts.speak(_uiTranslations[_langCode]!["video_start"]!);
       await launchUrl(Uri.parse(videoUrl));
    } else {
       _tts.speak(_uiTranslations[_langCode]!["no_wifi"]!);
    }
  }

  Future<void> _showAdminDialog() async {
    final prefs = await SharedPreferences.getInstance();
    String savedPin = prefs.getString('user_pin') ?? '5687'; // Code par défaut: 5687
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final TextEditingController pinController = TextEditingController();
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text(
            _langCode == 'pt' ? 'Código de Acesso' : 
            _langCode == 'es' ? 'Código de Acceso' :
            _langCode == 'en' ? 'Access Code' : 'Code d\'Accès',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: pinController,
                keyboardType: TextInputType.number,
                obscureText: true,
                maxLength: 4,
                style: const TextStyle(color: Colors.white, fontSize: 24),
                decoration: InputDecoration(
                  hintText: _langCode == 'pt' ? 'Digite o código (4 dígitos)' : 
                            _langCode == 'es' ? 'Introduzca el código (4 dígitos)' :
                            _langCode == 'en' ? 'Enter code (4 digits)' : 'Entrez le code (4 chiffres)',
                  hintStyle: const TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: Colors.grey[800],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _showMasterCodeDialog(savedPin);
                },
                child: Text(
                  _langCode == 'pt' ? 'Código esquecido?' : 
                  _langCode == 'es' ? '¿Código olvidado?' :
                  _langCode == 'en' ? 'Forgot code?' : 'Code oublié?',
                  style: const TextStyle(color: Colors.blue),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                _langCode == 'pt' ? 'Cancelar' : 
                _langCode == 'es' ? 'Cancelar' :
                _langCode == 'en' ? 'Cancel' : 'Annuler',
                style: const TextStyle(color: Colors.white),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (pinController.text == savedPin) {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminSettingsScreen())).then((changed) {
                    if (changed == true) {
                      _loadInitialData();
                    }
                  });
                } else {
                  Navigator.pop(context);
                  _tts.speak(_langCode == "fr" ? "Code incorrect" : 
                            _langCode == "pt" ? "Código incorreto" :
                            _langCode == "es" ? "Código incorrecto" : "Incorrect code");
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              child: const Text("OK", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showMasterCodeDialog(String currentPin) {
    showDialog(
      context: context,
      builder: (context) {
        final TextEditingController masterController = TextEditingController();
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text(
            _langCode == 'pt' ? 'Código Mestre' : 
            _langCode == 'es' ? 'Código Maestro' :
            _langCode == 'en' ? 'Master Code' : 'Code Maître',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: TextField(
            controller: masterController,
            keyboardType: TextInputType.number,
            obscureText: true,
            style: const TextStyle(color: Colors.white, fontSize: 24),
            decoration: InputDecoration(
              hintText: '5687',
              hintStyle: const TextStyle(color: Colors.white54),
              filled: true,
              fillColor: Colors.grey[800],
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar", style: TextStyle(color: Colors.white)),
            ),
            ElevatedButton(
              onPressed: () async {
                if (masterController.text == '5687') {
                  Navigator.pop(context);
                  // Accès avec code maître
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminSettingsScreen())).then((changed) {
                    if (changed == true) {
                      _loadInitialData();
                    }
                  });
                } else {
                  Navigator.pop(context);
                  _tts.speak("Código mestre incorreto");
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text("OK", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _checkFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    bool isFirstLaunch = prefs.getBool('first_launch') ?? true;
    
    if (isFirstLaunch) {
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        _showFirstLaunchPinSetup();
      }
    }
  }

  void _showFirstLaunchPinSetup() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final TextEditingController pinController = TextEditingController();
        final TextEditingController confirmController = TextEditingController();
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text(
            _langCode == 'pt' ? 'Bem-vindo ao ClickAndCall!' : 
            _langCode == 'es' ? '¡Bienvenido a ClickAndCall!' :
            _langCode == 'en' ? 'Welcome to ClickAndCall!' : 'Bienvenue sur ClickAndCall!',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _langCode == 'pt' ? 'Defina o seu código de acesso (4 dígitos):' : 
                  _langCode == 'es' ? 'Establezca su código de acceso (4 dígitos):' :
                  _langCode == 'en' ? 'Set your access code (4 digits):' : 'Définissez votre code d\'accès (4 chiffres):',
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: pinController,
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  maxLength: 4,
                  style: const TextStyle(color: Colors.white, fontSize: 24),
                  decoration: InputDecoration(
                    labelText: _langCode == 'pt' ? 'Código' : 
                               _langCode == 'es' ? 'Código' :
                               _langCode == 'en' ? 'Code' : 'Code',
                    labelStyle: const TextStyle(color: Colors.blue),
                    filled: true,
                    fillColor: Colors.grey[800],
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: confirmController,
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  maxLength: 4,
                  style: const TextStyle(color: Colors.white, fontSize: 24),
                  decoration: InputDecoration(
                    labelText: _langCode == 'pt' ? 'Confirmar código' : 
                               _langCode == 'es' ? 'Confirmar código' :
                               _langCode == 'en' ? 'Confirm code' : 'Confirmer le code',
                    labelStyle: const TextStyle(color: Colors.blue),
                    filled: true,
                    fillColor: Colors.grey[800],
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                if (pinController.text.length == 4 && 
                    pinController.text == confirmController.text) {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setString('user_pin', pinController.text);
                  await prefs.setBool('first_launch', false);
                  Navigator.pop(context);
                  _tts.speak(_langCode == 'pt' ? 'Código definido com sucesso!' : 
                            _langCode == 'es' ? '¡Código establecido correctamente!' :
                            _langCode == 'en' ? 'Code set successfully!' : 'Code défini avec succès!');
                } else {
                  _tts.speak(_langCode == 'pt' ? 'Código inválido ou não coincidente' : 
                            _langCode == 'es' ? 'Código inválido o no coincidente' :
                            _langCode == 'en' ? 'Invalid or non-matching code' : 'Code invalide ou non correspondant');
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: Text(
                _langCode == 'pt' ? 'Guardar' : 
                _langCode == 'es' ? 'Guardar' :
                _langCode == 'en' ? 'Save' : 'Enregistrer',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _updateTime() {
    final DateTime now = DateTime.now();
    String locale;
    switch (_langCode) {
      case "es": locale = "es_ES"; break;
      case "en": locale = "en_US"; break;
      case "pt": locale = "pt_PT"; break;
      default: locale = "fr_FR";
    }
    setState(() {
      _timeString = DateFormat('HH:mm').format(now);
      _dateString = DateFormat('EEEE, d MMMM', locale).format(now).toUpperCase();
    });
  }

  Future<void> _initBattery() async {
    final level = await _battery.batteryLevel;
    setState(() => _batteryLevel = level);
    _battery.onBatteryStateChanged.listen((state) async {
      final level = await _battery.batteryLevel;
      setState(() => _batteryLevel = level);
    });
  }

  Future<void> _loadContacts() async {
    final contacts = await _db.getContacts();
    setState(() => _contacts = contacts);
  }

  Future<void> _makeCall(String number) async {
    await Vibration.vibrate(duration: 200);
    try {
      await _callService.makeCall(number);
    } catch (e) {
      _tts.speak(_uiTranslations[_langCode]!["call_fail"]!);
    }
  }

  Future<void> _toggleFlashlight() async {
    try {
      if (_isFlashlightOn) {
        await TorchLight.disableTorch();
        _tts.speak(_uiTranslations[_langCode]!["flashlight_off"]!);
      } else {
        await TorchLight.enableTorch();
        _tts.speak(_uiTranslations[_langCode]!["flashlight_on"]!);
      }
      setState(() => _isFlashlightOn = !_isFlashlightOn);
    } catch (e) {
      _tts.speak(_uiTranslations[_langCode]!["flashlight_unavailable"]!);
    }
  }

  Future<void> _handleClockTap() async {
    _clockTapCount++;
    
    // Reset counter after 2 seconds
    _tapResetTimer?.cancel();
    _tapResetTimer = Timer(const Duration(seconds: 2), () {
      _clockTapCount = 0;
    });
    
    // 1 tap = announce time and date (format numerique pour le TTS)
    if (_clockTapCount == 1) {
      await Vibration.vibrate(duration: 100);
      final DateTime now = DateTime.now();
      String ttsDate = "${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}";
      _tts.speak('$_timeString, $ttsDate');
    }
    // 5 taps = admin mode
    else if (_clockTapCount >= 5) {
      _clockTapCount = 0;
      _tapResetTimer?.cancel();
      _showAdminDialog();
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = _uiTranslations[_langCode]!;
    final Size screenSize = MediaQuery.of(context).size;
    final bool isSmallScreen = screenSize.width < 600;
    final bool isVerySmallScreen = screenSize.width < 400;
    
    return Scaffold(
      body: Column(
        children: [
          // HEADER
          Container(
            padding: EdgeInsets.all(isVerySmallScreen ? 8.0 : 16.0),
            color: Colors.black,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Weather Button (Tap to hear forecast)
                    GestureDetector(
                      onTap: () async {
                        await Vibration.vibrate(duration: 100);
                        await _weather?.announceWeather(_langCode);
                      },
                      child: Row(
                        children: [
                          Icon(Icons.wb_sunny, color: Colors.yellow, size: isSmallScreen ? 30 : 40),
                          SizedBox(width: isSmallScreen ? 5 : 10),
                          Text("${_weather?.getTemperature() ?? '--'}°C", style: TextStyle(
                            color: Colors.white,
                            fontSize: isSmallScreen ? 18 : 24,
                          )),
                        ],
                      ),
                    ),
                    // Battery (Tap to announce battery level)
                    GestureDetector(
                      onTap: () async {
                        await Vibration.vibrate(duration: 100);
                        String level = _batteryLevel.toString();
                        String batteryText = _uiTranslations[_langCode]!["battery_level"]!
                            .replaceAll("{level}", level);
                        _tts.speak(batteryText);
                      },
                      child: Row(
                        children: [
                          Icon(
                            _batteryLevel > 20 ? Icons.battery_full : Icons.battery_alert,
                            color: _batteryLevel > 20 ? Colors.green : Colors.red,
                            size: isSmallScreen ? 30 : 40,
                          ),
                          const SizedBox(width: 5),
                          Text("$_batteryLevel%", style: TextStyle(
                            color: Colors.white,
                            fontSize: isSmallScreen ? 18 : 24,
                          )),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: isSmallScreen ? 10 : 20),
                GestureDetector(
                  onTap: _handleClockTap,
                  child: Text(
                    _timeString,
                    style: TextStyle(
                      fontSize: isVerySmallScreen ? 50 : (isSmallScreen ? 60 : 80), 
                      fontWeight: FontWeight.bold, 
                      color: Colors.white,
                    ),
                  ),
                ),
                Text(
                  _dateString,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 16 : 24, 
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          
          const Divider(color: Colors.white24, thickness: 2),

          // MAIN GRID
          Expanded(
            child: _contacts.isEmpty 
              ? Center(child: Text(t["empty_contacts"]!, textAlign: TextAlign.center, style: TextStyle(
                color: Colors.white54, 
                fontSize: isSmallScreen ? 18 : 24,
              )))
              : GridView.builder(
                padding: EdgeInsets.all(isSmallScreen ? 8 : 16),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isSmallScreen ? 1 : 2,
                  crossAxisSpacing: isSmallScreen ? 8 : 16,
                  mainAxisSpacing: isSmallScreen ? 8 : 16,
                ),
                itemCount: _contacts.length,
                itemBuilder: (context, index) {
                  final contact = _contacts[index];
                  return _buildContactCard(contact, isSmallScreen);
                },
              ),
          ),

          // FOOTER - 4 BOUTONS
          Container(
            height: isSmallScreen ? 120 : 160,
            padding: EdgeInsets.all(isSmallScreen ? 5 : 10),
            color: Colors.black,
            child: Row(
              children: [
                // VIDÉO FAMILLE - 1 CLICK
                Expanded(
                  child: _buildFooterButton(
                    label: "VIDÉO",
                    color: Colors.purple[700]!,
                    icon: Icons.video_call,
                    isSmallScreen: isSmallScreen,
                    onTap: () async {
                      await Vibration.vibrate(duration: 100);
                      _tts.speak(_uiTranslations[_langCode]!["video_call_family"]!);
                      _checkWifiAndVideoCall();
                    },
                  ),
                ),
                const SizedBox(width: 10),
                // LAMPE TORCHE
                Expanded(
                  child: _buildFooterButton(
                    label: "LAMPE",
                    color: _isFlashlightOn ? Colors.orange[700]! : Colors.grey[700]!,
                    icon: _isFlashlightOn ? Icons.flashlight_on : Icons.flashlight_off,
                    isSmallScreen: isSmallScreen,
                    onTap: () async {
                      await Vibration.vibrate(duration: 100);
                      _toggleFlashlight();
                    },
                  ),
                ),
                const SizedBox(width: 10),
                // COMMANDE VOCALE
                Expanded(
                  child: _buildFooterButton(
                    label: t["manual_voice"]!,
                    color: Colors.blue,
                    icon: Icons.mic,
                    isSmallScreen: isSmallScreen,
                    onTap: () async {
                      await Vibration.vibrate(duration: 100);
                      _tts.speak(t["listening"]!);
                      _voiceParams.listenAndProcess((status) {
                         String statusLower = status.toLowerCase();
                         if (statusLower.contains("video")) {
                           _checkWifiAndVideoCall();
                         } else if (statusLower.contains("lampe") || statusLower.contains("flashlight") || 
                                    statusLower.contains("luz") || statusLower.contains("linterna")) {
                           _toggleFlashlight();
                         } else if (statusLower.contains("météo") || statusLower.contains("weather") || 
                                    statusLower.contains("tempo")) {
                           _weather?.announceWeather(_langCode);
                         } else if (statusLower.contains("batterie") || statusLower.contains("battery") || 
                                    statusLower.contains("bateria")) {
                           String level = _batteryLevel.toString();
                           String batteryText = _uiTranslations[_langCode]!["battery_level"]!
                               .replaceAll("{level}", level);
                           _tts.speak(batteryText);
                         }
                      });
                    },
                  ),
                ),
                const SizedBox(width: 10),
                // AJOUT CONTACT
                Expanded(
                  child: _buildFooterButton(
                    label: t["manual_photo"]!,
                    color: Colors.yellow[700]!,
                    icon: Icons.camera_alt,
                    textColor: Colors.black,
                    isSmallScreen: isSmallScreen,
                    onTap: () async {
                      await Vibration.vibrate(duration: 100);
                      _tts.speak(t["add_contact"]!);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AddContactScreen()),
                      ).then((_) => _loadContacts());
                    },
                  ),
                ),
              ],
            ),
          ),
          
          // SOS BUTTON
          Container(
            color: Colors.red[900],
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            child: InkWell(
              onTap: () => _tts.speak(t["sos_msg"]!),
              onLongPress: () async {
                 _tts.speak(t["emergency_calling"]!);
                 await _makeSosCall();
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "SOS (${_sosNumbers.isNotEmpty ? _sosNumbers[0] : '112'})",
                    style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    t["sos_hold"]!,
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _makeSosCall() async {
    if (_sosNumbers.isEmpty) {
      _sosNumbers = await _settings.getEmergencyNumbers();
      if (_sosNumbers.isEmpty) {
        _makeCall("112");
        return;
      }
    }
    
    for (int i = 0; i < _sosNumbers.length; i++) {
      _currentSosIndex = i;
      await _makeCall(_sosNumbers[i]);
      
      // Attendre le délai avant d'essayer le numéro suivant
      if (i < _sosNumbers.length - 1) {
        await Future.delayed(Duration(seconds: _sosDelay));
      }
    }
  }

  Widget _buildContactCard(Map<String, dynamic> contact, bool isSmallScreen) {
    return GestureDetector(
      onTapDown: (details) {
        _onContactTapDown(contact);
      },
      onTapUp: (details) {
        _onContactTapUp();
      },
      onTapCancel: () {
        _onContactTapCancel();
      },
      child: Card(
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (contact['imagePath'] != null && File(contact['imagePath']).existsSync())
              Image.file(File(contact['imagePath']), fit: BoxFit.cover)
            else
              Container(
                color: Colors.grey[800],
                child: const Icon(Icons.person, size: 60, color: Colors.white),
              ),
            // Optional: Name overlay? No, prompt says "Zero Text Entry" but we can show visual name if available for helpers, 
            // but the prompt emphasizes photos. I'll leave it clean or add a small label at bottom.
          ],
        ),
      ),
    );
  }

  void _onContactTapDown(Map<String, dynamic> contact) {
    _heldContact = contact;
    _isContactHeld = true;
    
    // Timer de 2 secondes pour déclencher l'appel
    _contactTapTimer = Timer(const Duration(seconds: 2), () {
      if (_isContactHeld) {
        Vibration.vibrate(duration: 200);
        _tts.speak("${_uiTranslations[_langCode]!['calling']!}${contact['name']}");
        _makeCall(contact['phoneNumber']);
        _isContactHeld = false;
      }
    });
    
    // Timer de 8 secondes pour proposer la suppression
    _deleteContactTimer = Timer(const Duration(seconds: 8), () {
      if (_isContactHeld) {
        _showDeleteContactDialog(contact);
        _isContactHeld = false;
      }
    });
  }

  void _onContactTapUp() {
    if (_isContactHeld && _contactTapTimer != null && _contactTapTimer!.isActive) {
      // Tap court (<2s) = dire le nom
      _contactTapTimer!.cancel();
      _deleteContactTimer?.cancel();
      Vibration.vibrate(duration: 50);
      _tts.speak(_heldContact!['name']);
    }
    _isContactHeld = false;
    _heldContact = null;
  }

  void _onContactTapCancel() {
    _contactTapTimer?.cancel();
    _deleteContactTimer?.cancel();
    _isContactHeld = false;
    _heldContact = null;
  }

  void _showDeleteContactDialog(Map<String, dynamic> contact) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(
          _langCode == 'pt' ? 'Eliminar Contacto' :
          _langCode == 'es' ? 'Eliminar Contacto' :
          _langCode == 'en' ? 'Delete Contact' : 'Supprimer le contact',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (contact['imagePath'] != null && contact['imagePath'].toString().isNotEmpty)
              ClipOval(
                child: Image.file(
                  File(contact['imagePath'].toString()),
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 20),
            Text(
              contact['name'].toString(),
              style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              _langCode == 'pt' ? 'Deseja eliminar este contacto?' :
              _langCode == 'es' ? '¿Desea eliminar este contacto?' :
              _langCode == 'en' ? 'Do you want to delete this contact?' : 'Voulez-vous supprimer ce contact?',
              style: const TextStyle(color: Colors.white70, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              _langCode == 'pt' ? 'CANCELAR' :
              _langCode == 'es' ? 'CANCELAR' :
              _langCode == 'en' ? 'CANCEL' : 'ANNULER',
              style: const TextStyle(color: Colors.white),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              await _db.deleteContact(contact['id'] as int);
              Navigator.pop(context);
              await _loadContacts();
              _tts.speak(_langCode == 'pt' ? 'Contacto eliminado' :
                         _langCode == 'es' ? 'Contacto eliminado' :
                         _langCode == 'en' ? 'Contact deleted' : 'Contact supprimé');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(
              _langCode == 'pt' ? 'ELIMINAR' :
              _langCode == 'es' ? 'ELIMINAR' :
              _langCode == 'en' ? 'DELETE' : 'SUPPRIMER',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterButton({
    required String label,
    required Color color,
    required IconData icon,
    required VoidCallback onTap,
    Color textColor = Colors.white,
    bool isSmallScreen = false,
  }) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: isSmallScreen ? 30 : 40, color: textColor),
            SizedBox(height: isSmallScreen ? 4 : 8),
            Text(label, style: TextStyle(
              fontSize: isSmallScreen ? 16 : 24, 
              fontWeight: FontWeight.bold, 
              color: textColor,
            )),
          ],
        ),
      ),
    );
  } // End _buildFooterButton
}
