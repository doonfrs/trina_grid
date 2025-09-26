import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trina_grid/trina_grid.dart';

import '../../helper/column_helper.dart';
import '../../helper/row_helper.dart';

void main() {
  testWidgets(
    'WHEN frozen one column on the right when there are no frozen columns in the grid.'
    'THEN showFrozenColumn changes to true and the column is moved to the right and should disappear from its original position.',
    (WidgetTester tester) async {
      // given
      final columns = [...ColumnHelper.textColumn('header', count: 10)];
      final rows = RowHelper.count(10, columns);

      TrinaGridStateManager? stateManager;

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

      await tester.pumpAndSettle();

      // when
      // first cell of first column
      Finder firstCell = find.byKey(rows.first.cells['header0']!.key);

      // select first cell
      await tester.tap(
        find.descendant(of: firstCell, matching: find.byType(GestureDetector)),
      );

      // Check first cell value of first column
      expect(stateManager!.currentCell!.value, 'header0 value 0');

      // Check showFrozenColumn before freezing column.
      expect(stateManager!.showFrozenColumn, false);

      // Freeze the 3rd column
      stateManager!.toggleFrozenColumn(columns[2], TrinaColumnFrozen.end);

      // Await re-build by toggleFrozenColumn
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Check showFrozenColumn after freezing column.
      expect(stateManager!.showFrozenColumn, true);

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pumpAndSettle();
      expect(stateManager!.currentColumn!.title, 'header0');

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pumpAndSettle();
      expect(stateManager!.currentColumn!.title, 'header1');

      // Move current cell position to 10rd column (1 -> 9)
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pumpAndSettle();

      expect(stateManager!.currentColumn!.title, 'header9');

      // Right frozen column
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pumpAndSettle();
      expect(stateManager!.currentColumn!.title, 'header2');
    },
  );
}
