import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:trina_grid/trina_grid.dart';

import '../../helper/column_helper.dart';
import '../../helper/row_helper.dart';
import '../../matcher/trina_object_matcher.dart';
import '../../mock/mock_build_context.dart';
import '../../mock/mock_methods.dart';
import '../../mock/shared_mocks.mocks.dart';

void main() {
  group('createFilterRow', () {
    test(
        'When called without arguments,'
        'Should be returned a row filled with default values.', () {
      var row = FilterHelper.createFilterRow();

      expect(row.cells.length, 3);

      expect(
        row.cells[FilterHelper.filterFieldColumn]!.value,
        FilterHelper.filterFieldAllColumns,
      );

      expect(
        row.cells[FilterHelper.filterFieldType]!.value,
        isA<TrinaFilterTypeContains>(),
      );

      expect(row.cells[FilterHelper.filterFieldValue]!.value, '');
    });

    test(
        'When called with arguments,'
        'Should be returned a row filled with arguments.', () {
      var filter = const TrinaFilterTypeEndsWith();

      var row = FilterHelper.createFilterRow(
        columnField: 'filterColumnField',
        filterType: filter,
        filterValue: 'abc',
      );

      expect(row.cells.length, 3);

      expect(
        row.cells[FilterHelper.filterFieldColumn]!.value,
        'filterColumnField',
      );

      expect(row.cells[FilterHelper.filterFieldType]!.value, filter);

      expect(row.cells[FilterHelper.filterFieldValue]!.value, 'abc');
    });
  });

  group('convertRowsToFilter', () {
    test(
        'When called with empty rows, '
        'Should be returned null.', () {
      expect(FilterHelper.convertRowsToFilter([], []), isNull);
    });

    group('with rows.', () {
      List<TrinaColumn>? columns;

      TrinaRow? row;

      setUp(() {
        columns = ColumnHelper.textColumn('column', count: 3);

        row = TrinaRow(
          cells: {
            'column1': TrinaCell(value: 'column1 value'),
            'column2': TrinaCell(value: 'column2 value'),
            'column3': TrinaCell(value: 'column3 value'),
          },
        );
      });

      test(
          'filterFieldColumn : All, '
          'filterFieldType : Contains, '
          'filterFieldValue : column1, '
          'true', () {
        var filterRows = [FilterHelper.createFilterRow(filterValue: 'column1')];

        var enabledFilterColumns = columns;

        expect(
          FilterHelper.convertRowsToFilter(filterRows, enabledFilterColumns)!(
            row,
          ),
          isTrue,
        );
      });

      test(
          'filterFieldColumn : column2, '
          'filterFieldType : Contains, '
          'filterFieldValue : column1, '
          'false', () {
        var filterRows = [
          FilterHelper.createFilterRow(
            columnField: 'column2',
            filterValue: 'column1',
          ),
        ];

        var enabledFilterColumns = columns;

        expect(
          FilterHelper.convertRowsToFilter(filterRows, enabledFilterColumns)!(
            row,
          ),
          isFalse,
        );
      });

      test(
          'filterFieldColumn : column1, '
          'filterFieldType : StartsWith, '
          'filterFieldValue : column1, '
          'true', () {
        var filterRows = [
          FilterHelper.createFilterRow(
            columnField: 'column1',
            filterType: const TrinaFilterTypeStartsWith(),
            filterValue: 'column1',
          ),
        ];

        var enabledFilterColumns = columns;

        expect(
          FilterHelper.convertRowsToFilter(filterRows, enabledFilterColumns)!(
            row,
          ),
          isTrue,
        );
      });

      test(
          'When column1 does not exist in enabledFilterColumns, '
          'filterFieldColumn : column1, '
          'filterFieldType : Contains, '
          'filterFieldValue : column1, '
          'false', () {
        var filterRows = [
          FilterHelper.createFilterRow(
            columnField: 'column1',
            filterType: const TrinaFilterTypeContains(),
            filterValue: 'column1',
          ),
        ];

        columns!.removeWhere((element) => element.field == 'column1');

        var enabledFilterColumns = columns;

        expect(
          FilterHelper.convertRowsToFilter(filterRows, enabledFilterColumns)!(
            row,
          ),
          isFalse,
        );
      });

      test(
          'filterFieldColumn : All, '
          'filterFieldType : StartsWith, '
          'filterFieldValue : column1, '
          'enabledFilterColumnFields : [column3]'
          'false', () {
        var filterRows = [
          FilterHelper.createFilterRow(
            filterType: const TrinaFilterTypeStartsWith(),
            filterValue: 'column1',
          ),
        ];

        var enabledFilterColumns =
            columns!.where((element) => element.field == 'column3').toList();

        expect(
          FilterHelper.convertRowsToFilter(filterRows, enabledFilterColumns)!(
            row,
          ),
          isFalse,
        );
      });
    });
  });

  group('convertRowsToMap', () {
    test('When filterRows is empty, an empty map should be returned.', () {
      final List<TrinaRow> filterRows = [];

      final result = FilterHelper.convertRowsToMap(filterRows);

      expect(result.isEmpty, true);
      expect(result, isA<Map<String, List<Map<String, String>>>>());
    });

    test('When filterRows is set, the map should be returned with values.', () {
      final List<TrinaRow> filterRows = [
        TrinaRow(
          cells: {
            FilterHelper.filterFieldColumn: TrinaCell(value: 'column'),
            FilterHelper.filterFieldType: TrinaCell(
              value: const TrinaFilterTypeContains(),
            ),
            FilterHelper.filterFieldValue: TrinaCell(value: '123'),
          },
        ),
      ];

      final result = FilterHelper.convertRowsToMap(filterRows);

      expect(result.length, 1);
      expect(
        result,
        TrinaObjectMatcher<Map<String, List<Map<String, String>>>>(
          rule: (value) {
            return value.keys.first == 'column' &&
                value.values.first[0].keys.first ==
                    TrinaFilterTypeContains.name &&
                value.values.first[0].values.first == '123';
          },
        ),
      );
    });

    test(
        'When filterRows has duplicate column conditions, '
        'the map should be returned with values.', () {
      final List<TrinaRow> filterRows = [
        TrinaRow(
          cells: {
            FilterHelper.filterFieldColumn: TrinaCell(value: 'column'),
            FilterHelper.filterFieldType: TrinaCell(
              value: const TrinaFilterTypeContains(),
            ),
            FilterHelper.filterFieldValue: TrinaCell(value: '123'),
          },
        ),
        TrinaRow(
          cells: {
            FilterHelper.filterFieldColumn: TrinaCell(value: 'column'),
            FilterHelper.filterFieldType: TrinaCell(
              value: const TrinaFilterTypeEndsWith(),
            ),
            FilterHelper.filterFieldValue: TrinaCell(value: '456'),
          },
        ),
      ];

      final result = FilterHelper.convertRowsToMap(filterRows);

      expect(result.length, 1);
      expect(
        result,
        TrinaObjectMatcher<Map<String, List<Map<String, String>>>>(
          rule: (value) {
            return value.keys.contains('column') &&
                value['column']!.length == 2 &&
                value['column']![0].keys.contains(
                      TrinaFilterTypeContains.name,
                    ) &&
                value['column']![0].values.contains('123') &&
                value['column']![1].keys.contains(
                      TrinaFilterTypeEndsWith.name,
                    ) &&
                value['column']![1].values.contains('456');
          },
        ),
      );
    });

    test(
        'When all columns are included in the filtering conditions, '
        'the map should be returned with default value all.', () {
      final List<TrinaRow> filterRows = [
        TrinaRow(
          cells: {
            FilterHelper.filterFieldColumn: TrinaCell(value: 'column'),
            FilterHelper.filterFieldType: TrinaCell(
              value: const TrinaFilterTypeContains(),
            ),
            FilterHelper.filterFieldValue: TrinaCell(value: '123'),
          },
        ),
        TrinaRow(
          cells: {
            FilterHelper.filterFieldColumn: TrinaCell(
              value: FilterHelper.filterFieldAllColumns,
            ),
            FilterHelper.filterFieldType: TrinaCell(
              value: const TrinaFilterTypeContains(),
            ),
            FilterHelper.filterFieldValue: TrinaCell(value: '123'),
          },
        ),
      ];

      final result = FilterHelper.convertRowsToMap(filterRows);

      expect(result.length, 2);
      expect(
        result,
        TrinaObjectMatcher<Map<String, List<Map<String, String>>>>(
          rule: (value) {
            return value.containsKey('all');
          },
        ),
      );
    });

    test(
        'When allField is changed to allColumns, '
        'the map should be returned with default value allColumns.', () {
      final List<TrinaRow> filterRows = [
        TrinaRow(
          cells: {
            FilterHelper.filterFieldColumn: TrinaCell(value: 'column'),
            FilterHelper.filterFieldType: TrinaCell(
              value: const TrinaFilterTypeContains(),
            ),
            FilterHelper.filterFieldValue: TrinaCell(value: '123'),
          },
        ),
        TrinaRow(
          cells: {
            FilterHelper.filterFieldColumn: TrinaCell(
              value: FilterHelper.filterFieldAllColumns,
            ),
            FilterHelper.filterFieldType: TrinaCell(
              value: const TrinaFilterTypeContains(),
            ),
            FilterHelper.filterFieldValue: TrinaCell(value: '123'),
          },
        ),
      ];

      final result = FilterHelper.convertRowsToMap(
        filterRows,
        allField: 'allColumns',
      );

      expect(result.length, 2);
      expect(
        result,
        TrinaObjectMatcher<Map<String, List<Map<String, String>>>>(
          rule: (value) {
            return value.containsKey('allColumns');
          },
        ),
      );
    });
  });

  group('isFilteredColumn', () {
    test(
        'filterRows : null, empty, '
        'Should be returned false.', () {
      expect(
        FilterHelper.isFilteredColumn(
          TrinaColumn(
            title: 'column',
            field: 'column',
            type: TrinaColumnType.text(),
          ),
          null,
        ),
        isFalse,
      );

      expect(
        FilterHelper.isFilteredColumn(
          TrinaColumn(
            title: 'column',
            field: 'column',
            type: TrinaColumnType.text(),
          ),
          [],
        ),
        isFalse,
      );
    });

    test(
        'filterRows : [All columns], '
        'Should be returned true.', () {
      expect(
        FilterHelper.isFilteredColumn(
          TrinaColumn(
            title: 'column',
            field: 'column',
            type: TrinaColumnType.text(),
          ),
          [FilterHelper.createFilterRow()],
        ),
        isTrue,
      );
    });

    test(
        'filterRows : [column], '
        'Should be returned true.', () {
      expect(
        FilterHelper.isFilteredColumn(
          TrinaColumn(
            title: 'column',
            field: 'column',
            type: TrinaColumnType.text(),
          ),
          [FilterHelper.createFilterRow(columnField: 'column')],
        ),
        isTrue,
      );
    });

    test(
        'filterRows : [non_exists_column], '
        'Should be returned false.', () {
      expect(
        FilterHelper.isFilteredColumn(
          TrinaColumn(
            title: 'column',
            field: 'column',
            type: TrinaColumnType.text(),
          ),
          [FilterHelper.createFilterRow(columnField: 'non_exists_column')],
        ),
        isFalse,
      );
    });
  });

  group('compareByFilterType', () {
    late bool Function(dynamic a, dynamic b) Function(
      TrinaFilterType filterType, {
      TrinaColumn? column,
    }) makeCompareFunction;

    setUp(() {
      makeCompareFunction = (
        TrinaFilterType filterType, {
        TrinaColumn? column,
      }) {
        column ??= TrinaColumn(
          title: 'column',
          field: 'column',
          type: TrinaColumnType.text(),
        );

        return (dynamic a, dynamic b) {
          return FilterHelper.compareByFilterType(
            filterType: filterType,
            base: a.toString(),
            search: b.toString(),
            column: column!,
          );
        };
      };
    });

    group('Contains', () {
      late Function compare;

      setUp(() {
        compare = makeCompareFunction(const TrinaFilterTypeContains());
      });

      test('apple contains le', () {
        expect(compare('apple', 'le'), isTrue);
      });

      test('apple is not contains banana', () {
        expect(compare('apple', 'banana'), isFalse);
      });
    });

    group('Equals', () {
      late Function compare;

      setUp(() {
        compare = makeCompareFunction(const TrinaFilterTypeEquals());
      });

      test('apple equals apple', () {
        expect(compare('apple', 'apple'), isTrue);
      });

      test('apple is not equals banana', () {
        expect(compare('apple', 'banana'), isFalse);
      });

      test('0 equals "0"', () {
        expect(compare(0, '0'), isTrue);
      });
    });

    group('StartsWith', () {
      late Function compare;

      setUp(() {
        compare = makeCompareFunction(const TrinaFilterTypeStartsWith());
      });

      test('apple startsWith ap', () {
        expect(compare('apple', 'ap'), isTrue);
      });

      test('apple is not startsWith banana', () {
        expect(compare('apple', 'banana'), isFalse);
      });
    });

    group('EndsWith', () {
      late Function compare;

      setUp(() {
        compare = makeCompareFunction(const TrinaFilterTypeEndsWith());
      });

      test('apple endsWith le', () {
        expect(compare('apple', 'le'), isTrue);
      });

      test('apple is not endsWith app', () {
        expect(compare('apple', 'app'), isFalse);
      });
    });

    group('GreaterThan', () {
      late Function compare;

      setUp(() {
        compare = makeCompareFunction(const TrinaFilterTypeGreaterThan());
      });

      test('banana GreaterThan apple', () {
        expect(compare('banana', 'apple'), isTrue);
      });

      test('apple is not GreaterThan banana', () {
        expect(compare('apple', 'banana'), isFalse);
      });
    });

    group('GreaterThanOrEqualTo', () {
      late Function compare;

      setUp(() {
        compare = makeCompareFunction(
          const TrinaFilterTypeGreaterThanOrEqualTo(),
        );
      });

      test('banana GreaterThanOrEqualTo apple', () {
        expect(compare('banana', 'apple'), isTrue);
      });

      test('banana GreaterThanOrEqualTo apple', () {
        expect(compare('banana', 'banana'), isTrue);
      });

      test('apple is not GreaterThanOrEqualTo banana', () {
        expect(compare('apple', 'banana'), isFalse);
      });
    });

    group('LessThan', () {
      late Function compare;

      setUp(() {
        compare = makeCompareFunction(const TrinaFilterTypeLessThan());
      });

      test('A LessThan B', () {
        expect(compare('A', 'B'), isTrue);
      });

      test('B is not LessThan A', () {
        expect(compare('B', 'A'), isFalse);
      });
    });

    group('LessThanOrEqualTo', () {
      late Function compare;

      setUp(() {
        compare = makeCompareFunction(const TrinaFilterTypeLessThanOrEqualTo());
      });

      test('A LessThanOrEqualTo B', () {
        expect(compare('A', 'B'), isTrue);
      });

      test('A LessThanOrEqualTo A', () {
        expect(compare('A', 'A'), isTrue);
      });

      test('B is not LessThanOrEqualTo A', () {
        expect(compare('B', 'A'), isFalse);
      });
    });

    group('Regex', () {
      late Function compare;

      setUp(() {
        compare = makeCompareFunction(const TrinaFilterTypeRegex());
      });

      test('Value matches regex pattern', () {
        expect(compare('apple123', r'apple\d+'), isTrue);
      });

      test('Value with special characters matches regex pattern', () {
        expect(compare('user@example.com', r'.+@.+\..+'), isTrue);
      });

      test('Value does not match regex pattern', () {
        expect(compare('apple', r'^\d+$'), isFalse);
      });

      test('Invalid regex pattern returns false', () {
        expect(compare('apple', r'[unclosed'), isFalse);
      });
    });
  });

  group('FilterPopupState', () {
    test('columns should not be empty.', () {
      expect(() {
        FilterPopupState(
          context: MockBuildContext(),
          configuration: const TrinaGridConfiguration(),
          handleAddNewFilter: (_) {},
          handleApplyFilter: (_) {},
          columns: [],
          filterRows: [],
          focusFirstFilterValue: false,
        );
      }, throwsA(isA<AssertionError>()));
    });

    group('onLoaded', () {
      test('should be called setSelectingMode, addListener.', () {
        final List<TrinaRow> filterRows = [];

        var filterPopupState = FilterPopupState(
          context: MockBuildContext(),
          configuration: const TrinaGridConfiguration(),
          handleAddNewFilter: (_) {},
          handleApplyFilter: (_) {},
          columns: ColumnHelper.textColumn('column'),
          filterRows: filterRows,
          focusFirstFilterValue: false,
        );

        var stateManager = MockTrinaGridStateManager();

        when(stateManager.rows).thenReturn(filterRows);

        filterPopupState.onLoaded(
          TrinaGridOnLoadedEvent(stateManager: stateManager),
        );

        verify(
          stateManager.setSelectingMode(TrinaGridSelectingMode.cellWithCtrl,
              notify: false),
        ).called(1);

        verify(
          stateManager.addListener(filterPopupState.stateListener),
        ).called(1);
      });

      test(
        'if focusFirstFilterValue is true and stateManager has rows, '
        'then setKeepFocus, setCurrentCell and setEditing should be called.',
        () {
          var columns = ColumnHelper.textColumn('column');
          var rows = RowHelper.count(1, columns);

          var filterPopupState = FilterPopupState(
            context: MockBuildContext(),
            configuration: const TrinaGridConfiguration(),
            handleAddNewFilter: (_) {},
            handleApplyFilter: (_) {},
            columns: columns,
            filterRows: [
              FilterHelper.createFilterRow(
                columnField: columns[0].enableFilterMenuItem
                    ? columns[0].field
                    : FilterHelper.filterFieldAllColumns,
                filterType: columns[0].defaultFilter,
              ),
            ],
            focusFirstFilterValue: true,
          );

          var stateManager = MockTrinaGridStateManager();

          when(stateManager.rows).thenReturn(rows);

          filterPopupState.onLoaded(
            TrinaGridOnLoadedEvent(stateManager: stateManager),
          );

          verify(stateManager.setKeepFocus(true, notify: false)).called(1);

          verify(
            stateManager.setCurrentCell(
              rows.first.cells[FilterHelper.filterFieldValue],
              0,
              notify: false,
            ),
          ).called(1);

          verify(stateManager.setEditing(true, notify: false)).called(1);

          verify(stateManager.notifyListeners()).called(1);
        },
      );
    });

    test('onChanged', () {
      final columns = ColumnHelper.textColumn('column');

      final rows = RowHelper.count(1, columns);

      var mock = MockMethods();

      var filterPopupState = FilterPopupState(
        context: MockBuildContext(),
        configuration: const TrinaGridConfiguration(),
        handleAddNewFilter: (_) {},
        handleApplyFilter: mock.oneParamReturnVoid,
        columns: columns,
        filterRows: [],
        focusFirstFilterValue: true,
      );

      filterPopupState.onChanged(
        TrinaGridOnChangedEvent(
          columnIdx: 0,
          column: columns.first,
          rowIdx: 0,
          row: rows.first,
        ),
      );

      verify(mock.oneParamReturnVoid(any)).called(1);
    });

    test('onSelected', () {
      final List<TrinaRow> filterRows = [];

      var filterPopupState = FilterPopupState(
        context: MockBuildContext(),
        configuration: const TrinaGridConfiguration(),
        handleAddNewFilter: (_) {},
        handleApplyFilter: (_) {},
        columns: ColumnHelper.textColumn('column'),
        filterRows: filterRows,
        focusFirstFilterValue: false,
      );

      var stateManager = MockTrinaGridStateManager();

      when(stateManager.rows).thenReturn(filterRows);

      filterPopupState.onLoaded(
        TrinaGridOnLoadedEvent(stateManager: stateManager),
      );

      filterPopupState.onSelected(const TrinaGridOnSelectedEvent());

      verify(
        stateManager.removeListener(filterPopupState.stateListener),
      ).called(1);
    });

    group('stateListener', () {
      test(
        'When filterRows is not changed, handleApplyFilter should not be called.',
        () {
          var mock = MockMethods();

          var columns = ColumnHelper.textColumn('column');

          var filterRows = RowHelper.count(1, columns);

          var filterPopupState = FilterPopupState(
            context: MockBuildContext(),
            configuration: const TrinaGridConfiguration(),
            handleAddNewFilter: (_) {},
            handleApplyFilter: mock.oneParamReturnVoid,
            columns: columns,
            filterRows: filterRows,
            focusFirstFilterValue: false,
          );

          var stateManager = MockTrinaGridStateManager();

          when(stateManager.rows).thenReturn([...filterRows]);

          filterPopupState.onLoaded(
            TrinaGridOnLoadedEvent(stateManager: stateManager),
          );

          filterPopupState.stateListener();

          verifyNever(mock.oneParamReturnVoid(stateManager));
        },
      );

      test(
        'When filterRows is changed, handleApplyFilter should be called.',
        () {
          var mock = MockMethods();

          var columns = ColumnHelper.textColumn('column');

          var filterPopupState = FilterPopupState(
            context: MockBuildContext(),
            configuration: const TrinaGridConfiguration(),
            handleAddNewFilter: (_) {},
            handleApplyFilter: mock.oneParamReturnVoid,
            columns: columns,
            filterRows: [],
            focusFirstFilterValue: false,
          );

          var stateManager = MockTrinaGridStateManager();

          when(stateManager.rows).thenReturn(RowHelper.count(1, columns));

          filterPopupState.onLoaded(
            TrinaGridOnLoadedEvent(stateManager: stateManager),
          );

          filterPopupState.stateListener();

          verify(mock.oneParamReturnVoid(stateManager)).called(1);
        },
      );
    });

    group('makeColumns', () {
      var columns = ColumnHelper.textColumn('column', count: 3);

      var configuration = const TrinaGridConfiguration();

      var filterPopupState = FilterPopupState(
        context: MockBuildContext(),
        configuration: configuration,
        handleAddNewFilter: (_) {},
        handleApplyFilter: (_) {},
        columns: columns,
        filterRows: [],
        focusFirstFilterValue: false,
      );

      var filterColumns = filterPopupState.makeColumns();

      test('3 columns should be generated.', () {
        expect(filterColumns.length, 3);
        expect(filterColumns[0].field, FilterHelper.filterFieldColumn);
        expect(filterColumns[1].field, FilterHelper.filterFieldType);
        expect(filterColumns[2].field, FilterHelper.filterFieldValue);
      });

      test('The first column of filterColumns should be select type.', () {
        var filterColumn = filterColumns[0];

        expect(filterColumn.type, isA<TrinaColumnTypeSelect>());

        var columnType = filterColumn.type as TrinaColumnTypeSelect;

        // When the filter field is added, +1 (FilterHelper.filterFieldAllColumns)
        expect(columnType.items.length, columns.length + 1);

        expect(columnType.items[0], FilterHelper.filterFieldAllColumns);
        expect(columnType.items[1], columns[0].field);
        expect(columnType.items[2], columns[1].field);
        expect(columnType.items[3], columns[2].field);

        // formatter (The column's field is used as a value and returned as a title in the formatter.)
        expect(
          filterColumn.formatter!(FilterHelper.filterFieldAllColumns),
          configuration.localeText.filterAllColumns,
        );

        for (var i = 0; i < columns.length; i += 1) {
          expect(filterColumn.formatter!(columns[i].field), columns[i].title);
        }
      });

      test('The second column of filterColumns should be select type.', () {
        var filterColumn = filterColumns[1];

        expect(filterColumn.type, isA<TrinaColumnTypeSelect>());

        var columnType = filterColumn.type as TrinaColumnTypeSelect;

        // configuration's filter count should be created. (default 9)
        expect(configuration.columnFilter.filters.length, 9);
        expect(
          columnType.items.length,
          configuration.columnFilter.filters.length,
        );

        // formatter (filter value is used formatter to return title.)
        for (var i = 0; i < configuration.columnFilter.filters.length; i += 1) {
          expect(
            filterColumn.formatter!(configuration.columnFilter.filters[i]),
            configuration.columnFilter.filters[i].title,
          );
        }
      });

      test('The third column of filterColumns should be text type.', () {
        var filterColumn = filterColumns[2];

        expect(filterColumn.type, isA<TrinaColumnTypeText>());
      });
    });
  });

  group('TrinaGridFilterPopupHeader', () {
    testWidgets(
      'When the add button is tapped, the handleAddNewFilter callback should be called.',
      (tester) async {
        final stateManager = MockTrinaGridStateManager();
        const configuration = TrinaGridConfiguration();
        final mockListener = MockMethods();

        await tester.pumpWidget(
          MaterialApp(
            home: Material(
              child: TrinaGridFilterPopupHeader(
                stateManager: stateManager,
                configuration: configuration,
                handleAddNewFilter: mockListener.oneParamReturnVoid,
              ),
            ),
          ),
        );

        final button = find.byType(IconButton).first;

        await tester.tap(button);

        expect(
          ((button.evaluate().first.widget as IconButton).icon as Icon).icon,
          Icons.add,
        );

        verify(mockListener.oneParamReturnVoid(any)).called(1);
      },
    );

    testWidgets(
        'When selectedRows is empty, '
        'tapping the remove icon should call removeCurrentRow.', (
      tester,
    ) async {
      final stateManager = MockTrinaGridStateManager();
      const configuration = TrinaGridConfiguration();
      final mockListener = MockMethods();

      when(stateManager.selectedRows).thenReturn([]);

      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: TrinaGridFilterPopupHeader(
              stateManager: stateManager,
              configuration: configuration,
              handleAddNewFilter: mockListener.oneParamReturnVoid,
            ),
          ),
        ),
      );

      final button = find.byType(IconButton).at(1);

      await tester.tap(button);

      expect(
        ((button.evaluate().first.widget as IconButton).icon as Icon).icon,
        Icons.remove,
      );

      verify(stateManager.removeCurrentRow()).called(1);
    });

    testWidgets(
        'When selectedRows is not empty, '
        'tapping the remove icon should call removeRows.', (tester) async {
      final stateManager = MockTrinaGridStateManager();
      const configuration = TrinaGridConfiguration();
      final mockListener = MockMethods();

      final dummyRow = TrinaRow(cells: {'test': TrinaCell(value: '')});

      when(stateManager.selectedRows).thenReturn([dummyRow]);

      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: TrinaGridFilterPopupHeader(
              stateManager: stateManager,
              configuration: configuration,
              handleAddNewFilter: mockListener.oneParamReturnVoid,
            ),
          ),
        ),
      );

      final button = find.byType(IconButton).at(1);

      await tester.tap(button);

      expect(
        ((button.evaluate().first.widget as IconButton).icon as Icon).icon,
        Icons.remove,
      );

      verify(stateManager.removeRows([dummyRow])).called(1);
    });
  });
}
