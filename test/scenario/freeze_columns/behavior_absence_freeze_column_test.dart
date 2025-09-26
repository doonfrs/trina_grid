import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trina_grid/trina_grid.dart';

import '../../helper/column_helper.dart';
import '../../helper/trina_widget_test_helper.dart';
import '../../helper/row_helper.dart';
import '../../helper/test_helper_util.dart';

void main() {
  group('Without frozen columns', () {
    List<TrinaColumn> columns;

    List<TrinaRow> rows;

    TrinaGridStateManager? stateManager;

    final toLeftColumn1 = TrinaWidgetTestHelper(
      'Select a cell in column 1 and freeze column 1 to the left',
      (tester) async {
        await TestHelperUtil.changeWidth(
          tester: tester,
          width: 1920,
          height: 1080,
        );

        columns = [...ColumnHelper.textColumn('header', count: 10)];

        rows = RowHelper.count(10, columns);

        await tester.pumpWidget(
          MaterialApp(
            home: Material(
              child: TrinaGrid(
                columns: columns,
                rows: rows,
                onLoaded: (TrinaGridOnLoadedEvent event) {
                  stateManager = event.stateManager;
                },
              ),
            ),
          ),
        );

        await tester.tap(find.text('header1 value 3'));

        stateManager!.toggleFrozenColumn(columns[1], TrinaColumnFrozen.start);
      },
    );

    toLeftColumn1.test('currentCellPosition should be null', (tester) async {
      expect(stateManager!.currentCellPosition, null);
    });

    toLeftColumn1.test(
      'currentCellPosition should update when moving cells with keyboard',
      (tester) async {
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
        await tester.pumpAndSettle();
        // toggleFrozenColumn called after currentCellPosition is null
        // When moving cells with keyboard, the first cell should be selected
        expect(stateManager!.currentCellPosition!.columnIdx, 0);
        expect(stateManager!.currentCellPosition!.rowIdx, 0);

        await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
        await tester.pumpAndSettle();
        // When moving to the right, columnIdx increases by 1
        expect(stateManager!.currentCellPosition!.columnIdx, 1);
        expect(stateManager!.currentCellPosition!.rowIdx, 0);

        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.pumpAndSettle();
        // When moving down, rowIdx increases by 1
        expect(stateManager!.currentCellPosition!.columnIdx, 1);
        expect(stateManager!.currentCellPosition!.rowIdx, 1);

        await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
        await tester.pumpAndSettle();
        // When moving up, rowIdx decreases by 1
        expect(stateManager!.currentCellPosition!.columnIdx, 1);
        expect(stateManager!.currentCellPosition!.rowIdx, 0);

        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pumpAndSettle();
        // When the tab key is pressed, columnIdx increases by 1
        expect(stateManager!.currentCellPosition!.columnIdx, 2);
        expect(stateManager!.currentCellPosition!.rowIdx, 0);

        await tester.sendKeyDownEvent(LogicalKeyboardKey.shift);
        await tester.pumpAndSettle();
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pumpAndSettle();
        await tester.sendKeyUpEvent(LogicalKeyboardKey.shift);
        await tester.pumpAndSettle();
        // When the shift + tab key is pressed, columnIdx decreases by 1
        expect(stateManager!.currentCellPosition!.columnIdx, 1);
        expect(stateManager!.currentCellPosition!.rowIdx, 0);
      },
    );
  });

  group('Without frozen columns', () {
    List<TrinaColumn> columns;

    List<TrinaRow> rows;

    TrinaGridStateManager? stateManager;

    final toLeftColumn1 = TrinaWidgetTestHelper(
      'Select a cell in column 3 and freeze column 3 to the right',
      (tester) async {
        columns = [...ColumnHelper.textColumn('header', count: 10)];

        rows = RowHelper.count(10, columns);

        await tester.pumpWidget(
          MaterialApp(
            home: Material(
              child: TrinaGrid(
                columns: columns,
                rows: rows,
                onLoaded: (TrinaGridOnLoadedEvent event) {
                  stateManager = event.stateManager;
                },
              ),
            ),
          ),
        );

        await tester.pump();

        await tester.tap(find.text('header3 value 5'));

        stateManager!.toggleFrozenColumn(columns[3], TrinaColumnFrozen.end);
      },
    );

    toLeftColumn1.test('currentCellPosition should become null', (
      tester,
    ) async {
      expect(stateManager!.currentCellPosition, null);
    });

    toLeftColumn1.test(
      'When there is no current cell, pressing left key should select the first cell',
      (tester) async {
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);

        expect(stateManager!.currentCellPosition!.columnIdx, 0);
        expect(stateManager!.currentCellPosition!.rowIdx, 0);

        await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
        // When moving left, the first cell cannot be moved, so the value is maintained
        expect(stateManager!.currentCellPosition!.columnIdx, 0);
        expect(stateManager!.currentCellPosition!.rowIdx, 0);

        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        // When moving up, the first cell cannot be moved, so the value is maintained
        expect(stateManager!.currentCellPosition!.columnIdx, 0);
        expect(stateManager!.currentCellPosition!.rowIdx, 0);
      },
    );
  });
}
