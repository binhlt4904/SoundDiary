import 'package:flutter/foundation.dart';
import '../domain/entities/song.dart';
import '../domain/enums/player_state.dart';

class PlayerViewModel extends ChangeNotifier {
  Song? _currentSong;
  PlayerState _playerState = PlayerState.stopped;
  Duration _position = Duration.zero;
  Duration _duration = const Duration(minutes: 3, seconds: 30);
  List<Song> _queue = [];
  int _currentIndex = -1;
  bool _isShuffle = false;
  RepeatMode _repeatMode = RepeatMode.none;

  // Getters
  Song? get currentSong => _currentSong;
  PlayerState get playerState => _playerState;
  Duration get position => _position;
  Duration get duration => _duration;
  bool get isPlaying => _playerState == PlayerState.playing;
  bool get isShuffle => _isShuffle;
  RepeatMode get repeatMode => _repeatMode;
  List<Song> get queue => _queue;
  double get progress =>
      _duration.inMilliseconds > 0
          ? _position.inMilliseconds / _duration.inMilliseconds
          : 0.0;

  void playSong(Song song, {List<Song>? queue}) {
    if (queue != null) {
      _queue = queue;
      _currentIndex = queue.indexWhere((s) => s.id == song.id);
    } else if (!_queue.contains(song)) {
      _queue = [song];
      _currentIndex = 0;
    } else {
      _currentIndex = _queue.indexWhere((s) => s.id == song.id);
    }

    _currentSong = song;
    _duration = song.duration;
    _position = Duration.zero;
    _playerState = PlayerState.playing;
    _startSimulatedPlayback();
    notifyListeners();
  }

  void togglePlayPause() {
    if (_currentSong == null) return;
    if (_playerState == PlayerState.playing) {
      _playerState = PlayerState.paused;
    } else {
      _playerState = PlayerState.playing;
      _startSimulatedPlayback();
    }
    notifyListeners();
  }

  void skipNext() {
    if (_queue.isEmpty) return;
    if (_isShuffle) {
      _currentIndex = (DateTime.now().millisecond % _queue.length);
    } else {
      _currentIndex = (_currentIndex + 1) % _queue.length;
    }
    playSong(_queue[_currentIndex], queue: _queue);
  }

  void skipPrevious() {
    if (_queue.isEmpty) return;
    if (_position.inSeconds > 3) {
      _position = Duration.zero;
      notifyListeners();
      return;
    }
    _currentIndex = (_currentIndex - 1 + _queue.length) % _queue.length;
    playSong(_queue[_currentIndex], queue: _queue);
  }

  void seekTo(double value) {
    _position = Duration(
      milliseconds: (value * _duration.inMilliseconds).round(),
    );
    notifyListeners();
  }

  void toggleShuffle() {
    _isShuffle = !_isShuffle;
    notifyListeners();
  }

  void toggleRepeat() {
    switch (_repeatMode) {
      case RepeatMode.none:
        _repeatMode = RepeatMode.all;
        break;
      case RepeatMode.all:
        _repeatMode = RepeatMode.one;
        break;
      case RepeatMode.one:
        _repeatMode = RepeatMode.none;
        break;
    }
    notifyListeners();
  }

  // Simulates progress (in real app, use just_audio)
  void _startSimulatedPlayback() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(milliseconds: 500));
      if (_playerState != PlayerState.playing) return false;
      _position += const Duration(milliseconds: 500);
      if (_position >= _duration) {
        _handleSongEnd();
        return false;
      }
      notifyListeners();
      return true;
    });
  }

  void _handleSongEnd() {
    switch (_repeatMode) {
      case RepeatMode.one:
        playSong(_currentSong!, queue: _queue);
        break;
      case RepeatMode.all:
        skipNext();
        break;
      case RepeatMode.none:
        if (_currentIndex < _queue.length - 1) {
          skipNext();
        } else {
          _playerState = PlayerState.stopped;
          _position = Duration.zero;
          notifyListeners();
        }
        break;
    }
  }

  String formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
