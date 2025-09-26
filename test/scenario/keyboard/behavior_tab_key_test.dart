import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trina_grid/trina_grid.dart';

import '../../helper/column_helper.dart';
import '../../helper/trina_widget_test_helper.dart';
import '../../helper/row_helper.dart';
import '../../helper/test_helper_util.dart';

void main() {
  group('TrinaGridTabKeyAction.moveToNextOnEdge - Tab Key Test', () {
    late List<TrinaColumn> columns;

    late List<TrinaRow> rows;

    late TrinaGridStateManager stateManager;

    TrinaWidgetTestHelper buildGrid({String? tapValue}) {
      return TrinaWidgetTestHelper('5 columns 5 rows.', (tester) async {
        await TestHelperUtil.changeWidth(
          tester: tester,
          width: 1200,
          height: 600,
        );

        columns = ColumnHelper.textColumn('column', count: 5);

        rows = RowHelper.count(5, columns);

        await tester.pumpWidget(
          MaterialApp(
            home: Material(
              child: TrinaGrid(
                columns: columns,
                rows: rows,
                onLoaded: (TrinaGridOnLoadedEvent event) {
                  stateManager = event.stateManager;
                },
                configuration: const TrinaGridConfiguration(
                  tabKeyAction: TrinaGridTabKeyAction.moveToNextOnEdge,
                ),
              ),
            ),
          ),
        );

        if (tapValue != null) {
          await tester.tap(find.text(tapValue));
        }
      });
    }

    buildGrid(tapValue: 'column4 value 0').test(
      'When Tab is pressed in the last cell of the 0th row, focus should move to the first cell of the 1st row.',
      (tester) async {
        expect(stateManager.currentCellPosition!.rowIdx, 0);
        expect(stateManager.currentCellPosition!.columnIdx, 4);

        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pumpAndSettle();

        expect(stateManager.currentCellPosition!.rowIdx, 1);
        expect(stateManager.currentCellPosition!.columnIdx, 0);
      },
    );

    buildGrid(tapValue: 'column4 value 1').test(
      'When Tab is pressed twice in the second last cell of the 1st row, focus should move to the first cell of the 2nd row.',
      (tester) async {
        expect(stateManager.currentCellPosition!.rowIdx, 1);
        expect(stateManager.currentCellPosition!.columnIdx, 4);

        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pumpAndSettle();

        expect(stateManager.currentCellPosition!.rowIdx, 2);
        expect(stateManager.currentCellPosition!.columnIdx, 0);
      },
    );

    buildGrid(tapValue: 'column4 value 4').test(
      'When Tab is pressed in the last cell of the last row, focus should not move.',
      (tester) async {
        expect(stateManager.currentCellPosition!.rowIdx, 4);
        expect(stateManager.currentCellPosition!.columnIdx, 4);

        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pumpAndSettle();

        expect(stateManager.currentCellPosition!.rowIdx, 4);
        expect(stateManager.currentCellPosition!.columnIdx, 4);
      },
    );
  });

  group('TrinaGridTabKeyAction.moveToNextOnEdge - Shift + Tab Key Test', () {
    late List<TrinaColumn> columns;

    late List<TrinaRow> rows;

    late TrinaGridStateManager stateManager;

    TrinaWidgetTestHelper buildGrid({String? tapValue}) {
      return TrinaWidgetTestHelper('5 columns 5 rows.', (tester) async {
        await TestHelperUtil.changeWidth(
          tester: tester,
          width: 1200,
          height: 600,
        );

        columns = ColumnHelper.textColumn('column', count: 5);

        rows = RowHelper.count(5, columns);

        await tester.pumpWidget(
          MaterialApp(
            home: Material(
              child: TrinaGrid(
                columns: columns,
                rows: rows,
                onLoaded: (TrinaGridOnLoadedEvent event) {
                  stateManager = event.stateManager;
                },
                configuration: const TrinaGridConfiguration(
                  tabKeyAction: TrinaGridTabKeyAction.moveToNextOnEdge,
                ),
              ),
            ),
          ),
        );

        if (tapValue != null) {
          await tester.tap(find.text(tapValue));
        }
      });
    }

    buildGrid(tapValue: 'column0 value 1').test(
      'When Shift+Tab is pressed in the first cell of the 1st row, focus should move to the last cell of the 0th row.',
      (tester) async {
        expect(stateManager.currentCellPosition!.rowIdx, 1);
        expect(stateManager.currentCellPosition!.columnIdx, 0);

        await tester.sendKeyDownEvent(LogicalKeyboardKey.shift);
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.shift);
        await tester.pumpAndSettle();

        expect(stateManager.currentCellPosition!.rowIdx, 0);
        expect(stateManager.currentCellPosition!.columnIdx, 4);
      },
    );

    buildGrid(tapValue: 'column0 value 2').test(
      'When Shift+Tab is pressed twice in the first cell of the 2nd row, focus should move to the last cell of the 1st row.',
      (tester) async {
        expect(stateManager.currentCellPosition!.rowIdx, 2);
        expect(stateManager.currentCellPosition!.columnIdx, 0);

        await tester.sendKeyDownEvent(LogicalKeyboardKey.shift);
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.shift);
        await tester.sendKeyDownEvent(LogicalKeyboardKey.shift);
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.shift);
        await tester.pumpAndSettle();

        expect(stateManager.currentCellPosition!.rowIdx, 1);
        expect(stateManager.currentCellPosition!.columnIdx, 4);
      },
    );

    buildGrid(tapValue: 'column0 value 0').test(
      'When Shift+Tab is pressed in the first cell of the 0th row, focus should not move.',
      (tester) async {
        expect(stateManager.currentCellPosition!.rowIdx, 0);
        expect(stateManager.currentCellPosition!.columnIdx, 0);

        await tester.sendKeyDownEvent(LogicalKeyboardKey.shift);
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.shift);
        await tester.pumpAndSettle();

        expect(stateManager.currentCellPosition!.rowIdx, 0);
        expect(stateManager.currentCellPosition!.columnIdx, 0);
      },
    );
  });
}
