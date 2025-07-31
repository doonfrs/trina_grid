import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trina_grid/trina_grid.dart';
import 'package:trina_grid/src/ui/ui.dart';

import '../../helper/column_helper.dart';
import '../../helper/trina_widget_test_helper.dart';
import '../../helper/row_helper.dart';

/// Row height setting behavior test
void main() {
  const TrinaGridSelectingMode selectingMode = TrinaGridSelectingMode.row;

  TrinaGridStateManager? stateManager;

  buildRowsWithSettingRowHeight({
    int numberOfRows = 10,
    List<TrinaColumn>? columns,
    int columnIdx = 0,
    int rowIdx = 0,
    double rowHeight = 45.0,
    bool enableCellBorderHorizontal = true,
  }) {
    // given
    final safetyColumns =
        columns ?? ColumnHelper.textColumn('header', count: 10);
    final rows = RowHelper.count(numberOfRows, safetyColumns);

    return TrinaWidgetTestHelper(
      'build with setting row height.',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Material(
              child: TrinaGrid(
                columns: safetyColumns,
                rows: rows,
                onLoaded: (TrinaGridOnLoadedEvent event) {
                  stateManager = event.stateManager;
                  stateManager!.setSelectingMode(selectingMode);

                  stateManager!.setCurrentCell(
                    stateManager!.rows[rowIdx].cells['header$columnIdx'],
                    rowIdx,
                  );
                },
                configuration: TrinaGridConfiguration(
                  style: TrinaGridStyleConfig(
                    rowHeight: rowHeight,
                    enableCellBorderHorizontal: enableCellBorderHorizontal,
                  ),
                ),
              ),
            ),
          ),
        );

        expect(stateManager!.currentCell, isNotNull);
        expect(stateManager!.currentCellPosition!.columnIdx, columnIdx);
        expect(stateManager!.currentCellPosition!.rowIdx, rowIdx);
      },
    );
  }

  group('state', () {
    const rowHeight = 90.0;

    buildRowsWithSettingRowHeight(rowHeight: rowHeight).test(
      'When rowHeight is set to 90, rowTotalHeight should be 90 + cellHorizontalBorderWidth',
      (tester) async {
        expect(
          stateManager!.rowTotalHeight,
          rowHeight + stateManager!.style.cellHorizontalBorderWidth,
        );
      },
    );
  });
  group('widget', () {
    const rowHeight = 90.0;

    buildRowsWithSettingRowHeight(rowHeight: rowHeight).test(
      'When enableCellBorderHorizontal is true, cell height should be equal to the set row height',
      (tester) async {
        final Size cellSize = tester.getSize(find.byType(TrinaBaseCell).first);

        expect(cellSize.height, rowHeight);
      },
    );
    buildRowsWithSettingRowHeight(
      rowHeight: rowHeight,
      enableCellBorderHorizontal: false,
    ).test(
      'When enableCellBorderHorizontal is false, cell height should be equal to `rowTotalHeight`',
      (tester) async {
        final Size cellSize = tester.getSize(find.byType(TrinaBaseCell).first);

        expect(cellSize.height, stateManager!.rowTotalHeight);
      },
    );
  });
}
