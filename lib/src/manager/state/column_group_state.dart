import 'package:flutter/cupertino.dart';
import 'package:trina_grid/trina_grid.dart';

abstract class IColumnGroupState {
  List<TrinaColumnGroup> get columnGroups;

  FilteredList<TrinaColumnGroup> get refColumnGroups;

  bool get hasColumnGroups;

  bool get showColumnGroups;

  void setShowColumnGroups(bool flag, {bool notify = true});

  List<TrinaColumnGroupPair> separateLinkedGroup({
    required List<TrinaColumnGroup> columnGroupList,
    required List<TrinaColumn> columns,
  });

  int columnGroupDepth(List<TrinaColumnGroup> groups);

  void removeColumnsInColumnGroup(
    List<TrinaColumn> columns, {
    bool notify = true,
  });

  @protected
  void setGroupToColumn();
}

class _State {
  bool _showColumnGroups = false;
}

mixin ColumnGroupState implements ITrinaGridState {
  final _State _state = _State();

  @override
  List<TrinaColumnGroup> get columnGroups => [...refColumnGroups];

  @override
  bool get hasColumnGroups => refColumnGroups.isNotEmpty;

  @override
  bool get showColumnGroups =>
      _state._showColumnGroups == true && hasColumnGroups;

  @override
  void setShowColumnGroups(bool flag, {bool notify = true}) {
    if (showColumnGroups == flag) {
      return;
    }

    _state._showColumnGroups = flag;

    notifyListeners(notify, setShowColumnGroups.hashCode);
  }

  @override
  List<TrinaColumnGroupPair> separateLinkedGroup({
    required List<TrinaColumnGroup> columnGroupList,
    required List<TrinaColumn> columns,
  }) {
    return TrinaColumnGroupHelper.separateLinkedGroup(
      columnGroupList: columnGroupList,
      columns: columns,
    );
  }

  @override
  int columnGroupDepth(List<TrinaColumnGroup> columnGroupList) {
    return TrinaColumnGroupHelper.maxDepth(columnGroupList: columnGroupList);
  }

  @override
  void removeColumnsInColumnGroup(
    List<TrinaColumn> columns, {
    bool notify = true,
  }) {
    if (refColumnGroups.originalList.isEmpty == true) {
      return;
    }

    final Set<String> columnFields = Set.from(columns.map((e) => e.field));

    refColumnGroups.removeWhereFromOriginal((group) {
      return _emptyGroupAfterRemoveColumns(
        columnGroup: group,
        columnFields: columnFields,
      );
    });

    notifyListeners(notify, removeColumnsInColumnGroup.hashCode);
  }

  @override
  @protected
  void setGroupToColumn() {
    if (hasColumnGroups == false) {
      return;
    }

    for (final column in refColumns.originalList) {
      column.group = TrinaColumnGroupHelper.getParentGroupIfExistsFromList(
        field: column.field,
        columnGroupList: refColumnGroups,
      );
    }
  }

  bool _emptyGroupAfterRemoveColumns({
    required TrinaColumnGroup columnGroup,
    required Set<String> columnFields,
  }) {
    if (columnGroup.hasFields) {
      columnGroup.fields!.removeWhere((field) => columnFields.contains(field));
    } else if (columnGroup.hasChildren) {
      columnGroup.children!.removeWhere((child) {
        return _emptyGroupAfterRemoveColumns(
          columnGroup: child,
          columnFields: columnFields,
        );
      });
    }

    return (columnGroup.hasFields && columnGroup.fields!.isEmpty) ||
        (columnGroup.hasChildren && columnGroup.children!.isEmpty);
  }
}
