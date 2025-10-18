import 'package:flutter/material.dart';
import 'package:trina_grid/trina_grid.dart';

import 'ui.dart';

class TrinaLeftFrozenRows extends TrinaStatefulWidget {
  final TrinaGridStateManager stateManager;

  const TrinaLeftFrozenRows(this.stateManager, {super.key});

  @override
  TrinaLeftFrozenRowsState createState() => TrinaLeftFrozenRowsState();
}

class TrinaLeftFrozenRowsState
    extends TrinaStateWithChange<TrinaLeftFrozenRows> {
  List<TrinaColumn> _columns = [];

  List<TrinaRow> _rows = [];
  List<TrinaRow> _frozenTopRows = [];
  List<TrinaRow> _frozenBottomRows = [];
  List<TrinaRow> _scrollableRows = [];

  late final ScrollController _scroll;

  @override
  TrinaGridStateManager get stateManager => widget.stateManager;

  @override
  void initState() {
    super.initState();

    _scroll = stateManager.scroll.vertical!.addAndGet();

    updateState(TrinaNotifierEventForceUpdate.instance);
  }

  @override
  void dispose() {
    _scroll.dispose();

    super.dispose();
  }

  @override
  void updateState(TrinaNotifierEvent event) {
    forceUpdate();

    _columns = stateManager.leftFrozenColumns;

    // Get all rows
    _rows = stateManager.refRows;

    // Separate frozen rows from scrollable rows
    _frozenTopRows = stateManager.refRows.originalList
        .where((row) => row.frozen == TrinaRowFrozen.start)
        .toList();
    _frozenBottomRows = stateManager.refRows.originalList
        .where((row) => row.frozen == TrinaRowFrozen.end)
        .toList();
    _scrollableRows = _rows
        .where((row) => row.frozen == TrinaRowFrozen.none)
        .toList();
  }

  Widget _buildRow(BuildContext context, TrinaRow row, int index) {
    Widget rowWidget = TrinaBaseRow(
      key: ValueKey('left_frozen_row_${row.key}'),
      rowIdx: index,
      row: row,
      columns: _columns,
      stateManager: stateManager,
      visibilityLayout: true,
    );

    return stateManager.rowWrapper?.call(
          context,
          rowWidget,
          row,
          stateManager,
        ) ??
        rowWidget;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Frozen top rows
        if (_frozenTopRows.isNotEmpty)
          Column(
            children: _frozenTopRows
                .asMap()
                .entries
                .map((e) => _buildRow(context, e.value, e.key))
                .toList(),
          ),
        // Scrollable rows
        Expanded(
          child: ListView.builder(
            controller: _scroll,
            scrollDirection: Axis.vertical,
            physics: const ClampingScrollPhysics(),
            itemCount: _scrollableRows.length,
            // Remove fixed itemExtent for variable heights
            itemBuilder: (ctx, i) =>
                _buildRow(ctx, _scrollableRows[i], i + _frozenTopRows.length),
          ),
        ),
        // Frozen bottom rows
        if (_frozenBottomRows.isNotEmpty)
          Column(
            children: _frozenBottomRows
                .asMap()
                .entries
                .map(
                  (e) => _buildRow(
                    context,
                    e.value,
                    e.key + _frozenTopRows.length + _scrollableRows.length,
                  ),
                )
                .toList(),
          ),
      ],
    );
  }
}
