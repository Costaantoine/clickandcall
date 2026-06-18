# AGENTS.md — clickandcall

## Project Summary

A new Flutter project.

## Entry Points

_No entry points detected._

## Key Commands

```bash
pip install -e '.[dev]'  # Install
pytest                   # Test
ruff check .             # Lint
mypy src/                # Type check
```

## Conventions

- snake_case, absolute imports, modular file organization
- Patterns: command, handler, helper, provider, service

## Architecture Flow

**Type:** monolith

```
Entry
  → Modules: android, ios, lib, linux, macos
  → Frontend
```

## Modules

- `android`
- `ios`
- `lib`
- `linux`
- `macos`
- `test`
- `web`
- `windows`

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

## Build Status

See `docs/progress.md` for current implementation state.
