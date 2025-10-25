// lib/models/user_model.dart
class UserModel {
  final int id;
  final String email;
  final String rank;
  final int experience;
  final bool hardMode;
  final String timezone;
  final String createdAt;

  UserModel({
    required this.id,
    required this.email,
    required this.rank,
    required this.experience,
    required this.hardMode,
    required this.timezone,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json["id"] as int,
      email: json["email"] as String,
      rank: (json["rank"] ?? "") as String,
      experience: (json["experience"] ?? 0) as int,
      hardMode: (json["hardMode"] ?? json["hard_mode"] ?? false) as bool,
      timezone: (json["timezone"] ?? "Europe/Warsaw") as String,
      createdAt: (json["createdAt"] ?? json["created_at"] ?? "") as String,
    );
  }
}

