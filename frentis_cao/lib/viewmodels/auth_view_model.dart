import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:frentis_cao/models/user_model.dart';
import 'package:frentis_cao/services/supabase_auth_service.dart';

class AuthViewModel extends ChangeNotifier {
  final SupabaseAuthService _authService = SupabaseAuthService();

  bool _isLoading = false;
  String? _error;
  UserType? _selectedUserType;
  bool _termsAccepted = false;

  String _name = '';
  String _email = '';
  String _password = '';
  String _phone = '';

  bool get isLoading => _isLoading;
  String? get error => _error;
  UserType? get selectedUserType => _selectedUserType;
  bool get termsAccepted => _termsAccepted;
  String get phone => _phone;

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

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _authService.login(email, password);
      if (!success) {
        _error = 'Email ou senha invalidos';
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

  Future<bool> register() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      bool success = false;
      final currentUser = Supabase.instance.client.auth.currentUser;

      if (currentUser != null) {
        success = await _authService.completeProfile(
          name: _name,
          userType: _selectedUserType ?? UserType.donor,
        );
      } else {
        success = await _authService.register(
          name: _name,
          email: _email,
          password: _password,
          userType: _selectedUserType ?? UserType.donor,
        );
      }

      if (!success) {
        _error = 'Falha ao salvar o perfil. Tente novamente.';
      }
      return success;
    } catch (e) {
      if (e.toString().contains('42501')) {
        _error = 'Erro de permissao no banco (RLS). Contate o suporte.';
      } else if (e.toString().contains('already registered') ||
          e.toString().contains('User already exists')) {
        _error = 'Este e-mail ja esta em uso. Faca login.';
      } else {
        _error = 'Erro no cadastro. Verifique os dados.';
        debugPrint('Detalhe do erro: $e');
      }
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> checkProfileExists(String userId) async {
    return await _authService.checkProfileExists(userId);
  }

  Future<bool> verifyCode(String code) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _authService.verifyCode(_email, code);
      if (!success) {
        _error = 'Codigo invalido';
      } else {
        await _authService.completeProfile(
          name: _name,
          userType: _selectedUserType ?? UserType.donor,
        );
      }
      return success;
    } catch (e) {
      _error = 'Erro na verificacao: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
