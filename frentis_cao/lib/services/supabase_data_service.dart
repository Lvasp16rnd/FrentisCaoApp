import 'dart:convert';

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:frentis_cao/models/content_models.dart';
import 'package:frentis_cao/models/user_model.dart';

class SupabaseDataService {
  static const String _postsTable = 'posts';

  final SupabaseClient _supabase = Supabase.instance.client;

  String? get currentUserId =>
      (_supabase.auth.currentSession?.user ?? _supabase.auth.currentUser)?.id;

  User _requireAuthenticatedUser() {
    final user =
        _supabase.auth.currentSession?.user ?? _supabase.auth.currentUser;
    if (user == null) {
      throw StateError('Usuário autenticado obrigatório para criar campanha.');
    }
    return user;
  }

  /// Busca os posts para o feed da Home
  /// Faz um join com a tabela de profiles para obter os dados da ONG.
  Future<List<PostModel>> fetchPosts() async {
    try {
      final response = await _supabase
          .from(_postsTable)
          .select('*, profiles:org_id(name, avatar_url)')
          .eq('ativo', true)
          .order('created_at', ascending: false);

      final List<dynamic> data = response;
      return data
          .map((json) {
            final postJson = Map<String, dynamic>.from(json as Map);
            postJson['image_url'] = _storagePublicUrls(postJson['image_url']);
            return PostModel.fromJson(postJson);
          })
          .where((post) => post.ativo)
          .toList();
    } catch (e) {
      debugPrint('Erro ao buscar posts ativos em $_postsTable.ativo: $e');
      return [];
    }
  }

  List<String> _storagePublicUrls(dynamic value) {
    return _imageValues(value).map(_storagePublicUrl).toList();
  }

  String _storagePublicUrl(String raw) {
    if (raw.isEmpty ||
        raw.startsWith('http://') ||
        raw.startsWith('https://')) {
      return raw;
    }

    return _supabase.storage
        .from('frentiscao_images')
        .getPublicUrl(raw.replaceFirst(RegExp(r'^/+'), ''));
  }

  List<String> _imageValues(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value
          .map((item) => item.toString().trim())
          .where((item) => item.isNotEmpty)
          .toList();
    }

    final text = value.toString().trim();
    if (text.isEmpty) return [];
    if (!text.startsWith('[')) return [text];

    try {
      final decoded = jsonDecode(text);
      if (decoded is List) {
        return decoded
            .map((item) => item.toString().trim())
            .where((item) => item.isNotEmpty)
            .toList();
      }
    } catch (_) {
      return [text];
    }

    return [text];
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

  Future<bool> isCurrentUserOng() async {
    try {
      final user =
          _supabase.auth.currentSession?.user ?? _supabase.auth.currentUser;
      if (user == null) return false;

      final response =
          await _supabase
              .from('profiles')
              .select('user_type')
              .eq('id', user.id)
              .maybeSingle();

      return response?['user_type'] == 'ong';
    } catch (e) {
      debugPrint('Erro ao verificar perfil ONG: $e');
      return false;
    }
  }

  Future<List<UserModel>> searchOngs({
    required String query,
    required int page,
    int pageSize = 30,
  }) async {
    final search = query.trim();
    if (search.isEmpty) return [];

    try {
      final from = page * pageSize;
      final to = from + pageSize - 1;
      final response = await _supabase
          .from('profiles')
          .select('id, name, user_type, phone, avatar_url')
          .eq('user_type', 'ong')
          .ilike('name', '%$search%')
          .order('name', ascending: true)
          .range(from, to);

      final List<dynamic> data = response;
      return data.map((json) => UserModel.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Erro ao buscar ONGs: $e');
      return [];
    }
  }

  Future<String> uploadCampaignImage({
    required Uint8List bytes,
    required String fileName,
    required int index,
  }) async {
    final user = _requireAuthenticatedUser();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final extension = fileName.split('.').last.toLowerCase();
    final safeExtension = extension == fileName ? 'png' : extension;
    final path =
        'private/campaign_img/${user.id}/${timestamp}_$index.$safeExtension';

    await _supabase.storage
        .from('frentiscao_images')
        .uploadBinary(
          path,
          bytes,
          fileOptions: const FileOptions(upsert: true),
        );

    return _supabase.storage.from('frentiscao_images').getPublicUrl(path);
  }

  Future<String> uploadPostImage({
    required Uint8List bytes,
    required String fileName,
    required int index,
  }) async {
    final user = _requireAuthenticatedUser();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final extension = fileName.split('.').last.toLowerCase();
    final safeExtension = extension == fileName ? 'png' : extension;
    final path =
        'private/post_img/${user.id}/${timestamp}_$index.$safeExtension';

    await _supabase.storage
        .from('frentiscao_images')
        .uploadBinary(
          path,
          bytes,
          fileOptions: const FileOptions(upsert: true),
        );

    return _supabase.storage.from('frentiscao_images').getPublicUrl(path);
  }

  Future<bool> createPost({
    required String title,
    String description = '',
    String fullDescription = '',
    List<String> imageUrls = const [],
    String tag = '',
  }) async {
    try {
      final user = _requireAuthenticatedUser();

      await _supabase.from(_postsTable).insert({
        'title': title,
        'description': description.isEmpty ? null : description,
        'full_description': fullDescription.isEmpty ? null : fullDescription,
        'image_url': imageUrls.isEmpty ? null : jsonEncode(imageUrls),
        'tag': tag.isEmpty ? null : tag,
        'org_id': user.id,
        'ativo': true,
      });

      return true;
    } catch (e) {
      debugPrint('Erro ao criar post: $e');
      return false;
    }
  }

  Future<bool> updatePost({
    required String id,
    required String title,
    String description = '',
    String fullDescription = '',
    List<String> imageUrls = const [],
  }) async {
    try {
      final user = _requireAuthenticatedUser();

      await _supabase
          .from(_postsTable)
          .update({
            'title': title,
            'description': description.isEmpty ? null : description,
            'full_description':
                fullDescription.isEmpty ? null : fullDescription,
            'image_url': imageUrls.isEmpty ? null : jsonEncode(imageUrls),
          })
          .eq('id', id)
          .eq('org_id', user.id);

      return true;
    } catch (e) {
      debugPrint('Erro ao atualizar post: $e');
      return false;
    }
  }

  Future<bool> deletePost(String id) async {
    try {
      final user = _requireAuthenticatedUser();

      await _supabase
          .from(_postsTable)
          .update({'ativo': false})
          .eq('id', id)
          .eq('org_id', user.id);

      return true;
    } catch (e) {
      debugPrint('Erro ao marcar post como inativo em $_postsTable.ativo: $e');
      return false;
    }
  }

  Future<bool> createCampaign({
    required String title,
    required String description,
    required String location,
    required String date,
    required String type,
    required String instructions,
    required bool donationEnabled,
    List<String> imageUrls = const [],
  }) async {
    try {
      final user = _requireAuthenticatedUser();

      await _supabase.from('campaigns').insert({
        'title': title,
        'description': description,
        'location': location,
        'date': date.isEmpty ? null : date,
        'image_url': imageUrls.isEmpty ? null : imageUrls,
        'type': type,
        'instructions': CampaignModel.encodeInstructionsMetadata(
          instructions,
          donationEnabled,
        ),
        'creator_id': user.id,
      });

      return true;
    } catch (e) {
      debugPrint('Erro ao criar campanha: $e');
      return false;
    }
  }
}
