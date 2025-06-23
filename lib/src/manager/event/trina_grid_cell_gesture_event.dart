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
    } else if (stateManager.mode.isSelectMode) {
      _selectMode(stateManager);
    } else {
      _handleNormalInteraction(stateManager);
    }
  }

  void _handleSelectingInteraction(TrinaGridStateManager stateManager) {
    if (stateManager.keyPressed.shift) {
      _onSelectionWithShift(stateManager);
    } else if (stateManager.keyPressed.ctrl) {
      stateManager.toggleSelectingRow(rowIdx);
    }
  }

  void _onSelectionWithShift(TrinaGridStateManager stateManager) {
    final int? columnIdx = stateManager.columnIndex(column);

    stateManager.setCurrentSelectingPosition(
      cellPosition: TrinaGridCellPosition(
        columnIdx: columnIdx,
        rowIdx: rowIdx,
      ),
    );
  }

  void _handleNormalInteraction(TrinaGridStateManager stateManager) {
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

    stateManager.setCurrentSelectingPositionWithOffset(offset);

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

    if (stateManager.mode.isMultiSelectMode) {
      stateManager.handleOnSelected();
    }
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

  void _selectMode(TrinaGridStateManager stateManager) {
    switch (stateManager.mode) {
      case TrinaGridMode.normal:
      case TrinaGridMode.readOnly:
      case TrinaGridMode.popup:
        return;
      case TrinaGridMode.select:
      case TrinaGridMode.selectWithOneTap:
        if (stateManager.isCurrentCell(cell) == false) {
          stateManager.setCurrentCell(cell, rowIdx);

          if (!stateManager.mode.isSelectWithOneTap) {
            return;
          }
        }
        break;
      case TrinaGridMode.multiSelect:
        stateManager.toggleSelectingRow(rowIdx);
        break;
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
