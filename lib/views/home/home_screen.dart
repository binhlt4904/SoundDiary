import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/entities/song.dart';
import '../../viewmodels/home_viewmodel.dart';
import '../../viewmodels/player_viewmodel.dart';
import '../../viewmodels/history_viewmodel.dart';
import '../library/now_playing_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<HomeViewModel, PlayerViewModel>(
      builder: (context, homeVm, playerVm, _) {
        return RefreshIndicator(
          color: AppColors.primary,
          backgroundColor: AppColors.surface,
          onRefresh: () async => homeVm.refresh(),
          child: ListView(
            padding: const EdgeInsets.only(bottom: 16),
            children: [
              // ── Greeting ───────────────────────────────────────────
              _buildGreeting(),

              // ── Featured Banner ────────────────────────────────────
              if (homeVm.featuredSong != null)
                _FeaturedBanner(
                  song: homeVm.featuredSong!,
                  isPlaying: playerVm.currentSong?.id == homeVm.featuredSong!.id &&
                      playerVm.isPlaying,
                  onTap: () {
                    context.read<HistoryViewModel>().addToHistory(homeVm.featuredSong!);
                    playerVm.playSong(homeVm.featuredSong!,
                        queue: homeVm.topSongs);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const NowPlayingScreen()),
                    );
                  },
                ),

              // ── Continue Listening ─────────────────────────────────
              if (homeVm.continueListening.isNotEmpty) ...[
                _SectionTitle(
                  title: 'Tiếp tục nghe',
                  icon: Icons.history_rounded,
                ),
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: homeVm.continueListening.length,
                    itemBuilder: (context, index) {
                      final song = homeVm.continueListening[index];
                      return _SmallSongCard(
                        song: song,
                        isActive: playerVm.currentSong?.id == song.id,
                        onTap: () {
                          context.read<HistoryViewModel>().addToHistory(song);
                          playerVm.playSong(song,
                              queue: homeVm.continueListening);
                        },
                      );
                    },
                  ),
                ),
              ],

              // ── Gợi ý hôm nay ─────────────────────────────────────
              _SectionTitle(
                title: 'Gợi ý hôm nay',
                icon: Icons.auto_awesome_rounded,
              ),
              SizedBox(
                height: 180,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: homeVm.suggestedSongs.length,
                  itemBuilder: (context, index) {
                    final song = homeVm.suggestedSongs[index];
                    return _SuggestedCard(
                      song: song,
                      isActive: playerVm.currentSong?.id == song.id,
                      onTap: () {
                        context.read<HistoryViewModel>().addToHistory(song);
                        playerVm.playSong(song,
                            queue: homeVm.suggestedSongs);
                      },
                    );
                  },
                ),
              ),

              // ── Top bài hát ────────────────────────────────────────
              _SectionTitle(
                title: 'Top bài hát',
                icon: Icons.trending_up_rounded,
              ),
              ...homeVm.topSongs.asMap().entries.map((entry) {
                final index = entry.key;
                final song = entry.value;
                final isActive = playerVm.currentSong?.id == song.id;
                return _TopSongTile(
                  rank: index + 1,
                  song: song,
                  isActive: isActive,
                  isPlaying: isActive && playerVm.isPlaying,
                  onTap: () {
                    context.read<HistoryViewModel>().addToHistory(song);
                    playerVm.playSong(song, queue: homeVm.topSongs);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGreeting() {
    final hour = DateTime.now().hour;
    String greeting;
    IconData icon;
    if (hour < 12) {
      greeting = 'Chào buổi sáng';
      icon = Icons.wb_sunny_rounded;
    } else if (hour < 18) {
      greeting = 'Chào buổi chiều';
      icon = Icons.wb_cloudy_rounded;
    } else {
      greeting = 'Chào buổi tối';
      icon = Icons.nights_stay_rounded;
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 22),
          const SizedBox(width: 8),
          Text(
            greeting,
            style: const TextStyle(
              color: AppColors.onBackground,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Section Title ─────────────────────────────────────────────────────────────
class _SectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionTitle({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 18),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.onBackground,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Featured Banner ───────────────────────────────────────────────────────────
class _FeaturedBanner extends StatelessWidget {
  final Song song;
  final bool isPlaying;
  final VoidCallback onTap;

  const _FeaturedBanner({
    required this.song,
    required this.isPlaying,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.25),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background image
              Image.network(
                song.albumArt,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: AppColors.surfaceVariant,
                  child: const Icon(Icons.music_note,
                      color: AppColors.primary, size: 60),
                ),
              ),
              // Gradient overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.8),
                    ],
                  ),
                ),
              ),
              // Content
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'NỔI BẬT',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              song.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              song.artist,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 52,
                        height: 52,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isPlaying
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Small Song Card (Continue Listening) ─────────────────────────────────────
class _SmallSongCard extends StatelessWidget {
  final Song song;
  final bool isActive;
  final VoidCallback onTap;

  const _SmallSongCard(
      {required this.song, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 220,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primary.withOpacity(0.15)
              : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isActive
                ? AppColors.primary.withOpacity(0.4)
                : AppColors.divider,
            width: 0.8,
          ),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(song.albumArt,
                  width: 52, height: 52, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                        width: 52,
                        height: 52,
                        color: AppColors.surfaceVariant,
                        child: const Icon(Icons.music_note,
                            color: AppColors.primary),
                      )),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(song.title,
                      style: TextStyle(
                          color: isActive
                              ? AppColors.primary
                              : AppColors.onBackground,
                          fontSize: 13,
                          fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 3),
                  Text(song.artist,
                      style: const TextStyle(
                          color: AppColors.onSurfaceVariant, fontSize: 11),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            if (isActive)
              const Icon(Icons.equalizer_rounded,
                  color: AppColors.primary, size: 18),
          ],
        ),
      ),
    );
  }
}

// ── Suggested Card ────────────────────────────────────────────────────────────
class _SuggestedCard extends StatelessWidget {
  final Song song;
  final bool isActive;
  final VoidCallback onTap;

  const _SuggestedCard(
      {required this.song, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 130,
        margin: const EdgeInsets.only(right: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.network(
                    song.albumArt,
                    width: 130,
                    height: 130,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 130,
                      height: 130,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.music_note,
                          color: AppColors.primary, size: 40),
                    ),
                  ),
                ),
                if (isActive)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black38,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.equalizer_rounded,
                          color: AppColors.primary, size: 28),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(song.title,
                style: TextStyle(
                    color: isActive
                        ? AppColors.primary
                        : AppColors.onBackground,
                    fontSize: 13,
                    fontWeight: FontWeight.w600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            Text(song.artist,
                style: const TextStyle(
                    color: AppColors.onSurfaceVariant, fontSize: 11),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}

// ── Top Song Tile ─────────────────────────────────────────────────────────────
class _TopSongTile extends StatelessWidget {
  final int rank;
  final Song song;
  final bool isActive;
  final bool isPlaying;
  final VoidCallback onTap;

  const _TopSongTile({
    required this.rank,
    required this.song,
    required this.isActive,
    required this.isPlaying,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primary.withOpacity(0.08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: isActive
              ? Border.all(color: AppColors.primary.withOpacity(0.2))
              : null,
        ),
        child: Row(
          children: [
            // Rank number
            SizedBox(
              width: 28,
              child: Text(
                '#$rank',
                style: TextStyle(
                  color: rank <= 3
                      ? AppColors.primary
                      : AppColors.onSurfaceVariant,
                  fontSize: rank <= 3 ? 15 : 13,
                  fontWeight: rank <= 3
                      ? FontWeight.w700
                      : FontWeight.w400,
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Album art
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(song.albumArt,
                  width: 48, height: 48, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                        width: 48,
                        height: 48,
                        color: AppColors.surfaceVariant,
                        child: const Icon(Icons.music_note,
                            color: AppColors.primary, size: 22),
                      )),
            ),
            const SizedBox(width: 12),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(song.title,
                      style: TextStyle(
                          color: isActive
                              ? AppColors.primary
                              : AppColors.onBackground,
                          fontSize: 14,
                          fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 3),
                  Text(song.artist,
                      style: const TextStyle(
                          color: AppColors.onSurfaceVariant, fontSize: 12),
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            // Playing indicator or duration
            if (isPlaying)
              const Icon(Icons.equalizer_rounded,
                  color: AppColors.primary, size: 20)
            else
              Text(
                _formatDuration(song.duration),
                style: const TextStyle(
                    color: AppColors.onSurfaceVariant, fontSize: 12),
              ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}
