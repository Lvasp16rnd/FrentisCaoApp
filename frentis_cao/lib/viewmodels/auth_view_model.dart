import 'package:flutter/material.dart';
import 'package:frentis_cao/models/user_model.dart';
import 'package:frentis_cao/services/mock_auth_service.dart';

/// ViewModel de autenticação usando ChangeNotifier (Provider).
class AuthViewModel extends ChangeNotifier {
  final MockAuthService _authService = MockAuthService();

  // State
  bool _isLoading = false;
  String? _error;
  UserType? _selectedUserType;
  bool _termsAccepted = false;

  // Form fields
  String _name = '';
  String _email = '';
  String _password = '';
  String _phone = '';

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  UserType? get selectedUserType => _selectedUserType;
  bool get termsAccepted => _termsAccepted;
  String get phone => _phone;

  // Setters
  void setName(String value) => _name = value;
  void setEmail(String value) => _email = value;
  void setPassword(String value) => _password = value;
  void setPhone(String value) => _phone = value;

  void selectUserType(UserType type) {
    _selectedUserType = type;
    notifyListeners();
  }

  void toggleTermsAccepted() {
    _termsAccepted = !_termsAccepted;
    notifyListeners();
  }

  /// Login com email e senha
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _authService.login(email, password);
      if (!success) {
        _error = 'Email ou senha inválidos';
      }
      return success;
    } catch (e) {
      _error = 'Erro ao fazer login: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Login com Google
  Future<bool> loginWithGoogle() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _authService.loginWithGoogle();
      if (!success) _error = 'Falha no login com Google';
      return success;
    } catch (e) {
      _error = 'Erro: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Cadastro
  Future<bool> register() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _authService.register(
        name: _name,
        email: _email,
        password: _password,
        userType: _selectedUserType ?? UserType.donor,
      );
      if (!success) _error = 'Verifique os dados informados';
      return success;
    } catch (e) {
      _error = 'Erro no cadastro: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Verificação de código 2FA
  Future<bool> verifyCode(String code) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _authService.verifyCode(code);
      if (!success) _error = 'Código inválido';
      return success;
    } catch (e) {
      _error = 'Erro na verificação: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
