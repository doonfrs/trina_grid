import 'package:flutter/material.dart';
import 'package:trina_grid/trina_grid.dart';

abstract class IFilteringRowState {
  List<TrinaRow> get filterRows;

  bool get hasFilter;

  void setFilter(FilteredListFilter<TrinaRow>? filter, {bool notify = true});

  void setFilterWithFilterRows(List<TrinaRow> rows, {bool notify = true});

  void setFilterRows(List<TrinaRow> rows);

  List<TrinaRow> filterRowsByField(String columnField);

  /// Check if the column is in a state with filtering applied.
  bool isFilteredColumn(TrinaColumn column);

  void removeColumnsInFilterRows(
    List<TrinaColumn> columns, {
    bool notify = true,
  });

  void showFilterPopup(BuildContext context, {TrinaColumn? calledColumn});

  /// Set or update a column filter value programmatically
  void setColumnFilter({
    required String columnField,
    required TrinaFilterType filterType,
    required dynamic filterValue,
    bool notify = true,
  });

  /// Remove a specific column filter
  void removeColumnFilter(String columnField, {bool notify = true});

  /// Clear all column filters
  void clearAllColumnFilters({bool notify = true});

  /// Get the current filter value for a specific column
  /// Returns null if no filter is applied to the column
  dynamic getColumnFilterValue(String columnField);

  /// Get the current filter type for a specific column
  /// Returns null if no filter is applied to the column
  TrinaFilterType? getColumnFilterType(String columnField);
}

class _State {
  List<TrinaRow> _filterRows = [];
}

mixin FilteringRowState implements ITrinaGridState {
  final _State _state = _State();

  @override
  List<TrinaRow> get filterRows => _state._filterRows;

  @override
  bool get hasFilter =>
      refRows.hasFilter || (filterOnlyEvent && filterRows.isNotEmpty);

  @override
  void setFilter(FilteredListFilter<TrinaRow>? filter, {bool notify = true}) {
    if (filter == null) {
      setFilterRows([]);
    }

    if (filterOnlyEvent) {
      eventManager!.addEvent(
        TrinaGridSetColumnFilterEvent(filterRows: filterRows),
      );
      return;
    }

    for (final row in iterateAllRowAndGroup) {
      row.setState(TrinaRowState.none);
    }

    var savedFilter = filter;

    if (filter != null) {
      savedFilter = (TrinaRow row) {
        return !row.state.isNone || filter(row);
      };
    }

    if (enabledRowGroups) {
      setRowGroupFilter(savedFilter);
    } else {
      refRows.setFilter(savedFilter);
    }

    resetCurrentState(notify: false);

    notifyListeners(notify, setFilter.hashCode);
  }

  @override
  void setFilterWithFilterRows(List<TrinaRow> rows, {bool notify = true}) {
    setFilterRows(rows);

    var enabledFilterColumnFields = refColumns
        .where((element) => element.enableFilterMenuItem)
        .toList();

    setFilter(
      FilterHelper.convertRowsToFilter(filterRows, enabledFilterColumnFields),
      notify: isPaginated ? false : notify,
    );

    if (isPaginated) {
      resetPage(notify: notify);
    }
  }

  @override
  void setFilterRows(List<TrinaRow> rows) {
    _state._filterRows = rows.where((element) {
      final value = element.cells[FilterHelper.filterFieldValue]!.value;
      return value != null && value.toString().isNotEmpty;
    }).toList();
  }

  @override
  List<TrinaRow> filterRowsByField(String columnField) {
    return filterRows
        .where(
          (element) =>
              element.cells[FilterHelper.filterFieldColumn]!.value ==
              columnField,
        )
        .toList();
  }

  @override
  bool isFilteredColumn(TrinaColumn column) {
    return hasFilter && FilterHelper.isFilteredColumn(column, filterRows);
  }

  @override
  void removeColumnsInFilterRows(
    List<TrinaColumn> columns, {
    bool notify = true,
  }) {
    if (filterRows.isEmpty) {
      return;
    }

    final Set<String> columnFields = Set.from(columns.map((e) => e.field));

    filterRows.removeWhere((filterRow) {
      return columnFields.contains(
        filterRow.cells[FilterHelper.filterFieldColumn]!.value,
      );
    });

    setFilterWithFilterRows(filterRows, notify: notify);
  }

  @override
  void showFilterPopup(
    BuildContext context, {
    TrinaColumn? calledColumn,
    void Function()? onClosed,
  }) {
    var shouldProvideDefaultFilterRow =
        filterRows.isEmpty && calledColumn != null;

    var rows = shouldProvideDefaultFilterRow
        ? [
            FilterHelper.createFilterRow(
              columnField: calledColumn.enableFilterMenuItem
                  ? calledColumn.field
                  : FilterHelper.filterFieldAllColumns,
              filterType: calledColumn.defaultFilter,
            ),
          ]
        : filterRows;

    FilterHelper.filterPopup(
      FilterPopupState(
        context: context,
        configuration: configuration.copyWith(
          style: configuration.style.copyWith(
            gridBorderRadius: configuration.style.gridPopupBorderRadius,
            enableRowColorAnimation: false,
            oddRowColor: const TrinaOptional(null),
            evenRowColor: const TrinaOptional(null),
          ),
        ),
        handleAddNewFilter: (filterState) {
          filterState!.appendRows([FilterHelper.createFilterRow()]);
        },
        handleApplyFilter: (filterState) {
          setFilterWithFilterRows(filterState!.rows);
        },
        columns: columns,
        filterRows: rows,
        focusFirstFilterValue: shouldProvideDefaultFilterRow,
        onClosed: onClosed,
      ),
    );
  }

  @override
  void setColumnFilter({
    required String columnField,
    required TrinaFilterType filterType,
    required dynamic filterValue,
    bool notify = true,
  }) {
    List<TrinaRow> updatedFilterRows = List.from(filterRows);

    // Find existing filter row for this column
    int existingIndex = updatedFilterRows.indexWhere(
      (row) => row.cells[FilterHelper.filterFieldColumn]?.value == columnField,
    );

    if (existingIndex != -1) {
      // Update existing filter
      updatedFilterRows[existingIndex]
              .cells[FilterHelper.filterFieldValue]!
              .value =
          filterValue;
      updatedFilterRows[existingIndex]
              .cells[FilterHelper.filterFieldType]!
              .value =
          filterType;
    } else {
      // Add new filter
      updatedFilterRows.add(
        FilterHelper.createFilterRow(
          columnField: columnField,
          filterType: filterType,
          filterValue: filterValue,
        ),
      );
    }

    setFilterWithFilterRows(updatedFilterRows, notify: notify);
  }

  @override
  void removeColumnFilter(String columnField, {bool notify = true}) {
    List<TrinaRow> updatedFilterRows = filterRows
        .where(
          (row) =>
              row.cells[FilterHelper.filterFieldColumn]?.value != columnField,
        )
        .toList();

    setFilterWithFilterRows(updatedFilterRows, notify: notify);
  }

  @override
  void clearAllColumnFilters({bool notify = true}) {
    setFilterWithFilterRows([], notify: notify);
  }

  @override
  dynamic getColumnFilterValue(String columnField) {
    final filterRow = filterRows.firstWhere(
      (row) => row.cells[FilterHelper.filterFieldColumn]?.value == columnField,
      orElse: () => TrinaRow(cells: {}),
    );

    if (filterRow.cells.isEmpty) {
      return null;
    }

    return filterRow.cells[FilterHelper.filterFieldValue]?.value;
  }

  @override
  TrinaFilterType? getColumnFilterType(String columnField) {
    final filterRow = filterRows.firstWhere(
      (row) => row.cells[FilterHelper.filterFieldColumn]?.value == columnField,
      orElse: () => TrinaRow(cells: {}),
    );

    if (filterRow.cells.isEmpty) {
      return null;
    }

    return filterRow.cells[FilterHelper.filterFieldType]?.value
        as TrinaFilterType?;
  }
}
