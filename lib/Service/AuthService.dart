import 'package:mangxahoi/Model/AuthResult.dart';
import 'package:mangxahoi/Repository/AuthRepository.dart';

class AuthService {
  AuthService({AuthRepository? repository}) : _repository = repository ?? AuthRepository();

  final AuthRepository _repository;

  Future<AuthResult> register({
    required String email,
    required String password,
    String? userName,
    String? phone,
    DateTime? dateOfBirth,
    Map<String, dynamic>? address,
  }) {
    return _repository.register(
      email: email,
      password: password,
      userName: userName,
      phone: phone,
      dateOfBirth: dateOfBirth,
      address: address,
    );
  }

  Future<AuthResult> login({
    required String email,
    required String password,
  }) {
    return _repository.login(email: email, password: password);
  }
}
