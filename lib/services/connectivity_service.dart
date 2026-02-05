
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();

  Future<bool> isWifiConnected() async {
    final result = await _connectivity.checkConnectivity();
    // checkConnectivity returns a List<ConnectivityResult> in newer versions or single in older.
    // Assuming version ^6.0.0, it might return a list or single enum depending on platform.
    // We handle the common case.
    if (result is List<ConnectivityResult>) {
      return result.contains(ConnectivityResult.wifi);
    } else {
       // Fallback for older API shape if needed, though ^6.0.0 usually uses List
      return result == ConnectivityResult.wifi;
    }
  }
}
