// lib/config/app_config.dart
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class AppConfig {
  /// Tự động nhận diện thiết bị:
  /// - Android Emulator kết nối qua: http://10.0.2.2:5000
  /// - Windows Desktop hoặc Chrome Web kết nối qua: http://localhost:5000
  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:5000';
    try {
      if (Platform.isAndroid) {
        return 'http://10.0.2.2:5000';
      }
    } catch (_) {}
    return 'http://localhost:5000';
  }

  static const int examDurationMinutes = 75;
}
