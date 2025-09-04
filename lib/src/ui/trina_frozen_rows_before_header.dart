import 'package:flutter/material.dart';
import 'package:trina_grid/trina_grid.dart';

import 'ui.dart';

/// Widget for displaying frozen rows before column titles or filters
class TrinaFrozenRowsBeforeHeader extends StatelessWidget {
  final TrinaGridStateManager stateManager;
  final TrinaRowFrozen frozenType;

  const TrinaFrozenRowsBeforeHeader({
    super.key,
    required this.stateManager,
    required this.frozenType,
  });

  @override
  Widget build(BuildContext context) {
    // Get the rows with the specific frozen type
    final rows = stateManager.refRows.originalList
        .where((row) => row.frozen == frozenType)
        .toList();

    if (rows.isEmpty) {
      return const SizedBox.shrink();
    }

    // Get all columns (including frozen ones)
    final columns = stateManager.columns;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: rows.asMap().entries.map((entry) {
        final index = entry.key;
        final row = entry.value;

        Widget rowWidget = TrinaBaseRow(
          key: ValueKey('${frozenType.name}_row_${row.key}'),
          rowIdx: index,
          row: row,
          columns: columns,
          stateManager: stateManager,
          visibilityLayout: false,
        );

        // Apply row wrapper if available
        return stateManager.rowWrapper?.call(
              context,
              rowWidget,
              row,
              stateManager,
            ) ??
            rowWidget;
      }).toList(),
    );
  }
}