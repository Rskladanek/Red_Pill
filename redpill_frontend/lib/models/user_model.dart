class UserModel {
  final int id;
  final String email;

  const UserModel({required this.id, required this.email});

  factory UserModel.fromMap(Map<dynamic, dynamic> m) {
    return UserModel(
      id: (m['id'] as num?)?.toInt() ?? -1,
      email: (m['email'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'email': email};
}

