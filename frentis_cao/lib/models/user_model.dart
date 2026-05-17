enum UserType { donor, independentProtector, ong }

extension UserTypeExtension on UserType {
  String get nameString {
    switch (this) {
      case UserType.donor:
        return 'donor';
      case UserType.independentProtector:
        return 'independent_protector';
      case UserType.ong:
        return 'ong';
    }
  }

  static UserType fromString(String type) {
    switch (type) {
      case 'independent_protector':
        return UserType.independentProtector;
      case 'ong':
        return UserType.ong;
      case 'donor':
      default:
        return UserType.donor;
    }
  }
}

class UserModel {
  final String? id;
  final String name;
  final String email;
  final UserType userType;
  final String? phone;
  final String? photoUrl;

  const UserModel({
    this.id,
    required this.name,
    required this.email,
    required this.userType,
    this.phone,
    this.photoUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String?,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '', // Email doesn't usually come from profiles directly unless joined, but we keep it here for now.
      userType: UserTypeExtension.fromString(json['user_type'] as String? ?? 'donor'),
      phone: json['phone'] as String?,
      photoUrl: json['avatar_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      // 'email': email, // Not saved to profiles, managed by auth
      'user_type': userType.nameString,
      'phone': phone,
      'avatar_url': photoUrl,
    };
  }
}
