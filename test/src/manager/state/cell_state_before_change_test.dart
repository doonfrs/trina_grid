import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trina_grid/trina_grid.dart';

import '../../../helper/column_helper.dart';
import '../../../helper/row_helper.dart';
import '../../../mock/shared_mocks.mocks.dart';

void main() {
  TrinaGridStateManager createStateManager({
    required List<TrinaColumn> columns,
    required List<TrinaRow> rows,
    FocusNode? gridFocusNode,
    TrinaGridScrollController? scroll,
    BoxConstraints? layout,
    TrinaGridConfiguration configuration = const TrinaGridConfiguration(),
    TrinaGridMode? mode,
    bool isRTL = false,
    TrinaOnBeforeActiveCellChangeEventCallback? onBeforeActiveCellChange,
    TrinaOnActiveCellChangedEventCallback? onActiveCellChanged,
  }) {
    final stateManager = TrinaGridStateManager(
      columns: columns,
      rows: rows,
      gridFocusNode: gridFocusNode ?? MockFocusNode(),
      scroll: scroll ?? MockTrinaGridScrollController(),
      configuration: configuration,
      mode: mode,
      onBeforeActiveCellChange: onBeforeActiveCellChange,
      onActiveCellChanged: onActiveCellChanged,
    );

    stateManager.setEventManager(MockTrinaGridEventManager());
    stateManager.setTextDirection(
      isRTL ? TextDirection.rtl : TextDirection.ltr,
    );
    if (layout != null) {
      stateManager.setLayout(layout);
    }

    return stateManager;
  }

  group('onBeforeActiveCellChange callback', () {
    testWidgets(
      'When onBeforeActiveCellChange returns true, cell change should proceed',
      (WidgetTester tester) async {
        // given
        List<TrinaColumn> columns = [
          ...ColumnHelper.textColumn('col', count: 3, width: 150),
        ];

        List<TrinaRow> rows = RowHelper.count(5, columns);

        bool callbackCalled = false;
        TrinaGridOnBeforeActiveCellChangeEvent? capturedEvent;

        TrinaGridStateManager stateManager = createStateManager(
          columns: columns,
          rows: rows,
          onBeforeActiveCellChange: (event) {
            callbackCalled = true;
            capturedEvent = event;
            return true; // Allow the change
          },
        );

        stateManager.setLayout(
          const BoxConstraints(maxWidth: 500, maxHeight: 500),
        );

        // when
        stateManager.setCurrentCell(rows[0].cells['col0'], 0);
        expect(stateManager.currentCell, rows[0].cells['col0']);
        expect(stateManager.currentCellPosition!.rowIdx, 0);

        // Try to change to a different cell
        callbackCalled = false;
        stateManager.setCurrentCell(rows[2].cells['col1'], 2);

        // then
        expect(callbackCalled, isTrue);
        expect(capturedEvent, isNotNull);
        expect(capturedEvent!.oldCell, rows[0].cells['col0']);
        expect(capturedEvent!.oldRowIdx, 0);
        expect(capturedEvent!.newCell, rows[2].cells['col1']);
        expect(capturedEvent!.newRowIdx, 2);
        expect(stateManager.currentCell, rows[2].cells['col1']);
        expect(stateManager.currentCellPosition!.rowIdx, 2);
      },
    );

    testWidgets(
      'When onBeforeActiveCellChange returns false, cell change should be cancelled',
      (WidgetTester tester) async {
        // given
        List<TrinaColumn> columns = [
          ...ColumnHelper.textColumn('col', count: 3, width: 150),
        ];

        List<TrinaRow> rows = RowHelper.count(5, columns);

        bool callbackCalled = false;
        bool blockChanges = false;

        TrinaGridStateManager stateManager = createStateManager(
          columns: columns,
          rows: rows,
          onBeforeActiveCellChange: (event) {
            callbackCalled = true;
            return !blockChanges; // Cancel only when blockChanges is true
          },
        );

        stateManager.setLayout(
          const BoxConstraints(maxWidth: 500, maxHeight: 500),
        );

        // when
        // First, set the initial cell (should succeed)
        stateManager.setCurrentCell(rows[0].cells['col0'], 0);
        expect(stateManager.currentCell, rows[0].cells['col0']);
        expect(stateManager.currentCellPosition!.rowIdx, 0);

        // Now enable blocking
        blockChanges = true;
        callbackCalled = false;

        // Try to change to a different cell (should be blocked)
        stateManager.setCurrentCell(rows[2].cells['col1'], 2);

        // then
        expect(callbackCalled, isTrue);
        // Cell should not have changed
        expect(stateManager.currentCell, rows[0].cells['col0']);
        expect(stateManager.currentCellPosition!.rowIdx, 0);
      },
    );

    testWidgets(
      'When onBeforeActiveCellChange is not set, cell change should proceed normally',
      (WidgetTester tester) async {
        // given
        List<TrinaColumn> columns = [
          ...ColumnHelper.textColumn('col', count: 3, width: 150),
        ];

        List<TrinaRow> rows = RowHelper.count(5, columns);

        TrinaGridStateManager stateManager = createStateManager(
          columns: columns,
          rows: rows,
          onBeforeActiveCellChange: null, // No callback
        );

        stateManager.setLayout(
          const BoxConstraints(maxWidth: 500, maxHeight: 500),
        );

        // when
        stateManager.setCurrentCell(rows[0].cells['col0'], 0);
        expect(stateManager.currentCell, rows[0].cells['col0']);

        stateManager.setCurrentCell(rows[2].cells['col1'], 2);

        // then
        expect(stateManager.currentCell, rows[2].cells['col1']);
        expect(stateManager.currentCellPosition!.rowIdx, 2);
      },
    );

    testWidgets('Validation scenario: prevent row change if validation fails', (
      WidgetTester tester,
    ) async {
      // given
      List<TrinaColumn> columns = [
        ...ColumnHelper.textColumn('col', count: 3, width: 150),
      ];

      List<TrinaRow> rows = RowHelper.count(5, columns);

      // Simulate validation: only allow navigation from row 0 to row 1
      TrinaGridStateManager stateManager = createStateManager(
        columns: columns,
        rows: rows,
        onBeforeActiveCellChange: (event) {
          // Allow initial cell selection
          if (event.oldRowIdx == null) {
            return true;
          }

          // Allow navigation from row 0 to row 1
          if (event.oldRowIdx == 0 && event.newRowIdx == 1) {
            return true; // Allow
          }

          // Prevent other row changes
          if (event.oldRowIdx != event.newRowIdx) {
            return false; // Cancel row changes except 0->1
          }

          return true; // Allow same-row navigation
        },
      );

      stateManager.setLayout(
        const BoxConstraints(maxWidth: 500, maxHeight: 500),
      );

      // when
      stateManager.setCurrentCell(rows[0].cells['col0'], 0);
      expect(stateManager.currentCellPosition!.rowIdx, 0);

      // Try to navigate to row 1 (should succeed)
      stateManager.setCurrentCell(rows[1].cells['col0'], 1);
      expect(stateManager.currentCellPosition!.rowIdx, 1);

      // Try to navigate to row 2 (should fail)
      stateManager.setCurrentCell(rows[2].cells['col0'], 2);
      expect(stateManager.currentCellPosition!.rowIdx, 1); // Still at row 1

      // Try to navigate to a different cell in same row (should succeed)
      stateManager.setCurrentCell(rows[1].cells['col1'], 1);
      expect(stateManager.currentCellPosition!.rowIdx, 1);
      expect(stateManager.currentCellPosition!.columnIdx, 1);
    });

    testWidgets(
      'When onBeforeActiveCellChange cancels change, onActiveCellChanged should not be called',
      (WidgetTester tester) async {
        // given
        List<TrinaColumn> columns = [
          ...ColumnHelper.textColumn('col', count: 3, width: 150),
        ];

        List<TrinaRow> rows = RowHelper.count(5, columns);

        bool beforeCallbackCalled = false;
        bool afterCallbackCalled = false;
        bool blockChanges = false;

        TrinaGridStateManager stateManager = createStateManager(
          columns: columns,
          rows: rows,
          onBeforeActiveCellChange: (event) {
            beforeCallbackCalled = true;
            return !blockChanges; // Cancel only when blockChanges is true
          },
          onActiveCellChanged: (event) {
            afterCallbackCalled = true;
          },
        );

        stateManager.setLayout(
          const BoxConstraints(maxWidth: 500, maxHeight: 500),
        );

        // when
        // First, set initial cell
        stateManager.setCurrentCell(rows[0].cells['col0'], 0);
        expect(stateManager.currentCell, rows[0].cells['col0']);

        // Reset flags and enable blocking
        beforeCallbackCalled = false;
        afterCallbackCalled = false;
        blockChanges = true;

        // Try to change to a different cell (should be blocked)
        stateManager.setCurrentCell(rows[2].cells['col1'], 2);

        // then
        expect(beforeCallbackCalled, isTrue);
        expect(afterCallbackCalled, isFalse); // Should not be called
        expect(stateManager.currentCell, rows[0].cells['col0']); // No change
      },
    );

    testWidgets(
      'When onBeforeActiveCellChange allows change, onActiveCellChanged should be called',
      (WidgetTester tester) async {
        // given
        List<TrinaColumn> columns = [
          ...ColumnHelper.textColumn('col', count: 3, width: 150),
        ];

        List<TrinaRow> rows = RowHelper.count(5, columns);

        bool beforeCallbackCalled = false;
        bool afterCallbackCalled = false;

        TrinaGridStateManager stateManager = createStateManager(
          columns: columns,
          rows: rows,
          onBeforeActiveCellChange: (event) {
            beforeCallbackCalled = true;
            return true; // Allow the change
          },
          onActiveCellChanged: (event) {
            afterCallbackCalled = true;
          },
        );

        stateManager.setLayout(
          const BoxConstraints(maxWidth: 500, maxHeight: 500),
        );

        // when
        stateManager.setCurrentCell(rows[0].cells['col0'], 0);
        expect(stateManager.currentCell, rows[0].cells['col0']);

        // Reset flags
        beforeCallbackCalled = false;
        afterCallbackCalled = false;

        // Try to change to a different cell
        stateManager.setCurrentCell(rows[2].cells['col1'], 2);

        // then
        expect(beforeCallbackCalled, isTrue);
        expect(afterCallbackCalled, isTrue); // Should be called
        expect(stateManager.currentCell, rows[2].cells['col1']); // Changed
      },
    );

    testWidgets('Event should contain correct old and new cell information', (
      WidgetTester tester,
    ) async {
      // given
      List<TrinaColumn> columns = [
        ...ColumnHelper.textColumn('col', count: 3, width: 150),
      ];

      List<TrinaRow> rows = RowHelper.count(5, columns);

      TrinaGridOnBeforeActiveCellChangeEvent? firstEvent;
      TrinaGridOnBeforeActiveCellChangeEvent? secondEvent;

      TrinaGridStateManager stateManager = createStateManager(
        columns: columns,
        rows: rows,
        onBeforeActiveCellChange: (event) {
          if (firstEvent == null) {
            firstEvent = event;
          } else {
            secondEvent = event;
          }
          return true;
        },
      );

      stateManager.setLayout(
        const BoxConstraints(maxWidth: 500, maxHeight: 500),
      );

      // when
      // First cell selection (no previous cell)
      stateManager.setCurrentCell(rows[0].cells['col0'], 0);

      // Second cell selection (previous cell exists)
      stateManager.setCurrentCell(rows[2].cells['col1'], 2);

      // then
      expect(firstEvent, isNotNull);
      expect(firstEvent!.oldCell, isNull); // No previous cell
      expect(firstEvent!.oldRowIdx, isNull); // No previous row
      expect(firstEvent!.newCell, rows[0].cells['col0']);
      expect(firstEvent!.newRowIdx, 0);

      expect(secondEvent, isNotNull);
      expect(secondEvent!.oldCell, rows[0].cells['col0']);
      expect(secondEvent!.oldRowIdx, 0);
      expect(secondEvent!.newCell, rows[2].cells['col1']);
      expect(secondEvent!.newRowIdx, 2);
    });

    testWidgets(
      'Callback should not be invoked when trying to set the same cell',
      (WidgetTester tester) async {
        // given
        List<TrinaColumn> columns = [
          ...ColumnHelper.textColumn('col', count: 3, width: 150),
        ];

        List<TrinaRow> rows = RowHelper.count(5, columns);

        int callbackCount = 0;

        TrinaGridStateManager stateManager = createStateManager(
          columns: columns,
          rows: rows,
          onBeforeActiveCellChange: (event) {
            callbackCount++;
            return true;
          },
        );

        stateManager.setLayout(
          const BoxConstraints(maxWidth: 500, maxHeight: 500),
        );

        // when
        stateManager.setCurrentCell(rows[0].cells['col0'], 0);
        expect(callbackCount, 1);

        // Try to set the same cell again
        stateManager.setCurrentCell(rows[0].cells['col0'], 0);

        // then
        expect(callbackCount, 1); // Should not be called again
      },
    );

    testWidgets('Callback should not be invoked for invalid cell parameters', (
      WidgetTester tester,
    ) async {
      // given
      List<TrinaColumn> columns = [
        ...ColumnHelper.textColumn('col', count: 3, width: 150),
      ];

      List<TrinaRow> rows = RowHelper.count(5, columns);

      int callbackCount = 0;

      TrinaGridStateManager stateManager = createStateManager(
        columns: columns,
        rows: rows,
        onBeforeActiveCellChange: (event) {
          callbackCount++;
          return true;
        },
      );

      stateManager.setLayout(
        const BoxConstraints(maxWidth: 500, maxHeight: 500),
      );

      // when
      // Try to set with null cell
      stateManager.setCurrentCell(null, 0);
      expect(callbackCount, 0);

      // Try to set with null rowIdx
      stateManager.setCurrentCell(rows[0].cells['col0'], null);
      expect(callbackCount, 0);

      // Try to set with invalid rowIdx
      stateManager.setCurrentCell(rows[0].cells['col0'], -1);
      expect(callbackCount, 0);

      stateManager.setCurrentCell(rows[0].cells['col0'], 999);
      expect(callbackCount, 0);

      // then
      expect(callbackCount, 0); // Should never be called for invalid params
    });
  });
}
