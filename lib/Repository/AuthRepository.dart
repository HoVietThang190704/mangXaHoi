import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mangxahoi/Model/AuthResult.dart';
import 'package:mangxahoi/Utils.dart';
import 'BaseRepository.dart';
import 'package:mangxahoi/services/api_service.dart';

class AuthRepository extends BaseRepository {
  Future<AuthResult> register({
    required String email,
    required String password,
    required String confirmPassword,
    String? userName,
    String? phone,
    DateTime? dateOfBirth,
    Map<String, dynamic>? address,
  }) async {
    final uri = Uri.parse('${Utils.baseUrl}/api/auth/register');
    final payload = <String, dynamic>{
      'email': email,
      'password': password,
      'confirmPassword': confirmPassword,
      'userName': userName,
      'phone': phone,
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'address': address,
    };
    payload.removeWhere((_, value) => value == null);

    // Use ApiService to perform the request (centralized HTTP client)
    final api = await ApiService.create();
    final data = await api.register(payload);

    return AuthResult.fromJson(data as Map<String, dynamic>);

  }

  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    // Use ApiService to perform the login
    final api = await ApiService.create();
    final data = await api.login(email, password);

    return AuthResult.fromJson(data as Map<String, dynamic>);

  }

  Never _handleError(http.Response response) {
    String message = 'Server error (${response.statusCode})';
    try {
      final dynamic decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic> && decoded['message'] != null) {
        message = decoded['message'].toString();
      }
    } catch (_) {
      // ignore JSON parse issues, fall back to default message
    }
    throw Exception(message);
  }
}
