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
}
