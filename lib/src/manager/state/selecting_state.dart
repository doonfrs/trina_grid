import 'dart:math';

import 'package:collection/collection.dart';
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

  /// Position list of currently selected.
  /// Only valid in [TrinaGridSelectingMode.cell].
  ///
  /// ```dart
  /// stateManager.currentSelectingPositionList.forEach((element) {
  ///   final cellValue = stateManager.rows[element.rowIdx].cells[element.field].value;
  /// });
  /// ```
  List<TrinaGridSelectingCellPosition> get currentSelectingPositionList;

  bool get hasCurrentSelectingPosition;

  /// Currently selected rows.
  List<TrinaRow> get selectedRows;

  /// String of multi-selected cells.
  /// Preserves the structure of the cells selected by the tabs and the enter key.
  String get currentSelectingText;

  /// Change Multi-Select Status.
  void setSelecting(bool flag, {bool notify = true});

  /// Set the mode to select cells or rows.
  ///
  /// If [TrinaGrid.mode] is [TrinaGridMode.select] or [TrinaGridMode.selectWithOneTap]
  /// Coerced to [TrinaGridSelectingMode.disabled] regardless of [selectingMode] value.
  ///
  /// When [TrinaGrid.mode] is [TrinaGridMode.multiSelect]
  /// Coerced to [TrinaGridSelectingMode.row] regardless of [selectingMode] value.
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

  /// Sets the currentSelectingRows by range.
  /// [from] rowIdx of rows.
  /// [to] rowIdx of rows.
  void setCurrentSelectingRowsByRange(int from, int to, {bool notify = true});

  /// Resets currently selected rows and cells.
  void clearCurrentSelecting({bool notify = true});

  /// Select or unselect a row.
  void toggleSelectingRow(int rowIdx, {bool notify = true});

  bool isSelectingInteraction();

  bool isSelectedRow(Key rowKey);

  /// Whether the cell is the currently multi selected cell.
  bool isSelectedCell(TrinaCell cell, TrinaColumn column, int rowIdx);

  /// The action that is selected in the Select dialog
  /// and processed after the dialog is closed.
  void handleAfterSelectingRow(TrinaCell cell, dynamic value);
}

class _State {
  bool _isSelecting = false;

  TrinaGridSelectingMode _selectingMode =
      TrinaGridSelectingMode.cellWithSingleTap;

  List<TrinaRow> _currentSelectingRows = [];

  TrinaGridCellPosition? _currentSelectingPosition;
}

mixin SelectingState implements ITrinaGridState {
  final _State _state = _State();

  @override
  bool get isSelecting => _state._isSelecting;

  @override
  TrinaGridSelectingMode get selectingMode => _state._selectingMode;

  @override
  TrinaGridCellPosition? get currentSelectingPosition =>
      _state._currentSelectingPosition;

  @override
  List<TrinaGridSelectingCellPosition> get currentSelectingPositionList {
    if (currentCellPosition == null || currentSelectingPosition == null) {
      return [];
    }

    switch (selectingMode) {
      case TrinaGridSelectingMode.cellWithCtrl:
      case TrinaGridSelectingMode.cellWithSingleTap:
        return _selectingCells();
      case TrinaGridSelectingMode.horizontal:
        return _selectingCellsHorizontally();
      case TrinaGridSelectingMode.rowWithCtrl:
      case TrinaGridSelectingMode.rowWithSingleTap:
      case TrinaGridSelectingMode.disabled:
        return [];
    }
  }

  @override
  bool get hasCurrentSelectingPosition => currentSelectingPosition != null;

  @override
  List<TrinaRow> get currentSelectingRows {
    List<TrinaRow> rows = [];
    rows = _state._currentSelectingRows;
    if (currentRowIdx != null && selectingMode.isRow) {
      if (!rows.contains(refRows[currentRowIdx!])) {
        rows.add(refRows[currentRowIdx!]);
      }
      rows.sort((a, b) => a.sortIdx.compareTo(b.sortIdx));
    }
    return rows;
  }

  @override
  String get currentSelectingText {
    final bool fromSelectingRows =
        selectingMode.isRow && currentSelectingRows.isNotEmpty;

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

    _state._currentSelectingRows = [];

    _state._currentSelectingPosition = null;

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
      case TrinaGridSelectingMode.horizontal:
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

        setCurrentSelectingRowsByRange(0, refRows.length - 1);
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

    if (currentSelectingPosition != null && selectingMode.isRow) {
      setCurrentSelectingRowsByRange(
        currentRowIdx,
        currentSelectingPosition!.rowIdx,
        notify: false,
      );
    }

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
  void setCurrentSelectingPositionWithOffset(Offset? offset) {
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

    if (gridBodyOffsetDy > offset!.dy) {
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
  void setCurrentSelectingRowsByRange(
    int? from,
    int? to, {
    bool notify = true,
  }) {
    if (!selectingMode.isRow) {
      return;
    }

    final maxFrom = min(from!, to!);

    final maxTo = max(from, to) + 1;

    if (maxFrom < 0 || maxTo > refRows.length) {
      return;
    }

    _state._currentSelectingRows = refRows.getRange(maxFrom, maxTo).toList();

    notifyListeners(notify, setCurrentSelectingRowsByRange.hashCode);
  }

  @override
  void clearCurrentSelecting({bool notify = true}) {
    _clearCurrentSelectingPosition(notify: false);

    _clearCurrentSelectingRows(notify: false);

    notifyListeners(notify, clearCurrentSelecting.hashCode);
  }

  @override
  void toggleSelectingRow(int? rowIdx, {notify = true}) {
    if (!selectingMode.isRow) {
      return;
    }

    if (rowIdx == null || rowIdx < 0 || rowIdx > refRows.length - 1) {
      return;
    }

    final TrinaRow row = refRows[rowIdx];

    final keys = Set.from(currentSelectingRows.map((e) => e.key));

    if (keys.contains(row.key)) {
      currentSelectingRows.removeWhere((element) => element.key == row.key);
    } else {
      currentSelectingRows.add(row);
    }

    notifyListeners(notify, toggleSelectingRow.hashCode);
  }

  @override
  bool isSelectingInteraction() {
    return !selectingMode.isDisabled &&
        (keyPressed.shift || keyPressed.ctrl) &&
        currentCell != null;
  }

  @override
  bool isSelectedRow(Key? rowKey) {
    if (rowKey == null ||
        !selectingMode.isRow ||
        currentSelectingRows.isEmpty) {
      return false;
    }

    return currentSelectingRows.firstWhereOrNull(
          (element) => element.key == rowKey,
        ) !=
        null;
  }

  // todo : code cleanup
  @override
  bool isSelectedCell(TrinaCell cell, TrinaColumn column, int rowIdx) {
    if (selectingMode.isDisabled) {
      return false;
    }

    if (currentCellPosition == null) {
      return false;
    }

    if (currentSelectingPosition == null) {
      return false;
    }

    if (selectingMode.isCell) {
      final bool inRangeOfRows = min(
                currentCellPosition!.rowIdx as num,
                currentSelectingPosition!.rowIdx as num,
              ) <=
              rowIdx &&
          rowIdx <=
              max(
                currentCellPosition!.rowIdx!,
                currentSelectingPosition!.rowIdx!,
              );

      if (inRangeOfRows == false) {
        return false;
      }

      final int? columnIdx = columnIndex(column);

      if (columnIdx == null) {
        return false;
      }

      final bool inRangeOfColumns = min(
                currentCellPosition!.columnIdx as num,
                currentSelectingPosition!.columnIdx as num,
              ) <=
              columnIdx &&
          columnIdx <=
              max(
                currentCellPosition!.columnIdx!,
                currentSelectingPosition!.columnIdx!,
              );

      if (inRangeOfColumns == false) {
        return false;
      }

      return true;
    } else if (selectingMode.isHorizontal) {
      int startRowIdx = min(
        currentCellPosition!.rowIdx!,
        currentSelectingPosition!.rowIdx!,
      );

      int endRowIdx = max(
        currentCellPosition!.rowIdx!,
        currentSelectingPosition!.rowIdx!,
      );

      final int? columnIdx = columnIndex(column);

      if (columnIdx == null) {
        return false;
      }

      int? startColumnIdx;

      int? endColumnIdx;

      if (currentCellPosition!.rowIdx! < currentSelectingPosition!.rowIdx!) {
        startColumnIdx = currentCellPosition!.columnIdx;
        endColumnIdx = currentSelectingPosition!.columnIdx;
      } else if (currentCellPosition!.rowIdx! >
          currentSelectingPosition!.rowIdx!) {
        startColumnIdx = currentSelectingPosition!.columnIdx;
        endColumnIdx = currentCellPosition!.columnIdx;
      } else {
        startColumnIdx = min(
          currentCellPosition!.columnIdx!,
          currentSelectingPosition!.columnIdx!,
        );
        endColumnIdx = max(
          currentCellPosition!.columnIdx!,
          currentSelectingPosition!.columnIdx!,
        );
      }

      if (rowIdx == startRowIdx && startRowIdx == endRowIdx) {
        return !(columnIdx < startColumnIdx! || columnIdx > endColumnIdx!);
      } else if (rowIdx == startRowIdx && columnIdx >= startColumnIdx!) {
        return true;
      } else if (rowIdx == endRowIdx && columnIdx <= endColumnIdx!) {
        return true;
      } else if (rowIdx > startRowIdx && rowIdx < endRowIdx) {
        return true;
      }

      return false;
    } else if (selectingMode.isRow) {
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

  List<TrinaGridSelectingCellPosition> _selectingCells() {
    final List<TrinaGridSelectingCellPosition> positions = [];

    final columnIndexes = columnIndexesByShowFrozen;

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
      for (int j = columnStartIdx; j <= columnEndIdx; j += 1) {
        final String field = refColumns[columnIndexes[j]].field;

        positions.add(TrinaGridSelectingCellPosition(rowIdx: i, field: field));
      }
    }

    return positions;
  }

  List<TrinaGridSelectingCellPosition> _selectingCellsHorizontally() {
    final List<TrinaGridSelectingCellPosition> positions = [];

    final columnIndexes = columnIndexesByShowFrozen;

    final bool firstCurrent = currentCellPosition!.rowIdx! <
            currentSelectingPosition!.rowIdx! ||
        (currentCellPosition!.rowIdx! == currentSelectingPosition!.rowIdx! &&
            currentCellPosition!.columnIdx! <=
                currentSelectingPosition!.columnIdx!);

    TrinaGridCellPosition startCell =
        firstCurrent ? currentCellPosition! : currentSelectingPosition!;

    TrinaGridCellPosition endCell =
        !firstCurrent ? currentCellPosition! : currentSelectingPosition!;

    int columnStartIdx = startCell.columnIdx!;

    int columnEndIdx = endCell.columnIdx!;

    int rowStartIdx = startCell.rowIdx!;

    int rowEndIdx = endCell.rowIdx!;

    final length = columnIndexes.length;

    for (int i = rowStartIdx; i <= rowEndIdx; i += 1) {
      for (int j = 0; j < length; j += 1) {
        if (i == rowStartIdx && j < columnStartIdx) {
          continue;
        }

        final String field = refColumns[columnIndexes[j]].field;

        positions.add(TrinaGridSelectingCellPosition(rowIdx: i, field: field));

        if (i == rowEndIdx && j == columnEndIdx) {
          break;
        }
      }
    }

    return positions;
  }

  String _selectingTextFromSelectingRows() {
    final columnIndexes = columnIndexesByShowFrozen;

    List<String> rowText = [];

    for (final row in currentSelectingRows) {
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

  void _clearCurrentSelectingPosition({bool notify = true}) {
    if (currentSelectingPosition == null) {
      return;
    }

    _state._currentSelectingPosition = null;

    if (notify) {
      notifyListeners();
    }
  }

  void _clearCurrentSelectingRows({bool notify = true}) {
    if (currentSelectingRows.isEmpty) {
      return;
    }

    _state._currentSelectingRows = [];

    if (notify) {
      notifyListeners();
    }
  }
}
