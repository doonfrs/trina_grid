import 'package:flutter/material.dart';
import 'package:trina_grid/trina_grid.dart';

enum TrinaRowFrozen { none, start, end }

class TrinaRow<T> {
  TrinaRow({
    required this.cells,
    TrinaRowType? type,
    this.sortIdx = 0,
    this.data,
    bool checked = false,
    Key? key,
    TrinaRowFrozen? frozen,
    this.height,
  }) : type = type ?? TrinaRowTypeNormal.instance,
       _checked = checked,
       _state = TrinaRowState.none,
       _key = key ?? UniqueKey(),
       frozen = frozen ?? TrinaRowFrozen.none;

  final TrinaRowType type;

  final Key _key;

  T? data;

  /// Indicates if the row should be frozen at the top or bottom of the grid
  /// TrinaRowFrozen.none means the row is not frozen
  /// TrinaRowFrozen.start means the row is frozen at the top
  /// TrinaRowFrozen.end means the row is frozen at the bottom
  final TrinaRowFrozen frozen;

  /// Custom height for this specific row
  /// If null, uses the global rowHeight from configuration
  final double? height;

  Map<String, TrinaCell> cells;

  /// Value to maintain the default sort order when sorting columns.
  /// If there is no value, it is automatically set when loading the grid.
  int sortIdx;

  bool? _checked;

  bool? _checkedViaSelect;

  TrinaRow? _parent;

  TrinaRowState _state;

  /// Version number that increments when any cell value in this row changes.
  /// Used by cell renderer caching to detect cross-cell dependencies.
  int _version = 0;

  Key get key => _key;

  /// Get the current row version for cache invalidation.
  int get version => _version;

  /// Increment the row version (called when any cell changes).
  void incrementVersion() => _version++;

  bool get initialized {
    if (cells.isEmpty) {
      return true;
    }

    return cells.values.first.initialized;
  }

  /// If [TrinaRow] is included as a child of a group row,
  /// [parent] is the parent's reference.
  TrinaRow? get parent => _parent;

  /// Returns the depth if [TrinaRow] is a child of a group row.
  int get depth {
    int depth = 0;
    var current = parent;
    while (current != null) {
      depth += 1;
      current = current.parent;
    }
    return depth;
  }

  /// Returns whether [TrinaRow] is the top position.
  bool get isMain => parent == null;

  /// The state value that the checkbox is checked.
  /// If the enableRowChecked value of the [TrinaColumn] property is set to true,
  /// a check box appears in the cell of the corresponding column.
  /// To manually change the values at runtime,
  /// use the TrinaStateManager.setRowChecked
  /// or TrinaStateManager.toggleAllRowChecked methods.
  bool? get checked {
    return type.isGroup ? _tristateCheckedRow : _checked;
  }

  bool get checkedViaSelect {
    return (checked ?? false) && (_checkedViaSelect ?? false);
  }

  bool? get _tristateCheckedRow {
    if (!type.isGroup) return false;

    final children = type.group.children;

    final length = children.length;

    if (length == 0) return _checked;

    int countTrue = 0;

    int countFalse = 0;

    int countTristate = 0;

    for (var i = 0; i < length; i += 1) {
      if (children[i].type.isGroup) {
        switch (children[i]._tristateCheckedRow) {
          case true:
            ++countTrue;
            break;
          case false:
            ++countFalse;
            break;
          case null:
            ++countTristate;
            break;
        }
      } else {
        children[i].checked == true ? ++countTrue : ++countFalse;
      }

      if ((countTrue > 0 && countFalse > 0) || countTristate > 0) return null;
    }

    return countTrue == length;
  }

  /// State when a new row is added or the cell value in the row is changed.
  ///
  /// Keeps the row from disappearing when changing the cell value
  /// to a value other than the filtering condition while column filtering is applied.
  /// When the value of a cell is changed,
  /// the [state] value of the changed row is changed to [TrinaRowState.updated],
  /// and in this case, even if the filtering condition is not
  /// Make sure it stays in the list unless you change the filtering again.
  TrinaRowState get state => _state;

  void setParent(TrinaRow? row) {
    _parent = row;
  }

  void setData(T data) => this.data = data;

  void setChecked(bool? flag, {bool viaSelect = false}) {
    _checked = flag;
    _checkedViaSelect = viaSelect;
    if (type.isGroup) {
      for (final child in type.group.children) {
        child.setChecked(flag);
      }
    }
  }

  void setState(TrinaRowState state) {
    _state = state;
  }

  /// Create TrinaRow in json type.
  /// The key of the json you want to generate must match the key of [TrinaColumn].
  ///
  /// ```dart
  /// final json = {
  ///   'column1': 'value1',
  ///   'column2': 'value2',
  ///   'column3': 'value3',
  /// };
  ///
  /// final row = TrinaRow.fromJson(json);
  /// ```
  ///
  /// If you want to create a group row with children, you need to pass [childrenField] .
  ///
  /// ```dart
  /// // Example when the child row field is children
  /// final json = {
  ///   'column1': 'group value1',
  ///   'column2': 'group value2',
  ///   'column3': 'group value3',
  ///   'children': [
  ///     {
  ///       'column1': 'child1 value1',
  ///       'column2': 'child1 value2',
  ///       'column3': 'child1 value3',
  ///     },
  ///     {
  ///       'column1': 'child2 value1',
  ///       'column2': 'child2 value2',
  ///       'column3': 'child2 value3',
  ///     },
  ///   ],
  /// };
  ///
  /// final rowGroup = TrinaRow.fromJson(json, childrenField: 'children');
  /// ```
  factory TrinaRow.fromJson(
    Map<String, dynamic> json, {
    String? childrenField,
  }) {
    final Map<String, TrinaCell> cells = {};

    final bool hasChildren =
        childrenField != null && json.containsKey(childrenField);

    final entries = hasChildren
        ? json.entries.where((e) => e.key != childrenField)
        : json.entries;

    assert(!hasChildren || json.length - 1 == entries.length);

    for (final item in entries) {
      cells[item.key] = TrinaCell(value: item.value);
    }

    TrinaRowType? type;

    if (hasChildren) {
      assert(json[childrenField] is List<Map<String, dynamic>>);

      final children = <TrinaRow>[];

      for (final child in json[childrenField]) {
        children.add(TrinaRow.fromJson(child, childrenField: childrenField));
      }

      type = TrinaRowType.group(children: FilteredList(initialList: children));
    }

    return TrinaRow(cells: cells, type: type);
  }

  /// Convert the row to json type.
  ///
  /// ```dart
  /// // Assuming you have a line like below.
  /// final TrinaRow row = TrinaRow(cells: {
  ///   'column1': TrinaCell(value: 'value1'),
  ///   'column2': TrinaCell(value: 'value2'),
  ///   'column3': TrinaCell(value: 'value3'),
  /// });
  ///
  /// final json = row.toJson();
  /// // toJson is returned as below.
  /// // {
  /// //   'column1': 'value1',
  /// //   'column2': 'value2',
  /// //   'column3': 'value3',
  /// // }
  /// ```
  ///
  /// In case of group row, [includeChildren] is true (default)
  /// If [childrenField] is set to 'children' (default), the following is returned.
  ///
  /// ```dart
  /// // Assuming you have rows grouped by 1 depth.
  /// final TrinaRow row = TrinaRow(
  ///   cells: {
  ///     'column1': TrinaCell(value: 'group value1'),
  ///     'column2': TrinaCell(value: 'group value2'),
  ///     'column3': TrinaCell(value: 'group value3'),
  ///   },
  ///   type: TrinaRowType.group(
  ///     children: FilteredList(initialList: [
  ///       TrinaRow(
  ///         cells: {
  ///           'column1': TrinaCell(value: 'child1 value1'),
  ///           'column2': TrinaCell(value: 'child1 value2'),
  ///           'column3': TrinaCell(value: 'child1 value3'),
  ///         },
  ///       ),
  ///       TrinaRow(
  ///         cells: {
  ///           'column1': TrinaCell(value: 'child2 value1'),
  ///           'column2': TrinaCell(value: 'child2 value2'),
  ///           'column3': TrinaCell(value: 'child2 value3'),
  ///         },
  ///       ),
  ///     ]),
  ///   ),
  /// );
  ///
  /// final json = row.toJson();
  /// // It is returned in the following format.
  /// // {
  /// //   'column1': 'group value1',
  /// //   'column2': 'group value2',
  /// //   'column3': 'group value3',
  /// //   'children': [
  /// //     {
  /// //       'column1': 'child1 value1',
  /// //       'column2': 'child1 value2',
  /// //       'column3': 'child1 value3',
  /// //     },
  /// //     {
  /// //       'child1': 'child2 value1',
  /// //       'column2': 'child2 value2',
  /// //       'column3': 'child2 value3',
  /// //     },
  /// //   ],
  /// // }
  /// ```
  Map<String, dynamic> toJson({
    bool includeChildren = true,
    String childrenField = 'children',
  }) {
    final json = cells.map((key, value) => MapEntry(key, value.value));

    if (!includeChildren || !type.isGroup) return json;

    final List<Map<String, dynamic>> children = type.group.children
        .map((e) => e.toJson(childrenField: childrenField))
        .toList();

    json[childrenField] = children;

    return json;
  }
}

enum TrinaRowState {
  none,
  added,
  updated;

  bool get isNone => this == TrinaRowState.none;

  bool get isAdded => this == TrinaRowState.added;

  bool get isUpdated => this == TrinaRowState.updated;
}
