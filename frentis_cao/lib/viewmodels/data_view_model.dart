import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:frentis_cao/models/content_models.dart';
import 'package:frentis_cao/models/user_model.dart';
import 'package:frentis_cao/services/supabase_data_service.dart';

class DataViewModel extends ChangeNotifier {
  final SupabaseDataService _dataService = SupabaseDataService();

  List<PostModel> _posts = [];
  List<AnimalModel> _animals = [];
  List<CampaignModel> _campaigns = [];
  List<UserModel> _ongSuggestions = [];
  final Set<String> _likedPostIds = {};
  final Set<String> _savedCampaignIds = {};
  final Map<String, int> _postLikeCounts = {};

  bool _isLoadingPosts = false;
  bool _isLoadingAnimals = false;
  bool _isLoadingCampaigns = false;
  bool _isLoadingOngSuggestions = false;
  bool _hasMoreOngSuggestions = true;
  bool _isCreatingPost = false;
  bool _isCreatingCampaign = false;
  String _ongSuggestionQuery = '';
  int _ongSuggestionPage = 0;
  int _ongSuggestionRequestId = 0;

  static const int ongSuggestionPageSize = 30;

  // Getters
  List<PostModel> get posts => _posts;
  List<AnimalModel> get animals => _animals;
  List<CampaignModel> get campaigns => _campaigns;
  List<UserModel> get ongSuggestions => _ongSuggestions;
  List<CampaignModel> get savedCampaigns =>
      _campaigns.where((campaign) => _savedCampaignIds.contains(campaign.id)).toList();

  bool get isLoadingPosts => _isLoadingPosts;
  bool get isLoadingAnimals => _isLoadingAnimals;
  bool get isLoadingCampaigns => _isLoadingCampaigns;
  bool get isLoadingOngSuggestions => _isLoadingOngSuggestions;
  bool get hasMoreOngSuggestions => _hasMoreOngSuggestions;
  bool get isCreatingPost => _isCreatingPost;
  bool get isCreatingCampaign => _isCreatingCampaign;

  bool isPostLiked(PostModel post) => _likedPostIds.contains(post.id);

  bool isCampaignSaved(CampaignModel campaign) => _savedCampaignIds.contains(campaign.id);

  int likeCountForPost(PostModel post) => _postLikeCounts[post.id] ?? post.likeCount;

  Future<void> fetchPosts() async {
    _isLoadingPosts = true;
    notifyListeners();

    _posts = await _dataService.fetchPosts();
    final currentUserId = _dataService.currentUserId;
    if (currentUserId != null) {
      for (var p in _posts) {
        if (p.likes.contains(currentUserId)) {
          _likedPostIds.add(p.id);
        }
        _postLikeCounts[p.id] = p.likeCount;
      }
    }

    _isLoadingPosts = false;
    notifyListeners();
  }

  Future<void> fetchAnimals() async {
    _isLoadingAnimals = true;
    notifyListeners();

    _animals = await _dataService.fetchAnimals();

    _isLoadingAnimals = false;
    notifyListeners();
  }

  Future<void> fetchCampaigns() async {
    _isLoadingCampaigns = true;
    notifyListeners();

    _campaigns = await _dataService.fetchCampaigns();
    final currentUserId = _dataService.currentUserId;
    if (currentUserId != null) {
      for (var c in _campaigns) {
        if (c.saves.contains(currentUserId)) {
          _savedCampaignIds.add(c.id);
        }
      }
    }

    _isLoadingCampaigns = false;
    notifyListeners();
  }

  Future<bool> isCurrentUserOng() {
    return _dataService.isCurrentUserOng();
  }

  Future<void> togglePostLike(PostModel post) async {
    if (_dataService.currentUserId == null) return;

    final isLiked = _likedPostIds.contains(post.id);
    final currentCount = _postLikeCounts[post.id] ?? post.likeCount;

    // Atualização Otimista
    if (isLiked) {
      _likedPostIds.remove(post.id);
      _postLikeCounts[post.id] = currentCount > 0 ? currentCount - 1 : 0;
    } else {
      _likedPostIds.add(post.id);
      _postLikeCounts[post.id] = currentCount + 1;
    }
    notifyListeners();

    // Sincroniza com banco
    final success = await _dataService.togglePostLike(post.id);
    if (!success) {
      // Reverte em caso de erro
      if (isLiked) {
        _likedPostIds.add(post.id);
        _postLikeCounts[post.id] = currentCount;
      } else {
        _likedPostIds.remove(post.id);
        _postLikeCounts[post.id] = currentCount;
      }
      notifyListeners();
    }
  }

  Future<void> toggleCampaignSaved(CampaignModel campaign) async {
    if (_dataService.currentUserId == null) return;

    final isSaved = _savedCampaignIds.contains(campaign.id);
    
    // Atualização otimista
    if (isSaved) {
      _savedCampaignIds.remove(campaign.id);
    } else {
      _savedCampaignIds.add(campaign.id);
    }
    notifyListeners();

    // Sincroniza com banco
    final success = await _dataService.toggleCampaignSave(campaign.id);
    if (!success) {
      // Reverte em caso de erro
      if (isSaved) {
        _savedCampaignIds.add(campaign.id);
      } else {
        _savedCampaignIds.remove(campaign.id);
      }
      notifyListeners();
    }
  }

  bool ownsPost(PostModel post) {
    final currentUserId = _dataService.currentUserId;
    return currentUserId != null &&
        post.orgId.isNotEmpty &&
        post.orgId == currentUserId;
  }

  void clearOngSuggestions() {
    _ongSuggestions = [];
    _ongSuggestionQuery = '';
    _ongSuggestionPage = 0;
    _ongSuggestionRequestId++;
    _hasMoreOngSuggestions = true;
    _isLoadingOngSuggestions = false;
    notifyListeners();
  }

  Future<void> searchOngSuggestions(String query, {bool reset = false}) async {
    final search = query.trim();
    if (search.isEmpty) {
      clearOngSuggestions();
      return;
    }

    if (reset || search != _ongSuggestionQuery) {
      _ongSuggestionQuery = search;
      _ongSuggestionPage = 0;
      _ongSuggestions = [];
      _hasMoreOngSuggestions = true;
    }

    if (_isLoadingOngSuggestions && !reset) return;
    if (!reset && !_hasMoreOngSuggestions) return;

    final requestId = ++_ongSuggestionRequestId;
    _isLoadingOngSuggestions = true;
    notifyListeners();

    try {
      final page = _ongSuggestionPage;
      final results = await _dataService.searchOngs(
        query: search,
        page: page,
        pageSize: ongSuggestionPageSize,
      );

      if (requestId != _ongSuggestionRequestId ||
          search != _ongSuggestionQuery) {
        return;
      }

      _ongSuggestions = [..._ongSuggestions, ...results];
      _hasMoreOngSuggestions = results.length == ongSuggestionPageSize;
      if (results.isNotEmpty) {
        _ongSuggestionPage = page + 1;
      }
    } finally {
      if (requestId == _ongSuggestionRequestId) {
        _isLoadingOngSuggestions = false;
        notifyListeners();
      }
    }
  }

  Future<bool> createPost({
    required String title,
    String description = '',
    String fullDescription = '',
    String tag = '',
    List<Uint8List> imageBytes = const [],
    List<String> imageFileNames = const [],
  }) async {
    _isCreatingPost = true;
    notifyListeners();

    try {
      final imageUrls = <String>[];
      for (var index = 0; index < imageBytes.length; index++) {
        imageUrls.add(
          await _dataService.uploadPostImage(
            bytes: imageBytes[index],
            fileName:
                index < imageFileNames.length
                    ? imageFileNames[index]
                    : 'post_$index.png',
            index: index,
          ),
        );
      }

      final created = await _dataService.createPost(
        title: title,
        description: description,
        fullDescription: fullDescription,
        imageUrls: imageUrls,
        tag: tag,
      );

      if (!created) return false;
      _posts = await _dataService.fetchPosts();
      return true;
    } catch (e) {
      debugPrint('Erro ao criar post no viewmodel: $e');
      return false;
    } finally {
      _isCreatingPost = false;
      notifyListeners();
    }
  }

  Future<bool> updatePost({
    required PostModel post,
    required String title,
    String description = '',
    String fullDescription = '',
    String tag = '',
    List<Uint8List> imageBytes = const [],
    List<String> imageFileNames = const [],
  }) async {
    _isCreatingPost = true;
    notifyListeners();

    try {
      var imageUrls = post.imageUrls;
      if (imageBytes.isNotEmpty) {
        imageUrls = [];
        for (var index = 0; index < imageBytes.length; index++) {
          imageUrls.add(
            await _dataService.uploadPostImage(
              bytes: imageBytes[index],
              fileName:
                  index < imageFileNames.length
                      ? imageFileNames[index]
                      : 'post_$index.png',
              index: index,
            ),
          );
        }
      }

      final updated = await _dataService.updatePost(
        id: post.id,
        title: title,
        description: description,
        fullDescription: fullDescription,
        imageUrls: imageUrls,
        tag: tag,
      );

      if (!updated) return false;
      _posts = await _dataService.fetchPosts();
      return true;
    } catch (e) {
      debugPrint('Erro ao atualizar post no viewmodel: $e');
      return false;
    } finally {
      _isCreatingPost = false;
      notifyListeners();
    }
  }

  Future<bool> deletePost(PostModel post) async {
    try {
      final deleted = await _dataService.deletePost(post.id);
      if (!deleted) return false;
      _posts = _posts.where((item) => item.id != post.id).toList();
      notifyListeners();
      _posts = await _dataService.fetchPosts();
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Erro ao deletar post no viewmodel: $e');
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
    List<Uint8List> imageBytes = const [],
    List<String> imageFileNames = const [],
  }) async {
    _isCreatingCampaign = true;
    notifyListeners();

    try {
      final imageUrls = <String>[];
      for (var index = 0; index < imageBytes.length; index++) {
        imageUrls.add(
          await _dataService.uploadCampaignImage(
            bytes: imageBytes[index],
            fileName:
                index < imageFileNames.length
                    ? imageFileNames[index]
                    : 'campaign_$index.png',
            index: index,
          ),
        );
      }

      final created = await _dataService.createCampaign(
        title: title,
        description: description,
        location: location,
        date: date,
        type: type,
        instructions: instructions,
        donationEnabled: donationEnabled,
        imageUrls: imageUrls,
      );

      if (!created) return false;
      _campaigns = await _dataService.fetchCampaigns();
      return true;
    } catch (e) {
      debugPrint('Erro ao criar campanha no viewmodel: $e');
      return false;
    } finally {
      _isCreatingCampaign = false;
      notifyListeners();
    }
  }

  /// Método utilitário para carregar tudo de uma vez (ex: logo após login)
  Future<void> fetchAll() async {
    await Future.wait([fetchPosts(), fetchAnimals(), fetchCampaigns()]);
  }
}
