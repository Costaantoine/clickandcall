import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:elderly_launcher/services/settings_service.dart';
import 'package:elderly_launcher/services/database_service.dart';

class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  final SettingsService _settings = SettingsService();
  final DatabaseService _db = DatabaseService();
  
  bool _wifiOnly = true;
  String _selectedLanguage = "pt";
  final TextEditingController _urlController = TextEditingController();
  List<Map<String, dynamic>> _contacts = [];
  final TextEditingController _emergencyNumbersController = TextEditingController();
  int _sosDelay = 3;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _loadContacts();
  }

  Future<void> _loadSettings() async {
    bool wifi = await _settings.getWifiOnly();
    String url = await _settings.getVideoUrl();
    String lang = await _settings.getLanguage();
    List<String> emergencyNumbers = await _settings.getEmergencyNumbers();
    int sosDelay = await _settings.getSosDelay();
    setState(() {
      _wifiOnly = wifi;
      _urlController.text = url;
      _selectedLanguage = lang;
      _emergencyNumbersController.text = emergencyNumbers.join(', ');
      _sosDelay = sosDelay;
    });
  }
  
  Future<void> _loadContacts() async {
    final contacts = await _db.getContacts();
    setState(() => _contacts = contacts);
  }

  Future<void> _save() async {
    await _settings.setWifiOnly(_wifiOnly);
    await _settings.setVideoUrl(_urlController.text);
    await _settings.setLanguage(_selectedLanguage);
    
    // Sauvegarder les numéros SOS
    List<String> emergencyNumbers = _emergencyNumbersController.text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    if (emergencyNumbers.isEmpty) {
      emergencyNumbers = ["112"];
    }
    await _settings.setEmergencyNumbers(emergencyNumbers);
    
    // Sauvegarder le délai SOS
    await _settings.setSosDelay(_sosDelay);
    
    if (mounted) Navigator.pop(context, true);
  }

  String _getTranslation(String key) {
    final Map<String, String>? langData = _translations[_selectedLanguage];
    if (langData == null) return _translations['en']![key] ?? '';
    return langData[key] ?? '';
  }

  final Map<String, Map<String, String>> _translations = {
    "fr": {
      "title": "Paramètres Aidant",
      "restrictions": "Restrictions",
      "wifi_only_label": "Appel Vidéo uniquement sur Wifi",
      "wifi_only_subtitle": "Empêche la consommation de données mobiles",
      "language_section": "Langue de l'interface",
      "language_label": "Langue (Voix et Textes)",
      "video_url_section": "Configuration",
      "video_url_label": "Lien Jitsi Meet (Salle Vidéo)",
      "save_button": "ENREGISTRER",
      "advanced_section": "Mode Avancé",
      "quit_button": "QUITTER L'APPLICATION",
      "quit_dialog_title": "Quitter l'application ?",
      "quit_dialog_content": "Cela fermera l'application et retournera à l'écran d'accueil Android.",
      "quit_cancel": "ANNULER",
      "quit_confirm": "QUITTER",
      "security_section": "Sécurité",
      "change_pin_button": "CHANGER CODE",
      "apps_button": "OUVRIR APPLICATIONS",
      "contacts_section": "Gestion des contacts",
      "delete_contact_title": "Supprimer un contact",
      "delete_contact_subtitle": "Touchez sur le contact à supprimer",
      "confirm_delete": "Confirmer la suppression ?",
      "delete_confirm": "SUPPRIMER",
      "delete_cancel": "ANNULER",
      "sos_section": "Numéros d'urgence",
      "sos_numbers_label": "Numéros SOS (séparés par des virgules)",
      "sos_delay_label": "Délai entre les appels (secondes)",
      "sos_numbers_hint": "Ex: 112, 911, 17"
    },
    "pt": {
      "title": "Definições",
      "restrictions": "Restrições",
      "wifi_only_label": "Chamadas de vídeo apenas com Wi-Fi",
      "wifi_only_subtitle": "Evita consumo de dados móveis",
      "language_section": "Língua da interface",
      "language_label": "Língua (Voz e Textos)",
      "video_url_section": "Configuração",
      "video_url_label": "Ligação Jitsi Meet (Sala de Vídeo)",
      "save_button": "GUARDAR",
      "advanced_section": "Modo Avançado",
      "quit_button": "SAIR DA APLICAÇÃO",
      "quit_dialog_title": "Sair da aplicação?",
      "quit_dialog_content": "Isto fechará a aplicação e voltará ao ecrã inicial do Android.",
      "quit_cancel": "CANCELAR",
      "quit_confirm": "SAIR",
      "security_section": "Segurança",
      "change_pin_button": "MUDAR CÓDIGO",
      "apps_button": "ABRIR APLICAÇÕES",
      "contacts_section": "Gerir Contactos",
      "delete_contact_title": "Eliminar Contacto",
      "delete_contact_subtitle": "Toque no contacto a eliminar",
      "confirm_delete": "Confirmar eliminação?",
      "delete_confirm": "ELIMINAR",
      "delete_cancel": "CANCELAR",
      "sos_section": "Números de emergência",
      "sos_numbers_label": "Números SOS (separados por vírgulas)",
      "sos_delay_label": "Atraso entre chamadas (segundos)",
      "sos_numbers_hint": "Ex: 112, 911, 17"
    },
    "es": {
      "title": "Configuración del Asistente",
      "restrictions": "Restricciones",
      "wifi_only_label": "Llamadas de vídeo solo en Wi-Fi",
      "wifi_only_subtitle": "Evita el consumo de datos móviles",
      "language_section": "Idioma de la interfaz",
      "language_label": "Idioma (Voz y Textos)",
      "video_url_section": "Configuración",
      "video_url_label": "Enlace Jitsi Meet (Sala de Vídeo)",
      "save_button": "GUARDAR",
      "advanced_section": "Modo Avanzado",
      "quit_button": "SALIR DE LA APLICACIÓN",
      "quit_dialog_title": "¿Salir de la aplicación?",
      "quit_dialog_content": "Esto cerrará la aplicación y volverá a la pantalla de inicio de Android.",
      "quit_cancel": "CANCELAR",
      "quit_confirm": "SALIR",
      "security_section": "Seguridad",
      "change_pin_button": "CAMBIAR CÓDIGO",
      "apps_button": "ABRIR APLICACIONES",
      "contacts_section": "Gestión de Contactos",
      "delete_contact_title": "Eliminar Contacto",
      "delete_contact_subtitle": "Toque en el contacto a eliminar",
      "confirm_delete": "¿Confirmar eliminación?",
      "delete_confirm": "ELIMINAR",
      "delete_cancel": "CANCELAR",
      "sos_section": "Números de emergencia",
      "sos_numbers_label": "Números SOS (separados por comas)",
      "sos_delay_label": "Retraso entre llamadas (segundos)",
      "sos_numbers_hint": "Ej: 112, 911, 17"
    },
    "en": {
      "title": "Settings",
      "restrictions": "Restrictions",
      "wifi_only_label": "Video Call Only on Wi-Fi",
      "wifi_only_subtitle": "Prevents mobile data usage",
      "language_section": "Interface Language",
      "language_label": "Language (Voice and Texts)",
      "video_url_section": "Configuration",
      "video_url_label": "Jitsi Meet Link (Video Room)",
      "save_button": "SAVE",
      "advanced_section": "Advanced Mode",
      "quit_button": "EXIT APPLICATION",
      "quit_dialog_title": "Exit application?",
      "quit_dialog_content": "This will close the application and return to Android home screen.",
      "quit_cancel": "CANCEL",
      "quit_confirm": "EXIT",
      "security_section": "Security",
      "change_pin_button": "CHANGE CODE",
      "apps_button": "OPEN APPLICATIONS",
      "contacts_section": "Manage Contacts",
      "delete_contact_title": "Delete Contact",
      "delete_contact_subtitle": "Tap contact to delete",
      "confirm_delete": "Confirm deletion?",
      "delete_confirm": "DELETE",
      "delete_cancel": "CANCEL",
      "sos_section": "Emergency Numbers",
      "sos_numbers_label": "SOS Numbers (comma separated)",
      "sos_delay_label": "Delay between calls (seconds)",
      "sos_numbers_hint": "Eg: 112, 911, 17"
    }
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: Text(_getTranslation("title")),
        backgroundColor: Colors.grey[800],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Section Restrictions
          Text(_getTranslation("restrictions"), style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          SwitchListTile(
            title: Text(_getTranslation("wifi_only_label"), style: TextStyle(color: Colors.white)),
            subtitle: Text(_getTranslation("wifi_only_subtitle"), style: TextStyle(color: Colors.white70)),
            value: _wifiOnly,
            onChanged: (val) => setState(() => _wifiOnly = val),
          ),
          
          const Divider(color: Colors.white24),
          const SizedBox(height: 20),

          // Section Langue
          Text(_getTranslation("language_section"), style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          ListTile(
            title: Text(_getTranslation("language_label"), style: TextStyle(color: Colors.white)),
            trailing: DropdownButton<String>(
              value: _selectedLanguage,
              dropdownColor: Colors.grey[800],
              style: const TextStyle(color: Colors.white),
              items: const [
                DropdownMenuItem(value: "fr", child: Text("Français")),
                DropdownMenuItem(value: "pt", child: Text("Português (PT)")),
                DropdownMenuItem(value: "es", child: Text("Español")),
                DropdownMenuItem(value: "en", child: Text("English")),
              ],
              onChanged: (val) {
                if (val != null) {
                  setState(() => _selectedLanguage = val);
                  _settings.setLanguage(val); // Sauvegarde immédiate
                }
              },
            ),
          ),

          const Divider(color: Colors.white24),
          const SizedBox(height: 20),

          // Section Configuration
          Text(_getTranslation("video_url_section"), style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          TextField(
            controller: _urlController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: _getTranslation("video_url_label"),
              labelStyle: TextStyle(color: Colors.blue),
              border: const OutlineInputBorder(),
              enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
            ),
          ),
          
          const SizedBox(height: 40),
          const Divider(color: Colors.white24),
          const SizedBox(height: 20),

          // Section Numéros SOS
          Text(_getTranslation("sos_section"), style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          
          TextField(
            controller: _emergencyNumbersController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: _getTranslation("sos_numbers_label"),
              labelStyle: TextStyle(color: Colors.red),
              hintText: _getTranslation("sos_numbers_hint"),
              hintStyle: TextStyle(color: Colors.white54),
              border: const OutlineInputBorder(),
              enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
            ),
          ),
          
          const SizedBox(height: 10),
          
          ListTile(
            title: Text(_getTranslation("sos_delay_label"), style: TextStyle(color: Colors.white)),
            trailing: DropdownButton<int>(
              value: _sosDelay,
              dropdownColor: Colors.grey[800],
              style: const TextStyle(color: Colors.white),
              items: [1, 2, 3, 4, 5].map((seconds) {
                return DropdownMenuItem(
                  value: seconds,
                  child: Text("$seconds seconds", style: TextStyle(color: Colors.white)),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _sosDelay = val);
              },
            ),
          ),

          const SizedBox(height: 40),
          const Divider(color: Colors.white24),
          const SizedBox(height: 20),

          // Section Sécurité
          Text(_getTranslation("security_section"), style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),

          // Bouton changer code PIN
          ElevatedButton.icon(
            onPressed: () => _showChangePinDialog(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange[700],
              padding: const EdgeInsets.all(20),
            ),
            icon: const Icon(Icons.lock, color: Colors.white),
            label: Text(
              _getTranslation("change_pin_button"),
              style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),

          const SizedBox(height: 20),
          const Divider(color: Colors.white24),
          const SizedBox(height: 20),

          // Section Gestion des contacts
          Text(_getTranslation("contacts_section"), style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          
          if (_contacts.isEmpty)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                "Aucun contact.",
                style: TextStyle(color: Colors.white70, fontSize: 18),
              ),
            ),
          
          // Liste des contacts
          ..._contacts.map((contact) {
            return Container(
              margin: const EdgeInsets.only(bottom: 15),
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: null,
              ),
              child: ListTile(
                leading: contact['imagePath'] != null && contact['imagePath'].toString().isNotEmpty
                    ? ClipOval(
                        child: Image.file(
                          File(contact['imagePath'].toString()),
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        ),
                      )
                    : const Icon(Icons.person, size: 40, color: Colors.white70),
                title: Text(
                  contact['name'].toString(),
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  contact['phoneNumber'].toString(),
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  color: Colors.red,
                  onPressed: () => _showDeleteContactDialog(contact),
                ),
              ),
            );
          }).toList(),

          const SizedBox(height: 40),
          const Divider(color: Colors.white24),
          const SizedBox(height: 20),

          // Section Mode Avancé
          Text(_getTranslation("advanced_section"), style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          
          // Bouton ouvrir applications
          ElevatedButton.icon(
            onPressed: () async {
              await launchUrl(Uri.parse('android-app://com.android.launcher3'));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[700],
              padding: const EdgeInsets.all(20),
            ),
            icon: const Icon(Icons.apps, color: Colors.white),
            label: Text(
              _getTranslation("apps_button"),
              style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Bouton quitter application
          ElevatedButton.icon(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: Colors.grey[900],
                  title: Text(_getTranslation("quit_dialog_title"), style: TextStyle(color: Colors.white)),
                  content: Text(_getTranslation("quit_dialog_content"), style: TextStyle(color: Colors.white70)),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(_getTranslation("quit_cancel"), style: TextStyle(color: Colors.white)),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pop(context);
                        Future.delayed(const Duration(milliseconds: 500), () {
                          SystemChannels.platform.invokeMethod('SystemNavigator.pop');
                        });
                      },
                      style: TextButton.styleFrom(backgroundColor: Colors.red),
                      child: Text(_getTranslation("quit_confirm"), style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[700],
              padding: const EdgeInsets.all(20),
            ),
            icon: const Icon(Icons.exit_to_app, color: Colors.white),
            label: Text(
              _getTranslation("quit_button"),
              style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _showChangePinDialog() {
    final TextEditingController currentPinController = TextEditingController();
    final TextEditingController newPinController = TextEditingController();
    final TextEditingController confirmPinController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(_getTranslation("change_pin_button"), style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: currentPinController,
                keyboardType: TextInputType.number,
                obscureText: true,
                maxLength: 4,
                style: const TextStyle(color: Colors.white, fontSize: 20),
                decoration: InputDecoration(
                  labelText: _getTranslation("current_pin_label") ?? "Code actuel",
                  labelStyle: TextStyle(color: Colors.blue),
                  filled: true,
                  fillColor: Colors.grey[800],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: newPinController,
                keyboardType: TextInputType.number,
                obscureText: true,
                maxLength: 4,
                style: const TextStyle(color: Colors.white, fontSize: 20),
                decoration: InputDecoration(
                  labelText: _getTranslation("new_pin_label") ?? "Nouveau code",
                  labelStyle: TextStyle(color: Colors.blue),
                  filled: true,
                  fillColor: Colors.grey[800],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: confirmPinController,
                keyboardType: TextInputType.number,
                obscureText: true,
                maxLength: 4,
                style: const TextStyle(color: Colors.white, fontSize: 20),
                decoration: InputDecoration(
                  labelText: _getTranslation("confirm_pin_label") ?? "Confirmer le code",
                  labelStyle: TextStyle(color: Colors.blue),
                  filled: true,
                  fillColor: Colors.grey[800],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(_getTranslation("delete_cancel"), style: TextStyle(color: Colors.white, fontSize: 18)),
          ),
          ElevatedButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              String savedPin = prefs.getString('user_pin') ?? '5687';
              
              if (currentPinController.text != savedPin) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      _getTranslation("pin_incorrect") ?? "Code actuel incorrect",
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              
              if (newPinController.text.length != 4) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      _getTranslation("pin_invalid_length") ?? "Le code doit avoir 4 chiffres",
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              
              if (newPinController.text != confirmPinController.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      _getTranslation("pin_mismatch") ?? "Les codes ne correspondent pas",
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              
              await prefs.setString('user_pin', newPinController.text);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    _getTranslation("pin_changed") ?? "Code changé avec succès!",
                  ),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: Text(_getTranslation("save_button"), style: TextStyle(fontSize: 18, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showDeleteContactDialog(Map<String, dynamic> contact) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(_getTranslation("delete_contact_title"), style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              _getTranslation("delete_contact_subtitle"),
              style: TextStyle(color: Colors.white70, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(_getTranslation("delete_cancel"), style: TextStyle(color: Colors.white, fontSize: 18)),
          ),
          ElevatedButton(
            onPressed: () async {
              await _db.deleteContact(contact['id'] as int);
              Navigator.pop(context);
              await _loadContacts();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    _getTranslation("contact_deleted") ?? "Contact supprimé",
                  ),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(_getTranslation("delete_confirm"), style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
