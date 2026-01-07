import 'dart:math';

import 'package:flutter/material.dart';
import 'package:trina_grid/trina_grid.dart';

abstract class IEditingState {
  /// Editing status of the current.
  bool get isEditing;

  /// Automatically set to editing state when cell is selected.
  bool get autoEditing;

  TextEditingController? get textEditingController;

  /// Callback triggered when cell validation fails
  TrinaOnValidationFailedCallback? get onValidationFailed;

  /// Custom renderer for the edit cell widget.
  /// This allows customizing the edit cell UI.
  Widget Function(
    Widget defaultEditCellWidget,
    TrinaCell cell,
    TextEditingController controller,
    FocusNode focusNode,
    Function(dynamic value)? handleSelected,
  )?
  get editCellRenderer;

  bool isEditableCell(TrinaCell cell);

  /// Change the editing status of the current cell.
  void setEditing(bool flag, {bool notify = true});

  void setAutoEditing(bool flag, {bool notify = true});

  void setTextEditingController(TextEditingController? textEditingController);

  /// Toggle the editing status of the current cell.
  void toggleEditing({bool notify = true});

  /// Paste based on current cell
  void pasteCellValue(List<List<String>> textList);

  /// Cast the value according to the column type.
  dynamic castValueByColumnType(dynamic value, TrinaColumn column);

  /// Change cell value
  /// [callOnChangedEvent] triggers a [TrinaOnChangedEventCallback] callback.
  /// [validate] determines whether to validate the value before setting it.
  void changeCellValue(
    TrinaCell cell,
    dynamic value, {
    bool callOnChangedEvent = true,
    bool force = false,
    bool notify = true,
    bool validate = true,
  });
}

class _State {
  bool _isEditing = false;

  bool _autoEditing = false;

  TextEditingController? _textEditingController;
}

mixin EditingState implements ITrinaGridState {
  final _State _state = _State();

  @override
  Widget Function(
    Widget defaultEditCellWidget,
    TrinaCell cell,
    TextEditingController controller,
    FocusNode focusNode,
    Function(dynamic value)? handleSelected,
  )?
  get editCellRenderer;

  @override
  bool get isEditing => _state._isEditing;

  @override
  bool get autoEditing =>
      _state._autoEditing || currentColumn?.enableAutoEditing == true;

  @override
  TextEditingController? get textEditingController =>
      _state._textEditingController;

  @override
  TrinaOnValidationFailedCallback? get onValidationFailed =>
      (this as TrinaGridStateManager).onValidationFailed;

  @override
  bool isEditableCell(TrinaCell cell) {
    if (cell.column.enableEditingMode != true) {
      return false;
    }

    if (enabledRowGroups) {
      return rowGroupDelegate?.isEditableCell(cell) == true;
    }

    return true;
  }

  @override
  void setEditing(bool flag, {bool notify = true}) {
    if (!mode.isEditableMode || (flag && currentCell == null)) {
      flag = false;
    }

    if (isEditing == flag) return;

    if (flag) {
      assert(currentCell?.column != null && currentCell?.row != null, """
      TrinaCell is not Initialized. 
      TrinaColumn and TrinaRow must be initialized in TrinaCell via TrinaGridStateManager.
      initializeRows method. When adding or deleting columns or rows, 
      you must use methods on TrinaGridStateManager. Otherwise, 
      the TrinaCell is not initialized and this error occurs.
      """);

      if (!isEditableCell(currentCell!)) {
        flag = false;
      }
    }

    _state._isEditing = flag;

    // When Ctrl+Click multi-select is enabled, preserve individual selections
    if (configuration.enableCtrlClickMultiSelect &&
        selectingMode == TrinaGridSelectingMode.cell) {
      debugPrint(
        '[Selection] setEditing - Ctrl+Click mode enabled, clearing only range selections',
      );
      clearRangeSelections(notify: false);
    } else {
      debugPrint(
        '[Selection] setEditing - Standard mode, clearing all selections',
      );
      clearCurrentSelecting(notify: false);
    }

    notifyListeners(notify, setEditing.hashCode);
  }

  @override
  void setAutoEditing(bool flag, {bool notify = true}) {
    if (autoEditing == flag) {
      return;
    }

    _state._autoEditing = flag;

    notifyListeners(notify, setAutoEditing.hashCode);
  }

  @override
  void setTextEditingController(TextEditingController? textEditingController) {
    _state._textEditingController = textEditingController;
  }

  @override
  void toggleEditing({bool notify = true}) =>
      setEditing(!(isEditing == true), notify: notify);

  @override
  void pasteCellValue(List<List<String>> textList) {
    if (currentCellPosition == null) {
      return;
    }

    if (selectingMode.isRow && currentSelectingRows.isNotEmpty) {
      _pasteCellValueIntoSelectingRows(textList: textList);
    } else {
      int? columnStartIdx;

      int columnEndIdx;

      int? rowStartIdx;

      int rowEndIdx;

      if (currentSelectingPosition == null) {
        // No cell selection : Paste in order based on the current cell
        columnStartIdx = currentCellPosition!.columnIdx;

        columnEndIdx =
            currentCellPosition!.columnIdx! + textList.first.length - 1;

        rowStartIdx = currentCellPosition!.rowIdx;

        rowEndIdx = currentCellPosition!.rowIdx! + textList.length - 1;
      } else {
        // If there are selected cells : Paste in order from selected cell range
        columnStartIdx = min(
          currentCellPosition!.columnIdx!,
          currentSelectingPosition!.columnIdx!,
        );

        columnEndIdx = max(
          currentCellPosition!.columnIdx!,
          currentSelectingPosition!.columnIdx!,
        );

        rowStartIdx = min(
          currentCellPosition!.rowIdx!,
          currentSelectingPosition!.rowIdx!,
        );

        rowEndIdx = max(
          currentCellPosition!.rowIdx!,
          currentSelectingPosition!.rowIdx!,
        );
      }

      _pasteCellValueInOrder(
        textList: textList,
        rowIdxList: [for (var i = rowStartIdx!; i <= rowEndIdx; i += 1) i],
        columnStartIdx: columnStartIdx,
        columnEndIdx: columnEndIdx,
      );
    }

    notifyListeners(true, pasteCellValue.hashCode);
  }

  @override
  dynamic castValueByColumnType(dynamic value, TrinaColumn column) {
    if (column.type is TrinaColumnTypeWithNumberFormat) {
      return (column.type as TrinaColumnTypeWithNumberFormat).toNumber(
        column.type.applyFormat(value),
      );
    }

    return value;
  }

  /// Validates a value against a column's validation rules
  /// Returns null if validation passes, or an error message if validation fails
  String? validateValue(
    dynamic value,
    TrinaColumn column,
    TrinaRow row,
    int rowIdx,
    dynamic oldValue,
  ) {
    // First check the column type's built-in validation
    if (!column.type.isValid(value)) {
      return 'Invalid value for ${column.title}';
    }

    // Then check the custom validator if present
    if (column.validator != null) {
      final context = TrinaValidationContext(
        column: column,
        row: row,
        rowIdx: rowIdx,
        oldValue: oldValue,
        stateManager: this as TrinaGridStateManager,
      );

      return column.validator!(value, context);
    }

    return null;
  }

  @override
  void changeCellValue(
    TrinaCell cell,
    dynamic value, {
    bool callOnChangedEvent = true,
    bool force = false,
    bool notify = true,
    bool validate = true,
  }) {
    final currentColumn = cell.column;
    final currentRow = cell.row;
    final dynamic oldValue = cell.value;
    final rowIdx = refRows.indexOf(currentRow);

    value = filteredCellValue(
      column: currentColumn,
      newValue: value,
      oldValue: oldValue,
    );

    // Only cast value if we're validating
    if (validate) {
      value = castValueByColumnType(value, currentColumn);
    }

    if (force == false &&
        canNotChangeCellValue(
          cell: cell,
          newValue: value,
          oldValue: oldValue,
        )) {
      return;
    }

    // Validate the value before applying the change (only if validate is true)
    if (validate) {
      final validationError = validateValue(
        value,
        currentColumn,
        currentRow,
        rowIdx,
        oldValue,
      );

      if (validationError != null) {
        // Trigger validation failed callback
        if (onValidationFailed != null) {
          onValidationFailed!(
            TrinaGridValidationEvent(
              column: currentColumn,
              row: currentRow,
              rowIdx: rowIdx,
              value: value,
              oldValue: oldValue,
              errorMessage: validationError,
            ),
          );
        }
        return;
      }
    }

    // Store the old value if change tracking is enabled
    if ((this as TrinaGridStateManager).enableChangeTracking && !cell.isDirty) {
      cell.trackChange();
    }

    currentRow.setState(TrinaRowState.updated);
    cell.value = value;
    currentRow.incrementVersion();

    final changedEvent = TrinaGridOnChangedEvent(
      columnIdx: columnIndex(currentColumn)!,
      column: currentColumn,
      rowIdx: rowIdx,
      row: currentRow,
      cell: cell,
      value: value,
      oldValue: oldValue,
    );

    if (callOnChangedEvent == true && cell.onChanged != null) {
      cell.onChanged!(changedEvent);
    }

    if (callOnChangedEvent == true && onChanged != null) {
      onChanged!(changedEvent);
    }

    notifyListeners(notify, changeCellValue.hashCode);
  }

  void _pasteCellValueIntoSelectingRows({List<List<String>>? textList}) {
    int columnStartIdx = 0;

    int columnEndIdx = refColumns.length - 1;

    final Set<Key> selectingRowKeys = Set.from(
      currentSelectingRows.map((e) => e.key),
    );

    List<int> rowIdxList = [];

    for (int i = 0; i < refRows.length; i += 1) {
      final currentRowKey = refRows[i].key;

      if (selectingRowKeys.contains(currentRowKey)) {
        selectingRowKeys.remove(currentRowKey);
        rowIdxList.add(i);
      }

      if (selectingRowKeys.isEmpty) {
        break;
      }
    }

    _pasteCellValueInOrder(
      textList: textList,
      rowIdxList: rowIdxList,
      columnStartIdx: columnStartIdx,
      columnEndIdx: columnEndIdx,
    );
  }

  void _pasteCellValueInOrder({
    List<List<String>>? textList,
    required List<int> rowIdxList,
    int? columnStartIdx,
    int? columnEndIdx,
  }) {
    final List<int> columnIndexes = columnIndexesByShowFrozen;

    int textRowIdx = 0;

    for (int i = 0; i < rowIdxList.length; i += 1) {
      final rowIdx = rowIdxList[i];

      int textColumnIdx = 0;

      if (rowIdx > refRows.length - 1) {
        break;
      }

      if (textRowIdx > textList!.length - 1) {
        textRowIdx = 0;
      }

      for (
        int columnIdx = columnStartIdx!;
        columnIdx <= columnEndIdx!;
        columnIdx += 1
      ) {
        if (columnIdx > columnIndexes.length - 1) {
          break;
        }

        if (textColumnIdx > textList.first.length - 1) {
          textColumnIdx = 0;
        }

        final currentColumn = refColumns[columnIndexes[columnIdx]];

        final currentCell = refRows[rowIdx].cells[currentColumn.field]!;

        dynamic newValue = textList[textRowIdx][textColumnIdx];

        final dynamic oldValue = currentCell.value;

        newValue = filteredCellValue(
          column: currentColumn,
          newValue: newValue,
          oldValue: oldValue,
        );

        newValue = castValueByColumnType(newValue, currentColumn);

        if (canNotChangeCellValue(
          cell: currentCell,
          newValue: newValue,
          oldValue: oldValue,
        )) {
          ++textColumnIdx;
          continue;
        }

        // Store the old value if change tracking is enabled
        if (this case final TrinaGridStateManager stateManager
            when stateManager.enableChangeTracking) {
          if (!currentCell.isDirty) {
            currentCell.trackChange();
          }
        }

        refRows[rowIdx].setState(TrinaRowState.updated);

        currentCell.value = newValue;
        refRows[rowIdx].incrementVersion();

        // Create the event object once to reuse for both callbacks
        final changedEvent = TrinaGridOnChangedEvent(
          columnIdx: columnIndexes[columnIdx],
          column: currentColumn,
          rowIdx: rowIdx,
          row: refRows[rowIdx],
          cell: currentCell,
          value: newValue,
          oldValue: oldValue,
        );

        // Call the cell-level onChanged callback if it exists
        if (currentCell.onChanged != null) {
          currentCell.onChanged!(changedEvent);
        }

        // Call the grid-level onChanged callback if it exists
        if (onChanged != null) {
          onChanged!(changedEvent);
        }

        ++textColumnIdx;
      }
      ++textRowIdx;
    }
  }
}
