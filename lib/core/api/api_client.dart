import 'package:flutter/foundation.dart';

import '../utils/error_message.dart';
import 'api_exception.dart';
import 'api_http.dart';

typedef OnUnauthorized = Future<void> Function();

class ApiClient {
  ApiClient({
    required this.getToken,
    this.onUnauthorized,
  });

  final Future<String?> Function() getToken;
  final OnUnauthorized? onUnauthorized;

  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    T Function(dynamic data)? parser,
  }) async {
    final pathWithQuery = _withQuery(path, queryParameters);
    return _request(
      () async => ApiHttp.get(
        pathWithQuery,
        extraHeaders: await _authHeaders(pathWithQuery),
      ),
      parser: parser,
      path: pathWithQuery,
    );
  }

  Future<T> post<T>(
    String path, {
    Map<String, dynamic>? data,
    T Function(dynamic data)? parser,
  }) async {
    return _request(
      () async => ApiHttp.post(
        path,
        body: data,
        extraHeaders: await _authHeaders(path),
      ),
      parser: parser,
      path: path,
    );
  }

  Future<T> put<T>(
    String path, {
    Map<String, dynamic>? data,
    T Function(dynamic data)? parser,
  }) async {
    return _request(
      () async => ApiHttp.put(
        path,
        body: data,
        extraHeaders: await _authHeaders(path),
      ),
      parser: parser,
      path: path,
    );
  }

  Future<Map<String, String>> _authHeaders(String path) async {
    if (path.contains('/auth/')) return {};
    final token = await getToken();
    if (token != null && token.isNotEmpty) {
      return {'Authorization': 'Bearer $token'};
    }
    return {};
  }

  String _withQuery(String path, Map<String, dynamic>? queryParameters) {
    if (queryParameters == null || queryParameters.isEmpty) return path;
    final uri = Uri.parse(path).replace(
      queryParameters: queryParameters.map(
        (k, v) => MapEntry(k, v?.toString() ?? ''),
      ),
    );
    return uri.toString();
  }

  Future<T> _request<T>(
    Future<dynamic> Function() call, {
    T Function(dynamic data)? parser,
    required String path,
  }) async {
    try {
      final responseData = await call();
      if (parser != null) {
        try {
          return parser(responseData);
        } catch (e, stack) {
          if (kDebugMode) debugPrint('Parse error: $e\n$stack');
          throw ApiException(message: 'Sunucu yanıtı işlenemedi');
        }
      }
      return responseData as T;
    } on ApiException catch (e) {
      if (e.statusCode == 401 &&
          !path.contains('/auth/') &&
          onUnauthorized != null) {
        await onUnauthorized!();
      }
      rethrow;
    } catch (e, stack) {
      if (kDebugMode) debugPrint('API error: $e\n$stack');
      throw ApiException(message: friendlyErrorMessage(e));
    }
  }
}
