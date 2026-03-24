import 'package:flutter/foundation.dart';
import '../domain/entities/song.dart';
import '../data/implementations/mock_music_repository.dart';

class FavoritesViewModel extends ChangeNotifier {
  final MockMusicRepository _repository;

  List<Song> _favorites = [];

  FavoritesViewModel(this._repository) {
    loadFavorites();
  }

  List<Song> get favorites => _favorites;

  void loadFavorites() {
    _favorites = _repository.getFavoriteSongs();
    notifyListeners();
  }

  void toggleFavorite(String songId) {
    _repository.toggleFavorite(songId);
    loadFavorites();
  }
}
