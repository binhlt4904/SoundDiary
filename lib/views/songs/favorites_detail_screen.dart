import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../viewmodels/favorites_viewmodel.dart';
import '../../viewmodels/player_viewmodel.dart';
import '../../viewmodels/history_viewmodel.dart';
import '../widgets/song_list_tile.dart';

class FavoritesDetailScreen extends StatelessWidget {
  const FavoritesDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.onBackground, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Yêu thích'),
      ),
      body: Consumer2<FavoritesViewModel, PlayerViewModel>(
        builder: (context, favVm, playerVm, _) {
          if (favVm.favorites.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.favorite_border,
                      size: 56,
                      color: AppColors.onSurfaceVariant.withOpacity(0.4)),
                  const SizedBox(height: 16),
                  const Text('Chưa có bài hát yêu thích',
                      style: TextStyle(color: AppColors.onSurfaceVariant)),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 8),
            itemCount: favVm.favorites.length,
            itemBuilder: (context, index) {
              final song = favVm.favorites[index];
              final isActive = playerVm.currentSong?.id == song.id;
              return SongListTile(
                song: song,
                isActive: isActive,
                isPlaying: isActive && playerVm.isPlaying,
                onTap: () {
                  context.read<HistoryViewModel>().addToHistory(song);
                  playerVm.playSong(song, queue: favVm.favorites);
                },
                onFavoriteToggle: () => favVm.toggleFavorite(song.id),
              );
            },
          );
        },
      ),
    );
  }
}
