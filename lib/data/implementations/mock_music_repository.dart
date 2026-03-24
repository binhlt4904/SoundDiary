import '../../domain/entities/song.dart';
import '../../domain/entities/playlist.dart';

class MockMusicRepository {
  static final List<Song> _allSongs = [
    Song(
      id: '1',
      title: 'Midnight Dreams',
      artist: 'The Wanderers',
      albumArt: 'https://picsum.photos/seed/midnight/200',
      audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
      duration: const Duration(minutes: 3, seconds: 45),
      isFavorite: false,
    ),
    Song(
      id: '2',
      title: 'Summer Vibes',
      artist: 'Coastal Beats',
      albumArt: 'https://picsum.photos/seed/summer/200',
      audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3',
      duration: const Duration(minutes: 4, seconds: 12),
      isFavorite: true,
    ),
    Song(
      id: '3',
      title: 'Urban Nights',
      artist: 'City Lights',
      albumArt: 'https://picsum.photos/seed/urban/200',
      audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3',
      duration: const Duration(minutes: 3, seconds: 28),
      isFavorite: false,
    ),
    Song(
      id: '4',
      title: 'Mountain Echo',
      artist: 'Nature Sounds',
      albumArt: 'https://picsum.photos/seed/mountain/200',
      audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-4.mp3',
      duration: const Duration(minutes: 5, seconds: 3),
      isFavorite: true,
    ),
    Song(
      id: '5',
      title: 'Electric Soul',
      artist: 'Neon Pulse',
      albumArt: 'https://picsum.photos/seed/electric/200',
      audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-5.mp3',
      duration: const Duration(minutes: 3, seconds: 58),
      isFavorite: false,
    ),
    Song(
      id: '6',
      title: 'Jazz Cafe',
      artist: 'The Blue Notes',
      albumArt: 'https://picsum.photos/seed/jazz/200',
      audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-6.mp3',
      duration: const Duration(minutes: 4, seconds: 33),
      isFavorite: true,
    ),
    Song(
      id: '7',
      title: 'Desert Wind',
      artist: 'Sand Dunes',
      albumArt: 'https://picsum.photos/seed/desert/200',
      audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-7.mp3',
      duration: const Duration(minutes: 3, seconds: 17),
      isFavorite: false,
    ),
    Song(
      id: '8',
      title: 'Ocean Drive',
      artist: 'Wave Riders',
      albumArt: 'https://picsum.photos/seed/ocean/200',
      audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-8.mp3',
      duration: const Duration(minutes: 4, seconds: 52),
      isFavorite: false,
    ),
  ];

  static final List<Playlist> _playlists = [
    Playlist(
      id: 'p1',
      name: 'Chill Vibes',
      coverArt: 'https://picsum.photos/seed/chill/200',
      songs: [_allSongs[1], _allSongs[3], _allSongs[5]],
    ),
    Playlist(
      id: 'p2',
      name: 'Workout Mix',
      coverArt: 'https://picsum.photos/seed/workout/200',
      songs: [_allSongs[0], _allSongs[4]],
    ),
  ];

  List<Song> getAllSongs() => List.from(_allSongs);

  List<Song> getFavoriteSongs() =>
      _allSongs.where((s) => s.isFavorite).toList();

  List<Playlist> getPlaylists() => List.from(_playlists);

  void toggleFavorite(String songId) {
    final idx = _allSongs.indexWhere((s) => s.id == songId);
    if (idx != -1) {
      _allSongs[idx].isFavorite = !_allSongs[idx].isFavorite;
    }
    // Sync across playlists
    for (final pl in _playlists) {
      final pi = pl.songs.indexWhere((s) => s.id == songId);
      if (pi != -1) {
        pl.songs[pi].isFavorite = _allSongs[idx].isFavorite;
      }
    }
  }

  Playlist addPlaylist(String name) {
    final pl = Playlist(
      id: 'p${_playlists.length + 1}_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
    );
    _playlists.add(pl);
    return pl;
  }

  void deletePlaylist(String id) {
    _playlists.removeWhere((p) => p.id == id);
  }

  void addSongToPlaylist(String playlistId, Song song) {
    final pl = _playlists.firstWhere((p) => p.id == playlistId);
    if (!pl.songs.any((s) => s.id == song.id)) {
      pl.songs.add(song);
    }
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
