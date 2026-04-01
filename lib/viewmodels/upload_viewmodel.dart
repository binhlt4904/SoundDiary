import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart' as ja;
import '../domain/entities/song.dart';
import '../domain/entities/artist.dart';
import '../data/implementations/mock_music_repository.dart';
import 'auth_viewmodel.dart';

enum UploadStep { songInfo, confirm }
enum UploadStatus { idle, uploading, success, error }

class UploadViewModel extends ChangeNotifier {
  final MockMusicRepository _repository;
  final AuthViewModel _auth;

  String get uploaderName =>
      _auth.currentUser?.displayName ?? 'Người dùng';

  UploadViewModel(this._repository, this._auth);

  // ── Form state ─────────────────────────────────────────────
  UploadStep _step = UploadStep.songInfo;
  UploadStatus _status = UploadStatus.idle;
  String? _errorMessage;

  // Song info
  String _title = '';
  String _genre = '';
  int _durationSec = 180;
  String? _audioFilePath;
  String? _audioFileName;
  bool _isDetectingDuration = false;
  String? _coverUrl;

  // Getters
  UploadStep get step => _step;
  UploadStatus get status => _status;
  String? get errorMessage => _errorMessage;
  String get title => _title;
  String get genre => _genre;
  int get durationSec => _durationSec;
  String? get coverUrl => _coverUrl;
  bool get hasAudioFile => _audioFilePath != null;
  String? get audioFileName => _audioFileName;
  bool get isDetectingDuration => _isDetectingDuration;
  bool get isUploading => _status == UploadStatus.uploading;

  bool get canProceedStep1 =>
      _title.trim().isNotEmpty && _audioFilePath != null;

  // ── Step 1: Song info ──────────────────────────────────────
  void setTitle(String v) {
    _title = v;
    notifyListeners();
  }

  void setGenre(String v) {
    _genre = v;
    notifyListeners();
  }

  void setCoverUrl(String? v) {
    _coverUrl = v;
    notifyListeners();
  }

  /// Opens the native audio file picker, then auto-detects duration.
  Future<void> pickAudioFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
      allowMultiple: false,
    );
    if (result == null || result.files.isEmpty) return;

    final file = result.files.single;
    if (file.path == null) return;

    _audioFilePath = file.path;
    _audioFileName = file.name;
    _isDetectingDuration = true;
    notifyListeners();

    // Use a temporary AudioPlayer to read the actual duration from the file.
    final player = ja.AudioPlayer();
    try {
      final duration = await player.setFilePath(file.path!);
      if (duration != null && duration.inSeconds > 0) {
        _durationSec = duration.inSeconds;
      }
    } catch (_) {
      // Keep the default 180s if detection fails.
    } finally {
      await player.dispose();
      _isDetectingDuration = false;
      notifyListeners();
    }
  }

  // ── Navigation ─────────────────────────────────────────────
  void nextStep() {
    if (_step == UploadStep.songInfo) {
      _step = UploadStep.confirm;
    }
    notifyListeners();
  }

  void prevStep() {
    if (_step == UploadStep.confirm) {
      _step = UploadStep.songInfo;
    }
    notifyListeners();
  }

  void reset() {
    _step = UploadStep.songInfo;
    _status = UploadStatus.idle;
    _errorMessage = null;
    _title = '';
    _genre = '';
    _durationSec = 180;
    _audioFilePath = null;
    _audioFileName = null;
    _isDetectingDuration = false;
    _coverUrl = null;
    notifyListeners();
  }

  // ── Submit ─────────────────────────────────────────────────
  Future<Song?> submit() async {
    _status = UploadStatus.uploading;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. Resolve artist — tìm hoặc tạo artist cho người upload
      final existing = _repository
          .getAllArtists()
          .where((a) => a.name == uploaderName)
          .toList();
      final Artist artist = existing.isNotEmpty
          ? existing.first
          : _repository.addArtist(name: uploaderName);

      // 2. Add song — audioUrl is the local file URI for just_audio playback
      final song = _repository.addSong(
        title: _title.trim(),
        artistId: artist.id,
        albumId: null,
        audioUrl: Uri.file(_audioFilePath!).toString(),
        coverUrl:
            _coverUrl ?? 'https://picsum.photos/seed/${_title.hashCode}/400',
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
