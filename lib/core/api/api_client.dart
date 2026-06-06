import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../config/api_config.dart';
import '../utils/error_message.dart';
import 'api_exception.dart';

typedef OnUnauthorized = Future<void> Function();

class ApiClient {
  ApiClient({
    required this.getToken,
    this.onUnauthorized,
  }) {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: ApiConfig.timeout,
        receiveTimeout: ApiConfig.timeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final isAuthPath = options.path.startsWith('/auth/');
          if (!isAuthPath) {
            final token = await getToken();
            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          }
          if (kDebugMode) {
            debugPrint('API ${options.method} ${options.uri}');
          }
          handler.next(options);
        },
        onResponse: (response, handler) {
          final status = response.statusCode ?? 0;
          if (status >= 400) {
            handler.reject(
              DioException(
                requestOptions: response.requestOptions,
                response: response,
                type: DioExceptionType.badResponse,
              ),
            );
            return;
          }
          handler.next(response);
        },
        onError: (error, handler) async {
          final path = error.requestOptions.path;
          final isAuthPath = path.startsWith('/auth/');
          if (!isAuthPath && error.response?.statusCode == 401) {
            await onUnauthorized?.call();
          }
          handler.next(error);
        },
      ),
    );
  }

  late final Dio _dio;
  final Future<String?> Function() getToken;
  final OnUnauthorized? onUnauthorized;

  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    T Function(dynamic data)? parser,
  }) async {
    return _request(
      () => _dio.get<dynamic>(path, queryParameters: queryParameters),
      parser: parser,
    );
  }

  Future<T> post<T>(
    String path, {
    Map<String, dynamic>? data,
    T Function(dynamic data)? parser,
  }) async {
    return _request(
      () => _dio.post<dynamic>(path, data: data),
      parser: parser,
    );
  }

  Future<T> put<T>(
    String path, {
    Map<String, dynamic>? data,
    T Function(dynamic data)? parser,
  }) async {
    return _request(
      () => _dio.put<dynamic>(path, data: data),
      parser: parser,
    );
  }

  Future<T> _request<T>(
    Future<Response<dynamic>> Function() request, {
    T Function(dynamic data)? parser,
  }) async {
    try {
      final response = await request();
      final responseData = response.data;
      if (parser != null) {
        try {
          return parser(responseData);
        } catch (e, stack) {
          if (kDebugMode) debugPrint('Parse error: $e\n$stack');
          throw ApiException(message: 'Sunucu yanıtı işlenemedi');
        }
      }
      return responseData as T;
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      throw _mapError(e);
    } catch (e, stack) {
      if (kDebugMode) debugPrint('API error: $e\n$stack');
      throw ApiException(message: friendlyErrorMessage(e));
    }
  }

  ApiException _mapError(DioException e) {
    final statusCode = e.response?.statusCode;
    final data = e.response?.data;

    if (data is Map && data['error'] != null) {
      return ApiException(
        message: data['error'].toString(),
        statusCode: statusCode,
      );
    }
    if (data is String && data.isNotEmpty) {
      try {
        // Bazı yanıtlar JSON string olarak gelebilir
        if (data.contains('"error"')) {
          final match = RegExp(r'"error"\s*:\s*"([^"]+)"').firstMatch(data);
          if (match != null) {
            return ApiException(
              message: match.group(1)!,
              statusCode: statusCode,
            );
          }
        }
      } catch (_) {}
      return ApiException(message: data, statusCode: statusCode);
    }
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return ApiException(
        message: 'Bağlantı zaman aşımına uğradı',
        statusCode: statusCode,
      );
    }
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.unknown) {
      return ApiException(
        message:
            'Sunucuya bağlanılamadı. CORS veya ağ hatası olabilir — backend erişimini kontrol edin.',
        statusCode: statusCode,
      );
    }
    return ApiException(
      message: friendlyErrorMessage(e),
      statusCode: statusCode,
    );
  }
}
