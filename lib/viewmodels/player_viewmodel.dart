import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart' as ja;
import '../domain/entities/song.dart';
import '../domain/enums/player_state.dart';

class PlayerViewModel extends ChangeNotifier {
  final _player = ja.AudioPlayer();

  Song? _currentSong;
  PlayerState _playerState = PlayerState.stopped;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  List<Song> _queue = [];
  int _currentIndex = -1;
  bool _isShuffle = false;
  RepeatMode _repeatMode = RepeatMode.none;

  late final StreamSubscription<ja.PlayerState> _playerStateSub;
  late final StreamSubscription<Duration> _positionSub;
  late final StreamSubscription<Duration?> _durationSub;

  PlayerViewModel() {
    _playerStateSub = _player.playerStateStream.listen(_onPlayerState);
    _positionSub = _player.positionStream.listen(_onPosition);
    _durationSub = _player.durationStream.listen(_onDuration);
  }

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

  void _onPlayerState(ja.PlayerState state) {
    if (state.processingState == ja.ProcessingState.completed) {
      _handleSongEnd();
      return;
    }

    if (state.processingState == ja.ProcessingState.idle) return;

    if (state.playing) {
      _playerState = PlayerState.playing;
    } else if (state.processingState == ja.ProcessingState.loading ||
        state.processingState == ja.ProcessingState.buffering) {
      _playerState = PlayerState.loading;
    } else if (_currentSong != null) {
      _playerState = PlayerState.paused;
    }
    notifyListeners();
  }

  void _onPosition(Duration pos) {
    _position = pos;
    notifyListeners();
  }

  void _onDuration(Duration? dur) {
    if (dur != null) {
      _duration = dur;
      notifyListeners();
    }
  }

  Future<void> playSong(Song song, {List<Song>? queue}) async {
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
    _position = Duration.zero;
    _duration = Duration.zero;
    _playerState = PlayerState.loading;
    notifyListeners();

    try {
      await _player.setUrl(song.audioUrl);
      await _player.play();
    } catch (_) {
      _playerState = PlayerState.stopped;
      notifyListeners();
    }
  }

  void togglePlayPause() {
    if (_currentSong == null) return;
    if (_player.playing) {
      _player.pause();
    } else {
      _player.play();
    }
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
      _player.seek(Duration.zero);
      return;
    }
    _currentIndex = (_currentIndex - 1 + _queue.length) % _queue.length;
    playSong(_queue[_currentIndex], queue: _queue);
  }

  void seekTo(double value) {
    _player.seek(Duration(
      milliseconds: (value * _duration.inMilliseconds).round(),
    ));
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

  @override
  void dispose() {
    _playerStateSub.cancel();
    _positionSub.cancel();
    _durationSub.cancel();
    _player.dispose();
    super.dispose();
  }
}
