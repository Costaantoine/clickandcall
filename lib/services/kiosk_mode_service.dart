
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class KioskModeService {
  static final KioskModeService _instance = KioskModeService._internal();
  factory KioskModeService() => _instance;
  KioskModeService._internal();

  bool _isKioskModeEnabled = false;

  bool get isEnabled => _isKioskModeEnabled;

  void enableKioskMode() {
    _isKioskModeEnabled = true;
    
    // Cacher la barre de navigation et status bar
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [],
    );
    
    // Bloquer l'orientation en portrait
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    
    print('🔒 Mode Kiosk activé - Navigation système bloquée');
  }

  void disableKioskMode() {
    _isKioskModeEnabled = false;
    
    // Restaurer la barre système
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
      overlays: SystemUiOverlay.values,
    );
    
    print('🔓 Mode Kiosk désactivé - Navigation système restaurée');
  }

  // Gérer le bouton retour physique
  Future<bool> onWillPop() async {
    if (_isKioskModeEnabled) {
      // Bloquer le retour
      return false;
    }
    return true;
  }

  // Pour Android natif via MethodChannel (plus robuste)
  // Nécessite des modifications Android natives pour bloquer complètement
}
