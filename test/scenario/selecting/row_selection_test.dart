import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:trina_grid/trina_grid.dart';

import '../../helper/column_helper.dart';
import '../../helper/on_selected_helper.dart';
import '../../helper/row_selection_test_cases.dart';
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
      'build with selecting rows.',
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
                    autoSetFirstCellAsCurrent: autoSetFirstCellAsCurrent),
              ),
            ),
          ),
        );
      },
    );
  }

  group('row with single tap selecting mode', () {
    selectRow(WidgetTester tester, int rowId) async {
      await tester.tap(find.text('column0 value $rowId'));
      await tester.pumpAndSettle();
    }

    selectRows(tester, {required int count}) async {
      for (var i = 0; i < count; i += 1) {
        await selectRow.call(tester, i);
      }
    }

    /// Builds a grid with `selectingMode` set to TrinaGridSelectingMode.rowWithSingleTap.
    buildGridHelper({
      int numberOfRows = 10,
      int numberOfCols = 1,
      void Function(TrinaGridOnLoadedEvent)? onLoaded,
      void Function(TrinaGridOnSelectedEvent)? onSelected,
    }) {
      return buildGrid(
        numberOfRows: numberOfRows,
        numberOfCols: numberOfCols,
        onLoaded: onLoaded,
        onSelected: onSelected,
        selectingMode: TrinaGridSelectingMode.rowWithSingleTap,
      );
    }

    runGeneralRowSelectionTestCases(
      stateManager: () => stateManager,
      buildGrid: buildGridHelper,
      selectRows: selectRows,
    );

    runRowSelectionWithKeyboardTestCases(
      stateManager: () => stateManager,
      buildGrid: buildGridHelper,
      mock: mock,
      selectRow: selectRow,
    );

    runRowSelectionByLongPressTestCases(
      stateManager: () => stateManager,
      buildGrid: buildGridHelper,
      mock: mock,
      selectRow: selectRow,
    );

    runRowRangeSelectionWithShiftTestCases(
      stateManager: () => stateManager,
      buildGrid: buildGridHelper,
      mock: mock,
      selectRow: selectRow,
    );

    runClearRowSelectionOnNavigatingViaKeyboardTestCases(
      stateManager: () => stateManager,
      buildGrid: buildGridHelper,
      mock: mock,
      selectRow: selectRow,
    );
    buildGrid(
      selectingMode: TrinaGridSelectingMode.rowWithSingleTap,
      onSelected: mock.oneParamReturnVoid<TrinaGridOnSelectedEvent>,
    ).test(
      'when tapping on a row with secondary button, '
      'the selection should be cleared',
      (tester) async {
        await selectRow(tester, 0);

        expect(stateManager.selectedRows.length, 1);
        reset(mock);

        await tester.tap(
          find.text('column0 value 1'),
          buttons: kSecondaryButton,
          kind: PointerDeviceKind.mouse,
        );
        await tester.pumpAndSettle();

        expect(stateManager.selectedRows.length, 0);
        verifyOnSelectedEvent(mock: mock, expectedSelectedRows: []);
      },
    );
    buildGridHelper(
      onSelected: mock.oneParamReturnVoid<TrinaGridOnSelectedEvent>,
    ).test(
      'when tapping on a selected row with secondary button, '
      'the selection should be cleared',
      (tester) async {
        await selectRow(tester, 0);

        expect(stateManager.selectedRows.length, 1);
        reset(mock);

        await tester.tap(
          find.text('column0 value 0'),
          buttons: kSecondaryButton,
          kind: PointerDeviceKind.mouse,
        );
        await tester.pumpAndSettle();

        expect(stateManager.selectedRows.length, 0);
        verifyOnSelectedEvent(mock: mock, expectedSelectedRows: []);
      },
    );
  });

  group('row with ctrl selecting mode', () {
    selectRow(WidgetTester tester, int rowId) async {
      await tester.sendKeyDownEvent(LogicalKeyboardKey.control);

      await tester.tap(find.text('column0 value $rowId'));
      await tester.sendKeyUpEvent(LogicalKeyboardKey.control);
      await tester.pumpAndSettle();
    }

    selectRows(tester, {required int count}) async {
      for (var i = 0; i < count; i++) {
        await selectRow(tester, i);
      }
    }

    /// Builds a grid with `selectingMode` set to TrinaGridSelectingMode.rowWithCtrl.
    buildGridHelper({
      int numberOfRows = 10,
      int numberOfCols = 1,
      void Function(TrinaGridOnLoadedEvent)? onLoaded,
      void Function(TrinaGridOnSelectedEvent)? onSelected,
    }) {
      return buildGrid(
        numberOfRows: numberOfRows,
        numberOfCols: numberOfCols,
        onLoaded: onLoaded,
        onSelected: onSelected,
        selectingMode: TrinaGridSelectingMode.rowWithCtrl,
      );
    }

    runGeneralRowSelectionTestCases(
      stateManager: () => stateManager,
      buildGrid: buildGridHelper,
      selectRows: selectRows,
    );

    runRowSelectionWithKeyboardTestCases(
      stateManager: () => stateManager,
      buildGrid: buildGridHelper,
      mock: mock,
      selectRow: selectRow,
    );

    runRowSelectionByLongPressTestCases(
      stateManager: () => stateManager,
      buildGrid: buildGridHelper,
      mock: mock,
      selectRow: selectRow,
    );

    runRowRangeSelectionWithShiftTestCases(
      stateManager: () => stateManager,
      buildGrid: buildGridHelper,
      mock: mock,
      selectRow: selectRow,
    );

    runClearRowSelectionOnNavigatingViaKeyboardTestCases(
      stateManager: () => stateManager,
      buildGrid: buildGridHelper,
      mock: mock,
      selectRow: selectRow,
    );

    buildGridHelper().test(
      'when currently selecting rows, tapping a row should clear selection',
      (tester) async {
        // select first row
        await selectRow(tester, 0);
        expect(stateManager.selectedRows.length, 1);
        // tap on a row
        await tester.tap(find.text('column0 value 0'));
        await tester.pumpAndSettle();

        expect(stateManager.selectedRows.length, 0);
      },
    );
  });
}
