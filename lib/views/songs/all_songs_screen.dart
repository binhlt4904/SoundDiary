import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../viewmodels/library_viewmodel.dart';
import '../../viewmodels/player_viewmodel.dart';
import '../../viewmodels/history_viewmodel.dart';
import '../widgets/song_list_tile.dart';

class AllSongsScreen extends StatelessWidget {
  final bool embedded;

  const AllSongsScreen({super.key}) : embedded = false;
  const AllSongsScreen.embedded({super.key}) : embedded = true;

  @override
  Widget build(BuildContext context) {
    final body = Consumer2<LibraryViewModel, PlayerViewModel>(
      builder: (context, libraryVm, playerVm, _) {
        return Column(
          children: [
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
            Expanded(
              child: libraryVm.songs.isEmpty
                  ? const Center(
                child: Text('Không tìm thấy bài hát',
                    style:
                    TextStyle(color: AppColors.onSurfaceVariant)),
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
                      context
                          .read<HistoryViewModel>()
                          .addToHistory(song);
                      playerVm.playSong(song,
                          queue: libraryVm.songs);
                    },
                    onFavoriteToggle: () =>
                        libraryVm.toggleFavorite(song.id),
                  );
                },
              ),
            ),
          ],
        );
      },
    );

    if (embedded) return body;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.onBackground, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Tất cả bài hát'),
      ),
      body: body,
    );
  }
}