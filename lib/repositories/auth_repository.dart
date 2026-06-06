import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/api/api_client.dart';
import '../models/auth_response.dart';
import '../models/user_profile.dart';

class AuthRepository {
  AuthRepository(this._client);

  final ApiClient _client;

  Future<AuthResponse> login({
    required String name,
    required String password,
    String? channelCode,
  }) async {
    return _client.post(
      '/auth/login',
      data: {
        'name': name,
        'password': password,
        if (channelCode != null && channelCode.isNotEmpty)
          'channel_code': channelCode,
      },
      parser: (data) => AuthResponse.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<AuthResponse> register({
    required String name,
    required String password,
    required String channelCode,
  }) async {
    return _client.post(
      '/auth/register',
      data: {
        'name': name,
        'password': password,
        'channel_code': channelCode,
      },
      parser: (data) => AuthResponse.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<UserProfile> getMe() async {
    return _client.get(
      '/me',
      parser: (data) => UserProfile.fromJson(data as Map<String, dynamic>),
    );
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(apiClientProvider));
});
