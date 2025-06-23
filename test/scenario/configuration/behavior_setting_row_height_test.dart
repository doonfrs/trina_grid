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
  const TrinaGridSelectingMode selectingMode =
      TrinaGridSelectingMode.rowWithSingleTap;

  TrinaGridStateManager? stateManager;

  buildRowsWithSettingRowHeight({
    int numberOfRows = 10,
    List<TrinaColumn>? columns,
    int columnIdx = 0,
    int rowIdx = 0,
    double rowHeight = 45.0,
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
          rowHeight +
              stateManager!.configuration.style.cellHorizontalBorderWidth,
        );
      },
    );
  });

  group('widget', () {
    const rowHeight = 90.0;

    buildRowsWithSettingRowHeight(rowHeight: rowHeight).test(
      'CellWidget height should be equal to the set row height',
      (tester) async {
        final Size cellSize = tester.getSize(find.byType(TrinaBaseCell).first);

        expect(cellSize.height, rowHeight);
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
      'When row height is set, select column popup cell height should be equal to the set row height',
      (tester) async {
        // Editing 상태로 설정
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        expect(stateManager!.isEditing, isTrue);

        // Call the select popup
        await tester.pumpAndSettle(const Duration(milliseconds: 300));
        await tester.sendKeyEvent(LogicalKeyboardKey.f2);
        await tester.pumpAndSettle(const Duration(milliseconds: 300));

        final popupGrid = find.byType(TrinaGrid).last;

        final Size cellPopupSize = tester.getSize(find
            .descendant(of: popupGrid, matching: find.byType(TrinaBaseCell))
            .first);

        // Check the height of the select popup
        expect(cellPopupSize.height, rowHeight);
      },
    );

    buildRowsWithSettingRowHeight(
      rowHeight: rowHeight,
      columns: ColumnHelper.dateColumn('header', count: 10),
    ).test(
      'When row height is set, date column popup cell height should be equal to the set row height',
      (tester) async {
        // Set to editing state
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        expect(stateManager!.isEditing, isTrue);

        // Call the date popup
        await tester.pumpAndSettle(const Duration(milliseconds: 300));
        await tester.sendKeyEvent(LogicalKeyboardKey.f2);
        await tester.pumpAndSettle(const Duration(milliseconds: 300));

        final sundayColumn =
            find.text(stateManager!.configuration.localeText.sunday);

        expect(
          sundayColumn,
          findsOneWidget,
        );

        // Check the height of the date popup's CellWidget
        final parent =
            find.ancestor(of: sundayColumn, matching: find.byType(TrinaGrid));

        final Size cellSize = tester.getSize(find
            .descendant(of: parent, matching: find.byType(TrinaBaseCell))
            .first);

        expect(cellSize.height, rowHeight);
      },
    );

    buildRowsWithSettingRowHeight(
      rowHeight: rowHeight,
      columns: ColumnHelper.timeColumn('header', count: 10),
    ).test(
      'When row height is set, time column popup cell height should be equal to the set row height',
      (tester) async {
        // Editing 상태로 설정
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        expect(stateManager!.isEditing, isTrue);

        // time 팝업 호출
        await tester.pumpAndSettle(const Duration(milliseconds: 300));
        await tester.sendKeyEvent(LogicalKeyboardKey.f2);
        await tester.pumpAndSettle(const Duration(milliseconds: 300));

        final hourColumn =
            find.text(stateManager!.configuration.localeText.hour);

        expect(
          hourColumn,
          findsOneWidget,
        );

        // Check the height of the time popup's CellWidget
        final parent =
            find.ancestor(of: hourColumn, matching: find.byType(TrinaGrid));

        final Size cellSize = tester.getSize(find
            .descendant(of: parent, matching: find.byType(TrinaBaseCell))
            .first);

        expect(cellSize.height, rowHeight);
      },
    );
  });
}
