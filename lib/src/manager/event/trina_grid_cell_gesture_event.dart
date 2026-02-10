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
      case TrinaGridGestureType.onPointerDown:
        _onPointerDown(stateManager);
        break;
      case TrinaGridGestureType.onPointerMove:
        _onPointerMove(stateManager);
        break;
      case TrinaGridGestureType.onPointerUp:
        _onPointerUp(stateManager);
        break;
    }
  }

  void _onTapUp(TrinaGridStateManager stateManager) {
    if (_setKeepFocusAndCurrentCell(stateManager)) {
      return;
    } else if (stateManager.isSelectingInteraction()) {
      _selecting(stateManager);
      return;
    } else if (stateManager.mode.isSelectMode) {
      _selectMode(stateManager);
      return;
    }

    // Clear individual selections when clicking without modifiers
    if (stateManager.configuration.enableCtrlClickMultiSelect &&
        !stateManager.keyPressed.ctrl &&
        !stateManager.keyPressed.shift) {
      stateManager.clearIndividualSelections(notify: false);
    }

    if (stateManager.isCurrentCell(cell) && stateManager.isEditing != true) {
      stateManager.setEditing(true);
    } else {
      stateManager.setCurrentCell(cell, rowIdx);

      // In normal mode, also fire onSelected callback when row selection is configured
      if (stateManager.mode.isNormal &&
          stateManager.selectingMode.isRow &&
          stateManager.onSelected != null) {
        stateManager.handleOnSelected();
      }
    }
  }

  void _onLongPressStart(TrinaGridStateManager stateManager) {
    _setCurrentCell(stateManager, cell, rowIdx);

    // If drag selection is enabled in cell mode, use the drag selection system
    if (stateManager.configuration.enableDragSelection &&
        stateManager.selectingMode == TrinaGridSelectingMode.cell) {
      final int? columnIdx = stateManager.columnIndex(column);
      if (columnIdx != null) {
        final cellPosition = TrinaGridCellPosition(
          columnIdx: columnIdx,
          rowIdx: rowIdx,
        );
        stateManager.startDragSelection(cellPosition);

        // Set the initial selection position
        stateManager.setCurrentSelectingPosition(
          cellPosition: cellPosition,
          notify: true,
        );
      }
    } else {
      // Use traditional selection system for row mode or when drag selection is disabled
      stateManager.setSelecting(true);

      if (stateManager.selectingMode.isRow) {
        stateManager.toggleSelectingRow(rowIdx);

        // Fire onSelected callback for long press selection in normal mode too
        if ((stateManager.mode.isMultiSelectMode ||
                (stateManager.mode.isNormal &&
                    stateManager.selectingMode.isRow)) &&
            stateManager.onSelected != null) {
          stateManager.handleOnSelected();
        }
      }
    }
  }

  void _onLongPressMoveUpdate(TrinaGridStateManager stateManager) {
    _setCurrentCell(stateManager, cell, rowIdx);

    // Use setCurrentSelectingPositionWithOffset which calculates the cell
    // position from the global offset (pointer position)
    stateManager.setCurrentSelectingPositionWithOffset(offset);

    stateManager.eventManager!.addEvent(
      TrinaGridScrollUpdateEvent(offset: offset),
    );
  }

  void _onLongPressEnd(TrinaGridStateManager stateManager) {
    _setCurrentCell(stateManager, cell, rowIdx);

    // If drag selection is active, end it
    if (stateManager.isDragSelecting) {
      stateManager.endDragSelection();
    } else {
      // Use traditional selection system
      stateManager.setSelecting(false);

      if (stateManager.mode.isMultiSelectMode) {
        stateManager.handleOnSelected();
      }
    }

    TrinaGridScrollUpdateEvent.stopScroll(
      stateManager,
      TrinaGridScrollUpdateDirection.all,
    );
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

  void _onPointerDown(TrinaGridStateManager stateManager) {
    if (!stateManager.configuration.enableDragSelection) return;
    if (stateManager.selectingMode != TrinaGridSelectingMode.cell) return;

    final int? columnIdx = stateManager.columnIndex(column);
    if (columnIdx == null) return;

    final cellPosition = TrinaGridCellPosition(
      columnIdx: columnIdx,
      rowIdx: rowIdx,
    );

    // Don't start drag if Ctrl/Shift pressed (they have different behavior)
    // They will be handled in onTapUp
    if (stateManager.keyPressed.ctrl || stateManager.keyPressed.shift) {
      return;
    }

    stateManager.startDragSelection(cellPosition);

    // Clear any range selection to start fresh
    stateManager.setCurrentSelectingPosition(
      cellPosition: cellPosition,
      notify: false,
    );
  }

  void _onPointerMove(TrinaGridStateManager stateManager) {
    if (!stateManager.configuration.enableDragSelection) return;
    if (!stateManager.isDragSelecting) return;

    final int? columnIdx = stateManager.columnIndex(column);
    if (columnIdx == null) return;

    final cellPosition = TrinaGridCellPosition(
      columnIdx: columnIdx,
      rowIdx: rowIdx,
    );

    stateManager.updateDragSelection(cellPosition);

    // Handle auto-scroll during drag
    stateManager.eventManager!.addEvent(
      TrinaGridScrollUpdateEvent(offset: offset),
    );
  }

  void _onPointerUp(TrinaGridStateManager stateManager) {
    if (!stateManager.configuration.enableDragSelection) return;
    if (!stateManager.isDragSelecting) return;

    stateManager.endDragSelection();

    TrinaGridScrollUpdateEvent.stopScroll(
      stateManager,
      TrinaGridScrollUpdateDirection.all,
    );
  }

  bool _setKeepFocusAndCurrentCell(TrinaGridStateManager stateManager) {
    if (stateManager.hasFocus) {
      return false;
    }

    stateManager.setKeepFocus(true);

    return stateManager.isCurrentCell(cell);
  }

  void _selecting(TrinaGridStateManager stateManager) {
    // Allow onSelected callback to fire in both multiSelect mode and normal mode with row selection
    bool callOnSelected =
        stateManager.mode.isMultiSelectMode ||
        (stateManager.mode.isNormal && stateManager.selectingMode.isRow);

    if (stateManager.keyPressed.shift) {
      final int? columnIdx = stateManager.columnIndex(column);

      stateManager.setCurrentSelectingPosition(
        cellPosition: TrinaGridCellPosition(
          columnIdx: columnIdx,
          rowIdx: rowIdx,
        ),
      );
    } else if (stateManager.keyPressed.ctrl) {
      // Ctrl in cell mode with enableCtrlClickMultiSelect = individual cell toggle
      if (stateManager.selectingMode == TrinaGridSelectingMode.cell &&
          stateManager.configuration.enableCtrlClickMultiSelect) {
        final int? columnIdx = stateManager.columnIndex(column);
        if (columnIdx != null) {
          final cellPosition = TrinaGridCellPosition(
            columnIdx: columnIdx,
            rowIdx: rowIdx,
          );
          stateManager.toggleSelectingCell(cellPosition);
        }
        callOnSelected = false;
      } else {
        // Ctrl in row mode or without enableCtrlClickMultiSelect = row toggle (existing behavior)
        stateManager.toggleSelectingRow(rowIdx);
      }
    } else {
      callOnSelected = false;
    }

    if (callOnSelected) {
      stateManager.handleOnSelected();
    }
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
  onSecondaryTap,
  // Pointer events for drag selection
  onPointerDown,
  onPointerMove,
  onPointerUp;

  bool get isOnTapUp => this == TrinaGridGestureType.onTapUp;

  bool get isOnLongPressStart => this == TrinaGridGestureType.onLongPressStart;

  bool get isOnLongPressMoveUpdate =>
      this == TrinaGridGestureType.onLongPressMoveUpdate;

  bool get isOnLongPressEnd => this == TrinaGridGestureType.onLongPressEnd;

  bool get isOnDoubleTap => this == TrinaGridGestureType.onDoubleTap;

  bool get isOnSecondaryTap => this == TrinaGridGestureType.onSecondaryTap;

  bool get isOnPointerDown => this == TrinaGridGestureType.onPointerDown;

  bool get isOnPointerMove => this == TrinaGridGestureType.onPointerMove;

  bool get isOnPointerUp => this == TrinaGridGestureType.onPointerUp;
}
