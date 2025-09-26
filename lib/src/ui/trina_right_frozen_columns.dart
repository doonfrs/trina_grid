import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:trina_grid/trina_grid.dart';

import 'ui.dart';

class TrinaRightFrozenColumns extends TrinaStatefulWidget {
  final TrinaGridStateManager stateManager;

  const TrinaRightFrozenColumns(this.stateManager, {super.key});

  @override
  TrinaRightFrozenColumnsState createState() => TrinaRightFrozenColumnsState();
}

class TrinaRightFrozenColumnsState
    extends TrinaStateWithChange<TrinaRightFrozenColumns> {
  List<TrinaColumn> _columns = [];

  List<TrinaColumnGroupPair> _columnGroups = [];

  bool _showColumnGroups = false;

  int _itemCount = 0;

  @override
  TrinaGridStateManager get stateManager => widget.stateManager;

  @override
  void initState() {
    super.initState();

    updateState(TrinaNotifierEventForceUpdate.instance);
  }

  @override
  void updateState(TrinaNotifierEvent event) {
    _showColumnGroups = update<bool>(
      _showColumnGroups,
      stateManager.showColumnGroups,
    );

    _columns = update<List<TrinaColumn>>(
      _columns,
      stateManager.rightFrozenColumns,
      compare: listEquals,
    );

    _columnGroups = update<List<TrinaColumnGroupPair>>(
      _columnGroups,
      stateManager.separateLinkedGroup(
        columnGroupList: stateManager.refColumnGroups,
        columns: _columns,
      ),
    );

    _itemCount = update<int>(_itemCount, _getItemCount());
  }

  int _getItemCount() {
    return _showColumnGroups == true ? _columnGroups.length : _columns.length;
  }

  Widget _makeColumnGroup(TrinaColumnGroupPair e) {
    return LayoutId(
      id: e.key,
      child: TrinaBaseColumnGroup(
        stateManager: stateManager,
        columnGroup: e,
        depth: stateManager.columnGroupDepth(stateManager.refColumnGroups),
      ),
    );
  }

  Widget _makeColumn(TrinaColumn e) {
    return LayoutId(
      id: e.field,
      child: TrinaBaseColumn(stateManager: stateManager, column: e),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomMultiChildLayout(
      delegate: MainColumnLayoutDelegate(
        stateManager: stateManager,
        columns: _columns,
        columnGroups: _columnGroups,
        frozen: TrinaColumnFrozen.end,
        textDirection: stateManager.textDirection,
      ),
      children: _showColumnGroups == true
          ? _columnGroups.map(_makeColumnGroup).toList(growable: false)
          : _columns.map(_makeColumn).toList(growable: false),
    );
  }
}
