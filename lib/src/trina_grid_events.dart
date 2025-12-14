import 'package:flutter/services.dart';
import 'package:trina_grid/trina_grid.dart';

/// [TrinaGrid.onLoaded] Argument received by registering callback.
class TrinaGridOnLoadedEvent {
  final TrinaGridStateManager stateManager;

  const TrinaGridOnLoadedEvent({required this.stateManager});
}

/// Event called when the value of [TrinaCell] is changed.
///
/// Notice.
/// [columnIdx], [rowIdx] are the values in the current screen state.
/// Values in their current state, not actual data values
/// with filtering, sorting, or pagination applied.
/// This value is from
/// [TrinaGridStateManager.columns] and [TrinaGridStateManager.rows].
///
/// All data is in
/// [TrinaGridStateManager.refColumns.originalList]
/// [TrinaGridStateManager.refRows.originalList]
class TrinaGridOnChangedEvent {
  final int columnIdx;
  final TrinaColumn column;
  final int rowIdx;
  final TrinaRow row;
  final TrinaCell cell;
  final dynamic value;
  final dynamic oldValue;

  const TrinaGridOnChangedEvent({
    required this.columnIdx,
    required this.column,
    required this.rowIdx,
    required this.row,
    required this.cell,
    this.value,
    this.oldValue,
  });

  @override
  String toString() {
    String out = '[TrinaOnChangedEvent] ';
    out += 'ColumnIndex : $columnIdx, RowIndex : $rowIdx\n';
    out += '::: oldValue : $oldValue\n';
    out += '::: newValue : $value';
    return out;
  }
}

/// This is the argument value of the [TrinaGrid.onSelected] callback
/// that is called when the [TrinaGrid.mode] value is in select mode.
///
/// If [row], [rowIdx], [cell] is [TrinaGridMode.select] or [TrinaGridMode.selectWithOneTap],
/// Information of the row selected with the tab or enter key.
/// If the Escape key is pressed, these values are null.
///
/// [selectedRows] is valid only in case of [TrinaGridMode.multiSelect].
/// If rows are selected by tab or keyboard, the selected rows are included.
/// If the Escape key is pressed, this value is null.
class TrinaGridOnSelectedEvent {
  final TrinaRow? row;
  final int? rowIdx;
  final TrinaCell? cell;
  final List<TrinaRow>? selectedRows;

  const TrinaGridOnSelectedEvent({
    this.row,
    this.rowIdx,
    this.cell,
    this.selectedRows,
  });

  @override
  String toString() {
    return '[TrinaGridOnSelectedEvent] rowIdx: $rowIdx, selectedRows: ${selectedRows?.length}';
  }
}

/// Argument of [TrinaGrid.onSorted] callback for receiving column sort change event.
class TrinaGridOnSortedEvent {
  final TrinaColumn column;

  final TrinaColumnSort oldSort;

  const TrinaGridOnSortedEvent({required this.column, required this.oldSort});

  @override
  String toString() {
    return '[TrinaGridOnSortedEvent] ${column.title} (changed: ${column.sort}, old: $oldSort)';
  }
}

/// Argument of [TrinaGrid.onRowChecked] callback to receive row checkbox event.
///
/// [runtimeType] is [TrinaGridOnRowCheckedAllEvent] if [isAll] is true.
/// When [isAll] is true, it means the entire check button event of the column.
///
/// [runtimeType] is [TrinaGridOnRowCheckedOneEvent] if [isRow] is true.
/// If [isRow] is true, it means the check button event of a specific row.
abstract class TrinaGridOnRowCheckedEvent {
  bool get isAll => runtimeType == TrinaGridOnRowCheckedAllEvent;

  bool get isRow => runtimeType == TrinaGridOnRowCheckedOneEvent;

  final TrinaRow? row;
  final int? rowIdx;
  final bool? isChecked;

  const TrinaGridOnRowCheckedEvent({this.row, this.rowIdx, this.isChecked});

  @override
  String toString() {
    String checkMessage = isAll ? 'All rows ' : 'RowIdx $rowIdx ';
    checkMessage += isChecked == true ? 'checked' : 'unchecked';
    return '[TrinaGridOnRowCheckedEvent] $checkMessage';
  }
}

/// Argument of [TrinaGrid.onRowChecked] callback when the checkbox of the row is tapped.
class TrinaGridOnRowCheckedOneEvent extends TrinaGridOnRowCheckedEvent {
  const TrinaGridOnRowCheckedOneEvent({
    required TrinaRow super.row,
    required int super.rowIdx,
    required super.isChecked,
  });
}

/// Argument of [TrinaGrid.onRowChecked] callback when all checkboxes of the column are tapped.
class TrinaGridOnRowCheckedAllEvent extends TrinaGridOnRowCheckedEvent {
  const TrinaGridOnRowCheckedAllEvent({super.isChecked})
    : super(row: null, rowIdx: null);
}

/// The argument of the [TrinaGrid.onRowDoubleTap] callback
/// to receive the event of double-tapping the row.
class TrinaGridOnRowDoubleTapEvent {
  final TrinaRow row;
  final int rowIdx;
  final TrinaCell cell;

  const TrinaGridOnRowDoubleTapEvent({
    required this.row,
    required this.rowIdx,
    required this.cell,
  });
}

/// Argument of the [TrinaGrid.onRowSecondaryTap] callback
/// to receive the event of tapping the row with the right mouse button.
class TrinaGridOnRowSecondaryTapEvent {
  final TrinaRow row;
  final int rowIdx;
  final TrinaCell cell;
  final Offset offset;

  const TrinaGridOnRowSecondaryTapEvent({
    required this.row,
    required this.rowIdx,
    required this.cell,
    required this.offset,
  });
}

/// Argument of [TrinaGrid.onRowEnter] callback
/// to receive the event of entering the row with the mouse.
class TrinaGridOnRowEnterEvent {
  final TrinaRow? row;
  final int? rowIdx;

  const TrinaGridOnRowEnterEvent({this.row, this.rowIdx});
}

/// Argument of [TrinaGrid.onRowExit] callback
/// to receive the event of exiting the row with the mouse.
class TrinaGridOnRowExitEvent {
  final TrinaRow? row;
  final int? rowIdx;

  const TrinaGridOnRowExitEvent({this.row, this.rowIdx});
}

/// Argument of [TrinaGrid.onRowsMoved] callback
/// to receive the event of moving the row by dragging it.
class TrinaGridOnRowsMovedEvent {
  final int idx;
  final List<TrinaRow> rows;

  const TrinaGridOnRowsMovedEvent({required this.idx, required this.rows});
}

/// Argument of [TrinaGrid.onColumnsMoved] callback
/// to move columns by dragging or receive left or right fixed events.
///
/// [idx] means the actual index of
/// [TrinaGridStateManager.columns] or [TrinaGridStateManager.refColumns].
///
/// [visualIdx] means the order displayed on the screen, not the actual index.
/// For example, if there are 5 columns of [0, 1, 2, 3, 4]
/// If 1 column is frozen to the right, [visualIndex] becomes 4.
/// But the actual index is preserved.
class TrinaGridOnColumnsMovedEvent {
  final int idx;
  final int visualIdx;
  final List<TrinaColumn> columns;

  const TrinaGridOnColumnsMovedEvent({
    required this.idx,
    required this.visualIdx,
    required this.columns,
  });

  @override
  String toString() {
    String text =
        '[TrinaGridOnColumnsMovedEvent] idx: $idx, visualIdx: $visualIdx\n';

    text += columns.map((e) => e.title).join(',');

    return text;
  }
}

/// Event triggered before the active cell changes.
/// Return true to allow the change, false to cancel it.
class TrinaGridOnBeforeActiveCellChangeEvent {
  /// The current (old) cell that is active
  final TrinaCell? oldCell;

  /// The current (old) row index
  final int? oldRowIdx;

  /// The new cell that will become active
  final TrinaCell newCell;

  /// The new row index
  final int newRowIdx;

  /// The direction of movement that triggered this cell change.
  /// This is `null` when the cell change was triggered by a mouse click
  /// or programmatic call without direction context.
  /// When navigating via keyboard (arrow keys, tab, etc.), this will be
  /// [TrinaMoveDirection.left], [TrinaMoveDirection.right],
  /// [TrinaMoveDirection.up], or [TrinaMoveDirection.down].
  final TrinaMoveDirection? moveDirection;

  const TrinaGridOnBeforeActiveCellChangeEvent({
    required this.oldCell,
    required this.oldRowIdx,
    required this.newCell,
    required this.newRowIdx,
    this.moveDirection,
  });

  @override
  String toString() {
    String out = '[TrinaGridOnBeforeActiveCellChangeEvent] ';
    out += 'OldRowIdx: $oldRowIdx, NewRowIdx: $newRowIdx';
    if (moveDirection != null) {
      out += ', MoveDirection: $moveDirection';
    }
    return out;
  }
}

/// When the active cell changes this callback is called
class TrinaGridOnActiveCellChangedEvent {
  final int idx;
  final TrinaCell? cell;

  const TrinaGridOnActiveCellChangedEvent({
    required this.idx,
    required this.cell,
  });
}

/// Event triggered when cell validation fails
class TrinaGridValidationEvent {
  final TrinaColumn column;
  final TrinaRow row;
  final int rowIdx;
  final dynamic value;
  final dynamic oldValue;
  final String errorMessage;

  const TrinaGridValidationEvent({
    required this.column,
    required this.row,
    required this.rowIdx,
    required this.value,
    required this.oldValue,
    required this.errorMessage,
  });

  @override
  String toString() {
    String out = '[TrinaGridValidationEvent] ';
    out += 'Column: ${column.title}, RowIndex: $rowIdx\n';
    out += '::: oldValue: $oldValue\n';
    out += '::: newValue: $value\n';
    out += '::: error: $errorMessage';
    return out;
  }
}

/// Event triggered when a lazy pagination fetch operation completes
class TrinaGridOnLazyFetchCompletedEvent {
  /// The associated state manager
  final TrinaGridStateManager stateManager;

  /// The current page number
  final int page;

  /// The total number of pages
  final int totalPage;

  /// The total number of records (if available)
  final int? totalRecords;

  const TrinaGridOnLazyFetchCompletedEvent({
    required this.stateManager,
    required this.page,
    required this.totalPage,
    this.totalRecords,
  });

  @override
  String toString() {
    return '[TrinaGridOnLazyFetchCompletedEvent] page: $page, totalPage: $totalPage, totalRecords: $totalRecords';
  }
}

/// Event triggered when a key is pressed in a cell.
/// This allows developers to capture keyboard interactions like Enter, Shift, Tab, etc.
class TrinaGridOnKeyEvent {
  /// The column where the key was pressed
  final TrinaColumn column;

  /// The row where the key was pressed
  final TrinaRow row;

  /// The row index
  final int rowIdx;

  /// The cell where the key was pressed
  final TrinaCell cell;

  /// The raw KeyEvent from Flutter
  final KeyEvent event;

  /// Whether the Enter key was pressed
  final bool isEnter;

  /// Whether the Escape key was pressed
  final bool isEscape;

  /// Whether the Tab key was pressed
  final bool isTab;

  /// Whether Shift is pressed
  final bool isShiftPressed;

  /// Whether Ctrl/Cmd is pressed
  final bool isCtrlPressed;

  /// Whether Alt is pressed
  final bool isAltPressed;

  /// The logical key that was pressed
  final LogicalKeyboardKey logicalKey;

  /// The current text value in the cell (if editing)
  final String? currentValue;

  const TrinaGridOnKeyEvent({
    required this.column,
    required this.row,
    required this.rowIdx,
    required this.cell,
    required this.event,
    required this.isEnter,
    required this.isEscape,
    required this.isTab,
    required this.isShiftPressed,
    required this.isCtrlPressed,
    required this.isAltPressed,
    required this.logicalKey,
    this.currentValue,
  });

  @override
  String toString() {
    String out = '[TrinaGridOnKeyEvent] ';
    out += 'Column: ${column.title}, RowIndex: $rowIdx\n';
    out += '::: Key: ${logicalKey.debugName}\n';
    out +=
        '::: Modifiers: Shift=$isShiftPressed, Ctrl=$isCtrlPressed, Alt=$isAltPressed\n';
    if (currentValue != null) {
      out += '::: Current value: $currentValue';
    }
    return out;
  }
}
