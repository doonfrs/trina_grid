import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:trina_grid/trina_grid.dart';

import '../../../helper/column_helper.dart';
import '../../../helper/row_helper.dart';
import '../../../mock/mock_methods.dart';
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
    void Function(TrinaGridOnChangedEvent)? onChangedEventCallback,
  }) {
    final stateManager = TrinaGridStateManager(
      columns: columns,
      rows: rows,
      gridFocusNode: gridFocusNode ?? MockFocusNode(),
      scroll: scroll ?? MockTrinaGridScrollController(),
      configuration: configuration,
      mode: mode,
      onChanged: onChangedEventCallback,
    );

    stateManager.setEventManager(MockTrinaGridEventManager());

    if (layout != null) {
      stateManager.setLayout(layout);
    }

    return stateManager;
  }

  group('pasteCellValue', () {
    testWidgets(
        'WHEN'
        'currentCellPosition != null'
        'selectingMode.rowWithSingleTap'
        'selectedRows.length > 0'
        'THEN'
        'Values should be filled in the selected rows by _pasteCellValueIntoSelectingRows.',
        (WidgetTester tester) async {
      // given
      List<TrinaColumn> columns = [
        ...ColumnHelper.textColumn('left',
            count: 3, frozen: TrinaColumnFrozen.start),
        ...ColumnHelper.textColumn('body', count: 3, width: 150),
        ...ColumnHelper.textColumn('right',
            count: 3, frozen: TrinaColumnFrozen.end),
      ];

      List<TrinaRow> rows = RowHelper.count(10, columns);

      TrinaGridStateManager.initializeRows(columns, rows);

      TrinaGridStateManager stateManager = createStateManager(
        columns: columns,
        rows: rows,
        gridFocusNode: null,
        scroll: null,
        layout: const BoxConstraints(maxHeight: 300, maxWidth: 50),
      );

      stateManager.setSelectingMode(TrinaGridSelectingMode.rowWithSingleTap);

      final currentCell = rows[2].cells['body2'];

      stateManager.setCurrentCell(currentCell, 2);

      stateManager.selectRowsInRange(2, 4);

      // when
      stateManager.pasteCellValue([
        ['changed']
      ]);

      // then
      for (var rowIdx in [0, 1, 5, 6, 7, 8, 9]) {
        for (var column in ['left', 'body', 'right']) {
          for (var idx in [0, 1, 2]) {
            expect(rows[rowIdx].cells['$column$idx']!.value,
                '$column$idx value $rowIdx');
            expect(rows[rowIdx].cells['$column$idx']!.value, isNot('changed'));
          }
        }
      }

      for (var rowIdx in [2, 3, 4]) {
        for (var column in ['left', 'body', 'right']) {
          for (var idx in [0, 1, 2]) {
            expect(rows[rowIdx].cells['$column$idx']!.value, 'changed');
          }
        }
      }
    });

    testWidgets(
        'WHEN'
        'currentCellPosition != null'
        'selectingMode.cellWithSingleTap'
        'selectedRows.length < 1'
        '_currentSelectingPosition != null'
        'THEN'
        'Values should be filled in the selected rows by _pasteCellValueInOrder.',
        (WidgetTester tester) async {
      // given
      List<TrinaColumn> columns = [
        ...ColumnHelper.textColumn('left',
            count: 3, frozen: TrinaColumnFrozen.start),
        ...ColumnHelper.textColumn('body', count: 3, width: 150),
        ...ColumnHelper.textColumn('right',
            count: 3, frozen: TrinaColumnFrozen.end),
      ];

      List<TrinaRow> rows = RowHelper.count(10, columns);

      TrinaGridStateManager stateManager = createStateManager(
        columns: columns,
        rows: rows,
        gridFocusNode: null,
        scroll: null,
        layout: const BoxConstraints(maxHeight: 300, maxWidth: 50),
      );

      stateManager.setSelectingMode(TrinaGridSelectingMode.cellWithSingleTap);

      final currentCell = rows[2].cells['body2'];

      stateManager.setCurrentCell(currentCell, 2);

      stateManager.setCurrentSelectingPosition(
        cellPosition: const TrinaGridCellPosition(
          columnIdx: 6,
          rowIdx: 4,
        ),
      );

      // when
      stateManager.pasteCellValue([
        ['changed1-1', 'changed1-2'],
        ['changed2-1', 'changed2-2'],
      ]);

      // then
      for (var rowIdx in [0, 1, 5, 6, 7, 8, 9]) {
        for (var column in ['left', 'body', 'right']) {
          for (var idx in [0, 1, 2]) {
            expect(rows[rowIdx].cells['$column$idx']!.value,
                '$column$idx value $rowIdx');
          }
        }
      }

      expect(rows[2].cells['left0']!.value, 'left0 value 2');
      expect(rows[2].cells['left1']!.value, 'left1 value 2');
      expect(rows[2].cells['left2']!.value, 'left2 value 2');

      expect(rows[2].cells['body0']!.value, 'body0 value 2');
      expect(rows[2].cells['body1']!.value, 'body1 value 2');
      expect(rows[2].cells['body2']!.value, 'changed1-1');

      expect(rows[2].cells['right0']!.value, 'changed1-2');
      expect(rows[2].cells['right1']!.value, 'right1 value 2');
      expect(rows[2].cells['right2']!.value, 'right2 value 2');

      expect(rows[3].cells['left0']!.value, 'left0 value 3');
      expect(rows[3].cells['left1']!.value, 'left1 value 3');
      expect(rows[3].cells['left2']!.value, 'left2 value 3');

      expect(rows[3].cells['body0']!.value, 'body0 value 3');
      expect(rows[3].cells['body1']!.value, 'body1 value 3');
      expect(rows[3].cells['body2']!.value, 'changed2-1');

      expect(rows[3].cells['right0']!.value, 'changed2-2');
      expect(rows[3].cells['right1']!.value, 'right1 value 3');
      expect(rows[3].cells['right2']!.value, 'right2 value 3');

      expect(rows[4].cells['left0']!.value, 'left0 value 4');
      expect(rows[4].cells['left1']!.value, 'left1 value 4');
      expect(rows[4].cells['left2']!.value, 'left2 value 4');

      expect(rows[4].cells['body0']!.value, 'body0 value 4');
      expect(rows[4].cells['body1']!.value, 'body1 value 4');
      expect(rows[4].cells['body2']!.value, 'changed1-1');

      expect(rows[4].cells['right0']!.value, 'changed1-2');
      expect(rows[4].cells['right1']!.value, 'right1 value 4');
      expect(rows[4].cells['right2']!.value, 'right2 value 4');
    });
  });

  group('setEditing', () {
    MockMethods? mock;
    List<TrinaColumn> columns;
    List<TrinaRow> rows;
    late TrinaGridStateManager stateManager;

    late Function({
      TrinaGridMode? mode,
      bool? enableEditingMode,
      bool? setCurrentCell,
      bool? setIsEditing,
    }) buildState;

    setUp(() {
      buildState = ({
        mode = TrinaGridMode.normal,
        enableEditingMode = true,
        setCurrentCell = false,
        setIsEditing = false,
      }) {
        mock = MockMethods();

        columns = [
          TrinaColumn(
            title: 'column',
            field: 'column',
            type: TrinaColumnType.text(),
            enableEditingMode: enableEditingMode,
          ),
        ];

        rows = RowHelper.count(10, columns);

        stateManager = createStateManager(
          columns: columns,
          rows: rows,
          gridFocusNode: null,
          scroll: null,
          mode: mode,
          layout: const BoxConstraints(maxHeight: 300, maxWidth: 50),
        );

        stateManager.addListener(mock!.noParamReturnVoid);

        if (setCurrentCell!) {
          stateManager.setCurrentCell(rows.first.cells['column'], 0);
        }

        if (setIsEditing!) {
          stateManager.setEditing(true);
        }

        clearInteractions(mock);
      };
    });

    test(
      'TrinaMode = normal, '
      'enableEditingMode = true, '
      'setCurrentCell = true, '
      'setIsEditing = false, '
      'notifyListener should be called',
      () {
        // given
        buildState(
          mode: TrinaGridMode.normal,
          enableEditingMode: true,
          setCurrentCell: true,
          setIsEditing: false,
        );

        // when
        stateManager.setEditing(true);

        // then
        verify(mock!.noParamReturnVoid()).called(1);
      },
    );

    test(
      'TrinaMode = normal, '
      'enableEditingMode = true, '
      'setCurrentCell = false, '
      'setIsEditing = false, '
      'notifyListener should not be called',
      () {
        // given
        buildState(
          mode: TrinaGridMode.normal,
          enableEditingMode: true,
          setCurrentCell: false,
          setIsEditing: false,
        );

        // when
        stateManager.setEditing(true);

        // then
        verifyNever(mock!.noParamReturnVoid());
      },
    );

    test(
      'TrinaMode = normal, '
      'enableEditingMode = true, '
      'setCurrentCell = true, '
      'setIsEditing = true, '
      'notifyListener should not be called',
      () {
        // given
        buildState(
          mode: TrinaGridMode.normal,
          enableEditingMode: true,
          setCurrentCell: true,
          setIsEditing: true,
        );

        // when
        stateManager.setEditing(true);

        // then
        verifyNever(mock!.noParamReturnVoid());
      },
    );
  });

  group('changeCellValue', () {
    List<TrinaColumn> columns = [
      ...ColumnHelper.textColumn('column', count: 3, width: 150),
    ];

    List<TrinaRow> rows = RowHelper.count(10, columns);

    test(
      'force is false (default) and canNotChangeCellValue is true (grid mode is readOnly), '
      'onChanged callback should not be called',
      () {
        final mock = MockMethods();

        TrinaGridStateManager stateManager = createStateManager(
          columns: columns,
          rows: rows,
          gridFocusNode: null,
          scroll: null,
          mode: TrinaGridMode.readOnly,
          onChangedEventCallback: mock.oneParamReturnVoid,
        );

        final cell = TrinaCell(value: '');
        final column = columns.first;
        final row = TrinaRow(cells: {columns.first.field: cell});
        cell
          ..setColumn(column)
          ..setRow(row);

        final bool canNotChangeCellValue = stateManager.canNotChangeCellValue(
          cell: cell,
          newValue: 'abc',
          oldValue: 'ABC',
        );

        expect(canNotChangeCellValue, isTrue);

        stateManager.changeCellValue(
          rows.first.cells['column0']!,
          'DEF',
          // force: false,
        );

        verifyNever(mock.oneParamReturnVoid(any));
      },
    );

    test(
      'force is true and canNotChangeCellValue is true (grid mode is readOnly), '
      'onChanged callback should be called',
      () {
        final mock = MockMethods();

        TrinaGridStateManager stateManager = createStateManager(
          columns: columns,
          rows: rows,
          gridFocusNode: null,
          scroll: null,
          mode: TrinaGridMode.readOnly,
          onChangedEventCallback: mock.oneParamReturnVoid,
          layout: const BoxConstraints(maxHeight: 300, maxWidth: 50),
        );

        final cell = TrinaCell(value: '');
        final column = columns.first;
        final row = TrinaRow(cells: {columns.first.field: cell});
        cell
          ..setColumn(column)
          ..setRow(row);

        final bool canNotChangeCellValue = stateManager.canNotChangeCellValue(
          cell: cell,
          newValue: 'abc',
          oldValue: 'ABC',
        );

        expect(canNotChangeCellValue, isTrue);

        stateManager.changeCellValue(
          rows.first.cells['column0']!,
          'DEF',
          force: true,
        );

        verify(mock.oneParamReturnVoid(any)).called(1);
      },
    );
  });
}
