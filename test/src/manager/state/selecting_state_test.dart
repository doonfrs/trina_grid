import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
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
  }) {
    final stateManager = TrinaGridStateManager(
      columns: columns,
      rows: rows,
      gridFocusNode: gridFocusNode ?? MockFocusNode(),
      scroll: scroll ?? MockTrinaGridScrollController(),
      configuration: configuration,
    );

    stateManager.setEventManager(MockTrinaGridEventManager());

    if (layout != null) {
      stateManager.setLayout(layout);
    }

    return stateManager;
  }

  group('currentSelectingPositionList', () {
    testWidgets('selectingMode.Row status'
        'should return an empty array.', (WidgetTester tester) async {
      // given
      List<TrinaColumn> columns = [
        ...ColumnHelper.textColumn('text', count: 3, width: 150),
      ];

      List<TrinaRow> rows = RowHelper.count(5, columns);

      TrinaGridStateManager stateManager = createStateManager(
        columns: columns,
        rows: rows,
        gridFocusNode: null,
        scroll: null,
        layout: const BoxConstraints(maxHeight: 300, maxWidth: 50),
      );

      stateManager.setSelectingMode(TrinaGridSelectingMode.row);

      stateManager.setCurrentSelectingRowsByRange(1, 2);

      // when
      final currentSelectingPositionList =
          stateManager.currentSelectingPositionList;

      // then
      expect(currentSelectingPositionList.length, 0);
    });

    testWidgets('selectingMode.Square status'
        '(1, 3) ~ (2, 4) selection should return 4 selected cells.', (
      WidgetTester tester,
    ) async {
      // given
      List<TrinaColumn> columns = [
        ...ColumnHelper.textColumn('text', count: 3, width: 150),
      ];

      List<TrinaRow> rows = RowHelper.count(5, columns);

      TrinaGridStateManager stateManager = createStateManager(
        columns: columns,
        rows: rows,
        gridFocusNode: null,
        scroll: null,
        layout: const BoxConstraints(maxHeight: 300, maxWidth: 50),
      );

      stateManager.setSelectingMode(TrinaGridSelectingMode.cell);

      final currentCell = rows[3].cells['text1'];

      stateManager.setCurrentCell(currentCell, 3);

      stateManager.setCurrentSelectingPosition(
        cellPosition: const TrinaGridCellPosition(columnIdx: 2, rowIdx: 4),
      );

      // when
      final currentSelectingPositionList =
          stateManager.currentSelectingPositionList;

      // then
      expect(currentSelectingPositionList.length, 4);
      expect(currentSelectingPositionList[0].rowIdx, 3);
      expect(currentSelectingPositionList[0].field, 'text1');
      expect(currentSelectingPositionList[1].rowIdx, 3);
      expect(currentSelectingPositionList[1].field, 'text2');
      expect(currentSelectingPositionList[2].rowIdx, 4);
      expect(currentSelectingPositionList[2].field, 'text1');
      expect(currentSelectingPositionList[3].rowIdx, 4);
      expect(currentSelectingPositionList[3].field, 'text2');
    });
  });

  group('currentSelectingText', () {
    testWidgets('WHEN'
        'selectingMode.Row'
        'currentSelectingRows.length > 0'
        'THEN'
        'The values of the selected rows should be returned.', (
      WidgetTester tester,
    ) async {
      // given
      List<TrinaColumn> columns = [
        ...ColumnHelper.textColumn('text', count: 3, width: 150),
      ];

      List<TrinaRow> rows = RowHelper.count(5, columns);

      TrinaGridStateManager stateManager = createStateManager(
        columns: columns,
        rows: rows,
        gridFocusNode: null,
        scroll: null,
        layout: const BoxConstraints(maxHeight: 300, maxWidth: 50),
      );

      stateManager.setSelectingMode(TrinaGridSelectingMode.row);

      stateManager.setCurrentSelectingRowsByRange(1, 2);

      // when
      final currentSelectingText = stateManager.currentSelectingText;

      final transformedSelectingText =
          TrinaClipboardTransformation.stringToList(currentSelectingText);

      // then
      expect(transformedSelectingText[0][0], rows[1].cells['text0']!.value);
      expect(transformedSelectingText[0][1], rows[1].cells['text1']!.value);
      expect(transformedSelectingText[0][2], rows[1].cells['text2']!.value);

      expect(transformedSelectingText[1][0], rows[2].cells['text0']!.value);
      expect(transformedSelectingText[1][1], rows[2].cells['text1']!.value);
      expect(transformedSelectingText[1][2], rows[2].cells['text2']!.value);
    });

    testWidgets(
      'WHEN'
      'selectingMode.Row'
      'currentSelectingRows.length > 0'
      'THEN'
      'The value of the row selected with toggleSelectingRow should be returned.',
      (WidgetTester tester) async {
        // given
        List<TrinaColumn> columns = [
          ...ColumnHelper.textColumn('text', count: 3, width: 150),
        ];

        List<TrinaRow> rows = RowHelper.count(5, columns);

        TrinaGridStateManager stateManager = createStateManager(
          columns: columns,
          rows: rows,
          gridFocusNode: null,
          scroll: null,
          layout: const BoxConstraints(maxHeight: 300, maxWidth: 50),
        );

        stateManager.setSelectingMode(TrinaGridSelectingMode.row);

        stateManager.toggleSelectingRow(1);
        stateManager.toggleSelectingRow(3);

        // when
        final currentSelectingText = stateManager.currentSelectingText;

        final transformedSelectingText =
            TrinaClipboardTransformation.stringToList(currentSelectingText);

        // then
        expect(transformedSelectingText[0][0], rows[1].cells['text0']!.value);
        expect(transformedSelectingText[0][1], rows[1].cells['text1']!.value);
        expect(transformedSelectingText[0][2], rows[1].cells['text2']!.value);

        expect(
          transformedSelectingText[1][0],
          isNot(rows[2].cells['text0']!.value),
        );
        expect(
          transformedSelectingText[1][1],
          isNot(rows[2].cells['text1']!.value),
        );
        expect(
          transformedSelectingText[1][2],
          isNot(rows[2].cells['text2']!.value),
        );

        expect(transformedSelectingText[1][0], rows[3].cells['text0']!.value);
        expect(transformedSelectingText[1][1], rows[3].cells['text1']!.value);
        expect(transformedSelectingText[1][2], rows[3].cells['text2']!.value);
      },
    );

    testWidgets(
      'WHEN'
      'selectingMode.Row'
      'currentSelectingRows.length == 0'
      'currentCellPosition == null'
      'currentSelectingPosition == null'
      'THEN'
      'The values of the selected rows should be returned as an empty value.',
      (WidgetTester tester) async {
        // given
        List<TrinaColumn> columns = [
          ...ColumnHelper.textColumn('text', count: 3, width: 150),
        ];

        List<TrinaRow> rows = RowHelper.count(5, columns);

        TrinaGridStateManager stateManager = createStateManager(
          columns: columns,
          rows: rows,
          gridFocusNode: null,
          scroll: null,
          layout: const BoxConstraints(maxHeight: 300, maxWidth: 50),
        );

        stateManager.setSelectingMode(TrinaGridSelectingMode.row);

        // when
        final currentSelectingText = stateManager.currentSelectingText;

        // then
        expect(currentSelectingText, '');
      },
    );

    testWidgets('WHEN'
        'selectingMode.Row'
        'currentSelectingRows.length > 0'
        'has frozen column In a state of sufficient width'
        'THEN'
        'The values of the selected rows should be returned.', (
      WidgetTester tester,
    ) async {
      // given
      List<TrinaColumn> columns = [
        ...ColumnHelper.textColumn(
          'left',
          count: 1,
          width: 150,
          frozen: TrinaColumnFrozen.start,
        ),
        ...ColumnHelper.textColumn('text', count: 3, width: 150),
        ...ColumnHelper.textColumn(
          'right',
          count: 1,
          width: 150,
          frozen: TrinaColumnFrozen.end,
        ),
      ];

      List<TrinaRow> rows = RowHelper.count(5, columns);

      TrinaGridStateManager stateManager = createStateManager(
        columns: columns,
        rows: rows,
        gridFocusNode: null,
        scroll: null,
        layout: const BoxConstraints(maxHeight: 500, maxWidth: 600),
      );

      stateManager.setSelectingMode(TrinaGridSelectingMode.row);

      stateManager.setCurrentSelectingRowsByRange(1, 2);

      // when
      final currentSelectingText = stateManager.currentSelectingText;

      final transformedSelectingText =
          TrinaClipboardTransformation.stringToList(currentSelectingText);

      // then
      expect(stateManager.showFrozenColumn, true);

      expect(transformedSelectingText[0][0], rows[1].cells['left0']!.value);
      expect(transformedSelectingText[0][1], rows[1].cells['text0']!.value);
      expect(transformedSelectingText[0][2], rows[1].cells['text1']!.value);
      expect(transformedSelectingText[0][3], rows[1].cells['text2']!.value);
      expect(transformedSelectingText[0][4], rows[1].cells['right0']!.value);

      expect(transformedSelectingText[1][0], rows[2].cells['left0']!.value);
      expect(transformedSelectingText[1][1], rows[2].cells['text0']!.value);
      expect(transformedSelectingText[1][2], rows[2].cells['text1']!.value);
      expect(transformedSelectingText[1][3], rows[2].cells['text2']!.value);
      expect(transformedSelectingText[1][4], rows[2].cells['right0']!.value);
    });

    testWidgets('WHEN'
        'selectingMode.Row'
        'currentSelectingRows.length > 0'
        'has frozen column In a narrow area'
        'THEN'
        'The values of the selected rows should be returned.', (
      WidgetTester tester,
    ) async {
      // given
      List<TrinaColumn> columns = [
        ...ColumnHelper.textColumn(
          'left',
          count: 1,
          width: 150,
          frozen: TrinaColumnFrozen.start,
        ),
        ...ColumnHelper.textColumn('text', count: 3, width: 150),
        ...ColumnHelper.textColumn(
          'right',
          count: 1,
          width: 150,
          frozen: TrinaColumnFrozen.end,
        ),
      ];

      List<TrinaRow> rows = RowHelper.count(5, columns);

      TrinaGridStateManager stateManager = createStateManager(
        columns: columns,
        rows: rows,
        gridFocusNode: null,
        scroll: null,
        // 최소 넓이(고정 컬럼 2개 + TrinaDefaultSettings.bodyMinWidth) 부족
        layout: const BoxConstraints(maxHeight: 500, maxWidth: 400),
      );

      stateManager.setSelectingMode(TrinaGridSelectingMode.row);

      stateManager.setCurrentSelectingRowsByRange(1, 2);

      // when
      final currentSelectingText = stateManager.currentSelectingText;

      final transformedSelectingText =
          TrinaClipboardTransformation.stringToList(currentSelectingText);

      // then
      expect(stateManager.showFrozenColumn, false);

      expect(transformedSelectingText[0][0], rows[1].cells['left0']!.value);
      expect(transformedSelectingText[0][1], rows[1].cells['text0']!.value);
      expect(transformedSelectingText[0][2], rows[1].cells['text1']!.value);
      expect(transformedSelectingText[0][3], rows[1].cells['text2']!.value);
      expect(transformedSelectingText[0][4], rows[1].cells['right0']!.value);

      expect(transformedSelectingText[1][0], rows[2].cells['left0']!.value);
      expect(transformedSelectingText[1][1], rows[2].cells['text0']!.value);
      expect(transformedSelectingText[1][2], rows[2].cells['text1']!.value);
      expect(transformedSelectingText[1][3], rows[2].cells['text2']!.value);
      expect(transformedSelectingText[1][4], rows[2].cells['right0']!.value);
    });

    testWidgets('WHEN'
        'selectingMode.Square'
        'currentSelectingRows.length == 0'
        'currentCellPosition != null'
        'currentSelectingPosition != null'
        'THEN'
        'The values of the selected cells should be returned.', (
      WidgetTester tester,
    ) async {
      // given
      List<TrinaColumn> columns = [
        ...ColumnHelper.textColumn('text', count: 3, width: 150),
      ];

      List<TrinaRow> rows = RowHelper.count(5, columns);

      TrinaGridStateManager stateManager = createStateManager(
        columns: columns,
        rows: rows,
        gridFocusNode: null,
        scroll: null,
        layout: const BoxConstraints(maxHeight: 300, maxWidth: 50),
      );

      stateManager.setSelectingMode(TrinaGridSelectingMode.cell);

      final currentCell = rows[3].cells['text1'];

      stateManager.setCurrentCell(currentCell, 3);

      stateManager.setCurrentSelectingPosition(
        cellPosition: const TrinaGridCellPosition(columnIdx: 2, rowIdx: 4),
      );

      // when
      final currentSelectingText = stateManager.currentSelectingText;

      // then
      expect(
        currentSelectingText,
        'text1 value 3\ttext2 value 3\ntext1 value 4\ttext2 value 4',
      );
    });
  });

  group('setSelecting', () {
    testWidgets('When selectingMode is None, should not change isSelecting.', (
      WidgetTester tester,
    ) async {
      // given
      List<TrinaColumn> columns = [
        ...ColumnHelper.textColumn('text', count: 3, width: 150),
      ];

      TrinaGridStateManager stateManager = createStateManager(
        columns: columns,
        rows: [],
        gridFocusNode: null,
        scroll: null,
        layout: const BoxConstraints(maxHeight: 500, maxWidth: 400),
      );

      stateManager.setSelectingMode(TrinaGridSelectingMode.none);

      expect(stateManager.isSelecting, false);
      // when
      stateManager.setSelecting(true);

      // then
      expect(stateManager.isSelecting, false);
    });

    testWidgets('When selectingMode is Square'
        'and currentCell is null'
        'then isSelecting should not change.', (WidgetTester tester) async {
      // given
      List<TrinaColumn> columns = [
        ...ColumnHelper.textColumn('text', count: 3, width: 150),
      ];

      TrinaGridStateManager stateManager = createStateManager(
        columns: columns,
        rows: [],
        gridFocusNode: null,
        scroll: null,
        layout: const BoxConstraints(maxHeight: 500, maxWidth: 400),
      );

      stateManager.setSelectingMode(TrinaGridSelectingMode.cell);

      expect(stateManager.currentCell, null);
      expect(stateManager.isSelecting, false);
      // when
      stateManager.setSelecting(true);

      // then
      expect(stateManager.isSelecting, false);
    });

    testWidgets('When selectingMode is Row'
        'and currentCell is null'
        'then isSelecting should not change.', (WidgetTester tester) async {
      // given
      List<TrinaColumn> columns = [
        ...ColumnHelper.textColumn('text', count: 3, width: 150),
      ];

      TrinaGridStateManager stateManager = createStateManager(
        columns: columns,
        rows: [],
        gridFocusNode: null,
        scroll: null,
        layout: const BoxConstraints(maxHeight: 500, maxWidth: 400),
      );

      stateManager.setSelectingMode(TrinaGridSelectingMode.row);

      expect(stateManager.currentCell, null);
      expect(stateManager.isSelecting, false);
      // when
      stateManager.setSelecting(true);

      // then
      expect(stateManager.isSelecting, false);
    });

    testWidgets('When selectingMode is Row'
        'and currentCell is not null'
        'then isSelecting should change.', (WidgetTester tester) async {
      // given
      List<TrinaColumn> columns = [
        ...ColumnHelper.textColumn('text', count: 3, width: 150),
      ];

      List<TrinaRow> rows = RowHelper.count(10, columns);

      TrinaGridStateManager stateManager = createStateManager(
        columns: columns,
        rows: rows,
        gridFocusNode: null,
        scroll: null,
        layout: const BoxConstraints(maxHeight: 500, maxWidth: 400),
      );

      stateManager.setSelectingMode(TrinaGridSelectingMode.row);
      stateManager.setCurrentCell(rows.first.cells['text1'], 0);

      expect(stateManager.currentCell, isNot(null));
      expect(stateManager.isSelecting, false);
      // when
      stateManager.setSelecting(true);

      // then
      expect(stateManager.isSelecting, true);
    });

    testWidgets('When selectingMode is Row'
        'and currentCell is not null'
        'then isSelecting should change.'
        'isEditing is true then isEditing should change to false.', (
      WidgetTester tester,
    ) async {
      // given
      List<TrinaColumn> columns = [
        ...ColumnHelper.textColumn('text', count: 3, width: 150),
      ];

      List<TrinaRow> rows = RowHelper.count(10, columns);

      TrinaGridStateManager stateManager = createStateManager(
        columns: columns,
        rows: rows,
        gridFocusNode: null,
        scroll: null,
        layout: const BoxConstraints(maxHeight: 500, maxWidth: 400),
      );

      stateManager.setSelectingMode(TrinaGridSelectingMode.row);
      stateManager.setCurrentCell(rows.first.cells['text1'], 0);
      stateManager.setEditing(true);

      expect(stateManager.currentCell, isNot(null));
      expect(stateManager.isEditing, true);
      expect(stateManager.isSelecting, false);
      // when
      stateManager.setSelecting(true);

      // then
      expect(stateManager.isSelecting, true);
      expect(stateManager.isEditing, false);
    });
  });

  group('clearCurrentSelectingPosition', () {
    testWidgets('When currentSelectingPosition is not null'
        'then currentSelectingPosition should be null.', (
      WidgetTester tester,
    ) async {
      // given
      List<TrinaColumn> columns = [
        ...ColumnHelper.textColumn('text', count: 3, width: 150),
      ];

      List<TrinaRow> rows = RowHelper.count(10, columns);

      TrinaGridStateManager stateManager = createStateManager(
        columns: columns,
        rows: rows,
        gridFocusNode: null,
        scroll: null,
        layout: const BoxConstraints(maxHeight: 500, maxWidth: 400),
      );

      // when
      stateManager.setCurrentCell(rows.first.cells['text1'], 0);

      stateManager.setCurrentSelectingPosition(
        cellPosition: const TrinaGridCellPosition(columnIdx: 0, rowIdx: 1),
      );

      expect(stateManager.currentSelectingPosition, isNot(null));

      stateManager.clearCurrentSelecting();

      // then
      expect(stateManager.currentSelectingPosition, null);
    });
  });

  group('clearCurrentSelectingRows', () {
    testWidgets('When currentSelectingRows is not empty'
        'then currentSelectingRows should be empty.', (
      WidgetTester tester,
    ) async {
      // given
      List<TrinaColumn> columns = [
        ...ColumnHelper.textColumn('text', count: 3, width: 150),
      ];

      List<TrinaRow> rows = RowHelper.count(10, columns);

      TrinaGridStateManager stateManager = createStateManager(
        columns: columns,
        rows: rows,
        gridFocusNode: null,
        scroll: null,
        layout: const BoxConstraints(maxHeight: 500, maxWidth: 400),
      );

      // when
      stateManager.setSelectingMode(TrinaGridSelectingMode.row);

      stateManager.toggleSelectingRow(1);

      expect(stateManager.currentSelectingRows.length, 1);

      stateManager.clearCurrentSelecting();

      // then
      expect(stateManager.currentSelectingRows.length, 0);
    });
  });

  group('setAllCurrentSelecting', () {
    testWidgets('When rows is null'
        'then currentCell should be null.', (WidgetTester tester) async {
      // given
      List<TrinaColumn> columns = [
        ...ColumnHelper.textColumn('text', count: 3, width: 150),
      ];

      TrinaGridStateManager stateManager = createStateManager(
        columns: columns,
        rows: [],
        gridFocusNode: null,
        scroll: null,
        layout: const BoxConstraints(maxHeight: 500, maxWidth: 400),
      );

      // when
      stateManager.setAllCurrentSelecting();

      // then
      expect(stateManager.currentCell, null);
      expect(stateManager.currentSelectingPosition, null);
      expect(stateManager.currentSelectingRows.length, 0);
    });

    testWidgets('When rows.length < 1'
        'then currentCell should be null.', (WidgetTester tester) async {
      // given
      List<TrinaColumn> columns = [
        ...ColumnHelper.textColumn('text', count: 3, width: 150),
      ];

      TrinaGridStateManager stateManager = createStateManager(
        columns: columns,
        rows: [],
        gridFocusNode: null,
        scroll: null,
        layout: const BoxConstraints(maxHeight: 500, maxWidth: 400),
      );

      // when
      stateManager.setAllCurrentSelecting();

      // then
      expect(stateManager.currentCell, null);
      expect(stateManager.currentSelectingPosition, null);
      expect(stateManager.currentSelectingRows.length, 0);
    });

    testWidgets('When selectingMode is Square'
        'and rows.length > 0'
        'then current cell should be first cell, '
        'selected cell position should be last cell position.', (
      WidgetTester tester,
    ) async {
      // given
      List<TrinaColumn> columns = [
        ...ColumnHelper.textColumn('text', count: 3, width: 150),
      ];

      List<TrinaRow> rows = RowHelper.count(5, columns);

      TrinaGridStateManager stateManager = createStateManager(
        columns: columns,
        rows: rows,
        gridFocusNode: null,
        scroll: null,
        layout: const BoxConstraints(maxHeight: 500, maxWidth: 400),
      );

      stateManager.setSelectingMode(TrinaGridSelectingMode.cell);

      // when
      stateManager.setAllCurrentSelecting();

      // then
      expect(stateManager.currentCell, rows.first.cells['text0']);
      expect(stateManager.currentSelectingPosition!.rowIdx, 4);
      expect(stateManager.currentSelectingPosition!.columnIdx, 2);
    });

    testWidgets('When selectingMode is Row'
        'and rows.length > 0'
        'then The number of selected rows should be correct.', (
      WidgetTester tester,
    ) async {
      // given
      List<TrinaColumn> columns = [
        ...ColumnHelper.textColumn('text', count: 3, width: 150),
      ];

      List<TrinaRow> rows = RowHelper.count(5, columns);

      TrinaGridStateManager stateManager = createStateManager(
        columns: columns,
        rows: rows,
        gridFocusNode: null,
        scroll: null,
        layout: const BoxConstraints(maxHeight: 500, maxWidth: 400),
      );

      stateManager.setSelectingMode(TrinaGridSelectingMode.row);

      // when
      stateManager.setAllCurrentSelecting();

      // then
      expect(stateManager.currentCell!.value, rows.first.cells['text0']!.value);
      expect(stateManager.currentSelectingPosition!.columnIdx, 2);
      expect(stateManager.currentSelectingPosition!.rowIdx, 4);
      expect(stateManager.currentSelectingRows.length, 5);
    });

    testWidgets('When selectingMode is None'
        'and rows.length > 0'
        'then Nothing should be selected.', (WidgetTester tester) async {
      // given
      List<TrinaColumn> columns = [
        ...ColumnHelper.textColumn('text', count: 3, width: 150),
      ];

      List<TrinaRow> rows = RowHelper.count(5, columns);

      TrinaGridStateManager stateManager = createStateManager(
        columns: columns,
        rows: rows,
        gridFocusNode: null,
        scroll: null,
        layout: const BoxConstraints(maxHeight: 500, maxWidth: 400),
      );

      stateManager.setSelectingMode(TrinaGridSelectingMode.none);

      // when
      stateManager.setAllCurrentSelecting();

      // then
      expect(stateManager.currentCell, null);
      expect(stateManager.currentSelectingPosition, null);
      expect(stateManager.currentSelectingRows.length, 0);
    });
  });

  group('setCurrentSelectingPosition', () {
    testWidgets('When selectingMode is Row'
        'then currentRowIdx, rowIdx should be set to currentSelectingRows.', (
      WidgetTester tester,
    ) async {
      // given
      List<TrinaColumn> columns = [
        ...ColumnHelper.textColumn('text', count: 3, width: 150),
      ];

      List<TrinaRow> rows = RowHelper.count(5, columns);

      TrinaGridStateManager stateManager = createStateManager(
        columns: columns,
        rows: rows,
        gridFocusNode: null,
        scroll: null,
        layout: const BoxConstraints(maxHeight: 500, maxWidth: 400),
      );

      stateManager.setSelectingMode(TrinaGridSelectingMode.row);

      stateManager.setCurrentCell(rows[3].cells['text1'], 3);

      stateManager.setCurrentSelectingPosition(
        cellPosition: const TrinaGridCellPosition(columnIdx: 1, rowIdx: 4),
      );

      // then
      // Rows 3 and 4 are selected.
      expect(stateManager.currentSelectingRows.length, 2);

      final List<Key> keys = stateManager.currentSelectingRows
          .map((e) => e.key)
          .toList();

      expect(keys.contains(rows[3].key), isTrue);
      expect(keys.contains(rows[4].key), isTrue);
    });
  });

  group('toggleSelectingRow', () {
    testWidgets('When selectingMode is Row'
        'and the row is already selected'
        'then it should be removed.', (WidgetTester tester) async {
      // given
      List<TrinaColumn> columns = [
        ...ColumnHelper.textColumn('text', count: 3, width: 150),
      ];

      List<TrinaRow> rows = RowHelper.count(5, columns);

      TrinaGridStateManager stateManager = createStateManager(
        columns: columns,
        rows: rows,
        gridFocusNode: null,
        scroll: null,
        layout: const BoxConstraints(maxHeight: 500, maxWidth: 400),
      );

      stateManager.setSelectingMode(TrinaGridSelectingMode.row);

      stateManager.toggleSelectingRow(3);

      expect(stateManager.isSelectedRow(rows[3].key), true);

      stateManager.toggleSelectingRow(3);
      // then

      expect(stateManager.isSelectedRow(rows[3].key), false);
    });
  });

  group('isSelectingInteraction', () {
    testWidgets('When selectingMode is None'
        'then isSelectingInteraction should return false.', (
      WidgetTester tester,
    ) async {
      // given
      List<TrinaColumn> columns = [
        ...ColumnHelper.textColumn('text', count: 3, width: 150),
      ];

      List<TrinaRow> rows = RowHelper.count(5, columns);

      TrinaGridStateManager stateManager = createStateManager(
        columns: columns,
        rows: rows,
        gridFocusNode: null,
        scroll: null,
        layout: const BoxConstraints(maxHeight: 500, maxWidth: 400),
      );

      // when
      stateManager.setSelectingMode(TrinaGridSelectingMode.none);

      // then
      expect(stateManager.isSelectingInteraction(), isFalse);
    });

    testWidgets('When selectingMode is not None'
        'and shift or ctrl key is not pressed'
        'then isSelectingInteraction should return false.', (
      WidgetTester tester,
    ) async {
      // given
      List<TrinaColumn> columns = [
        ...ColumnHelper.textColumn('text', count: 3, width: 150),
      ];

      List<TrinaRow> rows = RowHelper.count(5, columns);

      TrinaGridStateManager stateManager = createStateManager(
        columns: columns,
        rows: rows,
        gridFocusNode: null,
        scroll: null,
        layout: const BoxConstraints(maxHeight: 500, maxWidth: 400),
      );

      // when
      stateManager.setSelectingMode(TrinaGridSelectingMode.row);

      // then
      expect(stateManager.isSelectingInteraction(), isFalse);
    });

    testWidgets('When selectingMode is not None'
        'and shift key is pressed'
        'and currentCell is null'
        'then isSelectingInteraction should return false.', (
      WidgetTester tester,
    ) async {
      // given
      List<TrinaColumn> columns = [
        ...ColumnHelper.textColumn('text', count: 3, width: 150),
      ];

      List<TrinaRow> rows = RowHelper.count(5, columns);

      TrinaGridStateManager stateManager = createStateManager(
        columns: columns,
        rows: rows,
        gridFocusNode: null,
        scroll: null,
        layout: const BoxConstraints(maxHeight: 500, maxWidth: 400),
      );

      // when
      stateManager.setSelectingMode(TrinaGridSelectingMode.row);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.shift);

      // then
      expect(stateManager.isSelectingInteraction(), isFalse);
    });

    testWidgets('When selectingMode is not None'
        'and ctrl key is pressed'
        'and currentCell is null'
        'then isSelectingInteraction should return false.', (
      WidgetTester tester,
    ) async {
      // given
      List<TrinaColumn> columns = [
        ...ColumnHelper.textColumn('text', count: 3, width: 150),
      ];

      List<TrinaRow> rows = RowHelper.count(5, columns);

      TrinaGridStateManager stateManager = createStateManager(
        columns: columns,
        rows: rows,
        gridFocusNode: null,
        scroll: null,
        layout: const BoxConstraints(maxHeight: 500, maxWidth: 400),
      );

      // when
      stateManager.setSelectingMode(TrinaGridSelectingMode.row);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.control);

      // then
      expect(stateManager.isSelectingInteraction(), isFalse);
    });

    testWidgets('When selectingMode is not None'
        'and shift key is pressed'
        'and currentCell is not null'
        'then isSelectingInteraction should return true.', (
      WidgetTester tester,
    ) async {
      // given
      List<TrinaColumn> columns = [
        ...ColumnHelper.textColumn('text', count: 3, width: 150),
      ];

      List<TrinaRow> rows = RowHelper.count(5, columns);

      TrinaGridStateManager stateManager = createStateManager(
        columns: columns,
        rows: rows,
        gridFocusNode: null,
        scroll: null,
        layout: const BoxConstraints(maxHeight: 500, maxWidth: 400),
      );

      // when
      stateManager.setSelectingMode(TrinaGridSelectingMode.row);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.shift);
      stateManager.setCurrentCell(rows.first.cells['text0'], 0);

      // then
      expect(stateManager.isSelectingInteraction(), isTrue);
    });

    testWidgets('When selectingMode is not None'
        'and ctrl key is pressed'
        'and currentCell is not null'
        'then isSelectingInteraction should return true.', (
      WidgetTester tester,
    ) async {
      // given
      List<TrinaColumn> columns = [
        ...ColumnHelper.textColumn('text', count: 3, width: 150),
      ];

      List<TrinaRow> rows = RowHelper.count(5, columns);

      TrinaGridStateManager stateManager = createStateManager(
        columns: columns,
        rows: rows,
        gridFocusNode: null,
        scroll: null,
        layout: const BoxConstraints(maxHeight: 500, maxWidth: 400),
      );

      // when
      stateManager.setSelectingMode(TrinaGridSelectingMode.cell);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.control);
      stateManager.setCurrentCell(rows.first.cells['text0'], 0);

      // then
      expect(stateManager.isSelectingInteraction(), isTrue);
    });
  });

  group('isSelectedCell', () {
    testWidgets('When nothing is selected, all cells should be false', (
      WidgetTester tester,
    ) async {
      // given
      List<TrinaColumn> columns = [
        ...ColumnHelper.textColumn('text', count: 3, width: 150),
      ];

      List<TrinaRow> rows = RowHelper.count(5, columns);

      TrinaGridStateManager stateManager = createStateManager(
        columns: columns,
        rows: rows,
        gridFocusNode: null,
        scroll: null,
        layout: const BoxConstraints(maxHeight: 500, maxWidth: 400),
      );

      // when
      expect(stateManager.selectingMode.isCell, isTrue);

      // then
      for (var i = 0; i < rows.length; i += 1) {
        for (var column in columns) {
          expect(
            stateManager.isSelectedCell(
              rows[i].cells[column.field]!,
              column,
              i,
            ),
            false,
          );
        }
      }
    });

    testWidgets('WHEN '
        'current cell is 0th row, 0th column, '
        '0th row, 1st column is selected. '
        'THEN '
        'the cell should be true.', (WidgetTester tester) async {
      // given
      List<TrinaColumn> columns = [
        ...ColumnHelper.textColumn('text', count: 3, width: 150),
      ];

      List<TrinaRow> rows = RowHelper.count(5, columns);

      TrinaGridStateManager stateManager = createStateManager(
        columns: columns,
        rows: rows,
        gridFocusNode: null,
        scroll: null,
        layout: const BoxConstraints(maxHeight: 500, maxWidth: 400),
      );

      stateManager.setCurrentCell(stateManager.firstCell, 0);

      stateManager.setCurrentSelectingPosition(
        cellPosition: const TrinaGridCellPosition(columnIdx: 1, rowIdx: 0),
      );

      // when
      expect(stateManager.selectingMode.isCell, isTrue);

      // then
      for (var i = 0; i < rows.length; i += 1) {
        for (var column in columns) {
          if (i == 0 && (column.field == 'text0' || column.field == 'text1')) {
            expect(
              stateManager.isSelectedCell(
                rows[i].cells[column.field]!,
                column,
                i,
              ),
              true,
            );
          } else {
            expect(
              stateManager.isSelectedCell(
                rows[i].cells[column.field]!,
                column,
                i,
              ),
              false,
            );
          }
        }
      }
    });

    testWidgets('WHEN '
        'current cell is 1st row, 1st column, '
        '3rd row, 2nd column is selected. '
        'THEN '
        'the cell should be true.', (WidgetTester tester) async {
      // given
      List<TrinaColumn> columns = [
        ...ColumnHelper.textColumn('text', count: 3, width: 150),
      ];

      List<TrinaRow> rows = RowHelper.count(5, columns);

      TrinaGridStateManager stateManager = createStateManager(
        columns: columns,
        rows: rows,
        gridFocusNode: null,
        scroll: null,
        layout: const BoxConstraints(maxHeight: 500, maxWidth: 400),
      );

      stateManager.setCurrentCell(rows[1].cells['text1'], 1);

      stateManager.setCurrentSelectingPosition(
        cellPosition: const TrinaGridCellPosition(rowIdx: 3, columnIdx: 2),
      );

      // when
      expect(stateManager.selectingMode.isCell, isTrue);

      // then
      for (var i = 0; i < rows.length; i += 1) {
        for (var column in columns) {
          if ((i >= 1 && i <= 3) &&
              (column.field == 'text1' || column.field == 'text2')) {
            expect(
              stateManager.isSelectedCell(
                rows[i].cells[column.field]!,
                column,
                i,
              ),
              true,
            );
          } else {
            expect(
              stateManager.isSelectedCell(
                rows[i].cells[column.field]!,
                column,
                i,
              ),
              false,
            );
          }
        }
      }
    });
  });

  group('handleAfterSelectingRow', () {
    testWidgets('When enableMoveDownAfterSelecting is false'
        'then cell value change should not move to the next row.', (
      WidgetTester tester,
    ) async {
      // given
      List<TrinaColumn> columns = [
        ...ColumnHelper.textColumn('text', count: 3, width: 150),
      ];

      List<TrinaRow> rows = RowHelper.count(5, columns);

      TrinaGridStateManager stateManager = createStateManager(
        columns: columns,
        rows: rows,
        gridFocusNode: FocusNode(),
        scroll: null,
        configuration: const TrinaGridConfiguration(
          enableMoveDownAfterSelecting: false,
        ),
      );

      stateManager.setLayout(
        const BoxConstraints(maxHeight: 500, maxWidth: 400),
      );

      stateManager.setCurrentCell(rows[1].cells['text1'], 1);

      stateManager.setCurrentSelectingPosition(
        cellPosition: const TrinaGridCellPosition(rowIdx: 3, columnIdx: 2),
      );

      // when
      expect(stateManager.currentCellPosition!.rowIdx, 1);

      stateManager.handleAfterSelectingRow(
        rows[1].cells['text1']!,
        'new value',
      );

      // then
      expect(stateManager.currentCellPosition!.rowIdx, 1);
    });

    testWidgets('When enableMoveDownAfterSelecting is true'
        'then cell value change should move to the next row.', (
      WidgetTester tester,
    ) async {
      // given
      List<TrinaColumn> columns = [
        ...ColumnHelper.textColumn('text', count: 3, width: 150),
      ];

      List<TrinaRow> rows = RowHelper.count(5, columns);

      final vertical = MockLinkedScrollControllerGroup();

      when(vertical.offset).thenReturn(0);

      TrinaGridStateManager stateManager = createStateManager(
        columns: columns,
        rows: rows,
        gridFocusNode: FocusNode(),
        scroll: TrinaGridScrollController(
          vertical: vertical,
          horizontal: MockLinkedScrollControllerGroup(),
        ),
        configuration: const TrinaGridConfiguration(
          enableMoveDownAfterSelecting: true,
        ),
        layout: const BoxConstraints(maxHeight: 500, maxWidth: 400),
      );

      stateManager.setCurrentCell(rows[1].cells['text1'], 1);

      stateManager.setCurrentSelectingPosition(
        cellPosition: const TrinaGridCellPosition(rowIdx: 3, columnIdx: 2),
      );

      // when
      expect(stateManager.currentCellPosition!.rowIdx, 1);

      stateManager.handleAfterSelectingRow(
        rows[1].cells['text1']!,
        'new value',
      );

      // then
      expect(stateManager.currentCellPosition!.rowIdx, 2);
    });
  });
}
