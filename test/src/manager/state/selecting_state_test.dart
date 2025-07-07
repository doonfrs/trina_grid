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

  group('selectedCells', () {
    testCellSelecting(TrinaGridSelectingMode selectingMode) {
      testWidgets(
        'when selectingMode is ${selectingMode.name}, '
        '(1, 3) ~ (2, 4) selection should return 4 selected cells.',
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

          stateManager.setSelectingMode(selectingMode);

          final currentCell = rows[3].cells['text1'];

          stateManager.setCurrentCell(currentCell, 3);

          // act
          stateManager.selectCellsInRange(
            const TrinaGridCellPosition(
              columnIdx: 1,
              rowIdx: 3,
            ),
            const TrinaGridCellPosition(
              columnIdx: 2,
              rowIdx: 4,
            ),
          );

          // assert
          expect(stateManager.selectedCells.length, 4);
          expect(stateManager.isSelectedCell(rows[3].cells['text1']!), isTrue);
          expect(stateManager.isSelectedCell(rows[3].cells['text2']!), isTrue);
          expect(stateManager.isSelectedCell(rows[4].cells['text1']!), isTrue);
          expect(stateManager.isSelectedCell(rows[4].cells['text2']!), isTrue);
        },
      );
    }

    testCellSelecting(TrinaGridSelectingMode.cellWithSingleTap);
    testCellSelecting(TrinaGridSelectingMode.cellWithCtrl);

    testRowSelecting(TrinaGridSelectingMode selectingMode) {
      return testWidgets(
        'When selectingMode is ${selectingMode.name}, '
        'selectedCells should be empty.',
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

          stateManager.setSelectingMode(selectingMode);

          stateManager.selectRowsInRange(1, 2);

          // then
          expect(stateManager.selectedCells.length, 0);
        },
      );
    }

    testRowSelecting(TrinaGridSelectingMode.rowWithSingleTap);
    testRowSelecting(TrinaGridSelectingMode.rowWithCtrl);
  });

  group('currentSelectingText', () {
    testRowSelecting(TrinaGridSelectingMode selectingMode) {
      return testWidgets(
          'WHEN '
          'selectingMode.${selectingMode.name}, '
          'selectedRows.length > 0, '
          'THEN '
          'The values of the selected rows should be returned.',
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

        stateManager.setSelectingMode(selectingMode);

        stateManager.selectRowsInRange(1, 2);

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
    }

    testRowSelecting(TrinaGridSelectingMode.rowWithSingleTap);
    testRowSelecting(TrinaGridSelectingMode.rowWithCtrl);

    testRowToggleSelecting(TrinaGridSelectingMode selectingMode) {
      return testWidgets(
          'WHEN '
          'selectingMode.${selectingMode.name}, '
          'selectedRows.length > 0, '
          'THEN '
          'The value of the row selected with toggleRowSelection should be returned.',
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

        stateManager.setSelectingMode(selectingMode);

        stateManager.toggleRowSelection(1);
        stateManager.toggleRowSelection(3);

        // when
        final currentSelectingText = stateManager.currentSelectingText;

        final transformedSelectingText =
            TrinaClipboardTransformation.stringToList(currentSelectingText);

        // then
        expect(transformedSelectingText[0][0], rows[1].cells['text0']!.value);
        expect(transformedSelectingText[0][1], rows[1].cells['text1']!.value);
        expect(transformedSelectingText[0][2], rows[1].cells['text2']!.value);

        expect(transformedSelectingText[1][0],
            isNot(rows[2].cells['text0']!.value));
        expect(transformedSelectingText[1][1],
            isNot(rows[2].cells['text1']!.value));
        expect(transformedSelectingText[1][2],
            isNot(rows[2].cells['text2']!.value));

        expect(transformedSelectingText[1][0], rows[3].cells['text0']!.value);
        expect(transformedSelectingText[1][1], rows[3].cells['text1']!.value);
        expect(transformedSelectingText[1][2], rows[3].cells['text2']!.value);
      });
    }

    testRowToggleSelecting(TrinaGridSelectingMode.rowWithSingleTap);
    testRowToggleSelecting(TrinaGridSelectingMode.rowWithCtrl);

    testEmptyRowSelecting(TrinaGridSelectingMode selectingMode) {
      return testWidgets(
          'WHEN '
          'selectingMode.${selectingMode.name}, '
          'selectedRows.length == 0, '
          'currentCellPosition == null, '
          'currentSelectingPosition == null, '
          'THEN '
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

        stateManager.setSelectingMode(selectingMode);

        // when
        final currentSelectingText = stateManager.currentSelectingText;

        // then
        expect(currentSelectingText, '');
      });
    }

    testEmptyRowSelecting(TrinaGridSelectingMode.rowWithSingleTap);
    testEmptyRowSelecting(TrinaGridSelectingMode.rowWithCtrl);

    testFrozenColumnRowSelecting(TrinaGridSelectingMode selectingMode) {
      return testWidgets(
          'WHEN '
          'selectingMode.${selectingMode.name}, '
          'selectedRows.length > 0, '
          'has frozen column In a state of sufficient width, '
          'THEN '
          'The values of the selected rows should be returned.',
          (WidgetTester tester) async {
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

        stateManager.setSelectingMode(selectingMode);

        stateManager.selectRowsInRange(1, 2);

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
    }

    testFrozenColumnRowSelecting(TrinaGridSelectingMode.rowWithSingleTap);
    testFrozenColumnRowSelecting(TrinaGridSelectingMode.rowWithCtrl);

    testNarrowFrozenColumnRowSelecting(TrinaGridSelectingMode selectingMode) {
      return testWidgets(
          'WHEN '
          'selectingMode.${selectingMode.name}, '
          'selectedRows.length > 0, '
          'has frozen column In a narrow area, '
          'THEN '
          'The values of the selected rows should be returned.',
          (WidgetTester tester) async {
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

        stateManager.setSelectingMode(selectingMode);

        stateManager.selectRowsInRange(1, 2);

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
    }

    testNarrowFrozenColumnRowSelecting(TrinaGridSelectingMode.rowWithSingleTap);
    testNarrowFrozenColumnRowSelecting(TrinaGridSelectingMode.rowWithCtrl);

    testCellSelecting(TrinaGridSelectingMode selectingMode) {
      return testWidgets(
          'WHEN '
          'selectingMode.${selectingMode.name}, '
          'selectedRows.length == 0, '
          'currentCellPosition != null, '
          'currentSelectingPosition != null, '
          'THEN '
          'The values of the selected cells should be returned.',
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

        stateManager.setSelectingMode(selectingMode);

        final currentCell = rows[3].cells['text1'];

        stateManager.setCurrentCell(currentCell, 3);

        stateManager.setCurrentSelectingPosition(
          cellPosition: const TrinaGridCellPosition(
            columnIdx: 2,
            rowIdx: 4,
          ),
        );

        // when
        final currentSelectingText = stateManager.currentSelectingText;

        // then
        expect(currentSelectingText,
            'text1 value 3\ttext2 value 3\ntext1 value 4\ttext2 value 4');
      });
    }

    testCellSelecting(TrinaGridSelectingMode.cellWithSingleTap);
    testCellSelecting(TrinaGridSelectingMode.cellWithCtrl);
  });

  group('setSelecting', () {
    testWidgets(
      'When selectingMode is None, should not change isSelecting.',
      (WidgetTester tester) async {
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

        stateManager.setSelectingMode(TrinaGridSelectingMode.disabled);

        expect(stateManager.isSelecting, false);
        // when
        stateManager.setSelecting(true);

        // then
        expect(stateManager.isSelecting, false);
      },
    );

    testCellSelecting(TrinaGridSelectingMode selectingMode) {
      return testWidgets(
        'When selectingMode is ${selectingMode.name}'
        'and currentCell is null'
        'then isSelecting should not change.',
        (WidgetTester tester) async {
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

          stateManager.setSelectingMode(selectingMode);

          expect(stateManager.currentCell, null);
          expect(stateManager.isSelecting, false);
          // when
          stateManager.setSelecting(true);

          // then
          expect(stateManager.isSelecting, false);
        },
      );
    }

    testCellSelecting(TrinaGridSelectingMode.cellWithSingleTap);
    testCellSelecting(TrinaGridSelectingMode.cellWithCtrl);

    testRowSelecting(TrinaGridSelectingMode selectingMode) {
      return testWidgets(
        'When selectingMode is ${selectingMode.name}'
        'and currentCell is null'
        'then isSelecting should not change.',
        (WidgetTester tester) async {
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

          stateManager.setSelectingMode(selectingMode);

          expect(stateManager.currentCell, null);
          expect(stateManager.isSelecting, false);
          // when
          stateManager.setSelecting(true);

          // then
          expect(stateManager.isSelecting, false);
        },
      );
    }

    testRowSelecting(TrinaGridSelectingMode.rowWithSingleTap);
    testRowSelecting(TrinaGridSelectingMode.rowWithCtrl);

    testRowSelectingNotNull(TrinaGridSelectingMode selectingMode) {
      return testWidgets(
        'When selectingMode is ${selectingMode.name}'
        'and currentCell is not null'
        'then isSelecting should change.',
        (WidgetTester tester) async {
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

          stateManager.setSelectingMode(selectingMode);
          stateManager.setCurrentCell(rows.first.cells['text1'], 0);

          expect(stateManager.currentCell, isNot(null));
          expect(stateManager.isSelecting, false);
          // when
          stateManager.setSelecting(true);

          // then
          expect(stateManager.isSelecting, true);
        },
      );
    }

    testRowSelectingNotNull(TrinaGridSelectingMode.rowWithSingleTap);
    testRowSelectingNotNull(TrinaGridSelectingMode.rowWithCtrl);

    testRowEditing(TrinaGridSelectingMode selectingMode) {
      return testWidgets(
        'When selectingMode is ${selectingMode.name}'
        'and currentCell is not null'
        'then isSelecting should change.'
        'isEditing is true then isEditing should change to false.',
        (WidgetTester tester) async {
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

          stateManager.setSelectingMode(selectingMode);
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
        },
      );
    }

    testRowEditing(TrinaGridSelectingMode.rowWithSingleTap);
    testRowEditing(TrinaGridSelectingMode.rowWithCtrl);
  });

  group('clearCurrentSelectingPosition', () {
    testWidgets(
      'When currentSelectingPosition is not null'
      'then currentSelectingPosition should be null.',
      (WidgetTester tester) async {
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
          cellPosition: const TrinaGridCellPosition(
            columnIdx: 0,
            rowIdx: 1,
          ),
        );

        expect(stateManager.currentSelectingPosition, isNot(null));

        stateManager.clearCurrentSelecting();

        // then
        expect(stateManager.currentSelectingPosition, null);
      },
    );
  });

  group('clearselectedRows', () {
    testClearSelected(TrinaGridSelectingMode selectingMode) {
      return testWidgets(
        'When selectedRows is not empty'
        'then selectedRows should be empty.',
        (WidgetTester tester) async {
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
          stateManager.setSelectingMode(selectingMode);

          stateManager.toggleRowSelection(1);

          expect(stateManager.selectedRows.length, 1);

          stateManager.clearCurrentSelecting();

          // then
          expect(stateManager.selectedRows.length, 0);
        },
      );
    }

    testClearSelected(TrinaGridSelectingMode.rowWithSingleTap);
    testClearSelected(TrinaGridSelectingMode.rowWithCtrl);
  });

  group('setAllCurrentSelecting', () {
    testWidgets(
        'When rows is null'
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
      expect(stateManager.selectedRows.length, 0);
    });

    testWidgets(
        'When rows.length < 1'
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
      expect(stateManager.selectedRows.length, 0);
    });

    testCellSelecting(TrinaGridSelectingMode selectingMode) {
      return testWidgets(
          'When selectingMode is ${selectingMode.name}'
          'and rows.length > 0'
          'then current cell should be first cell, '
          'selected cell position should be last cell position.',
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
          layout: const BoxConstraints(maxHeight: 500, maxWidth: 400),
        );

        stateManager.setSelectingMode(selectingMode);

        // when
        stateManager.setAllCurrentSelecting();

        // then
        expect(stateManager.currentCell, rows.first.cells['text0']);
        expect(stateManager.currentSelectingPosition!.rowIdx, 4);
        expect(stateManager.currentSelectingPosition!.columnIdx, 2);
      });
    }

    testCellSelecting(TrinaGridSelectingMode.cellWithSingleTap);
    testCellSelecting(TrinaGridSelectingMode.cellWithCtrl);

    testRowSelecting(TrinaGridSelectingMode selectingMode) {
      return testWidgets(
          'When selectingMode is ${selectingMode.name}'
          'and rows.length > 0'
          'then The number of selected rows should be correct.',
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
          layout: const BoxConstraints(maxHeight: 500, maxWidth: 400),
        );

        stateManager.setSelectingMode(selectingMode);

        // when
        stateManager.setAllCurrentSelecting();

        // then
        expect(
            stateManager.currentCell!.value, rows.first.cells['text0']!.value);
        expect(stateManager.currentSelectingPosition!.columnIdx, 2);
        expect(stateManager.currentSelectingPosition!.rowIdx, 4);
        expect(stateManager.selectedRows.length, 5);
      });
    }

    testRowSelecting(TrinaGridSelectingMode.rowWithSingleTap);
    testRowSelecting(TrinaGridSelectingMode.rowWithCtrl);

    testWidgets(
        'When selectingMode is None'
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

      stateManager.setSelectingMode(TrinaGridSelectingMode.disabled);

      // when
      stateManager.setAllCurrentSelecting();

      // then
      expect(stateManager.currentCell, null);
      expect(stateManager.currentSelectingPosition, null);
      expect(stateManager.selectedRows.length, 0);
    });
  });

  group('toggleRowSelection', () {
    testTogglingRowInMode(TrinaGridSelectingMode selectingMode) {
      return testWidgets(
        'When selectingMode is ${selectingMode.name}'
        'and the row is already selected'
        'then it should be removed.',
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
            configuration: TrinaGridConfiguration(selectingMode: selectingMode),
            layout: const BoxConstraints(maxHeight: 500, maxWidth: 400),
          );

          stateManager.setSelectingMode(selectingMode);

          stateManager.toggleRowSelection(3);

          expect(stateManager.isSelectedRow(rows[3].key), true);

          stateManager.toggleRowSelection(3);
          // then

          expect(stateManager.isSelectedRow(rows[3].key), false);
        },
      );
    }

    testTogglingRowInMode(TrinaGridSelectingMode.rowWithSingleTap);
    testTogglingRowInMode(TrinaGridSelectingMode.rowWithCtrl);
  });

  group('setSelectedRows', () {
    testSetSelected(TrinaGridSelectingMode selectingMode) {
      return testWidgets(
        'When selectingMode is ${selectingMode.name}'
        'then the rows should be selected.',
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
            layout: const BoxConstraints(maxHeight: 500, maxWidth: 400),
          );

          stateManager.setSelectingMode(selectingMode);

          stateManager.setSelectedRows([rows[1], rows[3]]);

          // then
          expect(stateManager.selectedRows.length, 2);
          expect(stateManager.isSelectedRow(rows[1].key), true);
          expect(stateManager.isSelectedRow(rows[3].key), true);
        },
      );
    }

    testSetSelected(TrinaGridSelectingMode.rowWithSingleTap);
    testSetSelected(TrinaGridSelectingMode.rowWithCtrl);
  });

  group('isSelectingInteraction', () {
    testWidgets(
      'When selectingMode is None'
      'then isSelectingInteraction should return false.',
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
          layout: const BoxConstraints(maxHeight: 500, maxWidth: 400),
        );

        // when
        stateManager.setSelectingMode(TrinaGridSelectingMode.disabled);

        // then
        expect(stateManager.isSelectingInteraction(), isFalse);
      },
    );

    testNotKeyPressed(TrinaGridSelectingMode selectingMode) {
      return testWidgets(
        'When selectingMode is ${selectingMode.name}'
        'and shift or ctrl key is not pressed'
        'then isSelectingInteraction should return false.',
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
            layout: const BoxConstraints(maxHeight: 500, maxWidth: 400),
          );

          // when
          stateManager.setSelectingMode(selectingMode);

          // then
          expect(stateManager.isSelectingInteraction(), isFalse);
        },
      );
    }

    testNotKeyPressed(TrinaGridSelectingMode.rowWithSingleTap);
    testNotKeyPressed(TrinaGridSelectingMode.rowWithCtrl);
    testNotKeyPressed(TrinaGridSelectingMode.cellWithSingleTap);
    testNotKeyPressed(TrinaGridSelectingMode.cellWithCtrl);

    testShiftKeyPressed(TrinaGridSelectingMode selectingMode) {
      return testWidgets(
        'When selectingMode is ${selectingMode.name}'
        'and shift key is pressed'
        'and currentCellPosition is null'
        'then isSelectingInteraction should return false.',
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
            layout: const BoxConstraints(maxHeight: 500, maxWidth: 400),
          );

          // when
          expect(stateManager.currentCellPosition, isNull);

          stateManager.setSelectingMode(selectingMode);
          await tester.sendKeyDownEvent(LogicalKeyboardKey.shift);

          // then
          expect(stateManager.isSelectingInteraction(), isFalse);
        },
      );
    }

    testShiftKeyPressed(TrinaGridSelectingMode.rowWithSingleTap);
    testShiftKeyPressed(TrinaGridSelectingMode.rowWithCtrl);
    testShiftKeyPressed(TrinaGridSelectingMode.cellWithSingleTap);
    testShiftKeyPressed(TrinaGridSelectingMode.cellWithCtrl);

    testCtrlKeyPressed(TrinaGridSelectingMode selectingMode) {
      return testWidgets(
        'When selectingMode is ${selectingMode.name}'
        'and ctrl key is pressed'
        'and currentCellPosition is null'
        'then isSelectingInteraction should return false.',
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
            layout: const BoxConstraints(maxHeight: 500, maxWidth: 400),
          );
          expect(stateManager.currentCellPosition, isNull);
          // when
          stateManager.setSelectingMode(selectingMode);
          await tester.sendKeyDownEvent(LogicalKeyboardKey.control);

          // then
          expect(stateManager.isSelectingInteraction(), isFalse);
        },
      );
    }

    testCtrlKeyPressed(TrinaGridSelectingMode.rowWithSingleTap);
    testCtrlKeyPressed(TrinaGridSelectingMode.rowWithCtrl);
    testCtrlKeyPressed(TrinaGridSelectingMode.cellWithSingleTap);
    testCtrlKeyPressed(TrinaGridSelectingMode.cellWithCtrl);

    testShiftKeyPressedNotNull(TrinaGridSelectingMode selectingMode) {
      return testWidgets(
        'When selectingMode is ${selectingMode.name}'
        'and shift key is pressed'
        'and currentCellPosition is not null'
        'then isSelectingInteraction should return true.',
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
            layout: const BoxConstraints(maxHeight: 500, maxWidth: 400),
          );

          // when

          stateManager.setSelectingMode(selectingMode);
          await tester.sendKeyDownEvent(LogicalKeyboardKey.shift);
          stateManager.setCurrentCell(rows.first.cells['text0'], 0);

          expect(stateManager.currentCellPosition, isNotNull);
          // then
          expect(stateManager.isSelectingInteraction(), isTrue);
        },
      );
    }

    testShiftKeyPressedNotNull(TrinaGridSelectingMode.rowWithSingleTap);
    testShiftKeyPressedNotNull(TrinaGridSelectingMode.rowWithCtrl);
    testShiftKeyPressedNotNull(TrinaGridSelectingMode.cellWithSingleTap);
    testShiftKeyPressedNotNull(TrinaGridSelectingMode.cellWithCtrl);

    testCtrlKeyPressedNotNull(TrinaGridSelectingMode selectingMode) {
      return testWidgets(
        'When selectingMode is ${selectingMode.name}'
        'and ctrl key is pressed'
        'and currentCellPosition is not null'
        'then isSelectingInteraction should return true.',
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
            layout: const BoxConstraints(maxHeight: 500, maxWidth: 400),
          );

          // when
          stateManager.setSelectingMode(selectingMode);
          await tester.sendKeyDownEvent(LogicalKeyboardKey.control);
          stateManager.setCurrentCell(rows.first.cells['text0'], 0);
          expect(stateManager.currentCellPosition, isNotNull);

          // then
          expect(stateManager.isSelectingInteraction(), isTrue);
        },
      );
    }

    testCtrlKeyPressedNotNull(TrinaGridSelectingMode.rowWithSingleTap);
    testCtrlKeyPressedNotNull(TrinaGridSelectingMode.rowWithCtrl);
    testCtrlKeyPressedNotNull(TrinaGridSelectingMode.cellWithSingleTap);
    testCtrlKeyPressedNotNull(TrinaGridSelectingMode.cellWithCtrl);
  });

  group('isSelectedCell', () {
    testWidgets('When nothing is selected, all cells should be false',
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
        layout: const BoxConstraints(maxHeight: 500, maxWidth: 400),
      );

      // when
      expect(stateManager.selectingMode.isCell, isTrue);

      // then
      for (var i = 0; i < rows.length; i += 1) {
        for (var column in columns) {
          expect(
            stateManager.isSelectedCell(rows[i].cells[column.field]!),
            false,
          );
        }
      }
    });

    testWidgets(
        'WHEN '
        'current cell is 0th row, 0th column, '
        'the cell at (0th row, 1st column) is selected. '
        'THEN '
        'the cells should be true.', (WidgetTester tester) async {
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
      stateManager.selectCellsInRange(
        const TrinaGridCellPosition(columnIdx: 0, rowIdx: 0),
        const TrinaGridCellPosition(columnIdx: 1, rowIdx: 0),
      );

      // when
      expect(stateManager.selectingMode.isCell, isTrue);

      // then
      for (var i = 0; i < rows.length; i += 1) {
        for (var column in columns) {
          if (i == 0 && (column.field == 'text0' || column.field == 'text1')) {
            expect(
              stateManager.isSelectedCell(rows[i].cells[column.field]!),
              true,
            );
          } else {
            expect(
              stateManager.isSelectedCell(rows[i].cells[column.field]!),
              false,
            );
          }
        }
      }
    });

    testWidgets(
        'WHEN '
        'current cell is 1st row, 1st column, '
        'the cell at (3rd row, 2nd column) is selected. '
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
      stateManager.selectCellsInRange(
        stateManager.currentCellPosition!,
        const TrinaGridCellPosition(columnIdx: 2, rowIdx: 3),
      );

      // when
      expect(stateManager.selectingMode.isCell, isTrue);

      // then
      for (var i = 0; i < rows.length; i += 1) {
        for (var column in columns) {
          if ((i >= 1 && i <= 3) &&
              (column.field == 'text1' || column.field == 'text2')) {
            expect(
              stateManager.isSelectedCell(rows[i].cells[column.field]!),
              true,
            );
          } else {
            expect(
              stateManager.isSelectedCell(rows[i].cells[column.field]!),
              false,
            );
          }
        }
      }
    });
  });

  group('handleAfterSelectingRow', () {
    testWidgets(
      'When enableMoveDownAfterSelecting is false '
      'then cell value change should not move to the next row.',
      (WidgetTester tester) async {
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

        stateManager
            .setLayout(const BoxConstraints(maxHeight: 500, maxWidth: 400));

        stateManager.setCurrentCell(rows[1].cells['text1'], 1);

        stateManager.setCurrentSelectingPosition(
          cellPosition: const TrinaGridCellPosition(
            rowIdx: 3,
            columnIdx: 2,
          ),
        );

        // when
        expect(stateManager.currentCellPosition!.rowIdx, 1);

        stateManager.handleAfterSelectingRow(
          rows[1].cells['text1']!,
          'new value',
        );

        // then
        expect(stateManager.currentCellPosition!.rowIdx, 1);
      },
    );

    testWidgets(
      'When enableMoveDownAfterSelecting is true, '
      'then cell value change should move to the next row.',
      (WidgetTester tester) async {
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
          cellPosition: const TrinaGridCellPosition(
            rowIdx: 3,
            columnIdx: 2,
          ),
        );

        // when
        expect(stateManager.currentCellPosition!.rowIdx, 1);

        stateManager.handleAfterSelectingRow(
          rows[1].cells['text1']!,
          'new value',
        );

        // then
        expect(stateManager.currentCellPosition!.rowIdx, 2);
      },
    );
  });
}
