import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trina_grid/trina_grid.dart';

import '../../helper/column_helper.dart';
import '../../helper/trina_widget_test_helper.dart';
import '../../helper/row_helper.dart';

void main() {
  group('Auto Editing Test', () {
    List<TrinaColumn> columns;

    List<TrinaRow> rows;

    TrinaGridStateManager? stateManager;

    final trinaGrid = TrinaWidgetTestHelper(
      '5 columns and 10 rows are created',
      (tester) async {
        columns = [...ColumnHelper.textColumn('header', count: 5)];

        rows = RowHelper.count(10, columns);

        await tester.pumpWidget(
          MaterialApp(
            home: Material(
              child: TrinaGrid(
                columns: columns,
                rows: rows,
                onLoaded: (TrinaGridOnLoadedEvent event) {
                  stateManager = event.stateManager;
                  stateManager!.setAutoEditing(true);
                },
              ),
            ),
          ),
        );
      },
    );

    trinaGrid.test(
      'When clicking the first cell, the editing state should be true.',
      (tester) async {
        expect(stateManager!.isEditing, false);

        await tester.tap(find.text('header0 value 0'));

        expect(stateManager!.currentCell!.value, 'header0 value 0');

        expect(stateManager!.isEditing, true);
      },
    );

    trinaGrid.test(
      'When clicking the first cell and pressing the tab key, the second cell should be in editing state.',
      (tester) async {
        expect(stateManager!.isEditing, false);

        await tester.tap(find.text('header0 value 0'));

        await tester.sendKeyEvent(LogicalKeyboardKey.tab);

        expect(stateManager!.currentCell!.value, 'header1 value 0');

        expect(stateManager!.isEditing, true);
      },
    );

    trinaGrid.test(
      'When clicking the first cell and pressing the enter key, the first cell of the second row should be in editing state.',
      (tester) async {
        expect(stateManager!.isEditing, false);

        await tester.tap(find.text('header0 value 0'));

        await tester.sendKeyEvent(LogicalKeyboardKey.enter);

        expect(stateManager!.currentCell!.value, 'header0 value 1');

        expect(stateManager!.isEditing, true);
      },
    );

    trinaGrid.test(
      'When clicking the first cell and pressing the ESC key, the editing state should change from true to false.',
      (tester) async {
        expect(stateManager!.isEditing, false);

        await tester.tap(find.text('header0 value 0'));

        expect(stateManager!.isEditing, true);

        await tester.sendKeyEvent(LogicalKeyboardKey.escape);

        expect(stateManager!.currentCell!.value, 'header0 value 0');

        expect(stateManager!.isEditing, false);
      },
    );

    trinaGrid.test(
      'When clicking the first cell and pressing the ESC key, then pressing the end key, the last cell should be in editing state.',
      (tester) async {
        await tester.tap(find.text('header0 value 0'));

        await tester.sendKeyEvent(LogicalKeyboardKey.escape);

        await tester.sendKeyEvent(LogicalKeyboardKey.end);

        expect(stateManager!.currentCell!.value, 'header4 value 0');

        expect(stateManager!.isEditing, true);
      },
    );

    trinaGrid.test(
      'When clicking the first cell and pressing the ESC key, then pressing the down arrow key, the second cell should be in editing state.',
      (tester) async {
        await tester.tap(find.text('header0 value 0'));

        await tester.sendKeyEvent(LogicalKeyboardKey.escape);

        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);

        expect(stateManager!.currentCell!.value, 'header0 value 1');

        expect(stateManager!.isEditing, true);
      },
    );

    trinaGrid.test(
      'When clicking the first cell and pressing the ESC key, then pressing the right arrow key, the second cell should be in editing state.',
      (tester) async {
        await tester.tap(find.text('header0 value 0'));

        await tester.sendKeyEvent(LogicalKeyboardKey.escape);

        await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);

        expect(stateManager!.currentCell!.value, 'header1 value 0');

        expect(stateManager!.isEditing, true);
      },
    );
  });
}
