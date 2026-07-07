# Agent Guidelines for AI Planner

## Tech Stack

- **Framework**: Flutter 3.x with Material 3
- **Language**: Dart
- **State Management**: `provider`
- **Local Storage**: `shared_preferences`
- **Calendar**: `table_calendar`
- **Calendar Sync**: `device_calendar` (mobile), `google_sign_in` + `googleapis` (web)
- **Networking**: `http` (for future AI backend)
- **IDs**: `uuid`
- **Date Formatting**: `intl`

## Architecture

- Keep UI in `lib/screens/` and `lib/widgets/`
- Keep business logic/state in `lib/providers/`
- Keep data models in `lib/models/`
- Keep services (storage, AI, API) in `lib/services/`
- Use `ChangeNotifier` providers for reactive state

## Code Style

- Use `const` constructors where possible
- Prefer named parameters for model constructors
- Follow Flutter/Dart lints defined in `analysis_options.yaml`
- Keep widgets small and focused

## Adding Features

- New data models must include `toJson()` and `fromJson()`
- Update `TaskProvider` when adding task-related features
- Update `StorageService` if adding new local data types
- Update `AIService` for new assistant capabilities
- Update `CalendarSyncService` implementations when adding new calendar providers

## Testing

- Run `flutter test` before committing
- Run `flutter build web` to verify compilation
- Windows builds require Developer Mode for plugin symlinks

## Environment

Flutter SDK is installed locally at `../flutter/` in the parent directory.
Add to PATH before running commands:

```bash
export PATH="/c/Users/psoni/Documents/work_data/Ideas/flutter/bin:$PATH"
```
