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

  // Getters
  List<PostModel> get posts => _posts;
  List<AnimalModel> get animals => _animals;
  List<CampaignModel> get campaigns => _campaigns;

  bool get isLoadingPosts => _isLoadingPosts;
  bool get isLoadingAnimals => _isLoadingAnimals;
  bool get isLoadingCampaigns => _isLoadingCampaigns;

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

  /// Método utilitário para carregar tudo de uma vez (ex: logo após login)
  Future<void> fetchAll() async {
    await Future.wait([
      fetchPosts(),
      fetchAnimals(),
      fetchCampaigns(),
    ]);
  }
}
