import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import 'home/home_screen.dart';
import 'search/search_screen.dart';
import 'library/library_screen.dart';
import 'songs/all_songs_screen.dart';
import 'profile/profile_screen.dart';
import 'widgets/mini_player_widget.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    SearchScreen(),
    LibraryScreen(),
    AllSongsScreen.embedded(),
    ProfileScreen(),
  ];

  static const List<_NavItem> _navItems = [
    _NavItem(icon: Icons.home_outlined,          activeIcon: Icons.home_rounded,          label: 'Home'),
    _NavItem(icon: Icons.search_outlined,         activeIcon: Icons.search_rounded,         label: 'Tìm kiếm'),
    _NavItem(icon: Icons.folder_outlined,         activeIcon: Icons.folder_rounded,         label: 'Thư viện'),
    _NavItem(icon: Icons.library_music_outlined,  activeIcon: Icons.library_music_rounded,  label: 'Nhạc'),
    _NavItem(icon: Icons.person_outline_rounded,  activeIcon: Icons.person_rounded,         label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        titleSpacing: 16,
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.music_note_rounded,
                  color: AppColors.primary, size: 18),
            ),
            const SizedBox(width: 10),
            const Text('Music App',
                style: TextStyle(
                    color: AppColors.onBackground,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3)),
          ],
        ),
      ),
      body: Column(
        children: [
          const Divider(height: 1, thickness: 0.5),
          Expanded(
            child: IndexedStack(index: _currentIndex, children: _screens),
          ),
          const MiniPlayerWidget(),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.divider, width: 0.5)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: List.generate(_navItems.length, (index) {
              final item = _navItems[index];
              final isActive = _currentIndex == index;
              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => setState(() => _currentIndex = index),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isActive ? item.activeIcon : item.icon,
                        color: isActive
                            ? AppColors.primary
                            : AppColors.onSurfaceVariant,
                        size: 24,
                      ),
                      const SizedBox(height: 4),
                      Text(item.label,
                          style: TextStyle(
                              color: isActive
                                  ? AppColors.primary
                                  : AppColors.onSurfaceVariant,
                              fontSize: 10,
                              fontWeight: isActive
                                  ? FontWeight.w600
                                  : FontWeight.w400)),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _NavItem(
      {required this.icon, required this.activeIcon, required this.label});
}
