class UserModel {
  final String id;
  final String email;
  final String? name;
  final String? username;
  final String? avatarUrl;

  const UserModel({
    required this.id,
    required this.email,
    this.name,
    this.username,
    this.avatarUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String?,
      username: json['username'] as String?,
      avatarUrl: json['avatar_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'username': username,
      'avatar_url': avatarUrl,
    };
  }
}