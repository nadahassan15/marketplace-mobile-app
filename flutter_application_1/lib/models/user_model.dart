enum UserRole {
  admin,
  brand,
  user,
  guest, // For users not logged in
}

class UserModel {
  final String id;
  final String email;
  final UserRole role;

  UserModel({
    required this.id,
    required this.email,
    required this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      role: UserRole.values.firstWhere(
        (e) => e.toString().split('.').last == json['role'],
        orElse: () => UserRole.guest,
      ),
    );
  }
}