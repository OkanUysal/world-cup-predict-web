import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../config/api_config.dart';
import '../../models/auth_response.dart';
import 'api_exception.dart';

/// Giriş/kayıt için doğrudan HTTP — Riverpod zinciri yok, minified hata riski az.
class AuthApi {
  AuthApi._();

  static final Dio _dio = Dio(
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

  static Future<AuthResponse> login({
    required String name,
    required String password,
    String? channelCode,
  }) {
    return _postAuth('/auth/login', {
      'name': name,
      'password': password,
      if (channelCode != null && channelCode.isNotEmpty)
        'channel_code': channelCode,
    });
  }

  static Future<AuthResponse> register({
    required String name,
    required String password,
    required String channelCode,
  }) {
    return _postAuth('/auth/register', {
      'name': name,
      'password': password,
      'channel_code': channelCode,
    });
  }

  static Future<AuthResponse> _postAuth(
    String path,
    Map<String, dynamic> body,
  ) async {
    if (kDebugMode) {
      debugPrint('AuthApi POST ${ApiConfig.baseUrl}$path');
    }
    try {
      final response = await _dio.post<Map<String, dynamic>>(path, data: body);
      final status = response.statusCode ?? 0;
      final data = response.data;

      if (status >= 400) {
        final message = _extractError(data);
        throw ApiException(message: message, statusCode: status);
      }
      if (data == null) {
        throw ApiException(message: 'Boş sunucu yanıtı');
      }
      return AuthResponse.fromJson(data);
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      throw ApiException(message: _dioMessage(e), statusCode: e.response?.statusCode);
    } catch (e) {
      throw ApiException(message: 'Bağlantı hatası: ${e.runtimeType}');
    }
  }

  static String _extractError(Map<String, dynamic>? data) {
    if (data != null && data['error'] != null) {
      return data['error'].toString();
    }
    return 'Giriş başarısız';
  }

  static String _dioMessage(DioException e) {
    final data = e.response?.data;
    if (data is Map && data['error'] != null) {
      return data['error'].toString();
    }
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.unknown) {
      return 'Sunucuya bağlanılamadı. Backend CORS ayarını kontrol edin '
          '(frontend farklı domainden istek atıyor).';
    }
    return e.message ?? 'Beklenmeyen ağ hatası';
  }
}
