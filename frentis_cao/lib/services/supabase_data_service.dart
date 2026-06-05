import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:frentis_cao/models/content_models.dart';

class SupabaseDataService {
  final SupabaseClient _supabase = Supabase.instance.client;

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
          .from('posts')
          .select('*, profiles:org_id(name, avatar_url)')
          .order('created_at', ascending: false);

      final List<dynamic> data = response;
      return data.map((json) {
        final postJson = Map<String, dynamic>.from(json as Map);
        postJson['image_url'] = _storagePublicUrl(postJson['image_url']);
        return PostModel.fromJson(postJson);
      }).toList();
    } catch (e) {
      debugPrint('Erro ao buscar posts: $e');
      return [];
    }
  }

  String _storagePublicUrl(dynamic value) {
    final raw = _firstImageValue(value);
    if (raw.isEmpty ||
        raw.startsWith('http://') ||
        raw.startsWith('https://')) {
      return raw;
    }

    return _supabase.storage
        .from('frentiscao_images')
        .getPublicUrl(raw.replaceFirst(RegExp(r'^/+'), ''));
  }

  String _firstImageValue(dynamic value) {
    if (value == null) return '';
    if (value is List) {
      return value.isEmpty ? '' : value.first.toString().trim();
    }

    final text = value.toString().trim();
    if (!text.startsWith('[')) return text;

    try {
      final decoded = jsonDecode(text);
      if (decoded is List && decoded.isNotEmpty) {
        return decoded.first.toString().trim();
      }
    } catch (_) {
      return text;
    }

    return text;
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
  }) async {
    final user = _requireAuthenticatedUser();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final extension = fileName.split('.').last.toLowerCase();
    final safeExtension = extension == fileName ? 'png' : extension;
    final path = 'private/post_img/${user.id}/$timestamp.$safeExtension';

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
    String imageUrl = '',
    String tag = '',
  }) async {
    try {
      final user = _requireAuthenticatedUser();

      await _supabase.from('posts').insert({
        'title': title,
        'description': description.isEmpty ? null : description,
        'full_description': fullDescription.isEmpty ? null : fullDescription,
        'image_url': imageUrl.isEmpty ? null : imageUrl,
        'tag': tag.isEmpty ? null : tag,
        'org_id': user.id,
      });

      return true;
    } catch (e) {
      debugPrint('Erro ao criar post: $e');
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
