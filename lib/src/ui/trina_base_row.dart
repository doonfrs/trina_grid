import 'package:flutter/material.dart';
import 'package:trina_grid/trina_grid.dart';
import 'package:trina_grid/src/manager/event/trina_grid_row_hover_event.dart';

import 'ui.dart';

class TrinaBaseRow extends StatelessWidget {
  final int rowIdx;

  final TrinaRow row;

  final List<TrinaColumn> columns;

  final TrinaGridStateManager stateManager;

  final bool visibilityLayout;

  const TrinaBaseRow({
    required this.rowIdx,
    required this.row,
    required this.columns,
    required this.stateManager,
    this.visibilityLayout = false,
    super.key,
  });

  bool _checkSameDragRows(DragTargetDetails<TrinaRow> draggingRow) {
    final List<TrinaRow> selectedRows = stateManager.selectedRows.isNotEmpty
        ? stateManager.selectedRows
        : [draggingRow.data];

    final end = rowIdx + selectedRows.length;

    for (int i = rowIdx; i < end; i += 1) {
      if (stateManager.refRows[i].key != selectedRows[i - rowIdx].key) {
        return false;
      }
    }

    return true;
  }

  bool _handleOnWillAccept(DragTargetDetails<TrinaRow> draggingRow) {
    return !_checkSameDragRows(draggingRow);
  }

  void _handleOnAccept(DragTargetDetails<TrinaRow> draggingRow) async {
    // Use the rows that were actually set for dragging during the drag operation
    final draggingRows = stateManager.dragRows.isNotEmpty
        ? stateManager.dragRows
        : [draggingRow.data];

    stateManager.eventManager!.addEvent(
      TrinaGridDragRowsEvent(rows: draggingRows, targetIdx: rowIdx),
    );
  }

  TrinaVisibilityLayoutId _makeCell(TrinaColumn column) {
    return TrinaVisibilityLayoutId(
      id: column.field,
      child: TrinaBaseCell(
        key: row.cells[column.field]!.key,
        cell: row.cells[column.field]!,
        column: column,
        rowIdx: rowIdx,
        row: row,
        stateManager: stateManager,
      ),
    );
  }

  Widget _dragTargetBuilder(dragContext, candidate, rejected) {
    return _RowContainerWidget(
      stateManager: stateManager,
      rowIdx: rowIdx,
      row: row,
      enableRowColorAnimation: stateManager.style.enableRowColorAnimation,
      key: ValueKey('rowContainer_${row.key}'),
      child: visibilityLayout
          ? TrinaVisibilityLayout(
              key: ValueKey('rowContainer_${row.key}_row'),
              delegate: _RowCellsLayoutDelegate(
                stateManager: stateManager,
                columns: columns,
                textDirection: stateManager.textDirection,
                row: row,
              ),
              scrollController: stateManager.scroll.bodyRowsHorizontal!,
              initialViewportDimension: MediaQuery.of(dragContext).size.width,
              children: columns.map(_makeCell).toList(growable: false),
            )
          : CustomMultiChildLayout(
              key: ValueKey('rowContainer_${row.key}_row'),
              delegate: _RowCellsLayoutDelegate(
                stateManager: stateManager,
                columns: columns,
                textDirection: stateManager.textDirection,
                row: row,
              ),
              children: columns.map(_makeCell).toList(growable: false),
            ),
    );
  }

  void _handleOnEnter() {
    // set hovered row index
    stateManager.eventManager!.addEvent(
      TrinaGridRowHoverEvent(rowIdx: rowIdx, isHovered: true),
    );
  }

  void _handleOnExit() {
    // reset hovered row index
    stateManager.eventManager!.addEvent(
      TrinaGridRowHoverEvent(rowIdx: rowIdx, isHovered: false),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (event) => _handleOnEnter(),
      onExit: (event) => _handleOnExit(),
      child: DragTarget<TrinaRow>(
        onWillAcceptWithDetails: _handleOnWillAccept,
        onAcceptWithDetails: _handleOnAccept,
        builder: _dragTargetBuilder,
      ),
    );
  }
}

class _RowCellsLayoutDelegate extends MultiChildLayoutDelegate {
  final TrinaGridStateManager stateManager;

  final List<TrinaColumn> columns;

  final TextDirection textDirection;

  final TrinaRow row;

  _RowCellsLayoutDelegate({
    required this.stateManager,
    required this.columns,
    required this.textDirection,
    required this.row,
  }) : super(relayout: stateManager.resizingChangeNotifier);

  @override
  Size getSize(BoxConstraints constraints) {
    final double width = columns.fold(
      0,
      (previousValue, element) => previousValue + element.width,
    );

    return Size(width, stateManager.rowHeight);
  }

  @override
  void performLayout(Size size) {
    final isLTR = textDirection == TextDirection.ltr;
    final items = isLTR ? columns : columns.reversed;
    double dx = 0;

    for (var element in items) {
      var width = element.width;

      if (hasChild(element.field)) {
        // Get the cell to check if it's merged
        final cell = row.cells[element.field];

        // Check if this cell should be rendered (not a spanned cell)
        bool shouldRender = stateManager.cellMergeManager
            .shouldRenderCell(cell ?? TrinaCell(value: null));

        if (shouldRender) {
          // If this is a merged cell, calculate the total width
          if (cell?.merge?.isMainCell == true) {
            final colIdx = columns.indexOf(element);
            final colSpan = cell!.merge!.colSpan;

            // Calculate width by summing the widths of spanned columns
            double totalWidth = 0;
            for (int i = colIdx;
                i < colIdx + colSpan && i < columns.length;
                i++) {
              totalWidth += columns[i].width;
            }
            width = totalWidth;
          }

          layoutChild(
            element.field,
            BoxConstraints.tightFor(
              width: width,
              height: stateManager.style.enableCellBorderHorizontal
                  ? stateManager.rowHeight
                  // we add `cellHorizontalBorderWidth` to the row height so the cells are not
                  // vertically-separated by the disabled horizontal border
                  : stateManager.rowHeight +
                      stateManager.style.cellHorizontalBorderWidth,
            ),
          );

          positionChild(element.field, Offset(dx, 0));
        } else {
          // For spanned cells, give them minimal width to show borders but zero height
          // This preserves the right border while hiding the content
          layoutChild(
            element.field,
            BoxConstraints.tightFor(
              width: width,
              height: stateManager.style.enableCellBorderHorizontal
                  ? stateManager.rowHeight
                  : stateManager.rowHeight +
                      stateManager.style.cellHorizontalBorderWidth,
            ),
          );

          positionChild(element.field, Offset(dx, 0));
        }
      }

      dx += element.width;
    }
  }

  @override
  bool shouldRelayout(covariant MultiChildLayoutDelegate oldDelegate) {
    return true;
  }
}

class _RowContainerWidget extends TrinaStatefulWidget {
  final TrinaGridStateManager stateManager;

  final int rowIdx;

  final TrinaRow row;

  final bool enableRowColorAnimation;

  final Widget child;

  const _RowContainerWidget({
    required this.stateManager,
    required this.rowIdx,
    required this.row,
    required this.enableRowColorAnimation,
    required this.child,
    super.key,
  });

  @override
  State<_RowContainerWidget> createState() => _RowContainerWidgetState();
}

class _RowContainerWidgetState extends TrinaStateWithChange<_RowContainerWidget>
    with
        AutomaticKeepAliveClientMixin,
        TrinaStateWithKeepAlive<_RowContainerWidget> {
  @override
  TrinaGridStateManager get stateManager => widget.stateManager;

  BoxDecoration _decoration = const BoxDecoration();

  Color get _oddRowColor => stateManager.configuration.style.oddRowColor == null
      ? stateManager.configuration.style.rowColor
      : stateManager.configuration.style.oddRowColor!;

  Color get _evenRowColor =>
      stateManager.configuration.style.evenRowColor == null
          ? stateManager.configuration.style.rowColor
          : stateManager.configuration.style.evenRowColor!;

  Color get _rowColor {
    if (widget.row.frozen != TrinaRowFrozen.none) {
      return stateManager.configuration.style.frozenRowColor;
    }
    return _getDefaultRowColor();
  }

  @override
  void initState() {
    super.initState();

    updateState(TrinaNotifierEventForceUpdate.instance);
  }

  @override
  void updateState(TrinaNotifierEvent event) {
    _decoration = update<BoxDecoration>(_decoration, _getBoxDecoration());

    setKeepAlive(
      stateManager.isSelecting && stateManager.currentRowIdx == widget.rowIdx,
    );
  }

  Color _getDefaultRowColor() {
    if (stateManager.rowColorCallback == null) {
      return widget.rowIdx % 2 == 0 ? _oddRowColor : _evenRowColor;
    }

    return stateManager.rowColorCallback!(
      TrinaRowColorContext(
        rowIdx: widget.rowIdx,
        row: widget.row,
        stateManager: stateManager,
      ),
    );
  }

  /// Check if this row should hide its bottom border due to vertical merging
  bool _shouldHideBottomBorder() {
    final columns = stateManager.refColumns;
    final rows = stateManager.refRows;

    // Check if any cell in this row is vertically merged and not the last row of the merge
    for (int colIdx = 0; colIdx < columns.length; colIdx++) {
      final field = columns[colIdx].field;
      final cell = widget.row.cells[field];

      if (cell?.merge?.isMainCell == true) {
        final merge = cell!.merge!;
        if (merge.rowSpan > 1) {
          // This is a main cell of a vertical merge, hide bottom border
          return true;
        }
      }

      // Check if this cell is a spanned cell referencing a main cell above
      if (cell?.merge?.isSpannedCell == true) {
        final merge = cell!.merge!;
        final mainRowIdx = merge.mainCellRowIdx;
        final mainField = merge.mainCellField;

        if (mainRowIdx != null &&
            mainField != null &&
            mainRowIdx < rows.length) {
          final mainCell = rows[mainRowIdx].cells[mainField];
          if (mainCell?.merge?.isMainCell == true) {
            final mainMerge = mainCell!.merge!;
            // Check if this is not the last row of the merge
            if (widget.rowIdx < mainRowIdx + mainMerge.rowSpan - 1) {
              return true;
            }
          }
        }
      }
    }

    return false;
  }

  BoxDecoration _getBoxDecoration() {
    final isCurrentRow = stateManager.currentRowIdx == widget.rowIdx;
    final isCheckedRow = widget.row.checked == true;
    final isHoveredRow = stateManager.isRowIdxHovered(widget.rowIdx);
    final isSelectedRow = stateManager.isSelectedRow(widget.row.key);
    final isTopDragTarget = stateManager.isRowIdxTopDragTarget(widget.rowIdx);
    final isBottomDragTarget = stateManager.isRowIdxBottomDragTarget(
      widget.rowIdx,
    );

    Color rowColor = _rowColor;

    // A current row is considered active if we don't have any selected rows
    final isActiveRow = (isCurrentRow &&
            stateManager.hasFocus &&
            stateManager.selectedRows.isEmpty) ||
        isSelectedRow;
    // Only apply non-transparent activated color here
    // For transparent colors, we'll overlay them in the build method
    if (isActiveRow && stateManager.configuration.style.activatedColor.a > 0) {
      rowColor = stateManager.configuration.style.activatedColor;
    } else if (isCheckedRow) {
      rowColor = stateManager.configuration.style.rowCheckedColor;
    } else if (isHoveredRow &&
        stateManager.configuration.style.enableRowHoverColor) {
      rowColor = stateManager.configuration.style.rowHoveredColor;
    }

    final frozenBorder = widget.row.frozen != TrinaRowFrozen.none
        ? Border(
            top: BorderSide(
              width: stateManager.configuration.style.cellHorizontalBorderWidth,
              color: stateManager.configuration.style.frozenRowBorderColor,
            ),
            bottom: BorderSide(
              width: stateManager.configuration.style.cellHorizontalBorderWidth,
              color: stateManager.configuration.style.frozenRowBorderColor,
            ),
          )
        : null;

    return BoxDecoration(
      color: rowColor,
      border: frozenBorder ??
          Border(
            top: isTopDragTarget
                ? BorderSide(
                    width: stateManager.style.cellHorizontalBorderWidth,
                    color:
                        stateManager.configuration.style.activatedBorderColor,
                  )
                : BorderSide.none,
            bottom: isBottomDragTarget
                ? BorderSide(
                    width: stateManager.style.cellHorizontalBorderWidth,
                    color: stateManager.style.activatedBorderColor,
                  )
                : stateManager.style.enableCellBorderHorizontal &&
                        !_shouldHideBottomBorder()
                    ? BorderSide(
                        width: stateManager.style.cellHorizontalBorderWidth,
                        color: stateManager.style.borderColor,
                      )
                    : BorderSide.none,
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return _AnimatedOrNormalContainer(
      enable: widget.enableRowColorAnimation,
      decoration: _decoration,
      child: widget.child,
    );
  }
}

class _AnimatedOrNormalContainer extends StatelessWidget {
  final bool enable;

  final Widget child;

  final BoxDecoration decoration;

  const _AnimatedOrNormalContainer({
    required this.enable,
    required this.child,
    required this.decoration,
  });

  @override
  Widget build(BuildContext context) {
    return enable
        ? AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: decoration,
            child: child,
          )
        : DecoratedBox(decoration: decoration, child: child);
  }
}
