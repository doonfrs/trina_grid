import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trina_grid/trina_grid.dart';

import '../../helper/column_helper.dart';
import '../../helper/row_helper.dart';

void main() {
  group('RTL Keyboard Navigation', () {
    late TrinaGridStateManager stateManager;
    late List<TrinaColumn> columns;
    late List<TrinaRow> rows;

    setUp(() {
      columns = ColumnHelper.textColumn('column', count: 3);
      rows = RowHelper.count(3, columns);
    });

    Future<void> buildGrid(
      WidgetTester tester,
      TextDirection textDirection, {
      TrinaGridConfiguration configuration = const TrinaGridConfiguration(),
    }) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: Directionality(
              textDirection: textDirection,
              child: TrinaGrid(
                columns: columns,
                rows: rows,
                configuration: configuration,
                onLoaded: (event) => stateManager = event.stateManager,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('Arrow keys should work correctly in RTL mode', (tester) async {
      await buildGrid(tester, TextDirection.rtl);

      // Start at the first cell (visually rightmost in RTL)
      stateManager.setCurrentCell(rows[0].cells['column0'], 0);
      await tester.pumpAndSettle();

      // Ensure the grid has focus
      stateManager.gridFocusNode.requestFocus();
      await tester.pumpAndSettle();

      // Pressing left arrow should move to the right column visually (column1)
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pumpAndSettle();
      expect(stateManager.currentColumn?.field, 'column1');

      // Pressing right arrow should move to the left column visually (column0)
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pumpAndSettle();
      expect(stateManager.currentColumn?.field, 'column0');

      // Pressing down arrow should move to the next row
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();
      expect(stateManager.currentRowIdx, 1);
      expect(stateManager.currentColumn?.field, 'column0');

      // Pressing up arrow should move to the previous row
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pumpAndSettle();
      expect(stateManager.currentRowIdx, 0);
      expect(stateManager.currentColumn?.field, 'column0');
    });

    testWidgets('Arrow keys should work correctly in LTR mode', (tester) async {
      await buildGrid(tester, TextDirection.ltr);

      // Start at the first cell (visually leftmost in LTR)
      stateManager.setCurrentCell(rows[0].cells['column0'], 0);
      await tester.pumpAndSettle();

      // Ensure the grid has focus
      stateManager.gridFocusNode.requestFocus();
      await tester.pumpAndSettle();

      // Pressing left arrow should move to the left column visually (no change at edge)
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pumpAndSettle();
      expect(
        stateManager.currentColumn?.field,
        'column0',
      ); // Should stay at edge

      // Pressing right arrow should move to the right column visually (column1)
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pumpAndSettle();
      expect(stateManager.currentColumn?.field, 'column1');

      // Pressing left arrow should move back to column0
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pumpAndSettle();
      expect(stateManager.currentColumn?.field, 'column0');
    });

    testWidgets('Tab navigation should work correctly in RTL mode', (
      tester,
    ) async {
      await buildGrid(tester, TextDirection.rtl);

      // Start at the first cell (visually rightmost in RTL)
      stateManager.setCurrentCell(rows[0].cells['column0'], 0);
      await tester.pumpAndSettle();

      // Ensure the grid has focus
      stateManager.gridFocusNode.requestFocus();
      await tester.pumpAndSettle();

      // Pressing tab should move to the next cell visually (column1)
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
      expect(stateManager.currentColumn?.field, 'column1');

      // Pressing tab again should move to the next cell (column2)
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
      expect(stateManager.currentColumn?.field, 'column2');

      // Pressing shift+tab should move to the previous cell (column1)
      await tester.sendKeyDownEvent(LogicalKeyboardKey.shift);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shift);
      await tester.pumpAndSettle();
      expect(stateManager.currentColumn?.field, 'column1');
    });

    testWidgets('Home/End keys should work correctly in RTL mode', (
      tester,
    ) async {
      await buildGrid(tester, TextDirection.rtl);

      // Start at the middle cell
      stateManager.setCurrentCell(rows[0].cells['column1'], 0);
      await tester.pumpAndSettle();

      // Ensure the grid has focus
      stateManager.gridFocusNode.requestFocus();
      await tester.pumpAndSettle();

      // Pressing End should move to the visually leftmost cell (column2 in RTL)
      await tester.sendKeyEvent(LogicalKeyboardKey.end);
      await tester.pumpAndSettle();
      expect(stateManager.currentColumn?.field, 'column2');

      // Pressing home should move to the visually rightmost cell (column0 in RTL)
      await tester.sendKeyEvent(LogicalKeyboardKey.home);
      await tester.pumpAndSettle();
      expect(stateManager.currentColumn?.field, 'column0');
    });

    testWidgets('Home/End keys should work correctly in LTR mode', (
      tester,
    ) async {
      await buildGrid(tester, TextDirection.ltr);

      // Start at the middle cell
      stateManager.setCurrentCell(rows[0].cells['column1'], 0);
      await tester.pumpAndSettle();

      // Ensure the grid has focus
      stateManager.gridFocusNode.requestFocus();
      await tester.pumpAndSettle();

      // Pressing Home should move to the leftmost cell (column0 in LTR)
      await tester.sendKeyEvent(LogicalKeyboardKey.home);
      await tester.pumpAndSettle();
      expect(stateManager.currentColumn?.field, 'column0');

      // Pressing End should move to the rightmost cell (column2 in LTR)
      await tester.sendKeyEvent(LogicalKeyboardKey.end);
      await tester.pumpAndSettle();
      expect(stateManager.currentColumn?.field, 'column2');
    });

    testWidgets(
      'When enterKeyAction is editingAndMoveRight, '
      'pressing Enter key should move currentCell to next column of current row.',
      (tester) async {
        await buildGrid(
          tester,
          TextDirection.rtl,
          configuration: const TrinaGridConfiguration(
            enterKeyAction: TrinaGridEnterKeyAction.editingAndMoveRight,
          ),
        );

        // Start at the first cell
        stateManager.setCurrentCell(rows[0].cells['column0'], 0);
        await tester.pumpAndSettle();

        // Set the cell in editing mode (required for editingAndMoveRight action)
        stateManager.setEditing(true);
        await tester.pumpAndSettle();

        // Ensure the grid has focus
        stateManager.gridFocusNode.requestFocus();
        await tester.pumpAndSettle();

        // Pressing enter should move to the next cell visually (column1 in RTL)
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pumpAndSettle();
        expect(stateManager.currentColumn?.field, 'column1');

        // Pressing shift+enter should move to the previous cell visually (column0 in RTL)
        await tester.sendKeyDownEvent(LogicalKeyboardKey.shift);
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.shift);
        await tester.pumpAndSettle();
        expect(stateManager.currentColumn?.field, 'column0');
      },
    );
    testWidgets('when tabKeyAction is moveToNextOnEdge, '
        'pressing Tab key from the last cell of row, '
        'should move to next row.', (tester) async {
      await buildGrid(
        tester,
        TextDirection.rtl,
        configuration: const TrinaGridConfiguration(
          tabKeyAction: TrinaGridTabKeyAction.moveToNextOnEdge,
        ),
      );
      // Start at the visually last cell of the first row (column0 in RTL)
      stateManager.setCurrentCell(rows[0].cells.values.last, 0);
      await tester.pumpAndSettle();
      // expect(stateManager.currentColumn?.field, 'column0');

      // Ensure the grid has focus
      stateManager.gridFocusNode.requestFocus();
      await tester.pumpAndSettle();

      // Pressing tab should wrap to the first cell of the next row
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();

      // Expect to be on the second row (index 1)
      expect(stateManager.currentRowIdx, 1);
      // Expect to be on the visually first column
      expect(stateManager.currentColumn?.field, 'column0');
    });
  });
}
