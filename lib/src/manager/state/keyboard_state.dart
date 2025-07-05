import 'dart:math';

import 'package:trina_grid/trina_grid.dart';

abstract class IKeyboardState {
  /// Currently pressed key
  TrinaGridKeyPressed get keyPressed;

  /// The index position of the cell to move in that direction in the current cell.
  TrinaGridCellPosition cellPositionToMove(
    TrinaGridCellPosition cellPosition,
    TrinaMoveDirection direction,
  );

  /// Change the current cell to the cell in the [direction] and move the scroll
  /// [force] true : Allow left and right movement with tab key in editing state.
  void moveCurrentCell(
    TrinaMoveDirection direction, {
    bool force = false,
    bool notify = true,
  });

  void moveCurrentCellToEdgeOfColumns(
    TrinaMoveDirection direction, {
    bool force = false,
    bool notify = true,
  });

  void moveCurrentCellToEdgeOfRows(
    TrinaMoveDirection direction, {
    bool force = false,
    bool notify = true,
  });

  void moveCurrentCellByRowIdx(
    int rowIdx,
    TrinaMoveDirection direction, {
    bool notify = true,
  });

  void moveSelectingCell(TrinaMoveDirection direction);

  void moveSelectingCellToEdgeOfColumns(
    TrinaMoveDirection direction, {
    bool force = false,
    bool notify = true,
  });

  void moveSelectingCellToEdgeOfRows(
    TrinaMoveDirection direction, {
    bool force = false,
    bool notify = true,
  });

  void moveSelectingCellByRowIdx(
    int rowIdx,
    TrinaMoveDirection direction, {
    bool notify = true,
  });
}

mixin KeyboardState implements ITrinaGridState {
  final TrinaGridKeyPressed _keyPressed = TrinaGridKeyPressed();

  @override
  TrinaGridKeyPressed get keyPressed => _keyPressed;

  @override
  TrinaGridCellPosition cellPositionToMove(
    TrinaGridCellPosition? cellPosition,
    TrinaMoveDirection direction,
  ) {
    final columnIndexes = columnIndexesByShowFrozen;

    switch (direction) {
      case TrinaMoveDirection.left:
        return TrinaGridCellPosition(
          columnIdx: columnIndexes[cellPosition!.columnIdx! - 1],
          rowIdx: cellPosition.rowIdx,
        );
      case TrinaMoveDirection.right:
        return TrinaGridCellPosition(
          columnIdx: columnIndexes[cellPosition!.columnIdx! + 1],
          rowIdx: cellPosition.rowIdx,
        );
      case TrinaMoveDirection.up:
        return TrinaGridCellPosition(
          columnIdx: columnIndexes[cellPosition!.columnIdx!],
          rowIdx: cellPosition.rowIdx! - 1,
        );
      case TrinaMoveDirection.down:
        return TrinaGridCellPosition(
          columnIdx: columnIndexes[cellPosition!.columnIdx!],
          rowIdx: cellPosition.rowIdx! + 1,
        );
    }
  }

  @override
  void moveCurrentCell(
    TrinaMoveDirection direction, {
    bool force = false,
    bool notify = true,
  }) {
    if (currentCell == null) return;

    // @formatter:off
    if (!force && isEditing && direction.horizontal) {
      // Select type column can be moved left or right even in edit state
      if (currentColumn?.type.isSelect == true) {
      }
      // Date type column can be moved left or right even in edit state
      else if (currentColumn?.type.isDate == true) {
      }
      // Time type column can be moved left or right even in edit state
      else if (currentColumn?.type.isTime == true) {
      }
      // Currency type column can be moved left or right even in edit state
      else if (currentColumn?.type.isCurrency == true) {
      }
      // Read only type column can be moved left or right even in edit state
      else if (currentColumn?.readOnly == true) {
      }
      // Unable to move left and right in other modified states
      else {
        return;
      }
    }
    // @formatter:on

    final cellPosition = currentCellPosition;

    if (cellPosition != null && canNotMoveCell(cellPosition, direction)) {
      eventManager!.addEvent(
        TrinaGridCannotMoveCurrentCellEvent(
          cellPosition: cellPosition,
          direction: direction,
        ),
      );

      return;
    }

    final toMove = cellPositionToMove(cellPosition, direction);

    setCurrentCell(
      refRows[toMove.rowIdx!].cells[refColumns[toMove.columnIdx!].field],
      toMove.rowIdx,
      notify: notify,
    );

    if (direction.horizontal) {
      moveScrollByColumn(direction, cellPosition!.columnIdx);
    } else if (direction.vertical) {
      moveScrollByRow(direction, cellPosition!.rowIdx);
    }
    return;
  }

  @override
  void moveCurrentCellToEdgeOfColumns(
    TrinaMoveDirection direction, {
    bool force = false,
    bool notify = true,
  }) {
    if (!direction.horizontal) {
      return;
    }

    if (!force && isEditing == true) {
      return;
    }

    if (currentCell == null) {
      return;
    }

    final columnIndexes = columnIndexesByShowFrozen;

    final int columnIdx =
        direction.isLeft ? columnIndexes.first : columnIndexes.last;

    final column = refColumns[columnIdx];

    final cellToMove = currentRow!.cells[column.field];

    setCurrentCell(cellToMove, currentRowIdx, notify: notify);

    if (!showFrozenColumn || column.frozen.isFrozen != true) {
      direction.isLeft
          ? scroll.horizontal!.jumpTo(0)
          : scroll.horizontal!.jumpTo(scroll.maxScrollHorizontal);
    }
  }

  @override
  void moveCurrentCellToEdgeOfRows(
    TrinaMoveDirection direction, {
    bool force = false,
    bool notify = true,
  }) {
    if (!direction.vertical) {
      return;
    }

    if (!force && isEditing == true) {
      return;
    }

    final field = currentColumnField ?? columns.first.field;

    final int rowIdx = direction.isUp ? 0 : refRows.length - 1;

    final cellToMove = refRows[rowIdx].cells[field];

    setCurrentCell(cellToMove, rowIdx, notify: notify);

    direction.isUp
        ? scroll.vertical!.jumpTo(0)
        : scroll.vertical!.jumpTo(scroll.maxScrollVertical);
  }

  @override
  void moveCurrentCellByRowIdx(
    int rowIdx,
    TrinaMoveDirection direction, {
    bool notify = true,
  }) {
    if (!direction.vertical) {
      return;
    }

    if (rowIdx < 0) {
      rowIdx = 0;
    }

    if (rowIdx > refRows.length - 1) {
      rowIdx = refRows.length - 1;
    }

    final field = currentColumnField ?? refColumns.first.field;

    final cellToMove = refRows[rowIdx].cells[field];

    setCurrentCell(cellToMove, rowIdx, notify: notify);

    moveScrollByRow(direction, rowIdx - direction.offset);

    if (selectingMode.isRow) {
      selectRowsInRange(
        currentCellPosition?.rowIdx,
        currentSelectingPosition?.rowIdx,
        notify: false,
      );
    }
  }

  @override
  void moveSelectingCell(TrinaMoveDirection direction) {
    final TrinaGridCellPosition? cellPosition =
        currentSelectingPosition ?? currentCellPosition;

    if (canNotMoveCell(cellPosition, direction)) {
      return;
    }
    if (cellPosition == null) {
      return;
    }

    if (direction.horizontal) {
      moveScrollByColumn(direction, cellPosition.columnIdx);
    } else {
      moveScrollByRow(direction, cellPosition.rowIdx);
    }

    if (selectingMode.isEnabled) {
      final oldSelectingPosition = currentSelectingPosition;
      final newSelectingPosition = TrinaGridCellPosition(
        columnIdx: cellPosition.columnIdx! +
            (direction.horizontal ? direction.offset : 0),
        rowIdx:
            cellPosition.rowIdx! + (direction.vertical ? direction.offset : 0),
      );
      //
      setCurrentSelectingPosition(cellPosition: newSelectingPosition);

      // The anchor point for any selection is the cell that was current
      // when the selection mode started.
      final TrinaGridCellPosition? anchorPosition = currentCellPosition;
      if (anchorPosition == null) {
        return;
      }
      if (selectingMode.isRow) {
        _updateSelectedRows(
          anchorPosition,
          oldSelectingPosition,
          newSelectingPosition,
        );
      } else {
        _updateSelectedCells(
          anchorPosition,
          newSelectingPosition,
          oldSelectingPosition,
        );
      }
      handleOnSelected();
    }
  }

  void _updateSelectedCells(
    TrinaGridCellPosition anchorPosition,
    TrinaGridCellPosition newSelectingPosition,
    TrinaGridCellPosition? oldSelectingPosition,
  ) {
    // This is the first move of a new selection drag.
    // The "old range" is effectively just the anchor cell itself.
    if (oldSelectingPosition == null) {
      // The new range is from the anchor to the new position.

      selectCellsInRange(anchorPosition, newSelectingPosition, notify: false);
    } else {
      // For subsequent moves, calculate the difference.

      // 1. Get the map of cells in the old and new selection rectangles.
      final Map<String, TrinaCell> oldRangeMap =
          _getCellsMapInRange(anchorPosition, oldSelectingPosition);
      final Map<String, TrinaCell> newRangeMap =
          _getCellsMapInRange(anchorPosition, newSelectingPosition);

      // 2. Use Sets to efficiently find the difference.
      final Set<String> oldKeys = oldRangeMap.keys.toSet();
      final Set<String> newKeys = newRangeMap.keys.toSet();

      // 3. Determine which cells to add and which to remove.
      final Set<String> keysToSelect = newKeys.difference(oldKeys);
      final Set<String> keysToUnselect = oldKeys.difference(newKeys);

      // 4. Apply the new selection.
      for (final key in keysToUnselect) {
        toggleCellSelection(oldRangeMap[key]!, notify: false);
      }
      for (final key in keysToSelect) {
        toggleCellSelection(newRangeMap[key]!, notify: false);
      }
    }
  }

  /// Helper method to get a map of all cells within a rectangular range.
  Map<String, TrinaCell> _getCellsMapInRange(
    TrinaGridCellPosition pos1,
    TrinaGridCellPosition pos2,
  ) {
    final Map<String, TrinaCell> cellsInRange = {};
    final columnIndexes = columnIndexesByShowFrozen;

    // Normalize coordinates to get top-left and bottom-right corners
    final int startCol = min(pos1.columnIdx!, pos2.columnIdx!);
    final int endCol = max(pos1.columnIdx!, pos2.columnIdx!);
    final int startRow = min(pos1.rowIdx!, pos2.rowIdx!);
    final int endRow = max(pos1.rowIdx!, pos2.rowIdx!);

    for (int i = startRow; i <= endRow; i++) {
      for (int j = startCol; j <= endCol; j++) {
        final String field = refColumns[columnIndexes[j]].field;
        final TrinaCell cell = refRows[i].cells[field]!;
        cellsInRange[cell.key.toString()] = cell;
      }
    }
    return cellsInRange;
  }

  void _updateSelectedRows(
    TrinaGridCellPosition anchorPosition,
    TrinaGridCellPosition? oldSelectingPosition,
    TrinaGridCellPosition newSelectingPosition,
  ) {
    final int anchorRow = anchorPosition.rowIdx!;
    final int newEndRow = newSelectingPosition.rowIdx!;

    // This check is crucial. If oldSelectingPosition is null, it's the first
    // move after pressing Shift. We must select the range.
    if (oldSelectingPosition == null) {
      selectRowsInRange(anchorRow, newEndRow, notify: false);
    } else {
      final int oldEndRow = oldSelectingPosition.rowIdx!;
      // Check if we are moving towards the anchor row.
      final bool isShrinkingSelection =
          (newEndRow - anchorRow).abs() < (oldEndRow - anchorRow).abs();

      if (isShrinkingSelection) {
        // If we are shrinking, unselect the row we just moved away from.
        toggleSelectingRow(oldEndRow, notify: false);
      } else {
        // If we are extending, select the new row
        toggleSelectingRow(newEndRow, notify: false);
      }
    }
  }

  @override
  void moveSelectingCellToEdgeOfColumns(
    TrinaMoveDirection direction, {
    bool force = false,
    bool notify = true,
  }) {
    if (!direction.horizontal) {
      return;
    }

    if (!force && isEditing == true) {
      return;
    }

    if (currentCellPosition == null) {
      return;
    }

    direction.isLeft
        ? scroll.horizontal!.jumpTo(0)
        : scroll.horizontal!.jumpTo(scroll.maxScrollHorizontal);

    if (selectingMode.isCell == false || currentCellPosition == null) {
      return;
    }
    final int columnIdx = direction.isLeft ? 0 : refColumns.length - 1;

    final int? rowIdx = hasCurrentSelectingPosition
        ? currentSelectingPosition!.rowIdx
        : currentCellPosition!.rowIdx;

    final newSelectionPosition =
        TrinaGridCellPosition(columnIdx: columnIdx, rowIdx: rowIdx);

    clearCurrentSelecting(notify: false);

    setCurrentSelectingPosition(
      cellPosition: newSelectionPosition,
      notify: notify,
    );
    selectCellsInRange(
      currentCellPosition!,
      newSelectionPosition,
      notify: false,
    );
    handleOnSelected();
  }

  @override
  void moveSelectingCellToEdgeOfRows(
    TrinaMoveDirection direction, {
    bool force = false,
    bool notify = true,
  }) {
    if (!direction.vertical) {
      return;
    }

    if (!force && isEditing == true) {
      return;
    }

    if (currentCellPosition == null) {
      return;
    }

    /// The current cell column index
    final columnIdx = hasCurrentSelectingPosition
        ? currentSelectingPosition!.columnIdx
        : currentCellPosition!.columnIdx;

    clearCurrentSelecting(notify: false);

    final int rowIdx = direction.isUp ? 0 : refRows.length - 1;

    setCurrentSelectingPosition(
      cellPosition: TrinaGridCellPosition(columnIdx: columnIdx, rowIdx: rowIdx),
      notify: notify,
    );

    if (selectingMode.isRow) {
      selectRowsInRange(
        currentCellPosition?.rowIdx,
        currentSelectingPosition?.rowIdx,
        notify: false,
      );
      handleOnSelected();
    }
    if (selectingMode.isCell) {
      selectCellsInRange(
        currentCellPosition!,
        TrinaGridCellPosition(columnIdx: columnIdx, rowIdx: rowIdx),
        notify: false,
      );
      handleOnSelected();
    }

    direction.isUp
        ? scroll.vertical!.jumpTo(0)
        : scroll.vertical!.jumpTo(scroll.maxScrollVertical);
  }

  @override
  void moveSelectingCellByRowIdx(
    int rowIdx,
    TrinaMoveDirection direction, {
    bool notify = true,
  }) {
    int moveToRowId = rowIdx;
    if (moveToRowId < 0) {
      moveToRowId = 0;
    }

    if (moveToRowId > refRows.length - 1) {
      moveToRowId = refRows.length - 1;
    }

    if (currentCell == null) {
      return;
    }

    int? columnIdx = hasCurrentSelectingPosition
        ? currentSelectingPosition!.columnIdx
        : currentCellPosition!.columnIdx;

    clearCurrentSelecting(notify: false);

    setCurrentSelectingPosition(
      cellPosition:
          TrinaGridCellPosition(columnIdx: columnIdx, rowIdx: moveToRowId),
    );
    if (currentCellPosition?.hasPosition != true) {
      setCurrentCellPosition(
        TrinaGridCellPosition(
          rowIdx: currentRowIdx,
          columnIdx: columnIndex(currentCell!.column),
        ),
        notify: false,
      );
    }
    if (selectingMode.isRow) {
      selectRowsInRange(
        currentCellPosition?.rowIdx,
        currentSelectingPosition?.rowIdx,
        notify: false,
      );
      handleOnSelected();
    } else if (selectingMode.isCell) {
      selectCellsInRange(
        currentCellPosition!,
        currentSelectingPosition!,
        notify: false,
      );
      handleOnSelected();
    }
    moveScrollByRow(direction, rowIdx - direction.offset);
  }
}
