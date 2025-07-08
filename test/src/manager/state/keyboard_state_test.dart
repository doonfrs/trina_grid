import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:trina_grid/trina_grid.dart';

import '../../../helper/column_helper.dart';
import '../../../helper/trina_widget_test_helper.dart';
import '../../../helper/row_helper.dart';
import '../../../mock/shared_mocks.mocks.dart';

void main() {
  late List<TrinaColumn> columns;

  late List<TrinaRow> rows;

  TrinaGridScrollController scrollController;

  TrinaGridEventManager eventManager;

  LinkedScrollControllerGroup horizontal;

  LinkedScrollControllerGroup vertical;

  late TrinaGridStateManager stateManager;

  final withColumnAndRows =
      TrinaWidgetTestHelper('With 10 columns and 10 rows, ', (tester) async {
    columns = [
      ...ColumnHelper.textColumn('column', count: 10, width: 100),
    ];

    rows = RowHelper.count(10, columns);

    scrollController = MockTrinaGridScrollController();

    eventManager = MockTrinaGridEventManager();

    horizontal = MockLinkedScrollControllerGroup();

    vertical = MockLinkedScrollControllerGroup();

    when(scrollController.verticalOffset).thenReturn(100);

    when(scrollController.maxScrollHorizontal).thenReturn(0);

    when(scrollController.maxScrollVertical).thenReturn(0);

    when(scrollController.horizontal).thenReturn(horizontal);

    when(scrollController.vertical).thenReturn(vertical);

    stateManager = TrinaGridStateManager(
      columns: columns,
      rows: rows,
      gridFocusNode: MockFocusNode(),
      scroll: scrollController,
    );
    stateManager.setEventManager(eventManager);
    when(stateManager.eventManager?.stateManager).thenReturn(stateManager);
    stateManager.setLayout(const BoxConstraints(maxWidth: 500, maxHeight: 500));
  });

  group('moveCurrentCellToEdgeOfColumns', () {
    withColumnAndRows.test(
      'When TrinaMoveDirection is Up, no cell should be selected',
      (tester) async {
        stateManager.moveCurrentCellToEdgeOfColumns(TrinaMoveDirection.up);

        expect(stateManager.currentCell, isNull);
      },
    );

    withColumnAndRows.test(
      'When TrinaMoveDirection is Down, no cell should be selected',
      (tester) async {
        stateManager.moveCurrentCellToEdgeOfColumns(TrinaMoveDirection.down);

        expect(stateManager.currentCell, isNull);
      },
    );

    withColumnAndRows.test(
      'When currentCell is null, no cell should be selected',
      (tester) async {
        expect(stateManager.currentCell, isNull);

        stateManager.moveCurrentCellToEdgeOfColumns(TrinaMoveDirection.left);

        expect(stateManager.currentCell, isNull);
      },
    );

    withColumnAndRows.test(
      'When isEditing is true, cell should not move',
      (tester) async {
        stateManager.setCurrentCell(stateManager.firstCell, 0);

        stateManager.setEditing(true);

        expect(stateManager.isEditing, isTrue);

        expect(stateManager.currentCellPosition!.columnIdx, 0);
        expect(stateManager.currentCellPosition!.rowIdx, 0);

        stateManager.moveCurrentCellToEdgeOfColumns(TrinaMoveDirection.right);

        expect(stateManager.currentCellPosition!.columnIdx, 0);
        expect(stateManager.currentCellPosition!.rowIdx, 0);
      },
    );

    withColumnAndRows.test(
      'When isEditing is true but force is true, cell should move',
      (tester) async {
        stateManager.setCurrentCell(stateManager.firstCell, 0);

        stateManager.setEditing(true);

        expect(stateManager.isEditing, isTrue);

        expect(stateManager.currentCellPosition!.columnIdx, 0);
        expect(stateManager.currentCellPosition!.rowIdx, 0);

        stateManager.moveCurrentCellToEdgeOfColumns(
          TrinaMoveDirection.right,
          force: true,
        );

        expect(stateManager.currentCellPosition!.columnIdx, 9);
        expect(stateManager.currentCellPosition!.rowIdx, 0);
      },
    );

    withColumnAndRows.test(
      'When TrinaMoveDirection is Left, should move to leftmost cell',
      (tester) async {
        stateManager.setCurrentCell(rows.first.cells['column3'], 0);

        stateManager.setEditing(false);

        expect(stateManager.isEditing, isFalse);

        expect(stateManager.currentCellPosition!.columnIdx, 3);
        expect(stateManager.currentCellPosition!.rowIdx, 0);

        stateManager.moveCurrentCellToEdgeOfColumns(
          TrinaMoveDirection.left,
        );

        expect(stateManager.currentCellPosition!.columnIdx, 0);
        expect(stateManager.currentCellPosition!.rowIdx, 0);
      },
    );

    withColumnAndRows.test(
      'When TrinaMoveDirection is Right, should move to rightmost cell',
      (tester) async {
        stateManager.setCurrentCell(rows.first.cells['column3'], 0);

        stateManager.setEditing(false);

        expect(stateManager.isEditing, isFalse);

        expect(stateManager.currentCellPosition!.columnIdx, 3);
        expect(stateManager.currentCellPosition!.rowIdx, 0);

        stateManager.moveCurrentCellToEdgeOfColumns(
          TrinaMoveDirection.right,
        );

        expect(stateManager.currentCellPosition!.columnIdx, 9);
        expect(stateManager.currentCellPosition!.rowIdx, 0);
      },
    );
  });

  group('moveCurrentCellToEdgeOfRows', () {
    withColumnAndRows.test(
      'When TrinaMoveDirection is Left, no cell should be selected',
      (tester) async {
        stateManager.moveCurrentCellToEdgeOfRows(TrinaMoveDirection.left);

        expect(stateManager.currentCell, isNull);
      },
    );

    withColumnAndRows.test(
      'When TrinaMoveDirection is Right, no cell should be selected',
      (tester) async {
        stateManager.moveCurrentCellToEdgeOfRows(TrinaMoveDirection.right);

        expect(stateManager.currentCell, isNull);
      },
    );

    withColumnAndRows.test(
      'When isEditing is true, cell should not move',
      (tester) async {
        stateManager.setCurrentCell(stateManager.firstCell, 0);

        stateManager.setEditing(true);

        expect(stateManager.isEditing, isTrue);

        expect(stateManager.currentCellPosition!.columnIdx, 0);
        expect(stateManager.currentCellPosition!.rowIdx, 0);

        stateManager.moveCurrentCellToEdgeOfRows(TrinaMoveDirection.down);

        expect(stateManager.currentCellPosition!.columnIdx, 0);
        expect(stateManager.currentCellPosition!.rowIdx, 0);
      },
    );

    withColumnAndRows.test(
      'When isEditing is true but force is true, cell should move',
      (tester) async {
        stateManager.setCurrentCell(stateManager.firstCell, 0);

        stateManager.setEditing(true);

        expect(stateManager.isEditing, isTrue);

        expect(stateManager.currentCellPosition!.columnIdx, 0);
        expect(stateManager.currentCellPosition!.rowIdx, 0);

        stateManager.moveCurrentCellToEdgeOfRows(
          TrinaMoveDirection.down,
          force: true,
        );

        expect(stateManager.currentCellPosition!.columnIdx, 0);
        expect(stateManager.currentCellPosition!.rowIdx, 9);
      },
    );

    withColumnAndRows.test(
      'When TrinaMoveDirection is Up, should move to topmost row',
      (tester) async {
        stateManager.setCurrentCell(stateManager.rows[4].cells['column7'], 4);

        stateManager.setEditing(false);

        expect(stateManager.isEditing, isFalse);

        expect(stateManager.currentCellPosition!.columnIdx, 7);
        expect(stateManager.currentCellPosition!.rowIdx, 4);

        stateManager.moveCurrentCellToEdgeOfRows(
          TrinaMoveDirection.up,
        );

        expect(stateManager.currentCellPosition!.columnIdx, 7);
        expect(stateManager.currentCellPosition!.rowIdx, 0);
      },
    );

    withColumnAndRows.test(
      'When TrinaMoveDirection is Down, should move to bottommost row',
      (tester) async {
        stateManager.setCurrentCell(stateManager.rows[4].cells['column7'], 4);

        stateManager.setEditing(false);

        expect(stateManager.isEditing, isFalse);

        expect(stateManager.currentCellPosition!.columnIdx, 7);
        expect(stateManager.currentCellPosition!.rowIdx, 4);

        stateManager.moveCurrentCellToEdgeOfRows(
          TrinaMoveDirection.down,
        );

        expect(stateManager.currentCellPosition!.columnIdx, 7);
        expect(stateManager.currentCellPosition!.rowIdx, 9);
      },
    );
  });

  group('moveCurrentCellByRowIdx', () {
    withColumnAndRows.test(
      'When TrinaMoveDirection is Left, no cell should be selected',
      (tester) async {
        stateManager.moveCurrentCellByRowIdx(0, TrinaMoveDirection.left);

        expect(stateManager.currentCell, isNull);
      },
    );

    withColumnAndRows.test(
      'When TrinaMoveDirection is Right, no cell should be selected',
      (tester) async {
        stateManager.moveCurrentCellByRowIdx(0, TrinaMoveDirection.right);

        expect(stateManager.currentCell, isNull);
      },
    );

    withColumnAndRows.test(
      'When rowIdx is less than 0, should move to row 0',
      (tester) async {
        stateManager.moveCurrentCellByRowIdx(-1, TrinaMoveDirection.down);

        expect(stateManager.currentCellPosition!.rowIdx, 0);
        expect(stateManager.currentCellPosition!.columnIdx, 0);
      },
    );

    withColumnAndRows.test(
      'When rowIdx is greater than total rows, should move to last row',
      (tester) async {
        stateManager.moveCurrentCellByRowIdx(11, TrinaMoveDirection.down);

        expect(stateManager.currentCellPosition!.rowIdx, 9);
        expect(stateManager.currentCellPosition!.columnIdx, 0);
      },
    );
  });

  group('moveSelectingCellToEdgeOfColumns', () {
    withColumnAndRows.test(
      'When TrinaMoveDirection is Up, no cell should be selected',
      (tester) async {
        stateManager.moveSelectingCellToEdgeOfColumns(TrinaMoveDirection.up);

        expect(stateManager.currentSelectingPosition, isNull);
      },
    );

    withColumnAndRows.test(
      'When TrinaMoveDirection is Down, no cell should be selected',
      (tester) async {
        stateManager.moveSelectingCellToEdgeOfColumns(TrinaMoveDirection.down);

        expect(stateManager.currentSelectingPosition, isNull);
      },
    );

    withColumnAndRows.test(
      'When isEditing is true, cell should not be selected',
      (tester) async {
        stateManager.setCurrentCell(stateManager.firstCell, 0);

        stateManager.setEditing(true);

        expect(stateManager.isEditing, isTrue);

        expect(stateManager.currentSelectingPosition, isNull);

        stateManager.moveSelectingCellToEdgeOfColumns(TrinaMoveDirection.right);

        expect(stateManager.currentSelectingPosition, isNull);
      },
    );

    withColumnAndRows.test(
      'When isEditing is true but force is true, cell should be selected',
      (tester) async {
        stateManager.setCurrentCell(stateManager.firstCell, 0);

        stateManager.setEditing(true);

        expect(stateManager.isEditing, isTrue);

        expect(stateManager.currentSelectingPosition, isNull);

        stateManager.moveSelectingCellToEdgeOfColumns(
          TrinaMoveDirection.right,
          force: true,
        );

        expect(stateManager.currentSelectingPosition, isNotNull);
        expect(stateManager.currentSelectingPosition!.columnIdx, 9);
        expect(stateManager.currentSelectingPosition!.rowIdx, 0);
      },
    );

    withColumnAndRows.test(
      'When TrinaMoveDirection is Left, should select from current cell to leftmost cell',
      (tester) async {
        stateManager.setCurrentCell(stateManager.rows[0].cells['column3'], 0);

        stateManager.setEditing(false);

        expect(stateManager.isEditing, isFalse);

        expect(stateManager.currentSelectingPosition, isNull);

        stateManager.moveSelectingCellToEdgeOfColumns(
          TrinaMoveDirection.left,
        );

        expect(stateManager.currentCellPosition!.rowIdx, 0);
        expect(stateManager.currentCellPosition!.columnIdx, 3);

        expect(stateManager.currentSelectingPosition, isNotNull);
        expect(stateManager.currentSelectingPosition!.columnIdx, 0);
        expect(stateManager.currentSelectingPosition!.rowIdx, 0);
      },
    );

    withColumnAndRows.test(
      'When TrinaMoveDirection is Left and there is a selected cell, should move the selected cell to leftmost cell',
      (tester) async {
        stateManager.setCurrentCell(stateManager.rows[0].cells['column3'], 0);

        stateManager.setEditing(false);

        expect(stateManager.isEditing, isFalse);

        stateManager.setCurrentSelectingPosition(
          cellPosition: const TrinaGridCellPosition(
            columnIdx: 2,
            rowIdx: 0,
          ),
        );

        expect(stateManager.currentSelectingPosition, isNotNull);
        expect(stateManager.currentSelectingPosition!.columnIdx, 2);
        expect(stateManager.currentSelectingPosition!.rowIdx, 0);

        stateManager.moveSelectingCellToEdgeOfColumns(
          TrinaMoveDirection.left,
        );

        expect(stateManager.currentCellPosition!.rowIdx, 0);
        expect(stateManager.currentCellPosition!.columnIdx, 3);

        expect(stateManager.currentSelectingPosition, isNotNull);
        expect(stateManager.currentSelectingPosition!.columnIdx, 0);
        expect(stateManager.currentSelectingPosition!.rowIdx, 0);
      },
    );

    withColumnAndRows.test(
      'When TrinaMoveDirection is Right, should select from current cell to rightmost cell',
      (tester) async {
        stateManager.setCurrentCell(stateManager.rows[0].cells['column3'], 0);

        stateManager.setEditing(false);

        expect(stateManager.isEditing, isFalse);

        expect(stateManager.currentSelectingPosition, isNull);

        stateManager.moveSelectingCellToEdgeOfColumns(
          TrinaMoveDirection.right,
        );

        expect(stateManager.currentCellPosition!.rowIdx, 0);
        expect(stateManager.currentCellPosition!.columnIdx, 3);

        expect(stateManager.currentSelectingPosition, isNotNull);
        expect(stateManager.currentSelectingPosition!.columnIdx, 9);
        expect(stateManager.currentSelectingPosition!.rowIdx, 0);
      },
    );

    withColumnAndRows.test(
      'When TrinaMoveDirection is Right and there is a selected cell, should move the selected cell to rightmost cell',
      (tester) async {
        stateManager.setCurrentCell(stateManager.rows[0].cells['column3'], 0);

        stateManager.setEditing(false);

        expect(stateManager.isEditing, isFalse);

        stateManager.setCurrentSelectingPosition(
          cellPosition: const TrinaGridCellPosition(
            columnIdx: 2,
            rowIdx: 0,
          ),
        );

        expect(stateManager.currentSelectingPosition, isNotNull);
        expect(stateManager.currentSelectingPosition!.columnIdx, 2);
        expect(stateManager.currentSelectingPosition!.rowIdx, 0);

        stateManager.moveSelectingCellToEdgeOfColumns(
          TrinaMoveDirection.right,
        );

        expect(stateManager.currentCellPosition!.rowIdx, 0);
        expect(stateManager.currentCellPosition!.columnIdx, 3);

        expect(stateManager.currentSelectingPosition, isNotNull);
        expect(stateManager.currentSelectingPosition!.columnIdx, 9);
        expect(stateManager.currentSelectingPosition!.rowIdx, 0);
      },
    );
  });

  group('moveSelectingCellToEdgeOfRows', () {
    withColumnAndRows.test(
      'When TrinaMoveDirection is Left, no cell should be selected',
      (tester) async {
        stateManager.moveSelectingCellToEdgeOfRows(TrinaMoveDirection.left);

        expect(stateManager.currentSelectingPosition, isNull);
      },
    );

    withColumnAndRows.test(
      'When TrinaMoveDirection is Right, no cell should be selected',
      (tester) async {
        stateManager.moveSelectingCellToEdgeOfRows(TrinaMoveDirection.right);

        expect(stateManager.currentSelectingPosition, isNull);
      },
    );

    withColumnAndRows.test(
      'When isEditing is true, cell should not move',
      (tester) async {
        stateManager.setCurrentCell(stateManager.firstCell, 0);

        stateManager.setEditing(true);

        expect(stateManager.isEditing, isTrue);

        expect(stateManager.currentSelectingPosition, isNull);

        stateManager.moveSelectingCellToEdgeOfRows(TrinaMoveDirection.down);

        expect(stateManager.currentSelectingPosition, isNull);
      },
    );

    withColumnAndRows.test(
      'When isEditing is true but force is true, cell should move',
      (tester) async {
        stateManager.setCurrentCell(stateManager.firstCell, 0);

        stateManager.setEditing(true);

        expect(stateManager.isEditing, isTrue);

        expect(stateManager.currentSelectingPosition, isNull);

        stateManager.moveSelectingCellToEdgeOfRows(
          TrinaMoveDirection.down,
          force: true,
        );

        expect(stateManager.currentSelectingPosition, isNotNull);
        expect(stateManager.currentSelectingPosition!.columnIdx, 0);
        expect(stateManager.currentSelectingPosition!.rowIdx, 9);
      },
    );

    withColumnAndRows.test(
      'When currentSelectingPosition is null, no cell should be selected',
      (tester) async {
        stateManager.setEditing(false);

        expect(stateManager.isEditing, isFalse);

        expect(stateManager.currentSelectingPosition, isNull);

        stateManager.moveSelectingCellToEdgeOfRows(
          TrinaMoveDirection.down,
        );

        expect(stateManager.currentSelectingPosition, isNull);
      },
    );

    withColumnAndRows.test(
      'When TrinaMoveDirection is Down, should select the bottommost cell',
      (tester) async {
        stateManager.setCurrentCell(stateManager.firstCell, 0);

        stateManager.setEditing(false);

        expect(stateManager.isEditing, isFalse);

        expect(stateManager.currentSelectingPosition, isNull);

        stateManager.moveSelectingCellToEdgeOfRows(
          TrinaMoveDirection.down,
        );

        expect(stateManager.currentSelectingPosition, isNotNull);
        expect(stateManager.currentSelectingPosition!.columnIdx, 0);
        expect(stateManager.currentSelectingPosition!.rowIdx, 9);
      },
    );

    withColumnAndRows.test(
      'When TrinaMoveDirection is Up, should select the topmost cell',
      (tester) async {
        stateManager.setCurrentCell(stateManager.rows[4].cells['column3'], 4);

        stateManager.setEditing(false);

        expect(stateManager.isEditing, isFalse);

        expect(stateManager.currentSelectingPosition, isNull);

        stateManager.moveSelectingCellToEdgeOfRows(
          TrinaMoveDirection.up,
        );

        expect(stateManager.currentSelectingPosition, isNotNull);
        expect(stateManager.currentSelectingPosition!.columnIdx, 3);
        expect(stateManager.currentSelectingPosition!.rowIdx, 0);
      },
    );

    withColumnAndRows.test(
      'When TrinaMoveDirection is Down and there is a selected cell, should move the selected cell to the bottommost cell',
      (tester) async {
        stateManager.setCurrentCell(stateManager.firstCell, 0);

        stateManager.setEditing(false);

        expect(stateManager.isEditing, isFalse);

        stateManager.setCurrentSelectingPosition(
          cellPosition: const TrinaGridCellPosition(
            columnIdx: 3,
            rowIdx: 2,
          ),
        );

        expect(stateManager.currentSelectingPosition!.columnIdx, 3);
        expect(stateManager.currentSelectingPosition!.rowIdx, 2);

        stateManager.moveSelectingCellToEdgeOfRows(
          TrinaMoveDirection.down,
        );

        expect(stateManager.currentSelectingPosition, isNotNull);
        expect(stateManager.currentSelectingPosition!.columnIdx, 3);
        expect(stateManager.currentSelectingPosition!.rowIdx, 9);
      },
    );
  });

  group('moveSelectingCellByRowIdx', () {
    withColumnAndRows.test(
      'When TrinaMoveDirection is Left, no cell should be selected',
      (tester) async {
        stateManager.moveSelectingCellByRowIdx(0, TrinaMoveDirection.left);

        expect(stateManager.currentSelectingPosition, isNull);
      },
    );

    withColumnAndRows.test(
      'When TrinaMoveDirection is Right, no cell should be selected',
      (tester) async {
        stateManager.moveSelectingCellByRowIdx(0, TrinaMoveDirection.right);

        expect(stateManager.currentSelectingPosition, isNull);
      },
    );

    withColumnAndRows.test(
      'When currentCell is null, no cell should be selected',
      (tester) async {
        expect(stateManager.currentCell, isNull);

        expect(stateManager.currentSelectingPosition, isNull);

        stateManager.moveSelectingCellByRowIdx(0, TrinaMoveDirection.down);

        expect(stateManager.currentSelectingPosition, isNull);
      },
    );

    withColumnAndRows.test(
      'When rowIdx is less than 0, should select the cell at row 0',
      (tester) async {
        stateManager.setCurrentCell(stateManager.rows[3].cells['column3'], 3);

        expect(stateManager.currentCell, isNotNull);

        expect(stateManager.currentSelectingPosition, isNull);

        stateManager.moveSelectingCellByRowIdx(-1, TrinaMoveDirection.down);

        expect(stateManager.currentSelectingPosition, isNotNull);
        expect(stateManager.currentSelectingPosition!.columnIdx, 3);
        expect(stateManager.currentSelectingPosition!.rowIdx, 0);
      },
    );

    withColumnAndRows.test(
      'When rowIdx is greater than total rows, should select the cell at the last row',
      (tester) async {
        stateManager.setCurrentCell(stateManager.rows[3].cells['column3'], 3);

        expect(stateManager.currentCell, isNotNull);

        expect(stateManager.currentSelectingPosition, isNull);

        stateManager.moveSelectingCellByRowIdx(11, TrinaMoveDirection.down);

        expect(stateManager.currentSelectingPosition, isNotNull);
        expect(stateManager.currentSelectingPosition!.columnIdx, 3);
        expect(stateManager.currentSelectingPosition!.rowIdx, 9);
      },
    );

    withColumnAndRows.test(
      'When rowIdx is 3, should select the cell at row 3',
      (tester) async {
        stateManager.setCurrentCell(stateManager.firstCell, 0);

        expect(stateManager.currentCell, isNotNull);

        expect(stateManager.currentSelectingPosition, isNull);

        stateManager.moveSelectingCellByRowIdx(3, TrinaMoveDirection.down);

        expect(stateManager.currentSelectingPosition, isNotNull);
        expect(stateManager.currentSelectingPosition!.columnIdx, 0);
        expect(stateManager.currentSelectingPosition!.rowIdx, 3);
      },
    );

    withColumnAndRows.test(
      'When there is a selected cell, should maintain the column position',
      (tester) async {
        stateManager.setCurrentCell(stateManager.rows[3].cells['column3'], 0);

        expect(stateManager.currentCell, isNotNull);

        stateManager.setCurrentSelectingPosition(
          cellPosition: const TrinaGridCellPosition(
            columnIdx: 5,
            rowIdx: 3,
          ),
        );

        expect(stateManager.currentSelectingPosition!.columnIdx, 5);
        expect(stateManager.currentSelectingPosition!.rowIdx, 3);

        stateManager.moveSelectingCellByRowIdx(6, TrinaMoveDirection.down);

        expect(stateManager.currentSelectingPosition, isNotNull);
        expect(stateManager.currentSelectingPosition!.columnIdx, 5);
        expect(stateManager.currentSelectingPosition!.rowIdx, 6);
      },
    );
  });
}
