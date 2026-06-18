# CLAUDE.md — clickandcall

## What Is This Project?

A new Flutter project.

## Quick Reference

- **Languages**: dart, c, swift, cpp, kotlin, shell, objective-c, python, java
- **Architecture**: monolith
- **Modules**: 8
- **Last scanned**: 2026-06-18 08:11:36.482737+00:00

## Architecture

**Type:** monolith

**Infrastructure:** Frontend

## Build & Run

```bash
# Install in dev mode
pip install -e '.[dev]'

# Run tests
pytest

# Lint
ruff check .
ruff format .
```

## Conventions

- **Naming:** snake_case
- **File Organization:** modular
- **Import Style:** absolute
- **Patterns:** command, handler, helper, provider, service

**Examples from codebase:**
- Functions: `handle_new_rx_page`

## Modules

### android
- **Path:** `android`
- **Language:** kotlin
- **Files:** 42

**Key Files:**
- `android/build.gradle.kts`
- `android/gradlew.bat`
- `android/settings.gradle.kts`
- `android/gradlew`
- `android/gradle.properties`

### ios
- **Path:** `ios`
- **Language:** swift
- **Files:** 45

**Key Files:**
- `ios/Flutter/ephemeral/flutter_lldb_helper.py` — data access
  Exports: `handle_new_rx_page`

### lib
- **Path:** `lib`
- **Language:** dart
- **Files:** 18

**Key Files:**
- `lib/globals.dart`
- `lib/service_locator.dart`
- `lib/main.dart`
- `lib/services/call_service.dart`
- `lib/services/kiosk_mode_service.dart`

### linux
- **Path:** `linux`
- **Language:** c
- **Files:** 10

**Key Files:**
- `linux/.gitignore`
- `linux/CMakeLists.txt`
- `linux/runner/my_application.cc`
- `linux/runner/main.cc`
- `linux/runner/CMakeLists.txt`

### macos
- **Path:** `macos`
- **Language:** swift
- **Files:** 30

**Key Files:**
- `macos/.gitignore`
- `macos/Runner.xcworkspace/contents.xcworkspacedata`
- `macos/RunnerTests/RunnerTests.swift`
- `macos/Runner.xcodeproj/project.pbxproj`
- `macos/Flutter/Flutter-Release.xcconfig`

### test
- **Path:** `test`
- **Language:** dart
- **Files:** 1

**Key Files:**
- `test/widget_test.dart`

### web
- **Path:** `web`
- **Files:** 7

**Key Files:**
- `web/index.html`
- `web/manifest.json`
- `web/favicon.png`
- `web/icons/Icon-192.png`
- `web/icons/Icon-512.png`

### windows
- **Path:** `windows`
- **Language:** c
- **Files:** 18

**Key Files:**
- `windows/.gitignore`
- `windows/CMakeLists.txt`
- `windows/runner/flutter_window.h`
- `windows/runner/resource.h`
- `windows/runner/win32_window.cpp`

## Key Files

- `ios/Flutter/ephemeral/flutter_lldb_helper.py` — data access
  Exports: `handle_new_rx_page`
  Imports: `lldb`

## Git Insights

- **Branch:** `master`
- **Total commits:** 1
- **Contributors:** Costaantoine

**Most Changed Files (Hotspots):**
- `.gitignore`
- `.metadata`
- `README.md`
- `analysis_options.yaml`
- `android/.gitignore`
- `android/app/build.gradle.kts`
- `android/app/src/debug/AndroidManifest.xml`
- `android/app/src/main/AndroidManifest.xml`
- `android/app/src/main/kotlin/com/example/elderly_launcher/BootReceiver.kt`
- `android/app/src/main/kotlin/com/example/elderly_launcher/MainActivity.kt`
