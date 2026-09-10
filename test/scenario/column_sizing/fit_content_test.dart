import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trina_grid/trina_grid.dart';

import '../../helper/test_helper_util.dart';

/// End-to-end coverage for [TrinaAutoSizeMode.fitContent]: the sizing itself
/// runs inside the grid's layout pass, and the refit runs when rows arrive.
void main() {
  List<TrinaColumn> buildColumns() {
    return ['short', 'long'].map((field) {
      return TrinaColumn(
        title: field,
        field: field,
        // Wide enough to swallow the fit if it were used as the floor, which is
        // the shape real grids have.
        minWidth: 300,
        width: 300,
        type: TrinaColumnType.text(),
      );
    }).toList();
  }

  TrinaRow row(String short, String long) {
    return TrinaRow(
      cells: {
        'short': TrinaCell(value: short),
        'long': TrinaCell(value: long),
      },
    );
  }

  Widget buildGrid({
    required List<TrinaColumn> columns,
    required List<TrinaRow> rows,
    required TrinaGridConfiguration configuration,
    void Function(TrinaGridOnLoadedEvent)? onLoaded,
  }) {
    return MaterialApp(
      home: Material(
        child: TrinaGrid(
          columns: columns,
          rows: rows,
          configuration: configuration,
          onLoaded: onLoaded,
        ),
      ),
    );
  }

  const fitContent = TrinaGridConfiguration(
    columnSize: TrinaGridColumnSizeConfig(
      autoSizeMode: TrinaAutoSizeMode.fitContent,
      minFitContentWidth: 40,
    ),
  );

  testWidgets(
    'When a column holds much wider values than its neighbour, it should end '
    'up wider',
    (tester) async {
      await TestHelperUtil.changeWidth(
        tester: tester,
        width: 1200,
        height: 600,
      );

      final columns = buildColumns();

      await tester.pumpWidget(
        buildGrid(
          columns: columns,
          rows: [
            row('a', 'a value that is considerably longer than its neighbour'),
            row('b', 'another notably long value in the very same column'),
          ],
          configuration: fitContent,
        ),
      );
      await tester.pumpAndSettle();

      expect(columns[1].width, greaterThan(columns[0].width));
    },
  );

  testWidgets(
    'When the content is narrower than the grid, the columns should fill its '
    'width',
    (tester) async {
      await TestHelperUtil.changeWidth(
        tester: tester,
        width: 1200,
        height: 600,
      );

      final columns = buildColumns();

      await tester.pumpWidget(
        buildGrid(
          columns: columns,
          rows: [row('a', 'b')],
          configuration: fitContent,
        ),
      );
      await tester.pumpAndSettle();

      final total = columns.fold<double>(0, (sum, c) => sum + c.width);
      // Allowance for the scrollbar strip the sizing pass subtracts.
      expect(total, greaterThan(1200 - 40));
      expect(total, lessThanOrEqualTo(1200));
    },
  );

  testWidgets(
    'When rows are replaced, the columns should refit to the new values',
    (tester) async {
      await TestHelperUtil.changeWidth(
        tester: tester,
        width: 1200,
        height: 600,
      );

      final columns = buildColumns();
      late TrinaGridStateManager stateManager;

      await tester.pumpWidget(
        buildGrid(
          columns: columns,
          rows: [row('a', 'b')],
          configuration: fitContent,
          onLoaded: (event) => stateManager = event.stateManager,
        ),
      );
      await tester.pumpAndSettle();

      final before = columns[1].width;

      // What lazy pagination does when it moves to another page.
      stateManager.refRows.clearFromOriginal();
      stateManager.insertRows(0, [
        row('a', 'a value far wider than anything the first page held here'),
      ]);
      await tester.pumpAndSettle();

      expect(columns[1].width, greaterThan(before));
    },
  );

  testWidgets(
    'When refitOnRowsChanged is off, replacing the rows should leave the '
    'widths alone',
    (tester) async {
      await TestHelperUtil.changeWidth(
        tester: tester,
        width: 1200,
        height: 600,
      );

      final columns = buildColumns();
      late TrinaGridStateManager stateManager;

      await tester.pumpWidget(
        buildGrid(
          columns: columns,
          rows: [row('a', 'b')],
          configuration: const TrinaGridConfiguration(
            columnSize: TrinaGridColumnSizeConfig(
              autoSizeMode: TrinaAutoSizeMode.fitContent,
              minFitContentWidth: 40,
              refitOnRowsChanged: false,
            ),
          ),
          onLoaded: (event) => stateManager = event.stateManager,
        ),
      );
      await tester.pumpAndSettle();

      final before = columns[1].width;

      stateManager.refRows.clearFromOriginal();
      stateManager.insertRows(0, [
        row('a', 'a value far wider than anything the first page held here'),
      ]);
      await tester.pumpAndSettle();

      expect(columns[1].width, before);
    },
  );

  testWidgets(
    'When the filter row is shown, a column of short values should still be '
    'wide enough for its filter placeholder and buttons',
    (tester) async {
      // Narrow on purpose: the filler column below overflows it, so there is
      // no leftover width to share. Otherwise the sharing widens the EAN
      // column regardless and the fit itself goes untested.
      await TestHelperUtil.changeWidth(tester: tester, width: 400, height: 600);

      // Short title, short values: without counting the filter this fits to
      // roughly the width of the word "null" and leaves the filter below it
      // with room for about one character.
      final columns = [
        TrinaColumn(
          title: 'EAN',
          field: 'ean',
          width: 300,
          minWidth: 300,
          type: TrinaColumnType.text(),
          filterWidgetDelegate:
              const TrinaFilterColumnWidgetDelegate.multiItems(),
        ),
        TrinaColumn(
          title: 'filler',
          field: 'filler',
          width: 300,
          minWidth: 300,
          type: TrinaColumnType.text(),
        ),
      ];

      late TrinaGridStateManager stateManager;

      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: TrinaGrid(
              columns: columns,
              rows: [
                TrinaRow(
                  cells: {
                    'ean': TrinaCell(value: 'null'),
                    // Far wider than the grid on its own, so the fitted total
                    // overflows and nothing is shared back to the EAN column.
                    'filler': TrinaCell(
                      value:
                          'a value long enough on its own to overflow the '
                          'whole grid several times over, so that the fitted '
                          'widths leave nothing at all to share out',
                    ),
                  },
                ),
              ],
              configuration: fitContent,
              onLoaded: (event) {
                stateManager = event.stateManager;
                event.stateManager.setShowColumnFilter(true);
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(stateManager.showColumnFilter, isTrue);

      // Fitting the title and the value alone lands near 96, which leaves the
      // filter's two 30px buttons almost no room for the placeholder. Counting
      // the filter puts it well past that.
      expect(columns[0].width, greaterThan(120));
    },
  );

  testWidgets(
    'A suppressed column should keep its width while the others are fitted',
    (tester) async {
      await TestHelperUtil.changeWidth(
        tester: tester,
        width: 1200,
        height: 600,
      );

      final columns = [
        TrinaColumn(
          title: 'kept',
          field: 'kept',
          width: 300,
          minWidth: 300,
          suppressedAutoSize: true,
          type: TrinaColumnType.text(),
        ),
        TrinaColumn(
          title: 'fitted',
          field: 'fitted',
          width: 300,
          minWidth: 300,
          type: TrinaColumnType.text(),
        ),
      ];

      await tester.pumpWidget(
        buildGrid(
          columns: columns,
          rows: [
            TrinaRow(
              cells: {
                'kept': TrinaCell(value: 'a'),
                'fitted': TrinaCell(value: 'b'),
              },
            ),
          ],
          configuration: fitContent,
        ),
      );
      await tester.pumpAndSettle();

      expect(columns[0].width, 300);
    },
  );
}
