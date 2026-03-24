import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/entities/song.dart';

class SongListTile extends StatelessWidget {
  final Song song;
  final bool isPlaying;
  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;
  final Widget? trailing;

  const SongListTile({
    super.key,
    required this.song,
    required this.onTap,
    required this.onFavoriteToggle,
    this.isPlaying = false,
    this.isActive = false,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? AppColors.activeTrack : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            // Album Art
            Stack(
              alignment: Alignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    song.albumArt,
                    width: 52,
                    height: 52,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.music_note,
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ),
                  ),
                ),
                if (isActive)
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.black45,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 14),
            // Song Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    song.title,
                    style: isActive
                        ? AppTextStyles.songTitleActive
                        : AppTextStyles.songTitle,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    song.artist,
                    style: AppTextStyles.artistName,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Favorite Icon
            trailing ??
                GestureDetector(
                  onTap: onFavoriteToggle,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      song.isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: song.isFavorite
                          ? AppColors.primary
                          : AppColors.onSurfaceVariant,
                      size: 22,
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

class AppTextStyles {
  static const TextStyle songTitle = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.onBackground,
    letterSpacing: 0.1,
  );
  static const TextStyle songTitleActive = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.primary,
    letterSpacing: 0.1,
  );
  static const TextStyle artistName = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.onSurfaceVariant,
  );
}
