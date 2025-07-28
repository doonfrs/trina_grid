import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:trina_grid/trina_grid.dart';

import '../../helper/column_helper.dart';
import '../../helper/cell_selection_test_cases.dart';
import '../../helper/trina_widget_test_helper.dart';
import '../../helper/row_helper.dart';
import '../../mock/mock_methods.dart';

void main() {
  late TrinaGridStateManager stateManager;

  final MockMethods mock = MockMethods();

  setUp(() {
    reset(mock);
  });

  buildGrid({
    int numberOfRows = 10,
    int numberOfCols = 1,
    bool autoSetFirstCellAsCurrent = true,
    void Function(TrinaGridOnLoadedEvent)? onLoaded,
    void Function(TrinaGridOnSelectedEvent)? onSelected,
    required TrinaGridSelectingMode selectingMode,
  }) {
    // given
    final columns = ColumnHelper.textColumn('column', count: numberOfCols);
    final rows = RowHelper.count(numberOfRows, columns);

    return TrinaWidgetTestHelper(
      'build with selecting cells.',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Material(
              child: TrinaGrid(
                columns: columns,
                rows: rows,
                onLoaded: (TrinaGridOnLoadedEvent event) {
                  stateManager = event.stateManager;
                  if (onLoaded != null) onLoaded(event);
                },
                onSelected: onSelected,
                configuration: TrinaGridConfiguration(
                  selectingMode: selectingMode,
                  autoSetFirstCellAsCurrent: autoSetFirstCellAsCurrent,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  group('cell selecting mode', () {
    selectCell(WidgetTester tester, String cellValue) async {
      await tester.sendKeyDownEvent(LogicalKeyboardKey.control);

      await tester.tap(find.text(cellValue), kind: PointerDeviceKind.mouse);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.control);
      await tester.pumpAndSettle();
    }

    /// Builds a grid with `selectingMode` set to TrinaGridSelectingMode.cell
    buildGridHelper({
      int numberOfRows = 10,
      int numberOfCols = 1,
      void Function(TrinaGridOnLoadedEvent)? onLoaded,
      void Function(TrinaGridOnSelectedEvent)? onSelected,
    }) {
      return buildGrid(
        numberOfCols: numberOfCols,
        numberOfRows: numberOfRows,
        onLoaded: onLoaded,
        onSelected: onSelected,
        selectingMode: TrinaGridSelectingMode.cell,
      );
    }

    runGeneralCellSelectionTestCases(
      stateManager: () => stateManager,
      buildGrid: buildGridHelper,
      selectCell: selectCell,
    );

    runCellSelectionWithKeyboardTestCases(
      stateManager: () => stateManager,
      buildGrid: buildGridHelper,
      mock: mock,
      selectCell: selectCell,
    );

    runCellSelectionByLongPressTestCases(
      stateManager: () => stateManager,
      buildGrid: buildGridHelper,
      mock: mock,
      selectCell: selectCell,
    );

    runCellRangeSelectionWithShiftTestCases(
      stateManager: () => stateManager,
      buildGrid: buildGridHelper,
      mock: mock,
      selectCell: selectCell,
    );

    runClearCellSelectionOnNavigatingViaKeyboardTestCases(
      buildGrid: buildGridHelper,
      stateManager: () => stateManager,
      mock: mock,
      selectCell: selectCell,
    );

    buildGridHelper().test(
      'when currently selecting cells, tapping on a cell should clear selection',
      (tester) async {
        // select first cell
        await selectCell(tester, 'column0 value 0');
        expect(stateManager.selectedCells.length, 1);
        // tap on a cell
        await tester.tap(find.text('column0 value 0'));
        await tester.pumpAndSettle();

        expect(stateManager.selectedCells.length, 0);
      },
    );
  });
}
