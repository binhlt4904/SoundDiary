import 'package:flutter/foundation.dart';
import '../domain/entities/song.dart';
import '../data/implementations/mock_music_repository.dart';
import 'history_viewmodel.dart';

class HomeViewModel extends ChangeNotifier {
  final MockMusicRepository _repository;
  final HistoryViewModel _historyViewModel;

  Song? _featuredSong;
  List<Song> _suggestedSongs = [];
  List<Song> _topSongs = [];

  HomeViewModel(this._repository, this._historyViewModel) {
    _load();
    _historyViewModel.addListener(_onHistoryChanged);
  }

  Song? get featuredSong => _featuredSong;
  List<Song> get suggestedSongs => _suggestedSongs;
  List<Song> get topSongs => _topSongs;
  List<Song> get continueListening => _historyViewModel.history.take(5).toList();

  void _load() {
    final all = _repository.getAllSongs();
    if (all.isEmpty) return;

    // Featured: pick the first favorited song or just first
    _featuredSong = all.firstWhere(
      (s) => s.isFavorite,
      orElse: () => all.first,
    );

    // Suggested: shuffle-ish (pick every other song)
    _suggestedSongs = all.where((s) => s.id != _featuredSong?.id).take(5).toList();

    // Top songs: reversed order to simulate "most played"
    _topSongs = List<Song>.from(all.reversed).take(6).toList();

    notifyListeners();
  }

  void _onHistoryChanged() {
    notifyListeners();
  }

  void refresh() => _load();

  @override
  void dispose() {
    _historyViewModel.removeListener(_onHistoryChanged);
    super.dispose();
  }
}
