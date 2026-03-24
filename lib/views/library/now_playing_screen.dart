import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../viewmodels/player_viewmodel.dart';
import '../../domain/enums/player_state.dart';

class NowPlayingScreen extends StatelessWidget {
  const NowPlayingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.onBackground,
            size: 30,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Đang phát',
          style: TextStyle(
            color: AppColors.onBackground,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.more_horiz,
              color: AppColors.onBackground,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: Consumer<PlayerViewModel>(
        builder: (context, vm, _) {
          final song = vm.currentSong;
          if (song == null) {
            return const Center(
              child: Text(
                'Chưa có bài hát nào',
                style: TextStyle(color: AppColors.onSurfaceVariant),
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 24),
                // Album Art
                Hero(
                  tag: 'album_art_${song.id}',
                  child: Container(
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
                          child: const Icon(
                            Icons.music_note,
                            color: AppColors.primary,
                            size: 80,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                // Song Title & Artist
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            song.title,
                            style: const TextStyle(
                              color: AppColors.onBackground,
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            song.artist,
                            style: const TextStyle(
                              color: AppColors.onSurfaceVariant,
                              fontSize: 15,
                            ),
                          ),
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
                // Progress
                Column(
                  children: [
                    SliderTheme(
                      data: SliderThemeData(
                        trackHeight: 3,
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 6,
                        ),
                        overlayShape: const RoundSliderOverlayShape(
                          overlayRadius: 16,
                        ),
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
                          Text(
                            vm.formatDuration(vm.position),
                            style: const TextStyle(
                              color: AppColors.onSurfaceVariant,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            vm.formatDuration(vm.duration),
                            style: const TextStyle(
                              color: AppColors.onSurfaceVariant,
                              fontSize: 12,
                            ),
                          ),
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
                    // Shuffle
                    IconButton(
                      onPressed: vm.toggleShuffle,
                      icon: Icon(
                        Icons.shuffle_rounded,
                        color: vm.isShuffle
                            ? AppColors.primary
                            : AppColors.onSurfaceVariant,
                        size: 24,
                      ),
                    ),
                    // Previous
                    IconButton(
                      onPressed: vm.skipPrevious,
                      icon: const Icon(
                        Icons.skip_previous_rounded,
                        color: AppColors.onBackground,
                        size: 36,
                      ),
                    ),
                    // Play/Pause
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
                    // Next
                    IconButton(
                      onPressed: vm.skipNext,
                      icon: const Icon(
                        Icons.skip_next_rounded,
                        color: AppColors.onBackground,
                        size: 36,
                      ),
                    ),
                    // Repeat
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
