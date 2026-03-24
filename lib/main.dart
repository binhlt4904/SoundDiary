import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'core/di/service_locator.dart';
import 'core/theme/app_theme.dart';
import 'viewmodels/player_viewmodel.dart';
import 'viewmodels/library_viewmodel.dart';
import 'viewmodels/favorites_viewmodel.dart';
import 'viewmodels/playlist_viewmodel.dart';
import 'views/main_shell.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set status bar style
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Color(0xFF1A1A1A),
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  setupDependencies();

  runApp(const MusicApp());
}

class MusicApp extends StatelessWidget {
  const MusicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<PlayerViewModel>(
          create: (_) => sl<PlayerViewModel>(),
        ),
        ChangeNotifierProvider<LibraryViewModel>(
          create: (_) => sl<LibraryViewModel>(),
        ),
        ChangeNotifierProvider<FavoritesViewModel>(
          create: (_) => sl<FavoritesViewModel>(),
        ),
        ChangeNotifierProvider<PlaylistViewModel>(
          create: (_) => sl<PlaylistViewModel>(),
        ),
      ],
      child: MaterialApp(
        title: 'Music App',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const MainShell(),
      ),
    );
  }
}
