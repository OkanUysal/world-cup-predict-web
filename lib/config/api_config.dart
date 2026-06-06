class ApiConfig {
  /// Her ortamda aynı — local, Docker, Railway static.
  static const baseUrl =
      'https://world-cup-predict-be-production.up.railway.app/api/v1';

  static const timeout = Duration(seconds: 30);
}
