import 'dart:collection';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:trina_grid/trina_grid.dart';

import '../../ui/cells/trina_default_cell.dart';

abstract class IColumnState {
  /// Columns provided at grid start.
  List<TrinaColumn> get columns;

  FilteredList<TrinaColumn> get refColumns;

  /// Column index list.
  List<int> get columnIndexes;

  /// List of column indexes in which the sequence is maintained
  /// while the frozen column is visible.
  List<int> get columnIndexesForShowFrozen;

  /// Width of the entire column.
  double get columnsWidth;

  /// Left frozen columns.
  List<TrinaColumn> get leftFrozenColumns;

  /// Left frozen column Index List.
  List<int> get leftFrozenColumnIndexes;

  /// Width of the left frozen column.
  double get leftFrozenColumnsWidth;

  /// Right frozen columns.
  List<TrinaColumn> get rightFrozenColumns;

  /// Right frozen column Index List.
  List<int> get rightFrozenColumnIndexes;

  /// Width of the right frozen column.
  double get rightFrozenColumnsWidth;

  /// Body columns.
  List<TrinaColumn> get bodyColumns;

  /// Body column Index List.
  List<int> get bodyColumnIndexes;

  /// Width of the body column.
  double get bodyColumnsWidth;

  /// Column of currently selected cell.
  TrinaColumn? get currentColumn;

  /// Column field name of currently selected cell.
  String? get currentColumnField;

  bool get hasSortedColumn;

  TrinaColumn? get getSortedColumn;

  /// Column Index List by frozen Column
  List<int> get columnIndexesByShowFrozen;

  /// Toggle whether the column is frozen or not.
  ///
  /// When [column] is changed to a frozen column,
  /// the [TrinaColumn.frozen] is not changed if the frozen column width constraint is insufficient.
  /// Unfreeze the existing frozen or widen the entire grid width
  /// to set it wider than the frozen column width constraint.
  void toggleFrozenColumn(TrinaColumn column, TrinaColumnFrozen frozen);

  /// Toggle column sorting.
  ///
  /// It works when you tap the title area of a column.
  /// When called, [TrinaGrid.onSorted] callback is called. (If registered)
  ///
  /// [sortAscending], [sortDescending], [sortBySortIdx] also sort the column,
  /// but do not call the [TrinaGrid.onSorted] callback.
  void toggleSortColumn(TrinaColumn column);

  /// Index of [column] in [columns]
  ///
  /// Depending on the state of the frozen column, the column order index
  /// must be referenced with the columnIndexesByShowFrozen function.
  int? columnIndex(TrinaColumn column);

  /// Insert [columns] at [columnIdx] position.
  ///
  /// If there is a [TrinaColumn.frozen.isFrozen] column in [columns],
  /// If the width constraint of the frozen column is greater than the range,
  /// the columns are unfreeze in order.
  void insertColumns(int columnIdx, List<TrinaColumn> columns);

  void removeColumns(List<TrinaColumn> columns);

  /// Move [column] position to [targetColumn].
  ///
  /// In case of [column.frozen.isNone] and [targetColumn.frozen.isFroze],
  /// If the width constraint of a frozen column is narrow, it cannot be moved.
  void moveColumn({
    required TrinaColumn column,
    required TrinaColumn targetColumn,
  });

  /// Resize column size
  ///
  /// In case of [column.frozen.isFrozen],
  /// it is not changed if the width constraint of the frozen column is narrow.
  void resizeColumn(TrinaColumn column, double offset);

  void autoFitColumn(BuildContext context, TrinaColumn column);
  void autoFitColumns(BuildContext context, List<TrinaColumn> columns,
      List<int>? ignoreIndexes);

  /// Hide or show the [column] with [hide] value.
  void hideColumn(TrinaColumn column, bool hide, {bool notify = true});

  /// Hide or show the [columns] with [hide] value.
  void hideColumns(List<TrinaColumn> columns, bool hide, {bool notify = true});

  void sortAscending(TrinaColumn column, {bool notify = true});

  void sortDescending(TrinaColumn column, {bool notify = true});

  void sortBySortIdx(TrinaColumn column, {bool notify = true});

  void showSetColumnsPopup(BuildContext context);

  /// When expanding the width of the freeze column,
  /// check the width constraint of the freeze column.
  bool limitResizeColumn(TrinaColumn column, double offset);

  /// When moving from a non-frozen column to a frozen column area,
  /// check the frozen column width constraint.
  bool limitMoveColumn({
    required TrinaColumn column,
    required TrinaColumn targetColumn,
  });

  /// When changing the value of [TrinaColumn.frozen],
  /// check the frozen column width constraint.
  ///
  /// [frozen] is the value you want to change.
  bool limitToggleFrozenColumn(TrinaColumn column, TrinaColumnFrozen frozen);
}

mixin ColumnState implements ITrinaGridState {
  @override
  List<TrinaColumn> get columns => List.from(refColumns, growable: false);

  @override
  List<int> get columnIndexes =>
      List.generate(refColumns.length, (index) => index, growable: false);

  @override
  List<int> get columnIndexesForShowFrozen {
    final leftIndexes = <int>[];
    final bodyIndexes = <int>[];
    final rightIndexes = <int>[];
    final length = refColumns.length;

    for (int i = 0; i < length; i += 1) {
      refColumns[i].frozen.isNone
          ? bodyIndexes.add(i)
          : refColumns[i].frozen.isStart
              ? leftIndexes.add(i)
              : rightIndexes.add(i);
    }

    return leftIndexes + bodyIndexes + rightIndexes;
  }

  @override
  double get columnsWidth {
    double width = 0;

    for (final column in refColumns) {
      width += column.width;
    }

    return width;
  }

  @override
  List<TrinaColumn> get leftFrozenColumns {
    return refColumns.where((e) => e.frozen.isStart).toList(growable: false);
  }

  @override
  List<int> get leftFrozenColumnIndexes {
    final indexes = <int>[];
    final length = refColumns.length;

    for (int i = 0; i < length; i += 1) {
      if (refColumns[i].frozen.isStart) {
        indexes.add(i);
      }
    }

    return indexes;
  }

  @override
  double get leftFrozenColumnsWidth {
    double width = 0;

    for (final column in refColumns) {
      if (column.frozen.isStart) {
        width += column.width;
      }
    }

    return width;
  }

  @override
  List<TrinaColumn> get rightFrozenColumns {
    return refColumns.where((e) => e.frozen.isEnd).toList();
  }

  @override
  List<int> get rightFrozenColumnIndexes {
    final indexes = <int>[];
    final length = refColumns.length;

    for (int i = 0; i < length; i += 1) {
      if (refColumns[i].frozen.isEnd) {
        indexes.add(i);
      }
    }

    return indexes;
  }

  @override
  double get rightFrozenColumnsWidth {
    double width = 0;

    for (final column in refColumns) {
      if (column.frozen.isEnd) {
        width += column.width;
      }
    }

    return width;
  }

  @override
  List<TrinaColumn> get bodyColumns {
    return refColumns.where((e) => e.frozen.isNone).toList();
  }

  @override
  List<int> get bodyColumnIndexes {
    final indexes = <int>[];
    final length = refColumns.length;

    for (int i = 0; i < length; i += 1) {
      if (refColumns[i].frozen.isNone) {
        indexes.add(i);
      }
    }

    return indexes;
  }

  @override
  double get bodyColumnsWidth {
    double width = 0;

    for (final column in refColumns) {
      if (column.frozen.isNone) {
        width += column.width;
      }
    }

    return width;
  }

  @override
  TrinaColumn? get currentColumn {
    return currentCell?.column;
  }

  @override
  String? get currentColumnField {
    return currentCell?.column.field;
  }

  @override
  bool get hasSortedColumn {
    for (final column in refColumns) {
      if (column.sort.isNone == false) {
        return true;
      }
    }

    return false;
  }

  @override
  TrinaColumn? get getSortedColumn {
    for (final column in refColumns) {
      if (column.sort.isNone == false) {
        return column;
      }
    }

    return null;
  }

  @override
  List<int> get columnIndexesByShowFrozen {
    return showFrozenColumn ? columnIndexesForShowFrozen : columnIndexes;
  }

  @override
  void toggleFrozenColumn(TrinaColumn column, TrinaColumnFrozen frozen) {
    if (limitToggleFrozenColumn(column, frozen)) {
      return;
    }

    column.frozen = column.frozen.isFrozen ? TrinaColumnFrozen.none : frozen;

    resetCurrentState(notify: false);

    resetShowFrozenColumn();

    if (!columnSizeConfig.restoreAutoSizeAfterFrozenColumn) {
      deactivateColumnsAutoSize();
    }

    updateVisibilityLayout();

    if (onColumnsMoved != null) {
      onColumnsMoved!(
        TrinaGridOnColumnsMovedEvent(
          idx: refColumns.indexOf(column),
          visualIdx: columnIndex(column)!,
          columns: [column],
        ),
      );
    }

    notifyListeners(true, toggleFrozenColumn.hashCode);
  }

  @override
  void toggleSortColumn(TrinaColumn column) {
    final oldSort = column.sort;

    if (column.sort.isNone) {
      sortAscending(column, notify: false);
    } else if (column.sort.isAscending) {
      sortDescending(column, notify: false);
    } else {
      sortBySortIdx(column, notify: false);
    }

    _callOnSorted(column, oldSort);

    notifyListeners(true, toggleSortColumn.hashCode);
  }

  @override
  int? columnIndex(TrinaColumn column) {
    final columnIndexes = columnIndexesByShowFrozen;
    final length = columnIndexes.length;

    for (int i = 0; i < length; i += 1) {
      if (refColumns[columnIndexes[i]].field == column.field) {
        return i;
      }
    }

    return null;
  }

  @override
  void insertColumns(int columnIdx, List<TrinaColumn> columns) {
    if (columns.isEmpty) {
      return;
    }

    if (columnIdx < 0 || refColumns.length < columnIdx) {
      return;
    }

    _updateLimitedFrozenColumns(columns);

    if (columnIdx >= refColumns.originalLength) {
      refColumns.addAll(columns);
    } else {
      refColumns.insertAll(columnIdx, columns);
    }

    _fillCellsInRows(columns);

    resetCurrentState(notify: false);

    resetShowFrozenColumn();

    if (!columnSizeConfig.restoreAutoSizeAfterInsertColumn) {
      deactivateColumnsAutoSize();
    }

    updateVisibilityLayout();

    notifyListeners(true, insertColumns.hashCode);
  }

  @override
  void removeColumns(List<TrinaColumn> columns) {
    if (columns.isEmpty) {
      return;
    }

    removeColumnsInColumnGroup(columns, notify: false);

    removeColumnsInFilterRows(columns, notify: false);

    removeColumnsInRowGroupByColumn(columns, notify: false);

    _removeCellsInRows(columns);

    final removeKeys = Set.from(columns.map((e) => e.key));

    refColumns.removeWhereFromOriginal(
      (column) => removeKeys.contains(column.key),
    );

    resetShowFrozenColumn();

    if (!columnSizeConfig.restoreAutoSizeAfterRemoveColumn) {
      deactivateColumnsAutoSize();
    }

    updateVisibilityLayout();

    resetCurrentState(notify: false);

    notifyListeners(true, removeColumns.hashCode);
  }

  @override
  void moveColumn({
    required TrinaColumn column,
    required TrinaColumn targetColumn,
  }) {
    if (limitMoveColumn(column: column, targetColumn: targetColumn)) {
      return;
    }

    final foundIndexes = _findIndexOfColumns([column, targetColumn]);

    if (foundIndexes.length != 2) {
      return;
    }

    int index = foundIndexes[0];

    int targetIndex = foundIndexes[1];

    final frozen = refColumns[index].frozen;

    final targetFrozen = refColumns[targetIndex].frozen;

    if (frozen != targetFrozen) {
      if (targetFrozen.isEnd && index > targetIndex) {
        targetIndex += 1;
      } else if (targetFrozen.isStart && index < targetIndex) {
        targetIndex -= 1;
      } else if (frozen.isStart && index > targetIndex) {
        targetIndex += 1;
      } else if (frozen.isEnd && index < targetIndex) {
        targetIndex -= 1;
      }
    }

    refColumns[index].frozen = targetFrozen;

    var columnToMove = refColumns[index];

    refColumns.removeAt(index);

    refColumns.insert(targetIndex, columnToMove);

    updateCurrentCellPosition(notify: false);

    resetShowFrozenColumn();

    if (!columnSizeConfig.restoreAutoSizeAfterMoveColumn) {
      deactivateColumnsAutoSize();
    }

    updateVisibilityLayout();

    if (onColumnsMoved != null) {
      onColumnsMoved!(
        TrinaGridOnColumnsMovedEvent(
          idx: targetIndex,
          visualIdx: columnIndex(columnToMove)!,
          columns: [columnToMove],
        ),
      );
    }

    notifyListeners(true, moveColumn.hashCode);
  }

  @override
  void resizeColumn(TrinaColumn column, double offset) {
    if (columnsResizeMode.isNone || !column.enableDropToResize) {
      return;
    }

    if (limitResizeColumn(column, offset)) {
      return;
    }

    bool updated = false;

    if (columnsResizeMode.isNormal) {
      final setWidth = column.width + offset;

      column.width = setWidth > column.minWidth ? setWidth : column.minWidth;

      updated = setWidth == column.width;
    } else {
      updated = _updateResizeColumns(column: column, offset: offset);
    }

    if (updated == false) {
      return;
    }

    deactivateColumnsAutoSize();

    notifyResizingListeners();

    scrollByDirection(TrinaMoveDirection.right, correctHorizontalOffset);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      activateColumnsAutoSize();
    });
  }

  @override
  void autoFitColumn(BuildContext context, TrinaColumn column) {
    String maxValue = '';
    bool hasExpandableRowGroup = false;
    for (final row in refRows) {
      final cell = row.cells.entries
          .firstWhere((element) => element.key == column.field)
          .value;
      var value = column.formattedValueForDisplay(cell.value);
      if (hasRowGroups) {
        if (TrinaDefaultCell.showGroupCount(rowGroupDelegate!, cell)) {
          final groupCountValue = TrinaDefaultCell.groupCountText(
            rowGroupDelegate!,
            row,
          );
          if (groupCountValue.isNotEmpty) {
            value = '$value $groupCountValue';
          }
        }

        hasExpandableRowGroup |= TrinaDefaultCell.canExpand(
          rowGroupDelegate!,
          cell,
        );
      }
      if (maxValue.length < value.length) {
        maxValue = value;
      }
    }

    // Get size after rendering virtually
    // https://stackoverflow.com/questions/54351655/flutter-textfield-width-should-match-width-of-contained-text
    final titleTextWidth = _visualTextWidth(
      column.title,
      style.columnTextStyle,
    );
    final maxValueTextWidth = _visualTextWidth(maxValue, style.cellTextStyle);

    // todo : Handle (renderer) width

    final calculatedTileWidth = titleTextWidth -
        column.width +
        [
          (column.titlePadding ?? style.defaultColumnTitlePadding).horizontal,
          if (column.enableRowChecked)
            _getEffectiveButtonWidth(context, checkBox: true),
          if (column.isShowRightIcon) style.iconSize,
          8,
        ].reduce((acc, a) => acc + a);

    final calculatedCellWidth = maxValueTextWidth -
        column.width +
        [
          (column.cellPadding ?? style.defaultCellPadding).horizontal,
          if (hasExpandableRowGroup) _getEffectiveButtonWidth(context),
          if (column.enableRowChecked)
            _getEffectiveButtonWidth(context, checkBox: true),
          if (column.isShowRightIcon) style.iconSize,
          2,
        ].reduce((acc, a) => acc + a);

    resizeColumn(column, math.max(calculatedTileWidth, calculatedCellWidth));
  }

  double _visualTextWidth(String text, TextStyle style) {
    if (text.isEmpty) return 0;
    final painter = TextPainter(
      text: TextSpan(style: style, text: text),
      textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
    )..layout();
    return painter.width;
  }

  @override
  void autoFitColumns(
    BuildContext context,
    List<TrinaColumn> columns, [
    List<int>? ignoreIndexes,
  ]) {
    for (final column in columns) {
      // Skip if specific indexes provided and column not in list
      if (ignoreIndexes != null &&
          ignoreIndexes.contains(refColumns.originalList.indexOf(column))) {
        continue;
      }
      autoFitColumn(context, column);
    }
  }

  @override
  void hideColumn(TrinaColumn column, bool hide, {bool notify = true}) {
    if (column.hide == hide) {
      return;
    }

    column.hide = hide;
    _updateAfterHideColumn(columns: [column], notify: notify);

    eventManager?.addEvent(
      TrinaGridColumnHiddenEvent(columns: [column], isHidden: hide),
    );
  }

  @override
  void hideColumns(List<TrinaColumn> columns, bool hide, {bool notify = true}) {
    if (columns.isEmpty) {
      return;
    }

    final changedColumns = <TrinaColumn>[];
    for (final column in columns) {
      if (hide == column.hide) {
        continue;
      }

      column.hide = hide;
      changedColumns.add(column);
    }

    if (changedColumns.isEmpty) {
      return;
    }

    _updateAfterHideColumn(columns: columns, notify: notify);

    eventManager?.addEvent(
      TrinaGridColumnHiddenEvent(columns: changedColumns, isHidden: hide),
    );
  }

  @override
  void sortAscending(TrinaColumn column, {bool notify = true}) {
    _updateBeforeColumnSort();

    column.sort = TrinaColumnSort.ascending;

    if (sortOnlyEvent) return;

    compare(a, b) => column.type.compare(
          a.cells[column.field]!.valueForSorting,
          b.cells[column.field]!.valueForSorting,
        );

    if (enabledRowGroups) {
      sortRowGroup(column: column, compare: compare);
    } else {
      refRows.sort(compare);
    }

    notifyListeners(notify, sortAscending.hashCode);
  }

  @override
  void sortDescending(TrinaColumn column, {bool notify = true}) {
    _updateBeforeColumnSort();

    column.sort = TrinaColumnSort.descending;

    if (sortOnlyEvent) return;

    compare(b, a) => column.type.compare(
          a.cells[column.field]!.valueForSorting,
          b.cells[column.field]!.valueForSorting,
        );

    if (enabledRowGroups) {
      sortRowGroup(column: column, compare: compare);
    } else {
      refRows.sort(compare);
    }

    notifyListeners(notify, sortDescending.hashCode);
  }

  @override
  void sortBySortIdx(TrinaColumn column, {bool notify = true}) {
    _updateBeforeColumnSort();

    if (sortOnlyEvent) return;

    int compare(a, b) {
      if (a.sortIdx == null || b.sortIdx == null) {
        if (a.sortIdx == null && b.sortIdx == null) {
          return 0;
        }

        return a.sortIdx == null ? -1 : 1;
      }

      return a.sortIdx!.compareTo(b.sortIdx!);
    }

    if (enabledRowGroups) {
      sortRowGroup(column: column, compare: compare);
    } else {
      refRows.sort(compare);
    }

    notifyListeners(notify, sortBySortIdx.hashCode);
  }

  @override
  void showSetColumnsPopup(BuildContext context) {
    const titleField = 'title';
    const columnField = 'field';

    final columns = [
      TrinaColumn(
        title: configuration.localeText.setColumnsTitle,
        field: titleField,
        type: TrinaColumnType.text(),
        enableRowChecked: true,
        enableEditingMode: false,
        enableDropToResize: true,
        enableContextMenu: false,
        enableColumnDrag: false,
        backgroundColor: configuration.style.filterPopupHeaderColor,
      ),
      TrinaColumn(
        title: 'hidden column',
        field: columnField,
        type: TrinaColumnType.text(),
        hide: true,
      ),
    ];

    final toRow = _toRowByColumnField(
      titleField: titleField,
      columnField: columnField,
    );

    final rows = refColumns.originalList.map(toRow).toList(growable: false);

    void handleOnRowChecked(TrinaGridOnRowCheckedEvent event) {
      if (event.isAll) {
        hideColumns(refColumns.originalList, event.isChecked != true);
      } else {
        final checkedField = event.row!.cells[columnField]!.value.toString();
        final checkedColumn = refColumns.originalList.firstWhere(
          (column) => column.field == checkedField,
        );
        hideColumn(checkedColumn, event.isChecked != true);
      }
    }

    // Use dark configuration if the current configuration is in dark mode
    final baseConfiguration = configuration.style.isDarkStyle
        ? const TrinaGridConfiguration.dark()
        : const TrinaGridConfiguration();

    TrinaGridPopup(
      context: context,
      configuration: baseConfiguration.copyWith(
        style: baseConfiguration.style.copyWith(
          gridBorderRadius: configuration.style.gridPopupBorderRadius,
          enableRowColorAnimation: false,
          oddRowColor: const TrinaOptional(null),
          evenRowColor: const TrinaOptional(null),
        ),
      ),
      columns: columns,
      rows: rows,
      width: 200,
      height: 500,
      mode: TrinaGridMode.popup,
      onLoaded: (e) {
        e.stateManager.setSelectingMode(TrinaGridSelectingMode.none);
      },
      onRowChecked: handleOnRowChecked,
    );
  }

  @override
  bool limitResizeColumn(TrinaColumn column, double offset) {
    if (offset <= 0) {
      return false;
    }

    return _limitFrozenColumn(column.frozen, offset);
  }

  @override
  bool limitMoveColumn({
    required TrinaColumn column,
    required TrinaColumn targetColumn,
  }) {
    if (column.frozen.isFrozen) {
      return false;
    }

    return _limitFrozenColumn(targetColumn.frozen, column.width);
  }

  @override
  bool limitToggleFrozenColumn(TrinaColumn column, TrinaColumnFrozen frozen) {
    if (column.frozen.isFrozen) {
      return false;
    }

    return _limitFrozenColumn(frozen, column.width);
  }

  /// Check the width limit before changing the TrinaColumnFrozen value.
  ///
  /// In the following situations, need to check the frozen column width limit.
  /// 1. Change the width of the frozen column
  /// 2. Set a non-frozen column to a frozen column
  /// 3. If the column to be unhidden in the hidden state is a frozen column
  /// 4. Add a frozen column
  ///
  /// [frozen] The value to be changed.
  ///
  /// [offsetWidth] The size to be changed. Usually [TrinaColumn.width].
  /// Check the width limit of the frozen column
  /// by subtracting the offsetWidth value from the total width of the grid.
  /// Assume that a column has been added by subtracting the [offsetWidth] value
  /// from the total width while no column has been added yet.
  bool _limitFrozenColumn(TrinaColumnFrozen frozen, double offsetWidth) {
    if (frozen.isNone) {
      return false;
    }

    return !enoughFrozenColumnsWidth(maxWidth! - offsetWidth);
  }

  void _updateBeforeColumnSort() {
    clearCurrentCell(notify: false);

    clearCurrentSelecting(notify: false);

    // Reset column sort to none.
    for (var i = 0; i < refColumns.originalList.length; i += 1) {
      refColumns.originalList[i].sort = TrinaColumnSort.none;
    }
  }

  List<int> _findIndexOfColumns(List<TrinaColumn> findColumns) {
    SplayTreeMap<int, int> found = SplayTreeMap();

    for (int i = 0; i < refColumns.length; i += 1) {
      for (int j = 0; j < findColumns.length; j += 1) {
        if (findColumns[j].key == refColumns[i].key) {
          found[j] = i;
          continue;
        }
      }

      if (findColumns.length == found.length) {
        break;
      }
    }

    return found.values.toList();
  }

  TrinaRow Function(TrinaColumn column) _toRowByColumnField({
    required String titleField,
    required String columnField,
  }) {
    return (TrinaColumn column) {
      return TrinaRow(
        cells: {
          titleField: TrinaCell(value: column.titleWithGroup),
          columnField: TrinaCell(value: column.field),
        },
        checked: !column.hide,
      );
    };
  }

  /// [TrinaGrid.onSorted] Called when a callback is registered.
  void _callOnSorted(TrinaColumn column, TrinaColumnSort oldSort) {
    if (sortOnlyEvent) {
      eventManager!.addEvent(
        TrinaGridChangeColumnSortEvent(column: column, oldSort: oldSort),
      );
    }

    if (onSorted == null) {
      return;
    }

    onSorted!(TrinaGridOnSortedEvent(column: column, oldSort: oldSort));
  }

  /// Add [TrinaCell] to the whole [TrinaRow.cells].
  /// Called when a new column is added.
  void _fillCellsInRows(List<TrinaColumn> columns) {
    for (var row in iterateAllRowAndGroup) {
      final List<MapEntry<String, TrinaCell>> cells = [];

      for (var column in columns) {
        final cell = TrinaCell(value: column.type.defaultValue)
          ..setRow(row)
          ..setColumn(column);

        cells.add(MapEntry(column.field, cell));
      }

      row.cells.addEntries(cells);
    }
  }

  /// Delete [TrinaCell] with matching [columns.field] from [TrinaRow.cells].
  /// When a column is deleted, the corresponding [TrinaCell] is also called to be deleted.
  void _removeCellsInRows(List<TrinaColumn> columns) {
    for (var row in iterateAllRowAndGroup) {
      for (var column in columns) {
        row.cells.remove(column.field);
      }
    }
  }

  /// If there is a [TrinaColumn.frozen] column in [columns],
  /// check the width limit of the frozen column.
  /// If there are more frozen columns in [columns] than the width limit,
  /// they are updated in order to unfreeze them.
  void _updateLimitedFrozenColumns(List<TrinaColumn> columns) {
    double accumulateWidth = 0;

    for (final column in columns) {
      if (_limitFrozenColumn(column.frozen, column.width + accumulateWidth)) {
        column.frozen = TrinaColumnFrozen.none;
      }

      if (column.frozen.isFrozen) {
        accumulateWidth += column.width;
      }
    }
  }

  void _updateAfterHideColumn({
    required List<TrinaColumn> columns,
    required bool notify,
  }) {
    refColumns.update();

    resetCurrentState(notify: false);

    resetShowFrozenColumn();

    if (!columnSizeConfig.restoreAutoSizeAfterHideColumn) {
      deactivateColumnsAutoSize();
    }

    updateRowGroupByHideColumn(columns);

    updateVisibilityLayout();

    notifyListeners(notify, hideColumn.hashCode);
  }

  bool _updateResizeColumns({
    required TrinaColumn column,
    required double offset,
  }) {
    if (offset == 0 || columnsResizeMode.isNone || columnsResizeMode.isNormal) {
      return false;
    }

    final columns = showFrozenColumn
        ? leftFrozenColumns + bodyColumns + rightFrozenColumns
        : refColumns;

    final resizeHelper = getColumnsResizeHelper(
      columns: columns,
      column: column,
      offset: offset,
    );

    return resizeHelper.update();
  }

  double _getEffectiveButtonWidth(
    BuildContext context, {
    bool checkBox = false,
  }) {
    final theme = Theme.of(context);
    late double width;
    switch (theme.materialTapTargetSize) {
      case MaterialTapTargetSize.padded:
        width = kMinInteractiveDimension;
        break;
      case MaterialTapTargetSize.shrinkWrap:
        width = kMinInteractiveDimension - 8.0;
        break;
    }
    if (!checkBox) {
      return width;
    }
    return width + theme.visualDensity.baseSizeAdjustment.dx;
  }
}
