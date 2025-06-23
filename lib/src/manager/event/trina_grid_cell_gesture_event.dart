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
      stateManager.toggleSelectingRow(rowIdx);
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

    _handleRangeSelectionIfSelectingRows(stateManager);
  }

  void _handleNormalTap(TrinaGridStateManager stateManager) {
    if (stateManager.isCurrentCell(cell) && stateManager.isEditing != true) {
      stateManager.setEditing(true);
    } else {
      stateManager.setCurrentCell(cell, rowIdx);
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
    if (stateManager.selectingMode == TrinaGridSelectingMode.rowWithSingleTap) {
      stateManager.toggleSelectingRow(rowIdx);
      stateManager.handleOnSelected();
    }
    if (stateManager.selectingMode ==
        TrinaGridSelectingMode.cellWithSingleTap) {
      if (stateManager.isCurrentCell(cell) == false) {
        stateManager.setCurrentCell(cell, rowIdx);
      }
      stateManager.handleOnSelected();
    }
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
