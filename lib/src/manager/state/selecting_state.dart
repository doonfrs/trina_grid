import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:trina_grid/trina_grid.dart';

abstract class ISelectingState {
  /// Multi-selection state.
  bool get isSelecting;

  /// [selectingMode]
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

  /// Rows of currently selected.
  /// Only valid in [TrinaGridSelectingMode.row].
  List<TrinaRow> get currentSelectingRows;

  /// String of multi-selected cells.
  /// Preserves the structure of the cells selected by the tabs and the enter key.
  String get currentSelectingText;

  /// Change Multi-Select Status.
  void setSelecting(bool flag, {bool notify = true});

  /// Set the mode to select cells or rows.
  ///
  /// If [TrinaGrid.mode] is [TrinaGridMode.select] or [TrinaGridMode.selectWithOneTap]
  /// Coerced to [TrinaGridSelectingMode.none] regardless of [selectingMode] value.
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

  /// Clear only range selections, preserving individual cell selections.
  /// Used when Ctrl+Click multi-select is enabled to preserve individual selections.
  void clearRangeSelections({bool notify = true});

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

  TrinaGridSelectingMode _selectingMode = TrinaGridSelectingMode.cell;

  List<TrinaRow> _currentSelectingRows = [];

  TrinaGridCellPosition? _currentSelectingPosition;

  // Individual cell tracking for Ctrl+Click multi-select
  final Set<TrinaGridCellPosition> _individuallySelectedCells = {};

  // Drag state tracking
  bool _isDragSelecting = false;
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
    final List<TrinaGridSelectingCellPosition> positions = [];

    // Add range selections
    if (currentCellPosition != null && currentSelectingPosition != null) {
      switch (selectingMode) {
        case TrinaGridSelectingMode.cell:
          positions.addAll(_selectingCells());
          break;
        case TrinaGridSelectingMode.horizontal:
          positions.addAll(_selectingCellsHorizontally());
          break;
        case TrinaGridSelectingMode.row:
        case TrinaGridSelectingMode.none:
          break;
      }
    }

    // Add individual selections (for Ctrl+Click multi-select)
    if (configuration.enableCtrlClickMultiSelect && selectingMode.isCell) {
      final columnIndexes = columnIndexesByShowFrozen;
      for (final cellPos in _state._individuallySelectedCells) {
        if (cellPos.columnIdx != null &&
            cellPos.rowIdx != null &&
            cellPos.columnIdx! < columnIndexes.length &&
            cellPos.rowIdx! < refRows.length) {
          final String field =
              refColumns[columnIndexes[cellPos.columnIdx!]].field;
          final selectingPos = TrinaGridSelectingCellPosition(
            rowIdx: cellPos.rowIdx,
            field: field,
          );
          // Avoid duplicates
          if (!positions.any(
            (p) =>
                p.rowIdx == selectingPos.rowIdx &&
                p.field == selectingPos.field,
          )) {
            positions.add(selectingPos);
          }
        }
      }
    }

    return positions;
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

    // Check for individually selected cells (Ctrl+Click mode)
    final bool fromIndividualCells =
        configuration.enableCtrlClickMultiSelect &&
        selectingMode.isCell &&
        _state._individuallySelectedCells.isNotEmpty;

    final bool fromCurrentCell = currentCellPosition != null;

    if (fromSelectingRows) {
      return _selectingTextFromSelectingRows();
    } else if (fromSelectingPosition || fromIndividualCells) {
      // When we have range selection and/or individual cells, use the combined text
      return _selectingTextFromAllSelections();
    } else if (fromCurrentCell) {
      return _selectingTextFromCurrentCell();
    }

    return '';
  }

  @override
  void setSelecting(bool flag, {bool notify = true}) {
    debugPrint(
      '[Selection] setSelecting called - flag: $flag, notify: $notify, current isSelecting: $isSelecting',
    );

    if (selectingMode.isNone) {
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
      // When Ctrl+Click multi-select is enabled, preserve individual selections
      if (configuration.enableCtrlClickMultiSelect &&
          selectingMode == TrinaGridSelectingMode.cell) {
        debugPrint(
          '[Selection] setSelecting - Ctrl+Click mode enabled, clearing only range selections',
        );
        clearRangeSelections(notify: false);
      } else {
        debugPrint(
          '[Selection] setSelecting - Standard mode, clearing all selections',
        );
        clearCurrentSelecting(notify: false);
      }
    }

    notifyListeners(notify, setSelecting.hashCode);
  }

  @override
  void setSelectingMode(
    TrinaGridSelectingMode selectingMode, {
    bool notify = true,
  }) {
    if (mode.isSingleSelectMode) {
      selectingMode = TrinaGridSelectingMode.none;
    } else if (mode.isMultiSelectMode) {
      selectingMode = TrinaGridSelectingMode.row;
    }

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
      case TrinaGridSelectingMode.cell:
      case TrinaGridSelectingMode.horizontal:
        _setFistCellAsCurrent();

        setCurrentSelectingPosition(
          cellPosition: TrinaGridCellPosition(
            columnIdx: refColumns.length - 1,
            rowIdx: refRows.length - 1,
          ),
        );
        break;
      case TrinaGridSelectingMode.row:
        if (currentCell == null) {
          _setFistCellAsCurrent();
        }

        _state._currentSelectingPosition = TrinaGridCellPosition(
          columnIdx: refColumns.length - 1,
          rowIdx: refRows.length - 1,
        );

        setCurrentSelectingRowsByRange(0, refRows.length - 1);
        break;
      case TrinaGridSelectingMode.none:
        break;
    }
  }

  @override
  void setCurrentSelectingPosition({
    TrinaGridCellPosition? cellPosition,
    bool notify = true,
  }) {
    if (selectingMode.isNone) {
      return;
    }

    if (currentSelectingPosition == cellPosition) {
      return;
    }

    // Exit editing mode when creating a range selection
    // This ensures copy/paste operations work correctly
    if (isEditing && cellPosition != null) {
      setEditing(false, notify: false);
    }

    _state._currentSelectingPosition = isInvalidCellPosition(cellPosition)
        ? null
        : cellPosition;

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

    final double gridBodyOffsetDy =
        gridGlobalOffset!.dy +
        gridBorderWidth +
        headerHeight +
        columnGroupHeight +
        columnHeight +
        columnFilterHeight;

    double currentCellOffsetDy =
        (currentRowIdx! * rowTotalHeight) +
        gridBodyOffsetDy -
        scroll.vertical!.offset;

    if (gridBodyOffsetDy > offset!.dy) {
      return;
    }

    int rowIdx =
        (((currentCellOffsetDy - offset.dy) / rowTotalHeight).ceil() -
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

      final rightFrozenColumnOffset = column.frozen.isEnd && showFrozenColumn
          ? savedRightBlankOffset
          : 0;

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
    debugPrint('[Selection] clearCurrentSelecting called - notify: $notify');
    debugPrint(
      '[Selection] Clearing ${_state._individuallySelectedCells.length} individual cells',
    );

    _clearCurrentSelectingPosition(notify: false);

    _clearCurrentSelectingRows(notify: false);

    // Clear individual selections
    if (_state._individuallySelectedCells.isNotEmpty) {
      _state._individuallySelectedCells.clear();
    }

    notifyListeners(notify, clearCurrentSelecting.hashCode);
  }

  @override
  void clearRangeSelections({bool notify = true}) {
    debugPrint('[Selection] clearRangeSelections called - notify: $notify');
    debugPrint(
      '[Selection] Preserving ${_state._individuallySelectedCells.length} individual cells',
    );

    _clearCurrentSelectingPosition(notify: false);

    _clearCurrentSelectingRows(notify: false);

    // Do NOT clear individual selections - that's the difference from clearCurrentSelecting

    notifyListeners(notify, clearRangeSelections.hashCode);
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

  /// Toggle individual cell in multi-select mode.
  /// Used for Ctrl+Click functionality.
  void toggleSelectingCell(
    TrinaGridCellPosition cellPosition, {
    bool notify = true,
  }) {
    debugPrint(
      '[Selection] toggleSelectingCell called - cellPosition: (${cellPosition.columnIdx}, ${cellPosition.rowIdx}), notify: $notify',
    );
    debugPrint(
      '[Selection] Individual cells count before: ${_state._individuallySelectedCells.length}',
    );

    if (!configuration.enableCtrlClickMultiSelect) {
      debugPrint(
        '[Selection] toggleSelectingCell - Feature not enabled, returning',
      );
      return;
    }
    if (selectingMode != TrinaGridSelectingMode.cell) {
      debugPrint(
        '[Selection] toggleSelectingCell - Not in cell mode, returning',
      );
      return;
    }

    // Exit editing mode when selecting individual cells
    // This ensures copy/paste operations work correctly
    if (isEditing) {
      setEditing(false, notify: false);
    }

    if (_state._individuallySelectedCells.contains(cellPosition)) {
      debugPrint(
        '[Selection] toggleSelectingCell - Removing cell from selection',
      );
      _state._individuallySelectedCells.remove(cellPosition);
    } else {
      debugPrint('[Selection] toggleSelectingCell - Adding cell to selection');
      _state._individuallySelectedCells.add(cellPosition);
    }

    debugPrint(
      '[Selection] Individual cells count after: ${_state._individuallySelectedCells.length}',
    );
    notifyListeners(notify, toggleSelectingCell.hashCode);
  }

  /// Clear individual cell selections.
  void clearIndividualSelections({bool notify = true}) {
    if (_state._individuallySelectedCells.isEmpty) return;

    _state._individuallySelectedCells.clear();

    notifyListeners(notify, clearIndividualSelections.hashCode);
  }

  /// Start drag selection.
  void startDragSelection(TrinaGridCellPosition startPosition) {
    debugPrint(
      '[Selection] startDragSelection called - col: ${startPosition.columnIdx}, row: ${startPosition.rowIdx}',
    );

    if (!configuration.enableDragSelection) {
      debugPrint('[Selection] startDragSelection - Drag selection not enabled');
      return;
    }
    if (selectingMode != TrinaGridSelectingMode.cell) {
      debugPrint(
        '[Selection] startDragSelection - Not in cell selecting mode: $selectingMode',
      );
      return;
    }

    _state._isDragSelecting = true;
    debugPrint('[Selection] startDragSelection - Set _isDragSelecting to true');

    // Set the start position as current cell
    if (startPosition.columnIdx != null && startPosition.rowIdx != null) {
      final columnIndexes = columnIndexesByShowFrozen;
      if (startPosition.columnIdx! < columnIndexes.length &&
          startPosition.rowIdx! < refRows.length) {
        final column = refColumns[columnIndexes[startPosition.columnIdx!]];
        final row = refRows[startPosition.rowIdx!];
        final cell = row.cells[column.field];
        if (cell != null) {
          setCurrentCell(cell, startPosition.rowIdx, notify: false);
        }
      }
    }
  }

  /// Update drag selection endpoint.
  void updateDragSelection(TrinaGridCellPosition endPosition) {
    debugPrint(
      '[Selection] updateDragSelection called - isDragSelecting: ${_state._isDragSelecting}, col: ${endPosition.columnIdx}, row: ${endPosition.rowIdx}',
    );

    if (!_state._isDragSelecting) {
      debugPrint(
        '[Selection] updateDragSelection - Not drag selecting, returning',
      );
      return;
    }

    debugPrint(
      '[Selection] updateDragSelection - Calling setCurrentSelectingPosition',
    );
    setCurrentSelectingPosition(cellPosition: endPosition, notify: true);
  }

  /// End drag selection.
  void endDragSelection() {
    if (!_state._isDragSelecting) return;

    debugPrint(
      '[Selection] endDragSelection - Adding ${currentSelectingPositionList.length} cells to individual selections',
    );

    // Add all cells in the current selection range to individual selections
    if (configuration.enableCtrlClickMultiSelect) {
      for (final position in currentSelectingPositionList) {
        // Convert field name to column index
        final column = refColumns.firstWhereOrNull(
          (col) => col.field == position.field,
        );
        if (column == null) continue;

        final columnIdx = columnIndex(column);
        if (columnIdx != null && position.rowIdx != null) {
          final cellPos = TrinaGridCellPosition(
            columnIdx: columnIdx,
            rowIdx: position.rowIdx,
          );
          _state._individuallySelectedCells.add(cellPos);
          debugPrint(
            '[Selection] Added cell to individual selections: field=${position.field}, col=$columnIdx, row=${position.rowIdx}',
          );
        }
      }
    }

    // Clear the range selection (but keep individual selections)
    clearRangeSelections(notify: false);

    _state._isDragSelecting = false;

    debugPrint(
      '[Selection] endDragSelection - Total individual cells: ${_state._individuallySelectedCells.length}',
    );

    // Notify listeners to update the UI
    notifyListeners(true, endDragSelection.hashCode);
  }

  /// Get drag selecting state.
  bool get isDragSelecting => _state._isDragSelecting;

  @override
  bool isSelectingInteraction() {
    return !selectingMode.isNone &&
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
    if (selectingMode.isNone) {
      return false;
    }

    // Check individual selections first (for Ctrl+Click multi-select)
    if (configuration.enableCtrlClickMultiSelect && selectingMode.isCell) {
      final int? columnIdx = columnIndex(column);
      if (columnIdx != null) {
        final cellPosition = TrinaGridCellPosition(
          columnIdx: columnIdx,
          rowIdx: rowIdx,
        );
        if (_state._individuallySelectedCells.contains(cellPosition)) {
          return true;
        }
      }
    }

    if (currentCellPosition == null) {
      return false;
    }

    if (currentSelectingPosition == null) {
      return false;
    }

    if (selectingMode.isCell) {
      final bool inRangeOfRows =
          min(
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

      final bool inRangeOfColumns =
          min(
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

    final bool firstCurrent =
        currentCellPosition!.rowIdx! < currentSelectingPosition!.rowIdx! ||
        (currentCellPosition!.rowIdx! == currentSelectingPosition!.rowIdx! &&
            currentCellPosition!.columnIdx! <=
                currentSelectingPosition!.columnIdx!);

    TrinaGridCellPosition startCell = firstCurrent
        ? currentCellPosition!
        : currentSelectingPosition!;

    TrinaGridCellPosition endCell = !firstCurrent
        ? currentCellPosition!
        : currentSelectingPosition!;

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

  String _selectingTextFromAllSelections() {
    // This method combines BOTH range selections (from Shift+Click)
    // AND individual cell selections (from Ctrl+Click)
    final columnIndexes = columnIndexesByShowFrozen;

    // Use currentSelectingPositionList which already combines both types
    final positions = currentSelectingPositionList;

    // If we have individual cells but no range selection, also include current cell
    // (When user clicks a cell, then Ctrl+Clicks others, the first cell should be included)
    final hasRangeSelection =
        currentCellPosition != null && currentSelectingPosition != null;
    final hasIndividualCells = _state._individuallySelectedCells.isNotEmpty;

    List<TrinaGridSelectingCellPosition> allPositions = List.from(positions);

    if (hasIndividualCells &&
        !hasRangeSelection &&
        currentCellPosition != null) {
      // Add current cell to the list if it's not already there
      final currentField = currentColumn?.field;
      if (currentField != null) {
        final currentPos = TrinaGridSelectingCellPosition(
          rowIdx: currentRowIdx,
          field: currentField,
        );
        // Check if current cell is not already in the list
        if (!allPositions.any(
          (p) => p.rowIdx == currentPos.rowIdx && p.field == currentPos.field,
        )) {
          allPositions.add(currentPos);
        }
      }
    }

    if (allPositions.isEmpty) {
      return '';
    }

    // Group positions by row for structured output
    Map<int, List<TrinaGridSelectingCellPosition>> rowGroups = {};
    for (final pos in allPositions) {
      if (pos.rowIdx != null) {
        rowGroups.putIfAbsent(pos.rowIdx!, () => []).add(pos);
      }
    }

    // Sort rows and build text
    final sortedRowIdxs = rowGroups.keys.toList()..sort();
    List<String> rowTexts = [];

    for (final rowIdx in sortedRowIdxs) {
      final rowPositions = rowGroups[rowIdx]!;

      // Sort positions within row by column
      rowPositions.sort((a, b) {
        final aColIdx = columnIndexes.indexOf(
          refColumns.indexWhere((col) => col.field == a.field),
        );
        final bColIdx = columnIndexes.indexOf(
          refColumns.indexWhere((col) => col.field == b.field),
        );
        return aColIdx.compareTo(bColIdx);
      });

      List<String> cellTexts = [];
      for (final pos in rowPositions) {
        final cell = refRows[pos.rowIdx!].cells[pos.field];
        if (cell != null) {
          cellTexts.add(cell.value.toString());
        }
      }

      if (cellTexts.isNotEmpty) {
        rowTexts.add(cellTexts.join('\t'));
      }
    }

    return rowTexts.join('\n');
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
