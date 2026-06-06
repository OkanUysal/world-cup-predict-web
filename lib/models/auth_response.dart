import 'user_profile.dart';

class AuthResponse {
  const AuthResponse({
    required this.accessToken,
    required this.expiresAt,
    required this.user,
  });

  final String accessToken;
  final String expiresAt;
  final UserProfile user;

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['access_token'] as String,
      expiresAt: json['expires_at'] as String,
      user: UserProfile.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}
