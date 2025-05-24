class User {
  final String id;
  final String name;
  final String? keyId;
  final String? loginId; // New field for login ID

  User({
    required this.id,
    required this.name,
    this.keyId,
    this.loginId,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      keyId: json['key_id'] as String?,
      loginId: json['login_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'key_id': keyId,
      'login_id': loginId,
    };
  }
}