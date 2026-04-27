import 'package:frentis_cao/models/user_model.dart';

/// Serviço mock para simular autenticação durante o desenvolvimento.
class MockAuthService {
  /// Simula login com email e senha.
  Future<bool> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    return email.isNotEmpty && password.length >= 6;
  }

  /// Simula login com Google.
  Future<bool> loginWithGoogle() async {
    await Future.delayed(const Duration(seconds: 1));
    return true;
  }

  /// Simula cadastro de novo usuário.
  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required UserType userType,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    return name.isNotEmpty && email.contains('@') && password.length >= 6;
  }

  /// Simula verificação de código 2FA.
  Future<bool> verifyCode(String code) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return code.length == 6;
  }
}
