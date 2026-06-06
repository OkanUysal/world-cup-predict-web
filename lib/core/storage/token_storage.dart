import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _tokenKey = 'access_token';
const _userKeyPrefix = 'user_';

class TokenStorage {
  TokenStorage(this._prefs);

  final SharedPreferences _prefs;

  Future<String?> getToken() async => _prefs.getString(_tokenKey);

  Future<void> saveToken(String token) async {
    await _prefs.setString(_tokenKey, token);
  }

  Future<void> clearToken() async {
    await _prefs.remove(_tokenKey);
  }

  Future<void> saveUserId(String userId) async {
    await _prefs.setString('${_userKeyPrefix}id', userId);
  }

  Future<String?> getUserId() async => _prefs.getString('${_userKeyPrefix}id');

  Future<void> clearUser() async {
    await _prefs.remove('${_userKeyPrefix}id');
  }

  Future<void> clearAll() async {
    await clearToken();
    await clearUser();
  }
}

final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) async {
  return SharedPreferences.getInstance();
});

final tokenStorageProvider = FutureProvider<TokenStorage>((ref) async {
  final prefs = await ref.watch(sharedPreferencesProvider.future);
  return TokenStorage(prefs);
});
