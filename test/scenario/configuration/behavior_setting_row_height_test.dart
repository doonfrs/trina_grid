import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  double resolveCellHeight(TrinaGridStyleConfig style) {
    return style.enableCellBorderHorizontal
        ? style.rowHeight
        : style.rowHeight + style.cellHorizontalBorderWidth;
  }

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

    buildRowsWithSettingRowHeight(
      rowHeight: rowHeight,
      columns: [
        TrinaColumn(
            title: 'header',
            field: 'header0',
            type: TrinaColumnType.select(<String>['one', 'two', 'three'])),
      ],
    ).test(
      'When row height is set, popup-grid-cell height should be = '
      'rowHeight if `popupGrid.style.enableCellBorderHorizontal` is true, '
      'else `rowHeight + cellHorizontalBorderWidth`',
      (tester) async {
        // Set to editing state
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        expect(stateManager!.isEditing, isTrue);

        // Call the select popup
        await tester.pumpAndSettle(const Duration(milliseconds: 300));
        await tester.sendKeyEvent(LogicalKeyboardKey.f2);
        await tester.pumpAndSettle(const Duration(milliseconds: 300));

        final trinaGrids = find.byType(TrinaGrid);
        // Main grid and one popup grid
        expect(trinaGrids, findsAtLeastNWidgets(2));
        final popupGrid = trinaGrids.last;
        final popupStateManager =
            tester.state<TrinaGridState>(popupGrid).stateManager;

        final Size cellPopupSize = tester.getSize(find
            .descendant(of: popupGrid, matching: find.byType(TrinaBaseCell))
            .first);
        // assert popup grid cell height
        expect(
          cellPopupSize.height,
          resolveCellHeight(popupStateManager.style),
        );
      },
    );

    buildRowsWithSettingRowHeight(
      rowHeight: rowHeight,
      columns: ColumnHelper.dateColumn('header', count: 10),
    ).test(
      'When row height is set, date column popup cell height should equal to '
      'rowHeight if `popupGrid.style.enableCellBorderHorizontal` is true, '
      'else `rowHeight + cellHorizontalBorderWidth`',
      (tester) async {
        // Set to editing state
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        expect(stateManager!.isEditing, isTrue);

        // Call the date popup
        await tester.pumpAndSettle(const Duration(milliseconds: 300));
        await tester.sendKeyEvent(LogicalKeyboardKey.f2);
        await tester.pumpAndSettle(const Duration(milliseconds: 300));

        final trinaGrids = find.byType(TrinaGrid);
        // Main grid and one popup grid
        expect(trinaGrids, findsAtLeastNWidgets(2));

        final popupGrid = trinaGrids.last;
        final popupStateManager =
            tester.state<TrinaGridState>(popupGrid).stateManager;

        final Size cellSize = tester.getSize(find
            .descendant(of: popupGrid, matching: find.byType(TrinaBaseCell))
            .first);

        expect(
          cellSize.height,
          resolveCellHeight(popupStateManager.style),
        );
      },
    );

    buildRowsWithSettingRowHeight(
      rowHeight: rowHeight,
      columns: ColumnHelper.timeColumn('header', count: 10),
    ).test(
      'When row height is set, time column cell height should equal to '
      'rowHeight if `popupGrid.style.enableCellBorderHorizontal` is true, '
      'else `rowHeight + cellHorizontalBorderWidth`',
      (tester) async {
        // Set to editing state
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        expect(stateManager!.isEditing, isTrue);

        // Call the time popup
        await tester.pumpAndSettle(const Duration(milliseconds: 300));
        await tester.sendKeyEvent(LogicalKeyboardKey.f2);
        await tester.pumpAndSettle(const Duration(milliseconds: 300));

        final trinaGrids = find.byType(TrinaGrid);
        expect(
          trinaGrids,
          findsAtLeastNWidgets(3),
        );
        final datePopupGrid = trinaGrids.at(1);
        final timePopupGrid = trinaGrids.at(2);
        final dateGridStateManager =
            tester.state<TrinaGridState>(datePopupGrid).stateManager;
        final timeGridStateManager =
            tester.state<TrinaGridState>(timePopupGrid).stateManager;

        final dateGridCell = find
            .descendant(of: datePopupGrid, matching: find.byType(TrinaBaseCell))
            .first;
        final timeGridCell = find
            .descendant(of: timePopupGrid, matching: find.byType(TrinaBaseCell))
            .first;

        // Check the cell height in the date grid
        expect(
          tester.getSize(dateGridCell).height,
          resolveCellHeight(dateGridStateManager.style),
        );

        // Check the cell height in the time grid
        expect(
          tester.getSize(timeGridCell).height,
          resolveCellHeight(timeGridStateManager.style),
        );
      },
    );
  });
}
