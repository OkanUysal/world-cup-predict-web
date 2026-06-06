class ApiConfig {
  static const defaultBaseUrl =
      'https://world-cup-predict-be-production.up.railway.app/api/v1';

  static const baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: defaultBaseUrl,
  );

  static const timeout = Duration(seconds: 30);
}
