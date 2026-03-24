import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../viewmodels/playlist_viewmodel.dart';
import '../../viewmodels/player_viewmodel.dart';
import '../widgets/song_list_tile.dart';

class PlaylistDetailScreen extends StatelessWidget {
  final String playlistId;

  const PlaylistDetailScreen({super.key, required this.playlistId});

  @override
  Widget build(BuildContext context) {
    return Consumer2<PlaylistViewModel, PlayerViewModel>(
      builder: (context, playlistVm, playerVm, _) {
        final playlist = playlistVm.playlists.firstWhere(
          (p) => p.id == playlistId,
          orElse: () => throw Exception('Playlist not found'),
        );

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: Text(playlist.name),
            backgroundColor: AppColors.background,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: AppColors.onBackground, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: playlist.songs.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.music_off,
                          size: 56,
                          color: AppColors.onSurfaceVariant.withOpacity(0.4)),
                      const SizedBox(height: 16),
                      const Text('Playlist này chưa có bài hát',
                          style:
                              TextStyle(color: AppColors.onSurfaceVariant)),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Play all button
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                      child: GestureDetector(
                        onTap: () {
                          if (playlist.songs.isNotEmpty) {
                            playerVm.playSong(
                              playlist.songs.first,
                              queue: playlist.songs,
                            );
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.primary.withOpacity(0.3),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.play_arrow_rounded,
                                  color: AppColors.primary, size: 22),
                              SizedBox(width: 8),
                              Text(
                                'Phát tất cả',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.only(bottom: 8),
                        itemCount: playlist.songs.length,
                        itemBuilder: (context, index) {
                          final song = playlist.songs[index];
                          final isActive =
                              playerVm.currentSong?.id == song.id;
                          return SongListTile(
                            song: song,
                            isActive: isActive,
                            isPlaying: isActive && playerVm.isPlaying,
                            onTap: () {
                              playerVm.playSong(
                                song,
                                queue: playlist.songs,
                              );
                            },
                            onFavoriteToggle: () {},
                          );
                        },
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}
