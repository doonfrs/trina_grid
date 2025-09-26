import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trina_grid/trina_grid.dart';
import 'package:trina_grid/src/ui/ui.dart';

import '../../helper/column_helper.dart';
import '../../helper/trina_widget_test_helper.dart';
import '../../helper/row_helper.dart';

void main() {
  List<TrinaColumn> columns;

  List<TrinaRow> rows;

  late TrinaGridStateManager stateManager;

  final tenByTenGrid = TrinaWidgetTestHelper(
    '10 columns and 10 rows are created. ',
    (tester) async {
      columns = ColumnHelper.textColumn('column', count: 10);

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
    },
  );

  Finder findFilter(String columnTitle) {
    return find.descendant(
      of: find.ancestor(
        of: find.text(columnTitle),
        matching: find.byType(TrinaBaseColumn),
      ),
      matching: find.byType(TextField),
    );
  }

  Future<void> tapFilter(WidgetTester tester, Finder filter) async {
    // The text box must be tapped twice to receive focus for the first time.
    await tester.tap(filter);
    await tester.pump();
    await tester.tap(filter);
    await tester.pump();
  }

  tenByTenGrid.test(
    'Tap the filter of the 0th column and move right with the arrow key',
    (tester) async {
      final firstColumnFilter = findFilter('column0');

      await tapFilter(tester, firstColumnFilter);
      await tester.pump();
      expect(stateManager.refColumns[0].filterFocusNode!.hasFocus, true);

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      expect(stateManager.refColumns[1].filterFocusNode!.hasFocus, true);

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      expect(stateManager.refColumns[2].filterFocusNode!.hasFocus, true);
    },
  );

  tenByTenGrid.test(
    'Tap the filter of the 2nd column and move left with the arrow key',
    (tester) async {
      final firstColumnFilter = findFilter('column2');

      await tapFilter(tester, firstColumnFilter);
      await tester.pump();
      expect(stateManager.refColumns[2].filterFocusNode!.hasFocus, true);

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pump();
      expect(stateManager.refColumns[1].filterFocusNode!.hasFocus, true);

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pump();
      expect(stateManager.refColumns[0].filterFocusNode!.hasFocus, true);
    },
  );

  tenByTenGrid.test(
    'Tap the filter of the 0th column and move with the Tab key',
    (tester) async {
      final firstColumnFilter = findFilter('column0');

      await tapFilter(tester, firstColumnFilter);
      await tester.pump();
      expect(stateManager.refColumns[0].filterFocusNode!.hasFocus, true);

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(stateManager.refColumns[1].filterFocusNode!.hasFocus, true);

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(stateManager.refColumns[2].filterFocusNode!.hasFocus, true);
    },
  );

  tenByTenGrid.test(
    'Tap the filter of the 2nd column and move with Shift+Tab key',
    (tester) async {
      final firstColumnFilter = findFilter('column2');

      await tapFilter(tester, firstColumnFilter);
      await tester.pump();
      expect(stateManager.refColumns[2].filterFocusNode!.hasFocus, true);

      await tester.sendKeyDownEvent(LogicalKeyboardKey.shift);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shift);
      await tester.pump();
      expect(stateManager.refColumns[1].filterFocusNode!.hasFocus, true);

      await tester.sendKeyDownEvent(LogicalKeyboardKey.shift);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shift);
      await tester.pump();
      expect(stateManager.refColumns[0].filterFocusNode!.hasFocus, true);
    },
  );
}
