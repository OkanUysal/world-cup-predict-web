import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../config/api_config.dart';

/// Flutter web uyumlu HTTP katmanı.
class ApiHttp {
  ApiHttp._();

  static const _headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  static Future<dynamic> get(
    String path, {
    Map<String, String>? extraHeaders,
  }) {
    return _send('GET', path, extraHeaders: extraHeaders);
  }

  static Future<dynamic> post(
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? extraHeaders,
  }) {
    return _send('POST', path, body: body, extraHeaders: extraHeaders);
  }

  static Future<dynamic> put(
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? extraHeaders,
  }) {
    return _send('PUT', path, body: body, extraHeaders: extraHeaders);
  }

  static Future<dynamic> _send(
    String method,
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? extraHeaders,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}$path');
    final headers = {..._headers, ...?extraHeaders};

    if (kDebugMode) {
      debugPrint('HTTP $method $uri');
    }

    try {
      final response = await _execute(method, uri, headers, body)
          .timeout(ApiConfig.timeout);

      if (kDebugMode) {
        debugPrint('HTTP ${response.statusCode} ${response.body}');
      }

      return _handleResponse(response);
    } catch (e, stack) {
      if (kDebugMode) debugPrint('HTTP fail: $e\n$stack');
      throw _fail(e);
    }
  }

  static String _fail(Object e) {
    if (e is String) return e;
    try {
      final dynamic d = e;
      if (d.message is String && (d.message as String).isNotEmpty) {
        return d.message as String;
      }
    } catch (_) {}
    if (e is http.ClientException) {
      return 'Sunucuya bağlanılamadı (CORS veya ağ hatası). '
          'Backend\'in frontend domain\'ine izin vermesi gerekir.';
    }
    return 'Sunucuya bağlanılamadı (CORS veya ağ hatası). '
        'Backend\'in frontend domain\'ine izin vermesi gerekir.';
  }

  static Future<http.Response> _execute(
    String method,
    Uri uri,
    Map<String, String> headers,
    Map<String, dynamic>? body,
  ) {
    final encoded = body != null ? jsonEncode(body) : null;
    switch (method) {
      case 'GET':
        return http.get(uri, headers: headers);
      case 'POST':
        return http.post(uri, headers: headers, body: encoded);
      case 'PUT':
        return http.put(uri, headers: headers, body: encoded);
      default:
        throw 'Desteklenmeyen HTTP metodu: $method';
    }
  }

  static dynamic _handleResponse(http.Response response) {
    final status = response.statusCode;
    dynamic decoded;

    if (response.body.isNotEmpty) {
      try {
        decoded = jsonDecode(response.body);
      } catch (_) {
        if (status >= 400) throw response.body;
        throw 'Geçersiz sunucu yanıtı';
      }
    }

    if (status >= 400) {
      if (decoded is Map && decoded['error'] != null) {
        final msg = decoded['error'].toString();
        if (status == 401) throw 'HTTP_401:$msg';
        throw msg;
      }
      if (status == 401) throw 'HTTP_401:İstek başarısız ($status)';
      throw 'İstek başarısız ($status)';
    }

    return decoded;
  }
}
