import 'package:flutter/foundation.dart';

class ApiConfig {
  static const backendUrl =
      'https://world-cup-predict-be-production.up.railway.app/api/v1';

  /// Debug (`flutter run`): doğrudan backend → CORS gerekir.
  /// Release (Railway / npm start): `/api/v1` → server.js proxy → CORS yok.
  static String get baseUrl {
    if (kIsWeb && !kDebugMode) {
      return '/api/v1';
    }
    return backendUrl;
  }

  static const timeout = Duration(seconds: 30);

  /// Deploy doğrulama için
  static const appVersion = '1.0.1';
}
