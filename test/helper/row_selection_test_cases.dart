import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:trina_grid/trina_grid.dart';

import '../helper/build_grid_helper.dart';
import '../mock/mock_methods.dart';
import 'on_selected_helper.dart';
import 'trina_widget_test_helper.dart';

void runCommonRowSelectingTestCases({
  required TrinaWidgetTestHelper Function({
    int numberOfRows,
    void Function(TrinaGridOnLoadedEvent)? onLoaded,
    void Function(TrinaGridOnSelectedEvent)? onSelected,
  }) buildGrid,
  required TrinaGridStateManager Function() stateManager,
  required MockMethods mock,
  required Future<void> Function(WidgetTester tester, int rowId) selectRow,
  required Future<void> Function(WidgetTester tester, {required int count})
      selectRows,
}) {
  runGeneralRowSelectionTestCases(
    buildGrid: buildGrid,
    stateManager: stateManager,
    selectRows: selectRows,
  );

  runRowSelectionWithKeyboardTestCases(
    buildGrid: buildGrid,
    stateManager: stateManager,
    mock: mock,
    selectRow: selectRow,
  );

  runRowSelectionByLongPressTestCases(
    buildGrid: buildGrid,
    stateManager: stateManager,
    mock: mock,
    selectRow: selectRow,
  );
}

void runGeneralRowSelectionTestCases({
  required TrinaWidgetTestHelper Function({
    int numberOfRows,
    void Function(TrinaGridOnLoadedEvent)? onLoaded,
    void Function(TrinaGridOnSelectedEvent)? onSelected,
  }) buildGrid,
  required TrinaGridStateManager Function() stateManager,
  required Future<void> Function(WidgetTester tester, {required int count})
      selectRows,
}) {
  buildGrid(numberOfRows: 0).test(
    'When there are no rows, no error should occur and the grid should be focused',
    (tester) async {
      expect(stateManager().refRows.length, 0);
      expect(stateManager().currentCell, null);
      expect(stateManager().hasFocus, true);
    },
  );

  buildGrid().test(
    'When multiple rows are selected, stateManager.selectedRows should equal to the selected rows',
    (tester) async {
      expect(stateManager().currentRowIdx, 0);
      await selectRows(tester, count: 3);

      expect(stateManager().selectedRows.length, 3);
      expect(stateManager().selectedRows, stateManager().refRows.sublist(0, 3));
    },
  );
}

void runRowSelectionWithKeyboardTestCases({
  required TrinaWidgetTestHelper Function({
    int numberOfRows,
    void Function(TrinaGridOnLoadedEvent)? onLoaded,
    void Function(TrinaGridOnSelectedEvent)? onSelected,
  }) buildGrid,
  required TrinaGridStateManager Function() stateManager,
  required MockMethods mock,
  required Future<void> Function(WidgetTester tester, int rowId) selectRow,
}) {
  buildGrid(onSelected: mock.oneParamReturnVoid<TrinaGridOnSelectedEvent>).test(
    'When the first row is current row, '
    'press shift + arrowDown 3 times, '
    'the onSelected callback should contain rows 0, 1, 2, 3.',
    (tester) async {
      await tester.sendKeyDownEvent(LogicalKeyboardKey.shift);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shift);
      await tester.pumpAndSettle();

      verifyOnSelectedEvent(
        mock: mock,
        expectedSelectedRows: stateManager().refRows.sublist(0, 4),
      );

      expect(stateManager().selectedRows.length, 4);
    },
  );

  buildGrid(onSelected: mock.oneParamReturnVoid<TrinaGridOnSelectedEvent>).test(
    'When the first 3 rows are selected by shift+arrowDown, '
    'selecting 4th row by mode-specific method should add it to selection',
    (tester) async {
      // The first row should is current row, so it should be included in selection.
      expect(stateManager().currentRowIdx, 0);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.shift);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shift);
      await tester.pumpAndSettle();

      await selectRow(tester, 3);

      verifyOnSelectedEvent(
        mock: mock,
        expectedSelectedRows: stateManager().refRows.sublist(0, 4),
      );
      expect(stateManager().selectedRows.length, 4);
    },
  );

  buildGrid(onSelected: mock.oneParamReturnVoid<TrinaGridOnSelectedEvent>).test(
    'When pressing shift + ctrl + home, should select all rows from current row to the first row',
    (tester) async {
      final selectFromRowId = 4;
      stateManager().setCurrentCell(
          stateManager().rows[selectFromRowId].cells['column0'],
          selectFromRowId);
      await tester.pumpAndSettle();

      await tester.sendKeyDownEvent(LogicalKeyboardKey.control);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.shift);
      await tester.sendKeyEvent(LogicalKeyboardKey.home);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shift);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.control);
      await tester.pumpAndSettle();

      expect(
        stateManager().selectedRows.length,
        selectFromRowId + 1,
      );
    },
  );

  buildGrid(onSelected: mock.oneParamReturnVoid<TrinaGridOnSelectedEvent>).test(
    'When pressing shift + ctrl + end, should select all rows from current row to the last row',
    (tester) async {
      final selectFromRowId = 4;
      stateManager().setCurrentCell(
          stateManager().rows[selectFromRowId].cells['column0'],
          selectFromRowId);
      await tester.pumpAndSettle();

      await tester.sendKeyDownEvent(LogicalKeyboardKey.control);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.shift);
      await tester.sendKeyEvent(LogicalKeyboardKey.end);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shift);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.control);
      await tester.pumpAndSettle();

      expect(
        stateManager().selectedRows.length,
        stateManager().rows.length - selectFromRowId,
      );
    },
  );

  buildGrid(onSelected: mock.oneParamReturnVoid<TrinaGridOnSelectedEvent>).test(
    'when ESC key is pressed after selecting a row, the selectedRows should be cleared',
    (tester) async {
      // Setup: select one row.
      await selectRow(tester, 0);

      expect(stateManager().selectedRows.length, 1);
      // Reset mock because selection fires an event.
      reset(mock);

      // Action: Press ESC
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();

      // Verification
      verifyOnSelectedEvent(mock: mock, expectedSelectedRows: []);
      expect(stateManager().selectedRows.length, 0);
    },
  );
}

void runRowRangeSelectionWithShiftTestCases({
  required TrinaWidgetTestHelper Function({
    int numberOfRows,
    void Function(TrinaGridOnLoadedEvent)? onLoaded,
    void Function(TrinaGridOnSelectedEvent)? onSelected,
  }) buildGrid,
  required TrinaGridStateManager Function() stateManager,
  required MockMethods mock,
  required Future<void> Function(WidgetTester tester, int rowId) selectRow,
}) {
  buildGrid(onSelected: mock.oneParamReturnVoid<TrinaGridOnSelectedEvent>).test(
    'When the first row is current row, '
    'press shift then tapping the 3rd row, '
    'the onSelected callback should contain rows 0, 1, 2.',
    (tester) async {
      await tester.sendKeyDownEvent(LogicalKeyboardKey.shift);
      await tester.tap(find.text('column0 value 2'));
      await tester.pumpAndSettle();

      verifyOnSelectedEvent(
        mock: mock,
        expectedSelectedRows: stateManager().refRows.sublist(0, 3),
      );

      expect(stateManager().selectedRows.length, 3);
    },
  );

  buildGrid(onSelected: mock.oneParamReturnVoid<TrinaGridOnSelectedEvent>).test(
    'When the first 3 rows are selected by shift+tap, '
    'selecting 4th row by mode-specific method should add it to selection',
    (tester) async {
      expect(stateManager().currentRowIdx, 0);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.shift);
      // tap on 3rd row
      await tester.tap(find.text('column0 value 2'));
      await tester.pumpAndSettle();
      expect(stateManager().selectedRows.length, 3);

      await selectRow(tester, 3);

      verifyOnSelectedEvent(
        mock: mock,
        expectedSelectedRows: stateManager().refRows.sublist(0, 4),
      );
      expect(stateManager().selectedRows.length, 4);
    },
  );
}

void runRowSelectionByLongPressTestCases({
  required TrinaWidgetTestHelper Function({
    int numberOfRows,
    void Function(TrinaGridOnLoadedEvent)? onLoaded,
    void Function(TrinaGridOnSelectedEvent)? onSelected,
  }) buildGrid,
  required TrinaGridStateManager Function() stateManager,
  required MockMethods mock,
  required Future<void> Function(WidgetTester tester, int rowId) selectRow,
}) {
  buildGrid(onSelected: mock.oneParamReturnVoid<TrinaGridOnSelectedEvent>).test(
      'When rows 2 ~ 5 are selected by drag, '
      'the onSelected callback should contain rows 2 ~ 5.', (tester) async {
    final gridHelper = BuildGridHelper();

    await gridHelper.selectRows(
      columnTitle: 'column0',
      startRowIdx: 2,
      endRowIdx: 5,
      tester: tester,
    );
    await tester.pumpAndSettle();

    verifyOnSelectedEvent(
      mock: mock,
      expectedSelectedRows: stateManager().refRows.sublist(2, 6),
    );
  });
  buildGrid(onSelected: mock.oneParamReturnVoid<TrinaGridOnSelectedEvent>).test(
      'When rows 2 ~ 5 are selected by drag, '
      'stateManager.selectedRows should contain rows 2 ~ 5.', (tester) async {
    final gridHelper = BuildGridHelper();

    await gridHelper.selectRows(
      columnTitle: 'column0',
      startRowIdx: 2,
      endRowIdx: 5,
      tester: tester,
    );
    await tester.pumpAndSettle();

    expect(
      stateManager().selectedRows,
      stateManager().refRows.sublist(2, 6),
    );
  });

  buildGrid(onSelected: mock.oneParamReturnVoid<TrinaGridOnSelectedEvent>).test(
    'When rows are drag-selected, selecting a row by mode-specific method should add it to selection.',
    (tester) async {
      final selectedRowsByDrag = 4;
      final totalSelectedRows = selectedRowsByDrag + 1;
      final gridHelper = BuildGridHelper();

      await gridHelper.selectRows(
        columnTitle: 'column0',
        startRowIdx: 2,
        endRowIdx: 5,
        tester: tester,
      );
      await tester.pumpAndSettle();
      expect(stateManager().selectedRows.length, selectedRowsByDrag);

      await selectRow(tester, 0);
      verifyOnSelectedEvent(
        mock: mock,
        expectedSelectedRows: stateManager().refRows.sublist(2, 6),
      );
      expect(stateManager().selectedRows.length, totalSelectedRows);
    },
  );
}

void runClearRowSelectionOnNavigatingViaKeyboardTestCases({
  required TrinaWidgetTestHelper Function({
    int numberOfRows,
    int numberOfCols,
    void Function(TrinaGridOnLoadedEvent)? onLoaded,
    void Function(TrinaGridOnSelectedEvent)? onSelected,
  }) buildGrid,
  required TrinaGridStateManager Function() stateManager,
  required MockMethods mock,
  required Future<void> Function(WidgetTester tester, int rowId) selectRow,
}) {
  buildGrid(onSelected: mock.oneParamReturnVoid<TrinaGridOnSelectedEvent>).test(
    'When having selected Rows, moving down with arrow key should clear selection',
    (tester) async {
      // select first row
      await selectRow(tester, 0);
      expect(stateManager().selectedRows.length, 1);
      // we need at least 2 rows to move down
      expect(stateManager().refRows.length, greaterThan(1));
      reset(mock);
      // move right
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();

      verifyOnSelectedEvent(mock: mock, expectedSelectedRows: []);
      expect(stateManager().selectedRows.length, 0);
    },
  );

  buildGrid(
    onSelected: mock.oneParamReturnVoid<TrinaGridOnSelectedEvent>,
    numberOfCols: 2,
  ).test(
      'When having selected Rows, moving right with arrow key should clear selection',
      (tester) async {
    // select first row
    await selectRow(tester, 0);
    expect(stateManager().selectedRows.length, 1);
    // we need at least 2 columns to move right
    expect(stateManager().refColumns.length, greaterThan(1));
    reset(mock);
    // move right
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pumpAndSettle();

    verifyOnSelectedEvent(mock: mock, expectedSelectedRows: []);
    expect(stateManager().selectedRows.length, 0);
  });

  buildGrid(
    onSelected: mock.oneParamReturnVoid<TrinaGridOnSelectedEvent>,
    numberOfCols: 2,
  ).test(
      'When having selected Rows, moving right with arrow key should clear selection',
      (tester) async {
    // select first row
    await selectRow(tester, 0);
    expect(stateManager().selectedRows.length, 1);
    // we need at least 2 columns to move right
    expect(stateManager().refColumns.length, greaterThan(1));
    reset(mock);
    // move right
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pumpAndSettle();

    verifyOnSelectedEvent(mock: mock, expectedSelectedRows: []);
    expect(stateManager().selectedRows.length, 0);
  });

  buildGrid(onSelected: mock.oneParamReturnVoid<TrinaGridOnSelectedEvent>).test(
      'when Enter key is pressed after selecting a row, the selectedRows should be cleared',
      (tester) async {
    // Setup: select a row.
    await selectRow(tester, 0);

    expect(stateManager().selectedRows.length, 1);
    // Reset mock because selection fires an event.
    reset(mock);

    // Action
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();

    // Verification
    verifyOnSelectedEvent(mock: mock, expectedSelectedRows: []);
    expect(stateManager().selectedRows.length, 0);
  });

  buildGrid(
    onSelected: mock.oneParamReturnVoid<TrinaGridOnSelectedEvent>,
    numberOfCols: 2,
  ).test(
      'when Tab key is pressed after selecting a row, the selectedRows should be cleared',
      (tester) async {
    // Setup: select a row.
    await selectRow(tester, 0);

    expect(stateManager().selectedRows.length, 1);
    // we need at least 2 columns to move right when tab is pressed
    expect(stateManager().refColumns.length, greaterThan(1));
    // Reset mock because selection fires an event.
    reset(mock);

    // Action: Press Tab
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pumpAndSettle();

    // Verification
    verifyOnSelectedEvent(mock: mock, expectedSelectedRows: []);
    expect(stateManager().selectedRows.length, 0);
  });

  buildGrid(
    onSelected: mock.oneParamReturnVoid<TrinaGridOnSelectedEvent>,
    numberOfCols: 2,
  ).test(
      'when home key is pressed after selecting a row, the selectedRows should be cleared',
      (tester) async {
    // Setup: scroll down then select a row.
    await tester.sendKeyEvent(LogicalKeyboardKey.pageDown);
    await tester.pumpAndSettle();
    await selectRow(tester, 8);

    expect(stateManager().selectedRows, isNotEmpty);
    // Reset mock because selection fires an event.
    reset(mock);

    // Action
    await tester.sendKeyEvent(LogicalKeyboardKey.home);
    await tester.pumpAndSettle();

    // Verification
    verifyOnSelectedEvent(mock: mock, expectedSelectedRows: []);
    expect(stateManager().selectedRows.length, 0);
  });
  buildGrid(
    onSelected: mock.oneParamReturnVoid<TrinaGridOnSelectedEvent>,
    numberOfCols: 2,
  ).test(
      'when end key is pressed after selecting a row, the selectedRows should be cleared',
      (tester) async {
    // Setup: select a row.
    await selectRow(tester, 0);

    expect(stateManager().selectedRows.length, 1);
    expect(stateManager().refColumns.length, greaterThan(1));
    // Reset mock because selection fires an event.
    reset(mock);

    // Action
    await tester.sendKeyEvent(LogicalKeyboardKey.end);
    await tester.pumpAndSettle();

    // Verification
    verifyOnSelectedEvent(mock: mock, expectedSelectedRows: []);
    expect(stateManager().selectedRows.length, 0);
  });
  buildGrid(onSelected: mock.oneParamReturnVoid<TrinaGridOnSelectedEvent>).test(
      'when pgUp key is pressed after selecting a row, the selectedRows should be cleared',
      (tester) async {
    // Setup: scroll down then select a row.
    await tester.sendKeyEvent(LogicalKeyboardKey.pageDown);
    await tester.pumpAndSettle();
    await selectRow(tester, 8);

    expect(stateManager().selectedRows, isNotEmpty);
    // Reset mock because selection fires an event.
    reset(mock);

    // Action
    await tester.sendKeyEvent(LogicalKeyboardKey.pageUp);
    await tester.pumpAndSettle();

    // Verification
    verifyOnSelectedEvent(mock: mock, expectedSelectedRows: []);
    expect(stateManager().selectedRows.length, 0);
  });
  buildGrid(onSelected: mock.oneParamReturnVoid<TrinaGridOnSelectedEvent>).test(
      'when pgDown key is pressed after selecting a row, the selectedRows should be cleared',
      (tester) async {
    // Setup: select a row.
    await selectRow(tester, 0);

    expect(stateManager().selectedRows.length, 1);
    // Reset mock because selection fires an event.
    reset(mock);

    // Action
    await tester.sendKeyEvent(LogicalKeyboardKey.pageDown);
    await tester.pumpAndSettle();

    // Verification
    verifyOnSelectedEvent(mock: mock, expectedSelectedRows: []);
    expect(stateManager().selectedRows.length, 0);
  });
}
