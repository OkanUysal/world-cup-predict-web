import '../api/api_exception.dart';

/// Release/minified web build'lerde anlamsız "Instance of minified:..." metinlerini
/// kullanıcı dostu mesajlara çevirir.
String friendlyErrorMessage(Object error) {
  if (error is ApiException) return error.message;

  final text = error.toString();
  if (text.contains('minified:') ||
      text.startsWith('Instance of ') ||
      text == 'null') {
    return 'Bir hata oluştu. İnternet bağlantınızı kontrol edin veya daha sonra tekrar deneyin.';
  }

  return text;
}
