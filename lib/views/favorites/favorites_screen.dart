import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../viewmodels/favorites_viewmodel.dart';
import '../../viewmodels/player_viewmodel.dart';
import '../widgets/song_list_tile.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<FavoritesViewModel, PlayerViewModel>(
      builder: (context, favVm, playerVm, _) {
        return Column(
          children: [
            // Search Bar (same style as library)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: TextField(
                style: const TextStyle(color: AppColors.onBackground),
                decoration: const InputDecoration(
                  hintText: 'Tìm kiếm bài hát, nghệ sĩ...',
                  prefixIcon: Icon(Icons.search, size: 20),
                ),
                onChanged: (_) {},
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: favVm.favorites.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.favorite_border,
                            size: 56,
                            color: AppColors.onSurfaceVariant.withOpacity(0.4),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Chưa có bài hát yêu thích',
                            style: TextStyle(
                              color: AppColors.onSurfaceVariant,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Nhấn ♡ trên bài hát để thêm vào đây',
                            style: TextStyle(
                              color: AppColors.onSurfaceVariant,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(top: 8, bottom: 8),
                      itemCount: favVm.favorites.length,
                      itemBuilder: (context, index) {
                        final song = favVm.favorites[index];
                        final isActive =
                            playerVm.currentSong?.id == song.id;
                        return SongListTile(
                          song: song,
                          isActive: isActive,
                          isPlaying: isActive && playerVm.isPlaying,
                          onTap: () {
                            playerVm.playSong(
                              song,
                              queue: favVm.favorites,
                            );
                          },
                          onFavoriteToggle: () {
                            favVm.toggleFavorite(song.id);
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
