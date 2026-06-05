import 'dart:convert';

class PostModel {
  final String id;
  final String orgId;
  final String orgName;
  final String orgAvatarUrl;
  final String imageUrl;
  final List<String> imageUrls;
  final String title;
  final String description;
  final String tag;
  final String fullDescription;
  final bool ativo;
  final List<String> likes;
  final int likeCount;

  const PostModel({
    required this.id,
    required this.orgId,
    required this.orgName,
    required this.orgAvatarUrl,
    required this.imageUrl,
    this.imageUrls = const [],
    required this.title,
    required this.description,
    this.tag = 'Doar',
    this.fullDescription = '',
    this.ativo = true,
    this.likes = const [],
    this.likeCount = 0,
  });

  bool isLikedBy(String? userId) {
    if (userId == null || userId.isEmpty) return false;
    return likes.contains(userId);
  }

  factory PostModel.fromJson(Map<String, dynamic> json) {
    // Para relacionamentos, o Supabase pode retornar um mapa em 'profiles' dependendo da query
    final orgData = json['profiles'] as Map<String, dynamic>?;
    final imageUrls = _parseStringList(json['image_url']);
    final likes = _parseStringList(json['likes_id']);

    return PostModel(
      id: json['id'] as String? ?? '',
      orgId: json['org_id'] as String? ?? '',
      orgName: _nonEmptyString(orgData?['name'], 'ONG'),
      orgAvatarUrl: orgData?['avatar_url'] as String? ?? '',
      imageUrl: imageUrls.isEmpty ? '' : imageUrls.first,
      imageUrls: imageUrls,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      tag: json['tag'] as String? ?? 'Doar',
      fullDescription: json['full_description'] as String? ?? '',
      ativo: json['ativo'] as bool? ?? false,
      likes: likes,
      likeCount: _parseInt(json['like_count'], fallback: likes.length),
    );
  }

  PostModel copyWith({
    String? id,
    String? orgId,
    String? orgName,
    String? orgAvatarUrl,
    String? imageUrl,
    List<String>? imageUrls,
    String? title,
    String? description,
    String? tag,
    String? fullDescription,
    bool? ativo,
    List<String>? likes,
    int? likeCount,
  }) {
    return PostModel(
      id: id ?? this.id,
      orgId: orgId ?? this.orgId,
      orgName: orgName ?? this.orgName,
      orgAvatarUrl: orgAvatarUrl ?? this.orgAvatarUrl,
      imageUrl: imageUrl ?? this.imageUrl,
      imageUrls: imageUrls ?? this.imageUrls,
      title: title ?? this.title,
      description: description ?? this.description,
      tag: tag ?? this.tag,
      fullDescription: fullDescription ?? this.fullDescription,
      ativo: ativo ?? this.ativo,
      likes: likes ?? this.likes,
      likeCount: likeCount ?? this.likeCount,
    );
  }

  static String _nonEmptyString(dynamic value, String fallback) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? fallback : text;
  }

  static List<String> _parseStringList(dynamic value) {
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

  static int _parseInt(dynamic value, {int fallback = 0}) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'org_id': orgId,
      'image_url': imageUrls.isNotEmpty ? imageUrls : imageUrl,
      'title': title,
      'description': description,
      'tag': tag,
      'full_description': fullDescription,
      'ativo': ativo,
      'likes_id': likes,
      'like_count': likeCount,
      // org_id deveria ser mapeado na hora de inserir no banco, não incluímos orgName aqui
    };
  }
}

class AnimalModel {
  final String id;
  final String name;
  final String breed;
  final String age;
  final String imageUrl;
  final String gender;
  final String size;
  final String about;
  final bool vaccinated;
  final bool castrated;
  final List<String> photoUrls;

  const AnimalModel({
    required this.id,
    required this.name,
    required this.breed,
    required this.age,
    required this.imageUrl,
    required this.gender,
    this.size = 'Médio',
    this.about = '',
    this.vaccinated = false,
    this.castrated = false,
    this.photoUrls = const [],
  });

  factory AnimalModel.fromJson(Map<String, dynamic> json) {
    return AnimalModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      breed: json['breed'] as String? ?? '',
      age: json['age'] as String? ?? '',
      imageUrl: json['image_url'] as String? ?? '',
      gender: json['gender'] as String? ?? '',
      size: json['size'] as String? ?? 'Médio',
      about: json['about'] as String? ?? '',
      vaccinated: json['vaccinated'] as bool? ?? false,
      castrated: json['castrated'] as bool? ?? false,
      photoUrls:
          json['photo_urls'] != null
              ? List<String>.from(json['photo_urls'])
              : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'breed': breed,
      'age': age,
      'image_url': imageUrl,
      'gender': gender,
      'size': size,
      'about': about,
      'vaccinated': vaccinated,
      'castrated': castrated,
      // photo_urls não está no schema básico ainda, mas podemos manter no toJson
    };
  }
}

class CampaignModel {
  static final RegExp _donationMetadataPattern = RegExp(
    r'^\[donation_enabled=(true|false)\]\r?\n?',
  );

  final String id;
  final String title;
  final String location;
  final String date;
  final String imageUrl;
  final List<String> imageUrls;
  final String type;
  final String description;
  final String instructions;
  final bool donationEnabled;

  const CampaignModel({
    required this.id,
    required this.title,
    required this.location,
    required this.date,
    required this.imageUrl,
    required this.type,
    this.imageUrls = const [],
    this.description = '',
    this.instructions = '',
    this.donationEnabled = true,
  });

  factory CampaignModel.fromJson(Map<String, dynamic> json) {
    final imageUrls = _parseImageUrls(json['image_url']);
    final rawInstructions = json['instructions'] as String? ?? '';

    return CampaignModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      location: json['location'] as String? ?? '',
      date: json['date'] as String? ?? '',
      imageUrl: imageUrls.isEmpty ? '' : imageUrls.first,
      imageUrls: imageUrls,
      type: json['type'] as String? ?? '',
      description: json['description'] as String? ?? '',
      instructions: _stripDonationMetadata(rawInstructions),
      donationEnabled: _parseDonationEnabled(rawInstructions),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'location': location,
      'date': date,
      'image_url': imageUrls.isNotEmpty ? imageUrls : imageUrl,
      'type': type,
      'description': description,
      'instructions': encodeInstructionsMetadata(instructions, donationEnabled),
    };
  }

  static String encodeInstructionsMetadata(
    String instructions,
    bool donationEnabled,
  ) {
    final cleanInstructions = _stripDonationMetadata(instructions);
    if (donationEnabled) return cleanInstructions;
    return '[donation_enabled=false]\n$cleanInstructions';
  }

  static bool _parseDonationEnabled(String instructions) {
    final match = _donationMetadataPattern.firstMatch(instructions);
    if (match == null) return true;
    return match.group(1) == 'true';
  }

  static String _stripDonationMetadata(String instructions) {
    return instructions.replaceFirst(_donationMetadataPattern, '');
  }

  static List<String> _parseImageUrls(dynamic value) {
    if (value == null) return [];
    if (value is List) return value.map((item) => item.toString()).toList();
    if (value is! String || value.isEmpty) return [];

    final trimmed = value.trim();
    if (trimmed.startsWith('[')) {
      try {
        final decoded = jsonDecode(trimmed);
        if (decoded is List) {
          return decoded.map((item) => item.toString()).toList();
        }
      } catch (_) {
        return [value];
      }
    }

    return [value];
  }
}

class AdoptionModel {
  final String id;
  final String animalId;
  final String status;
  final AnimalModel? animal;

  const AdoptionModel({
    required this.id,
    required this.animalId,
    required this.status,
    this.animal,
  });

  factory AdoptionModel.fromJson(Map<String, dynamic> json) {
    return AdoptionModel(
      id: json['id'] as String? ?? '',
      animalId: json['animal_id'] as String? ?? '',
      status: json['status'] as String? ?? 'Em Análise',
      animal:
          json['animals'] != null
              ? AnimalModel.fromJson(json['animals'])
              : null,
    );
  }
}
