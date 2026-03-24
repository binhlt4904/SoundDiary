import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../viewmodels/library_viewmodel.dart';
import '../../viewmodels/player_viewmodel.dart';
import '../widgets/song_list_tile.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<LibraryViewModel, PlayerViewModel>(
      builder: (context, libraryVm, playerVm, _) {
        return Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: TextField(
                onChanged: libraryVm.search,
                style: const TextStyle(color: AppColors.onBackground),
                decoration: const InputDecoration(
                  hintText: 'Tìm kiếm bài hát, nghệ sĩ...',
                  prefixIcon: Icon(Icons.search, size: 20),
                ),
              ),
            ),
            const Divider(height: 1),
            // Song List
            Expanded(
              child: libraryVm.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    )
                  : libraryVm.songs.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.search_off,
                                size: 48,
                                color: AppColors.onSurfaceVariant
                                    .withOpacity(0.5),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Không tìm thấy bài hát',
                                style: TextStyle(
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.only(top: 8, bottom: 8),
                          itemCount: libraryVm.songs.length,
                          itemBuilder: (context, index) {
                            final song = libraryVm.songs[index];
                            final isActive =
                                playerVm.currentSong?.id == song.id;
                            return SongListTile(
                              song: song,
                              isActive: isActive,
                              isPlaying: isActive && playerVm.isPlaying,
                              onTap: () {
                                playerVm.playSong(
                                  song,
                                  queue: libraryVm.songs,
                                );
                              },
                              onFavoriteToggle: () {
                                libraryVm.toggleFavorite(song.id);
                              },
                            );
                          },
                        ),
            ),
          ],
        );
      },
    );
  }
}
