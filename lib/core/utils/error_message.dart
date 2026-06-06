import '../api/api_exception.dart';

/// Release/minified web build'lerde anlamsız "Instance of minified:..." metinlerini
/// kullanıcı dostu mesajlara çevirir.
String friendlyErrorMessage(Object error) {
  // Minified build'de `is ApiException` güvenilir olmayabilir — duck typing
  try {
    final dynamic e = error;
    final message = e.message;
    if (message is String && message.isNotEmpty) {
      return message;
    }
  } catch (_) {}

  if (error is ApiException) return error.message;

  final type = error.runtimeType.toString();
  if (type.contains('CircularDependency') ||
      type.contains('CircularProvider')) {
    return 'Uygulama yapılandırma hatası. Sayfayı yenileyip tekrar deneyin.';
  }

  final text = error.toString();
  final lower = text.toLowerCase();
  if (lower.contains('minified') ||
      lower.contains('instance of') ||
      text == 'null') {
    return 'Sunucuya bağlanılamadı. CORS veya ağ hatası olabilir — sayfayı yenileyip tekrar deneyin.';
  }

  return text;
}
