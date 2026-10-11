// End to end tests for #402: after scrolling toward the end of a wide grid
// with hidden columns, the cells and footers must stay aligned with their
// column headers.
//
// The column footers used to scroll one scrollbar width short of the header
// and body when the grid was scrolled to the end by an animated or dragged
// scroll (scrollbar track click, touch swipe), because they lacked the
// trailing padding the header and body reserve for the vertical scrollbar.
//
// Run with:
//   cd example
//   flutter test integration_test/issue_402_column_alignment_test.dart -d windows

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trina_grid/trina_grid.dart';

import 'e2e_harness.dart';

void main() {
  ensureE2EBinding();

  late TrinaGridStateManager stateManager;
  late List<TrinaColumn> columns;
  late List<TrinaRow> rows;

  /// A grid shaped like the one in the report: a frozen row number and
  /// checkbox column, many data columns with some of them hidden, the filter
  /// row, boxed cell renderers, rows of mixed height and pagination.
  Widget buildGrid({bool withFooter = false}) {
    columns = [
      TrinaColumn(
        title: '#',
        field: 'no',
        type: TrinaColumnType.number(),
        frozen: TrinaColumnFrozen.start,
        width: 50,
        enableContextMenu: false,
        enableSorting: false,
      ),
      TrinaColumn(
        title: '',
        field: 'check',
        type: TrinaColumnType.text(),
        frozen: TrinaColumnFrozen.start,
        width: 70,
        enableRowChecked: true,
        enableContextMenu: false,
        enableSorting: false,
      ),
      for (var i = 0; i < 24; i++)
        TrinaColumn(
          title: 'Column $i',
          field: 'c$i',
          type: i.isEven ? TrinaColumnType.text() : TrinaColumnType.number(),
          width: 140 + (i % 3) * 20,
          // Hide a few columns spread across the row, like the report.
          hide: const {3, 7, 12, 18}.contains(i),
          renderer: i % 4 == 1
              ? (ctx) => Container(
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black26),
                  ),
                  child: Text(ctx.cell.value.toString()),
                )
              : null,
          footerRenderer: withFooter
              ? (ctx) => TrinaAggregateColumnFooter(
                  rendererContext: ctx,
                  type: TrinaAggregateColumnType.count,
                  alignment: Alignment.center,
                )
              : null,
        ),
    ];

    rows = List.generate(60, (r) {
      return TrinaRow(
        // Mixed heights, like the taller rows in the report.
        height: r % 5 == 3 ? 70 : null,
        cells: {
          'no': TrinaCell(value: r + 1),
          'check': TrinaCell(value: ''),
          for (var i = 0; i < 24; i++)
            'c$i': TrinaCell(value: i.isEven ? 'R${r + 1} C$i' : r * 100 + i),
        },
      );
    });

    return TrinaGrid(
      columns: columns,
      rows: rows,
      configuration: const TrinaGridConfiguration(
        scrollbar: TrinaGridScrollbarConfig(isAlwaysShown: true),
      ),
      onLoaded: (event) {
        stateManager = event.stateManager;
        stateManager.setShowColumnFilter(true);
      },
      createFooter: (sm) {
        sm.setPageSize(30, notify: false);
        return TrinaPagination(sm);
      },
    );
  }

  void expectScrolledToEnd() {
    expect(
      stateManager.scroll.horizontalOffset,
      closeTo(stateManager.scroll.maxScrollHorizontal, 1),
      reason: 'The grid should be scrolled to the end of the row',
    );
  }

  group('column footers', () {
    testWidgets('scrollbar track click to the end', (tester) async {
      await pumpGridApp(tester, buildGrid(withFooter: true));
      await expectColumnsAligned(tester, '402_footer_initial');

      await clickHorizontalScrollbarTrack(tester);
      expectScrolledToEnd();
      await expectColumnsAligned(tester, '402_footer_track_click');

      await tapCell(tester, row: rows[2], field: 'c21');
      await expectColumnsAligned(tester, '402_footer_track_click_tap');

      await takeScreenshot(tester, '402_footer_track_click_tap');
    });

    testWidgets('touch swipe to the end', (tester) async {
      await pumpGridApp(tester, buildGrid(withFooter: true));

      await swipeHorizontally(tester, dx: 900, times: 4);
      expectScrolledToEnd();
      await expectColumnsAligned(tester, '402_footer_swipe');

      await takeScreenshot(tester, '402_footer_swipe');
    });

    testWidgets('mouse wheel to the end', (tester) async {
      await pumpGridApp(tester, buildGrid(withFooter: true));

      await wheelScrollHorizontally(tester, stateManager, delta: 5000);
      expectScrolledToEnd();
      await expectColumnsAligned(tester, '402_footer_wheel');
    });
  });

  group('cells', () {
    testWidgets('wheel to the end, then select a cell', (tester) async {
      await pumpGridApp(tester, buildGrid());
      await expectColumnsAligned(tester, '402_initial');

      await wheelScrollHorizontally(tester, stateManager, delta: 5000);
      expectScrolledToEnd();
      await expectColumnsAligned(tester, '402_wheel_end');

      await tapCell(tester, row: rows[2], field: 'c21');
      await expectColumnsAligned(tester, '402_wheel_end_tap');

      await takeScreenshot(tester, '402_wheel_end_tap');
    });

    testWidgets('scroll down, swipe to the end, then select a cell', (
      tester,
    ) async {
      await pumpGridApp(tester, buildGrid());

      await wheelScrollVertically(tester, stateManager, delta: 400);
      await swipeHorizontally(tester, dx: 900, times: 4);
      expectScrolledToEnd();

      await tapCell(tester, row: rows[12], field: 'c22');
      await expectColumnsAligned(tester, '402_scrolled_down_tap');
    });

    testWidgets('arrow keys to the last column', (tester) async {
      await pumpGridApp(tester, buildGrid());

      await tapCell(tester, row: rows[2], field: 'c0');

      for (var i = 0; i < 30; i++) {
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
        await tester.pump(const Duration(milliseconds: 16));
      }
      await settle(tester);

      expectScrolledToEnd();
      await expectColumnsAligned(tester, '402_arrow_end');
    });

    testWidgets('hide and show a column while scrolled to the end', (
      tester,
    ) async {
      await pumpGridApp(tester, buildGrid());
      await wheelScrollHorizontally(tester, stateManager, delta: 5000);

      final column = columns.firstWhere((c) => c.field == 'c20');

      stateManager.hideColumn(column, true);
      await settle(tester);
      await expectColumnsAligned(tester, '402_hide_at_end');

      await tapCell(tester, row: rows[2], field: 'c22');
      await expectColumnsAligned(tester, '402_hide_at_end_tap');

      stateManager.hideColumn(column, false);
      await settle(tester);
      await expectColumnsAligned(tester, '402_show_at_end');
    });
  });
}
