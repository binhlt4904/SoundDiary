class Song {
  final String id;
  String title;
  String artist;
  String albumArt;
  String audioUrl;
  Duration duration;
  bool isFavorite;
  String? artistId;
  String? albumId;

  Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.albumArt,
    required this.audioUrl,
    this.duration = const Duration(minutes: 3, seconds: 30),
    this.isFavorite = false,
    this.artistId,
    this.albumId,
  });

  Song copyWith({
    String? id, String? title, String? artist, String? albumArt,
    String? audioUrl, Duration? duration, bool? isFavorite,
    String? artistId, String? albumId,
  }) {
    return Song(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      albumArt: albumArt ?? this.albumArt,
      audioUrl: audioUrl ?? this.audioUrl,
      duration: duration ?? this.duration,
      isFavorite: isFavorite ?? this.isFavorite,
      artistId: artistId ?? this.artistId,
      albumId: albumId ?? this.albumId,
    );
  }

  @override
  bool operator ==(Object other) => other is Song && other.id == id;
  @override
  int get hashCode => id.hashCode;
}
