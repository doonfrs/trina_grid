import 'package:flutter/material.dart';
import 'package:trina_grid/trina_grid.dart';

abstract class ICellState {
  /// currently selected cell.
  TrinaCell? get currentCell;

  /// The position index value of the currently selected cell.
  TrinaGridCellPosition? get currentCellPosition;

  TrinaCell? get firstCell;

  void setCurrentCellPosition(
    TrinaGridCellPosition cellPosition, {
    bool notify = true,
  });

  void updateCurrentCellPosition({bool notify = true});

  /// Index position of cell in a column
  TrinaGridCellPosition? cellPositionByCellKey(Key cellKey);

  int? columnIdxByCellKeyAndRowIdx(Key cellKey, int rowIdx);

  /// set currentCell to null
  void clearCurrentCell({bool notify = true});

  /// Change the selected cell.
  void setCurrentCell(TrinaCell? cell, int? rowIdx, {bool notify = true});

  /// Whether it is possible to move in the [direction] from [cellPosition].
  bool canMoveCell(
    TrinaGridCellPosition cellPosition,
    TrinaMoveDirection direction,
  );

  bool canNotMoveCell(
    TrinaGridCellPosition? cellPosition,
    TrinaMoveDirection direction,
  );

  /// Whether the cell is in a mutable state
  bool canChangeCellValue({
    required TrinaCell cell,
    dynamic newValue,
    dynamic oldValue,
  });

  bool canNotChangeCellValue({
    required TrinaCell cell,
    dynamic newValue,
    dynamic oldValue,
  });

  /// Filter on cell value change
  dynamic filteredCellValue({
    required TrinaColumn column,
    dynamic newValue,
    dynamic oldValue,
  });

  /// Whether the cell is the currently selected cell.
  bool isCurrentCell(TrinaCell cell);

  bool isInvalidCellPosition(TrinaGridCellPosition? cellPosition);
}

class _State {
  TrinaCell? _currentCell;

  TrinaGridCellPosition? _currentCellPosition;
}

mixin CellState implements ITrinaGridState {
  final _State _state = _State();

  @override
  TrinaCell? get currentCell => _state._currentCell;

  @override
  TrinaGridCellPosition? get currentCellPosition => _state._currentCellPosition;

  @override
  TrinaCell? get firstCell {
    if (refRows.isEmpty || refColumns.isEmpty) {
      return null;
    }

    final columnIndexes = columnIndexesByShowFrozen;

    final columnField = refColumns[columnIndexes.first].field;

    return refRows.first.cells[columnField];
  }

  @override
  void setCurrentCellPosition(
    TrinaGridCellPosition? cellPosition, {
    bool notify = true,
  }) {
    if (currentCellPosition == cellPosition) {
      return;
    }

    if (cellPosition == null) {
      clearCurrentCell(notify: false);
    } else if (isInvalidCellPosition(cellPosition)) {
      return;
    }

    _state._currentCellPosition = cellPosition;

    notifyListeners(notify, setCurrentCellPosition.hashCode);
  }

  @override
  void updateCurrentCellPosition({bool notify = true}) {
    if (currentCell == null) {
      return;
    }

    setCurrentCellPosition(
      cellPositionByCellKey(currentCell!.key),
      notify: false,
    );

    notifyListeners(notify, updateCurrentCellPosition.hashCode);
  }

  @override
  TrinaGridCellPosition? cellPositionByCellKey(Key? cellKey) {
    if (cellKey == null) {
      return null;
    }

    final length = refRows.length;

    for (int rowIdx = 0; rowIdx < length; rowIdx += 1) {
      final columnIdx = columnIdxByCellKeyAndRowIdx(cellKey, rowIdx);

      if (columnIdx != null) {
        return TrinaGridCellPosition(columnIdx: columnIdx, rowIdx: rowIdx);
      }
    }

    return null;
  }

  @override
  int? columnIdxByCellKeyAndRowIdx(Key cellKey, int rowIdx) {
    if (rowIdx < 0 || rowIdx >= refRows.length) {
      return null;
    }

    final columnIndexes = columnIndexesByShowFrozen;
    final length = columnIndexes.length;

    for (int columnIdx = 0; columnIdx < length; columnIdx += 1) {
      final field = refColumns[columnIndexes[columnIdx]].field;

      if (refRows[rowIdx].cells[field]!.key == cellKey) {
        return columnIdx;
      }
    }

    return null;
  }

  @override
  void clearCurrentCell({bool notify = true}) {
    if (currentCell == null) {
      return;
    }

    _state._currentCell = null;

    _state._currentCellPosition = null;

    notifyListeners(notify, clearCurrentCell.hashCode);
  }

  @override
  void setCurrentCell(TrinaCell? cell, int? rowIdx, {bool notify = true}) {
    debugPrint(
      '[Selection] setCurrentCell called - rowIdx: $rowIdx, notify: $notify, ctrl: ${keyPressed.ctrl}, shift: ${keyPressed.shift}',
    );

    if (cell == null ||
        rowIdx == null ||
        refRows.isEmpty ||
        rowIdx < 0 ||
        rowIdx > refRows.length - 1) {
      debugPrint(
        '[Selection] setCurrentCell - Invalid cell or rowIdx, returning',
      );
      return;
    }

    if (currentCell != null && currentCell!.key == cell.key) {
      debugPrint('[Selection] setCurrentCell - Same cell, returning');
      return;
    }

    // Call onBeforeActiveCellChange callback before changing state
    if (onBeforeActiveCellChange != null) {
      final shouldProceed = onBeforeActiveCellChange!(
        TrinaGridOnBeforeActiveCellChangeEvent(
          oldCell: currentCell,
          oldRowIdx: currentCellPosition?.rowIdx,
          newCell: cell,
          newRowIdx: rowIdx,
        ),
      );

      // If callback returns false, cancel the cell change
      if (!shouldProceed) {
        debugPrint(
          '[Selection] setCurrentCell - Callback returned false, canceling',
        );
        return;
      }
    }

    _state._currentCell = cell;

    _state._currentCellPosition = TrinaGridCellPosition(
      rowIdx: rowIdx,
      columnIdx: columnIdxByCellKeyAndRowIdx(cell.key, rowIdx),
    );

    // When Ctrl+Click multi-select is enabled, preserve individual selections
    // when setting current cell. Only clear range selections.
    if (configuration.enableCtrlClickMultiSelect &&
        selectingMode == TrinaGridSelectingMode.cell) {
      debugPrint(
        '[Selection] setCurrentCell - Ctrl+Click mode enabled, clearing only range selections',
      );
      // Clear only range selection, preserve individual selections
      clearRangeSelections(notify: false);
    } else {
      debugPrint(
        '[Selection] setCurrentCell - Standard mode, clearing all selections',
      );
      // Clear all selections (range + individual + rows)
      clearCurrentSelecting(notify: false);
    }

    setEditing(autoEditing, notify: false);

    notifyListeners(notify, setCurrentCell.hashCode);

    onActiveCellChanged?.call(
      TrinaGridOnActiveCellChangedEvent(idx: rowIdx, cell: _state._currentCell),
    );
  }

  @override
  bool canMoveCell(
    TrinaGridCellPosition? cellPosition,
    TrinaMoveDirection direction,
  ) {
    if (cellPosition == null || !cellPosition.hasPosition) return false;

    switch (direction) {
      case TrinaMoveDirection.left:
        return cellPosition.columnIdx! > 0;
      case TrinaMoveDirection.right:
        return cellPosition.columnIdx! < refColumns.length - 1;
      case TrinaMoveDirection.up:
        return cellPosition.rowIdx! > 0;
      case TrinaMoveDirection.down:
        return cellPosition.rowIdx! < refRows.length - 1;
    }
  }

  @override
  bool canNotMoveCell(
    TrinaGridCellPosition? cellPosition,
    TrinaMoveDirection direction,
  ) {
    return !canMoveCell(cellPosition, direction);
  }

  @override
  bool canChangeCellValue({
    required TrinaCell cell,
    dynamic newValue,
    dynamic oldValue,
  }) {
    if (!mode.isEditableMode) {
      return false;
    }

    if (cell.column.checkReadOnly(
      cell.row,
      cell.row.cells[cell.column.field]!,
    )) {
      return false;
    }

    if (!isEditableCell(cell)) {
      return false;
    }

    if (newValue.toString() == oldValue.toString()) {
      return false;
    }

    return true;
  }

  @override
  bool canNotChangeCellValue({
    required TrinaCell cell,
    dynamic newValue,
    dynamic oldValue,
  }) {
    return !canChangeCellValue(
      cell: cell,
      newValue: newValue,
      oldValue: oldValue,
    );
  }

  @override
  dynamic filteredCellValue({
    required TrinaColumn column,
    dynamic newValue,
    dynamic oldValue,
  }) {
    final typeResult = column.type.filteredValue(
      oldValue: oldValue,
      newValue: newValue,
    );
    if (typeResult.$1) return typeResult.$2;

    if (column.type.isSelect) {
      return column.type.asSelect().items.contains(newValue) == true
          ? newValue
          : oldValue;
    }

    if (column.type.isDate) {
      try {
        final parseNewValue = column.type.date.dateFormat.parse(
          newValue.toString(),
        );

        return TrinaDateTimeHelper.isValidRange(
              date: parseNewValue,
              start: column.type.date.startDate,
              end: column.type.date.endDate,
            )
            ? column.type.date.dateFormat.format(parseNewValue)
            : oldValue;
      } catch (e) {
        return oldValue;
      }
    }

    if (column.type.isTime) {
      final time = RegExp(r'^([0-1]?\d|2[0-3]):[0-5]\d$');

      return time.hasMatch(newValue.toString()) ? newValue : oldValue;
    }

    return newValue;
  }

  @override
  bool isCurrentCell(TrinaCell? cell) {
    return currentCell != null && currentCell!.key == cell!.key;
  }

  @override
  bool isInvalidCellPosition(TrinaGridCellPosition? cellPosition) {
    return cellPosition == null ||
        cellPosition.columnIdx == null ||
        cellPosition.rowIdx == null ||
        cellPosition.columnIdx! < 0 ||
        cellPosition.rowIdx! < 0 ||
        cellPosition.columnIdx! > refColumns.length - 1 ||
        cellPosition.rowIdx! > refRows.length - 1;
  }
}
