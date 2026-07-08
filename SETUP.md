# AI Planner — Complete Setup Guide

This document contains everything you need to clone, set up, run, and deploy the AI Planner app.

---

## Table of Contents

1. [What is AI Planner?](#what-is-ai-planner)
2. [Project Structure](#project-structure)
3. [Prerequisites](#prerequisites)
4. [Clone the Project](#clone-the-project)
5. [Flutter Setup](#flutter-setup)
6. [Install Dependencies](#install-dependencies)
7. [Run the App](#run-the-app)
   - [Web (Chrome/Edge)](#web)
   - [Windows Desktop](#windows-desktop)
   - [Android Phone](#android-phone)
8. [Enable Gemini AI](#enable-gemini-ai)
9. [Calendar Sync Setup](#calendar-sync-setup)
10. [Build Release APK](#build-release-apk)
11. [Troubleshooting](#troubleshooting)
12. [Useful Commands](#useful-commands)

---

## What is AI Planner?

AI Planner is a cross-platform personal planner assistant built with Flutter. It includes:

- ✅ Task management with priorities and due dates
- 📅 Monthly calendar with task markers
- 🤖 AI assistant powered by Google Gemini (with free offline fallback)
- 📲 Calendar sync with Google/Outlook/Apple calendars
- 💾 Local data persistence
- 🌓 Light/Dark theme

It runs on **Web**, **Windows**, **Android**, and **iOS** from a single codebase.

---

## Project Structure

```
ai_planner/
├── android/              # Android-specific files
├── ios/                  # iOS-specific files
├── web/                  # Web-specific files
├── windows/              # Windows desktop files
├── lib/
│   ├── main.dart                 # App entry point
│   ├── models/
│   │   ├── calendar_event.dart   # Calendar event model
│   │   └── task.dart             # Task model
│   ├── providers/
│   │   └── task_provider.dart    # App state management
│   ├── screens/
│   │   ├── ai_assistant_screen.dart   # AI chat
│   │   ├── calendar_screen.dart       # Calendar view
│   │   ├── calendar_sync_screen.dart  # Calendar sync
│   │   ├── home_screen.dart           # Bottom navigation
│   │   ├── settings_screen.dart       # Settings / API key
│   │   └── tasks_screen.dart          # Task list
│   ├── services/
│   │   ├── ai_service.dart                 # Offline mock AI
│   │   ├── api_key_service.dart            # API key storage
│   │   ├── calendar_service_factory.dart   # Platform sync picker
│   │   ├── calendar_sync_service.dart      # Sync interface
│   │   ├── device_calendar_service.dart    # Mobile calendar sync
│   │   ├── gemini_ai_service.dart          # Gemini AI integration
│   │   ├── google_calendar_web_service.dart # Web Google Calendar sync
│   │   └── storage_service.dart            # Local task storage
│   └── widgets/
│       └── add_task_dialog.dart    # Add/edit task dialog
├── pubspec.yaml          # Flutter dependencies
├── README.md             # Project overview
└── SETUP.md              # This file
```

---

## Prerequisites

Before you start, you need:

1. **Git** — https://git-scm.com/downloads
2. **Flutter SDK** — https://docs.flutter.dev/get-started/install
3. **A code editor** — VS Code (recommended) or Android Studio
4. **For Android:** Android Studio + Android SDK
5. **For Windows:** Visual Studio with "Desktop development with C++" workload
6. **For iOS:** macOS + Xcode (Mac only)

---

## Clone the Project

Open a terminal and run:

```bash
git clone https://github.com/sPriyank2212/ai-planner.git
cd ai-planner
```

---

## Flutter Setup

### Option A: Use your system Flutter (recommended)

If Flutter is already installed and in your PATH:

```bash
flutter --version
```

You should see Flutter 3.22.2 or higher.

### Option B: Use the local Flutter SDK (this project)

If you don't have Flutter installed globally, this project includes a local Flutter SDK at `../flutter/`:

**On Windows (Git Bash):**
```bash
export PATH="/c/Users/psoni/Documents/work_data/Ideas/flutter/bin:$PATH"
flutter --version
```

**On Windows (PowerShell):**
```powershell
$env:PATH = "C:\Users\psoni\Documents\work_data\Ideas\flutter\bin;$env:PATH"
flutter --version
```

> **Note:** The local Flutter SDK was downloaded as a zip. If it ever gets corrupted, delete the `flutter/` folder and re-download from https://docs.flutter.dev/get-started/install.

---

## Install Dependencies

Inside the `ai_planner` folder, run:

```bash
flutter pub get
```

This downloads all required packages:
- `table_calendar` — calendar UI
- `provider` — state management
- `shared_preferences` — local storage
- `google_generative_ai` — Gemini AI
- `device_calendar` — mobile calendar sync
- `google_sign_in` + `googleapis` — web calendar sync
- `uuid`, `intl`, `timezone` — utilities

---

## Run the App

### Web

The easiest way to run on this PC without any extra setup:

```bash
flutter run -d chrome
```

Or for Edge:

```bash
flutter run -d edge
```

After it builds, the app opens automatically in your browser.

**Alternative — serve the built web app:**

```bash
flutter build web
cd build/web
python -m http.server 8080
```

Then open: http://localhost:8080

### Windows Desktop

**Prerequisite:** Enable Windows Developer Mode.

1. Press `Win + R`
2. Type `ms-settings:developers` and press Enter
3. Turn **Developer Mode** ON

**Prerequisite:** Install Visual Studio with "Desktop development with C++" workload.

Then run:

```bash
flutter run -d windows
```

### Android Phone

**Prerequisite:** Install Android Studio.

1. Download Android Studio from https://developer.android.com/studio
2. Run installer and choose **Standard** setup
3. On first launch, it installs Android SDK automatically

**Configure Flutter with Android SDK:**

```bash
flutter config --android-sdk "C:/Users/psoni/AppData/Local/Android/Sdk"
flutter doctor --android-licenses
```

Accept all licenses by typing `y`.

**Enable USB debugging on your phone:**

1. Open phone **Settings**
2. Go to **About phone** → tap **Build number** 7 times
3. Go back to **System** → **Developer Options**
4. Turn ON:
   - **USB debugging**
   - **Install via USB** (if available)

**Connect your phone:**

1. Connect phone to PC with USB cable
2. Allow the RSA fingerprint on your phone
3. Verify detection:

```bash
adb devices
```

**Run the app:**

```bash
flutter run -d android
```

---

## Enable Gemini AI

The AI assistant works in two modes:

1. **Offline mode** — built-in mock responses (no setup)
2. **Gemini mode** — real AI responses from Google Gemini

### Get a free Gemini API key

1. Go to https://aistudio.google.com/app/apikey
2. Sign in with your Google account
3. Click **Create API Key**
4. Copy the key

### Add the key to the app

1. Open the app
2. Go to the **Settings** tab
3. Paste your API key
4. Tap **Save API Key**

Your key is stored **locally on your device only**.

### Free tier limits

- Gemini 1.5 Flash: **1,500 requests/day** free
- More than enough for personal use

---

## Calendar Sync Setup

### Mobile (Android/iOS)

The app uses your phone's native calendar. This covers:
- Google Calendar (on Android)
- Apple Calendar / iCloud (on iOS)
- Outlook / Exchange (if synced to your device)

**Permissions are already configured in:**
- `android/app/src/main/AndroidManifest.xml`
- `ios/Runner/Info.plist`

**To sync:**
1. Go to the **Sync** tab
2. Tap **Connect & Load Events**
3. Allow calendar permission
4. Select events and tap **Import All**

### Web

Web sync uses Google Calendar via OAuth.

**Set up Google Cloud:**

1. Go to https://console.cloud.google.com/
2. Create a new project
3. Enable the **Google Calendar API**
4. Create OAuth 2.0 **Web client ID**
5. Add authorized origins:
   - `http://localhost:7357` (for local testing)
   - Your production domain (when deployed)
6. Replace the placeholder in `lib/services/google_calendar_web_service.dart`:

```dart
static const String clientId = 'YOUR_WEB_CLIENT_ID.apps.googleusercontent.com';
```

7. Rebuild the web app

### Windows

Windows desktop does not have a device calendar API. Outlook/Calendar sync requires Microsoft Graph API integration (future enhancement).

---

## Build Release APK

To create an installable Android APK:

```bash
flutter build apk
```

The APK will be at:

```
build/app/outputs/flutter-apk/app-release.apk
```

Transfer this file to your phone and install it.

For a smaller split APK:

```bash
flutter build apk --split-per-abi
```

---

## Troubleshooting

### "Building with plugins requires symlink support"

**Fix:** Enable Windows Developer Mode.

1. Press `Win + R`
2. Type `ms-settings:developers`
3. Turn **Developer Mode** ON

### "Unable to locate Android SDK"

**Fix:** Install Android Studio or set the SDK path manually:

```bash
flutter config --android-sdk "C:/Users/YOUR_USERNAME/AppData/Local/Android/Sdk"
```

### "adb devices" shows no device

**Fix:**
1. Enable USB debugging on your phone
2. Use a good quality USB cable
3. Install phone USB drivers on your PC
4. Allow the RSA fingerprint prompt on your phone

### Flutter commands fail with "<< was unexpected"

This means the Flutter SDK folder got corrupted (likely a git merge conflict).

**Fix:**

```bash
cd /path/to/flutter
git reset --hard
git clean -fd
```

This restores Flutter to its original state. It does not affect your project.

### Web calendar sync not working

**Fix:** Make sure you replaced `YOUR_WEB_CLIENT_ID` in `lib/services/google_calendar_web_service.dart` with a real OAuth client ID from Google Cloud.

---

## Useful Commands

```bash
# Check Flutter environment
flutter doctor

# Get dependencies
flutter pub get

# Run on web
flutter run -d chrome

# Run on Windows
flutter run -d windows

# Run on Android
flutter run -d android

# Build web
flutter build web

# Build Windows
flutter build windows

# Build Android APK
flutter build apk

# Run tests
flutter test

# Analyze code
flutter analyze
```

---

## Branches

- `main` — stable version
- `gemini-integration` — adds Gemini AI + Settings screen

To switch branches:

```bash
git checkout main
git checkout gemini-integration
```

---

## Need Help?

If something doesn't work:
1. Run `flutter doctor` and fix any issues
2. Check this SETUP.md again
3. Make sure Developer Mode is enabled (Windows)
4. Verify your phone has USB debugging enabled (Android)

---

**Happy planning! 🚀**
