import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trina_grid/trina_grid.dart';

import '../../helper/column_helper.dart';
import '../../helper/trina_widget_test_helper.dart';
import '../../helper/row_helper.dart';

void main() {
  group('F3 Key Test', () {
    List<TrinaColumn> columns;

    List<TrinaRow> rows;

    late TrinaGridStateManager stateManager;

    final focusedCell = find.text('header3 value 3');

    final withTheCellSelected = TrinaWidgetTestHelper(
      'With the cell selected',
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
                  stateManager.setShowColumnFilter(true);
                },
              ),
            ),
          ),
        );

        await tester.pump();

        await tester.tap(focusedCell);
      },
    );

    withTheCellSelected.test(
      'When F3 is pressed, the focus should move to the filter input box of the header3 column. '
      'After moving to the filter input box, pressing F3 again should call the filter popup.',
      (tester) async {
        await tester.sendKeyEvent(LogicalKeyboardKey.f3);

        await tester.pump();

        final currentColumn = stateManager.currentColumn;

        final focusNode = currentColumn!.filterFocusNode;

        expect(currentColumn.title, 'header3');

        expect(focusNode!.hasFocus, true);

        await tester.sendKeyEvent(LogicalKeyboardKey.f3);

        await tester.pump();

        expect(find.byType(TrinaGridFilterPopupHeader), findsOneWidget);
      },
    );

    withTheCellSelected.test(
      'When F3 is pressed to move the focus to the filter input box of the header3 column, '
      'pressing the down arrow key should change the focus to the first row cell of the column.',
      (tester) async {
        await tester.sendKeyEvent(LogicalKeyboardKey.f3);

        await tester.pump();

        final currentColumn = stateManager.currentColumn;

        final focusNode = currentColumn!.filterFocusNode;

        expect(currentColumn.title, 'header3');

        expect(focusNode!.hasFocus, true);

        expect(stateManager.hasFocus, false);

        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);

        await tester.pump();

        expect(focusNode.hasFocus, false);

        expect(stateManager.hasFocus, true);

        expect(stateManager.currentCell?.value, 'header3 value 0');
      },
    );

    withTheCellSelected.test(
      'When F3 is pressed to move the focus to the filter input box of the header3 column, '
      'pressing the Enter key should change the focus to the first row cell of the column.',
      (tester) async {
        await tester.sendKeyEvent(LogicalKeyboardKey.f3);

        await tester.pump();

        final currentColumn = stateManager.currentColumn;

        final focusNode = currentColumn!.filterFocusNode;

        expect(currentColumn.title, 'header3');

        expect(focusNode!.hasFocus, true);

        expect(stateManager.hasFocus, false);

        await tester.sendKeyEvent(LogicalKeyboardKey.enter);

        await tester.pump();

        expect(focusNode.hasFocus, false);

        expect(stateManager.hasFocus, true);

        expect(stateManager.currentCell?.value, 'header3 value 0');
      },
    );

    withTheCellSelected.test(
      'When F3 is pressed to move the focus to the filter input box of the header3 column, '
      'pressing the ESC key should change the focus to the original cell.',
      (tester) async {
        await tester.sendKeyEvent(LogicalKeyboardKey.f3);

        await tester.pump();

        final currentColumn = stateManager.currentColumn;

        final focusNode = currentColumn!.filterFocusNode;

        expect(currentColumn.title, 'header3');

        expect(focusNode!.hasFocus, true);

        expect(stateManager.hasFocus, false);

        await tester.sendKeyEvent(LogicalKeyboardKey.escape);

        await tester.pump();

        expect(focusNode.hasFocus, false);

        expect(stateManager.hasFocus, true);

        expect(stateManager.currentCell?.value, 'header3 value 3');
      },
    );

    withTheCellSelected.test(
      'When the column filter area is disabled, pressing F3 should not move the focus.',
      (tester) async {
        stateManager.setShowColumnFilter(false);

        await tester.pump();

        await tester.sendKeyEvent(LogicalKeyboardKey.f3);

        await tester.pump();

        expect(stateManager.gridFocusNode.hasFocus, true);

        expect(find.byType(TrinaGridFilterPopupHeader), findsNothing);
      },
    );

    withTheCellSelected.test(
      'When there is no selected cell, pressing F3 should not move the focus.',
      (tester) async {
        stateManager.clearCurrentCell();

        await tester.pump();

        await tester.sendKeyEvent(LogicalKeyboardKey.f3);

        await tester.pump();

        expect(stateManager.gridFocusNode.hasFocus, true);

        expect(find.byType(TrinaGridFilterPopupHeader), findsNothing);
      },
    );
  });
}
