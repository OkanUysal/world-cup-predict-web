import 'package:flutter/foundation.dart';

import '../../models/auth_response.dart';
import 'api_exception.dart';
import 'api_http.dart';

/// Giriş/kayıt — doğrudan HTTP, Riverpod yok.
class AuthApi {
  AuthApi._();

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
    try {
      final data = await ApiHttp.post(path, body: body);
      if (data is! Map<String, dynamic>) {
        throw ApiException(message: 'Geçersiz giriş yanıtı');
      }
      return AuthResponse.fromJson(data);
    } on ApiException {
      rethrow;
    } catch (e, stack) {
      if (kDebugMode) debugPrint('AuthApi error: $e\n$stack');
      throw ApiException(message: 'Giriş isteği başarısız');
    }
  }
}
