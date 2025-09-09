import 'package:flutter_test/flutter_test.dart';
import 'package:trina_grid/trina_grid.dart';

import '../../../helper/column_helper.dart';
import '../../../helper/row_helper.dart';
import '../../../mock/mock_methods.dart';
import '../../../mock/shared_mocks.mocks.dart';

void main() {
  List<TrinaColumn> columns;

  List<TrinaRow> rows;

  late TrinaGridStateManager stateManager;

  MockMethods listener;

  setUp(() {
    columns = [
      ...ColumnHelper.textColumn('column', count: 2, width: 150),
    ];

    rows = RowHelper.count(10, columns);

    stateManager = TrinaGridStateManager(
      columns: columns,
      rows: rows,
      gridFocusNode: MockFocusNode(),
      scroll: MockTrinaGridScrollController(),
    );

    listener = MockMethods();

    stateManager.addListener(listener.noParamReturnVoid);
  });

  group('hasFilter', () {
    test(
      'when filter is not set, '
      'should be returned false.',
      () {
        expect(stateManager.hasFilter, isFalse);
      },
    );

    test(
      'when filter is set, '
      'should be returned true.',
      () {
        var filter = FilterHelper.convertRowsToFilter(
          [FilterHelper.createFilterRow()],
          [],
        );

        stateManager.setFilter(filter);

        expect(stateManager.hasFilter, isTrue);
      },
    );
  });

  group('setFilter', () {
    test(
      'should be changed to none of state of row.',
      () {
        var filter = FilterHelper.convertRowsToFilter(
          [FilterHelper.createFilterRow()],
          [],
        );

        for (var i = 0; i < stateManager.rows.length; i += 1) {
          stateManager.rows[i].setState(TrinaRowState.updated);
        }

        for (var i = 0; i < stateManager.rows.length; i += 1) {
          expect(stateManager.rows[i].state, TrinaRowState.updated);
        }

        stateManager.setFilter(filter);

        for (var i = 0; i < stateManager.rows.length; i += 1) {
          expect(stateManager.rows[i].state, TrinaRowState.none);
        }
      },
    );

    test(
      'when filter is null, filterRows should be set to an empty List',
      () {
        expect(stateManager.filterRows.length, 0);

        stateManager.setFilterWithFilterRows(
          [FilterHelper.createFilterRow(filterValue: 'filter')],
        );

        expect(stateManager.filterRows.length, 1);

        stateManager.setFilter(null);

        expect(stateManager.filterRows.length, 0);
      },
    );
  });

  group('filterRowsByField', () {
    test(
      'When there is 0 column1 in filterRows, '
      'Should return 0 list.',
      () {
        expect(stateManager.filterRows.length, 0);

        stateManager.setFilterWithFilterRows(
          [
            FilterHelper.createFilterRow(
              columnField: 'column2',
              filterValue: 'filter',
            ),
            FilterHelper.createFilterRow(
              columnField: 'column3',
              filterValue: 'filter',
            ),
          ],
        );

        var filterRows = stateManager.filterRowsByField('column1');

        expect(filterRows.length, 0);
      },
    );

    test(
      'When there is 1 column1 in filterRows, '
      'Should return 1 list.',
      () {
        expect(stateManager.filterRows.length, 0);

        stateManager.setFilterWithFilterRows(
          [
            FilterHelper.createFilterRow(
              columnField: 'column1',
              filterValue: 'filter',
            ),
            FilterHelper.createFilterRow(
              columnField: 'column2',
              filterValue: 'filter',
            ),
          ],
        );

        var filterRows = stateManager.filterRowsByField('column1');

        expect(filterRows.length, 1);
      },
    );

    test(
      'When there is 2 column1 in filterRows, '
      'Should return 2 list.',
      () {
        expect(stateManager.filterRows.length, 0);

        stateManager.setFilterWithFilterRows(
          [
            FilterHelper.createFilterRow(
              columnField: 'column1',
              filterValue: 'filter',
            ),
            FilterHelper.createFilterRow(
              columnField: 'column1',
              filterValue: 'filter',
            ),
            FilterHelper.createFilterRow(
              columnField: 'column2',
              filterValue: 'filter',
            ),
          ],
        );

        var filterRows = stateManager.filterRowsByField('column1');

        expect(filterRows.length, 2);
      },
    );
  });

  group('isFilteredColumn', () {
    test(
      'when there is no filter, should be returned false.',
      () {
        var column = stateManager.columns.first;

        expect(stateManager.hasFilter, isFalse);

        expect(stateManager.isFilteredColumn(column), isFalse);
      },
    );

    test(
      'when filterRows is empty, should be returned false.',
      () {
        var column = stateManager.columns.first;

        expect(stateManager.filterRows.length, 0);

        expect(stateManager.isFilteredColumn(column), isFalse);
      },
    );

    test(
      'when filterRows is empty, should be returned false.',
      () {
        var column = stateManager.columns.first;

        var filter = FilterHelper.convertRowsToFilter(
          [FilterHelper.createFilterRow()],
          [],
        );

        stateManager.setFilter(filter);

        expect(stateManager.hasFilter, isTrue);

        expect(stateManager.filterRows.length, 0);

        expect(stateManager.isFilteredColumn(column), isFalse);
      },
    );

    test(
      'when the column is filtered, should be returned true.',
      () {
        var column = stateManager.columns.first;

        stateManager.setFilterWithFilterRows([
          FilterHelper.createFilterRow(
            columnField: column.field,
            filterValue: 'filter',
          )
        ]);

        expect(stateManager.hasFilter, isTrue);

        expect(stateManager.filterRows.length, 1);

        expect(stateManager.isFilteredColumn(column), isTrue);
      },
    );

    test(
      'when the column is not filtered, should be returned false.',
      () {
        var column = stateManager.columns.first;

        stateManager.setFilterWithFilterRows([
          FilterHelper.createFilterRow(
            columnField: stateManager.columns.last.field,
            filterValue: 'filter',
          ),
        ]);

        expect(stateManager.hasFilter, isTrue);

        expect(stateManager.filterRows.length, 1);

        expect(stateManager.isFilteredColumn(column), isFalse);
      },
    );
  });

  group('setColumnFilter', () {
    test(
      'should add new filter when column has no existing filter',
      () {
        expect(stateManager.filterRows.length, 0);

        stateManager.setColumnFilter(
          columnField: 'column1',
          filterType: const TrinaFilterTypeContains(),
          filterValue: 'test',
        );

        expect(stateManager.filterRows.length, 1);
        expect(
          stateManager.filterRows.first.cells[FilterHelper.filterFieldColumn]!.value,
          'column1',
        );
        expect(
          stateManager.filterRows.first.cells[FilterHelper.filterFieldValue]!.value,
          'test',
        );
        expect(
          stateManager.filterRows.first.cells[FilterHelper.filterFieldType]!.value,
          isA<TrinaFilterTypeContains>(),
        );
      },
    );

    test(
      'should update existing filter when column already has filter',
      () {
        // Add initial filter
        stateManager.setColumnFilter(
          columnField: 'column1',
          filterType: const TrinaFilterTypeContains(),
          filterValue: 'test',
        );

        expect(stateManager.filterRows.length, 1);

        // Update existing filter
        stateManager.setColumnFilter(
          columnField: 'column1',
          filterType: const TrinaFilterTypeEquals(),
          filterValue: 'updated',
        );

        expect(stateManager.filterRows.length, 1);
        expect(
          stateManager.filterRows.first.cells[FilterHelper.filterFieldValue]!.value,
          'updated',
        );
        expect(
          stateManager.filterRows.first.cells[FilterHelper.filterFieldType]!.value,
          isA<TrinaFilterTypeEquals>(),
        );
      },
    );

    test(
      'should add multiple filters for different columns',
      () {
        stateManager.setColumnFilter(
          columnField: 'column1',
          filterType: const TrinaFilterTypeContains(),
          filterValue: 'test1',
        );

        stateManager.setColumnFilter(
          columnField: 'column2',
          filterType: const TrinaFilterTypeEquals(),
          filterValue: 'test2',
        );

        expect(stateManager.filterRows.length, 2);
        
        var column1Filter = stateManager.filterRows.firstWhere(
          (row) => row.cells[FilterHelper.filterFieldColumn]!.value == 'column1',
        );
        var column2Filter = stateManager.filterRows.firstWhere(
          (row) => row.cells[FilterHelper.filterFieldColumn]!.value == 'column2',
        );

        expect(column1Filter.cells[FilterHelper.filterFieldValue]!.value, 'test1');
        expect(column2Filter.cells[FilterHelper.filterFieldValue]!.value, 'test2');
      },
    );
  });

  group('removeColumnFilter', () {
    test(
      'should remove specific column filter',
      () {
        // Add multiple filters
        stateManager.setColumnFilter(
          columnField: 'column1',
          filterType: const TrinaFilterTypeContains(),
          filterValue: 'test1',
        );
        
        stateManager.setColumnFilter(
          columnField: 'column2',
          filterType: const TrinaFilterTypeEquals(),
          filterValue: 'test2',
        );

        expect(stateManager.filterRows.length, 2);

        // Remove column1 filter
        stateManager.removeColumnFilter('column1');

        expect(stateManager.filterRows.length, 1);
        expect(
          stateManager.filterRows.first.cells[FilterHelper.filterFieldColumn]!.value,
          'column2',
        );
      },
    );

    test(
      'should do nothing when removing non-existent filter',
      () {
        stateManager.setColumnFilter(
          columnField: 'column1',
          filterType: const TrinaFilterTypeContains(),
          filterValue: 'test',
        );

        expect(stateManager.filterRows.length, 1);

        // Try to remove non-existent filter
        stateManager.removeColumnFilter('nonexistent');

        expect(stateManager.filterRows.length, 1);
        expect(
          stateManager.filterRows.first.cells[FilterHelper.filterFieldColumn]!.value,
          'column1',
        );
      },
    );
  });

  group('clearAllColumnFilters', () {
    test(
      'should remove all filters',
      () {
        // Add multiple filters
        stateManager.setColumnFilter(
          columnField: 'column1',
          filterType: const TrinaFilterTypeContains(),
          filterValue: 'test1',
        );
        
        stateManager.setColumnFilter(
          columnField: 'column2',
          filterType: const TrinaFilterTypeEquals(),
          filterValue: 'test2',
        );

        expect(stateManager.filterRows.length, 2);

        // Clear all filters
        stateManager.clearAllColumnFilters();

        expect(stateManager.filterRows.length, 0);
        expect(stateManager.hasFilter, isFalse);
      },
    );

    test(
      'should do nothing when no filters exist',
      () {
        expect(stateManager.filterRows.length, 0);

        stateManager.clearAllColumnFilters();

        expect(stateManager.filterRows.length, 0);
        expect(stateManager.hasFilter, isFalse);
      },
    );
  });

  group('getColumnFilterValue', () {
    test(
      'should return filter value for existing filter',
      () {
        stateManager.setColumnFilter(
          columnField: 'column1',
          filterType: const TrinaFilterTypeContains(),
          filterValue: 'test_value',
        );

        var filterValue = stateManager.getColumnFilterValue('column1');

        expect(filterValue, 'test_value');
      },
    );

    test(
      'should return null for non-existent filter',
      () {
        var filterValue = stateManager.getColumnFilterValue('nonexistent');

        expect(filterValue, isNull);
      },
    );

    test(
      'should return correct values for different data types',
      () {
        // String value
        stateManager.setColumnFilter(
          columnField: 'column1',
          filterType: const TrinaFilterTypeContains(),
          filterValue: 'string_value',
        );

        // Numeric value
        stateManager.setColumnFilter(
          columnField: 'column2',
          filterType: const TrinaFilterTypeGreaterThan(),
          filterValue: 42,
        );

        // Boolean value
        stateManager.setColumnFilter(
          columnField: 'column3',
          filterType: const TrinaFilterTypeEquals(),
          filterValue: true,
        );

        expect(stateManager.getColumnFilterValue('column1'), 'string_value');
        expect(stateManager.getColumnFilterValue('column2'), 42);
        expect(stateManager.getColumnFilterValue('column3'), true);
      },
    );
  });

  group('getColumnFilterType', () {
    test(
      'should return filter type for existing filter',
      () {
        stateManager.setColumnFilter(
          columnField: 'column1',
          filterType: const TrinaFilterTypeEquals(),
          filterValue: 'test',
        );

        var filterType = stateManager.getColumnFilterType('column1');

        expect(filterType, isA<TrinaFilterTypeEquals>());
      },
    );

    test(
      'should return null for non-existent filter',
      () {
        var filterType = stateManager.getColumnFilterType('nonexistent');

        expect(filterType, isNull);
      },
    );

    test(
      'should return correct filter types for different filters',
      () {
        stateManager.setColumnFilter(
          columnField: 'column1',
          filterType: const TrinaFilterTypeContains(),
          filterValue: 'test',
        );

        stateManager.setColumnFilter(
          columnField: 'column2',
          filterType: const TrinaFilterTypeGreaterThan(),
          filterValue: 10,
        );

        expect(stateManager.getColumnFilterType('column1'), isA<TrinaFilterTypeContains>());
        expect(stateManager.getColumnFilterType('column2'), isA<TrinaFilterTypeGreaterThan>());
      },
    );
  });

  group('integration tests', () {
    test(
      'should handle complete filter lifecycle',
      () {
        // Start with no filters
        expect(stateManager.filterRows.length, 0);
        expect(stateManager.getColumnFilterValue('column1'), isNull);
        expect(stateManager.getColumnFilterType('column1'), isNull);

        // Add filter
        stateManager.setColumnFilter(
          columnField: 'column1',
          filterType: const TrinaFilterTypeContains(),
          filterValue: 'test',
        );

        expect(stateManager.filterRows.length, 1);
        expect(stateManager.getColumnFilterValue('column1'), 'test');
        expect(stateManager.getColumnFilterType('column1'), isA<TrinaFilterTypeContains>());

        // Update filter
        stateManager.setColumnFilter(
          columnField: 'column1',
          filterType: const TrinaFilterTypeEquals(),
          filterValue: 'updated',
        );

        expect(stateManager.filterRows.length, 1);
        expect(stateManager.getColumnFilterValue('column1'), 'updated');
        expect(stateManager.getColumnFilterType('column1'), isA<TrinaFilterTypeEquals>());

        // Remove filter
        stateManager.removeColumnFilter('column1');

        expect(stateManager.filterRows.length, 0);
        expect(stateManager.getColumnFilterValue('column1'), isNull);
        expect(stateManager.getColumnFilterType('column1'), isNull);
      },
    );

    test(
      'should maintain filter integrity with mixed operations',
      () {
        // Add multiple filters
        stateManager.setColumnFilter(
          columnField: 'column1',
          filterType: const TrinaFilterTypeContains(),
          filterValue: 'test1',
        );
        
        stateManager.setColumnFilter(
          columnField: 'column2',
          filterType: const TrinaFilterTypeEquals(),
          filterValue: 42,
        );

        expect(stateManager.filterRows.length, 2);

        // Remove one, add another
        stateManager.removeColumnFilter('column1');
        
        stateManager.setColumnFilter(
          columnField: 'column3',
          filterType: const TrinaFilterTypeGreaterThan(),
          filterValue: true,
        );

        expect(stateManager.filterRows.length, 2);
        expect(stateManager.getColumnFilterValue('column1'), isNull);
        expect(stateManager.getColumnFilterValue('column2'), 42);
        expect(stateManager.getColumnFilterValue('column3'), true);

        // Clear all
        stateManager.clearAllColumnFilters();

        expect(stateManager.filterRows.length, 0);
        expect(stateManager.getColumnFilterValue('column2'), isNull);
        expect(stateManager.getColumnFilterValue('column3'), isNull);
      },
    );
  });
}
