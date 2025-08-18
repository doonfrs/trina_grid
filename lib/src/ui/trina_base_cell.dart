import 'ui.dart';
import 'package:flutter/material.dart';
import 'package:trina_grid/trina_grid.dart';
import 'package:trina_grid/src/helper/platform_helper.dart';
import 'package:trina_grid/src/helper/trina_double_tap_detector.dart';

class TrinaBaseCell extends StatelessWidget
    implements TrinaVisibilityLayoutChild {
  final TrinaCell cell;

  final TrinaColumn column;

  final int rowIdx;

  final TrinaRow row;

  final TrinaGridStateManager stateManager;

  const TrinaBaseCell({
    super.key,
    required this.cell,
    required this.column,
    required this.rowIdx,
    required this.row,
    required this.stateManager,
  });

  @override
  double get width => column.width;

  @override
  double get startPosition => column.startPosition;

  @override
  bool get keepAlive => stateManager.currentCell == cell;

  void _addGestureEvent(TrinaGridGestureType gestureType, Offset offset) {
    stateManager.eventManager!.addEvent(
      TrinaGridCellGestureEvent(
        gestureType: gestureType,
        offset: offset,
        cell: cell,
        column: column,
        rowIdx: rowIdx,
      ),
    );
  }

  void _handleOnTapUp(TapUpDetails details) {
    if (PlatformHelper.isDesktop &&
        TrinaDoubleTapDetector.isDoubleTap(cell) &&
        stateManager.onRowDoubleTap != null) {
      _handleOnDoubleTap();
      return;
    }
    _addGestureEvent(TrinaGridGestureType.onTapUp, details.globalPosition);
  }

  void _handleOnLongPressStart(LongPressStartDetails details) {
    if (stateManager.selectingMode.isNone) {
      return;
    }

    _addGestureEvent(
      TrinaGridGestureType.onLongPressStart,
      details.globalPosition,
    );
  }

  void _handleOnLongPressMoveUpdate(LongPressMoveUpdateDetails details) {
    if (stateManager.selectingMode.isNone) {
      return;
    }

    _addGestureEvent(
      TrinaGridGestureType.onLongPressMoveUpdate,
      details.globalPosition,
    );
  }

  void _handleOnLongPressEnd(LongPressEndDetails details) {
    if (stateManager.selectingMode.isNone) {
      return;
    }

    _addGestureEvent(
      TrinaGridGestureType.onLongPressEnd,
      details.globalPosition,
    );
  }

  void _handleOnDoubleTap() {
    _addGestureEvent(TrinaGridGestureType.onDoubleTap, Offset.zero);
  }

  void _handleOnSecondaryTap(TapDownDetails details) {
    _addGestureEvent(
      TrinaGridGestureType.onSecondaryTap,
      details.globalPosition,
    );
  }

  void Function()? _onDoubleTapOrNull() {
    if (PlatformHelper.isDesktop) {
      return null;
    }
    return stateManager.onRowDoubleTap == null ? null : _handleOnDoubleTap;
  }

  void Function(TapDownDetails details)? _onSecondaryTapOrNull() {
    return stateManager.onRowSecondaryTap == null
        ? null
        : _handleOnSecondaryTap;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      // Essential gestures.
      onTapUp: _handleOnTapUp,
      onLongPressStart: _handleOnLongPressStart,
      onLongPressMoveUpdate: _handleOnLongPressMoveUpdate,
      onLongPressEnd: _handleOnLongPressEnd,
      // Optional gestures.
      onDoubleTap: _onDoubleTapOrNull(),
      onSecondaryTapDown: _onSecondaryTapOrNull(),
      child: _CellContainer(
        cell: cell,
        rowIdx: rowIdx,
        row: row,
        column: column,
        cellPadding: column.cellPadding ??
            stateManager.configuration.style.defaultCellPadding,
        stateManager: stateManager,
        child: _Cell(
          stateManager: stateManager,
          rowIdx: rowIdx,
          column: column,
          row: row,
          cell: cell,
        ),
      ),
    );
  }
}

class _CellContainer extends TrinaStatefulWidget {
  final TrinaCell cell;

  final TrinaRow row;

  final int rowIdx;

  final TrinaColumn column;

  final EdgeInsets cellPadding;

  final TrinaGridStateManager stateManager;

  final Widget child;

  const _CellContainer({
    required this.cell,
    required this.row,
    required this.rowIdx,
    required this.column,
    required this.cellPadding,
    required this.stateManager,
    required this.child,
  });

  @override
  State<_CellContainer> createState() => _CellContainerState();
}

class _CellContainerState extends TrinaStateWithChange<_CellContainer> {
  BoxDecoration _decoration = const BoxDecoration();

  @override
  TrinaGridStateManager get stateManager => widget.stateManager;

  @override
  void initState() {
    super.initState();

    updateState(TrinaNotifierEventForceUpdate.instance);
  }

  @override
  void updateState(TrinaNotifierEvent event) {
    final style = stateManager.style;

    final isCurrentCell = stateManager.isCurrentCell(widget.cell);

    _decoration = update(
      _decoration,
      _boxDecoration(
        hasFocus: stateManager.hasFocus,
        readOnly: widget.column.checkReadOnly(widget.row, widget.cell),
        isEditing: stateManager.isEditing,
        isCurrentCell: isCurrentCell,
        isSelectedCell: stateManager.isSelectedCell(
          widget.cell,
          widget.column,
          widget.rowIdx,
        ),
        isGroupedRowCell: stateManager.enabledRowGroups &&
            stateManager.rowGroupDelegate!.isExpandableCell(widget.cell),
        enableCellVerticalBorder: style.enableCellBorderVertical,
        borderColor: style.borderColor,
        activatedBorderColor: style.activatedBorderColor,
        activatedColor: style.activatedColor,
        inactivatedBorderColor: style.inactivatedBorderColor,
        gridBackgroundColor: style.gridBackgroundColor,
        cellColorInEditState: style.cellColorInEditState,
        cellColorInReadOnlyState: style.cellColorInReadOnlyState,
        cellColorGroupedRow: style.cellColorGroupedRow,
        selectingMode: stateManager.selectingMode,
        cellReadonlyColor: style.cellReadonlyColor,
        cellDefaultColor: style.cellDefaultColor,
      ),
    );
  }

  Color? _currentCellColor({
    required bool readOnly,
    required bool hasFocus,
    required bool isEditing,
    required Color activatedColor,
    required Color gridBackgroundColor,
    required Color cellColorInEditState,
    required Color cellColorInReadOnlyState,
    required TrinaGridSelectingMode selectingMode,
  }) {
    if (!hasFocus) {
      return gridBackgroundColor;
    }

    if (!isEditing) {
      return selectingMode.isRow ? activatedColor : null;
    }

    return readOnly == true ? cellColorInReadOnlyState : cellColorInEditState;
  }

  Color? _getCellCallbackColor() {
    if (stateManager.cellColorCallback == null) {
      return null;
    }

    return stateManager.cellColorCallback!(
      TrinaCellColorContext(
        cell: widget.cell,
        column: widget.column,
        row: widget.row,
        rowIdx: widget.rowIdx,
        stateManager: stateManager,
      ),
    );
  }

  BoxDecoration _boxDecoration({
    required bool hasFocus,
    required bool readOnly,
    required bool isEditing,
    required bool isCurrentCell,
    required bool isSelectedCell,
    required bool isGroupedRowCell,
    required bool enableCellVerticalBorder,
    required Color borderColor,
    required Color activatedBorderColor,
    required Color activatedColor,
    required Color inactivatedBorderColor,
    required Color gridBackgroundColor,
    required Color cellColorInEditState,
    required Color cellColorInReadOnlyState,
    required Color? cellColorGroupedRow,
    required Color? cellReadonlyColor,
    required Color? cellDefaultColor,
    required TrinaGridSelectingMode selectingMode,
  }) {
    // Check if the cell has uncommitted changes (is dirty)
    final bool isDirty = widget.cell.isDirty;
    final Color dirtyColor = stateManager.configuration.style.cellDirtyColor;

    if (isCurrentCell) {
      return BoxDecoration(
        color: isDirty
            ? dirtyColor
            : _currentCellColor(
                hasFocus: hasFocus,
                isEditing: isEditing,
                readOnly: readOnly,
                gridBackgroundColor: gridBackgroundColor,
                activatedColor: activatedColor,
                cellColorInReadOnlyState: cellColorInReadOnlyState,
                cellColorInEditState: cellColorInEditState,
                selectingMode: selectingMode,
              ),
        border: Border.all(
          color: hasFocus ? activatedBorderColor : inactivatedBorderColor,
          width: 1,
        ),
      );
    } else if (isSelectedCell) {
      return BoxDecoration(
        color: isDirty ? dirtyColor : activatedColor,
        border: Border.all(
          color: hasFocus ? activatedBorderColor : inactivatedBorderColor,
          width: 1,
        ),
      );
    } else {
      // Get color from cell callback if available, otherwise fall back to default colors
      final cellCallbackColor = _getCellCallbackColor();
      final defaultColor = isGroupedRowCell
          ? cellColorGroupedRow
          : readOnly
              ? cellReadonlyColor
              : cellDefaultColor;

      return BoxDecoration(
        color: isDirty ? dirtyColor : cellCallbackColor ?? defaultColor,
        border: enableCellVerticalBorder
            ? BorderDirectional(
                end: BorderSide(
                  color: borderColor,
                  width: stateManager.style.cellVerticalBorderWidth,
                ),
              )
            : null,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: _decoration,
      child: Padding(padding: widget.cellPadding, child: widget.child),
    );
  }
}

class _Cell extends TrinaStatefulWidget {
  final TrinaGridStateManager stateManager;

  final int rowIdx;

  final TrinaRow row;

  final TrinaColumn column;

  final TrinaCell cell;

  const _Cell({
    required this.stateManager,
    required this.rowIdx,
    required this.row,
    required this.column,
    required this.cell,
  });

  @override
  State<_Cell> createState() => _CellState();
}

class _CellState extends TrinaStateWithChange<_Cell> {
  bool _showTypedCell = false;

  @override
  TrinaGridStateManager get stateManager => widget.stateManager;

  @override
  void initState() {
    super.initState();

    updateState(TrinaNotifierEventForceUpdate.instance);
  }

  @override
  void updateState(TrinaNotifierEvent event) {
    _showTypedCell = update<bool>(
      _showTypedCell,
      stateManager.isEditing && stateManager.isCurrentCell(widget.cell),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_showTypedCell && widget.column.enableEditingMode == true) {
      return widget.column.type
          .buildCell(stateManager, widget.cell, widget.column, widget.row);
    }

    return TrinaDefaultCell(
      cell: widget.cell,
      column: widget.column,
      rowIdx: widget.rowIdx,
      row: widget.row,
      stateManager: stateManager,
    );
  }
}
