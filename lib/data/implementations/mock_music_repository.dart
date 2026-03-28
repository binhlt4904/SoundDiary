import '../../domain/entities/song.dart';
import '../../domain/entities/playlist.dart';
import '../../domain/entities/artist.dart';
import '../../domain/entities/album.dart';

class MockMusicRepository {
  // ── Artists ────────────────────────────────────────────────
  static final List<Artist> _artists = [
    Artist(id: 'ar1', name: 'The Wanderers',  bio: 'Indie rock band'),
    Artist(id: 'ar2', name: 'Coastal Beats',  bio: 'Chill electronic'),
    Artist(id: 'ar3', name: 'City Lights',    bio: 'Urban pop'),
    Artist(id: 'ar4', name: 'Nature Sounds',  bio: 'Ambient'),
    Artist(id: 'ar5', name: 'The Blue Notes', bio: 'Jazz'),
    Artist(id: 'ar6', name: 'Neon Pulse',     bio: 'Electronic'),
  ];

  // ── Albums ─────────────────────────────────────────────────
  static final List<Album> _albums = [
    Album(id: 'al1', title: 'Night Journeys', artistId: 'ar1',
        releasedAt: DateTime(2023, 6, 1)),
    Album(id: 'al2', title: 'Ocean Drive',    artistId: 'ar2',
        releasedAt: DateTime(2023, 9, 15)),
    Album(id: 'al3', title: 'Blue Sessions',  artistId: 'ar5',
        releasedAt: DateTime(2022, 11, 20)),
  ];

  // ── Songs ──────────────────────────────────────────────────
  static final List<Song> _allSongs = [
    Song(id: '1', title: 'Midnight Dreams', artist: 'The Wanderers',
        albumArt: 'https://picsum.photos/seed/midnight/200',
        audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
        duration: const Duration(minutes: 3, seconds: 45),
        artistId: 'ar1', albumId: 'al1'),
    Song(id: '2', title: 'Summer Vibes', artist: 'Coastal Beats',
        albumArt: 'https://picsum.photos/seed/summer/200',
        audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3',
        duration: const Duration(minutes: 4, seconds: 12),
        isFavorite: true, artistId: 'ar2', albumId: 'al2'),
    Song(id: '3', title: 'Urban Nights', artist: 'City Lights',
        albumArt: 'https://picsum.photos/seed/urban/200',
        audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3',
        duration: const Duration(minutes: 3, seconds: 28),
        artistId: 'ar3'),
    Song(id: '4', title: 'Mountain Echo', artist: 'Nature Sounds',
        albumArt: 'https://picsum.photos/seed/mountain/200',
        audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-4.mp3',
        duration: const Duration(minutes: 5, seconds: 3),
        isFavorite: true, artistId: 'ar4'),
    Song(id: '5', title: 'Electric Soul', artist: 'Neon Pulse',
        albumArt: 'https://picsum.photos/seed/electric/200',
        audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-5.mp3',
        duration: const Duration(minutes: 3, seconds: 58),
        artistId: 'ar6'),
    Song(id: '6', title: 'Jazz Cafe', artist: 'The Blue Notes',
        albumArt: 'https://picsum.photos/seed/jazz/200',
        audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-6.mp3',
        duration: const Duration(minutes: 4, seconds: 33),
        isFavorite: true, artistId: 'ar5', albumId: 'al3'),
    Song(id: '7', title: 'Desert Wind', artist: 'Nature Sounds',
        albumArt: 'https://picsum.photos/seed/desert/200',
        audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-7.mp3',
        duration: const Duration(minutes: 3, seconds: 17),
        artistId: 'ar4'),
    Song(id: '8', title: 'Ocean Drive', artist: 'Coastal Beats',
        albumArt: 'https://picsum.photos/seed/ocean/200',
        audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-8.mp3',
        duration: const Duration(minutes: 4, seconds: 52),
        artistId: 'ar2', albumId: 'al2'),
  ];

  static final List<Playlist> _playlists = [
    Playlist(id: 'p1', name: 'Chill Vibes',
        coverArt: 'https://picsum.photos/seed/chill/200',
        songs: [_allSongs[1], _allSongs[3], _allSongs[5]]),
    Playlist(id: 'p2', name: 'Workout Mix',
        coverArt: 'https://picsum.photos/seed/workout/200',
        songs: [_allSongs[0], _allSongs[4]]),
  ];

  // ── Artist operations ──────────────────────────────────────
  List<Artist> getAllArtists() => List.from(_artists);

  Artist addArtist({required String name, String? bio, String? avatarUrl}) {
    final artist = Artist(
      id: 'ar${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      bio: bio,
      avatarUrl: avatarUrl,
    );
    _artists.add(artist);
    return artist;
  }

  void updateArtist(Artist updated) {
    final i = _artists.indexWhere((a) => a.id == updated.id);
    if (i != -1) {
      _artists[i].name = updated.name;
      _artists[i].bio = updated.bio;
      _artists[i].avatarUrl = updated.avatarUrl;
      // Sync artist name in songs
      for (final s in _allSongs) {
        if (s.artistId == updated.id) s.artist = updated.name;
      }
    }
  }

  void deleteArtist(String id) {
    _artists.removeWhere((a) => a.id == id);
    _allSongs.removeWhere((s) => s.artistId == id);
    _albums.removeWhere((a) => a.artistId == id);
  }

  // ── Album operations ───────────────────────────────────────
  List<Album> getAllAlbums() => List.from(_albums);

  Album addAlbum({
    required String title,
    required String artistId,
    String? coverUrl,
    DateTime? releasedAt,
  }) {
    final album = Album(
      id: 'al${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      artistId: artistId,
      coverUrl: coverUrl,
      releasedAt: releasedAt,
    );
    _albums.add(album);
    return album;
  }

  void updateAlbum(Album updated) {
    final i = _albums.indexWhere((a) => a.id == updated.id);
    if (i != -1) {
      _albums[i].title = updated.title;
      _albums[i].coverUrl = updated.coverUrl;
    }
  }

  void deleteAlbum(String id) {
    _albums.removeWhere((a) => a.id == id);
    for (final s in _allSongs) {
      if (s.albumId == id) s.albumId = null;
    }
  }

  // ── Song operations ────────────────────────────────────────
  List<Song> getAllSongs() => List.from(_allSongs);

  List<Song> getFavoriteSongs() =>
      _allSongs.where((s) => s.isFavorite).toList();

  Song addSong({
    required String title,
    required String artistId,
    String? albumId,
    required String audioUrl,
    String? coverUrl,
    Duration duration = const Duration(minutes: 3),
    String? genre,
  }) {
    final artistName = _artists
        .firstWhere((a) => a.id == artistId,
        orElse: () => Artist(id: artistId, name: 'Unknown'))
        .name;
    final song = Song(
      id: 's${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      artist: artistName,
      albumArt: coverUrl ?? 'https://picsum.photos/seed/$title/200',
      audioUrl: audioUrl,
      duration: duration,
      artistId: artistId,
      albumId: albumId,
    );
    _allSongs.add(song);
    return song;
  }

  void toggleFavorite(String songId) {
    final i = _allSongs.indexWhere((s) => s.id == songId);
    if (i != -1) {
      _allSongs[i].isFavorite = !_allSongs[i].isFavorite;
      for (final pl in _playlists) {
        final pi = pl.songs.indexWhere((s) => s.id == songId);
        if (pi != -1) pl.songs[pi].isFavorite = _allSongs[i].isFavorite;
      }
    }
  }

  // ── Playlist operations ────────────────────────────────────
  List<Playlist> getPlaylists() => List.from(_playlists);

  Playlist addPlaylist(String name) {
    final pl = Playlist(
      id: 'p${DateTime.now().millisecondsSinceEpoch}',
      name: name,
    );
    _playlists.add(pl);
    return pl;
  }

  void deletePlaylist(String id) => _playlists.removeWhere((p) => p.id == id);

  void addSongToPlaylist(String playlistId, Song song) {
    final pl = _playlists.firstWhere((p) => p.id == playlistId);
    if (!pl.songs.any((s) => s.id == song.id)) pl.songs.add(song);
  }

  List<Song> searchSongs(String query) {
    if (query.isEmpty) return getAllSongs();
    final q = query.toLowerCase();
    return _allSongs
        .where((s) =>
    s.title.toLowerCase().contains(q) ||
        s.artist.toLowerCase().contains(q))
        .toList();
  }
}
