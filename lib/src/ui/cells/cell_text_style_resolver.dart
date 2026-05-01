import 'package:flutter/widgets.dart';
import 'package:trina_grid/trina_grid.dart';

/// Resolves the effective [TextStyle] for a cell by merging:
///
/// 1. [TrinaGridStyleConfig.cellTextStyle] (base, from configuration)
/// 2. [TrinaGrid.rowTextStyleCallback] result (if non-null)
/// 3. [TrinaGrid.cellTextStyleCallback] result (if non-null)
///
/// Each callback may return `null` to mean "no change". Non-null returns are
/// merged via [TextStyle.merge], so callers typically only specify the fields
/// they want to override (commonly just `color`).
///
/// [rowIdx] is optional: edit-mode cell widgets do not carry the visual row
/// index, in which case it is resolved from `stateManager.refRows.indexOf(row)`.
TextStyle resolveCellTextStyle({
  required TrinaGridStateManager stateManager,
  required TrinaRow row,
  required TrinaCell cell,
  required TrinaColumn column,
  int? rowIdx,
}) {
  final base = stateManager.configuration.style.cellTextStyle;

  final rowCallback = stateManager.rowTextStyleCallback;
  final cellCallback = stateManager.cellTextStyleCallback;

  if (rowCallback == null && cellCallback == null) {
    return base;
  }

  final resolvedRowIdx = rowIdx ?? stateManager.refRows.indexOf(row);

  final rowStyle = rowCallback?.call(
    TrinaRowColorContext(
      row: row,
      rowIdx: resolvedRowIdx,
      stateManager: stateManager,
    ),
  );

  final cellStyle = cellCallback?.call(
    TrinaCellColorContext(
      cell: cell,
      column: column,
      row: row,
      rowIdx: resolvedRowIdx,
      stateManager: stateManager,
    ),
  );

  return base.merge(rowStyle).merge(cellStyle);
}
