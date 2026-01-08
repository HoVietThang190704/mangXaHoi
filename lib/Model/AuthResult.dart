import 'AuthUserModel.dart';

class AuthResult {
  final bool success;
  final String message;
  final AuthUserModel? user;
  final String? accessToken;
  final String? refreshToken;

  AuthResult({
    required this.success,
    required this.message,
    this.user,
    this.accessToken,
    this.refreshToken,
  });

  factory AuthResult.fromJson(Map<String, dynamic> json) {
    return AuthResult(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      user: json['user'] is Map<String, dynamic> ? AuthUserModel.fromJson(Map<String, dynamic>.from(json['user'] as Map)) : null,
      accessToken: json['accessToken']?.toString(),
      refreshToken: json['refreshToken']?.toString(),
    );
  }
}
