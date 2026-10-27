# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

TrinaGrid is a Flutter package providing a keyboard-navigable data grid widget. It supports multiple column types (text, number, date, time, boolean, select, currency, percentage, custom), in-place editing, filtering, sorting, pagination, and export (CSV, JSON, PDF). Works on web, desktop, and mobile. Fork/continuation of the discontinued PlutoGrid.

## Common Commands

```bash
flutter pub get                      # Install dependencies
flutter test                         # Run all tests
flutter test test/path/to_test.dart  # Run a single test file
cd example && flutter test integration_test -d windows  # Run the E2E tests in a real app window
cd example && for f in integration_test/issue_*_test.dart; do flutter test "$f" -d windows; done  # All E2E files, one at a time (a multi-file run fails to relaunch the app on Windows)
flutter test --coverage              # Run tests with coverage
dart analyze                         # Check for analysis errors
dart format .                        # Format all code
dart fix --apply                     # Apply automated fixes
```

## Workflow Rules

- **IMPORTANT: After finishing any code changes**, you MUST run `dart format` on the edited files and then run `dart analyze` to check for errors. Fix any issues found before considering the task done. Never skip this step.
- If an API or feature was changed/added, check `/doc` for relevant documentation to update, and update `/doc/index.md` if a new doc page was added.
- **Bug fixes are verified end to end.** For any bug that shows in the UI (layout, scrolling, alignment, rendering, focus, keyboard), follow `doc/contributing/e2e-testing.md`:
  1. Reproduce it first with an E2E test in `example/integration_test/issue_<n>_<topic>_test.dart`, built on `e2e_harness.dart` (real window, real input, geometry assertions, PNG screenshots). Run it with `cd example && flutter test integration_test/<file> -d windows` and confirm it fails for the reported reason.
  2. Fix, rerun, and **look at the saved screenshots** in `example/build/e2e_screenshots/` with the Read tool to validate the result visually. Revert the fix once to confirm the test fails without it.
  3. Also add a widget test in `test/`, since CI does not run the E2E tests.
  4. If the report does not reproduce on main, run the same E2E test against the reporter's release (git worktree of the release commit) before concluding.

## Git Workflow

When asked to commit & push (including via `/push`):
1. If on main, create a new branch first (never push directly to main). This overrides the "never create or switch branches" rule in the global `/push` command; do it without stopping to ask.
2. Commit the changes. Don't add `## Test plan` to commit messages.
3. Push the branch and open a PR with `gh pr create`.
4. If fixing a GitHub issue, link it in the PR so it closes on merge.
5. After pushing, switch back to main (`git switch main`) so the next task starts from there.

## Architecture

### Entry Point
- `lib/trina_grid.dart` — barrel export file re-exporting all public API (~80 exports).
- Single import: `import 'package:trina_grid/trina_grid.dart';`

### Source Layout (`lib/src/`)

**Core widgets** (top-level in `src/`):
- `trina_grid.dart` — main `TrinaGrid` widget (largest file, ~46KB)
- `trina_grid_configuration.dart` — `TrinaGridConfiguration` (~98KB, all config/style options)
- `trina_dual_grid.dart` — `TrinaDualGrid` (two linked grids side by side)
- `trina_grid_popup.dart` / `trina_dual_grid_popup.dart` — popup selection modes

**Model** (`model/`):
- `TrinaColumn`, `TrinaRow`, `TrinaCell` — core data models
- `column_types/` — typed column implementations (text, number, date, boolean, select, currency, percentage, custom)

**State Management** (`manager/`):
- `TrinaGridStateManager` — central state manager, obtained via `onLoaded` callback
- `TrinaGridEventManager` — event-based communication
- `TrinaGridKeyManager` — keyboard shortcut handling
- `state/` — modular state classes (cell, column, row, filtering, dragging, column sizing, etc.)
- `event/` — event classes for grid interactions

**UI** (`ui/`):
- `cells/`, `columns/`, `scrolls/`, `miscellaneous/`, `widgets/` — rendering components

**Plugins** (`plugin/`):
- `TrinaPagination` — client-side pagination
- `TrinaLazyPagination` — server-side pagination
- `TrinaInfinityScrollRows` — infinite scroll loading
- `TrinaAggregateColumnFooter` — column footer aggregation

**Export** (`export/`):
- CSV, JSON, PDF export implementations

**Helpers** (`helper/`):
- Row/column grouping, filtering, clipboard, date/time utilities, debouncing

### Key Patterns

- **State access**: `TrinaGridStateManager` is obtained from the `onLoaded` callback (`event.stateManager`) and used to programmatically control the grid.
- **Renderers**: Customization via `TrinaColumn.renderer` (cells), `.titleRenderer` (headers), `.footerRenderer` (footers).
- **Event-driven**: Grid interactions flow through `TrinaGridEventManager` with typed event classes.
- **Plugin architecture**: Pagination and footer aggregation are implemented as separate widget plugins.

### Test Structure (`test/`)

- `scenario/` — behavior-focused tests organized by feature (filtering, editing, dragging, configuration, etc.)
- `feature/` — integration tests (multi-select, drag selection)
- `helper/` — `trina_widget_test_helper.dart` and `test_helper_util.dart` for test setup
- `mock/` — mock data builders for columns and rows

### CLI Tool (`bin/trina_grid.dart`)

Migration tool for PlutoGrid → TrinaGrid: `flutter pub run trina_grid --migrate-from-pluto-grid`

### Analysis Config

Uses `package:flutter_lints/flutter.yaml`. Excludes `**.mocks.dart` from analysis.

### CI

- `tests.yaml` — runs `dart analyze` and `flutter test` on PRs to main
- `coverage.yml` — runs `flutter test --coverage` on push to main, uploads to codecov
