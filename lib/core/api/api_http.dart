import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../config/api_config.dart';

/// outcome_flutter proxy deseni:
/// `proxy?target=${Uri.encodeComponent(fullBackendUrl)}`
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
    final target = Uri.parse('${ApiConfig.backendUrl}$path');
    final uri = _requestUri(target);
    final headers = {..._headers, ...?extraHeaders};

    if (kDebugMode) {
      debugPrint('HTTP $method $uri');
      if (ApiConfig.useProxy) debugPrint('  target: $target');
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

  static Uri _requestUri(Uri target) {
    if (!ApiConfig.useProxy) return target;
    return Uri.parse(
      '${ApiConfig.proxyUrl}?target=${Uri.encodeComponent(target.toString())}',
    );
  }

  static String _fail(Object e) {
    if (e is String) return e;
    if (e is http.ClientException) {
      if (ApiConfig.useProxy && kDebugMode) {
        return 'Sunucuya bağlanılamadı. `npm start` ile proxy\'yi '
            'localhost:8080\'de çalıştırın.';
      }
      return 'Sunucuya bağlanılamadı (ağ hatası).';
    }
    return 'Sunucuya bağlanılamadı (ağ hatası).';
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
