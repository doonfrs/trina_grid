import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trina_grid/trina_grid.dart';

import '../../helper/column_helper.dart';
import '../../helper/trina_widget_test_helper.dart';
import '../../helper/row_helper.dart';

/// Test of behavior after selecting cells
void main() {
  late TrinaGridStateManager stateManager;

  buildRowsWithSelectingCellsFunction({
    required TrinaGridSelectingMode selectingMode,
  }) {
    return ({
      int numberOfRows = 10,
      int numberOfColumns = 10,
      int columnIdx = 0,
      int rowIdx = 0,
      int columnIdxToSelect = 1,
      int rowIdxToSelect = 0,
    }) {
      // given
      final columns = ColumnHelper.textColumn('header', count: numberOfColumns);
      final rows = RowHelper.count(numberOfRows, columns);

      return TrinaWidgetTestHelper(
        'build with selecting cells.',
        (tester) async {
          await tester.pumpWidget(
            MaterialApp(
              home: Material(
                child: TrinaGrid(
                  columns: columns,
                  rows: rows,
                  onLoaded: (TrinaGridOnLoadedEvent event) {
                    stateManager = event.stateManager;
                    stateManager.setSelectingMode(selectingMode);

                    stateManager.setCurrentCell(
                      stateManager.rows[rowIdx].cells['header$columnIdx'],
                      rowIdx,
                    );

                    stateManager.setCurrentSelectingPosition(
                      cellPosition: TrinaGridCellPosition(
                        columnIdx: columnIdxToSelect,
                        rowIdx: rowIdxToSelect,
                      ),
                    );
                  },
                ),
              ),
            ),
          );

          expect(stateManager.currentCell, isNotNull);
          expect(stateManager.currentCellPosition!.columnIdx, columnIdx);
          expect(stateManager.currentCellPosition!.rowIdx, rowIdx);

          expect(stateManager.currentSelectingPosition, isNotNull);
          expect(stateManager.currentSelectingPosition!.columnIdx,
              columnIdxToSelect);
          expect(stateManager.currentSelectingPosition!.rowIdx, rowIdxToSelect);
        },
      );
    };
  }

  selectCellsFunction({
    buildRowsWithSelectingCells,
    int numberOfRows = 10,
    int numberOfColumns = 10,
    int columnIdx = 0,
    int rowIdx = 0,
    int columnIdxToSelect = 1,
    int rowIdxToSelect = 0,
  }) {
    return buildRowsWithSelectingCells(
      numberOfRows: numberOfRows,
      numberOfColumns: numberOfColumns,
      columnIdx: columnIdx,
      rowIdx: rowIdx,
      columnIdxToSelect: columnIdxToSelect,
      rowIdxToSelect: rowIdxToSelect,
    );
  }

  const TrinaGridSelectingMode selectingMode = TrinaGridSelectingMode.cell;

  final buildRowsWithSelectingCells = buildRowsWithSelectingCellsFunction(
    selectingMode: selectingMode,
  );

  group('Select cells from (0, 1) to (1, 2)', () {
    const countTotalRows = 10;
    const currentColumnIdx = 0;
    const currentRowIdx = 1;
    const columnIdxToSelect = 1;
    const rowIdxToSelect = 2;

    selectCellsFunction(
      buildRowsWithSelectingCells: buildRowsWithSelectingCells,
      numberOfRows: countTotalRows,
      columnIdx: currentColumnIdx,
      rowIdx: currentRowIdx,
      columnIdxToSelect: columnIdxToSelect,
      rowIdxToSelect: rowIdxToSelect,
    ).test(
      'When a new row is added to row 0, '
      'the selected cell should be (0, 2), (1, 3).',
      (tester) async {
        // before
        expect(stateManager.currentCellPosition!.columnIdx, currentColumnIdx);
        expect(stateManager.currentCellPosition!.rowIdx, currentRowIdx);

        expect(stateManager.currentSelectingPosition!.columnIdx,
            columnIdxToSelect);
        expect(stateManager.currentSelectingPosition!.rowIdx, rowIdxToSelect);

        final rowToInsert = stateManager.getNewRow();

        stateManager.insertRows(0, [rowToInsert]);

        // after
        expect(stateManager.currentCellPosition!.columnIdx, 0);
        expect(stateManager.currentCellPosition!.rowIdx, 2);

        expect(stateManager.currentSelectingPosition!.columnIdx, 1);
        expect(stateManager.currentSelectingPosition!.rowIdx, 3);
      },
    );

    selectCellsFunction(
      buildRowsWithSelectingCells: buildRowsWithSelectingCells,
      numberOfRows: countTotalRows,
      columnIdx: currentColumnIdx,
      rowIdx: currentRowIdx,
      columnIdxToSelect: columnIdxToSelect,
      rowIdxToSelect: rowIdxToSelect,
    ).test(
      'When row 0 is deleted, '
      'the selected cell should be (0, 0), (1, 1).',
      (tester) async {
        // before
        expect(stateManager.currentCellPosition!.columnIdx, currentColumnIdx);
        expect(stateManager.currentCellPosition!.rowIdx, currentRowIdx);

        expect(stateManager.currentSelectingPosition!.columnIdx,
            columnIdxToSelect);
        expect(stateManager.currentSelectingPosition!.rowIdx, rowIdxToSelect);

        final rowToDelete = stateManager.rows.first;

        stateManager.removeRows([rowToDelete]);

        // after
        expect(stateManager.currentCellPosition!.columnIdx, 0);
        expect(stateManager.currentCellPosition!.rowIdx, 0);

        expect(stateManager.currentSelectingPosition!.columnIdx, 1);
        expect(stateManager.currentSelectingPosition!.rowIdx, 1);
      },
    );
  });

  group('Select all cells', () {
    const countTotalRows = 10;
    const countTotalColumns = 10;
    const currentColumnIdx = 0;
    const currentRowIdx = 0;
    const columnIdxToSelect = 9;
    const rowIdxToSelect = 9;

    selectCellsFunction(
      buildRowsWithSelectingCells: buildRowsWithSelectingCells,
      numberOfRows: countTotalRows,
      numberOfColumns: countTotalColumns,
      columnIdx: currentColumnIdx,
      rowIdx: currentRowIdx,
      columnIdxToSelect: columnIdxToSelect,
      rowIdxToSelect: rowIdxToSelect,
    ).test(
      'When rows are deleted from the last row, '
      'the selected rows should be deleted one by one.',
      (tester) async {
        expect(stateManager.rows.length, 10);

        getLastRow() {
          return stateManager.rows.last;
        }

        stateManager.removeRows([getLastRow()]);
        expect(stateManager.rows.length, 9);

        stateManager.removeRows([getLastRow()]);
        expect(stateManager.rows.length, 8);
      },
    );
  });
}
