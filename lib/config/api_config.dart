import 'package:flutter/foundation.dart';

class ApiConfig {
  static const backendUrl =
      'https://world-cup-predict-be-production.up.railway.app/api/v1';

  /// outcome_flutter ile aynı mantık: istekler proxy üzerinden gider.
  /// target = tam backend URL (encode edilir).
  static String get proxyUrl {
    if (kIsWeb && kDebugMode) {
      // flutter run: `npm start` ile localhost proxy (CORS header'lı)
      return 'http://localhost:8080/api/v1/proxy';
    }
    if (kIsWeb) {
      // Railway release: aynı origin proxy
      return '/api/v1/proxy';
    }
    return '';
  }

  static bool get useProxy => kIsWeb;

  static const timeout = Duration(seconds: 30);

  static const appVersion = '1.0.2';
}
