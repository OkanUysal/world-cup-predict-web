import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../config/api_config.dart';
import 'api_exception.dart';

/// Flutter web uyumlu HTTP katmanı (Dio yerine).
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
    } on ApiException {
      rethrow;
    } on Exception {
      throw ApiException(
        message:
            'Sunucuya bağlanılamadı. CORS veya ağ hatası olabilir — backend erişimini kontrol edin.',
      );
    }
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
        throw ApiException(message: 'Desteklenmeyen HTTP metodu: $method');
    }
  }

  static dynamic _handleResponse(http.Response response) {
    final status = response.statusCode;
    dynamic decoded;

    if (response.body.isNotEmpty) {
      try {
        decoded = jsonDecode(response.body);
      } catch (_) {
        if (status >= 400) {
          throw ApiException(
            message: response.body,
            statusCode: status,
          );
        }
        throw ApiException(message: 'Geçersiz sunucu yanıtı');
      }
    }

    if (status >= 400) {
      final message = decoded is Map && decoded['error'] != null
          ? decoded['error'].toString()
          : 'İstek başarısız ($status)';
      throw ApiException(message: message, statusCode: status);
    }

    return decoded;
  }
}
