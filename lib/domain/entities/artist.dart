class Artist {
  final String id;
  String name;
  String? bio;
  String? avatarUrl;

  Artist({
    required this.id,
    required this.name,
    this.bio,
    this.avatarUrl,
  });

  Artist copyWith({
    String? id,
    String? name,
    String? bio,
    String? avatarUrl,
  }) {
    return Artist(
      id: id ?? this.id,
      name: name ?? this.name,
      bio: bio ?? this.bio,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}
