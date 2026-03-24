import 'song.dart';

class Playlist {
  final String id;
  String name;
  String? coverArt;
  List<Song> songs;

  Playlist({
    required this.id,
    required this.name,
    this.coverArt,
    List<Song>? songs,
  }) : songs = songs ?? [];

  int get songCount => songs.length;

  Playlist copyWith({
    String? id,
    String? name,
    String? coverArt,
    List<Song>? songs,
  }) {
    return Playlist(
      id: id ?? this.id,
      name: name ?? this.name,
      coverArt: coverArt ?? this.coverArt,
      songs: songs ?? List.from(this.songs),
    );
  }
}
