import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:trina_grid/trina_grid.dart';

import '../../../helper/column_helper.dart';
import '../../../helper/trina_widget_test_helper.dart';
import '../../../helper/row_helper.dart';
import '../../../mock/mock_methods.dart';
import '../../../mock/shared_mocks.mocks.dart';

void main() {
  final scroll = MockTrinaGridScrollController();

  final vertical = MockLinkedScrollControllerGroup();

  when(scroll.vertical).thenReturn(vertical);

  TrinaGridStateManager createStateManager({
    required List<TrinaColumn> columns,
    required List<TrinaRow> rows,
    FocusNode? gridFocusNode,
    TrinaGridScrollController? scroll,
    BoxConstraints? layout,
    TrinaGridConfiguration configuration = const TrinaGridConfiguration(),
    Widget Function(TrinaGridStateManager)? createHeader,
  }) {
    final stateManager = TrinaGridStateManager(
      columns: columns,
      rows: rows,
      gridFocusNode: gridFocusNode ?? MockFocusNode(),
      scroll: scroll ?? MockTrinaGridScrollController(),
      configuration: configuration,
      createHeader: createHeader,
    );

    stateManager.setEventManager(MockTrinaGridEventManager());

    if (layout != null) {
      stateManager.setLayout(layout);
    }

    return stateManager;
  }

  group('checkedRows', () {
    testWidgets(
      'If there are no checked rows, it should return an empty list.',
      (WidgetTester tester) async {
        // given
        List<TrinaColumn> columns = ColumnHelper.textColumn(
          'body',
          count: 3,
          width: 150,
        );

        List<TrinaRow> rows = RowHelper.count(10, columns);

        TrinaGridStateManager stateManager = createStateManager(
          columns: columns,
          rows: rows,
          gridFocusNode: null,
          scroll: scroll,
        );

        // when
        // then
        expect(stateManager.checkedRows.toList(), <TrinaRow>[]);
      },
    );

    testWidgets(
      'If there are checked rows, it should return the list of checked rows.',
      (WidgetTester tester) async {
        // given
        List<TrinaColumn> columns = ColumnHelper.textColumn(
          'body',
          count: 1,
          width: 150,
        );

        final checkedRows = RowHelper.count(3, columns, checked: true);

        List<TrinaRow> rows = [...checkedRows, ...RowHelper.count(10, columns)];

        TrinaGridStateManager stateManager = createStateManager(
          columns: columns,
          rows: rows,
          gridFocusNode: null,
          scroll: scroll,
        );

        // when
        final keys = stateManager.checkedRows
            .toList()
            .map((e) => e.key)
            .toList();

        // then
        expect(keys.length, 3);
        expect(keys.contains(checkedRows[0].key), isTrue);
        expect(keys.contains(checkedRows[1].key), isTrue);
        expect(keys.contains(checkedRows[2].key), isTrue);
      },
    );
  });

  group('unCheckedRows', () {
    testWidgets('If there are no checked rows, it should return all rows.', (
      WidgetTester tester,
    ) async {
      // given
      List<TrinaColumn> columns = ColumnHelper.textColumn(
        'body',
        count: 3,
        width: 150,
      );

      List<TrinaRow> rows = RowHelper.count(10, columns);

      TrinaGridStateManager stateManager = createStateManager(
        columns: columns,
        rows: rows,
        gridFocusNode: null,
        scroll: scroll,
      );

      // when
      // then
      expect(stateManager.unCheckedRows.toList().length, rows.length);
    });

    testWidgets(
      'If there are checked rows, it should return the list of unchecked rows.',
      (WidgetTester tester) async {
        // given
        List<TrinaColumn> columns = ColumnHelper.textColumn(
          'body',
          count: 1,
          width: 150,
        );

        final checkedRows = RowHelper.count(3, columns, checked: true);

        List<TrinaRow> rows = [...checkedRows, ...RowHelper.count(10, columns)];

        TrinaGridStateManager stateManager = createStateManager(
          columns: columns,
          rows: rows,
          gridFocusNode: null,
          scroll: scroll,
        );

        // when
        final keys = stateManager.unCheckedRows
            .toList()
            .map((e) => e.key)
            .toList();

        // then
        expect(keys.length, 10);
        expect(keys.contains(checkedRows[0].key), isFalse);
        expect(keys.contains(checkedRows[1].key), isFalse);
        expect(keys.contains(checkedRows[2].key), isFalse);
      },
    );
  });

  group('hasCheckedRow', () {
    testWidgets('If there are no checked rows, it should return false.', (
      WidgetTester tester,
    ) async {
      // given
      List<TrinaColumn> columns = ColumnHelper.textColumn(
        'body',
        count: 3,
        width: 150,
      );

      List<TrinaRow> rows = RowHelper.count(10, columns);

      TrinaGridStateManager stateManager = createStateManager(
        columns: columns,
        rows: rows,
        gridFocusNode: null,
        scroll: scroll,
      );

      // when
      // then
      expect(stateManager.hasCheckedRow, isFalse);
    });

    testWidgets('If there are checked rows, it should return true.', (
      WidgetTester tester,
    ) async {
      // given
      List<TrinaColumn> columns = ColumnHelper.textColumn(
        'body',
        count: 1,
        width: 150,
      );

      final checkedRows = RowHelper.count(3, columns, checked: true);

      List<TrinaRow> rows = [...checkedRows, ...RowHelper.count(10, columns)];

      TrinaGridStateManager stateManager = createStateManager(
        columns: columns,
        rows: rows,
        gridFocusNode: null,
        scroll: scroll,
      );

      // when
      // then
      expect(stateManager.hasCheckedRow, isTrue);
    });
  });

  group('hasUnCheckedRow', () {
    testWidgets('If there are no checked rows, it should return true.', (
      WidgetTester tester,
    ) async {
      // given
      List<TrinaColumn> columns = ColumnHelper.textColumn(
        'body',
        count: 3,
        width: 150,
      );

      List<TrinaRow> rows = RowHelper.count(10, columns);

      TrinaGridStateManager stateManager = createStateManager(
        columns: columns,
        rows: rows,
        gridFocusNode: null,
        scroll: scroll,
      );

      // when
      // then
      expect(stateManager.hasUnCheckedRow, isTrue);
    });

    testWidgets(
      'If there is at least one unchecked row, it should return true.',
      (WidgetTester tester) async {
        // given
        List<TrinaColumn> columns = ColumnHelper.textColumn(
          'body',
          count: 1,
          width: 150,
        );

        final checkedRows = RowHelper.count(3, columns, checked: true);

        final uncheckedRows = RowHelper.count(1, columns, checked: false);

        List<TrinaRow> rows = [...checkedRows, ...uncheckedRows];

        TrinaGridStateManager stateManager = createStateManager(
          columns: columns,
          rows: rows,
          gridFocusNode: null,
          scroll: scroll,
        );

        // when
        // then
        expect(stateManager.hasUnCheckedRow, isTrue);
      },
    );

    testWidgets('If all rows are checked, it should return false.', (
      WidgetTester tester,
    ) async {
      // given
      List<TrinaColumn> columns = ColumnHelper.textColumn(
        'body',
        count: 1,
        width: 150,
      );

      final checkedRows = RowHelper.count(3, columns, checked: true);

      List<TrinaRow> rows = [...checkedRows];

      TrinaGridStateManager stateManager = createStateManager(
        columns: columns,
        rows: rows,
        gridFocusNode: null,
        scroll: scroll,
      );

      // when
      // then
      expect(stateManager.hasUnCheckedRow, isFalse);
    });
  });

  group('currentRowIdx', () {
    testWidgets(
      'When the current cell is not selected, null should be returned',
      (WidgetTester tester) async {
        // given
        List<TrinaColumn> columns = [
          ...ColumnHelper.textColumn(
            'left',
            count: 3,
            frozen: TrinaColumnFrozen.start,
          ),
          ...ColumnHelper.textColumn('body', count: 3, width: 150),
          ...ColumnHelper.textColumn(
            'right',
            count: 3,
            frozen: TrinaColumnFrozen.end,
          ),
        ];

        List<TrinaRow> rows = RowHelper.count(10, columns);

        TrinaGridStateManager stateManager = createStateManager(
          columns: columns,
          rows: rows,
          gridFocusNode: null,
          scroll: scroll,
        );

        // when
        int? currentRowIdx = stateManager.currentRowIdx;

        // when
        expect(currentRowIdx, null);
      },
    );

    testWidgets(
      'When the current cell is selected, return the row index of the selected cell',
      (WidgetTester tester) async {
        // given
        List<TrinaColumn> columns = [
          ...ColumnHelper.textColumn(
            'left',
            count: 3,
            frozen: TrinaColumnFrozen.start,
          ),
          ...ColumnHelper.textColumn('body', count: 3, width: 150),
          ...ColumnHelper.textColumn(
            'right',
            count: 3,
            frozen: TrinaColumnFrozen.end,
          ),
        ];

        List<TrinaRow> rows = RowHelper.count(10, columns);

        TrinaGridStateManager stateManager = createStateManager(
          columns: columns,
          rows: rows,
          gridFocusNode: null,
          scroll: scroll,
        );

        stateManager.setLayout(const BoxConstraints());

        // when
        String selectColumnField = 'right1';
        stateManager.setCurrentCell(rows[7].cells[selectColumnField], 7);

        int? currentRowIdx = stateManager.currentRowIdx;

        // when
        expect(currentRowIdx, 7);
      },
    );
  });

  group('currentRow', () {
    testWidgets(
      'When the current cell is not selected, null should be returned',
      (WidgetTester tester) async {
        // given
        List<TrinaColumn> columns = [
          ...ColumnHelper.textColumn(
            'left',
            count: 3,
            frozen: TrinaColumnFrozen.start,
          ),
          ...ColumnHelper.textColumn('body', count: 3, width: 150),
          ...ColumnHelper.textColumn(
            'right',
            count: 3,
            frozen: TrinaColumnFrozen.end,
          ),
        ];

        List<TrinaRow> rows = RowHelper.count(10, columns);

        TrinaGridStateManager stateManager = createStateManager(
          columns: columns,
          rows: rows,
          gridFocusNode: null,
          scroll: scroll,
        );

        // when
        TrinaRow? currentRow = stateManager.currentRow;

        // when
        expect(currentRow, null);
      },
    );

    testWidgets('If the current cell is selected, return the selected row.', (
      WidgetTester tester,
    ) async {
      // given
      List<TrinaColumn> columns = [
        ...ColumnHelper.textColumn(
          'left',
          count: 3,
          frozen: TrinaColumnFrozen.start,
        ),
        ...ColumnHelper.textColumn('body', count: 3, width: 150),
        ...ColumnHelper.textColumn(
          'right',
          count: 3,
          frozen: TrinaColumnFrozen.end,
        ),
      ];

      List<TrinaRow> rows = RowHelper.count(10, columns);

      TrinaGridStateManager stateManager = createStateManager(
        columns: columns,
        rows: rows,
        gridFocusNode: null,
        scroll: scroll,
        layout: const BoxConstraints(),
      );

      // when
      String selectColumnField = 'left1';
      stateManager.setCurrentCell(rows[3].cells[selectColumnField], 3);

      TrinaRow currentRow = stateManager.currentRow!;

      // when
      expect(currentRow, isNot(null));
      expect(currentRow.key, rows[3].key);
    });
  });

  group('getRowIdxByOffset', () {
    late TrinaGridStateManager stateManager;

    const rowsLength = 10;

    buildRows() {
      return TrinaWidgetTestHelper('build rows', (tester) async {
        List<TrinaColumn> columns = [
          ...ColumnHelper.textColumn('text', count: 3, width: 150),
        ];

        List<TrinaRow> rows = RowHelper.count(rowsLength, columns);

        when(scroll.verticalOffset).thenReturn(0);

        stateManager = createStateManager(
          columns: columns,
          rows: rows,
          gridFocusNode: null,
          scroll: scroll,
          layout: const BoxConstraints(maxWidth: 500, maxHeight: 300),
        );

        stateManager.setGridGlobalOffset(const Offset(0.0, 0.0));
      });
    }

    buildRows().test('The offset is above the 0th row.', (tester) async {
      final rowIdx = stateManager.getRowIdxByOffset(
        stateManager.rowTotalHeight * 0.7,
      );

      expect(rowIdx, isNull);
    });

    buildRows().test('The middle offset of the 0th row.', (tester) async {
      final rowIdx = stateManager.getRowIdxByOffset(
        stateManager.rowTotalHeight * 1.5,
      );

      expect(rowIdx, 0);
    });

    buildRows().test('The middle offset of the 1st row.', (tester) async {
      final rowIdx = stateManager.getRowIdxByOffset(
        stateManager.rowTotalHeight * 2.5,
      );

      expect(rowIdx, 1);
    });

    buildRows().test('The middle offset of the last 9th row.', (tester) async {
      final rowIdx = stateManager.getRowIdxByOffset(
        stateManager.rowTotalHeight * 10.5,
      );

      expect(rowIdx, 9);
    });

    buildRows().test('The offset is below the last row.', (tester) async {
      final rowIdx = stateManager.getRowIdxByOffset(
        stateManager.rowTotalHeight * 11.5,
      );

      expect(rowIdx, isNull);
    });
  });

  group('getRowByIdx', () {
    testWidgets('The rowIdx is null.', (WidgetTester tester) async {
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
      );

      // when
      final found = stateManager.getRowByIdx(null);

      // then
      expect(found, isNull);
    });

    testWidgets('The rowIdx is less than 0.', (WidgetTester tester) async {
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
      );

      // when
      final found = stateManager.getRowByIdx(-1);

      // then
      expect(found, isNull);
    });

    testWidgets('The rowIdx is larger than the rows range.', (
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
      );

      // when
      final found = stateManager.getRowByIdx(5);

      // then
      expect(found, isNull);
    });

    testWidgets('The rowIdx is within the rows range.', (
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
      );

      // when
      final found = stateManager.getRowByIdx(4)!;

      // then
      expect(found.key, rows[4].key);
    });
  });

  group('setRowChecked', () {
    testWidgets('The row does not exist.', (WidgetTester tester) async {
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
      );

      final listener = MockMethods();

      stateManager.addListener(listener.noParamReturnVoid);

      // when
      stateManager.setRowChecked(TrinaRow(cells: {}), true);

      // then
      verifyNever(listener.noParamReturnVoid());
    });

    testWidgets('The row exists.', (WidgetTester tester) async {
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
      );

      final listener = MockMethods();

      stateManager.addListener(listener.noParamReturnVoid);

      // when
      final row = rows.first;

      stateManager.setRowChecked(row, true);

      // then
      expect(
        stateManager.rows
            .firstWhere((element) => element.key == row.key)
            .checked,
        isTrue,
      );

      verify(listener.noParamReturnVoid()).called(1);
    });
  });

  group('insertRows', () {
    testWidgets(
      'The insert position is less than 0 or greater than the maximum index.',
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
        );

        // when
        int countRows = stateManager.rows.length;

        // then
        {
          final addedRows = RowHelper.count(3, columns);
          stateManager.insertRows(-1, addedRows);
          countRows += 3;
          expect(stateManager.rows.length, countRows);
          expect(stateManager.rows.getRange(0, 3), addedRows);
        }

        {
          final addedRows = RowHelper.count(3, columns);
          stateManager.insertRows(-2, addedRows);
          countRows += 3;
          expect(stateManager.rows.length, countRows);
          expect(stateManager.rows.getRange(0, 3), addedRows);
        }

        {
          final addedRows = RowHelper.count(3, columns);
          stateManager.insertRows(stateManager.rows.length + 1, addedRows);
          countRows += 3;
          expect(stateManager.rows.length, countRows);
          final length = stateManager.rows.length;
          expect(stateManager.rows.getRange(length - 3, length), addedRows);
        }
      },
    );

    testWidgets('The insert position is within the rows index range.', (
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
      );

      // when
      final countRows = stateManager.rows.length;

      int countAdded = 0;

      // then
      countAdded += 3;
      stateManager.insertRows(0, RowHelper.count(3, columns));
      expect(stateManager.rows.length, countRows + countAdded);

      countAdded += 4;
      stateManager.insertRows(1, RowHelper.count(4, columns));
      expect(stateManager.rows.length, countRows + countAdded);

      countAdded += 5;
      stateManager.insertRows(
        stateManager.rows.length,
        RowHelper.count(5, columns),
      );
      expect(stateManager.rows.length, countRows + countAdded);
    });

    testWidgets('The columns are not sorted.', (WidgetTester tester) async {
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
      );

      // when
      final rowsToAdd = RowHelper.count(3, columns);

      stateManager.insertRows(1, rowsToAdd);

      expect(stateManager.rows.length, 8);

      for (var i = 0; i < stateManager.rows.length; i += 1) {
        expect(stateManager.rows[i].sortIdx, i);
      }
    });

    testWidgets(
      'When there is a column sort state, the sortIdx of rows to be inserted should increase from the insertion position, '
      'the sortIdx of existing rows should be maintained if less than the insertion position, '
      'and if greater than the insertion position, it should increase by the size of the rows to be inserted.',
      (WidgetTester tester) async {
        // given
        List<TrinaColumn> columns = [
          ...ColumnHelper.textColumn('text', count: 1, width: 150),
        ];

        List<TrinaRow> rows = [
          TrinaRow(sortIdx: 0, cells: {'text0': TrinaCell(value: '3')}),
          TrinaRow(sortIdx: 1, cells: {'text0': TrinaCell(value: '1')}),
          TrinaRow(sortIdx: 2, cells: {'text0': TrinaCell(value: '2')}),
        ];

        TrinaGridStateManager stateManager = createStateManager(
          columns: columns,
          rows: rows,
          gridFocusNode: null,
          scroll: null,
        );

        stateManager.toggleSortColumn(columns.first);
        expect(stateManager.hasSortedColumn, isTrue);
        expect(stateManager.rows[0].sortIdx, 1); // 1
        expect(stateManager.rows[1].sortIdx, 2); // 2
        expect(stateManager.rows[2].sortIdx, 0); // 3

        // when
        final rowsToAdd = [
          TrinaRow(cells: {'text0': TrinaCell(value: 'a')}),
          TrinaRow(cells: {'text0': TrinaCell(value: 'b')}),
          TrinaRow(cells: {'text0': TrinaCell(value: 'c')}),
        ];

        stateManager.insertRows(1, rowsToAdd);

        expect(stateManager.rows.length, 6);
        expect(stateManager.rows[0].sortIdx, 1);
        expect(stateManager.rows[0].cells['text0']!.value, '1');

        expect(stateManager.rows[1].sortIdx, 2);
        expect(stateManager.rows[1].cells['text0']!.value, 'a');

        expect(stateManager.rows[2].sortIdx, 3);
        expect(stateManager.rows[2].cells['text0']!.value, 'b');

        expect(stateManager.rows[3].sortIdx, 4);
        expect(stateManager.rows[3].cells['text0']!.value, 'c');

        expect(stateManager.rows[4].sortIdx, 5);
        expect(stateManager.rows[4].cells['text0']!.value, '2');

        expect(stateManager.rows[5].sortIdx, 0);
        expect(stateManager.rows[5].cells['text0']!.value, '3');
      },
    );
  });

  group('prependNewRows', () {
    testWidgets('count default value 1, rows should be added to the front.', (
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
      );

      // when
      stateManager.prependNewRows();

      // then
      // Added row default value and sortIdx
      expect(stateManager.rows.length, 6);
      expect(
        stateManager.rows[0].cells['text0']!.value,
        columns[0].type.defaultValue,
      );
      expect(stateManager.rows[0].sortIdx, 0);
      // The first row that was already there moved to the second
      expect(stateManager.rows[1].cells['text0']!.value, 'text0 value 0');
      expect(stateManager.rows[1].sortIdx, 1);
    });

    testWidgets('count 5 should be added to the front of rows.', (
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
      );

      // when
      stateManager.prependNewRows(count: 5);

      // then
      expect(stateManager.rows.length, 10);
      // The first row that was already there moved to the sixth
      expect(stateManager.rows[5].cells['text0']!.value, 'text0 value 0');
      expect(stateManager.rows[5].sortIdx, 5);
    });
  });

  group('prependRows', () {
    testWidgets('A new row must be added before the existing row.', (
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
      );

      TrinaRow newRow = RowHelper.count(1, columns).first;

      // when
      stateManager.prependRows([newRow]);

      // then
      expect(stateManager.rows[0].key, newRow.key);
      expect(stateManager.rows[0].sortIdx, 0);
      expect(stateManager.rows.length, 6);
    });

    testWidgets('Row is not added when passing an empty array.', (
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
      );

      // when
      stateManager.prependRows([]);

      // then
      expect(stateManager.rows.length, 5);
    });

    testWidgets('WHEN currentCell is present '
        'THEN '
        'currentRowIdx and currentCellPosition should be updated '
        'to match the number of rows added.', (WidgetTester tester) async {
      // given
      List<TrinaColumn> columns = [
        ...ColumnHelper.textColumn('text', count: 3, width: 150),
      ];

      List<TrinaRow> rows = RowHelper.count(5, columns);

      TrinaGridStateManager stateManager = createStateManager(
        columns: columns,
        rows: rows,
        gridFocusNode: null,
        scroll: scroll,
        layout: const BoxConstraints(),
      );

      const int rowIdxBeforePrependRows = 0;

      stateManager.setCurrentCell(
        rows.first.cells['text1'],
        rowIdxBeforePrependRows,
      );

      expect(stateManager.currentRowIdx, rowIdxBeforePrependRows);

      List<TrinaRow> newRows = RowHelper.count(5, columns);

      // when
      stateManager.prependRows(newRows);

      // then
      // When a new row is added to the front, the current idx is added to the number of rows added.
      final rowIdxAfterPrependRows = newRows.length + rowIdxBeforePrependRows;

      expect(stateManager.currentRowIdx, rowIdxAfterPrependRows);

      expect(stateManager.currentCellPosition!.columnIdx, 1);

      expect(stateManager.currentCellPosition!.rowIdx, rowIdxAfterPrependRows);
    });

    testWidgets('WHEN _currentSelectingPosition is present '
        'THEN currentSelectingPosition should be updated.', (
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
        scroll: scroll,
      );

      const int rowIdxBeforePrependRows = 3;

      stateManager.setCurrentSelectingPosition(
        cellPosition: const TrinaGridCellPosition(
          columnIdx: 2,
          rowIdx: rowIdxBeforePrependRows,
        ),
      );

      expect(
        stateManager.currentSelectingPosition!.rowIdx,
        rowIdxBeforePrependRows,
      );

      List<TrinaRow> newRows = RowHelper.count(7, columns);

      // when
      stateManager.prependRows(newRows);

      // then
      expect(stateManager.currentSelectingPosition!.columnIdx, 2);

      expect(
        stateManager.currentSelectingPosition!.rowIdx,
        newRows.length + rowIdxBeforePrependRows,
      );
    });
  });

  group('appendNewRows', () {
    testWidgets('count default value 1, rows should be added to the end.', (
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
      );

      expect(stateManager.rows[4].sortIdx, 4);

      // when
      stateManager.appendNewRows();

      // then
      expect(stateManager.rows.length, 6);
      // Added row default value and sortIdx
      expect(
        stateManager.rows[5].cells['text0']!.value,
        columns[0].type.defaultValue,
      );
      // sortIdx is last
      expect(stateManager.rows[4].sortIdx, 4);
      expect(stateManager.rows[5].sortIdx, 5);
    });

    testWidgets('count 5, rows should be added to the end.', (
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
      );

      // when
      stateManager.appendNewRows(count: 5);

      // then
      expect(stateManager.rows.length, 10);
      // Added 5~9 cells default value
      expect(
        stateManager.rows[5].cells['text0']!.value,
        columns[0].type.defaultValue,
      );
      expect(
        stateManager.rows[9].cells['text0']!.value,
        columns[0].type.defaultValue,
      );
      // sortIdx
      expect(stateManager.rows[5].sortIdx, 5);
      expect(stateManager.rows[9].sortIdx, 9);
    });
  });

  group('appendRows', () {
    testWidgets('New rows must be added after the existing row.', (
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
      );

      List<TrinaRow> newRows = RowHelper.count(2, columns);

      // when
      stateManager.appendRows(newRows);

      // then
      expect(stateManager.rows[5].key, newRows[0].key);
      expect(stateManager.rows[6].key, newRows[1].key);
      expect(stateManager.rows[5].sortIdx, 5);
      expect(stateManager.rows[6].sortIdx, 6);
      expect(stateManager.rows.length, 7);
    });

    testWidgets('Row is not added when passing an empty array.', (
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
      );

      // when
      stateManager.appendRows([]);

      // then
      expect(stateManager.rows.length, 5);
    });
  });

  group('getNewRow', () {
    testWidgets(
      'Should be returned a row including cells filled with defaultValue of the column',
      (WidgetTester tester) async {
        // given
        List<TrinaColumn> columns = [
          TrinaColumn(
            title: 'text',
            field: 'text',
            type: TrinaColumnType.text(defaultValue: 'default text'),
          ),
          TrinaColumn(
            title: 'number',
            field: 'number',
            type: TrinaColumnType.number(defaultValue: 123),
          ),
          TrinaColumn(
            title: 'select',
            field: 'select',
            type: TrinaColumnType.select(<String>[
              'One',
              'Two',
            ], defaultValue: 'Two'),
          ),
          TrinaColumn(
            title: 'date',
            field: 'date',
            type: TrinaColumnType.date(
              defaultValue: DateTime.parse('2020-09-01'),
            ),
          ),
          TrinaColumn(
            title: 'time',
            field: 'time',
            type: TrinaColumnType.time(defaultValue: '23:59'),
          ),
        ];

        List<TrinaRow> rows = [];

        TrinaGridStateManager stateManager = createStateManager(
          columns: columns,
          rows: rows,
          gridFocusNode: null,
          scroll: null,
        );

        // when
        TrinaRow newRow = stateManager.getNewRow();

        // then
        expect(newRow.cells['text']!.value, 'default text');
        expect(newRow.cells['number']!.value, 123);
        expect(newRow.cells['select']!.value, 'Two');
        expect(newRow.cells['date']!.value, DateTime.parse('2020-09-01'));
        expect(newRow.cells['time']!.value, '23:59');
      },
    );
  });

  group('getNewRows', () {
    testWidgets('count default value 1, should be created.', (
      WidgetTester tester,
    ) async {
      // given
      List<TrinaColumn> columns = [
        ...ColumnHelper.textColumn('text', count: 2),
      ];

      List<TrinaRow> rows = [];

      TrinaGridStateManager stateManager = createStateManager(
        columns: columns,
        rows: rows,
        gridFocusNode: null,
        scroll: null,
      );
      // when
      List<TrinaRow> newRows = stateManager.getNewRows();

      // then
      expect(newRows.length, 1);
    });

    testWidgets('count 3, should be created.', (WidgetTester tester) async {
      // given
      List<TrinaColumn> columns = [
        ...ColumnHelper.textColumn('text', count: 2),
      ];

      List<TrinaRow> rows = [];

      TrinaGridStateManager stateManager = createStateManager(
        columns: columns,
        rows: rows,
        gridFocusNode: null,
        scroll: null,
      );
      // when
      List<TrinaRow> newRows = stateManager.getNewRows(count: 3);

      // then
      expect(newRows.length, 3);
    });
  });

  group('removeCurrentRow', () {
    testWidgets('Should not be removed rows, when currentRow is null.', (
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
      );

      // when
      stateManager.removeCurrentRow();

      // then
      expect(stateManager.rows.length, 5);
    });

    testWidgets('Should be removed currentRow, when currentRow is not null.', (
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
        layout: const BoxConstraints(),
      );

      // when
      final currentRowKey = rows[3].key;

      stateManager.setCurrentCell(rows[3].cells['text1'], 3);

      stateManager.removeCurrentRow();

      // then
      expect(stateManager.rows.length, 4);
      expect(stateManager.rows[0].key, isNot(currentRowKey));
      expect(stateManager.rows[1].key, isNot(currentRowKey));
      expect(stateManager.rows[2].key, isNot(currentRowKey));
      expect(stateManager.rows[3].key, isNot(currentRowKey));
    });
  });

  group('removeRows', () {
    testWidgets('Should not be removed rows, when rows parameter is null.', (
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
      );

      // when
      stateManager.removeRows([]);

      // then
      expect(stateManager.rows.length, 5);
    });

    testWidgets('Should be removed rows, when rows parameter is not null.', (
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
      );

      // when
      final deleteRows = [rows[0], rows[1]];

      stateManager.removeRows(deleteRows);

      // then
      final deleteRowKeys = deleteRows
          .map((e) => e.key)
          .toList(growable: false);

      expect(stateManager.rows.length, 3);
      expect(deleteRowKeys.contains(stateManager.rows[0].key), false);
      expect(deleteRowKeys.contains(stateManager.rows[1].key), false);
      expect(deleteRowKeys.contains(stateManager.rows[2].key), false);
    });

    testWidgets('Should be removed all rows', (WidgetTester tester) async {
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
      );

      // when
      final deleteRows = [...rows];

      stateManager.removeRows(deleteRows);

      // then
      expect(stateManager.rows.length, 0);
    });
  });

  group('moveRowsByOffset', () {
    testWidgets('Move the 0th row to the 1st row.', (
      WidgetTester tester,
    ) async {
      // given
      List<TrinaColumn> columns = [
        ...ColumnHelper.textColumn('text', count: 3, width: 150),
      ];

      List<TrinaRow> rows = RowHelper.count(5, columns);

      when(scroll.verticalOffset).thenReturn(0);

      TrinaGridStateManager stateManager = createStateManager(
        columns: columns,
        rows: rows,
        gridFocusNode: null,
        scroll: scroll,
        layout: const BoxConstraints(maxWidth: 500, maxHeight: 300),
      );

      stateManager.setGridGlobalOffset(const Offset(0.0, 0.0));

      final listener = MockMethods();

      stateManager.addListener(listener.noParamReturnVoid);

      // when
      final rowKey = rows.first.key;

      // header size + row 0 + row 1(중간)
      final offset = stateManager.rowTotalHeight * 2.5;

      stateManager.moveRowsByOffset([rows.first], offset);

      // then
      expect(stateManager.rows.length, 5);
      expect(stateManager.rows[1].key, rowKey);
      verify(listener.noParamReturnVoid()).called(1);
    });

    testWidgets('Move the 2nd row to the 1st row.', (
      WidgetTester tester,
    ) async {
      // given
      List<TrinaColumn> columns = [
        ...ColumnHelper.textColumn('text', count: 3, width: 150),
      ];

      List<TrinaRow> rows = RowHelper.count(5, columns);

      when(scroll.verticalOffset).thenReturn(0);

      TrinaGridStateManager stateManager = createStateManager(
        columns: columns,
        rows: rows,
        gridFocusNode: null,
        scroll: scroll,
        layout: const BoxConstraints(maxWidth: 500, maxHeight: 300),
      );

      stateManager.setGridGlobalOffset(const Offset(0.0, 0.0));

      final listener = MockMethods();

      stateManager.addListener(listener.noParamReturnVoid);

      // when
      final rowKey = rows[2].key;

      // header size + row 0 + row 1(중간)
      final offset = stateManager.rowTotalHeight * 2.5;

      stateManager.moveRowsByOffset([rows[2]], offset);

      // then
      expect(stateManager.rows.length, 5);
      expect(stateManager.rows[1].key, rowKey);
      verify(listener.noParamReturnVoid()).called(1);
    });

    testWidgets(
      'Move the index + number of rows to be moved is greater than the total number of rows.',
      (WidgetTester tester) async {
        // given
        List<TrinaColumn> columns = [
          ...ColumnHelper.textColumn('text', count: 3, width: 150),
        ];

        List<TrinaRow> rows = RowHelper.count(5, columns);

        when(scroll.verticalOffset).thenReturn(0);

        TrinaGridStateManager stateManager = createStateManager(
          columns: columns,
          rows: rows,
          gridFocusNode: null,
          scroll: scroll,
          layout: const BoxConstraints(maxWidth: 500, maxHeight: 300),
        );

        stateManager.setGridGlobalOffset(const Offset(0.0, 0.0));

        final listener = MockMethods();

        stateManager.addListener(listener.noParamReturnVoid);

        // when
        final rowKey = rows.first.key;

        // header size + row0 ~ row4
        final offset = stateManager.rowTotalHeight * 5.5;

        stateManager.moveRowsByOffset(<TrinaRow>[rows.first], offset);

        // then
        expect(stateManager.rows.length, 5);
        expect(stateManager.rows[4].key, rowKey);
        verify(listener.noParamReturnVoid()).called(1);
      },
    );

    testWidgets(
      'When the offset value is less than 0, notifyListener should not be called.',
      (WidgetTester tester) async {
        // given
        List<TrinaColumn> columns = [
          ...ColumnHelper.textColumn('text', count: 3, width: 150),
        ];

        List<TrinaRow> rows = RowHelper.count(5, columns);

        when(scroll.verticalOffset).thenReturn(0);

        TrinaGridStateManager stateManager = createStateManager(
          columns: columns,
          rows: rows,
          gridFocusNode: null,
          scroll: scroll,
          layout: const BoxConstraints(maxWidth: 500, maxHeight: 300),
        );

        stateManager.setGridGlobalOffset(const Offset(0.0, 0.0));

        final listener = MockMethods();

        stateManager.addListener(listener.noParamReturnVoid);

        // when
        const offset = -10.0;

        stateManager.moveRowsByOffset([rows.first], offset);

        // then
        expect(stateManager.rows.length, 5);
        verifyNever(listener.noParamReturnVoid());
      },
    );

    testWidgets(
      'When the offset value is greater than the row range, notifyListener should not be called.',
      (WidgetTester tester) async {
        // given
        List<TrinaColumn> columns = [
          ...ColumnHelper.textColumn('text', count: 3, width: 150),
        ];

        List<TrinaRow> rows = RowHelper.count(5, columns);

        when(scroll.verticalOffset).thenReturn(0);

        TrinaGridStateManager stateManager = createStateManager(
          columns: columns,
          rows: rows,
          gridFocusNode: null,
          scroll: scroll,
          layout: const BoxConstraints(maxWidth: 500, maxHeight: 300),
        );

        stateManager.setGridGlobalOffset(const Offset(0.0, 0.0));

        final listener = MockMethods();

        stateManager.addListener(listener.noParamReturnVoid);

        // when
        // header + row0 ~ row4 + 1
        final offset = stateManager.rowTotalHeight * 7;

        stateManager.moveRowsByOffset([rows.first], offset);

        // then
        expect(stateManager.rows.length, 5);
        verifyNever(listener.noParamReturnVoid());
      },
    );

    testWidgets(
      'When createHeader is present, move the 1st row to the 0th row.',
      (WidgetTester tester) async {
        // given
        List<TrinaColumn> columns = [
          ...ColumnHelper.textColumn('text', count: 3, width: 150),
        ];

        List<TrinaRow> rows = RowHelper.count(5, columns);

        when(scroll.verticalOffset).thenReturn(0);

        TrinaGridStateManager stateManager = createStateManager(
          columns: columns,
          rows: rows,
          gridFocusNode: null,
          scroll: scroll,
          createHeader: (TrinaGridStateManager? stateManager) =>
              const Text('header'),
          layout: const BoxConstraints(maxWidth: 500, maxHeight: 300),
        );

        stateManager.setGridGlobalOffset(const Offset(0.0, 0.0));

        final listener = MockMethods();

        stateManager.addListener(listener.noParamReturnVoid);

        // when
        final rowKey = rows[1].key;

        // header size + column size + row 0(중간)
        final offset = stateManager.rowTotalHeight * 2.5;

        stateManager.moveRowsByOffset([rows[1]], offset);

        // then
        expect(stateManager.rows.length, 5);
        expect(stateManager.rows[0].key, rowKey);
        verify(listener.noParamReturnVoid()).called(1);
      },
    );
  });

  group('moveRowsByIndex', () {
    testWidgets('Move the 0th row to the 1st row.', (
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
        scroll: scroll,
      );

      final listener = MockMethods();

      stateManager.addListener(listener.noParamReturnVoid);

      // when
      final rowKey = rows.first.key;

      stateManager.moveRowsByIndex([rows.first], 1);

      // then
      expect(stateManager.rows.length, 5);
      expect(stateManager.rows[1].key, rowKey);
      verify(listener.noParamReturnVoid()).called(1);
    });

    testWidgets('Move the 2nd row to the 1st row.', (
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
        scroll: scroll,
      );

      final listener = MockMethods();

      stateManager.addListener(listener.noParamReturnVoid);

      // when
      final rowKey = rows[2].key;

      stateManager.moveRowsByIndex([rows[2]], 1);

      // then
      expect(stateManager.rows.length, 5);
      expect(stateManager.rows[1].key, rowKey);
      verify(listener.noParamReturnVoid()).called(1);
    });

    testWidgets('When there are 2 rows, move the 0th row to the 1st row.', (
      WidgetTester tester,
    ) async {
      // given
      List<TrinaColumn> columns = [
        ...ColumnHelper.textColumn('text', count: 3, width: 150),
      ];

      List<TrinaRow> rows = RowHelper.count(2, columns);

      TrinaGridStateManager stateManager = createStateManager(
        columns: columns,
        rows: rows,
        gridFocusNode: null,
        scroll: scroll,
      );

      final listener = MockMethods();

      stateManager.addListener(listener.noParamReturnVoid);

      // when
      final rowKey = rows[0].key;

      stateManager.moveRowsByIndex([rows[0]], 1);

      // then
      expect(stateManager.rows.length, 2);
      expect(stateManager.rows[1].key, rowKey);
      verify(listener.noParamReturnVoid()).called(1);
    });
  });

  group('toggleAllRowChecked', () {
    testWidgets('All rows should be changed to checked true.', (
      WidgetTester tester,
    ) async {
      // given
      List<TrinaColumn> columns = ColumnHelper.textColumn(
        'body',
        count: 1,
        width: 150,
      );

      List<TrinaRow> rows = [...RowHelper.count(10, columns)];

      TrinaGridStateManager stateManager = createStateManager(
        columns: columns,
        rows: rows,
        gridFocusNode: null,
        scroll: null,
      );

      final listener = MockMethods();

      stateManager.addListener(listener.noParamReturnVoid);

      // when
      stateManager.toggleAllRowChecked(true);

      // then
      expect(stateManager.rows.where((element) => element.checked!).length, 10);
      verify(listener.noParamReturnVoid()).called(1);
    });

    testWidgets('All rows should be changed to checked false.', (
      WidgetTester tester,
    ) async {
      // given
      List<TrinaColumn> columns = ColumnHelper.textColumn(
        'body',
        count: 1,
        width: 150,
      );

      List<TrinaRow> rows = [...RowHelper.count(10, columns)];

      TrinaGridStateManager stateManager = createStateManager(
        columns: columns,
        rows: rows,
        gridFocusNode: null,
        scroll: null,
      );

      final listener = MockMethods();

      stateManager.addListener(listener.noParamReturnVoid);

      // when
      stateManager.toggleAllRowChecked(false);

      // then
      expect(
        stateManager.rows.where((element) => !element.checked!).length,
        10,
      );
      verify(listener.noParamReturnVoid()).called(1);
    });

    testWidgets('When notify is false, notifyListener should not be called.', (
      WidgetTester tester,
    ) async {
      // given
      List<TrinaColumn> columns = ColumnHelper.textColumn(
        'body',
        count: 1,
        width: 150,
      );

      List<TrinaRow> rows = [...RowHelper.count(10, columns)];

      TrinaGridStateManager stateManager = createStateManager(
        columns: columns,
        rows: rows,
        gridFocusNode: null,
        scroll: null,
      );

      final listener = MockMethods();

      stateManager.addListener(listener.noParamReturnVoid);

      // when
      stateManager.toggleAllRowChecked(true, notify: false);

      // then
      expect(stateManager.rows.where((element) => element.checked!).length, 10);
      verifyNever(listener.noParamReturnVoid());
    });
  });
}
