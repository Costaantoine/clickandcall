import 'package:flutter/services.dart';

class CallService {
  static final CallService _instance = CallService._internal();
  factory CallService() => _instance;
  CallService._internal();

  static const MethodChannel _channel = MethodChannel('elderly_launcher/kiosk');

  Future<void> makeCall(String phoneNumber) async {
    try {
      await _channel.invokeMethod('makeCall', {'phoneNumber': phoneNumber});
    } catch (e) {
      throw Exception('Failed to make call: $e');
    }
  }

  Future<void> setupCallListener() async {
    try {
      await _channel.invokeMethod('setupCallListener');
    } catch (e) {
      throw Exception('Failed to setup call listener: $e');
    }
  }
}
