enum UserType { donor, independentProtector, ong }

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
}
