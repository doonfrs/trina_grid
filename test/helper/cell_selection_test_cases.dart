import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:trina_grid/trina_grid.dart';

import '../helper/build_grid_helper.dart';
import '../mock/mock_methods.dart';
import 'on_selected_helper.dart';
import 'trina_widget_test_helper.dart';

void runGeneralCellSelectionTestCases({
  required TrinaWidgetTestHelper Function({
    int numberOfRows,
    int numberOfCols,
    void Function(TrinaGridOnLoadedEvent)? onLoaded,
    void Function(TrinaGridOnSelectedEvent)? onSelected,
  }) buildGrid,
  required TrinaGridStateManager Function() stateManager,
  required Future<void> Function(WidgetTester tester, String cellValue)
      selectCell,
}) {
  buildGrid().test(
    'the first cell is set as current cell',
    (tester) async {
      expect(stateManager().currentCell, isNot(null));
      expect(stateManager().currentCellPosition?.rowIdx, 0);
      expect(stateManager().currentCellPosition?.columnIdx, 0);
    },
  );

  buildGrid(numberOfRows: 0).test(
    'When there are no rows, no error should occur and the grid should be focused',
    (tester) async {
      expect(stateManager().refRows.length, 0);
      expect(stateManager().currentCell, null);
      expect(stateManager().hasFocus, true);
    },
  );

  buildGrid(numberOfCols: 3).test(
    'When multiple cells are selected, stateManager.selectedCells should equal to the selected cells',
    (tester) async {
      expect(stateManager().currentCellPosition?.rowIdx, 0);

      await selectCell(tester, 'column0 value 0');
      await selectCell(tester, 'column1 value 1');
      await selectCell(tester, 'column2 value 2');

      expect(stateManager().selectedCells.length, 3);
      expect(stateManager().selectedCells.first.value, 'column0 value 0');
      expect(stateManager().selectedCells[1].value, 'column1 value 1');
      expect(stateManager().selectedCells.last.value, 'column2 value 2');
    },
  );
}

void runCellSelectionWithKeyboardTestCases({
  required TrinaWidgetTestHelper Function({
    int numberOfRows,
    int numberOfCols,
    void Function(TrinaGridOnLoadedEvent)? onLoaded,
    void Function(TrinaGridOnSelectedEvent)? onSelected,
  }) buildGrid,
  required TrinaGridStateManager Function() stateManager,
  required MockMethods mock,
  required Future<void> Function(WidgetTester tester, String cellValue)
      selectCell,
}) {
  buildGrid(
    onSelected: mock.oneParamReturnVoid<TrinaGridOnSelectedEvent>,
    numberOfCols: 4,
  ).test(
    'When the first cell is current cell, '
    'press shift + arrowRight 3 times, '
    'the onSelected callback should contain cells 0, 1, 2, 3.',
    (tester) async {
      await tester.sendKeyDownEvent(LogicalKeyboardKey.shift);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pumpAndSettle();
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shift);
      await tester.pumpAndSettle();

      verifyOnSelectedEvent(
        mock: mock,
        expectedSelectedCells: stateManager().selectedCells,
      );

      expect(stateManager().selectedCells.length, 4);
    },
  );
  buildGrid(
    onSelected: mock.oneParamReturnVoid<TrinaGridOnSelectedEvent>,
  ).test(
    'When the first cell is current cell, '
    'press shift + arrowDown 3 times, '
    'the onSelected callback should contain cells 0, 1, 2, 3.',
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
        expectedSelectedCells: stateManager().selectedCells,
      );

      expect(stateManager().selectedCells.length, 4);
    },
  );

  buildGrid(
    onSelected: mock.oneParamReturnVoid<TrinaGridOnSelectedEvent>,
    numberOfCols: 4,
  ).test(
    'When the first 3 cells are selected by shift+arrowRight, '
    'selecting 4th cell by mode-specific method should add it to selection',
    (tester) async {
      // The first cell should is current cell, so it should be included in selection.
      expect(stateManager().currentCellPosition?.columnIdx, 0);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.shift);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pumpAndSettle();
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shift);
      await tester.pumpAndSettle();

      await selectCell(tester, 'column3 value 0');

      verifyOnSelectedEvent(
        mock: mock,
        expectedSelectedCells: stateManager().selectedCells,
      );
      expect(stateManager().selectedCells.length, 4);
    },
  );
  buildGrid(
    onSelected: mock.oneParamReturnVoid<TrinaGridOnSelectedEvent>,
    numberOfCols: 4,
  ).test(
    'When the first 3 cells are selected by shift+arrowDown, '
    'selecting 4th cell by mode-specific method should add it to selection',
    (tester) async {
      // The first cell should is current cell, so it should be included in selection.
      expect(stateManager().currentCellPosition?.columnIdx, 0);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.shift);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shift);
      await tester.pumpAndSettle();

      await selectCell(tester, 'column3 value 0');

      verifyOnSelectedEvent(
        mock: mock,
        expectedSelectedCells: stateManager().selectedCells,
      );
      expect(stateManager().selectedCells.length, 4);
    },
  );

  buildGrid(onSelected: mock.oneParamReturnVoid<TrinaGridOnSelectedEvent>).test(
    'When pressing shift + ctrl + home, should select all cells from current cell to the first cell',
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
        stateManager().selectedCells.length,
        stateManager().currentCellPosition!.rowIdx! *
                stateManager().columns.length +
            stateManager().currentCellPosition!.columnIdx! +
            1,
      );
    },
  );

  buildGrid(onSelected: mock.oneParamReturnVoid<TrinaGridOnSelectedEvent>).test(
    'When pressing shift + ctrl + end, should select all cells from current cell to the last cell',
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
        stateManager().selectedCells.length,
        (stateManager().rows.length -
                    stateManager().currentCellPosition!.rowIdx!) *
                stateManager().columns.length -
            stateManager().currentCellPosition!.columnIdx!,
      );
    },
  );

  buildGrid(onSelected: mock.oneParamReturnVoid<TrinaGridOnSelectedEvent>).test(
    'when ESC key is pressed after selecting a cell, the selectedCells should be cleared',
    (tester) async {
      // Setup: select one cell.
      await selectCell(tester, 'column0 value 0');

      expect(stateManager().selectedCells.length, 1);
      // Reset mock because selection fires an event.
      reset(mock);

      // Action: Press ESC
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();

      // Verification
      verifyOnSelectedEvent(mock: mock, expectedSelectedCells: []);
      expect(stateManager().selectedCells.length, 0);
    },
  );

  buildGrid(onSelected: mock.oneParamReturnVoid<TrinaGridOnSelectedEvent>).test(
    'when Enter key is pressed after selecting a cell, the selectedCells should be cleared',
    (tester) async {
      // Setup: select one cell.
      await selectCell(tester, 'column0 value 0');

      expect(stateManager().selectedCells.length, 1);
      // Reset mock because selection fires an event.
      reset(mock);

      // Action: Press ESC
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();

      // Verification
      verifyOnSelectedEvent(mock: mock, expectedSelectedCells: []);
      expect(stateManager().selectedCells.length, 0);
    },
  );
}

void runCellRangeSelectionWithShiftTestCases({
  required TrinaWidgetTestHelper Function({
    int numberOfRows,
    int numberOfCols,
    void Function(TrinaGridOnLoadedEvent)? onLoaded,
    void Function(TrinaGridOnSelectedEvent)? onSelected,
  }) buildGrid,
  required TrinaGridStateManager Function() stateManager,
  required MockMethods mock,
  required Future<void> Function(WidgetTester tester, String cellValue)
      selectCell,
}) {
  buildGrid(
    numberOfCols: 3,
    onSelected: mock.oneParamReturnVoid<TrinaGridOnSelectedEvent>,
  ).test(
    'When the first cell is current cell, '
    'press shift then tapping the 3rd cell, '
    'the onSelected callback should contain cells 0, 1, 2.',
    (tester) async {
      await tester.sendKeyDownEvent(LogicalKeyboardKey.shift);
      await tester.tap(find.text('column2 value 0'));
      await tester.pumpAndSettle();

      verifyOnSelectedEvent(
        mock: mock,
        expectedSelectedCells: stateManager().selectedCells,
      );

      expect(stateManager().selectedCells.length, 3);
    },
  );

  buildGrid(
    onSelected: mock.oneParamReturnVoid<TrinaGridOnSelectedEvent>,
    numberOfCols: 4,
  ).test(
    'When the first 3 cells are selected by shift+tap, '
    'selecting 4th cell by mode-specific method should add it to selection',
    (tester) async {
      expect(stateManager().currentCellPosition?.columnIdx, 0);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.shift);
      // tap on 3rd cell
      await tester.tap(find.text('column2 value 0'));
      await tester.pumpAndSettle();
      expect(stateManager().selectedCells.length, 3);

      await selectCell(tester, 'column3 value 0');

      verifyOnSelectedEvent(
        mock: mock,
        expectedSelectedCells: stateManager().selectedCells,
      );
      expect(stateManager().selectedCells.length, 4);
    },
  );
}

void runCellSelectionByLongPressTestCases({
  required TrinaWidgetTestHelper Function({
    int numberOfRows,
    void Function(TrinaGridOnLoadedEvent)? onLoaded,
    void Function(TrinaGridOnSelectedEvent)? onSelected,
  }) buildGrid,
  required TrinaGridStateManager Function() stateManager,
  required MockMethods mock,
  required Future<void> Function(WidgetTester tester, String cellValue)
      selectCell,
}) {
  buildGrid(onSelected: mock.oneParamReturnVoid<TrinaGridOnSelectedEvent>).test(
      'When cells (2, 0) ~ (5, 0) are selected by drag, '
      'the onSelected callback should contain cells (2, 0) ~ (5, 0).',
      (tester) async {
    final gridHelper = BuildGridHelper();

    await gridHelper.selectCells(
      startCellValue: 'column0 value 2',
      endCellValue: 'column0 value 5',
      tester: tester,
    );
    await tester.pumpAndSettle();

    verifyOnSelectedEvent(
      mock: mock,
      expectedSelectedCells: stateManager().selectedCells,
    );
  });
  buildGrid(onSelected: mock.oneParamReturnVoid<TrinaGridOnSelectedEvent>).test(
      'When cells (2, 0) ~ (5, 0) are selected by drag, '
      'stateManager.selectedCells should contain cells (2, 0) ~ (5, 0).',
      (tester) async {
    final gridHelper = BuildGridHelper();

    await gridHelper.selectCells(
      startCellValue: 'column0 value 2',
      endCellValue: 'column0 value 5',
      tester: tester,
    );
    await tester.pumpAndSettle();

    expect(
      stateManager().selectedCells.length,
      4,
    );
  });

  buildGrid(onSelected: mock.oneParamReturnVoid<TrinaGridOnSelectedEvent>).test(
    'When cells are drag-selected, selecting a cell by mode-specific method should add it to selection.',
    (tester) async {
      final selectedCellsByDrag = 4;
      final totalSelectedCells = selectedCellsByDrag + 1;
      final gridHelper = BuildGridHelper();

      await gridHelper.selectCells(
        startCellValue: 'column0 value 2',
        endCellValue: 'column0 value 5',
        tester: tester,
      );
      await tester.pumpAndSettle();
      expect(stateManager().selectedCells.length, selectedCellsByDrag);

      await selectCell(tester, 'column0 value 0');
      verifyOnSelectedEvent(
        mock: mock,
        expectedSelectedCells: stateManager().selectedCells,
      );
      expect(stateManager().selectedCells.length, totalSelectedCells);
    },
  );
}
