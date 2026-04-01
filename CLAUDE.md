# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
flutter pub get        # Install dependencies
flutter run            # Run in debug mode (portrait-only)
flutter test           # Run all tests
flutter test test/path/to_test.dart  # Run a single test
flutter analyze        # Lint and static analysis
dart format lib test   # Format code
flutter build apk      # Build Android APK
```

## Architecture

**MVVM + GetIt + Provider** — clean separation across three layers:

- `domain/entities/` — plain Dart models (Song, Artist, Album, Playlist) with `copyWith()` and equality
- `data/implementations/` — currently a single `MockMusicRepository` (in-memory, no backend yet)
- `viewmodels/` — `ChangeNotifier` classes injected via GetIt, exposed to UI via `MultiProvider` in `main.dart`
- `views/` — screens consume ViewModels via `Provider.of<T>(context)`

### Dependency injection flow

`setupDependencies()` in `core/di/service_locator.dart` registers all singletons into GetIt before `runApp`. `main.dart` then wraps the app in a `MultiProvider` that pulls those same singletons out of GetIt as `ChangeNotifierProvider`s.

### Navigation

Bottom tab navigation (5 tabs) is handled by `MainShell` using `IndexedStack`. Detail screens push onto the stack with `Navigator.push`. **GoRouter is in pubspec.yaml but not yet used.**

### Player simulation

`PlayerViewModel` simulates playback progress with a `Timer` firing every 500ms — there is no real audio yet. `just_audio` and `audio_service` packages are added but unused.

### What is not yet implemented

- Real audio playback (`just_audio` / `audio_service` wired up)
- Persistent storage (`shared_preferences` present but unused)
- Upload functionality (screen and ViewModel scaffold exist)
- History tracking (ViewModel skeleton only)
- GoRouter-based deep linking
- Profile and Artist detail screens are stubs
