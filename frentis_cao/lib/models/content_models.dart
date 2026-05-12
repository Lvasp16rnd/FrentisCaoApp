class PostModel {
  final String id;
  final String orgName;
  final String orgAvatarUrl;
  final String imageUrl;
  final String title;
  final String description;
  final String tag;
  final String fullDescription;

  const PostModel({
    required this.id,
    required this.orgName,
    required this.orgAvatarUrl,
    required this.imageUrl,
    required this.title,
    required this.description,
    this.tag = 'Doar',
    this.fullDescription = '',
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    // Para relacionamentos, o Supabase pode retornar um mapa em 'profiles' dependendo da query
    final orgData = json['profiles'] as Map<String, dynamic>?;

    return PostModel(
      id: json['id'] as String? ?? '',
      orgName: orgData?['name'] as String? ?? 'ONG',
      orgAvatarUrl: orgData?['avatar_url'] as String? ?? '',
      imageUrl: json['image_url'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      tag: json['tag'] as String? ?? 'Doar',
      fullDescription: json['full_description'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'image_url': imageUrl,
      'title': title,
      'description': description,
      'tag': tag,
      'full_description': fullDescription,
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
      photoUrls: json['photo_urls'] != null ? List<String>.from(json['photo_urls']) : [],
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
  final String id;
  final String title;
  final String location;
  final String date;
  final String imageUrl;
  final String type;
  final String description;
  final String instructions;

  const CampaignModel({
    required this.id,
    required this.title,
    required this.location,
    required this.date,
    required this.imageUrl,
    required this.type,
    this.description = '',
    this.instructions = '',
  });

  factory CampaignModel.fromJson(Map<String, dynamic> json) {
    return CampaignModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      location: json['location'] as String? ?? '',
      date: json['date'] as String? ?? '',
      imageUrl: json['image_url'] as String? ?? '',
      type: json['type'] as String? ?? '',
      description: json['description'] as String? ?? '',
      instructions: json['instructions'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'location': location,
      'date': date,
      'image_url': imageUrl,
      'type': type,
      'description': description,
      'instructions': instructions,
    };
  }
}
