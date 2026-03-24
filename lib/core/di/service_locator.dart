import 'package:get_it/get_it.dart';
import '../../data/implementations/mock_music_repository.dart';
import '../../viewmodels/player_viewmodel.dart';
import '../../viewmodels/library_viewmodel.dart';
import '../../viewmodels/favorites_viewmodel.dart';
import '../../viewmodels/playlist_viewmodel.dart';

final GetIt sl = GetIt.instance;

void setupDependencies() {
  // Repository (singleton — shared state across app)
  sl.registerLazySingleton<MockMusicRepository>(() => MockMusicRepository());

  // ViewModels (singleton so state persists across tab switches)
  sl.registerLazySingleton<PlayerViewModel>(() => PlayerViewModel());
  sl.registerLazySingleton<LibraryViewModel>(
    () => LibraryViewModel(sl<MockMusicRepository>()),
  );
  sl.registerLazySingleton<FavoritesViewModel>(
    () => FavoritesViewModel(sl<MockMusicRepository>()),
  );
  sl.registerLazySingleton<PlaylistViewModel>(
    () => PlaylistViewModel(sl<MockMusicRepository>()),
  );
}
