import 'package:get_it/get_it.dart';
import '../../data/implementations/mock_music_repository.dart';
import '../../viewmodels/player_viewmodel.dart';
import '../../viewmodels/library_viewmodel.dart';
import '../../viewmodels/favorites_viewmodel.dart';
import '../../viewmodels/playlist_viewmodel.dart';
import '../../viewmodels/history_viewmodel.dart';
import '../../viewmodels/home_viewmodel.dart';
import '../../viewmodels/search_viewmodel.dart';

final GetIt sl = GetIt.instance;

void setupDependencies() {
  sl.registerLazySingleton<MockMusicRepository>(() => MockMusicRepository());
  sl.registerLazySingleton<PlayerViewModel>(() => PlayerViewModel());
  sl.registerLazySingleton<HistoryViewModel>(() => HistoryViewModel());
  sl.registerLazySingleton<LibraryViewModel>(
          () => LibraryViewModel(sl<MockMusicRepository>()));
  sl.registerLazySingleton<FavoritesViewModel>(
          () => FavoritesViewModel(sl<MockMusicRepository>()));
  sl.registerLazySingleton<PlaylistViewModel>(
          () => PlaylistViewModel(sl<MockMusicRepository>()));
  sl.registerLazySingleton<HomeViewModel>(
          () => HomeViewModel(sl<MockMusicRepository>(), sl<HistoryViewModel>()));
  sl.registerLazySingleton<SearchViewModel>(
          () => SearchViewModel(sl<MockMusicRepository>()));
}
