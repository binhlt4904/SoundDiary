import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../viewmodels/player_viewmodel.dart';
import '../../viewmodels/playlist_viewmodel.dart';
import '../../domain/enums/player_state.dart';
import '../../domain/entities/song.dart';

class NowPlayingScreen extends StatelessWidget {
  const NowPlayingScreen({super.key});

  void _showAddToPlaylistSheet(BuildContext context, Song song) {
    final playlistVm = context.read<PlaylistViewModel>();
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceVariant,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.onSurfaceVariant.withOpacity(0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Title
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 4, 20, 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Thêm vào playlist',
                  style: TextStyle(
                    color: AppColors.onBackground,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const Divider(height: 1),
            // Playlist list
            if (playlistVm.playlists.isEmpty)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Chưa có playlist nào.\nHãy tạo playlist trong tab Thư viện.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.onSurfaceVariant),
                ),
              )
            else
              ...playlistVm.playlists.map((playlist) {
                final alreadyAdded =
                playlist.songs.any((s) => s.id == song.id);
                return ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: playlist.coverArt != null
                        ? Image.network(playlist.coverArt!,
                        width: 44, height: 44, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _defaultCover())
                        : _defaultCover(),
                  ),
                  title: Text(
                    playlist.name,
                    style: TextStyle(
                      color: alreadyAdded
                          ? AppColors.onSurfaceVariant
                          : AppColors.onBackground,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(
                    alreadyAdded
                        ? 'Đã có trong playlist'
                        : '${playlist.songCount} bài hát',
                    style: const TextStyle(
                        color: AppColors.onSurfaceVariant, fontSize: 12),
                  ),
                  trailing: alreadyAdded
                      ? const Icon(Icons.check_circle_rounded,
                      color: AppColors.primary, size: 20)
                      : const Icon(Icons.add_circle_outline,
                      color: AppColors.primary, size: 20),
                  onTap: alreadyAdded
                      ? null
                      : () {
                    playlistVm.addSongToPlaylist(playlist.id, song);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            'Đã thêm "${song.title}" vào "${playlist.name}"'),
                        backgroundColor: AppColors.primary,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                );
              }),
            const SizedBox(height: 12),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_down_rounded,
              color: AppColors.onBackground, size: 30),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Đang phát',
            style: TextStyle(
                color: AppColors.onBackground,
                fontSize: 16,
                fontWeight: FontWeight.w600)),
        centerTitle: true,
        actions: [
          Consumer<PlayerViewModel>(
            builder: (context, vm, _) {
              if (vm.currentSong == null) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(Icons.playlist_add_rounded,
                    color: AppColors.onBackground, size: 26),
                onPressed: () =>
                    _showAddToPlaylistSheet(context, vm.currentSong!),
              );
            },
          ),
        ],
      ),
      body: Consumer<PlayerViewModel>(
        builder: (context, vm, _) {
          final song = vm.currentSong;
          if (song == null) {
            return const Center(
              child: Text('Chưa có bài hát nào',
                  style: TextStyle(color: AppColors.onSurfaceVariant)),
            );
          }

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 24),
                // Album Art
                Container(
                  width: double.infinity,
                  height: 300,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.2),
                        blurRadius: 30,
                        offset: const Offset(0, 15),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(
                      song.albumArt,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: AppColors.surfaceVariant,
                        child: const Icon(Icons.music_note,
                            color: AppColors.primary, size: 80),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                // Title & Artist
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(song.title,
                              style: const TextStyle(
                                  color: AppColors.onBackground,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700),
                              overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 4),
                          Text(song.artist,
                              style: const TextStyle(
                                  color: AppColors.onSurfaceVariant,
                                  fontSize: 15)),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: Icon(
                        song.isFavorite
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: song.isFavorite
                            ? AppColors.primary
                            : AppColors.onSurfaceVariant,
                        size: 26,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Progress Slider
                Column(
                  children: [
                    SliderTheme(
                      data: SliderThemeData(
                        trackHeight: 3,
                        thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 6),
                        overlayShape: const RoundSliderOverlayShape(
                            overlayRadius: 16),
                        activeTrackColor: AppColors.primary,
                        inactiveTrackColor: AppColors.surfaceVariant,
                        thumbColor: AppColors.primary,
                        overlayColor: AppColors.primary.withOpacity(0.2),
                      ),
                      child: Slider(
                        value: vm.progress.clamp(0.0, 1.0),
                        onChanged: vm.seekTo,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(vm.formatDuration(vm.position),
                              style: const TextStyle(
                                  color: AppColors.onSurfaceVariant,
                                  fontSize: 12)),
                          Text(vm.formatDuration(vm.duration),
                              style: const TextStyle(
                                  color: AppColors.onSurfaceVariant,
                                  fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      onPressed: vm.toggleShuffle,
                      icon: Icon(Icons.shuffle_rounded,
                          color: vm.isShuffle
                              ? AppColors.primary
                              : AppColors.onSurfaceVariant,
                          size: 24),
                    ),
                    IconButton(
                      onPressed: vm.skipPrevious,
                      icon: const Icon(Icons.skip_previous_rounded,
                          color: AppColors.onBackground, size: 36),
                    ),
                    GestureDetector(
                      onTap: vm.togglePlayPause,
                      child: Container(
                        width: 68,
                        height: 68,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          vm.isPlaying
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 36,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: vm.skipNext,
                      icon: const Icon(Icons.skip_next_rounded,
                          color: AppColors.onBackground, size: 36),
                    ),
                    IconButton(
                      onPressed: vm.toggleRepeat,
                      icon: Icon(
                        vm.repeatMode == RepeatMode.one
                            ? Icons.repeat_one_rounded
                            : Icons.repeat_rounded,
                        color: vm.repeatMode != RepeatMode.none
                            ? AppColors.primary
                            : AppColors.onSurfaceVariant,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

Widget _defaultCover() {
  return Container(
    width: 44,
    height: 44,
    decoration: BoxDecoration(
      color: AppColors.primary.withOpacity(0.2),
      borderRadius: BorderRadius.circular(8),
    ),
    child: const Icon(Icons.queue_music_rounded,
        color: AppColors.primary, size: 22),
  );
}
