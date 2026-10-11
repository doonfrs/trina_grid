# End to End Testing

Widget tests in `test/` run in a headless, fake environment: a test font, no real window, fake time, and synthetic layout sizes. Many grid bugs (scroll offsets drifting apart, misaligned columns, scrollbar overlays, focus and keyboard behavior) only show up in a real app window. The end to end (E2E) tests in `example/integration_test/` cover that gap: they run the grid in a real desktop app, drive it with real pointer and keyboard input, assert on what was rendered, and save PNG screenshots you can look at.

## Running

From the `example` folder, on a desktop machine:

```bash
cd example
flutter pub get

# One test file
flutter test integration_test/issue_402_column_alignment_test.dart -d windows

# All E2E tests
flutter test integration_test -d windows
```

Use `-d macos` or `-d linux` on those platforms. The first run builds the app, so it takes a minute; later runs reuse the build.

Screenshots are written to `example/build/e2e_screenshots/` (git ignored). The test output prints the path of each one:

```
E2E screenshot: D:\...\example\build/e2e_screenshots/402_footer_swipe.png
```

When an assertion helper fails, it saves a screenshot named `FAILED_<step>.png` and puts the path in the failure message.

These tests need a real device, so CI does not run them. Pair every E2E test with a regular widget test in `test/` that pins the same behavior, so CI still guards against regressions.

## The harness

`example/integration_test/e2e_harness.dart` holds the shared helpers:

| Helper | What it does |
|--------|--------------|
| `ensureE2EBinding()` | Initializes the integration test binding with live frames. Call it first in `main()`. |
| `pumpGridApp(tester, grid)` | Runs the grid as the whole app, under a `Scaffold`, and waits for it to settle. |
| `settle(tester)` | Waits for scroll animations, smooth scrolling timers and post frame callbacks. |
| `takeScreenshot(tester, name)` | Saves a PNG of the app and returns its path. |
| `pixelColorAt(tester, position)` | Returns the color drawn at a global position, for bugs that only show in paint. |
| `wheelScrollHorizontally` / `wheelScrollVertically` | Scrolls the body with mouse wheel events. |
| `swipeHorizontally(tester, dx:)` | Swipes the body with a finger (touch drag and fling). |
| `clickHorizontalScrollbarTrack(tester)` | Clicks the horizontal scrollbar track near its end. Needs `isAlwaysShown: true`. |
| `tapCell(tester, row:, field:)` / `findCell` | Taps or finds the rendered cell of a row and column. |
| `findMisalignedColumns(tester)` | Compares the rendered x of every header with its cells and footers. |
| `expectColumnsAligned(tester, step)` | Fails with a screenshot when any cell or footer is not under its header. |

Add new helpers to the harness when a bug needs a new kind of input or a new rendered invariant, so later tests can reuse them.

## Fixing a bug with an E2E test

1. **Reproduce first.** Write `example/integration_test/issue_<number>_<topic>_test.dart` that builds a grid shaped like the one in the report and replays the steps with real input. Run it and confirm it fails for the reason in the report. Open the failure screenshot and check that it shows the reported problem.
2. **Fix the bug** in `lib/`.
3. **Confirm the fix.** Run the E2E test again and look at the screenshots it saves. Then revert the fix locally and check that the test fails, so you know it would catch a regression.
4. **Add a widget test** in `test/` that pins the same behavior, because CI only runs `flutter test`.

If the report cannot be reproduced, run the same E2E test against the version the reporter used: check out its release commit in a git worktree, copy the test files into its `example/integration_test/`, and run them there. This tells apart "already fixed" from "not reproduced yet".

## Writing assertions

Prefer assertions on rendered geometry over pixel comparisons. Geometry is exact and does not depend on fonts, anti aliasing or the platform. For example, `findMisalignedColumns` compares `localToGlobal` positions of the header, cell and footer widgets of each column. Keep screenshots for a person to review, and look at them when a fix is visual.
