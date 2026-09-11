import 'package:flutter/rendering.dart' show ItemExtentBuilder;
import 'package:trina_grid/trina_grid.dart';

/// How a scrollable row list sizes its children.
///
/// Resolve this once per state update rather than per build, and hand both
/// fields straight to the list. Exactly one of [itemExtent] and
/// [itemExtentBuilder] is non-null, except when the rows have to lay out
/// naturally, where both are null.
///
/// Supplying [itemExtentBuilder] for uniform rows makes Flutter sum preceding
/// extents during scroll layout, once per visible child, whereas [itemExtent]
/// allows constant-time index/offset calculations.
class TrinaRowExtent {
  const TrinaRowExtent({this.itemExtent, this.itemExtentBuilder});

  final double? itemExtent;

  final ItemExtentBuilder? itemExtentBuilder;

  factory TrinaRowExtent.resolve(
    List<TrinaRow> rows,
    TrinaGridStateManager stateManager,
  ) {
    if (stateManager.rowWrapper != null &&
        !stateManager.configuration.rowWrapperIsConstantHeight) {
      return const TrinaRowExtent();
    }

    final style = stateManager.configuration.style;

    double extentOf(TrinaRow row) =>
        (row.height ?? style.rowHeight) + style.cellHorizontalBorderWidth;

    if (rows.isEmpty) {
      return TrinaRowExtent(
        itemExtent: style.rowHeight + style.cellHorizontalBorderWidth,
      );
    }

    final fixed = extentOf(rows.first);
    for (final row in rows) {
      if (extentOf(row) != fixed) {
        return TrinaRowExtent(
          itemExtentBuilder: (index, _) => extentOf(rows[index]),
        );
      }
    }

    return TrinaRowExtent(itemExtent: fixed);
  }
}
