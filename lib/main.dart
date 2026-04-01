import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/di/service_locator.dart';
import 'core/theme/app_theme.dart';
import 'core/supabase/supabase_config.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/player_viewmodel.dart';
import 'viewmodels/library_viewmodel.dart';
import 'viewmodels/favorites_viewmodel.dart';
import 'viewmodels/playlist_viewmodel.dart';
import 'viewmodels/history_viewmodel.dart';
import 'viewmodels/home_viewmodel.dart';
import 'viewmodels/search_viewmodel.dart';
import 'viewmodels/artist_viewmodel.dart';
import 'views/main_shell.dart';
import 'views/auth/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    anonKey: SupabaseConfig.supabaseAnonKey,
  );

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
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
        ChangeNotifierProvider<AuthViewModel>(
            create: (_) => sl<AuthViewModel>()),
        ChangeNotifierProvider<PlayerViewModel>(
            create: (_) => sl<PlayerViewModel>()),
        ChangeNotifierProvider<LibraryViewModel>(
            create: (_) => sl<LibraryViewModel>()),
        ChangeNotifierProvider<FavoritesViewModel>(
            create: (_) => sl<FavoritesViewModel>()),
        ChangeNotifierProvider<PlaylistViewModel>(
            create: (_) => sl<PlaylistViewModel>()),
        ChangeNotifierProvider<HistoryViewModel>(
            create: (_) => sl<HistoryViewModel>()),
        ChangeNotifierProvider<HomeViewModel>(
            create: (_) => sl<HomeViewModel>()),
        ChangeNotifierProvider<SearchViewModel>(
            create: (_) => sl<SearchViewModel>()),
        ChangeNotifierProvider<ArtistViewModel>(
            create: (_) => sl<ArtistViewModel>()),
      ],
      child: MaterialApp(
        title: 'Sound Diary',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const _AuthGate(),
      ),
    );
  }
}

class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthViewModel>();

    if (auth.isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0D0D0D),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF7C5CBF)),
        ),
      );
    }

    return auth.isLoggedIn ? const MainShell() : const LoginScreen();
  }
}
