import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiConstants {
  // ==========================================
  // API CONFIGURATION
  // ==========================================

  // Use this for Physical Device connected to the same Wi-Fi as your PC
  static const String wifiIP = '192.168.29.36';

  // Use this strictly for Android Emulator (maps to PC's localhost)
  static const String emulatorIP = '10.0.2.2';

  // **TOGGLE THIS**
  // Set to true if testing on a Physical Device, false if on Emulator.
  // Note: Your Wi-Fi IP (192.168.29.36) usually works for BOTH emulator and physical device!
  static const bool isPhysicalDevice = false;

  static const String vercelUrl = 'https://rapid-x-project.vercel.app/api';

  static String get baseUrl {
    return vercelUrl;
    // For local testing, you can uncomment this:
    /*
    if (kIsWeb) {
      return 'http://localhost:3000/api';
    }
    final String targetIP = isPhysicalDevice ? wifiIP : emulatorIP;
    return 'http://$targetIP:3000/api';
    */
  }
}
