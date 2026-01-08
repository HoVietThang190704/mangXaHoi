import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mangxahoi/Model/AuthResult.dart';
import 'package:mangxahoi/Utils.dart';
import 'BaseRepository.dart';

class AuthRepository extends BaseRepository {
  Future<AuthResult> register({
    required String email,
    required String password,
    String? userName,
    String? phone,
    DateTime? dateOfBirth,
    Map<String, dynamic>? address,
  }) async {
    final uri = Uri.parse('${Utils.baseUrl}/api/auth/register');
    final payload = <String, dynamic>{
      'email': email,
      'password': password,
      'userName': userName,
      'phone': phone,
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'address': address,
    };
    payload.removeWhere((_, value) => value == null);

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(payload),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return AuthResult.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    }

    super.codeErrorHandle(response.statusCode);
    _handleError(response);
  }

  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    final uri = Uri.parse('${Utils.baseUrl}/api/auth/login');
    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      return AuthResult.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    }

    super.codeErrorHandle(response.statusCode);
    _handleError(response);
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
