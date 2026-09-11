import 'package:trina_grid/trina_grid.dart';

/// Returns the fixed extent of the scrollable rows, or null when they vary.
///
/// Resolve this once when building a row list. Supplying itemExtentBuilder for
/// uniform rows makes Flutter sum preceding extents during scroll layout,
/// whereas itemExtent allows constant-time index/offset calculations.
double? fixedRowExtent(
  List<TrinaRow> rows,
  TrinaGridStateManager stateManager,
) {
  if (stateManager.rowWrapper != null &&
      !stateManager.configuration.rowWrapperIsConstantHeight) {
    return null;
  }

  final style = stateManager.configuration.style;
  final height = rows.isEmpty
      ? style.rowHeight
      : rows.first.height ?? style.rowHeight;
  for (final row in rows) {
    if ((row.height ?? style.rowHeight) != height) return null;
  }
  return height + style.cellHorizontalBorderWidth;
}
