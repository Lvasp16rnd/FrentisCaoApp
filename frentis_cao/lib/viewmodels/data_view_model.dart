import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:frentis_cao/models/content_models.dart';
import 'package:frentis_cao/services/supabase_data_service.dart';

class DataViewModel extends ChangeNotifier {
  final SupabaseDataService _dataService = SupabaseDataService();

  List<PostModel> _posts = [];
  List<AnimalModel> _animals = [];
  List<CampaignModel> _campaigns = [];

  bool _isLoadingPosts = false;
  bool _isLoadingAnimals = false;
  bool _isLoadingCampaigns = false;
  bool _isCreatingPost = false;
  bool _isCreatingCampaign = false;

  // Getters
  List<PostModel> get posts => _posts;
  List<AnimalModel> get animals => _animals;
  List<CampaignModel> get campaigns => _campaigns;

  bool get isLoadingPosts => _isLoadingPosts;
  bool get isLoadingAnimals => _isLoadingAnimals;
  bool get isLoadingCampaigns => _isLoadingCampaigns;
  bool get isCreatingPost => _isCreatingPost;
  bool get isCreatingCampaign => _isCreatingCampaign;

  Future<void> fetchPosts() async {
    _isLoadingPosts = true;
    notifyListeners();

    _posts = await _dataService.fetchPosts();

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

    _isLoadingCampaigns = false;
    notifyListeners();
  }

  Future<bool> isCurrentUserOng() {
    return _dataService.isCurrentUserOng();
  }

  Future<bool> createPost({
    required String title,
    String description = '',
    String fullDescription = '',
    String tag = '',
    Uint8List? imageBytes,
    String? imageFileName,
  }) async {
    _isCreatingPost = true;
    notifyListeners();

    try {
      var imageUrl = '';
      if (imageBytes != null) {
        imageUrl = await _dataService.uploadPostImage(
          bytes: imageBytes,
          fileName: imageFileName ?? 'post.png',
        );
      }

      final created = await _dataService.createPost(
        title: title,
        description: description,
        fullDescription: fullDescription,
        imageUrl: imageUrl,
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
