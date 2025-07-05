import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:trina_grid/trina_grid.dart';

typedef SetFilterPopupHandler = void Function(
    TrinaGridStateManager? stateManager);

class FilterHelper {
  /// A value to identify all column searches when searching filters.
  static const filterFieldAllColumns = 'trinaFilterAllColumns';

  /// The field name of the column that includes the field values of the column
  /// when searching for a filter.
  static const filterFieldColumn = 'column';

  /// The field name of the column including the filter type
  /// when searching for a filter.
  static const filterFieldType = 'type';

  /// The field name of the column containing the value to be searched
  /// when searching for a filter.
  static const filterFieldValue = 'value';

  static const List<TrinaFilterType> defaultFilters = [
    TrinaFilterTypeContains(),
    TrinaFilterTypeEquals(),
    TrinaFilterTypeStartsWith(),
    TrinaFilterTypeEndsWith(),
    TrinaFilterTypeGreaterThan(),
    TrinaFilterTypeGreaterThanOrEqualTo(),
    TrinaFilterTypeLessThan(),
    TrinaFilterTypeLessThanOrEqualTo(),
    TrinaFilterTypeRegex(),
  ];

  /// Create a row to contain filter information.
  static TrinaRow createFilterRow({
    String? columnField,
    TrinaFilterType? filterType,
    String? filterValue,
  }) {
    return TrinaRow(
      cells: {
        filterFieldColumn: TrinaCell(
          value: columnField ?? filterFieldAllColumns,
        ),
        filterFieldType: TrinaCell(
          value: filterType ?? const TrinaFilterTypeContains(),
        ),
        filterFieldValue: TrinaCell(value: filterValue ?? ''),
      },
    );
  }

  /// Converts rows containing filter information into comparison functions.
  static FilteredListFilter<TrinaRow?>? convertRowsToFilter(
    List<TrinaRow?> rows,
    List<TrinaColumn>? enabledFilterColumns,
  ) {
    if (rows.isEmpty) {
      return null;
    }

    return (TrinaRow? row) {
      bool? flag;

      for (var e in rows) {
        final filterType = e!.cells[filterFieldType]!.value as TrinaFilterType?;

        if (e.cells[filterFieldColumn]!.value == filterFieldAllColumns) {
          bool? flagAllColumns;

          row!.cells.forEach((key, value) {
            var foundColumn = enabledFilterColumns!.firstWhereOrNull(
              (element) => element.field == key,
            );

            if (foundColumn != null) {
              flagAllColumns = compareOr(
                flagAllColumns,
                compareByFilterType(
                  filterType: filterType!,
                  base: value.value.toString(),
                  search: e.cells[filterFieldValue]!.value.toString(),
                  column: foundColumn,
                ),
              );
            }
          });

          flag = compareAnd(flag, flagAllColumns);
        } else {
          var foundColumn = enabledFilterColumns!.firstWhereOrNull(
            (element) => element.field == e.cells[filterFieldColumn]!.value,
          );

          if (foundColumn != null) {
            flag = compareAnd(
              flag,
              compareByFilterType(
                filterType: filterType!,
                base: row!.cells[e.cells[filterFieldColumn]!.value]!.value
                    .toString(),
                search: e.cells[filterFieldValue]!.value.toString(),
                column: foundColumn,
              ),
            );
          }
        }
      }

      return flag == true;
    };
  }

  /// Converts List&lt;TrinaRow&gt; type with filtering information to Map type.
  ///
  /// [allField] determines the key value of the filter applied to the entire scope.
  /// Default is all.
  ///
  /// ```dart
  /// // The return value below is an example of the condition
  /// in which two filtering is applied with the Contains type condition to all ranges.
  /// {all: [{Contains: abc}, {Contains: 123}]}
  ///
  /// // If filtering is applied to a column, the key is the field name of the column.
  /// {column1: [{Contains: abc}]}
  /// ```
  static Map<String, List<Map<String, String>>> convertRowsToMap(
    List<TrinaRow> filterRows, {
    String allField = 'all',
  }) {
    final map = <String, List<Map<String, String>>>{};

    if (filterRows.isEmpty) return map;

    for (final row in filterRows) {
      String columnField = row.cells[FilterHelper.filterFieldColumn]!.value;

      if (columnField == FilterHelper.filterFieldAllColumns) {
        columnField = allField;
      }

      final String filterType =
          (row.cells[FilterHelper.filterFieldType]!.value as TrinaFilterType)
              .title;

      final filterValue = row.cells[FilterHelper.filterFieldValue]!.value;

      if (map.containsKey(columnField)) {
        map[columnField]!.add({filterType: filterValue});
      } else {
        map[columnField] = [
          {filterType: filterValue},
        ];
      }
    }

    return map;
  }

  /// Whether [column] is included in [filteredRows].
  ///
  /// That is, check if it is a filtered column.
  /// If there is a search condition for all columns in [filteredRows],
  /// it is regarded as a filtering column.
  static bool isFilteredColumn(
    TrinaColumn column,
    List<TrinaRow?>? filteredRows,
  ) {
    if (filteredRows == null || filteredRows.isEmpty) {
      return false;
    }

    for (var row in filteredRows) {
      if (row!.cells[filterFieldColumn]!.value == filterFieldAllColumns ||
          row.cells[filterFieldColumn]!.value == column.field) {
        return true;
      }
    }

    return false;
  }

  /// Opens a pop-up for filtering.
  static void filterPopup(FilterPopupState popupState) {
    TrinaGridPopup(
      width: popupState.width,
      height: popupState.height,
      context: popupState.context,
      createHeader: popupState.createHeader,
      columns: popupState.makeColumns(),
      rows: popupState.filterRows,
      configuration: popupState.configuration,
      onLoaded: popupState.onLoaded,
      onChanged: popupState.onChanged,
      onSelected: popupState.onSelected,
      mode: TrinaGridMode.popup,
    );
  }

  /// 'or' comparison with null values
  static bool compareOr(bool? a, bool b) {
    return a != true ? a == true || b : true;
  }

  /// 'and' comparison with null values
  static bool? compareAnd(bool? a, bool? b) {
    return a != false ? b : false;
  }

  /// Compare [base] and [search] with [TrinaFilterType.compare].
  static bool compareByFilterType({
    required TrinaFilterType filterType,
    required String base,
    required String search,
    required TrinaColumn column,
  }) {
    bool compare = false;

    if (column.type is TrinaColumnTypeWithNumberFormat) {
      final numberColumn = column.type as TrinaColumnTypeWithNumberFormat;

      compare = compare ||
          filterType.compare(
            base: numberColumn.applyFormat(base),
            search: search,
            column: column,
          );

      search = search.replaceFirst(
        numberColumn.numberFormat.symbols.DECIMAL_SEP,
        '.',
      );
    }

    return compare ||
        filterType.compare(base: base, search: search, column: column);
  }

  /// Whether [search] is contains in [base].
  static bool compareContains({
    required String? base,
    required String? search,
    required TrinaColumn column,
  }) {
    return _compareWithRegExp(RegExp.escape(search!), base!);
  }

  /// Whether [search] is equals to [base].
  static bool compareEquals({
    required String? base,
    required String? search,
    required TrinaColumn column,
  }) {
    return _compareWithRegExp(
      // ignore: prefer_interpolation_to_compose_strings
      r'^' + RegExp.escape(search!) + r'$',
      base!,
    );
  }

  /// Whether [base] starts with [search].
  static bool compareStartsWith({
    required String? base,
    required String? search,
    required TrinaColumn column,
  }) {
    return _compareWithRegExp(
      // ignore: prefer_interpolation_to_compose_strings
      r'^' + RegExp.escape(search!),
      base!,
    );
  }

  /// Whether [base] ends with [search].
  static bool compareEndsWith({
    required String? base,
    required String? search,
    required TrinaColumn column,
  }) {
    return _compareWithRegExp(
      // ignore: prefer_interpolation_to_compose_strings
      RegExp.escape(search!) + r'$',
      base!,
    );
  }

  static bool compareGreaterThan({
    required String? base,
    required String? search,
    required TrinaColumn column,
  }) {
    return column.type.compare(base, search) == 1;
  }

  static bool compareGreaterThanOrEqualTo({
    required String? base,
    required String? search,
    required TrinaColumn column,
  }) {
    return column.type.compare(base, search) > -1;
  }

  static bool compareLessThan({
    required String? base,
    required String? search,
    required TrinaColumn column,
  }) {
    return column.type.compare(base, search) == -1;
  }

  static bool compareLessThanOrEqualTo({
    required String? base,
    required String? search,
    required TrinaColumn column,
  }) {
    return column.type.compare(base, search) < 1;
  }

  static bool _compareWithRegExp(
    String pattern,
    String value, {
    bool caseSensitive = false,
  }) {
    return RegExp(pattern, caseSensitive: caseSensitive).hasMatch(value);
  }

  /// Compare [base] with raw regex [search].
  static bool compareRegex({
    required String? base,
    required String? search,
    required TrinaColumn column,
  }) {
    if (base == null || search == null || search.isEmpty) {
      return false;
    }

    try {
      return RegExp(search).hasMatch(base);
    } catch (e) {
      // Return false if the regex pattern is invalid
      return false;
    }
  }

  static bool compareMultiItems({
    required String? base,
    required String? search,
    required TrinaColumn column,
    bool caseSensitive = true,
  }) {
    if (base == null || search == null) return false;
    final items = search
        .split(RegExp(r'[\n,]'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    if (caseSensitive) {
      return items.contains(base.trim());
    } else {
      final baseLower = base.trim().toLowerCase();
      return items.any((item) => item.toLowerCase() == baseLower);
    }
  }
}

/// State for calling filter pop
class FilterPopupState {
  /// [BuildContext] for calling [showDialog]
  final BuildContext context;

  /// [TrinaGridConfiguration] to call [TrinaGridPopup]
  final TrinaGridConfiguration configuration;

  /// A callback function called when adding a new filter.
  final SetFilterPopupHandler handleAddNewFilter;

  /// A callback function called when filter information changes.
  final SetFilterPopupHandler handleApplyFilter;

  /// List of columns to be filtered.
  final List<TrinaColumn> columns;

  /// List with filtering condition information
  final List<TrinaRow> filterRows;

  /// The filter popup opens and focuses on the filter value in the first row.
  final bool focusFirstFilterValue;

  /// Width of filter popup
  final double width;

  /// Height of filter popup
  final double height;

  final void Function()? onClosed;

  FilterPopupState({
    required this.context,
    required this.configuration,
    required this.handleAddNewFilter,
    required this.handleApplyFilter,
    required this.columns,
    required this.filterRows,
    required this.focusFirstFilterValue,
    this.width = 600,
    this.height = 450,
    this.onClosed,
  })  : assert(columns.isNotEmpty),
        _previousFilterRows = [...filterRows];

  TrinaGridStateManager? _stateManager;
  List<TrinaRow?> _previousFilterRows;

  void onLoaded(TrinaGridOnLoadedEvent e) {
    _stateManager = e.stateManager;

    // use cell selection with CTRL instead of single tap selection
    // to not close the filter popup when tapping on a cell
    _stateManager!
        .setSelectingMode(TrinaGridSelectingMode.cellWithCtrl, notify: false);

    if (_stateManager!.rows.isNotEmpty) {
      _stateManager!.setKeepFocus(true, notify: false);

      _stateManager!.setCurrentCell(
        _stateManager!.rows.first.cells[FilterHelper.filterFieldValue],
        0,
        notify: false,
      );

      if (focusFirstFilterValue) {
        _stateManager!.setEditing(true, notify: false);
      }
    }

    _stateManager!.notifyListeners();

    _stateManager!.addListener(stateListener);
  }

  void onChanged(TrinaGridOnChangedEvent e) {
    applyFilter();
  }

  void onSelected(TrinaGridOnSelectedEvent e) {
    _stateManager!.removeListener(stateListener);

    if (onClosed != null) {
      onClosed!();
    }
  }

  void stateListener() {
    if (listEquals(_previousFilterRows, _stateManager!.rows) == false) {
      _previousFilterRows = [..._stateManager!.rows];
      applyFilter();
    }
  }

  void applyFilter() {
    handleApplyFilter(_stateManager);
  }

  TrinaGridFilterPopupHeader createHeader(TrinaGridStateManager stateManager) {
    return TrinaGridFilterPopupHeader(
      stateManager: stateManager,
      configuration: configuration,
      handleAddNewFilter: handleAddNewFilter,
    );
  }

  List<TrinaColumn> makeColumns() {
    return _makeFilterColumns(configuration: configuration, columns: columns);
  }

  Map<String, String> _makeFilterColumnMap({
    required TrinaGridConfiguration configuration,
    required List<TrinaColumn> columns,
  }) {
    Map<String, String> columnMap = {
      FilterHelper.filterFieldAllColumns:
          configuration.localeText.filterAllColumns,
    };

    columns.where((element) => element.enableFilterMenuItem).forEach((element) {
      columnMap[element.field] = element.titleWithGroup;
    });

    return columnMap;
  }

  List<TrinaColumn> _makeFilterColumns({
    required TrinaGridConfiguration configuration,
    required List<TrinaColumn> columns,
  }) {
    Map<String, String> columnMap = _makeFilterColumnMap(
      configuration: configuration,
      columns: columns,
    );

    return [
      TrinaColumn(
        title: configuration.localeText.filterColumn,
        field: FilterHelper.filterFieldColumn,
        type: TrinaColumnType.select(columnMap.keys.toList(growable: false)),
        enableFilterMenuItem: false,
        applyFormatterInEditing: true,
        formatter: (dynamic value) {
          return columnMap[value] ?? '';
        },
      ),
      TrinaColumn(
        title: configuration.localeText.filterType,
        field: FilterHelper.filterFieldType,
        type: TrinaColumnType.select(configuration.columnFilter.filters),
        enableFilterMenuItem: false,
        applyFormatterInEditing: true,
        formatter: (dynamic value) {
          return (value?.title ?? '').toString();
        },
      ),
      TrinaColumn(
        title: configuration.localeText.filterValue,
        field: FilterHelper.filterFieldValue,
        type: TrinaColumnType.text(),
        enableFilterMenuItem: false,
      ),
    ];
  }
}

class TrinaGridFilterPopupHeader extends StatelessWidget {
  final TrinaGridStateManager? stateManager;
  final TrinaGridConfiguration? configuration;
  final SetFilterPopupHandler? handleAddNewFilter;

  const TrinaGridFilterPopupHeader({
    super.key,
    this.stateManager,
    this.configuration,
    this.handleAddNewFilter,
  });

  void handleAddButton() {
    handleAddNewFilter!(stateManager);
  }

  void handleRemoveButton() {
    if (stateManager!.selectedRows.isEmpty) {
      stateManager!.removeCurrentRow();
    } else {
      stateManager!.removeRows(stateManager!.selectedRows);
    }
  }

  void handleClearButton() {
    if (stateManager!.rows.isEmpty) {
      Navigator.of(stateManager!.gridFocusNode.context!).pop();
    } else {
      stateManager!.removeRows(stateManager!.rows);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.add),
            color: configuration!.style.iconColor,
            iconSize: configuration!.style.iconSize,
            onPressed: handleAddButton,
          ),
          IconButton(
            icon: const Icon(Icons.remove),
            color: configuration!.style.iconColor,
            iconSize: configuration!.style.iconSize,
            onPressed: handleRemoveButton,
          ),
          IconButton(
            icon: const Icon(Icons.clear_sharp),
            color: Colors.red,
            iconSize: configuration!.style.iconSize,
            onPressed: handleClearButton,
          ),
        ],
      ),
    );
  }
}

/// [base] is the cell values of the column on which the search is based.
/// [search] is the value entered by the user to search.
typedef TrinaCompareFunction = bool Function({
  required String? base,
  required String? search,
  required TrinaColumn column,
});

abstract class TrinaFilterType {
  String get title => throw UnimplementedError();

  TrinaCompareFunction get compare => throw UnimplementedError();
}

class TrinaFilterTypeContains implements TrinaFilterType {
  static String name = 'Contains';

  @override
  String get title => TrinaFilterTypeContains.name;

  @override
  TrinaCompareFunction get compare => FilterHelper.compareContains;

  const TrinaFilterTypeContains();
}

class TrinaFilterTypeEquals implements TrinaFilterType {
  static String name = 'Equals';

  @override
  String get title => TrinaFilterTypeEquals.name;

  @override
  TrinaCompareFunction get compare => FilterHelper.compareEquals;

  const TrinaFilterTypeEquals();
}

class TrinaFilterTypeStartsWith implements TrinaFilterType {
  static String name = 'Starts with';

  @override
  String get title => TrinaFilterTypeStartsWith.name;

  @override
  TrinaCompareFunction get compare => FilterHelper.compareStartsWith;

  const TrinaFilterTypeStartsWith();
}

class TrinaFilterTypeEndsWith implements TrinaFilterType {
  static String name = 'Ends with';

  @override
  String get title => TrinaFilterTypeEndsWith.name;

  @override
  TrinaCompareFunction get compare => FilterHelper.compareEndsWith;

  const TrinaFilterTypeEndsWith();
}

class TrinaFilterTypeGreaterThan implements TrinaFilterType {
  static String name = 'Greater than';

  @override
  String get title => TrinaFilterTypeGreaterThan.name;

  @override
  TrinaCompareFunction get compare => FilterHelper.compareGreaterThan;

  const TrinaFilterTypeGreaterThan();
}

class TrinaFilterTypeGreaterThanOrEqualTo implements TrinaFilterType {
  static String name = 'Greater than or equal to';

  @override
  String get title => TrinaFilterTypeGreaterThanOrEqualTo.name;

  @override
  TrinaCompareFunction get compare => FilterHelper.compareGreaterThanOrEqualTo;

  const TrinaFilterTypeGreaterThanOrEqualTo();
}

class TrinaFilterTypeLessThan implements TrinaFilterType {
  static String name = 'Less than';

  @override
  String get title => TrinaFilterTypeLessThan.name;

  @override
  TrinaCompareFunction get compare => FilterHelper.compareLessThan;

  const TrinaFilterTypeLessThan();
}

class TrinaFilterTypeLessThanOrEqualTo implements TrinaFilterType {
  static String name = 'Less than or equal to';

  @override
  String get title => TrinaFilterTypeLessThanOrEqualTo.name;

  @override
  TrinaCompareFunction get compare => FilterHelper.compareLessThanOrEqualTo;

  const TrinaFilterTypeLessThanOrEqualTo();
}

class TrinaFilterTypeRegex implements TrinaFilterType {
  static String name = 'Regex';

  @override
  String get title => TrinaFilterTypeRegex.name;

  @override
  TrinaCompareFunction get compare => FilterHelper.compareRegex;

  const TrinaFilterTypeRegex();
}

class TrinaFilterTypeMultiItems implements TrinaFilterType {
  static String name = 'MultiItems';

  final bool caseSensitive;

  const TrinaFilterTypeMultiItems({this.caseSensitive = true});

  @override
  String get title => TrinaFilterTypeMultiItems.name;

  @override
  TrinaCompareFunction get compare => ({
        required String? base,
        required String? search,
        required TrinaColumn column,
      }) =>
          FilterHelper.compareMultiItems(
            base: base,
            search: search,
            column: column,
            caseSensitive: caseSensitive,
          );
}
