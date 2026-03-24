import 'package:flutter/foundation.dart';
import '../domain/entities/song.dart';
import '../data/implementations/mock_music_repository.dart';

class LibraryViewModel extends ChangeNotifier {
  final MockMusicRepository _repository;

  List<Song> _allSongs = [];
  List<Song> _filteredSongs = [];
  String _searchQuery = '';
  bool _isLoading = false;

  LibraryViewModel(this._repository) {
    loadSongs();
  }

  List<Song> get songs => _filteredSongs;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;

  void loadSongs() {
    _isLoading = true;
    notifyListeners();

    _allSongs = _repository.getAllSongs();
    _filteredSongs = List.from(_allSongs);
    _isLoading = false;
    notifyListeners();
  }

  void search(String query) {
    _searchQuery = query;
    if (query.isEmpty) {
      _filteredSongs = List.from(_allSongs);
    } else {
      _filteredSongs = _repository.searchSongs(query);
    }
    notifyListeners();
  }

  void toggleFavorite(String songId) {
    _repository.toggleFavorite(songId);
    _allSongs = _repository.getAllSongs();
    if (_searchQuery.isEmpty) {
      _filteredSongs = List.from(_allSongs);
    } else {
      _filteredSongs = _repository.searchSongs(_searchQuery);
    }
    notifyListeners();
  }
}
