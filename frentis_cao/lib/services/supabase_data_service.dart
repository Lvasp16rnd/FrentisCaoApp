import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:frentis_cao/models/content_models.dart';

class SupabaseDataService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Busca os posts para o feed da Home
  /// Faz um join com a tabela de profiles para obter os dados da ONG.
  Future<List<PostModel>> fetchPosts() async {
    try {
      final response = await _supabase
          .from('posts')
          .select('*, profiles:org_id(name, avatar_url)')
          .order('created_at', ascending: false);

      final List<dynamic> data = response;
      return data.map((json) => PostModel.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Erro ao buscar posts: $e');
      return [];
    }
  }

  /// Busca os animais para adoção
  Future<List<AnimalModel>> fetchAnimals() async {
    try {
      final response = await _supabase
          .from('animals')
          .select()
          .order('created_at', ascending: false);

      final List<dynamic> data = response;
      return data.map((json) => AnimalModel.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Erro ao buscar animais: $e');
      return [];
    }
  }

  /// Busca as campanhas ativas
  Future<List<CampaignModel>> fetchCampaigns() async {
    try {
      final response = await _supabase
          .from('campaigns')
          .select()
          .order('created_at', ascending: false);

      final List<dynamic> data = response;
      return data.map((json) => CampaignModel.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Erro ao buscar campanhas: $e');
      return [];
    }
  }

  /// Insere um novo animal para adoção
  Future<bool> insertAnimal({
    required String name,
    required String breed,
    required String age,
    required String gender,
    required String size,
    required String about,
    required bool vaccinated,
    required bool castrated,
    required List<File> imageFiles,
  }) async {
    try {
      // 1. Validar Autenticação (Exigência do RLS)
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('Usuário não autenticado. O RLS bloqueou a requisição.');
      }

      // 2. Upload das imagens
      List<String> uploadedUrls = [];
      for (int i = 0; i < imageFiles.length; i++) {
        final imageFile = imageFiles[i];
        final fileExt = imageFile.path.split('.').last.toLowerCase();
        final safeExtension = fileExt == imageFile.path ? 'png' : fileExt;
        final fileName = '${DateTime.now().millisecondsSinceEpoch}_$i.$safeExtension';
        
        final filePath = 'private/animalimg/${user.id}/$fileName';
        
        await _supabase.storage.from('frentiscao_images').upload(
              filePath,
              imageFile,
              fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
            );

        final imageUrl = _supabase.storage.from('frentiscao_images').getPublicUrl(filePath);
        uploadedUrls.add(imageUrl);
      }

      // 3. Inserir no banco
      final mainImageUrl = uploadedUrls.isNotEmpty ? uploadedUrls.first : '';
      await _supabase.from('animals').insert({
        'name': name,
        'breed': breed,
        'age': age,
        'gender': gender,
        'size': size,
        'about': about,
        'vaccinated': vaccinated,
        'castrated': castrated,
        'image_url': mainImageUrl,
        'photo_urls': uploadedUrls,
        'owner_id': user.id, // Adiciona explicitamente o owner_id
      });

      return true;
    } catch (e) {
      debugPrint('Erro ao inserir animal: $e');
      return false;
    }
  }

  /// Busca as adoções feitas pelo usuário logado (com os dados do animal)
  Future<List<AdoptionModel>> fetchMyAdoptions() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return [];

      final response = await _supabase
          .from('adoptions')
          .select('*, animals(*)')
          .eq('adopter_id', user.id)
          .order('created_at', ascending: false);

      final List<dynamic> data = response;
      return data.map((json) => AdoptionModel.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Erro ao buscar adoções: $e');
      return [];
    }
  }

  /// Registra o interesse de adoção de um animal
  Future<bool> applyForAdoption(String animalId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('Usuário não autenticado');

      await _supabase.from('adoptions').insert({
        'animal_id': animalId,
        'adopter_id': user.id,
        'status': 'Em Análise',
      });
      return true;
    } catch (e) {
      debugPrint('Erro ao registrar adoção: $e');
      return false;
    }
  }
}
