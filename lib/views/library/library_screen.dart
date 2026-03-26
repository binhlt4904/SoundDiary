import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/entities/playlist.dart';
import '../../domain/entities/song.dart';
import '../../viewmodels/favorites_viewmodel.dart';
import '../../viewmodels/playlist_viewmodel.dart';
import '../../viewmodels/player_viewmodel.dart';
import '../../viewmodels/history_viewmodel.dart';
import '../playlist/playlist_detail_screen.dart';
import '../songs/all_songs_screen.dart';
import '../songs/favorites_detail_screen.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  void _showCreatePlaylistDialog(BuildContext context, PlaylistViewModel vm) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceVariant,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Tạo Playlist Mới',
            style: TextStyle(color: AppColors.onBackground, fontSize: 18)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: AppColors.onBackground),
          decoration: const InputDecoration(hintText: 'Tên playlist...'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy',
                style: TextStyle(color: AppColors.onSurfaceVariant)),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                vm.createPlaylist(controller.text.trim());
                Navigator.pop(ctx);
              }
            },
            child: const Text('Tạo', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  void _showPlaylistOptions(
      BuildContext context, Playlist playlist, PlaylistViewModel vm) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceVariant,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.onSurfaceVariant.withOpacity(0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline, color: Colors.redAccent),
            title: const Text('Xóa playlist',
                style: TextStyle(color: Colors.redAccent)),
            onTap: () {
              Navigator.pop(context);
              vm.deletePlaylist(playlist.id);
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<FavoritesViewModel, PlaylistViewModel, HistoryViewModel>(
      builder: (context, favVm, playlistVm, historyVm, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Quick Access Cards
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Row(
                  children: [
                    _QuickCard(
                      icon: Icons.favorite_rounded,
                      label: 'Yêu thích',
                      count: '${favVm.favorites.length} bài',
                      color: const Color(0xFFE8845C),
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const FavoritesDetailScreen())),
                    ),
                    const SizedBox(width: 12),
                    _QuickCard(
                      icon: Icons.library_music_rounded,
                      label: 'Tất cả nhạc',
                      count: 'Thư viện',
                      color: const Color(0xFF6C8EE8),
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const AllSongsScreen())),
                    ),
                  ],
                ),
              ),

              // Playlists Section
              _SectionHeader(
                title: 'Playlist',
                actionLabel: 'Tạo mới',
                onAction: () => _showCreatePlaylistDialog(context, playlistVm),
              ),
              if (playlistVm.playlists.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: GestureDetector(
                    onTap: () => _showCreatePlaylistDialog(context, playlistVm),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                      ),
                      child: const Column(
                        children: [
                          Icon(Icons.add_circle_outline,
                              color: AppColors.primary, size: 32),
                          SizedBox(height: 8),
                          Text('Tạo playlist đầu tiên',
                              style: TextStyle(color: AppColors.primary, fontSize: 14)),
                        ],
                      ),
                    ),
                  ),
                )
              else
                SizedBox(
                  height: 150,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: playlistVm.playlists.length,
                    itemBuilder: (context, index) {
                      final playlist = playlistVm.playlists[index];
                      return _PlaylistHCard(
                        playlist: playlist,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  PlaylistDetailScreen(playlistId: playlist.id)),
                        ),
                        onLongPress: () =>
                            _showPlaylistOptions(context, playlist, playlistVm),
                      );
                    },
                  ),
                ),

              // Recent History Section
              _SectionHeader(
                title: 'Nghe gần đây',
                actionLabel: historyVm.history.isNotEmpty ? 'Xóa tất cả' : null,
                onAction: historyVm.history.isNotEmpty ? historyVm.clearHistory : null,
              ),
              if (historyVm.history.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  child: Center(
                    child: Text('Chưa có lịch sử nghe nhạc',
                        style: TextStyle(
                            color: AppColors.onSurfaceVariant, fontSize: 14)),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(top: 4, bottom: 8),
                  itemCount: historyVm.history.length > 10 ? 10 : historyVm.history.length,
                  itemBuilder: (context, index) {
                    final song = historyVm.history[index];
                    return _HistoryTile(
                      song: song,
                      onTap: () {
                        historyVm.addToHistory(song);
                        context.read<PlayerViewModel>().playSong(
                            song, queue: historyVm.history.toList());
                      },
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;
  const _SectionHeader({required this.title, this.actionLabel, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: const TextStyle(
                  color: AppColors.onBackground,
                  fontSize: 18,
                  fontWeight: FontWeight.w700)),
          if (actionLabel != null)
            GestureDetector(
              onTap: onAction,
              child: Text(actionLabel!,
                  style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500)),
            ),
        ],
      ),
    );
  }
}

class _QuickCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String count;
  final Color color;
  final VoidCallback onTap;
  const _QuickCard(
      {required this.icon,
        required this.label,
        required this.count,
        required this.color,
        required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.25)),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: const TextStyle(
                            color: AppColors.onBackground,
                            fontSize: 13,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(count,
                        style: const TextStyle(
                            color: AppColors.onSurfaceVariant, fontSize: 11)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded,
                  color: color.withOpacity(0.6), size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlaylistHCard extends StatelessWidget {
  final Playlist playlist;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  const _PlaylistHCard(
      {required this.playlist,
        required this.onTap,
        required this.onLongPress});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        width: 130,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.divider, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius:
              const BorderRadius.vertical(top: Radius.circular(14)),
              child: playlist.coverArt != null
                  ? Image.network(playlist.coverArt!,
                  height: 90,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _defaultCover())
                  : _defaultCover(),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 2),
              child: Text(playlist.name,
                  style: const TextStyle(
                      color: AppColors.onBackground,
                      fontSize: 13,
                      fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 8),
              child: Text('${playlist.songCount} bài',
                  style: const TextStyle(
                      color: AppColors.onSurfaceVariant, fontSize: 11)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _defaultCover() => Container(
    height: 90,
    width: double.infinity,
    color: AppColors.primary.withOpacity(0.15),
    child: const Icon(Icons.queue_music_rounded,
        color: AppColors.primary, size: 32),
  );
}

class _HistoryTile extends StatelessWidget {
  final Song song;
  final VoidCallback onTap;
  const _HistoryTile({required this.song, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(song.albumArt,
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 48,
                    height: 48,
                    color: AppColors.surfaceVariant,
                    child: const Icon(Icons.music_note,
                        color: AppColors.primary, size: 22),
                  )),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(song.title,
                      style: const TextStyle(
                          color: AppColors.onBackground,
                          fontSize: 14,
                          fontWeight: FontWeight.w500),
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 3),
                  Text(song.artist,
                      style: const TextStyle(
                          color: AppColors.onSurfaceVariant, fontSize: 12),
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            const Icon(Icons.history_rounded,
                color: AppColors.onSurfaceVariant, size: 18),
          ],
        ),
      ),
    );
  }
}
