# codex.md — clickandcall

## Overview

A new Flutter project.

## Setup

```bash
pip install -e '.[dev]'
pytest
ruff check .
```

## Project Structure

- **Architecture:** monolith

**Modules:**
- `android` (42 files)
- `ios` (45 files)
- `lib` (18 files)
- `linux` (10 files)
- `macos` (30 files)
- `test` (1 files)
- `web` (7 files)
- `windows` (18 files)

## Conventions

- **Naming:** snake_case
- **File Organization:** modular
- **Import Style:** absolute
- **Patterns:** command, handler, helper, provider, service

**Examples from codebase:**
- Functions: `handle_new_rx_page`
