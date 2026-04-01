import 'dart:convert';

class User {
  final String id;
  final String displayName;
  final String email;
  final String? bio;

  const User({
    required this.id,
    required this.displayName,
    required this.email,
    this.bio,
  });

  User copyWith({String? displayName, String? bio}) => User(
        id: id,
        displayName: displayName ?? this.displayName,
        email: email,
        bio: bio ?? this.bio,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'displayName': displayName,
        'email': email,
        'bio': bio,
      };

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'] as String,
        displayName: json['displayName'] as String,
        email: json['email'] as String,
        bio: json['bio'] as String?,
      );

  static User? tryDecode(String? raw) {
    if (raw == null) return null;
    try {
      return User.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }
}
