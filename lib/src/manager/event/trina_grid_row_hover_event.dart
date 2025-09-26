import 'package:trina_grid/trina_grid.dart';

/// [TrinaRow] This event handles the hover status of the widget.
class TrinaGridRowHoverEvent extends TrinaGridEvent {
  final int rowIdx;
  bool isHovered;

  TrinaGridRowHoverEvent({required this.rowIdx, required this.isHovered});

  @override
  void handler(TrinaGridStateManager stateManager) {
    bool enableRowHoverColor =
        stateManager.configuration.style.enableRowHoverColor;

    // only change current hovered row index
    // if row hover color effect is enabled
    if (enableRowHoverColor) {
      // set the hovered row index to either the row index or null
      if (isHovered == true) {
        stateManager.setHoveredRowIdx(rowIdx, notify: true);
      } else {
        stateManager.setHoveredRowIdx(null, notify: true);
      }
    }

    // call the onRowEnter callback if it is not null
    if (stateManager.onRowEnter != null && isHovered == true) {
      stateManager.onRowEnter!(
        TrinaGridOnRowEnterEvent(
          row: stateManager.getRowByIdx(rowIdx),
          rowIdx: rowIdx,
        ),
      );
    }

    // call the onRowExit callback if it is not null
    if (stateManager.onRowExit != null && isHovered == false) {
      stateManager.onRowExit!(
        TrinaGridOnRowExitEvent(
          row: stateManager.getRowByIdx(rowIdx),
          rowIdx: rowIdx,
        ),
      );
    }
  }
}
