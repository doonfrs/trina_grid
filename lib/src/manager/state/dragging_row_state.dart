import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:trina_grid/trina_grid.dart';

abstract class IDraggingRowState {
  bool get isDraggingRow;

  List<TrinaRow> get dragRows;

  int? get dragTargetRowIdx;

  bool get canRowDrag;

  void setIsDraggingRow(bool flag, {bool notify = true});

  void setDragRows(List<TrinaRow> rows, {bool notify = true});

  void setDragTargetRowIdx(int rowIdx, {bool notify = true});

  bool isRowIdxDragTarget(int rowIdx);

  bool isRowIdxTopDragTarget(int rowIdx);

  bool isRowIdxBottomDragTarget(int rowIdx);

  bool isRowBeingDragged(Key rowKey);
}

class _State {
  bool _isDraggingRow = false;

  List<TrinaRow> _dragRows = [];

  int? _dragTargetRowIdx;
}

mixin DraggingRowState implements ITrinaGridState {
  final _State _state = _State();

  @override
  bool get isDraggingRow => _state._isDraggingRow;

  @override
  List<TrinaRow> get dragRows => _state._dragRows;

  @override
  int? get dragTargetRowIdx => _state._dragTargetRowIdx;

  @override
  bool get canRowDrag => !hasFilter && !hasSortedColumn && !enabledRowGroups;

  @override
  void setIsDraggingRow(bool flag, {bool notify = true}) {
    if (isDraggingRow == flag) {
      return;
    }

    _state._isDraggingRow = flag;

    // Only clear drag state when ending a drag (flag = false).
    // Don't clear when starting - dragRows will be set immediately after.
    // This ensures dragRows is still available when onAccept is called.
    if (!flag) {
      _state._dragTargetRowIdx = null;
    }

    notifyListeners(notify, setIsDraggingRow.hashCode);
  }

  @override
  void setDragRows(List<TrinaRow> rows, {bool notify = true}) {
    _state._dragRows = rows;

    notifyListeners(notify, setDragRows.hashCode);
  }

  @override
  void setDragTargetRowIdx(int? rowIdx, {bool notify = true}) {
    if (dragTargetRowIdx == rowIdx) {
      return;
    }

    _state._dragTargetRowIdx = rowIdx;

    notifyListeners(notify, setDragTargetRowIdx.hashCode);
  }

  @override
  bool isRowIdxDragTarget(int? rowIdx) {
    return rowIdx != null &&
        dragTargetRowIdx != null &&
        dragTargetRowIdx! <= rowIdx &&
        rowIdx < dragTargetRowIdx! + dragRows.length;
  }

  @override
  bool isRowIdxTopDragTarget(int? rowIdx) {
    return rowIdx != null &&
        dragTargetRowIdx != null &&
        dragTargetRowIdx == rowIdx &&
        rowIdx + dragRows.length <= refRows.length;
  }

  @override
  bool isRowIdxBottomDragTarget(int? rowIdx) {
    return rowIdx != null &&
        dragTargetRowIdx != null &&
        rowIdx == dragTargetRowIdx! + dragRows.length - 1;
  }

  @override
  bool isRowBeingDragged(Key? rowKey) {
    return rowKey != null &&
        isDraggingRow == true &&
        dragRows.firstWhereOrNull((element) => element.key == rowKey) != null;
  }
}
