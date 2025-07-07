import 'package:flutter/cupertino.dart';
import 'package:trina_grid/trina_grid.dart';

import '../ui/ui.dart';

class TrinaChangeNotifierFilter<T> {
  TrinaChangeNotifierFilter(this._filter, [this._debugNotifierNames])
      : _type = T;

  static bool enabled = true;

  static bool debug = false;

  static bool get printDebug => enabled && debug;

  static List<String> debugWidgets = [];

  final Set<int> _filter;

  final Map<int, String>? _debugNotifierNames;

  final Type _type;

  bool any(TrinaNotifierEvent event) {
    printNotifierOnFilter(event);
    return _filter.isEmpty ? true : event.any(_filter);
  }

  void printNotifierOnFilter(TrinaNotifierEvent event) {
    if (_ignoreDebugPrint()) return;

    final length = event.notifier.length;

    debugPrint('[$_type] called on $length notifier.');
    for (int i = 0; i < length; i += 1) {
      final bool isLast = length - 1 == i;
      final prefix = isLast ? '\u2514' : '\u251c';
      final notifier = event.notifier.elementAt(i);
      debugPrint('  $prefix ${_debugNotifierNames?[notifier]}');
    }
  }

  void printNotifierOnChange(TrinaNotifierEvent event, bool rebuild) {
    if (_ignoreDebugPrint()) return;

    debugPrint('    ON_CHANGE - REBUILD : ${rebuild.toString().toUpperCase()}');
  }

  bool _ignoreDebugPrint() {
    return !enabled ||
        !debug ||
        (debugWidgets.isNotEmpty && !debugWidgets.contains(_type.toString()));
  }
}

abstract class TrinaChangeNotifierFilterResolver {
  const TrinaChangeNotifierFilterResolver();

  Set<int> resolve(TrinaGridStateManager stateManager, Type type);

  static Map<int, String> notifierNames(TrinaGridStateManager stateManager) {
    return {
      /// trina_change_notifier
      stateManager.notifyListeners.hashCode: 'notifyListeners',
      stateManager.notifyListenersOnPostFrame.hashCode:
          'notifyListenersOnPostFrame',

      /// cell_state
      stateManager.setCurrentCellPosition.hashCode: 'setCurrentCellPosition',
      stateManager.updateCurrentCellPosition.hashCode:
          'updateCurrentCellPosition',
      stateManager.clearCurrentCell.hashCode: 'clearCurrentCell',
      stateManager.setCurrentCell.hashCode: 'setCurrentCell',

      /// column_group_state
      stateManager.setShowColumnGroups.hashCode: 'setShowColumnGroups',
      stateManager.removeColumnsInColumnGroup.hashCode:
          'removeColumnsInColumnGroup',

      /// column_state
      stateManager.toggleFrozenColumn.hashCode: 'toggleFrozenColumn',
      stateManager.toggleSortColumn.hashCode: 'toggleSortColumn',
      stateManager.insertColumns.hashCode: 'insertColumns',
      stateManager.removeColumns.hashCode: 'removeColumns',
      stateManager.moveColumn.hashCode: 'moveColumn',
      stateManager.sortAscending.hashCode: 'sortAscending',
      stateManager.sortDescending.hashCode: 'sortDescending',
      stateManager.sortBySortIdx.hashCode: 'sortBySortIdx',
      stateManager.hideColumn.hashCode: 'hideColumn',

      /// dragging_row_state
      stateManager.setIsDraggingRow.hashCode: 'setIsDraggingRow',
      stateManager.setDragRows.hashCode: 'setDragRows',
      stateManager.setDragTargetRowIdx.hashCode: 'setDragTargetRowIdx',

      /// editing_state
      stateManager.setEditing.hashCode: 'setEditing',
      stateManager.setAutoEditing.hashCode: 'setAutoEditing',
      stateManager.pasteCellValue.hashCode: 'pasteCellValue',
      stateManager.changeCellValue.hashCode: 'changeCellValue',

      /// filtering_row_state
      stateManager.setFilter.hashCode: 'setFilter',

      /// focus_state
      stateManager.setKeepFocus.hashCode: 'setKeepFocus',

      /// grid_state
      stateManager.resetCurrentState.hashCode: 'resetCurrentState',

      /// layout_state
      stateManager.setShowColumnTitle.hashCode: 'setShowColumnTitle',
      stateManager.setShowColumnFooter.hashCode: 'setShowColumnFooter',
      stateManager.setShowColumnFilter.hashCode: 'setShowColumnFilter',
      stateManager.setShowLoading.hashCode: 'setShowLoading',
      stateManager.notifyChangedShowFrozenColumn.hashCode:
          'notifyChangedShowFrozenColumn',

      /// pagination_state
      stateManager.setPageSize.hashCode: 'setPageSize',
      stateManager.setPage.hashCode: 'setPage',

      /// row_group_state
      stateManager.setRowGroup.hashCode: 'setRowGroup',
      stateManager.toggleExpandedRowGroup.hashCode: 'toggleExpandedRowGroup',

      /// row_state
      stateManager.setRowChecked.hashCode: 'setRowChecked',
      stateManager.insertRows.hashCode: 'insertRows',
      stateManager.prependRows.hashCode: 'prependRows',
      stateManager.appendRows.hashCode: 'appendRows',
      stateManager.removeCurrentRow.hashCode: 'removeCurrentRow',
      stateManager.removeRows.hashCode: 'removeRows',
      stateManager.removeAllRows.hashCode: 'removeAllRows',
      stateManager.moveRowsByIndex.hashCode: 'moveRowsByIndex',
      stateManager.toggleAllRowChecked.hashCode: 'toggleAllRowChecked',

      /// selecting_state
      stateManager.setSelecting.hashCode: 'setSelecting',
      stateManager.setSelectingMode.hashCode: 'setSelectingMode',
      stateManager.setCurrentSelectingPosition.hashCode:
          'setCurrentSelectingPosition',
      stateManager.selectRowsInRange.hashCode: 'selectRowsInRange',
      stateManager.setSelectedRows.hashCode: 'setSelectedRows',
      stateManager.clearCurrentSelecting.hashCode: 'clearCurrentSelecting',
      stateManager.toggleRowSelection.hashCode: 'toggleRowSelection',
      stateManager.handleAfterSelectingRow.hashCode: 'handleAfterSelectingRow',

      /// hovering_state
      stateManager.setHoveredRowIdx.hashCode: 'setHoveredRowIdx',
      stateManager.isRowIdxHovered.hashCode: 'isRowIdxHovered',
    };
  }
}

class TrinaNotifierFilterResolverDefault
    implements TrinaChangeNotifierFilterResolver {
  const TrinaNotifierFilterResolverDefault();

  @override
  Set<int> resolve(TrinaGridStateManager stateManager, Type type) {
    switch (type) {
      case const (TrinaGrid):
        return defaultGridFilter(stateManager);
      case const (TrinaBodyColumns):
      case const (TrinaBodyColumnsFooter):
      case const (TrinaLeftFrozenColumns):
      case const (TrinaLeftFrozenColumnsFooter):
      case const (TrinaRightFrozenColumns):
      case const (TrinaRightFrozenColumnsFooter):
        return defaultColumnsFilter(stateManager);
      case const (TrinaBodyRows):
      case const (TrinaLeftFrozenRows):
      case const (TrinaRightFrozenRows):
        return defaultRowsFilter(stateManager);
      case const (TrinaNoRowsWidget):
        return {
          ...defaultRowsFilter(stateManager),
          stateManager.setShowLoading.hashCode,
        };
      case const (TrinaAggregateColumnFooter):
        return defaultAggregateColumnFooterFilter(stateManager);
      case const (CheckboxSelectionWidget):
        return defaultCheckboxFilter(stateManager);
      case const (CheckboxAllSelectionWidget):
        return defaultCheckboxAllFilter(stateManager);
    }

    return <int>{};
  }

  static Set<int> defaultGridFilter(TrinaGridStateManager stateManager) {
    return {
      stateManager.setShowColumnTitle.hashCode,
      stateManager.setShowColumnFilter.hashCode,
      stateManager.setShowColumnFooter.hashCode,
      stateManager.setShowColumnGroups.hashCode,
      stateManager.setShowLoading.hashCode,
      stateManager.toggleFrozenColumn.hashCode,
      stateManager.insertColumns.hashCode,
      stateManager.removeColumns.hashCode,
      stateManager.moveColumn.hashCode,
      stateManager.hideColumn.hashCode,
      stateManager.notifyChangedShowFrozenColumn.hashCode,
    };
  }

  static Set<int> defaultColumnsFilter(TrinaGridStateManager stateManager) {
    return {
      stateManager.toggleFrozenColumn.hashCode,
      stateManager.insertColumns.hashCode,
      stateManager.removeColumns.hashCode,
      stateManager.moveColumn.hashCode,
      stateManager.hideColumn.hashCode,
      stateManager.setShowColumnGroups.hashCode,
      stateManager.removeColumnsInColumnGroup.hashCode,
      stateManager.notifyChangedShowFrozenColumn.hashCode,
    };
  }

  static Set<int> defaultRowsFilter(TrinaGridStateManager stateManager) {
    return {
      stateManager.toggleFrozenColumn.hashCode,
      stateManager.insertColumns.hashCode,
      stateManager.removeColumns.hashCode,
      stateManager.moveColumn.hashCode,
      stateManager.hideColumn.hashCode,
      stateManager.toggleSortColumn.hashCode,
      stateManager.sortAscending.hashCode,
      stateManager.sortDescending.hashCode,
      stateManager.sortBySortIdx.hashCode,
      stateManager.setShowColumnGroups.hashCode,
      stateManager.setFilter.hashCode,
      stateManager.removeColumnsInColumnGroup.hashCode,
      stateManager.insertRows.hashCode,
      stateManager.prependRows.hashCode,
      stateManager.appendRows.hashCode,
      stateManager.removeCurrentRow.hashCode,
      stateManager.removeRows.hashCode,
      stateManager.removeAllRows.hashCode,
      stateManager.moveRowsByIndex.hashCode,
      stateManager.setRowGroup.hashCode,
      stateManager.toggleExpandedRowGroup.hashCode,
      stateManager.notifyChangedShowFrozenColumn.hashCode,
      stateManager.setPage.hashCode,
      stateManager.setPageSize.hashCode,
    };
  }

  static Set<int> defaultAggregateColumnFooterFilter(
      TrinaGridStateManager stateManager) {
    return {
      stateManager.toggleAllRowChecked.hashCode,
      stateManager.setRowChecked.hashCode,
      stateManager.setPage.hashCode,
      stateManager.setPageSize.hashCode,
      stateManager.setFilter.hashCode,
      stateManager.toggleSortColumn.hashCode,
      stateManager.sortAscending.hashCode,
      stateManager.sortDescending.hashCode,
      stateManager.sortBySortIdx.hashCode,
      stateManager.insertRows.hashCode,
      stateManager.prependRows.hashCode,
      stateManager.appendRows.hashCode,
      stateManager.removeCurrentRow.hashCode,
      stateManager.removeRows.hashCode,
      stateManager.removeAllRows.hashCode,
      stateManager.setRowGroup.hashCode,
      stateManager.toggleExpandedRowGroup.hashCode,
      stateManager.changeCellValue.hashCode,
      stateManager.pasteCellValue.hashCode,
    };
  }

  static Set<int> defaultCheckboxFilter(TrinaGridStateManager stateManager) {
    if (stateManager.enabledRowGroups) {
      return TrinaNotifierFilterResolverDefault.defaultCheckboxAllFilter(
        stateManager,
      );
    }

    return {
      stateManager.toggleAllRowChecked.hashCode,
      stateManager.setRowChecked.hashCode,
    };
  }

  static Set<int> defaultCheckboxAllFilter(TrinaGridStateManager stateManager) {
    return {
      stateManager.toggleAllRowChecked.hashCode,
      stateManager.setRowChecked.hashCode,
      stateManager.setPage.hashCode,
      stateManager.setPageSize.hashCode,
      stateManager.setFilter.hashCode,
      stateManager.toggleSortColumn.hashCode,
      stateManager.sortAscending.hashCode,
      stateManager.sortDescending.hashCode,
      stateManager.sortBySortIdx.hashCode,
      stateManager.insertRows.hashCode,
      stateManager.prependRows.hashCode,
      stateManager.appendRows.hashCode,
      stateManager.removeCurrentRow.hashCode,
      stateManager.removeRows.hashCode,
      stateManager.removeAllRows.hashCode,
      stateManager.setRowGroup.hashCode,
      stateManager.toggleExpandedRowGroup.hashCode,
    };
  }
}
