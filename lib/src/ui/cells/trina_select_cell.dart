import 'package:flutter/material.dart';
import 'package:trina_grid/trina_grid.dart';

import 'popup_cell.dart';

class TrinaSelectCell extends StatefulWidget implements PopupCell {
  @override
  final TrinaGridStateManager stateManager;

  @override
  final TrinaCell cell;

  @override
  final TrinaColumn column;

  @override
  final TrinaRow row;

  const TrinaSelectCell({
    required this.stateManager,
    required this.cell,
    required this.column,
    required this.row,
    super.key,
  });

  @override
  TrinaSelectCellState createState() => TrinaSelectCellState();
}

class TrinaSelectCellState extends State<TrinaSelectCell>
    with PopupCellState<TrinaSelectCell> {
  @override
  List<TrinaColumn> popupColumns = [];

  @override
  List<TrinaRow> popupRows = [];

  @override
  IconData? get icon => widget.column.type.select.popupIcon;

  late bool enableColumnFilter;

  @override
  void initState() {
    super.initState();

    enableColumnFilter = widget.column.type.select.enableColumnFilter;

    final columnFilterHeight = enableColumnFilter
        ? widget.stateManager.configuration.style.columnFilterHeight
        : 0;

    final rowsHeight = widget.column.type.select.items.length *
        widget.stateManager.rowTotalHeight;

    popupHeight = widget.stateManager.configuration.style.columnHeight +
        columnFilterHeight +
        rowsHeight +
        TrinaGridSettings.gridInnerSpacing +
        widget.stateManager.configuration.style.gridBorderWidth;

    fieldOnSelected = widget.column.title;

    popupColumns = [
      TrinaColumn(
        width: widget.column.type.select.width ?? TrinaGridSettings.columnWidth,
        title: widget.column.title,
        field: widget.column.title,
        readOnly: true,
        type: TrinaColumnType.text(),
        formatter: widget.column.formatter,
        enableFilterMenuItem: enableColumnFilter,
        enableHideColumnMenuItem: false,
        enableSetColumnsMenuItem: false,
        renderer: widget.column.type.select.builder == null
            ? null
            : (rendererContext) {
                var item =
                    widget.column.type.select.items[rendererContext.rowIdx];

                return widget.column.type.select.builder!(item);
              },
      ),
    ];

    popupRows = widget.column.type.select.items.map((dynamic item) {
      return TrinaRow(cells: {widget.column.title: TrinaCell(value: item)});
    }).toList();
  }

  @override
  void onSelected(TrinaGridOnSelectedEvent event) {
    widget.column.type.select.onItemSelected(event);
    super.onSelected(event);
  }

  @override
  void onLoaded(TrinaGridOnLoadedEvent event) {
    super.onLoaded(event);

    if (enableColumnFilter) {
      event.stateManager.setShowColumnFilter(true, notify: false);
    }

    event.stateManager.setSelectingMode(TrinaGridSelectingMode.disabled);
  }
}
