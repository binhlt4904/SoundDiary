import 'package:flutter/foundation.dart';
import '../domain/entities/song.dart';
import '../domain/entities/artist.dart';
import '../domain/entities/album.dart';
import '../data/implementations/mock_music_repository.dart';

enum UploadStep { songInfo, artistAlbum, confirm }
enum UploadStatus { idle, uploading, success, error }

class UploadViewModel extends ChangeNotifier {
  final MockMusicRepository _repository;

  UploadViewModel(this._repository);

  // ── Form state ─────────────────────────────────────────────
  UploadStep _step = UploadStep.songInfo;
  UploadStatus _status = UploadStatus.idle;
  String? _errorMessage;

  // Song info
  String _title = '';
  String _genre = '';
  int _durationSec = 180;
  String? _audioBytesPath; // simulated file path
  String? _coverUrl;

  // Artist selection
  Artist? _selectedArtist;
  String _newArtistName = '';
  bool _createNewArtist = false;

  // Album selection
  Album? _selectedAlbum;
  String _newAlbumTitle = '';
  bool _createNewAlbum = false;
  bool _noAlbum = false;

  // Getters
  UploadStep get step => _step;
  UploadStatus get status => _status;
  String? get errorMessage => _errorMessage;
  String get title => _title;
  String get genre => _genre;
  int get durationSec => _durationSec;
  String? get coverUrl => _coverUrl;
  Artist? get selectedArtist => _selectedArtist;
  String get newArtistName => _newArtistName;
  bool get createNewArtist => _createNewArtist;
  Album? get selectedAlbum => _selectedAlbum;
  String get newAlbumTitle => _newAlbumTitle;
  bool get createNewAlbum => _createNewAlbum;
  bool get noAlbum => _noAlbum;
  bool get isUploading => _status == UploadStatus.uploading;

  bool get canProceedStep1 => _title.trim().isNotEmpty;
  bool get canProceedStep2 =>
      (_selectedArtist != null || _newArtistName.trim().isNotEmpty) &&
      (_noAlbum ||
          _selectedAlbum != null ||
          _newAlbumTitle.trim().isNotEmpty);

  // ── Step 1: Song info ──────────────────────────────────────
  void setTitle(String v) { _title = v; notifyListeners(); }
  void setGenre(String v) { _genre = v; notifyListeners(); }
  void setDuration(int sec) { _durationSec = sec; notifyListeners(); }
  void setCoverUrl(String? v) { _coverUrl = v; notifyListeners(); }
  void setAudioPath(String? v) { _audioBytesPath = v; notifyListeners(); }

  // ── Step 2: Artist ─────────────────────────────────────────
  void selectArtist(Artist? a) {
    _selectedArtist = a;
    _createNewArtist = false;
    // Reset album when artist changes
    _selectedAlbum = null;
    _newAlbumTitle = '';
    notifyListeners();
  }

  void setCreateNewArtist(bool v) {
    _createNewArtist = v;
    if (v) _selectedArtist = null;
    notifyListeners();
  }

  void setNewArtistName(String v) { _newArtistName = v; notifyListeners(); }

  // ── Step 2: Album ──────────────────────────────────────────
  void selectAlbum(Album? a) {
    _selectedAlbum = a;
    _createNewAlbum = false;
    _noAlbum = false;
    notifyListeners();
  }

  void setCreateNewAlbum(bool v) {
    _createNewAlbum = v;
    if (v) { _selectedAlbum = null; _noAlbum = false; }
    notifyListeners();
  }

  void setNewAlbumTitle(String v) { _newAlbumTitle = v; notifyListeners(); }

  void setNoAlbum(bool v) {
    _noAlbum = v;
    if (v) { _selectedAlbum = null; _createNewAlbum = false; }
    notifyListeners();
  }

  // ── Navigation ─────────────────────────────────────────────
  void nextStep() {
    if (_step == UploadStep.songInfo) _step = UploadStep.artistAlbum;
    else if (_step == UploadStep.artistAlbum) _step = UploadStep.confirm;
    notifyListeners();
  }

  void prevStep() {
    if (_step == UploadStep.confirm) _step = UploadStep.artistAlbum;
    else if (_step == UploadStep.artistAlbum) _step = UploadStep.songInfo;
    notifyListeners();
  }

  void reset() {
    _step = UploadStep.songInfo;
    _status = UploadStatus.idle;
    _errorMessage = null;
    _title = '';
    _genre = '';
    _durationSec = 180;
    _audioBytesPath = null;
    _coverUrl = null;
    _selectedArtist = null;
    _newArtistName = '';
    _createNewArtist = false;
    _selectedAlbum = null;
    _newAlbumTitle = '';
    _createNewAlbum = false;
    _noAlbum = false;
    notifyListeners();
  }

  // ── Submit ─────────────────────────────────────────────────
  Future<Song?> submit() async {
    _status = UploadStatus.uploading;
    _errorMessage = null;
    notifyListeners();

    try {
      // Simulate upload delay
      await Future.delayed(const Duration(milliseconds: 1200));

      // 1. Resolve artist
      Artist artist;
      if (_createNewArtist || _selectedArtist == null) {
        artist = _repository.addArtist(name: _newArtistName.trim());
      } else {
        artist = _selectedArtist!;
      }

      // 2. Resolve album
      Album? album;
      if (!_noAlbum) {
        if (_createNewAlbum || (_selectedAlbum == null && _newAlbumTitle.isNotEmpty)) {
          album = _repository.addAlbum(
            title: _newAlbumTitle.trim(),
            artistId: artist.id,
          );
        } else {
          album = _selectedAlbum;
        }
      }

      // 3. Add song
      final song = _repository.addSong(
        title: _title.trim(),
        artistId: artist.id,
        albumId: album?.id,
        audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
        coverUrl: _coverUrl ?? 'https://picsum.photos/seed/${_title.hashCode}/400',
        duration: Duration(seconds: _durationSec),
        genre: _genre.trim().isEmpty ? null : _genre.trim(),
      );

      _status = UploadStatus.success;
      notifyListeners();
      return song;
    } catch (e) {
      _status = UploadStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

  String formatDuration(int sec) {
    final m = (sec ~/ 60).toString().padLeft(2, '0');
    final s = (sec % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}
