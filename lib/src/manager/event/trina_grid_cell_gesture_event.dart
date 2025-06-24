import 'package:flutter/material.dart';
import 'package:trina_grid/trina_grid.dart';

/// [TrinaCell] This event handles the gesture of the widget.
class TrinaGridCellGestureEvent extends TrinaGridEvent {
  final TrinaGridGestureType gestureType;
  final Offset offset;
  final TrinaCell cell;
  final TrinaColumn column;
  final int rowIdx;

  TrinaGridCellGestureEvent({
    required this.gestureType,
    required this.offset,
    required this.cell,
    required this.column,
    required this.rowIdx,
  });

  @override
  void handler(TrinaGridStateManager stateManager) {
    switch (gestureType) {
      case TrinaGridGestureType.onTapUp:
        _onTapUp(stateManager);
        break;
      case TrinaGridGestureType.onLongPressStart:
        _onLongPressStart(stateManager);
        break;
      case TrinaGridGestureType.onLongPressMoveUpdate:
        _onLongPressMoveUpdate(stateManager);
        break;
      case TrinaGridGestureType.onLongPressEnd:
        _onLongPressEnd(stateManager);
        break;
      case TrinaGridGestureType.onDoubleTap:
        _onDoubleTap(stateManager);
        break;
      case TrinaGridGestureType.onSecondaryTap:
        _onSecondaryTap(stateManager);
        break;
    }
  }

  void _onTapUp(TrinaGridStateManager stateManager) {
    if (_setKeepFocusAndCurrentCell(stateManager)) {
      return;
    }

    if (stateManager.isSelectingInteraction()) {
      _handleSelectingInteraction(stateManager);
    } else if (stateManager.selectingMode.isSingleTapSelection) {
      _handleSingleTapSelection(stateManager);
    } else {
      _handleNormalTap(stateManager);
    }
  }

  /// Handles interactions when selection mode is active (e.g., Shift or Ctrl key pressed).
  void _handleSelectingInteraction(TrinaGridStateManager stateManager) {
    if (stateManager.keyPressed.shift) {
      _onSelectionWithShift(stateManager);
    } else if (stateManager.keyPressed.ctrl) {
      _onSelectionWithCTRL(stateManager);
    }
  }

  /// Handles selection when the Shift key is pressed.
  void _onSelectionWithShift(TrinaGridStateManager stateManager) {
    final int? columnIdx = stateManager.columnIndex(column);

    stateManager.setCurrentSelectingPosition(
      cellPosition: TrinaGridCellPosition(
        columnIdx: columnIdx,
        rowIdx: rowIdx,
      ),
    );
    _handleRangeSelectionIfSelectingCells(stateManager);
    _handleRangeSelectionIfSelectingRows(stateManager);
  }

  void _onSelectionWithCTRL(TrinaGridStateManager stateManager) {
    if (stateManager.selectingMode.isDisabled) {
      return;
    }
    if (stateManager.selectingMode.isCellWithCtrl) {
      if (stateManager.currentCell != null &&
          stateManager.selectedCells.isEmpty) {
        stateManager.toggleCellSelection(stateManager.currentCell!);
      }
      stateManager.toggleCellSelection(cell);
      // This is to update the current cell color if it became unselected
      if (stateManager.isCurrentCell(cell) &&
          !stateManager.isSelectedCell(cell, column, rowIdx)) {
        stateManager.clearCurrentCell();
      }
    }
    if (stateManager.selectingMode.isRowWithCtrl) {
      final int? currentRowIdx = stateManager.currentRowIdx;
      // If no rows are currently selected and the current row is different from the tapped row,
      // ensure the current row is included in the selection.
      if (stateManager.selectedRows.isEmpty && currentRowIdx != rowIdx) {
        stateManager.toggleSelectingRow(currentRowIdx);
      }
      // Always toggle the selection state of the tapped row.
      stateManager.toggleSelectingRow(rowIdx);
    }
    stateManager.handleOnSelected();
  }

  void _handleNormalTap(TrinaGridStateManager stateManager) {
    if (stateManager.isCurrentCell(cell) && stateManager.isEditing != true) {
      stateManager.setEditing(true);
    } else {
      stateManager.setCurrentCell(cell, rowIdx);
    }
    // If selection activates with ctrl\cmd, then selected cells\rows is cleared by
    // `stateManager.setCurrentCell`, so we should call handleOnSelected.
    // If grid mode is popup, calling handleOnSelected means the user is finished selecting and
    // the popup should be closed but It may not be the desired behavior.
    if (stateManager.selectingMode.isSelectWithCTRL &&
        stateManager.mode.isPopup == false) {
      stateManager.handleOnSelected();
    }
  }

  void _onLongPressStart(TrinaGridStateManager stateManager) {
    _setCurrentCell(stateManager, cell, rowIdx);

    stateManager.setSelecting(true);

    if (stateManager.selectingMode.isRow) {
      stateManager.toggleSelectingRow(rowIdx);
    }
  }

  void _onLongPressMoveUpdate(TrinaGridStateManager stateManager) {
    _setCurrentCell(stateManager, cell, rowIdx);

    final int? previousSelectingRowIdx =
        stateManager.currentSelectingPosition?.rowIdx;

    stateManager.setCurrentSelectingPositionWithOffset(offset);

    _handleRangeSelectionIfSelectingCells(stateManager);

    // Selected rows is only updated when the dragged offset enters a new row,
    // preventing performance issues from frequent updates.
    if (stateManager.currentSelectingPosition?.rowIdx !=
        previousSelectingRowIdx) {
      _handleRangeSelectionIfSelectingRows(stateManager);
    }

    stateManager.eventManager!.addEvent(
      TrinaGridScrollUpdateEvent(offset: offset),
    );
  }

  void _onLongPressEnd(TrinaGridStateManager stateManager) {
    _setCurrentCell(stateManager, cell, rowIdx);

    stateManager.setSelecting(false);

    TrinaGridScrollUpdateEvent.stopScroll(
      stateManager,
      TrinaGridScrollUpdateDirection.all,
    );
    _handleRangeSelectionIfSelectingRows(stateManager);
  }

  void _onDoubleTap(TrinaGridStateManager stateManager) {
    stateManager.onRowDoubleTap!(
      TrinaGridOnRowDoubleTapEvent(
        row: stateManager.getRowByIdx(rowIdx)!,
        rowIdx: rowIdx,
        cell: cell,
      ),
    );
  }

  void _onSecondaryTap(TrinaGridStateManager stateManager) {
    stateManager.onRowSecondaryTap!(
      TrinaGridOnRowSecondaryTapEvent(
        row: stateManager.getRowByIdx(rowIdx)!,
        rowIdx: rowIdx,
        cell: cell,
        offset: offset,
      ),
    );
  }

  bool _setKeepFocusAndCurrentCell(TrinaGridStateManager stateManager) {
    if (stateManager.hasFocus) {
      return false;
    }

    stateManager.setKeepFocus(true);

    return stateManager.isCurrentCell(cell);
  }

  /// Handle selection based on selecting mode
  void _handleSingleTapSelection(TrinaGridStateManager stateManager) {
    if (stateManager.selectingMode.isRowWithSingleTap) {
      stateManager.toggleSelectingRow(rowIdx);
    }
    if (stateManager.selectingMode.isCellWithSingleTap) {
      stateManager.toggleCellSelection(cell);
    }
    stateManager.handleOnSelected();
  }

  void _setCurrentCell(
    TrinaGridStateManager stateManager,
    TrinaCell? cell,
    int? rowIdx,
  ) {
    if (stateManager.isCurrentCell(cell) != true) {
      stateManager.setCurrentCell(cell, rowIdx, notify: false);
    }
  }

  void _handleRangeSelectionIfSelectingRows(
      TrinaGridStateManager stateManager) {
    if (stateManager.selectingMode.isRow) {
      stateManager.selectRowsInRange(
        stateManager.currentCellPosition?.rowIdx,
        cell.row.sortIdx,
        notify: false,
      );
      stateManager.handleOnSelected();
    }
  }

  void _handleRangeSelectionIfSelectingCells(
    TrinaGridStateManager stateManager,
  ) {
    if (stateManager.selectingMode.isCell) {
      stateManager.selectCellsInRange(
        stateManager.currentCellPosition!,
        stateManager.currentSelectingPosition!,
      );
      stateManager.handleOnSelected();
    }
  }
}

enum TrinaGridGestureType {
  onTapUp,
  onLongPressStart,
  onLongPressMoveUpdate,
  onLongPressEnd,
  onDoubleTap,
  onSecondaryTap;

  bool get isOnTapUp => this == TrinaGridGestureType.onTapUp;

  bool get isOnLongPressStart => this == TrinaGridGestureType.onLongPressStart;

  bool get isOnLongPressMoveUpdate =>
      this == TrinaGridGestureType.onLongPressMoveUpdate;

  bool get isOnLongPressEnd => this == TrinaGridGestureType.onLongPressEnd;

  bool get isOnDoubleTap => this == TrinaGridGestureType.onDoubleTap;

  bool get isOnSecondaryTap => this == TrinaGridGestureType.onSecondaryTap;
}
