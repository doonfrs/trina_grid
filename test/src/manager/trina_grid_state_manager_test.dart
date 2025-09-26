import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:trina_grid/trina_grid.dart';

import '../../helper/column_helper.dart';
import '../../helper/row_helper.dart';

class _MockScrollController extends Mock implements ScrollController {}

void main() {
  group('selectingModes', () {
    test('Square, Row, None should be returned.', () {
      const selectingModes = TrinaGridSelectingMode.values;

      expect(selectingModes.contains(TrinaGridSelectingMode.cell), isTrue);
      expect(selectingModes.contains(TrinaGridSelectingMode.row), isTrue);
      expect(selectingModes.contains(TrinaGridSelectingMode.none), isTrue);
    });
  });

  group('TrinaScrollController', () {
    test('bodyRowsVertical', () {
      final TrinaGridScrollController scrollController =
          TrinaGridScrollController();

      ScrollController scroll = _MockScrollController();
      ScrollController anotherScroll = _MockScrollController();

      scrollController.setBodyRowsVertical(scroll);

      expect(scrollController.bodyRowsVertical == scroll, isTrue);
      expect(scrollController.bodyRowsVertical == anotherScroll, isFalse);
      expect(scroll == anotherScroll, isFalse);
    });
  });

  group('TrinaCellPosition', () {
    testWidgets('null comparison should return false.', (
      WidgetTester tester,
    ) async {
      // given
      const cellPositionA = TrinaGridCellPosition(columnIdx: 1, rowIdx: 1);

      TrinaGridCellPosition? cellPositionB;

      // when
      final bool compare = cellPositionA == cellPositionB;
      // then

      expect(compare, false);
    });

    testWidgets('values are different, comparison should return false.', (
      WidgetTester tester,
    ) async {
      // given
      const cellPositionA = TrinaGridCellPosition(columnIdx: 1, rowIdx: 1);

      const cellPositionB = TrinaGridCellPosition(columnIdx: 2, rowIdx: 1);

      // when
      final bool compare = cellPositionA == cellPositionB;
      // then

      expect(compare, false);
    });

    testWidgets('values are same, comparison should return true.', (
      WidgetTester tester,
    ) async {
      // given
      const cellPositionA = TrinaGridCellPosition(columnIdx: 1, rowIdx: 1);

      const cellPositionB = TrinaGridCellPosition(columnIdx: 1, rowIdx: 1);

      // when
      final bool compare = cellPositionA == cellPositionB;
      // then

      expect(compare, true);
    });
  });

  group('initializeRows', () {
    test('The sortIdx of the row passed should be set.', () {
      final List<TrinaColumn> columns = ColumnHelper.textColumn('title');

      final List<TrinaRow> rows = [
        TrinaRow(cells: {'title0': TrinaCell(value: 'test')}),
        TrinaRow(cells: {'title0': TrinaCell(value: 'test')}),
        TrinaRow(cells: {'title0': TrinaCell(value: 'test')}),
        TrinaRow(cells: {'title0': TrinaCell(value: 'test')}),
        TrinaRow(cells: {'title0': TrinaCell(value: 'test')}),
      ];

      TrinaGridStateManager.initializeRows(
        columns,
        rows,
        forceApplySortIdx: true,
      );

      expect(rows.first.sortIdx, 0);
      expect(rows.last.sortIdx, 4);
    });

    test(
      'forceApplySortIdx is false and sortIdx is already set, sortIdx should be preserved.',
      () {
        final List<TrinaColumn> columns = ColumnHelper.textColumn('title');

        final List<TrinaRow> rows = [
          TrinaRow(cells: {'title0': TrinaCell(value: 'test')}, sortIdx: 3),
          TrinaRow(cells: {'title0': TrinaCell(value: 'test')}, sortIdx: 4),
          TrinaRow(cells: {'title0': TrinaCell(value: 'test')}, sortIdx: 5),
        ];

        expect(rows.first.sortIdx, 3);
        expect(rows.last.sortIdx, 5);

        TrinaGridStateManager.initializeRows(
          columns,
          rows,
          forceApplySortIdx: false,
        );

        expect(rows.first.sortIdx, 3);
        expect(rows.last.sortIdx, 5);
      },
    );

    test('forceApplySortIdx is true, sortIdx should be reset to 0.', () {
      final List<TrinaColumn> columns = ColumnHelper.textColumn('title');

      final List<TrinaRow> rows = [
        TrinaRow(cells: {'title0': TrinaCell(value: 'test')}, sortIdx: 3),
        TrinaRow(cells: {'title0': TrinaCell(value: 'test')}, sortIdx: 4),
        TrinaRow(cells: {'title0': TrinaCell(value: 'test')}, sortIdx: 5),
      ];

      expect(rows.first.sortIdx, 3);
      expect(rows.last.sortIdx, 5);

      TrinaGridStateManager.initializeRows(
        columns,
        rows,
        forceApplySortIdx: true,
      );

      expect(rows.first.sortIdx, 0);
      expect(rows.last.sortIdx, 2);
    });

    test('increase is false, values should be set from 0 to negative.', () {
      final List<TrinaColumn> columns = ColumnHelper.textColumn('title');

      final List<TrinaRow> rows = [
        TrinaRow(cells: {'title0': TrinaCell(value: 'test')}),
        TrinaRow(cells: {'title0': TrinaCell(value: 'test')}),
        TrinaRow(cells: {'title0': TrinaCell(value: 'test')}),
        TrinaRow(cells: {'title0': TrinaCell(value: 'test')}),
        TrinaRow(cells: {'title0': TrinaCell(value: 'test')}),
      ];

      TrinaGridStateManager.initializeRows(
        columns,
        rows,
        increase: false,
        forceApplySortIdx: true,
      );

      expect(rows.first.sortIdx, 0);
      expect(rows.last.sortIdx, -4);
    });

    test(
      'increase is false, start is -10, values should be set from -10 to negative.',
      () {
        final List<TrinaColumn> columns = ColumnHelper.textColumn('title');

        final List<TrinaRow> rows = [
          TrinaRow(cells: {'title0': TrinaCell(value: 'test')}),
          TrinaRow(cells: {'title0': TrinaCell(value: 'test')}),
          TrinaRow(cells: {'title0': TrinaCell(value: 'test')}),
          TrinaRow(cells: {'title0': TrinaCell(value: 'test')}),
          TrinaRow(cells: {'title0': TrinaCell(value: 'test')}),
        ];

        TrinaGridStateManager.initializeRows(
          columns,
          rows,
          increase: false,
          start: -10,
          forceApplySortIdx: true,
        );

        expect(rows.first.sortIdx, -10);
        expect(rows.last.sortIdx, -14);
      },
    );

    test(
      'When the column type is number, the cell value should be cast to number.',
      () {
        final List<TrinaColumn> columns = [
          TrinaColumn(
            title: 'title',
            field: 'field',
            type: TrinaColumnType.number(),
          ),
        ];

        final List<TrinaRow> rows = [
          TrinaRow(cells: {'field': TrinaCell(value: '10')}),
          TrinaRow(cells: {'field': TrinaCell(value: '300')}),
          TrinaRow(cells: {'field': TrinaCell(value: 1000)}),
        ];

        TrinaGridStateManager.initializeRows(columns, rows);

        expect(rows[0].cells['field']!.value, 10);
        expect(rows[1].cells['field']!.value, 300);
        expect(rows[2].cells['field']!.value, 1000);
      },
    );

    test(
      'When applyFormatOnInit is false, the cell value should not be cast.',
      () {
        final List<TrinaColumn> columns = [
          TrinaColumn(
            title: 'title',
            field: 'field',
            type: TrinaColumnType.number(applyFormatOnInit: false),
          ),
        ];

        final List<TrinaRow> rows = [
          TrinaRow(cells: {'field': TrinaCell(value: '10')}),
          TrinaRow(cells: {'field': TrinaCell(value: '300')}),
          TrinaRow(cells: {'field': TrinaCell(value: 1000)}),
        ];

        TrinaGridStateManager.initializeRows(columns, rows);

        expect(rows[0].cells['field']!.value, '10');
        expect(rows[1].cells['field']!.value, '300');
        expect(rows[2].cells['field']!.value, 1000);
      },
    );

    test(
      'When the column type is Date, the cell value should be formatted.',
      () {
        final List<TrinaColumn> columns = [
          TrinaColumn(
            title: 'title',
            field: 'field',
            type: TrinaColumnType.date(),
          ),
        ];

        final List<TrinaRow> rows = [
          TrinaRow(cells: {'field': TrinaCell(value: '2021-01-01 12:30:51')}),
          TrinaRow(cells: {'field': TrinaCell(value: '2021-01-03 12:40:52')}),
          TrinaRow(cells: {'field': TrinaCell(value: '2021-01-04 12:50:53')}),
        ];

        TrinaGridStateManager.initializeRows(columns, rows);

        expect(rows[0].cells['field']!.value, '2021-01-01');
        expect(rows[1].cells['field']!.value, '2021-01-03');
        expect(rows[2].cells['field']!.value, '2021-01-04');
      },
    );

    test(
      'When applyFormatOnInit is false, the cell value should not be formatted.',
      () {
        final List<TrinaColumn> columns = [
          TrinaColumn(
            title: 'title',
            field: 'field',
            type: TrinaColumnType.date(applyFormatOnInit: false),
          ),
        ];

        final List<TrinaRow> rows = [
          TrinaRow(cells: {'field': TrinaCell(value: '2021-01-01 12:30:51')}),
          TrinaRow(cells: {'field': TrinaCell(value: '2021-01-03 12:40:52')}),
          TrinaRow(cells: {'field': TrinaCell(value: '2021-01-04 12:50:53')}),
        ];

        TrinaGridStateManager.initializeRows(columns, rows);

        expect(rows[0].cells['field']!.value, '2021-01-01 12:30:51');
        expect(rows[1].cells['field']!.value, '2021-01-03 12:40:52');
        expect(rows[2].cells['field']!.value, '2021-01-04 12:50:53');
      },
    );

    test('When format is set, the cell value should be formatted.', () {
      final List<TrinaColumn> columns = [
        TrinaColumn(
          title: 'title',
          field: 'field',
          type: TrinaColumnType.date(format: 'yyyy-MM-dd'),
        ),
      ];

      final List<TrinaRow> rows = [
        TrinaRow(cells: {'field': TrinaCell(value: '2021-01-01 12:30:51')}),
        TrinaRow(cells: {'field': TrinaCell(value: '2021-01-03 12:40:52')}),
        TrinaRow(cells: {'field': TrinaCell(value: '2021-01-04 12:50:53')}),
      ];

      TrinaGridStateManager.initializeRows(columns, rows);

      expect(rows[0].cells['field']!.value, '2021-01-01');
      expect(rows[1].cells['field']!.value, '2021-01-03');
      expect(rows[2].cells['field']!.value, '2021-01-04');
    });

    test('When the cell value is set, the row and column should be set.', () {
      final List<TrinaColumn> columns = [
        TrinaColumn(
          title: 'title',
          field: 'field',
          type: TrinaColumnType.date(format: 'yyyy-MM-dd'),
        ),
      ];

      final List<TrinaRow> rows = [
        TrinaRow(cells: {'field': TrinaCell(value: '2021-01-01')}),
        TrinaRow(cells: {'field': TrinaCell(value: '2021-01-03')}),
        TrinaRow(cells: {'field': TrinaCell(value: '2021-01-04')}),
      ];

      TrinaGridStateManager.initializeRows(columns, rows);

      expect(rows[0].cells['field']!.row, rows[0]);
      expect(rows[0].cells['field']!.column, columns.first);

      expect(rows[1].cells['field']!.row, rows[1]);
      expect(rows[1].cells['field']!.column, columns.first);

      expect(rows[2].cells['field']!.row, rows[2]);
      expect(rows[2].cells['field']!.column, columns.first);
    });
  });

  group('initializeRowsAsync', () {
    test('When chunkSize is 0, an assertion error should be thrown.', () async {
      final List<TrinaColumn> columns = ColumnHelper.textColumn('title');

      final List<TrinaRow> rows = RowHelper.count(1, columns);

      expect(() async {
        await TrinaGridStateManager.initializeRowsAsync(
          columns,
          rows,
          chunkSize: 0,
        );
      }, throwsAssertionError);
    });

    test(
      'When chunkSize is -1, an assertion error should be thrown.',
      () async {
        final List<TrinaColumn> columns = ColumnHelper.textColumn('title');

        final List<TrinaRow> rows = RowHelper.count(1, columns);

        expect(() async {
          await TrinaGridStateManager.initializeRowsAsync(
            columns,
            rows,
            chunkSize: -1,
          );
        }, throwsAssertionError);
      },
    );

    test('When the sortIdx is 0, '
        'the rows should be sorted with the start value changed.', () async {
      final List<TrinaColumn> columns = ColumnHelper.textColumn('title');

      final List<TrinaRow> rows = RowHelper.count(100, columns);

      final Iterable<Key> rowKeys = rows.map((e) => e.key);

      expect(rows.first.sortIdx, 0);
      expect(rows.last.sortIdx, 99);

      final initializedRows = await TrinaGridStateManager.initializeRowsAsync(
        columns,
        rows,
        forceApplySortIdx: true,
        start: 10,
        chunkSize: 10,
        duration: const Duration(milliseconds: 1),
      );

      for (int i = 0; i < initializedRows.length; i += 1) {
        expect(initializedRows[i].sortIdx, 10 + i);
        expect(initializedRows[i].key, rowKeys.elementAt(i));
      }
    });

    test('When the sortIdx is 0, '
        'the rows should be sorted with the start value changed.', () async {
      final List<TrinaColumn> columns = ColumnHelper.textColumn('title');

      final List<TrinaRow> rows = RowHelper.count(100, columns);

      final Iterable<Key> rowKeys = rows.map((e) => e.key);

      expect(rows.first.sortIdx, 0);
      expect(rows.last.sortIdx, 99);

      final initializedRows = await TrinaGridStateManager.initializeRowsAsync(
        columns,
        rows,
        forceApplySortIdx: true,
        start: -10,
        chunkSize: 10,
        duration: const Duration(milliseconds: 1),
      );

      for (int i = 0; i < initializedRows.length; i += 1) {
        expect(initializedRows[i].sortIdx, -10 + i);
        expect(initializedRows[i].key, rowKeys.elementAt(i));
      }
    });

    test('When the sortIdx is 0, '
        'the rows should be sorted with the start value changed.', () async {
      final List<TrinaColumn> columns = ColumnHelper.textColumn('title');

      final List<TrinaRow> rows = RowHelper.count(100, columns);

      final Iterable<Key> rowKeys = rows.map((e) => e.key);

      expect(rows.first.sortIdx, 0);
      expect(rows.last.sortIdx, 99);

      final initializedRows = await TrinaGridStateManager.initializeRowsAsync(
        columns,
        rows,
        forceApplySortIdx: true,
        start: -10,
        chunkSize: 10,
        duration: const Duration(milliseconds: 1),
      );

      for (int i = 0; i < initializedRows.length; i += 1) {
        expect(initializedRows[i].sortIdx, -10 + i);
        expect(initializedRows[i].key, rowKeys.elementAt(i));
      }
    });

    test('When a single row is passed and chunkSize is 10, '
        'it should return normally.', () async {
      final List<TrinaColumn> columns = ColumnHelper.textColumn('title');

      final List<TrinaRow> rows = RowHelper.count(1, columns);

      final initializedRows = await TrinaGridStateManager.initializeRowsAsync(
        columns,
        rows,
        forceApplySortIdx: true,
        start: 99,
        chunkSize: 10,
        duration: const Duration(milliseconds: 1),
      );

      expect(initializedRows.first.sortIdx, 99);
    });
  });
}
