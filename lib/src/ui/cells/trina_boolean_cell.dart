import 'package:flutter/material.dart';
import 'package:trina_grid/src/ui/cells/popup_cell.dart';
import 'package:trina_grid/trina_grid.dart';

class TrinaBooleanCell extends StatefulWidget implements PopupCell {
  @override
  final TrinaGridStateManager stateManager;

  @override
  final TrinaCell cell;

  @override
  final TrinaColumn column;

  @override
  final TrinaRow row;

  const TrinaBooleanCell({
    required this.stateManager,
    required this.cell,
    required this.column,
    required this.row,
    super.key,
  });

  @override
  TrinaBooleanCellState createState() => TrinaBooleanCellState();
}

class TrinaBooleanCellState extends State<TrinaBooleanCell>
    with PopupCellState<TrinaBooleanCell> {
  @override
  List<TrinaColumn> popupColumns = [];

  @override
  List<TrinaRow> popupRows = [];

  @override
  IconData? get icon => widget.column.type.boolean.popupIcon;

  final List<bool?> _items = [];

  @override
  void initState() {
    super.initState();

    _items.addAll([
      if (widget.column.type.boolean.allowEmpty) null,
      true,
      false,
    ]);

    final rowsHeight = _items.length * widget.stateManager.rowTotalHeight;

    popupHeight = widget.stateManager.configuration.style.columnHeight +
        rowsHeight +
        TrinaGridSettings.gridInnerSpacing +
        widget.stateManager.configuration.style.gridBorderWidth;

    fieldOnSelected = widget.column.title;

    popupColumns = [
      TrinaColumn(
        width:
            widget.column.type.boolean.width ?? TrinaGridSettings.columnWidth,
        title: widget.column.title,
        field: widget.column.title,
        readOnly: true,
        type: TrinaColumnType.text(),
        formatter: widget.column.formatter,
        enableFilterMenuItem: false,
        enableHideColumnMenuItem: false,
        enableSetColumnsMenuItem: false,
        renderer: widget.column.type.boolean.builder == null
            ? (rendererContext) {
                switch (rendererContext.cell.value) {
                  case true:
                    return Text(widget.column.type.boolean.trueText);
                  case false:
                    return Text(widget.column.type.boolean.falseText);
                  default:
                    return const SizedBox.shrink();
                }
              }
            : (rendererContext) {
                var item = _items[rendererContext.rowIdx];

                return widget.column.type.boolean.builder!(item);
              },
      ),
    ];

    popupRows = _items.map((dynamic item) {
      return TrinaRow(cells: {widget.column.title: TrinaCell(value: item)});
    }).toList();
  }

  @override
  void onSelected(TrinaGridOnSelectedEvent event) {
    widget.column.type.boolean.onItemSelected(event);
    super.onSelected(event);
  }

  @override
  void onLoaded(TrinaGridOnLoadedEvent event) {
    super.onLoaded(event);

    event.stateManager.setSelectingMode(TrinaGridSelectingMode.disabled);
  }
}
