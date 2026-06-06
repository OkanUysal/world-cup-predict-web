import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/api/api_providers.dart';
import '../core/storage/token_storage.dart';
import '../models/auth_response.dart';
import '../models/user_profile.dart';
import '../repositories/auth_repository.dart';

class AuthState {
  const AuthState({
    this.token,
    this.user,
    this.isLoading = false,
  });

  final String? token;
  final UserProfile? user;
  final bool isLoading;

  bool get isAuthenticated => token != null && token!.isNotEmpty;

  AuthState copyWith({
    String? token,
    UserProfile? user,
    bool? isLoading,
  }) {
    return AuthState(
      token: token ?? this.token,
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._ref) : super(const AuthState()) {
    _init();
    _ref.listen(unauthorizedTriggerProvider, (_, __) {
      state = const AuthState();
    });
  }

  final Ref _ref;

  Future<void> _init() async {
    state = state.copyWith(isLoading: true);
    try {
      final storage = await _ref.read(tokenStorageProvider.future);
      final token = await storage.getToken();
      if (token != null && token.isNotEmpty) {
        state = AuthState(token: token, isLoading: false);
        await refreshProfile();
      } else {
        state = const AuthState(isLoading: false);
      }
    } catch (_) {
      state = const AuthState(isLoading: false);
    }
  }

  /// Giriş/kayıt sonrası oturumu kaydet.
  Future<void> setSession(AuthResponse response) async {
    await _saveAuth(response);
  }

  Future<void> _saveAuth(AuthResponse response) async {
    final storage = await _ref.read(tokenStorageProvider.future);
    await storage.saveToken(response.accessToken);
    await storage.saveUserId(response.user.id);
    state = AuthState(token: response.accessToken, user: response.user);
  }

  Future<void> refreshProfile() async {
    if (!state.isAuthenticated) return;
    try {
      final repo = _ref.read(authRepositoryProvider);
      final profile = await repo.getMe();
      state = state.copyWith(user: profile);
    } catch (_) {
      // Profil yenileme hatası kritik değil.
    }
  }

  Future<void> logout() async {
    final storage = await _ref.read(tokenStorageProvider.future);
    await storage.clearAll();
    state = const AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(ref),
);
