import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:trina_grid/trina_grid.dart';

import 'ui.dart';

class TrinaLeftFrozenColumnsFooter extends TrinaStatefulWidget {
  final TrinaGridStateManager stateManager;

  const TrinaLeftFrozenColumnsFooter(this.stateManager, {super.key});

  @override
  TrinaLeftFrozenColumnsFooterState createState() =>
      TrinaLeftFrozenColumnsFooterState();
}

class TrinaLeftFrozenColumnsFooterState
    extends TrinaStateWithChange<TrinaLeftFrozenColumnsFooter> {
  List<TrinaColumn> _columns = [];

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
    _columns = update<List<TrinaColumn>>(
      _columns,
      stateManager.leftFrozenColumns,
      compare: listEquals,
    );

    _itemCount = update<int>(_itemCount, _columns.length);
  }

  Widget _makeColumn(TrinaColumn e) {
    return LayoutId(
      id: e.field,
      child: TrinaBaseColumnFooter(stateManager: stateManager, column: e),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomMultiChildLayout(
      delegate: ColumnFooterLayoutDelegate(
        stateManager: stateManager,
        columns: _columns,
        textDirection: stateManager.textDirection,
      ),
      children: _columns.map(_makeColumn).toList(growable: false),
    );
  }
}
