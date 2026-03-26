import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../viewmodels/search_viewmodel.dart';
import '../../viewmodels/player_viewmodel.dart';
import '../../viewmodels/history_viewmodel.dart';
import '../widgets/song_list_tile.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<SearchViewModel, PlayerViewModel>(
      builder: (context, searchVm, playerVm, _) {
        return Column(
          children: [
            // ── Search Bar ─────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      onChanged: searchVm.search,
                      style: const TextStyle(color: AppColors.onBackground),
                      decoration: InputDecoration(
                        hintText: 'Tìm kiếm bài hát, nghệ sĩ...',
                        prefixIcon: const Icon(Icons.search, size: 20),
                        suffixIcon: _controller.text.isNotEmpty
                            ? GestureDetector(
                                onTap: () {
                                  _controller.clear();
                                  searchVm.clear();
                                },
                                child: const Icon(Icons.close,
                                    color: AppColors.onSurfaceVariant,
                                    size: 18),
                              )
                            : null,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // ── Results ────────────────────────────────────────────
            Expanded(
              child: !searchVm.hasSearched
                  ? _buildEmptyState()
                  : searchVm.results.isEmpty
                      ? _buildNoResults(searchVm.query)
                      : _buildResults(searchVm, playerVm, context),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_rounded,
              size: 64, color: AppColors.onSurfaceVariant.withOpacity(0.3)),
          const SizedBox(height: 16),
          const Text('Tìm kiếm bài hát hoặc nghệ sĩ',
              style: TextStyle(
                  color: AppColors.onSurfaceVariant, fontSize: 15)),
          const SizedBox(height: 8),
          const Text('Nhập tên bài hát, tên nghệ sĩ...',
              style: TextStyle(
                  color: AppColors.onSurfaceVariant, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildNoResults(String query) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.music_off_rounded,
              size: 56, color: AppColors.onSurfaceVariant.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text('Không tìm thấy "$query"',
              style: const TextStyle(
                  color: AppColors.onSurfaceVariant, fontSize: 15)),
          const SizedBox(height: 8),
          const Text('Thử tìm với từ khóa khác',
              style: TextStyle(
                  color: AppColors.onSurfaceVariant, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildResults(
    SearchViewModel searchVm,
    PlayerViewModel playerVm,
    BuildContext context,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Text(
            '${searchVm.results.length} kết quả',
            style: const TextStyle(
                color: AppColors.onSurfaceVariant, fontSize: 13),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(top: 4, bottom: 8),
            itemCount: searchVm.results.length,
            itemBuilder: (context, index) {
              final song = searchVm.results[index];
              final isActive = playerVm.currentSong?.id == song.id;
              return SongListTile(
                song: song,
                isActive: isActive,
                isPlaying: isActive && playerVm.isPlaying,
                onTap: () {
                  context.read<HistoryViewModel>().addToHistory(song);
                  playerVm.playSong(song, queue: searchVm.results);
                },
                onFavoriteToggle: () {},
              );
            },
          ),
        ),
      ],
    );
  }
}
