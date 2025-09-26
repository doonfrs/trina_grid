import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trina_grid/trina_grid.dart';

import '../../helper/column_helper.dart';
import '../../helper/trina_widget_test_helper.dart';
import '../../helper/row_helper.dart';

/// When enterKeyAction is set, test.
void main() {
  group('Enter key test.', () {
    List<TrinaColumn> columns;

    List<TrinaRow> rows;

    TrinaGridStateManager? stateManager;

    withEnterKeyAction(TrinaGridEnterKeyAction enterKeyAction) {
      return TrinaWidgetTestHelper('2, 2 cell is selected', (tester) async {
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
                configuration: TrinaGridConfiguration(
                  enterKeyAction: enterKeyAction,
                ),
              ),
            ),
          ),
        );

        await tester.pump();

        await tester.tap(find.text('header2 value 2'));
      });
    }

    withEnterKeyAction(TrinaGridEnterKeyAction.none).test(
      'When enterKeyAction is TrinaGridEnterKeyAction.none, '
      'pressing enter should not edit cell or move',
      (tester) async {
        stateManager!.setEditing(true);
        expect(stateManager!.isEditing, true);

        await tester.sendKeyEvent(LogicalKeyboardKey.enter);

        expect(stateManager!.currentCellPosition!.rowIdx, 2);
        expect(stateManager!.currentCellPosition!.columnIdx, 2);
      },
    );

    withEnterKeyAction(TrinaGridEnterKeyAction.toggleEditing).test(
      'When enterKeyAction is TrinaGridEnterKeyAction.toggleEditing, '
      'pressing enter should toggle edit mode',
      (tester) async {
        stateManager!.setEditing(true);
        expect(stateManager!.isEditing, true);

        await tester.sendKeyEvent(LogicalKeyboardKey.enter);

        expect(stateManager!.isEditing, isFalse);
        expect(stateManager!.currentCellPosition!.rowIdx, 2);
        expect(stateManager!.currentCellPosition!.columnIdx, 2);
      },
    );

    withEnterKeyAction(TrinaGridEnterKeyAction.toggleEditing).test(
      'When enterKeyAction is TrinaGridEnterKeyAction.toggleEditing, '
      'pressing enter should toggle edit mode',
      (tester) async {
        stateManager!.setEditing(false);
        expect(stateManager!.isEditing, false);

        await tester.sendKeyEvent(LogicalKeyboardKey.enter);

        expect(stateManager!.isEditing, isTrue);
        expect(stateManager!.currentCellPosition!.rowIdx, 2);
        expect(stateManager!.currentCellPosition!.columnIdx, 2);
      },
    );

    withEnterKeyAction(TrinaGridEnterKeyAction.editingAndMoveDown).test(
      'When enterKeyAction is TrinaGridEnterKeyAction.editingAndMoveDown, '
      'pressing enter should edit cell and move down',
      (tester) async {
        stateManager!.setEditing(true);
        expect(stateManager!.isEditing, true);

        await tester.sendKeyEvent(LogicalKeyboardKey.enter);

        expect(stateManager!.isEditing, isTrue);
        expect(stateManager!.currentCellPosition!.rowIdx, 3);
        expect(stateManager!.currentCellPosition!.columnIdx, 2);
      },
    );

    withEnterKeyAction(TrinaGridEnterKeyAction.editingAndMoveDown).test(
      'When enterKeyAction is TrinaGridEnterKeyAction.editingAndMoveDown, '
      'pressing enter with shift should edit cell and move up',
      (tester) async {
        stateManager!.setEditing(true);
        expect(stateManager!.isEditing, true);

        await tester.sendKeyDownEvent(LogicalKeyboardKey.shift);
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.shift);

        expect(stateManager!.isEditing, isTrue);
        expect(stateManager!.currentCellPosition!.rowIdx, 1);
        expect(stateManager!.currentCellPosition!.columnIdx, 2);
      },
    );

    withEnterKeyAction(TrinaGridEnterKeyAction.editingAndMoveRight).test(
      'When enterKeyAction is TrinaGridEnterKeyAction.editingAndMoveRight, '
      'pressing enter should edit cell and move right',
      (tester) async {
        stateManager!.setEditing(true);
        expect(stateManager!.isEditing, true);

        await tester.sendKeyEvent(LogicalKeyboardKey.enter);

        expect(stateManager!.isEditing, isTrue);
        expect(stateManager!.currentCellPosition!.rowIdx, 2);
        expect(stateManager!.currentCellPosition!.columnIdx, 3);
      },
    );

    withEnterKeyAction(TrinaGridEnterKeyAction.editingAndMoveRight).test(
      'When enterKeyAction is TrinaGridEnterKeyAction.editingAndMoveRight, '
      'pressing enter with shift should edit cell and move left',
      (tester) async {
        stateManager!.setEditing(true);
        expect(stateManager!.isEditing, true);

        await tester.sendKeyDownEvent(LogicalKeyboardKey.shift);
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.shift);

        expect(stateManager!.isEditing, isTrue);
        expect(stateManager!.currentCellPosition!.rowIdx, 2);
        expect(stateManager!.currentCellPosition!.columnIdx, 1);
      },
    );
  });
}
