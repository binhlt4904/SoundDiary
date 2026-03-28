import 'package:flutter/foundation.dart';
import '../domain/entities/artist.dart';
import '../domain/entities/album.dart';
import '../data/implementations/mock_music_repository.dart';

class ArtistViewModel extends ChangeNotifier {
  final MockMusicRepository _repository;
  MockMusicRepository get repository => _repository;

  List<Artist> _artists = [];
  List<Album> _albums = [];
  bool _isLoading = false;
  String? _error;

  ArtistViewModel(this._repository) {
    loadAll();
  }

  List<Artist> get artists => _artists;
  List<Album> get albums => _albums;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<Album> albumsOf(String artistId) =>
      _albums.where((a) => a.artistId == artistId).toList();

  void loadAll() {
    _isLoading = true;
    notifyListeners();
    _artists = _repository.getAllArtists();
    _albums = _repository.getAllAlbums();
    _isLoading = false;
    notifyListeners();
  }

  // ── Artist CRUD ────────────────────────────────────────────
  Artist createArtist({required String name, String? bio, String? avatarUrl}) {
    final artist = _repository.addArtist(name: name, bio: bio, avatarUrl: avatarUrl);
    loadAll();
    return artist;
  }

  void updateArtist(Artist artist) {
    _repository.updateArtist(artist);
    loadAll();
  }

  void deleteArtist(String id) {
    _repository.deleteArtist(id);
    loadAll();
  }

  // ── Album CRUD ─────────────────────────────────────────────
  Album createAlbum({
    required String title,
    required String artistId,
    String? coverUrl,
    DateTime? releasedAt,
  }) {
    final album = _repository.addAlbum(
      title: title,
      artistId: artistId,
      coverUrl: coverUrl,
      releasedAt: releasedAt,
    );
    loadAll();
    return album;
  }

  void updateAlbum(Album album) {
    _repository.updateAlbum(album);
    loadAll();
  }

  void deleteAlbum(String id) {
    _repository.deleteAlbum(id);
    loadAll();
  }

  // ── Search ─────────────────────────────────────────────────
  List<Artist> searchArtists(String query) {
    if (query.isEmpty) return _artists;
    final q = query.toLowerCase();
    return _artists.where((a) => a.name.toLowerCase().contains(q)).toList();
  }

  List<Album> searchAlbums(String query) {
    if (query.isEmpty) return _albums;
    final q = query.toLowerCase();
    return _albums
        .where((a) =>
            a.title.toLowerCase().contains(q) ||
            _artists
                .firstWhere((ar) => ar.id == a.artistId,
                    orElse: () => Artist(id: '', name: ''))
                .name
                .toLowerCase()
                .contains(q))
        .toList();
  }
}
