// Shared helpers for the end to end tests in this folder.
//
// These tests run the grid in a real app window (Windows, macOS, Linux or
// Chrome), drive it with real pointer and keyboard input, assert on the
// rendered geometry, and save PNG screenshots so a human (or an agent) can look
// at what was actually drawn. See doc/contributing/e2e-testing.md.
//
// ignore_for_file: implementation_imports

import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:trina_grid/src/ui/ui.dart';
import 'package:trina_grid/trina_grid.dart';

final GlobalKey _screenshotKey = GlobalKey(debugLabel: 'e2e-screenshot');

/// Initializes the integration test binding.
///
/// Call once at the top of `main()`.
IntegrationTestWidgetsFlutterBinding ensureE2EBinding() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Pump every frame, as the real app would, instead of only the frames the
  // test asks for. Scroll physics and animations then behave like they do for
  // a user.
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  return binding;
}

/// Pumps [grid] as the whole app and waits for it to settle.
///
/// The grid gets the full window, under a [Scaffold], like a typical app.
Future<void> pumpGridApp(WidgetTester tester, Widget grid) async {
  await tester.pumpWidget(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: RepaintBoundary(
        key: _screenshotKey,
        child: Scaffold(
          body: Padding(padding: const EdgeInsets.all(8), child: grid),
        ),
      ),
    ),
  );

  await settle(tester);
}

/// Waits for scroll animations, smooth scrolling timers and post frame
/// callbacks to finish.
///
/// The smooth scroll view uses a periodic [Timer], which `pumpAndSettle` does
/// not wait for, so real time is let pass as well.
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 3; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 120)),
    );
    await tester.pumpAndSettle();
  }
}

/// Saves a PNG of the app to `build/e2e_screenshots/<name>.png` and returns
/// the absolute path.
///
/// The path is printed too, so it shows up in the test output.
Future<String> takeScreenshot(WidgetTester tester, String name) async {
  await tester.pumpAndSettle();

  final boundary =
      _screenshotKey.currentContext!.findRenderObject()!
          as RenderRepaintBoundary;

  final path = await tester.runAsync(() async {
    final ui.Image image = await boundary.toImage(
      pixelRatio: tester.view.devicePixelRatio,
    );
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();

    final dir = Directory('build/e2e_screenshots')..createSync(recursive: true);
    final file = File('${dir.path}/$name.png');
    await file.writeAsBytes(bytes!.buffer.asUint8List());

    return file.absolute.path;
  });

  // ignore: avoid_print
  print('E2E screenshot: $path');

  return path!;
}

/// Scrolls the grid body horizontally with mouse wheel events, the way a
/// user with a horizontal wheel or a trackpad does.
///
/// [delta] is applied in [steps] wheel events. Positive scrolls toward the
/// end of the row.
Future<void> wheelScrollHorizontally(
  WidgetTester tester,
  TrinaGridStateManager stateManager, {
  required double delta,
  int steps = 10,
}) async {
  final bodyCenter = _bodyCenter(tester, stateManager);
  final pointer = TestPointer(1, PointerDeviceKind.mouse);

  await tester.sendEventToBinding(pointer.hover(bodyCenter));

  for (var i = 0; i < steps; i++) {
    await tester.sendEventToBinding(pointer.scroll(Offset(delta / steps, 0)));
    await tester.pump(const Duration(milliseconds: 16));
  }

  await settle(tester);
}

/// Scrolls the grid body vertically with mouse wheel events.
Future<void> wheelScrollVertically(
  WidgetTester tester,
  TrinaGridStateManager stateManager, {
  required double delta,
  int steps = 5,
}) async {
  final bodyCenter = _bodyCenter(tester, stateManager);
  final pointer = TestPointer(1, PointerDeviceKind.mouse);

  await tester.sendEventToBinding(pointer.hover(bodyCenter));

  for (var i = 0; i < steps; i++) {
    await tester.sendEventToBinding(pointer.scroll(Offset(0, delta / steps)));
    await tester.pump(const Duration(milliseconds: 16));
  }

  await settle(tester);
}

/// Clicks the horizontal scrollbar track [fromEnd] pixels before its end,
/// which animates the grid toward the end of the row.
///
/// The scrollbar is only clickable while it is shown, so use
/// `TrinaGridScrollbarConfig(isAlwaysShown: true)`.
Future<void> clickHorizontalScrollbarTrack(
  WidgetTester tester, {
  double fromEnd = 20,
}) async {
  final rect = tester.getRect(find.byType(TrinaBodyRows));

  await tester.tapAt(
    Offset(rect.right - fromEnd, rect.bottom - 6),
    kind: PointerDeviceKind.mouse,
  );
  await settle(tester);
}

/// Swipes the grid body horizontally with a finger, [times] times.
///
/// Positive [dx] moves the content toward the end of the row, like swiping
/// left in a left to right grid.
Future<void> swipeHorizontally(
  WidgetTester tester, {
  required double dx,
  int times = 1,
}) async {
  final rect = tester.getRect(find.byType(TrinaBodyRows));
  final start = dx > 0
      ? Offset(rect.right - 100, rect.center.dy)
      : Offset(rect.left + 100, rect.center.dy);

  for (var i = 0; i < times; i++) {
    await tester.dragFrom(start, Offset(-dx, 0), kind: PointerDeviceKind.touch);
    await settle(tester);
  }
}

Offset _bodyCenter(WidgetTester tester, TrinaGridStateManager stateManager) {
  return tester.getCenter(find.byType(TrinaBodyRows));
}

/// Taps the rendered cell of [field] in [row].
Future<void> tapCell(
  WidgetTester tester, {
  required TrinaRow row,
  required String field,
}) async {
  final finder = findCell(row: row, field: field);

  expect(
    finder,
    findsOneWidget,
    reason: 'Cell "$field" of row ${row.sortIdx} is not rendered',
  );

  await tester.tap(finder);
  await settle(tester);
}

/// Finds the rendered cell of [field] in [row].
Finder findCell({required TrinaRow row, required String field}) {
  return find.byWidgetPredicate(
    (w) => w is TrinaBaseCell && w.row == row && w.column.field == field,
    description: 'cell "$field" of row ${row.sortIdx}',
  );
}

/// A misaligned column: where its header was drawn versus where its cells or
/// footer were drawn.
class Misalignment {
  Misalignment(this.field, this.part, this.headerLeft, this.partLeft);

  final String field;

  /// `cell (row n)` or `footer`.
  final String part;

  final double headerLeft;

  final double partLeft;

  double get delta => partLeft - headerLeft;

  @override
  String toString() =>
      '"$field" $part is drawn at x=${partLeft.toStringAsFixed(1)} but its '
      'header at x=${headerLeft.toStringAsFixed(1)} '
      '(off by ${delta.toStringAsFixed(1)}px)';
}

/// Returns every column whose rendered cells or footer do not start at the
/// same x as its rendered header.
///
/// Only columns that are rendered in both places are compared, since the
/// grid only builds the columns inside the viewport.
List<Misalignment> findMisalignedColumns(
  WidgetTester tester, {
  double tolerance = 0.5,
}) {
  final headerLefts = <String, double>{};

  for (final element in find.byType(TrinaBaseColumn).evaluate()) {
    final widget = element.widget as TrinaBaseColumn;
    headerLefts[widget.column.field] = _globalLeft(element);
  }

  final result = <Misalignment>[];

  void compare(String field, String part, double left) {
    final headerLeft = headerLefts[field];

    if (headerLeft == null) return;

    if ((left - headerLeft).abs() > tolerance) {
      result.add(Misalignment(field, part, headerLeft, left));
    }
  }

  for (final element in find.byType(TrinaBaseCell).evaluate()) {
    final widget = element.widget as TrinaBaseCell;
    compare(
      widget.column.field,
      'cell (row ${widget.rowIdx})',
      _globalLeft(element),
    );
  }

  for (final element in find.byType(TrinaBaseColumnFooter).evaluate()) {
    final widget = element.widget as TrinaBaseColumnFooter;
    compare(widget.column.field, 'footer', _globalLeft(element));
  }

  return result;
}

/// Fails the test, with a screenshot, when any rendered cell or footer is not
/// aligned with its header.
Future<void> expectColumnsAligned(WidgetTester tester, String step) async {
  final misaligned = findMisalignedColumns(tester);

  if (misaligned.isEmpty) return;

  final screenshot = await takeScreenshot(tester, 'FAILED_$step');

  // Report one line per column, the first row is enough to see the shift.
  final byField = <String, Misalignment>{};
  for (final m in misaligned) {
    byField.putIfAbsent('${m.field}/${m.part == 'footer'}', () => m);
  }

  fail(
    'Columns are not aligned with their headers after "$step":\n'
    '${byField.values.map((m) => '  - $m').join('\n')}\n'
    'Screenshot: $screenshot',
  );
}

double _globalLeft(Element element) {
  final box = element.renderObject! as RenderBox;
  return box.localToGlobal(Offset.zero).dx;
}
