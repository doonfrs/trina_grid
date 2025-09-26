import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:trina_grid/trina_grid.dart';

/*
  todo
    ColumnGroup
      - Apply changed depth when removing column
    Row
      - Move
      - Improve initializeRows when adding rows
    Test
      - add, insert, prepend, append rows with pagination, sort, filter
    Performance
      - Toggle row group
      - Filtering
      - Sorting
      - Aggregate footer
 */

abstract class IRowGroupState {
  /// Whether to set [TrinaRowGroupDelegate] for row grouping.
  ///
  /// Returns true if [TrinaRowGroupDelegate] is set with [setRowGroup].
  bool get hasRowGroups;

  /// If [TrinaRowGroupDelegate] is set for row grouping,
  /// return the active status of the actual grouping function.
  ///
  /// If grouped by [TrinaRowGroupByColumnDelegate],
  /// return false if there is no set group column
  /// because the set group column is deleted or hidden.
  bool get enabledRowGroups;

  /// Setting delegate for grouping rows.
  ///
  /// {@template row_group_state_rowGroupDelegate}
  /// As a class that implements [TrinaRowGroupDelegate],
  /// it defines functions necessary for row grouping.
  ///
  /// [TrinaRowGroupTreeDelegate] allows grouping of complex depths.
  ///
  /// [TrinaRowGroupByColumnDelegate] groups rows by column.
  /// {@endtemplate}
  TrinaRowGroupDelegate? get rowGroupDelegate;

  /// Regardless of filtering or pagination applied,
  ///
  /// {@macro row_group_state_iterateMainRowGroup}
  Iterable<TrinaRow> get iterateAllMainRowGroup;

  /// Regardless of filtering or pagination applied,
  ///
  /// {@macro row_group_state_iterateRowGroup}
  Iterable<TrinaRow> get iterateAllRowGroup;

  /// Regardless of filtering or pagination applied,
  ///
  /// {@macro row_group_state_iterateRowAndGroup}
  Iterable<TrinaRow> get iterateAllRowAndGroup;

  /// Regardless of filtering or pagination applied,
  ///
  /// {@macro row_group_state_iterateRow}
  Iterable<TrinaRow> get iterateAllRow;

  /// Regardless of pagination applied,
  ///
  /// {@macro row_group_state_iterateMainRowGroup}
  Iterable<TrinaRow> get iterateFilteredMainRowGroup;

  /// With filtering or pagination applied,
  ///
  /// {@template row_group_state_iterateMainRowGroup}
  /// Returns the all rows with the highest depth.
  ///
  /// The depth is determined by [TrinaRow.parent].
  /// If [TrinaRow.parent] does not exist, the depth is the top level,
  /// and it continues to explore this property to determine the depth of the depth.
  /// {@endtemplate}
  Iterable<TrinaRow> get iterateMainRowGroup;

  /// With filtering or pagination applied,
  ///
  /// {@template row_group_state_iterateRowGroup}
  /// Returns all rows where [TrinaRow.type] is set to [TrinaRowType.group].
  /// {@endtemplate}
  Iterable<TrinaRow> get iterateRowGroup;

  /// With filtering or pagination applied,
  ///
  /// {@template row_group_state_iterateRowAndGroup}
  /// Returns all rows where [TrinaRow.type] is [TrinaRowType.group] or [TrinaRowType.normal].
  /// {@endtemplate}
  Iterable<TrinaRow> get iterateRowAndGroup;

  /// With filtering or pagination applied,
  ///
  /// {@template row_group_state_iterateRow}
  /// Returns all rows where [TrinaRow.type] is not [TrinaRowType.group].
  /// {@endtemplate}
  Iterable<TrinaRow> get iterateRow;

  /// Returns whether it is the top row or not.
  ///
  /// If [TrinaRow.parent] does not exist, it is the top row.
  bool isMainRow(TrinaRow row);

  bool isNotMainGroupedRow(TrinaRow row);

  bool isExpandedGroupedRow(TrinaRow row);

  /// Set up a delegate for grouping rows.
  ///
  /// {@macro row_group_state_rowGroupDelegate}
  void setRowGroup(TrinaRowGroupDelegate? delegate, {bool notify = true});

  /// Collapse or expand the group row.
  ///
  /// If [expanded] is provided, the group will be set to that state.
  /// If [expanded] is null, the group state will be toggled.
  void toggleExpandedRowGroup({
    required TrinaRow rowGroup,
    bool notify = true,
    bool? expanded,
  });

  /// Expand all group rows.
  void expandAllRowGroups({bool notify = true});

  /// Collapse all group rows.
  void collapseAllRowGroups({bool notify = true});

  @protected
  void setRowGroupFilter(FilteredListFilter<TrinaRow>? filter);

  @protected
  void sortRowGroup({
    required TrinaColumn column,
    required int Function(TrinaRow, TrinaRow) compare,
  });

  @protected
  void insertRowGroup(int index, List<TrinaRow> rows);

  @protected
  void removeRowAndGroupByKey(Iterable<Key> keys);

  @protected
  void removeColumnsInRowGroupByColumn(
    List<TrinaColumn> columns, {
    bool notify = true,
  });

  @protected
  void updateRowGroupByHideColumn(List<TrinaColumn> columns);
}

class _State {
  bool _previousEnabledRowGroups = false;

  TrinaRowGroupDelegate? _rowGroupDelegate;
}

mixin RowGroupState implements ITrinaGridState {
  final _State _state = _State();

  @override
  bool get hasRowGroups => _state._rowGroupDelegate != null;

  @override
  bool get enabledRowGroups => rowGroupDelegate?.enabled == true;

  @override
  TrinaRowGroupDelegate? get rowGroupDelegate => _state._rowGroupDelegate;

  @override
  Iterable<TrinaRow> get iterateAllMainRowGroup sync* {
    for (final row in refRows.originalList.where(isMainRow)) {
      yield row;
    }
  }

  @override
  Iterable<TrinaRow> get iterateAllRowGroup sync* {
    for (final row in _iterateRowGroup(iterateAllMainRowGroup)) {
      yield row;
    }
  }

  @override
  Iterable<TrinaRow> get iterateAllRowAndGroup sync* {
    for (final row in _iterateRowAndGroup(iterateAllMainRowGroup)) {
      yield row;
    }
  }

  @override
  Iterable<TrinaRow> get iterateAllRow sync* {
    for (final row in _iterateRow(iterateAllMainRowGroup)) {
      yield row;
    }
  }

  @override
  Iterable<TrinaRow> get iterateFilteredMainRowGroup sync* {
    for (final row in refRows.filterOrOriginalList.where(isMainRow)) {
      yield row;
    }
  }

  @override
  Iterable<TrinaRow> get iterateMainRowGroup sync* {
    for (final row in refRows.where(isMainRow)) {
      yield row;
    }
  }

  @override
  Iterable<TrinaRow> get iterateRowGroup sync* {
    for (final row in _iterateRowGroup(
      iterateMainRowGroup,
      iterateAll: false,
    )) {
      yield row;
    }
  }

  @override
  Iterable<TrinaRow> get iterateRowAndGroup sync* {
    for (final row in _iterateRowAndGroup(
      iterateMainRowGroup,
      iterateAll: false,
    )) {
      yield row;
    }
  }

  @override
  Iterable<TrinaRow> get iterateRow sync* {
    for (final row in _iterateRow(iterateMainRowGroup, iterateAll: false)) {
      yield row;
    }
  }

  bool get _previousEnabledRowGroups => _state._previousEnabledRowGroups;

  @override
  bool isMainRow(TrinaRow row) => row.isMain;

  @override
  bool isNotMainGroupedRow(TrinaRow row) => !isMainRow(row);

  @override
  bool isExpandedGroupedRow(TrinaRow row) {
    return row.type.isGroup && row.type.group.expanded;
  }

  @override
  void setRowGroup(TrinaRowGroupDelegate? delegate, {bool notify = true}) {
    _state._rowGroupDelegate = delegate;

    _updateRowGroup();

    notifyListeners(notify, setRowGroup.hashCode);
  }

  @override
  void toggleExpandedRowGroup({
    required TrinaRow rowGroup,
    bool notify = true,
    bool? expanded,
  }) {
    assert(enabledRowGroups);

    if (!rowGroup.type.isGroup ||
        rowGroup.type.group.children.originalList.isEmpty) {
      return;
    }

    if (expanded == true && rowGroup.type.group.expanded) {
      return;
    } else if (expanded == false && !rowGroup.type.group.expanded) {
      return;
    }

    if (rowGroup.type.group.expanded) {
      final Set<Key> removeKeys = {};

      for (final child in _iterateRowAndGroup(rowGroup.type.group.children)) {
        removeKeys.add(child.key);
      }

      refRows.removeWhereFromOriginal((e) => removeKeys.contains(e.key));
    } else {
      final Iterable<TrinaRow> children = TrinaRowGroupHelper.iterateWithFilter(
        rowGroup.type.group.children,
        filter: (r) => true,
        childrenFilter: (r) => r.type.isGroup && r.type.group.expanded
            ? r.type.group.children.iterator
            : null,
      );

      final idx = refRows.indexOf(rowGroup);

      refRows.insertAll(idx + 1, children);
    }

    rowGroup.type.group.setExpanded(expanded ?? !rowGroup.type.group.expanded);

    if (isPaginated) {
      resetPage(resetCurrentState: false, notify: false);
    }

    if (rowGroupDelegate?.onToggled != null) {
      rowGroupDelegate!.onToggled!(
        row: rowGroup,
        expanded: rowGroup.type.group.expanded,
      );
    }

    updateCurrentCellPosition(notify: false);

    clearCurrentSelecting(notify: false);

    notifyListeners(notify, toggleExpandedRowGroup.hashCode);
  }

  @override
  void expandAllRowGroups({bool notify = true}) {
    if (!enabledRowGroups) {
      return;
    }

    final List<TrinaRow> collapsedGroups = [];
    //check all children recursive
    void checkChildrenRecursive(TrinaRow row) {
      if (row.type.isGroup && !row.type.group.expanded) {
        collapsedGroups.add(row);
        for (final child in row.type.group.children.originalList) {
          if (!child.type.isGroup) {
            continue;
          }

          if (child.type.group.expanded) {
            continue;
          }

          collapsedGroups.add(child);

          checkChildrenRecursive(child);
        }
      }
    }

    for (final row in refRows.originalList) {
      checkChildrenRecursive(row);
    }

    for (final groupRow in collapsedGroups) {
      toggleExpandedRowGroup(rowGroup: groupRow, expanded: true, notify: false);
    }

    notifyListeners(notify);
  }

  @override
  void collapseAllRowGroups({bool notify = true}) {
    if (!enabledRowGroups) {
      return;
    }

    final List<TrinaRow> expandedGroups = [];
    //check all children recursive
    void checkChildrenRecursive(TrinaRow row) {
      if (row.type.isGroup && row.type.group.expanded) {
        expandedGroups.add(row);
        for (final child in row.type.group.children.originalList) {
          if (!child.type.isGroup) {
            continue;
          }

          if (!child.type.group.expanded) {
            continue;
          }

          expandedGroups.add(child);

          checkChildrenRecursive(child);
        }
      }
    }

    for (final row in refRows.originalList) {
      checkChildrenRecursive(row);
    }

    for (final groupRow in expandedGroups) {
      toggleExpandedRowGroup(
        rowGroup: groupRow,
        expanded: false,
        notify: false,
      );
    }

    notifyListeners(notify);
  }

  @override
  @protected
  void setRowGroupFilter(FilteredListFilter<TrinaRow>? filter) {
    assert(enabledRowGroups);

    _ensureRowGroups(() {
      rowGroupDelegate!.filter(rows: refRows, filter: filter);
    });
  }

  @override
  @protected
  void sortRowGroup({
    required TrinaColumn column,
    required int Function(TrinaRow, TrinaRow) compare,
  }) {
    assert(enabledRowGroups);

    _ensureRowGroups(() {
      rowGroupDelegate!.sort(column: column, rows: refRows, compare: compare);
    });
  }

  @override
  @protected
  void insertRowGroup(int index, List<TrinaRow> rows) {
    if (rows.isEmpty) {
      return;
    }

    assert(enabledRowGroups);

    if (!rows.first.initialized) {
      TrinaGridStateManager.initializeRows(
        refColumns.originalList,
        rows,
        forceApplySortIdx: false,
      );
    }

    final bool append = index >= refRows.length;
    final targetIdx = append ? refRows.length - 1 : index;
    final target = refRows.isEmpty ? null : refRows[targetIdx];

    if (rowGroupDelegate is TrinaRowGroupByColumnDelegate && !append) {
      _updateCellsByTargetForGroupByColumn(rows: rows, target: target);
    }

    final grouped = rowGroupDelegate!.toGroup(rows: rows);

    bool findByTargetKey(TrinaRow e) => e.key == target?.key;

    bool hasChildrenGroup(TrinaRow found) {
      return found.type.isGroup &&
          found.type.group.children.originalList.isNotEmpty &&
          found.type.group.children.originalList.first.type.isGroup;
    }

    void updateSortIdx({
      required List<TrinaRow> rows,
      required int start,
      required int compare,
      required int increase,
    }) {
      if (hasSortedColumn) {
        for (final row in rows) {
          if (compare >= row.sortIdx) {
            row.sortIdx += increase;
          }
        }
      } else {
        final length = rows.length;
        for (int i = start; i < length; i += 1) {
          rows[i].sortIdx += increase;
        }
      }
    }

    void updateAddedRow(TrinaRow row) {
      row.setState(TrinaRowState.added);
      if (row.type.isGroup) {
        updateChild(TrinaRow e) {
          e.setParent(row);
          updateAddedRow(e);
        }

        row.type.group.children.originalList.forEach(updateChild);
      }
    }

    void updateAddedChildren(TrinaRow parent, List<TrinaRow> children) {
      parent.setState(TrinaRowState.updated);
      updateChild(TrinaRow e) {
        e.setParent(parent);
        updateAddedRow(e);
      }

      children.forEach(updateChild);
    }

    void insertOrAdd({
      required FilteredList<TrinaRow> ref,
      required TrinaRow row,
      TrinaRow? parent,
    }) {
      row.setParent(parent);
      updateAddedRow(row);

      final insertIdx = ref.indexWhere(findByTargetKey);
      if (insertIdx > -1 && !append) {
        row.sortIdx = ref[insertIdx].sortIdx;
        updateSortIdx(
          rows: ref,
          start: insertIdx,
          compare: row.sortIdx,
          increase: 1,
        );
        ref.insert(insertIdx, row);
      } else {
        ref.add(row);
      }
    }

    void insertOrAddToChildren({
      required TrinaRow found,
      required TrinaRow row,
    }) {
      assert(row.type.isGroup);
      updateAddedChildren(found, row.type.group.children.originalList);

      final insertIdx = found.type.group.children.indexWhere(findByTargetKey);
      if (insertIdx > -1 && !append) {
        final length = row.type.group.children.length;
        for (int i = 0; i < length; i += 1) {
          row.type.group.children[i].sortIdx =
              found.type.group.children[insertIdx].sortIdx + i;
        }
        updateSortIdx(
          rows: found.type.group.children,
          start: insertIdx,
          compare: found.type.group.children[insertIdx].sortIdx,
          increase: row.type.group.children.length,
        );
        found.type.group.children.insertAll(insertIdx, row.type.group.children);
      } else {
        found.type.group.children.addAll(row.type.group.children);
      }
    }

    void addAllGroupByColumn(
      Iterable<TrinaRow> groupedRows,
      FilteredList<TrinaRow> ref,
      TrinaRow? parent,
    ) {
      for (final row in groupedRows) {
        findByRowKey(TrinaRow e) => e.key == row.key;
        final found = ref.originalList.firstWhereOrNull(findByRowKey);

        if (found == null) {
          insertOrAdd(ref: ref, row: row, parent: parent);
        } else {
          if (hasChildrenGroup(found)) {
            addAllGroupByColumn(
              row.type.group.children,
              found.type.group.children,
              found,
            );
          } else {
            insertOrAddToChildren(found: found, row: row);
          }
        }
      }
    }

    void addAllGroupTree() {
      final targetParent = target?.parent?.type.group.children ?? refRows;

      if (target?.parent == null) {
        grouped.forEach(updateAddedRow);
      } else {
        updateAddedChildren(target!.parent!, grouped);
      }

      if (append) {
        targetParent.addAll(grouped);
        return;
      }

      final targetParentList = targetParent.filterOrOriginalList;
      final insertIdx = targetParentList.indexWhere(findByTargetKey);
      assert(insertIdx != -1);

      final length = grouped.length;
      for (int i = 0; i < length; i += 1) {
        grouped[i].sortIdx = (target?.sortIdx ?? 0) + i;
      }

      updateSortIdx(
        rows: targetParent.originalList,
        start: target == null ? 0 : targetParent.originalList.indexOf(target),
        compare: target?.sortIdx ?? 0,
        increase: grouped.length,
      );

      targetParent.insertAll(insertIdx, grouped);
    }

    _ensureRowGroups(() {
      switch (rowGroupDelegate!.type) {
        case TrinaRowGroupDelegateType.tree:
          addAllGroupTree();
          break;
        case TrinaRowGroupDelegateType.byColumn:
          addAllGroupByColumn(grouped, refRows, null);
          break;
      }
    });

    refRows.update();
  }

  @override
  @protected
  void removeRowAndGroupByKey(Iterable<Key> keys) {
    if (keys.isEmpty) {
      return;
    }

    assert(enabledRowGroups);

    bool removeEmptyGroup(TrinaRow row) =>
        rowGroupDelegate!.type.isByColumn &&
        row.type.group.children.originalList.isEmpty;

    _ensureRowGroups(() {
      bool removeAll(TrinaRow row) {
        if (row.type.isGroup) {
          row.type.group.children.removeWhereFromOriginal(removeAll);

          if (removeEmptyGroup(row)) return true;
        }

        return keys.contains(row.key);
      }

      refRows.removeWhereFromOriginal(removeAll);
    });
  }

  @override
  @protected
  void removeColumnsInRowGroupByColumn(
    List<TrinaColumn> columns, {
    bool notify = true,
  }) {
    if (columns.isEmpty || rowGroupDelegate?.type.isByColumn != true) {
      return;
    }

    final delegate = rowGroupDelegate as TrinaRowGroupByColumnDelegate;

    final Set<Key> removeKeys = Set.from(columns.map((e) => e.key));

    isNotRemoved(e) => !removeKeys.contains(e.key);

    final remaining = delegate.columns
        .where(isNotRemoved)
        .toList(growable: false);

    if (remaining.length == delegate.columns.length) {
      return;
    }

    delegate.columns.clear();

    delegate.columns.addAll(remaining);

    _updateRowGroup();
  }

  @override
  @protected
  void updateRowGroupByHideColumn(List<TrinaColumn> columns) {
    if (rowGroupDelegate?.type.isByColumn != true ||
        rowGroupDelegate?.showFirstExpandableIcon == true) {
      return;
    }

    final delegate = rowGroupDelegate as TrinaRowGroupByColumnDelegate;

    final Set<Key> updateKeys = Set.from(columns.map((e) => e.key));

    isUpdated(e) => updateKeys.contains(e.key);

    final updated = delegate.columns.firstWhereOrNull(isUpdated) != null;

    if (updated) {
      _updateRowGroup();
    }
  }

  void _ensureRowGroups(void Function() callback) {
    assert(enabledRowGroups);

    _collapseAllRowGroup();

    callback();

    _restoreExpandedRowGroup();
  }

  void _collapseAllRowGroup() {
    refRows.removeWhereFromOriginal(isNotMainGroupedRow);
  }

  void _restoreExpandedRowGroup({bool resetCurrentState = false}) {
    final Iterable<TrinaRow> expandedRows = refRows.filterOrOriginalList
        .where(isExpandedGroupedRow)
        .toList(growable: false);

    bool toResetPage = false;

    if (isPaginated) {
      refRows.setFilterRange(null);
      toResetPage = true;
    }

    for (final rowGroup in expandedRows) {
      final Iterable<TrinaRow> children = TrinaRowGroupHelper.iterateWithFilter(
        rowGroup.type.group.children,
        filter: (r) => true,
        childrenFilter: (r) => r.type.isGroup && r.type.group.expanded
            ? r.type.group.children.iterator
            : null,
      );

      final idx = refRows.filterOrOriginalList.indexOf(rowGroup);

      refRows.insertAll(idx + 1, children);
    }

    if (toResetPage) {
      resetPage(resetCurrentState: resetCurrentState, notify: false);
    }
  }

  void _updateCellsByTargetForGroupByColumn({
    required List<TrinaRow> rows,
    required TrinaRow? target,
  }) {
    if (target == null) {
      return;
    }

    assert(rowGroupDelegate is TrinaRowGroupByColumnDelegate);

    final delegate = rowGroupDelegate as TrinaRowGroupByColumnDelegate;

    final depth = target.depth;

    final groupedColumn = delegate.columns.getRange(0, depth);

    for (final row in rows) {
      for (final column in groupedColumn) {
        row.cells[column.field]!.value = target.cells[column.field]!.value;
      }
    }
  }

  void _updateRowGroup() {
    assert(hasRowGroups);

    List<TrinaRow> rows;

    final previousRows = _previousEnabledRowGroups
        ? _iterateRow(iterateAllMainRowGroup)
        : refRows.originalList;

    if (enabledRowGroups == true) {
      rows = rowGroupDelegate!.toGroup(rows: previousRows);
    } else {
      // todo : reset sortIdx
      rows = previousRows.toList();
      setParent(TrinaRow e) => e.setParent(null);
      rows.forEach(setParent);
    }

    _state._previousEnabledRowGroups = enabledRowGroups;

    refRows.clearFromOriginal();

    refRows.addAll(rows);

    if (enabledRowGroups) {
      _restoreExpandedRowGroup(resetCurrentState: true);
    } else if (isPaginated) {
      resetPage(resetCurrentState: true, notify: false);
    }
  }

  Iterable<TrinaRow> _iterateRow(
    Iterable<TrinaRow> rows, {
    bool iterateAll = true,
  }) sync* {
    bool isNotGroup(TrinaRow e) => !e.type.isGroup;

    for (final row in TrinaRowGroupHelper.iterateWithFilter(
      rows,
      filter: isNotGroup,
      iterateAll: iterateAll,
    )) {
      yield row;
    }
  }

  Iterable<TrinaRow> _iterateRowGroup(
    Iterable<TrinaRow> rows, {
    bool iterateAll = true,
  }) sync* {
    bool isGroup(TrinaRow e) => e.type.isGroup;

    for (final row in TrinaRowGroupHelper.iterateWithFilter(
      rows,
      filter: isGroup,
      iterateAll: iterateAll,
    )) {
      yield row;
    }
  }

  Iterable<TrinaRow> _iterateRowAndGroup(
    Iterable<TrinaRow> rows, {
    bool iterateAll = true,
  }) sync* {
    for (final row in TrinaRowGroupHelper.iterateWithFilter(
      rows,
      iterateAll: iterateAll,
    )) {
      yield row;
    }
  }
}
