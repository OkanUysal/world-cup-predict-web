import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
        headers: {'Content-Type': 'application/json'},
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
          handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
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
        } catch (e) {
          throw ApiException(
            message: 'Sunucu yanıtı işlenemedi',
          );
        }
      }
      return responseData as T;
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      throw _mapError(e);
    } catch (e) {
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
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return ApiException(
        message: 'Bağlantı zaman aşımına uğradı',
        statusCode: statusCode,
      );
    }
    if (e.type == DioExceptionType.connectionError) {
      return ApiException(
        message:
            'Sunucuya bağlanılamadı. İnternet bağlantınızı veya CORS ayarlarını kontrol edin.',
        statusCode: statusCode,
      );
    }
    return ApiException(
      message: e.message ?? 'Beklenmeyen bir hata oluştu',
      statusCode: statusCode,
    );
  }
}

final apiClientProvider = Provider<ApiClient>((ref) {
  throw UnimplementedError('apiClientProvider must be overridden');
});
