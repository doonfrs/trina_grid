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

  void showFilterPopup(
    BuildContext context, {
    TrinaColumn? calledColumn,
  });
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

    var enabledFilterColumnFields =
        refColumns.where((element) => element.enableFilterMenuItem).toList();

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
    _state._filterRows = rows
        .where(
          (element) => element.cells[FilterHelper.filterFieldValue]!.value
              .toString()
              .isNotEmpty,
        )
        .toList();
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

    filterRows.removeWhere(
      (filterRow) {
        return columnFields.contains(
          filterRow.cells[FilterHelper.filterFieldColumn]!.value,
        );
      },
    );

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
          // use cell selection with CTRL instead of single tap selection
          // to not close the filter popup when tapping on a cell
          selectingMode: TrinaGridSelectingMode.cellWithCtrl,
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
}
