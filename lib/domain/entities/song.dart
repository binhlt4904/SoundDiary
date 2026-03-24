class Song {
  final String id;
  final String title;
  final String artist;
  final String albumArt; // URL or asset path
  final String audioUrl;
  final Duration duration;
  bool isFavorite;

  Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.albumArt,
    required this.audioUrl,
    this.duration = const Duration(minutes: 3, seconds: 30),
    this.isFavorite = false,
  });

  Song copyWith({
    String? id,
    String? title,
    String? artist,
    String? albumArt,
    String? audioUrl,
    Duration? duration,
    bool? isFavorite,
  }) {
    return Song(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      albumArt: albumArt ?? this.albumArt,
      audioUrl: audioUrl ?? this.audioUrl,
      duration: duration ?? this.duration,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  @override
  bool operator ==(Object other) => other is Song && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
