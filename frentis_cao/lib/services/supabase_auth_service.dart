import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:frentis_cao/models/user_model.dart';

class SupabaseAuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Retorna o usuário logado atualmente, ou nulo.
  User? get currentUser => _supabase.auth.currentUser;

  /// Login com email e senha.
  Future<bool> login(String email, String password) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response.session != null;
    } catch (e) {
      debugPrint('Erro no login: $e');
      return false;
    }
  }

  /// Login com Google (OAuth).
  Future<bool> loginWithGoogle() async {
    try {
      // Abre o fluxo de OAuth do Google. 
      // Requer configuração no Dashboard do Supabase e Google Cloud Console.
      final success = await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'frentiscao://login-callback/',
      );
      return success;
    } catch (e) {
      debugPrint('Erro no login com Google: $e');
      return false;
    }
  }

  /// Cadastro de novo usuário.
  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required UserType userType,
  }) async {
    // 1. Cria o usuário no Supabase Auth
    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
    );

    final user = response.user;
    
    if (user != null) {
      // 2. O usuário foi criado, mas a sessão ainda não existe (esperando OTP).
      // A inserção na tabela profiles será feita na etapa de verificação (completeProfile).
      return true;
    }
    return false;
  }

  /// Completa o perfil de um usuário que logou via OAuth (Google)
  Future<bool> completeProfile({
    required String name,
    required UserType userType,
    // (Podemos adicionar cpf e data de nascimento no mapa se a tabela suportar no futuro)
  }) async {
    final user = _supabase.auth.currentUser;
    if (user != null) {
      try {
        await _supabase.from('profiles').insert({
          'id': user.id,
          'name': name,
          'user_type': userType.nameString,
        });
        return true;
      } catch (e) {
        debugPrint('Erro ao completar perfil: $e');
        return false;
      }
    }
    return false;
  }

  /// Verifica se o perfil do usuário já existe na tabela 'profiles'
  Future<bool> checkProfileExists(String userId) async {
    try {
      final response = await _supabase
          .from('profiles')
          .select('id')
          .eq('id', userId)
          .maybeSingle();
      return response != null;
    } catch (e) {
      debugPrint('Erro ao verificar perfil: $e');
      return false; // Assume falso em caso de erro, forçando a completar o cadastro
    }
  }

  /// Verificação de código 2FA (se usar OTP por email no lugar de link)
  Future<bool> verifyCode(String email, String code) async {
    try {
      final response = await _supabase.auth.verifyOTP(
        email: email,
        token: code,
        type: OtpType.signup, // Tipo depende do fluxo, signup ou magiclink
      );
      return response.session != null;
    } catch (e) {
      debugPrint('Erro na verificação de código: $e');
      return false;
    }
  }

  /// Logout
  Future<void> logout() async {
    await _supabase.auth.signOut();
  }
}
