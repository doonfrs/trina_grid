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
    if (_isFirstTapToFocusGrid(stateManager)) {
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
    final currentPosition = TrinaGridCellPosition(
      columnIdx: columnIdx,
      rowIdx: rowIdx,
    );
    stateManager.setCurrentSelectingPosition(cellPosition: currentPosition);
    if (stateManager.currentCellPosition == null) {
      stateManager.setCurrentCellPosition(currentPosition, notify: false);
    }
    _handleRangeSelectionIfSelectingCells(stateManager);
    _handleRangeSelectionIfSelectingRows(stateManager);
  }

  void _onSelectionWithCTRL(TrinaGridStateManager stateManager) {
    if (stateManager.selectingMode.isDisabled) {
      return;
    }

    if (stateManager.selectingMode.isCellWithCtrl) {
      final isCurrentCell = stateManager.isCurrentCell(cell);
      final wasSelected = stateManager.isSelectedCell(cell);
      if (!isCurrentCell &&
          stateManager.currentCell != null &&
          stateManager.selectedCells.isEmpty) {
        stateManager.toggleCellSelection(stateManager.currentCell!);
      }
      stateManager.toggleCellSelection(cell);
      // Check after toggling the cell selection state
      final isNotCurrentlySelected = !stateManager.isSelectedCell(cell);
      // This is to update the current cell color if it was selected and became unselected
      if (isCurrentCell && wasSelected && isNotCurrentlySelected) {
        stateManager.clearCurrentCell();
      }
    }
    if (stateManager.selectingMode.isRowWithCtrl) {
      final int? currentRowIdx = stateManager.currentRowIdx;
      // If no rows are currently selected and the current row is different from the tapped row,
      // ensure the current row is included in the selection.
      if (stateManager.selectedRows.isEmpty && currentRowIdx != rowIdx) {
        stateManager.toggleRowSelection(currentRowIdx);
      }

      // Always toggle the selection state of the tapped row.
      stateManager.toggleRowSelection(rowIdx);
    }

    _setCurrentSelectionPosition(stateManager);

    stateManager.setCurrentCellPosition(TrinaGridCellPosition(
      rowIdx: rowIdx,
      columnIdx: stateManager.columnIndex(column),
    ));
    stateManager.handleOnSelected();
  }

  void _handleNormalTap(TrinaGridStateManager stateManager) {
    if (stateManager.isCurrentCell(cell)) {
      stateManager.setEditing(true);
    } else {
      stateManager.setCurrentCell(cell, rowIdx);
      // If selection activates with ctrl\cmd, then selected cells\rows is cleared by
      // `stateManager.setCurrentCell`, so we should call handleOnSelected.
      // If grid mode is popup, calling handleOnSelected means the user is finished selecting and
      // the popup should be closed but It may not be the desired behavior.
      if (stateManager.selectingMode.isSelectWithCTRL &&
          stateManager.mode.isPopup == false) {
        stateManager.handleOnSelected();
      }
    }
  }

  void _onLongPressStart(TrinaGridStateManager stateManager) {
    _setCurrentCell(stateManager, cell, rowIdx);

    stateManager.setSelecting(true);
  }

  void _onLongPressMoveUpdate(TrinaGridStateManager stateManager) {
    // The anchor point for any selection is the cell that was current
    // when the selection started.
    final TrinaGridCellPosition? anchorPosition =
        stateManager.currentCellPosition;

    final TrinaGridCellPosition? previousSelectingPosition =
        stateManager.currentSelectingPosition;

    stateManager.setCurrentSelectingPositionWithOffset(offset);

    stateManager.eventManager!.addEvent(
      TrinaGridScrollUpdateEvent(offset: offset),
    );

    final TrinaGridCellPosition? newSelectingPosition =
        stateManager.currentSelectingPosition;

    if (newSelectingPosition == null || anchorPosition == null) {
      return;
    }

    bool hasPositionChanged = false;
    if (stateManager.selectingMode.isRow) {
      hasPositionChanged =
          newSelectingPosition.rowIdx != previousSelectingPosition?.rowIdx;
    } else if (stateManager.selectingMode.isCell) {
      hasPositionChanged =
          newSelectingPosition.rowIdx != previousSelectingPosition?.rowIdx ||
              newSelectingPosition.columnIdx !=
                  previousSelectingPosition?.columnIdx;
    }

    if (hasPositionChanged) {
      stateManager.clearCurrentSelecting(notify: false);

      if (stateManager.selectingMode.isRow) {
        stateManager.selectRowsInRange(
          anchorPosition.rowIdx,
          newSelectingPosition.rowIdx,
        );
      } else if (stateManager.selectingMode.isCell) {
        stateManager.selectCellsInRange(
          anchorPosition,
          newSelectingPosition,
        );
      }

      stateManager.handleOnSelected();
    }
  }

  void _onLongPressEnd(TrinaGridStateManager stateManager) {
    _setCurrentCell(stateManager, cell, rowIdx);

    stateManager.setSelecting(false);

    TrinaGridScrollUpdateEvent.stopScroll(
      stateManager,
      TrinaGridScrollUpdateDirection.all,
    );
  }

  void _onDoubleTap(TrinaGridStateManager stateManager) {
    if (stateManager.mode.isPopup && stateManager.selectingMode.isEnabled) {
      if (stateManager.selectingMode.isRow) {
        stateManager.toggleRowSelection(rowIdx);
      } else {
        stateManager.toggleCellSelection(cell);
      }
      stateManager.handleOnSelected();
    } else if (!stateManager.autoEditing &&
        stateManager.selectingMode.isNotSingleTapSelection) {
      if (stateManager.isCurrentCell(cell)) {
        stateManager.setEditing(true);
      } else {
        stateManager.setCurrentCell(cell, rowIdx);
      }
    }
    stateManager.onDoubleTap?.call(
      TrinaGridOnDoubleTapEvent(
        row: stateManager.getRowByIdx(rowIdx)!,
        rowIdx: rowIdx,
        cell: cell,
      ),
    );
  }

  void _onSecondaryTap(TrinaGridStateManager stateManager) {
    if (stateManager.selectingMode.isSingleTapSelection) {
      if (!stateManager.isCurrentCell(cell)) {
        // calling `setCurrentCell` will clear the current selection
        stateManager.setCurrentCell(cell, rowIdx);
      } else {
        stateManager.clearCurrentSelecting();
      }
      stateManager.handleOnSelected();
      stateManager.setEditing(true);
    }
    stateManager.onRowSecondaryTap?.call(
      TrinaGridOnRowSecondaryTapEvent(
        row: stateManager.getRowByIdx(rowIdx)!,
        rowIdx: rowIdx,
        cell: cell,
        offset: offset,
      ),
    );
  }

  /// If the grid does not have focus, the tap's first job is to give it focus.
  /// If the tapped cell is already the current one, we shouldn't proceed
  /// with other actions like toggling selection or entering edit mode.
  /// This prevents unintended behavior on the first tap that is only meant
  /// to focus the grid.
  bool _isFirstTapToFocusGrid(TrinaGridStateManager stateManager) {
    if (stateManager.hasFocus) {
      return false;
    }

    stateManager.setKeepFocus(true);

    return stateManager.isCurrentCell(cell);
  }

  /// Handle selection based on selecting mode
  void _handleSingleTapSelection(TrinaGridStateManager stateManager) {
    if (stateManager.isEditing) {
      stateManager.setEditing(false);
    }
    if (stateManager.selectingMode.isRowWithSingleTap) {
      stateManager.toggleRowSelection(rowIdx);
    }
    if (stateManager.selectingMode.isCellWithSingleTap) {
      stateManager.toggleCellSelection(cell);
    }
    _setCurrentSelectionPosition(stateManager);
    stateManager.setCurrentCellPosition(TrinaGridCellPosition(
      rowIdx: rowIdx,
      columnIdx: stateManager.columnIndex(column),
    ));
    stateManager.handleOnSelected();
  }

  void _setCurrentSelectionPosition(TrinaGridStateManager stateManager) {
    stateManager.setCurrentSelectingPosition(
      cellPosition: TrinaGridCellPosition(
        columnIdx: stateManager.columnIndex(column),
        rowIdx: rowIdx,
      ),
    );
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
        rowIdx,
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
