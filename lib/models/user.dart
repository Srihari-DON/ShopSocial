class User {
  final String id;
  final String name;
  final String email;
  final String avatarUrl;
  final String bio;
  
  // Add alias for profileImageUrl
  String get profileImageUrl => avatarUrl;
  
  User({
    required this.id,
    required this.name,
    required this.email,
    required this.avatarUrl,
    this.bio = '',
  });
  
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      avatarUrl: json['avatarUrl'] as String,
      bio: json['bio'] as String,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatarUrl': avatarUrl,
      'bio': bio,
    };
  }
}
