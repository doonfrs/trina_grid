import 'dart:math';

import 'package:flutter/material.dart';
import 'package:trina_grid/trina_grid.dart';

abstract class ISelectingState {
  /// Multi-selection state.
  bool get isSelecting;

  /// The selecting mode of the grid.
  TrinaGridSelectingMode get selectingMode;

  /// Current position of multi-select cell.
  /// Calculate the currently selected cell and its multi-selection range.
  TrinaGridCellPosition? get currentSelectingPosition;

  bool get hasCurrentSelectingPosition;

  /// Currently selected rows.
  List<TrinaRow> get selectedRows;

  /// String of multi-selected cells.
  /// Preserves the structure of the cells selected by the tabs and the enter key.
  String get currentSelectingText;

  /// Change Multi-Select Status.
  void setSelecting(bool flag, {bool notify = true});

  /// Set the mode to select cells or rows.
  void setSelectingMode(
    TrinaGridSelectingMode selectingMode, {
    bool notify = true,
  });

  void setAllCurrentSelecting();

  /// Sets the position of a multi-selected cell.
  void setCurrentSelectingPosition({
    TrinaGridCellPosition? cellPosition,
    bool notify = true,
  });

  void setCurrentSelectingPositionByCellKey(Key? cellKey, {bool notify = true});

  /// Sets the position of a multi-selected cell.
  void setCurrentSelectingPositionWithOffset(Offset offset);

  /// Sets the selectedRows by range.
  /// [from] rowIdx of rows.
  /// [to] rowIdx of rows.
  /// If [from] or [to] is null, it is set to [currentRowIdx].
  void selectRowsInRange(int? from, int? to, {bool notify = true});

  void setSelectedRows(List<TrinaRow> rows, {bool notify = true});

  /// Resets currently selected rows and cells.
  void clearCurrentSelecting({bool notify = true});

  /// Select or unselect a row.
  void toggleRowSelection(int rowIdx, {bool notify = true});

  bool isSelectingInteraction();

  bool isSelectedRow(Key rowKey);

  /// Currently selected cells.
  List<TrinaCell> get selectedCells;

  void toggleCellSelection(TrinaCell cell, {bool notify = true});
  void selectCellsInRange(
    TrinaGridCellPosition startPosition,
    TrinaGridCellPosition endPosition, {
    bool notify = true,
  });

  /// Whether the cell is currently selected.
  bool isSelectedCell(TrinaCell cell);

  /// The action that is selected in the Select dialog
  /// and processed after the dialog is closed.
  void handleAfterSelectingRow(TrinaCell cell, dynamic value);
}

class _State {
  bool _isSelecting = false;

  TrinaGridSelectingMode _selectingMode =
      TrinaGridSelectingMode.cellWithSingleTap;

  final Map<String, TrinaRow> _selectedRows = {};
  List<TrinaRow> _sortedRows = [];
  final Map<String, TrinaCell> _selectedCells = {};

  TrinaGridCellPosition? _currentSelectingPosition;
}

mixin SelectingState implements ITrinaGridState {
  final _State _state = _State();

  @override
  bool get isSelecting => _state._isSelecting;

  @override
  TrinaGridSelectingMode get selectingMode => _state._selectingMode;

  @override
  get selectedCells => _state._selectedCells.values.toList();

  @override
  TrinaGridCellPosition? get currentSelectingPosition =>
      _state._currentSelectingPosition;

  @override
  bool get hasCurrentSelectingPosition => currentSelectingPosition != null;

  @override
  List<TrinaRow> get selectedRows => _state._sortedRows;

  @override
  String get currentSelectingText {
    final bool fromSelectingRows =
        selectingMode.isRow && selectedRows.isNotEmpty;

    final bool fromSelectingPosition =
        currentCellPosition != null && currentSelectingPosition != null;

    final bool fromCurrentCell = currentCellPosition != null;

    if (fromSelectingRows) {
      return _selectingTextFromSelectingRows();
    } else if (fromSelectingPosition) {
      return _selectingTextFromSelectingPosition();
    } else if (fromCurrentCell) {
      return _selectingTextFromCurrentCell();
    }

    return '';
  }

  @override
  void setSelecting(bool flag, {bool notify = true}) {
    if (selectingMode.isDisabled) {
      return;
    }

    if (currentCell == null || isSelecting == flag) {
      return;
    }

    _state._isSelecting = flag;

    if (isEditing == true) {
      setEditing(false, notify: false);
    }

    // Invalidates the previously selected row.
    if (isSelecting) {
      clearCurrentSelecting(notify: false);
    }

    notifyListeners(notify, setSelecting.hashCode);
  }

  @override
  void setSelectingMode(
    TrinaGridSelectingMode selectingMode, {
    bool notify = true,
  }) {
    if (_state._selectingMode == selectingMode) {
      return;
    }
    _state._currentSelectingPosition = null;

    _clearSelectedRows(notify: false);

    _clearSelectedCells(notify: false);

    _state._selectingMode = selectingMode;

    notifyListeners(notify, setSelectingMode.hashCode);
  }

  @override
  void setAllCurrentSelecting() {
    if (refRows.isEmpty) {
      return;
    }

    switch (selectingMode) {
      case TrinaGridSelectingMode.cellWithCtrl:
      case TrinaGridSelectingMode.cellWithSingleTap:
        _setFistCellAsCurrent();

        setCurrentSelectingPosition(
          cellPosition: TrinaGridCellPosition(
            columnIdx: refColumns.length - 1,
            rowIdx: refRows.length - 1,
          ),
        );
        break;
      case TrinaGridSelectingMode.rowWithCtrl:
      case TrinaGridSelectingMode.rowWithSingleTap:
        if (currentCell == null) {
          _setFistCellAsCurrent();
        }

        _state._currentSelectingPosition = TrinaGridCellPosition(
          columnIdx: refColumns.length - 1,
          rowIdx: refRows.length - 1,
        );

        selectRowsInRange(0, refRows.length - 1);
        break;
      case TrinaGridSelectingMode.disabled:
        break;
    }
  }

  @override
  void setCurrentSelectingPosition({
    TrinaGridCellPosition? cellPosition,
    bool notify = true,
  }) {
    if (selectingMode.isDisabled) {
      return;
    }

    if (currentSelectingPosition == cellPosition) {
      return;
    }

    _state._currentSelectingPosition =
        isInvalidCellPosition(cellPosition) ? null : cellPosition;

    notifyListeners(notify, setCurrentSelectingPosition.hashCode);
  }

  @override
  void setCurrentSelectingPositionByCellKey(
    Key? cellKey, {
    bool notify = true,
  }) {
    if (cellKey == null) {
      return;
    }

    setCurrentSelectingPosition(
      cellPosition: cellPositionByCellKey(cellKey),
      notify: notify,
    );
  }

  @override
  void setCurrentSelectingPositionWithOffset(Offset offset) {
    if (currentCell == null) {
      return;
    }

    final double gridBodyOffsetDy = gridGlobalOffset!.dy +
        gridBorderWidth +
        headerHeight +
        columnGroupHeight +
        columnHeight +
        columnFilterHeight;

    double currentCellOffsetDy = (currentRowIdx! * rowTotalHeight) +
        gridBodyOffsetDy -
        scroll.vertical!.offset;

    if (gridBodyOffsetDy > offset.dy) {
      return;
    }

    int rowIdx = (((currentCellOffsetDy - offset.dy) / rowTotalHeight).ceil() -
            currentRowIdx!)
        .abs();

    int? columnIdx;

    final directionalOffset = toDirectionalOffset(offset);
    double currentWidth = isLTR ? gridGlobalOffset!.dx : 0.0;

    final columnIndexes = columnIndexesByShowFrozen;

    final savedRightBlankOffset = rightBlankOffset;
    final savedHorizontalScrollOffset = scroll.horizontal!.offset;

    for (int i = 0; i < columnIndexes.length; i += 1) {
      final column = refColumns[columnIndexes[i]];

      currentWidth += column.width;

      final rightFrozenColumnOffset =
          column.frozen.isEnd && showFrozenColumn ? savedRightBlankOffset : 0;

      if (currentWidth + rightFrozenColumnOffset >
          directionalOffset.dx + savedHorizontalScrollOffset) {
        columnIdx = i;
        break;
      }
    }

    if (columnIdx == null) {
      return;
    }

    setCurrentSelectingPosition(
      cellPosition: TrinaGridCellPosition(columnIdx: columnIdx, rowIdx: rowIdx),
    );
  }

  @override
  void selectRowsInRange(
    int? from,
    int? to, {
    bool notify = true,
  }) {
    if (!selectingMode.isRow) {
      return;
    }

    final safeFrom = from ?? currentRowIdx;
    final safeTo = to ?? currentRowIdx;

    if (safeFrom == null || safeTo == null) {
      return;
    }

    final maxFrom = min(safeFrom, safeTo);
    final maxTo = max(safeFrom, safeTo);

    if (maxFrom < 0 || maxTo >= refRows.length) {
      return;
    }

    for (int i = maxFrom; i <= maxTo; i += 1) {
      final TrinaRow row = refRows[i];
      _state._selectedRows[row.key.toString()] = row;
    }

    _updateSortedRows();

    notifyListeners(notify, selectRowsInRange.hashCode);
  }

  @override
  void setSelectedRows(
    List<TrinaRow> rows, {
    bool notify = true,
  }) {
    if (!selectingMode.isRow) {
      return;
    }

    _clearSelectedRows(notify: false);

    for (final row in rows) {
      _state._selectedRows[row.key.toString()] = row;
    }

    _updateSortedRows();

    notifyListeners(notify, setSelectedRows.hashCode);
  }

  @override
  void clearCurrentSelecting({bool notify = true}) {
    _clearCurrentSelectingPosition(notify: false);

    _clearSelectedRows(notify: false);
    _clearSelectedCells(notify: false);

    notifyListeners(notify, clearCurrentSelecting.hashCode);
  }

  @override
  void toggleRowSelection(int? rowIdx, {notify = true}) {
    if (!selectingMode.isRow) {
      return;
    }

    if (rowIdx == null || rowIdx < 0 || rowIdx > refRows.length - 1) {
      return;
    }

    final TrinaRow row = refRows[rowIdx];

    final rowKey = row.key.toString();
    if (_state._selectedRows.containsKey(rowKey)) {
      _state._selectedRows.remove(rowKey);
    } else {
      _state._selectedRows[rowKey] = row;
    }
    _updateSortedRows();

    notifyListeners(notify, toggleRowSelection.hashCode);
  }

  @override
  void toggleCellSelection(TrinaCell cell, {bool notify = true}) {
    if (!selectingMode.isCell) {
      return;
    }

    final cellKey = cell.key.toString();

    if (_state._selectedCells.containsKey(cellKey)) {
      _state._selectedCells.remove(cellKey);
    } else {
      _state._selectedCells[cellKey] = cell;
    }

    notifyListeners(notify, toggleCellSelection.hashCode);
  }

  @override
  void selectCellsInRange(
    TrinaGridCellPosition startPosition,
    TrinaGridCellPosition endPosition, {
    bool notify = true,
  }) {
    if (!selectingMode.isCell) {
      return;
    }

    final columnIndexes = columnIndexesByShowFrozen;

    int columnStartIdx = min(
      startPosition.columnIdx!,
      endPosition.columnIdx!,
    );

    int columnEndIdx = max(
      startPosition.columnIdx!,
      endPosition.columnIdx!,
    );

    int rowStartIdx = min(
      startPosition.rowIdx!,
      endPosition.rowIdx!,
    );

    int rowEndIdx = max(
      startPosition.rowIdx!,
      endPosition.rowIdx!,
    );

    for (int i = rowStartIdx; i <= rowEndIdx; i += 1) {
      for (int j = columnStartIdx; j <= columnEndIdx; j += 1) {
        final String field = refColumns[columnIndexes[j]].field;
        final TrinaCell cell = refRows[i].cells[field]!;
        _state._selectedCells[cell.key.toString()] = cell;
      }
    }

    notifyListeners(notify, selectCellsInRange.hashCode);
  }

  @override
  bool isSelectingInteraction() {
    return !selectingMode.isDisabled &&
        (keyPressed.shift || keyPressed.ctrl) &&
        currentCellPosition != null;
  }

  @override
  bool isSelectedRow(Key? rowKey) {
    if (rowKey == null || !selectingMode.isRow || selectedRows.isEmpty) {
      return false;
    }

    return _state._selectedRows.containsKey(rowKey.toString());
  }

  @override
  bool isSelectedCell(TrinaCell cell) {
    if (selectingMode.isDisabled) {
      return false;
    }
    // If in cell selection mode (Ctrl or Single Tap), check if the cell is in the _selectedCells map.
    if (selectingMode.isCell) {
      return _state._selectedCells.containsKey(cell.key.toString());
    }

    // For range selection modes (horizontal), use the range logic.
    if (currentCellPosition == null || currentSelectingPosition == null) {
      return false;
    }

    if (selectingMode.isRow) {
      return false;
    } else {
      throw Exception('selectingMode is not handled');
    }
  }

  @override
  void handleAfterSelectingRow(TrinaCell cell, dynamic value) {
    changeCellValue(cell, value, notify: false);

    if (configuration.enableMoveDownAfterSelecting) {
      moveCurrentCell(TrinaMoveDirection.down, notify: false);

      setEditing(true, notify: false);
    }

    setKeepFocus(true, notify: false);

    notifyListeners(true, handleAfterSelectingRow.hashCode);
  }

  String _selectingTextFromSelectingRows() {
    final columnIndexes = columnIndexesByShowFrozen;

    List<String> rowText = [];

    for (final row in selectedRows) {
      List<String> columnText = [];

      for (int i = 0; i < columnIndexes.length; i += 1) {
        final String field = refColumns[columnIndexes[i]].field;

        columnText.add(row.cells[field]!.value.toString());
      }

      rowText.add(columnText.join('\t'));
    }

    return rowText.join('\n');
  }

  String _selectingTextFromSelectingPosition() {
    final columnIndexes = columnIndexesByShowFrozen;

    List<String> rowText = [];

    int columnStartIdx = min(
      currentCellPosition!.columnIdx!,
      currentSelectingPosition!.columnIdx!,
    );

    int columnEndIdx = max(
      currentCellPosition!.columnIdx!,
      currentSelectingPosition!.columnIdx!,
    );

    int rowStartIdx = min(
      currentCellPosition!.rowIdx!,
      currentSelectingPosition!.rowIdx!,
    );

    int rowEndIdx = max(
      currentCellPosition!.rowIdx!,
      currentSelectingPosition!.rowIdx!,
    );

    for (int i = rowStartIdx; i <= rowEndIdx; i += 1) {
      List<String> columnText = [];

      for (int j = columnStartIdx; j <= columnEndIdx; j += 1) {
        final String field = refColumns[columnIndexes[j]].field;

        columnText.add(refRows[i].cells[field]!.value.toString());
      }

      rowText.add(columnText.join('\t'));
    }

    return rowText.join('\n');
  }

  String _selectingTextFromCurrentCell() {
    return currentCell!.value.toString();
  }

  void _setFistCellAsCurrent() {
    setCurrentCell(firstCell, 0, notify: false);

    if (isEditing == true) {
      setEditing(false, notify: false);
    }
  }

  void _updateSortedRows() {
    _state._sortedRows = _state._selectedRows.values.toList();
    _state._sortedRows.sort((a, b) => a.sortIdx.compareTo(b.sortIdx));
  }

  void _clearCurrentSelectingPosition({bool notify = true}) {
    if (currentSelectingPosition == null) {
      return;
    }

    _state._currentSelectingPosition = null;

    if (notify) {
      notifyListeners();
    }
  }

  void _clearSelectedRows({bool notify = true}) {
    if (selectedRows.isEmpty) {
      return;
    }

    _state._selectedRows.clear();
    _state._sortedRows.clear();

    if (notify) {
      notifyListeners();
    }
  }

  void _clearSelectedCells({bool notify = true}) {
    if (_state._selectedCells.isEmpty) {
      return;
    }

    _state._selectedCells.clear();

    if (notify) {
      notifyListeners();
    }
  }
}
