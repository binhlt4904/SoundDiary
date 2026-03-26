import 'package:flutter/foundation.dart';
import '../domain/entities/song.dart';
import '../data/implementations/mock_music_repository.dart';

class SearchViewModel extends ChangeNotifier {
  final MockMusicRepository _repository;

  String _query = '';
  List<Song> _results = [];
  bool _hasSearched = false;

  SearchViewModel(this._repository);

  String get query => _query;
  List<Song> get results => _results;
  bool get hasSearched => _hasSearched;
  bool get isEmpty => _query.isEmpty;

  void search(String query) {
    _query = query;
    _hasSearched = query.isNotEmpty;
    if (query.trim().isEmpty) {
      _results = [];
    } else {
      _results = _repository.searchSongs(query.trim());
    }
    notifyListeners();
  }

  void clear() {
    _query = '';
    _results = [];
    _hasSearched = false;
    notifyListeners();
  }
}
