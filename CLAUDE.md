# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Common Commands

### Development
- `flutter run` - Run the app in debug mode
- `flutter run --release` - Run the app in release mode
- `flutter hot reload` - Hot reload changes (press `r` in terminal)
- `flutter hot restart` - Hot restart the app (press `R` in terminal)

### Dependencies
- `flutter pub get` - Install dependencies
- `flutter pub upgrade` - Upgrade dependencies

### Code Quality
- `flutter analyze` - Run static analysis
- `dart format .` - Format code
- `flutter test` - Run tests

### Build
- `flutter build apk` - Build Android APK
- `flutter build ios` - Build iOS app
- `flutter clean` - Clean build artifacts

## Architecture

This is a Flutter app for fleet management called "AT-EASE Fleet Management" using the **GetX pattern** for state management, routing, and dependency injection.

### Key Architecture Patterns
- **GetX State Management**: Controllers extend `GetxController`, observables use `.obs`
- **Modular Structure**: Features organized by modules (auth, driver, supervisor, etc.)
- **Route Management**: Centralized routing with `AppRoutes` and `AppPages`
- **Dependency Injection**: Uses GetX bindings for controller lifecycle management
- **Theme System**: Light/dark theme support with centralized colors and text styles

### Project Structure
```
lib/
├── main.dart                 # App entry point
├── app/
│   ├── core/                # Core utilities, theme, validators
│   ├── modules/             # Feature modules
│   │   ├── auth/           # Authentication (login, role selection)
│   │   ├── driver/         # Driver features (dashboard, clock, inspection)
│   │   ├── supervisor/     # Supervisor features (dashboard, reports, team)
│   │   └── common/         # Shared controllers
│   ├── routes/             # Route definitions and pages
│   ├── bindings/           # Dependency injection bindings
│   ├── translations/       # Internationalization
│   └── widgets/           # Reusable widgets
```

### State Management Pattern
- Controllers use GetX observables (`.obs`, `Rxn<T>()`)
- UI updates automatically when observables change
- Controllers are injected via bindings or `Get.lazyPut()`
- Use `Get.to()`, `Get.off()`, `Get.offAll()` for navigation

### Theme System
- Centralized theme in `AppTheme` with light/dark variants
- Colors defined in `AppColors` class
- Text styles in `AppTextStyles` class
- App uses system theme mode by default

### User Roles
The app supports two user types:
- **Driver**: Clock in/out, inspections, checklists, incidents
- **Supervisor**: Team management, reports, review tasks

### Key Dependencies
- `get: ^4.6.6` - State management, routing, DI
- `provider: ^6.1.2` - Additional state management
- `flutter_localizations` - Internationalization support
- `cupertino_icons` - iOS-style icons