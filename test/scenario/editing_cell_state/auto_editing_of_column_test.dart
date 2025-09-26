import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trina_grid/trina_grid.dart';

import '../../helper/trina_widget_test_helper.dart';
import '../../helper/row_helper.dart';

void main() {
  group('Auto Editing Column Test', () {
    List<TrinaColumn> columns;

    List<TrinaRow> rows;

    TrinaGridStateManager? stateManager;

    final trinaGrid = TrinaWidgetTestHelper(
      '0, 3rd column is autoEditing with 5 columns and 10 rows',
      (tester) async {
        columns = [
          TrinaColumn(
            title: 'header0',
            field: 'header0',
            type: TrinaColumnType.text(),
            enableAutoEditing: true,
          ),
          TrinaColumn(
            title: 'header1',
            field: 'header1',
            type: TrinaColumnType.text(),
          ),
          TrinaColumn(
            title: 'header2',
            field: 'header2',
            type: TrinaColumnType.text(),
          ),
          TrinaColumn(
            title: 'header3',
            field: 'header3',
            type: TrinaColumnType.text(),
            enableAutoEditing: true,
          ),
          TrinaColumn(
            title: 'header4',
            field: 'header4',
            type: TrinaColumnType.text(),
          ),
        ];

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

        expect(stateManager!.autoEditing, false);
      },
    );

    trinaGrid.test('Clicking the 0th cell should enter edit mode', (
      tester,
    ) async {
      expect(stateManager!.isEditing, false);

      await tester.tap(find.text('header0 value 0'));

      expect(stateManager!.currentCell!.value, 'header0 value 0');

      expect(stateManager!.isEditing, true);
    });

    trinaGrid.test('Clicking the 1st cell should not enter edit mode', (
      tester,
    ) async {
      expect(stateManager!.isEditing, false);

      await tester.tap(find.text('header1 value 0'));

      expect(stateManager!.currentCell!.value, 'header1 value 0');

      expect(stateManager!.isEditing, false);
    });

    trinaGrid.test('Clicking the 2nd cell should not enter edit mode', (
      tester,
    ) async {
      expect(stateManager!.isEditing, false);

      await tester.tap(find.text('header2 value 0'));

      expect(stateManager!.currentCell!.value, 'header2 value 0');

      expect(stateManager!.isEditing, false);
    });

    trinaGrid.test(
      'Clicking the 2nd cell and pressing the right arrow key should enter edit mode for the 3rd cell',
      (tester) async {
        expect(stateManager!.isEditing, false);

        await tester.tap(find.text('header2 value 0'));

        await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);

        expect(stateManager!.currentCell!.value, 'header3 value 0');

        expect(stateManager!.isEditing, true);
      },
    );

    trinaGrid.test('Clicking the 3rd cell should enter edit mode', (
      tester,
    ) async {
      expect(stateManager!.isEditing, false);

      await tester.tap(find.text('header3 value 0'));

      expect(stateManager!.currentCell!.value, 'header3 value 0');

      expect(stateManager!.isEditing, true);
    });

    trinaGrid.test(
      'Clicking the 3rd cell, pressing ESC, and pressing the left arrow key should not enter edit mode for the 2nd cell',
      (tester) async {
        expect(stateManager!.isEditing, false);

        await tester.tap(find.text('header3 value 0'));

        await tester.sendKeyEvent(LogicalKeyboardKey.escape);

        await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);

        expect(stateManager!.currentCell!.value, 'header2 value 0');

        expect(stateManager!.isEditing, false);
      },
    );
  });
}
