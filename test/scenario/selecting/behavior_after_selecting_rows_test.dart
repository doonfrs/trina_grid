import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trina_grid/trina_grid.dart';

import '../../helper/column_helper.dart';
import '../../helper/trina_widget_test_helper.dart';
import '../../helper/row_helper.dart';

/// Test of behavior after selecting rows
void main() {
  const TrinaGridSelectingMode selectingMode =
      TrinaGridSelectingMode.rowWithSingleTap;

  TrinaGridStateManager? stateManager;

  buildRowsWithSelectingRows({
    int numberOfRows = 10,
    int from = 0,
    int to = 0,
  }) {
    // given
    final columns = ColumnHelper.textColumn('header');
    final rows = RowHelper.count(numberOfRows, columns);

    return TrinaWidgetTestHelper(
      'build with selecting rows.',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Material(
              child: TrinaGrid(
                columns: columns,
                rows: rows,
                onLoaded: (TrinaGridOnLoadedEvent event) {
                  stateManager = event.stateManager;
                  stateManager!.setSelectingMode(selectingMode);
                  stateManager!.setCurrentSelectingRowsByRange(from, to);
                },
              ),
            ),
          ),
        );

        final selectingRows = stateManager!.currentSelectingRows;

        final int length = (from - to).abs() + 1;

        expect(selectingRows.length, length);
      },
    );
  }

  group(
    'Select 3 rows from 1 to 3',
    () {
      const countTotalRows = 10;
      const countSelectedRows = 3;
      const from = 1;
      const to = 3;

      selectRowsFrom1To3() {
        return buildRowsWithSelectingRows(
          numberOfRows: countTotalRows,
          from: from,
          to: to,
        );
      }

      selectRowsFrom1To3().test(
        'When row 0 is deleted, '
        'rows 0 ~ 2 should be selected.',
        (tester) async {
          final rowToRemove = stateManager!.rows.first;

          stateManager!.removeRows([rowToRemove]);

          final selectedRows = stateManager!.currentSelectingRows;
          final selectedRowKeys = selectedRows.map((e) => e.key);

          expect(selectedRows.length, countSelectedRows);
          expect(selectedRowKeys.contains(stateManager!.rows[0].key), isTrue);
          expect(selectedRowKeys.contains(stateManager!.rows[1].key), isTrue);
          expect(selectedRowKeys.contains(stateManager!.rows[2].key), isTrue);
        },
      );

      selectRowsFrom1To3().test(
        'When a new row is added to row 0, '
        '2 ~ 4 rows should be selected.',
        (tester) async {
          final rowToRemove = stateManager!.rows.first;

          stateManager!.insertRows(1, [rowToRemove]);

          expect(stateManager!.rows.length, countTotalRows + 1);

          final selectedRows = stateManager!.currentSelectingRows;
          final selectedRowKeys = selectedRows.map((e) => e.key);

          expect(selectedRows.length, countSelectedRows);
          expect(selectedRowKeys.contains(stateManager!.rows[2].key), isTrue);
          expect(selectedRowKeys.contains(stateManager!.rows[3].key), isTrue);
          expect(selectedRowKeys.contains(stateManager!.rows[4].key), isTrue);
        },
      );
    },
  );
}
