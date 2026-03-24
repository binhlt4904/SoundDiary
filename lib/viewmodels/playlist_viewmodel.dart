import 'package:flutter/foundation.dart';
import '../domain/entities/playlist.dart';
import '../domain/entities/song.dart';
import '../data/implementations/mock_music_repository.dart';

class PlaylistViewModel extends ChangeNotifier {
  final MockMusicRepository _repository;

  List<Playlist> _playlists = [];

  PlaylistViewModel(this._repository) {
    loadPlaylists();
  }

  List<Playlist> get playlists => _playlists;

  void loadPlaylists() {
    _playlists = _repository.getPlaylists();
    notifyListeners();
  }

  Playlist createPlaylist(String name) {
    final playlist = _repository.addPlaylist(name);
    loadPlaylists();
    return playlist;
  }

  void deletePlaylist(String id) {
    _repository.deletePlaylist(id);
    loadPlaylists();
  }

  void addSongToPlaylist(String playlistId, Song song) {
    _repository.addSongToPlaylist(playlistId, song);
    loadPlaylists();
  }
}
