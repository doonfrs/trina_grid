// End to end tests for #403 (and #304): the column header must be filled
// across the whole grid width, including the band reserved for the vertical
// scrollbar at the end of the header and the space after the last column.
//
// The header and body reserve a trailing band for the overlaid vertical
// scrollbar, so both share one scroll extent and stay aligned (#301, #402).
// No column paints that band, so it showed the grid background next to
// colored column titles. TrinaGridStyleConfig.columnBackgroundColor fills it.
//
// Run with:
//   cd example
//   flutter test integration_test/issue_403_column_header_fill_test.dart -d windows

// ignore_for_file: implementation_imports

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trina_grid/src/ui/ui.dart';
import 'package:trina_grid/trina_grid.dart';

import 'e2e_harness.dart';

const headerColor = Color(0xFFBBDEFB);

void main() {
  ensureE2EBinding();

  late TrinaGridStateManager stateManager;

  /// A grid shaped like the one in the report: colored column titles, a
  /// rounded grid border, no vertical cell borders and enough rows for the
  /// vertical scrollbar.
  Widget buildGrid({
    required int columnCount,
    double columnWidth = 150,
    TrinaAutoSizeMode autoSizeMode = TrinaAutoSizeMode.none,
    Color? columnBackgroundColor = headerColor,
  }) {
    final columns = [
      for (var i = 0; i < columnCount; i++)
        TrinaColumn(
          title: 'Column $i',
          field: 'c$i',
          type: TrinaColumnType.text(),
          width: columnWidth,
          backgroundColor: headerColor,
        ),
    ];

    final rows = List.generate(80, (r) {
      return TrinaRow(
        cells: {
          for (var i = 0; i < columnCount; i++)
            'c$i': TrinaCell(value: 'R${r + 1} C$i'),
        },
      );
    });

    return TrinaGrid(
      columns: columns,
      rows: rows,
      configuration: TrinaGridConfiguration(
        style: TrinaGridStyleConfig(
          gridBorderRadius: BorderRadius.circular(8),
          enableCellBorderVertical: false,
          columnBackgroundColor: columnBackgroundColor,
        ),
        columnSize: TrinaGridColumnSizeConfig(autoSizeMode: autoSizeMode),
      ),
      onLoaded: (event) => stateManager = event.stateManager,
    );
  }

  /// The middle of the band reserved for the vertical scrollbar at the end of
  /// the column titles.
  Offset scrollbarBandInHeader(WidgetTester tester) {
    final header = tester.getRect(find.byType(TrinaBodyColumns));
    final band = stateManager.configuration.scrollbar.effectiveThickness;

    return Offset(
      header.right - band / 2,
      header.top + stateManager.columnHeight / 2,
    );
  }

  Future<void> expectHeaderFilledAt(
    WidgetTester tester,
    Offset position,
    Color expected,
    String step,
  ) async {
    final actual = await pixelColorAt(tester, position);

    if (actual.toARGB32() == expected.toARGB32()) return;

    final screenshot = await takeScreenshot(tester, 'FAILED_$step');

    fail(
      'The header at $position should be drawn in '
      '0x${expected.toARGB32().toRadixString(16)} after "$step", but it is '
      '0x${actual.toARGB32().toRadixString(16)}.\n'
      'Screenshot: $screenshot',
    );
  }

  testWidgets('columns fitted to the grid: the scrollbar band is filled', (
    tester,
  ) async {
    await pumpGridApp(
      tester,
      buildGrid(columnCount: 8, autoSizeMode: TrinaAutoSizeMode.scale),
    );

    await expectHeaderFilledAt(
      tester,
      scrollbarBandInHeader(tester),
      headerColor,
      '403_fitted',
    );

    await takeScreenshot(tester, '403_fitted');
  });

  testWidgets('wide grid scrolled to the end: the scrollbar band is filled', (
    tester,
  ) async {
    await pumpGridApp(tester, buildGrid(columnCount: 20));

    await wheelScrollHorizontally(tester, stateManager, delta: 5000);
    expect(
      stateManager.scroll.horizontalOffset,
      closeTo(stateManager.scroll.maxScrollHorizontal, 1),
    );

    await expectHeaderFilledAt(
      tester,
      scrollbarBandInHeader(tester),
      headerColor,
      '403_scrolled_to_end',
    );
    await expectColumnsAligned(tester, '403_scrolled_to_end');

    await takeScreenshot(tester, '403_scrolled_to_end');
  });

  testWidgets('columns narrower than the grid: the space after them is '
      'filled (#304)', (tester) async {
    await pumpGridApp(tester, buildGrid(columnCount: 3));

    final grid = tester.getRect(find.byType(TrinaGrid));
    final header = tester.getRect(find.byType(TrinaBodyColumns));

    expect(
      header.right,
      lessThan(grid.right - 100),
      reason: 'The columns should end well before the grid',
    );

    await expectHeaderFilledAt(
      tester,
      Offset(grid.right - 50, header.top + stateManager.columnHeight / 2),
      headerColor,
      '304_gap',
    );

    await takeScreenshot(tester, '304_gap');
  });

  testWidgets('without columnBackgroundColor the header is not filled', (
    tester,
  ) async {
    await pumpGridApp(
      tester,
      buildGrid(
        columnCount: 8,
        autoSizeMode: TrinaAutoSizeMode.scale,
        columnBackgroundColor: null,
      ),
    );

    await expectHeaderFilledAt(
      tester,
      scrollbarBandInHeader(tester),
      stateManager.style.gridBackgroundColor,
      '403_default',
    );
  });
}
