# AI Planner

A cross-platform personal planner assistant built with Flutter. Runs on **Windows**, **Web**, **Android**, and **iOS** from a single codebase.

## Features

- ✅ **Tasks** — Create, complete, prioritize, and delete tasks with due dates
- 📅 **Calendar** — Visual monthly calendar with task markers and daily task lists
- 🤖 **AI Assistant** — Built-in planner assistant powered by Gemini (or offline mock mode)
- 📲 **Calendar Sync** — Import events from Google Calendar, Outlook, or Apple Calendar into tasks
- 💾 **Local Persistence** — Tasks are saved locally using `shared_preferences`
- 🌓 **Light/Dark Theme** — Follows system theme automatically

## Screenshots

*(Add screenshots here once you run the app)*

## Getting Started

See **[SETUP.md](SETUP.md)** for complete step-by-step instructions on cloning, running, configuring AI, building APKs, and troubleshooting.

### 1. Prerequisites

- Flutter SDK installed and in your `PATH`
- For Windows builds: **Developer Mode must be enabled** (required for plugin symlinks)
- For Android builds: Android Studio + SDK
- For iOS builds: macOS + Xcode
- For web builds: Chrome or Edge

### 2. Install dependencies

```bash
cd ai_planner
flutter pub get
```

### 3. Run the app

```bash
# Web
flutter run -d chrome

# Windows (requires Developer Mode)
flutter run -d windows

# Android
flutter run -d android

# iOS (macOS only)
flutter run -d ios
```

### 4. Build for release

```bash
# Web
flutter build web

# Windows
flutter build windows

# Android
flutter build apk

# iOS
flutter build ios
```

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/
│   └── task.dart             # Task data model
├── providers/
│   └── task_provider.dart    # State management
├── screens/
│   ├── home_screen.dart      # Bottom navigation shell
│   ├── tasks_screen.dart     # Task list
│   ├── calendar_screen.dart  # Calendar view
│   └── ai_assistant_screen.dart  # AI chat
├── services/
│   ├── storage_service.dart  # Local persistence
│   └── ai_service.dart       # AI logic (mock for MVP)
└── widgets/
    └── add_task_dialog.dart  # Add/edit task dialog
```

## Gemini AI Setup

The AI assistant can run in two modes:

1. **Offline mode** — Built-in mock responses (no API key needed)
2. **Gemini mode** — Uses Google's Gemini 1.5 Flash model (free tier: 1,500 requests/day)

To enable Gemini:

1. Go to https://aistudio.google.com/app/apikey
2. Create a free API key
3. Open the app → **Settings** tab
4. Paste your API key and tap **Save API Key**

Your API key is stored locally on your device only.

## Calendar Sync

The app can import events from external calendars and turn them into tasks.

### Mobile (Android / iOS)

Uses the device's native calendar via the `device_calendar` plugin. This covers:
- Google Calendar (synced on Android)
- Apple Calendar / iCloud (on iOS)
- Outlook / Exchange (if synced to device)

Permissions have already been configured in:
- `android/app/src/main/AndroidManifest.xml`
- `ios/Runner/Info.plist`

### Web

Uses Google Sign-In + Google Calendar API. To set this up:

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a project and enable the **Google Calendar API**
3. Create OAuth 2.0 **Web client ID**
4. Add your web origin (e.g., `http://localhost:7357` for local testing)
5. Replace `YOUR_WEB_CLIENT_ID.apps.googleusercontent.com` in:
   `lib/services/google_calendar_web_service.dart`
6. Rebuild the web app

### Windows

Windows desktop does not have a device calendar API. To support Outlook/Calendar sync on Windows, implement Microsoft Graph API integration (future enhancement).

## AI Integration

The app includes a mock AI service (`lib/services/ai_service.dart`) that runs locally without an API key.

To connect to a real AI model (OpenAI, Google Gemini, Claude, etc.):

1. Sign up for an API key
2. Update `AIService.getAIResponse()` to call the API via `http`
3. Store the API key securely (e.g., environment variables + backend proxy)

**Recommended architecture for production:**

```
App → Your Backend API → AI Provider API
```

This keeps API keys secure and lets you add features like sync, subscriptions, and analytics.

## Monetization Ideas

- **Freemium**: Free local-only planner; premium adds cloud sync, AI assistant, reminders
- **Subscription**: Monthly/annual for AI features and cross-device sync
- **Lifetime purchase**: One-time unlock
- **B2B/Teams**: Shared workspaces and team planning

## Next Steps to Make It Production-Ready

1. Enable Windows Developer Mode and test Windows build
2. Add a backend (Firebase, Supabase, or Node.js + PostgreSQL) for cloud sync
3. Replace mock AI with real API + backend proxy
4. Add push notifications for reminders
5. Add user authentication
6. Add recurring tasks and subtasks
7. Add tags, filters, and search
8. Add onboarding and settings
9. Publish to Google Play, App Store, and Microsoft Store

## License

MIT — feel free to build on it.
