/// Her zaman okunabilir metin döner — release build'de asla "Instance of minified:..." göstermez.
String displayError(Object? error) {
  if (error == null) return 'Bilinmeyen hata';

  // ApiException — .message kullan, toString değil
  try {
    final dynamic e = error;
    final msg = e.message;
    if (msg is String && msg.isNotEmpty && !_isMinified(msg)) {
      return msg;
    }
  } catch (_) {}

  if (error is String) {
    if (error.startsWith('HTTP_401:')) {
      return error.substring('HTTP_401:'.length);
    }
    return error;
  }

  final text = error.toString();
  if (_isMinified(text)) {
    return 'Bir hata oluştu. Muhtemel nedenler:\n'
        '• Proxy çalışmıyor (local: `npm start` gerekir)\n'
        '• Eski build deploy edilmiş (flutter build + push)\n'
        '• Ağ bağlantısı sorunu';
  }

  return text;
}

bool _isMinified(String text) {
  final lower = text.toLowerCase();
  return lower.contains('minified') || lower.contains('instance of');
}
