import 'package:collection/collection.dart';
import 'package:trina_grid/trina_grid.dart';

/// Helper class for grouping rows.
class TrinaRowGroupHelper {
  /// Traversing the group rows of [rows] according to the [filter] condition.
  ///
  /// If [childrenFilter] is passed, the traversal condition of child rows is applied.
  ///
  /// If [iterateAll] is true,
  /// the filtering condition applied to the child row of each group is ignored and
  /// Iterate through the entire row.
  static Iterable<TrinaRow> iterateWithFilter(
    Iterable<TrinaRow> rows, {
    bool Function(TrinaRow)? filter,
    Iterator<TrinaRow>? Function(TrinaRow)? childrenFilter,
    bool iterateAll = true,
  }) sync* {
    if (rows.isEmpty) return;

    final List<Iterator<TrinaRow>> stack = [];

    Iterator<TrinaRow>? currentIter = rows.iterator;

    Iterator<TrinaRow>? defaultChildrenFilter(TrinaRow row) {
      return row.type.isGroup
          ? iterateAll
                ? row.type.group.children.originalList.iterator
                : row.type.group.children.iterator
          : null;
    }

    final filterChildren = childrenFilter ?? defaultChildrenFilter;

    while (currentIter != null || stack.isNotEmpty) {
      bool hasChildren = false;

      if (currentIter != null) {
        while (currentIter!.moveNext()) {
          if (filter == null || filter(currentIter.current)) {
            yield currentIter.current;
          }

          final Iterator<TrinaRow>? children = filterChildren(
            currentIter.current,
          );

          if (children != null) {
            stack.add(currentIter);
            currentIter = children;
            hasChildren = true;
            break;
          }
        }
      }

      if (!hasChildren) {
        currentIter = stack.lastOrNull;
        if (currentIter != null) stack.removeLast();
      }
    }
  }

  /// Apply [filter] condition to all groups in [rows].
  static void applyFilter({
    required FilteredList<TrinaRow> rows,
    required FilteredListFilter<TrinaRow>? filter,
  }) {
    if (rows.originalList.isEmpty) return;

    isGroup(TrinaRow row) => row.type.isGroup;

    if (filter == null) {
      rows.setFilter(null);

      final children = TrinaRowGroupHelper.iterateWithFilter(
        rows.originalList,
        filter: isGroup,
      );

      for (final child in children) {
        child.type.group.children.setFilter(null);
      }
    } else {
      isNotEmptyGroup(TrinaRow row) =>
          row.type.isGroup &&
          row.type.group.children.filterOrOriginalList.isNotEmpty;

      filterOrHasChildren(TrinaRow row) => filter(row) || isNotEmptyGroup(row);

      final children = TrinaRowGroupHelper.iterateWithFilter(
        rows.originalList,
        filter: isGroup,
      );

      for (final child in children.toList().reversed) {
        child.type.group.children.setFilter(filterOrHasChildren);
      }

      rows.setFilter(filterOrHasChildren);
    }
  }
}
