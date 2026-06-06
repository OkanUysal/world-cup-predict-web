import 'package:flutter/foundation.dart';

class ApiConfig {
  /// Backend API — doğrudan kodda sabit.
  static const backendUrl =
      'https://world-cup-predict-be-production.up.railway.app/api/v1';

  /// Web release (Railway Docker + nginx proxy): aynı origin, CORS gerekmez.
  /// Local debug (`flutter run`): doğrudan backendUrl (backend CORS açık olmalı).
  static String get baseUrl {
    if (kIsWeb && !kDebugMode) {
      return '/api/v1';
    }
    return backendUrl;
  }

  static const timeout = Duration(seconds: 30);
}
