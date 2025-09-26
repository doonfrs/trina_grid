import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:trina_grid/trina_grid.dart';

/// {@template trina_row_group_delegate_type}
/// Determines the grouping type of the row.
///
/// [tree] groups rows into an unformatted tree.
///
/// [byColumn] groups rows by a specified column.
/// {@endtemplate}
enum TrinaRowGroupDelegateType {
  tree,
  byColumn;

  bool get isTree => this == TrinaRowGroupDelegateType.tree;

  bool get isByColumn => this == TrinaRowGroupDelegateType.byColumn;
}

/// {@template trina_row_group_on_toggled}
/// A callback that is called when a group row is expanded or collapsed.
///
/// For [row], [row.type] is a group.
/// You can access the parent row with [row.parent].
/// You can access child rows with [row.group.children].
///
/// If [expanded] is true, the group row is expanded, if false, it is collapsed.
/// {@endtemplate}
typedef TrinaRowGroupOnToggled =
    void Function({required TrinaRow row, required bool expanded});

/// Abstract class that defines a base interface for grouping rows.
///
/// [TrinaRowGroupTreeDelegate] or [TrinaRowGroupByColumnDelegate]
/// class implements this abstract class.
abstract class TrinaRowGroupDelegate {
  TrinaRowGroupDelegate({this.onToggled});

  final countFormat = NumberFormat.compact();

  /// {@macro trina_row_group_on_toggled}
  final TrinaRowGroupOnToggled? onToggled;

  /// {@macro trina_row_group_delegate_type}
  TrinaRowGroupDelegateType get type;

  /// {@template trina_row_group_delegate_enabled}
  /// Returns whether the grouping function is activated.
  ///
  /// It is enabled by default,
  /// In the case of [TrinaRowGroupDelegateType.byColumn],
  /// the column is hidden and temporarily deactivated when there is no column to group.
  /// {@endtemplate}
  bool get enabled;

  /// {@template trina_row_group_delegate_showCount}
  /// Decide whether to display the number of child rows in the cell
  /// where the expand icon is displayed in the grouped state.
  /// {@endtemplate}
  bool get showCount;

  /// {@template trina_row_group_delegate_enableCompactCount}
  /// Decide whether to simply display the number of child rows when [showCount] is true.
  ///
  /// ex) 1,234,567 > 1.2M
  /// {@endtemplate}
  bool get enableCompactCount;

  /// {@template trina_row_group_delegate_showFirstExpandableIon}
  /// Decide whether to force the expand button to be displayed in the first cell.
  /// {@endtemplate}
  bool get showFirstExpandableIcon;

  /// {@template trina_row_group_delegate_isEditableCell}
  /// Determines whether the cell is editable.
  /// {@endtemplate}
  bool isEditableCell(TrinaCell cell);

  /// {@template trina_row_group_delegate_isExpandableCell}
  /// Decide whether to show the extended button.
  /// {@endtemplate}
  bool isExpandableCell(TrinaCell cell);

  /// {@template trina_row_group_delegate_toGroup}
  /// Handling for grouping rows.
  /// {@endtemplate}
  List<TrinaRow> toGroup({required Iterable<TrinaRow> rows});

  /// {@template trina_row_group_delegate_sort}
  /// Handle sorting of grouped rows.
  /// {@endtemplate}
  void sort({
    required TrinaColumn column,
    required FilteredList<TrinaRow> rows,
    required int Function(TrinaRow, TrinaRow) compare,
  });

  /// {@template trina_row_group_delegate_filter}
  /// Handle filtering of grouped rows.
  /// {@endtemplate}
  void filter({
    required FilteredList<TrinaRow> rows,
    required FilteredListFilter<TrinaRow>? filter,
  });

  /// {@template trina_row_group_delegate_compactNumber}
  /// Brief summary of numbers.
  /// {@endtemplate}
  String compactNumber(num count) {
    return countFormat.format(count);
  }
}

class TrinaRowGroupTreeDelegate extends TrinaRowGroupDelegate {
  /// Determine the depth based on the cell column.
  ///
  /// ```dart
  /// // Determine the depth according to the column order.
  /// resolveColumnDepth: (column) => stateManager.columnIndex(column),
  /// ```
  final int? Function(TrinaColumn column) resolveColumnDepth;

  /// Decide whether to display the text in the cell.
  ///
  /// ```dart
  /// // Display the text in all cells.
  /// showText: (cell) => true,
  /// ```
  final bool Function(TrinaCell cell) showText;

  /// {@macro trina_row_group_delegate_showFirstExpandableIon}
  @override
  final bool showFirstExpandableIcon;

  /// {@macro trina_row_group_delegate_showCount}
  @override
  final bool showCount;

  /// {@macro trina_row_group_delegate_enableCompactCount}
  @override
  final bool enableCompactCount;

  TrinaRowGroupTreeDelegate({
    required this.resolveColumnDepth,
    required this.showText,
    this.showFirstExpandableIcon = false,
    this.showCount = true,
    this.enableCompactCount = true,
    super.onToggled,
  });

  /// {@macro trina_row_group_delegate_type}
  @override
  TrinaRowGroupDelegateType get type => TrinaRowGroupDelegateType.tree;

  /// {@macro trina_row_group_delegate_enabled}
  @override
  bool get enabled => true;

  /// {@macro trina_row_group_delegate_isEditableCell}
  @override
  bool isEditableCell(TrinaCell cell) => showText(cell);

  /// {@macro trina_row_group_delegate_isExpandableCell}
  @override
  bool isExpandableCell(TrinaCell cell) {
    if (!cell.row.type.isGroup) return false;
    final int checkDepth = showFirstExpandableIcon ? 0 : cell.row.depth;
    return cell.row.type.isGroup &&
        resolveColumnDepth(cell.column) == checkDepth;
  }

  /// {@macro trina_row_group_delegate_toGroup}
  @override
  List<TrinaRow> toGroup({required Iterable<TrinaRow> rows}) {
    if (rows.isEmpty) return rows.toList();

    final children = TrinaRowGroupHelper.iterateWithFilter(
      rows,
      filter: (r) => r.type.isGroup,
    );

    for (final child in children) {
      setParent(TrinaRow r) => r.setParent(child);
      child.type.group.children.originalList.forEach(setParent);
    }

    return rows.toList();
  }

  /// {@macro trina_row_group_delegate_sort}
  @override
  void sort({
    required TrinaColumn column,
    required FilteredList<TrinaRow> rows,
    required int Function(TrinaRow, TrinaRow) compare,
  }) {
    if (rows.originalList.isEmpty) return;

    rows.sort(compare);

    final children = TrinaRowGroupHelper.iterateWithFilter(
      rows.originalList,
      filter: (r) => r.type.isGroup,
    );

    for (final child in children) {
      child.type.group.children.sort(compare);
    }
  }

  /// {@macro trina_row_group_delegate_filter}
  @override
  void filter({
    required FilteredList<TrinaRow> rows,
    required FilteredListFilter<TrinaRow>? filter,
  }) {
    if (rows.originalList.isEmpty) return;

    TrinaRowGroupHelper.applyFilter(rows: rows, filter: filter);
  }
}

class TrinaRowGroupByColumnDelegate extends TrinaRowGroupDelegate {
  /// Column to group by.
  final List<TrinaColumn> columns;

  /// {@macro trina_row_group_delegate_showFirstExpandableIon}
  @override
  final bool showFirstExpandableIcon;

  /// {@macro trina_row_group_delegate_showCount}
  @override
  final bool showCount;

  /// {@macro trina_row_group_delegate_enableCompactCount}
  @override
  final bool enableCompactCount;

  TrinaRowGroupByColumnDelegate({
    required this.columns,
    this.showFirstExpandableIcon = false,
    this.showCount = true,
    this.enableCompactCount = true,
    super.onToggled,
  });

  /// {@macro trina_row_group_delegate_type}
  @override
  TrinaRowGroupDelegateType get type => TrinaRowGroupDelegateType.byColumn;

  /// {@macro trina_row_group_delegate_enabled}
  @override
  bool get enabled => visibleColumns.isNotEmpty;

  /// Returns a non-hidden column from the column to be grouped.
  List<TrinaColumn> get visibleColumns =>
      columns.where((e) => !e.hide).toList();

  /// {@macro trina_row_group_delegate_isEditableCell}
  @override
  bool isEditableCell(TrinaCell cell) =>
      cell.row.type.isNormal && !isRowGroupColumn(cell.column);

  /// {@macro trina_row_group_delegate_isExpandableCell}
  @override
  bool isExpandableCell(TrinaCell cell) {
    if (cell.row.type.isNormal) return false;
    final int checkDepth = showFirstExpandableIcon ? 0 : cell.row.depth;
    return _columnDepth(cell.column) == checkDepth;
  }

  /// Returns whether the column is a grouping column.
  bool isRowGroupColumn(TrinaColumn column) {
    return visibleColumns.firstWhereOrNull((e) => e.field == column.field) !=
        null;
  }

  /// {@macro trina_row_group_delegate_toGroup}
  @override
  List<TrinaRow> toGroup({required Iterable<TrinaRow> rows}) {
    if (rows.isEmpty) return rows.toList();
    assert(visibleColumns.isNotEmpty);

    final List<TrinaRow> groups = [];
    final List<List<TrinaRow>> groupStack = [];
    final List<TrinaRow> parentStack = [];
    final List<String> groupFields = visibleColumns
        .map((e) => e.field)
        .toList();
    final List<String> groupKeyStack = [];
    final maxDepth = groupFields.length;

    List<TrinaRow>? currentGroups = groups;
    TrinaRow? currentParent;
    int depth = 0;
    int sortIdx = 0;
    List<Iterator<MapEntry<String, List<TrinaRow>>>> stack = [];
    Iterator<MapEntry<String, List<TrinaRow>>>? currentIter;
    currentIter = groupBy<TrinaRow, String>(
      rows,
      (r) => r.cells[groupFields[depth]]!.value.toString(),
    ).entries.iterator;

    while (currentIter != null || stack.isNotEmpty) {
      if (currentIter != null && depth < maxDepth && currentIter.moveNext()) {
        groupKeyStack.add(currentIter.current.key);
        final groupKeys = [
          visibleColumns[depth].field,
          groupKeyStack.join('_'),
          'rowGroup',
        ];

        final row = _createRowGroup(
          groupKeys: groupKeys,
          sortIdx: ++sortIdx,
          sampleRow: currentIter.current.value.first,
        );

        currentParent = parentStack.lastOrNull;
        if (currentParent != null) row.setParent(currentParent);

        parentStack.add(row);
        currentGroups!.add(row);
        stack.add(currentIter);
        groupStack.add(currentGroups);
        currentGroups = row.type.group.children;

        if (depth + 1 < maxDepth) {
          currentIter = groupBy<TrinaRow, String>(
            currentIter.current.value,
            (r) => r.cells[groupFields[depth + 1]]!.value.toString(),
          ).entries.iterator;
        }

        ++depth;
      } else {
        --depth;
        if (depth < 0) break;

        groupKeyStack.removeLast();
        currentParent = parentStack.lastOrNull;
        if (currentParent != null) parentStack.removeLast();
        currentIter = stack.lastOrNull;
        if (currentIter != null) stack.removeLast();

        if (depth + 1 == maxDepth) {
          int sortIdx = 0;
          for (final child in currentIter!.current.value) {
            currentGroups!.add(child);
            child.setParent(currentParent);
            child.sortIdx = ++sortIdx;
          }
        }

        currentGroups = groupStack.lastOrNull;
        if (currentGroups != null) groupStack.removeLast();
      }

      if (depth == 0) groupKeyStack.clear();
    }

    return groups;
  }

  /// {@macro trina_row_group_delegate_sort}
  @override
  void sort({
    required TrinaColumn column,
    required FilteredList<TrinaRow> rows,
    required int Function(TrinaRow, TrinaRow) compare,
  }) {
    if (rows.originalList.isEmpty) return;

    final depth = _columnDepth(column);

    if (depth == 0) {
      rows.sort(compare);
      return;
    }

    final children = TrinaRowGroupHelper.iterateWithFilter(
      rows.originalList,
      filter: (r) => r.type.isGroup,
      childrenFilter: (r) => _isFirstChildGroup(r)
          ? r.type.group.children.originalList.iterator
          : null,
    );

    for (final child in children) {
      if (_firstChildDepth(child) == depth) {
        child.type.group.children.sort(compare);
      }
    }
  }

  /// {@macro trina_row_group_delegate_filter}
  @override
  void filter({
    required FilteredList<TrinaRow> rows,
    required FilteredListFilter<TrinaRow>? filter,
  }) {
    if (rows.originalList.isEmpty) return;

    TrinaRowGroupHelper.applyFilter(rows: rows, filter: filter);
  }

  int _columnDepth(TrinaColumn column) => visibleColumns.indexOf(column);

  int _firstChildDepth(TrinaRow row) {
    if (!row.type.group.children.originalList.first.type.isGroup) {
      return -1;
    }

    return row.type.group.children.originalList.first.depth;
  }

  bool _isFirstChildGroup(TrinaRow row) {
    return row.type.group.children.originalList.first.type.isGroup;
  }

  TrinaRow _createRowGroup({
    required List<String> groupKeys,
    required int sortIdx,
    required TrinaRow sampleRow,
  }) {
    final cells = <String, TrinaCell>{};

    final groupKey = groupKeys.join('_');

    final row = TrinaRow(
      key: ValueKey(groupKey),
      cells: cells,
      sortIdx: sortIdx,
      type: TrinaRowType.group(children: FilteredList(initialList: [])),
    );

    for (var e in sampleRow.cells.entries) {
      cells[e.key] =
          TrinaCell(
              value:
                  visibleColumns.firstWhereOrNull((c) => c.field == e.key) !=
                      null
                  ? e.value.value
                  : null,
              key: ValueKey('${groupKey}_${e.key}_cell'),
            )
            ..setColumn(e.value.column)
            ..setRow(row);
    }

    return row;
  }
}
