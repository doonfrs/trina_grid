import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trina_grid/trina_grid.dart';

import '../../helper/column_helper.dart';
import '../../helper/row_helper.dart';
import '../../helper/test_helper_util.dart';

void main() {
  late TrinaGridStateManager stateManager;

  final columns = [
    TrinaColumn(
      title: 'start',
      field: 'start',
      type: TrinaColumnType.text(),
      width: 100,
      frozen: TrinaColumnFrozen.start,
    ),
    ...ColumnHelper.textColumn('body', count: 5, width: 150),
    TrinaColumn(
      title: 'end',
      field: 'end',
      type: TrinaColumnType.text(),
      width: 100,
      frozen: TrinaColumnFrozen.end,
    ),
  ];

  final rows = RowHelper.count(10, columns);

  Future<void> buildGrid(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: TrinaGrid(
            columns: columns,
            rows: rows,
            onLoaded: (event) {
              stateManager = event.stateManager;
            },
          ),
        ),
      ),
    );
  }

  testWidgets(
    'When the window is resized to narrow and back to wide, frozen columns should be restored.',
    (tester) async {
      // Initial build with a wide window
      await buildGrid(tester);
      expect(stateManager.showFrozenColumn, isTrue);
      expect(stateManager.hasLeftFrozenColumns, isTrue);
      expect(stateManager.hasRightFrozenColumns, isTrue);

      // Resize to a narrow window
      await TestHelperUtil.changeWidth(tester: tester, width: 150, height: 500);
      expect(stateManager.showFrozenColumn, isFalse);
      expect(stateManager.hasLeftFrozenColumns, isTrue);
      expect(stateManager.hasRightFrozenColumns, isTrue);

      // Resize back to a wide window
      await TestHelperUtil.changeWidth(tester: tester, width: 800, height: 500);
      expect(
        stateManager.showFrozenColumn,
        isTrue,
        reason:
            'Frozen columns should be restored after resizing back to wide.',
      );
    },
  );

  testWidgets(
    'When the window is resized to just below threshold, frozen columns should be hidden but state preserved.',
    (tester) async {
      // Initial build with a wide window
      await buildGrid(tester);
      expect(stateManager.showFrozenColumn, isTrue);

      // Resize to just below the threshold where frozen columns are hidden
      await TestHelperUtil.changeWidth(tester: tester, width: 250, height: 500);
      expect(stateManager.showFrozenColumn, isFalse);
      expect(
        stateManager.columns[0].frozen,
        TrinaColumnFrozen.start,
        reason: 'Frozen state should be preserved even if not shown.',
      );
      expect(
        stateManager.columns.last.frozen,
        TrinaColumnFrozen.end,
        reason: 'Frozen state should be preserved even if not shown.',
      );

      // Resize back to wide
      await TestHelperUtil.changeWidth(tester: tester, width: 800, height: 500);
      expect(
        stateManager.showFrozenColumn,
        isTrue,
        reason:
            'Frozen columns should be restored after resizing back to wide.',
      );
    },
  );

  testWidgets(
    'When the window is resized with multiple frozen columns, all should be handled correctly.',
    (tester) async {
      // Modify columns to have multiple frozen columns on both sides
      final multiFrozenColumns = [
        TrinaColumn(
          title: 'start1',
          field: 'start1',
          type: TrinaColumnType.text(),
          width: 100,
          frozen: TrinaColumnFrozen.start,
        ),
        TrinaColumn(
          title: 'start2',
          field: 'start2',
          type: TrinaColumnType.text(),
          width: 100,
          frozen: TrinaColumnFrozen.start,
        ),
        ...ColumnHelper.textColumn('body', count: 3, width: 150),
        TrinaColumn(
          title: 'end1',
          field: 'end1',
          type: TrinaColumnType.text(),
          width: 100,
          frozen: TrinaColumnFrozen.end,
        ),
        TrinaColumn(
          title: 'end2',
          field: 'end2',
          type: TrinaColumnType.text(),
          width: 100,
          frozen: TrinaColumnFrozen.end,
        ),
      ];

      final multiFrozenRows = RowHelper.count(10, multiFrozenColumns);

      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: TrinaGrid(
              columns: multiFrozenColumns,
              rows: multiFrozenRows,
              onLoaded: (event) {
                stateManager = event.stateManager;
              },
            ),
          ),
        ),
      );

      expect(stateManager.showFrozenColumn, isTrue);
      expect(stateManager.leftFrozenColumns.length, 2);
      expect(stateManager.rightFrozenColumns.length, 2);

      // Resize to narrow
      await TestHelperUtil.changeWidth(tester: tester, width: 200, height: 500);
      expect(stateManager.showFrozenColumn, isFalse);
      expect(stateManager.columns[0].frozen, TrinaColumnFrozen.start);
      expect(stateManager.columns[1].frozen, TrinaColumnFrozen.start);
      expect(stateManager.columns.last.frozen, TrinaColumnFrozen.end);
      expect(
        stateManager.columns[multiFrozenColumns.length - 2].frozen,
        TrinaColumnFrozen.end,
      );

      // Resize back to wide
      await TestHelperUtil.changeWidth(tester: tester, width: 900, height: 500);
      expect(
        stateManager.showFrozenColumn,
        isTrue,
        reason:
            'All frozen columns should be restored after resizing back to wide.',
      );
    },
  );

  testWidgets(
    'When resizing with hidden frozen columns, state should be preserved.',
    (tester) async {
      // Initial build with a wide window
      await buildGrid(tester);
      expect(stateManager.showFrozenColumn, isTrue);

      // Hide a frozen column
      stateManager.hideColumn(columns[0], true);
      expect(stateManager.refColumns.originalList[0].hide, isTrue);
      expect(
        stateManager.refColumns.originalList[0].frozen,
        TrinaColumnFrozen.start,
        reason: 'Frozen state should be preserved even when hidden.',
      );

      // Resize to narrow
      await TestHelperUtil.changeWidth(tester: tester, width: 150, height: 500);
      expect(stateManager.showFrozenColumn, isFalse);
      expect(
        stateManager.refColumns.originalList[0].frozen,
        TrinaColumnFrozen.start,
      );

      // Resize back to wide
      await TestHelperUtil.changeWidth(tester: tester, width: 800, height: 500);
      expect(stateManager.showFrozenColumn, isTrue);
      expect(
        stateManager.refColumns.originalList[0].frozen,
        TrinaColumnFrozen.start,
        reason:
            'Frozen state of hidden column should be preserved after resizing.',
      );
      // unhide the first column
      stateManager.hideColumn(columns[0], false);
      // assert showFrozenColumn didn't change
      expect(stateManager.showFrozenColumn, isTrue);
      // assert column.frozen didn't change
      expect(
        stateManager.refColumns.originalList[0].frozen,
        TrinaColumnFrozen.start,
        reason:
            'Frozen state of hidden column should be preserved after resizing.',
      );
    },
  );
}
