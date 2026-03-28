class Album {
  final String id;
  String title;
  String artistId;
  String? coverUrl;
  DateTime? releasedAt;

  Album({
    required this.id,
    required this.title,
    required this.artistId,
    this.coverUrl,
    this.releasedAt,
  });

  Album copyWith({
    String? id,
    String? title,
    String? artistId,
    String? coverUrl,
    DateTime? releasedAt,
  }) {
    return Album(
      id: id ?? this.id,
      title: title ?? this.title,
      artistId: artistId ?? this.artistId,
      coverUrl: coverUrl ?? this.coverUrl,
      releasedAt: releasedAt ?? this.releasedAt,
    );
  }
}
