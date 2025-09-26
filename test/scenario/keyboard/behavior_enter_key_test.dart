import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trina_grid/trina_grid.dart';

import '../../helper/column_helper.dart';
import '../../helper/trina_widget_test_helper.dart';
import '../../helper/row_helper.dart';

void main() {
  group('Enter Key Test', () {
    List<TrinaColumn> columns;

    List<TrinaRow> rows;

    TrinaGridStateManager? stateManager;

    final withTheCellSelected = TrinaWidgetTestHelper(
      'With the cell selected at 3, 3',
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

        await tester.tap(find.text('header3 value 3'));
      },
    );

    withTheCellSelected.test(
      'In editing state, pressing shift + enter should move to the cell above.',
      (tester) async {
        stateManager!.setEditing(true);
        expect(stateManager!.currentCell!.value, 'header3 value 3');
        expect(stateManager!.currentCellPosition!.columnIdx, 3);
        expect(stateManager!.currentCellPosition!.rowIdx, 3);

        await tester.sendKeyDownEvent(LogicalKeyboardKey.shift);
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.shift);

        expect(stateManager!.currentCell!.value, 'header3 value 2');
        expect(stateManager!.currentCellPosition!.columnIdx, 3);
        expect(stateManager!.currentCellPosition!.rowIdx, 2);
      },
    );

    withTheCellSelected.test(
      'In editing state, pressing enter should move to the cell below.',
      (tester) async {
        stateManager!.setEditing(true);
        expect(stateManager!.currentCell!.value, 'header3 value 3');
        expect(stateManager!.currentCellPosition!.columnIdx, 3);
        expect(stateManager!.currentCellPosition!.rowIdx, 3);

        await tester.sendKeyEvent(LogicalKeyboardKey.enter);

        expect(stateManager!.currentCell!.value, 'header3 value 4');
        expect(stateManager!.currentCellPosition!.columnIdx, 3);
        expect(stateManager!.currentCellPosition!.rowIdx, 4);
      },
    );
  });
}
