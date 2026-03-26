import 'package:flutter/foundation.dart';
import '../domain/entities/song.dart';

class HistoryViewModel extends ChangeNotifier {
  final List<Song> _history = [];

  List<Song> get history => List.unmodifiable(_history);

  void addToHistory(Song song) {
    _history.removeWhere((s) => s.id == song.id);
    _history.insert(0, song);
    if (_history.length > 20) _history.removeLast();
    notifyListeners();
  }

  void clearHistory() {
    _history.clear();
    notifyListeners();
  }
}
