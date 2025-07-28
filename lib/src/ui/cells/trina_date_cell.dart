import 'package:flutter/material.dart';
import 'package:trina_grid/trina_grid.dart';

import 'popup_cell.dart';

class TrinaDateCell extends StatefulWidget implements PopupCell {
  @override
  final TrinaGridStateManager stateManager;

  @override
  final TrinaCell cell;

  @override
  final TrinaColumn column;

  @override
  final TrinaRow row;

  const TrinaDateCell({
    required this.stateManager,
    required this.cell,
    required this.column,
    required this.row,
    super.key,
  });

  @override
  TrinaDateCellState createState() => TrinaDateCellState();
}

class TrinaDateCellState extends State<TrinaDateCell>
    with PopupCellState<TrinaDateCell> {
  TrinaGridStateManager? popupStateManager;

  @override
  List<TrinaColumn> popupColumns = [];

  @override
  List<TrinaRow> popupRows = [];

  @override
  IconData? get icon => widget.column.type.date.popupIcon;

  @override
  void openPopup() async {
    if (widget.column.checkReadOnly(widget.row, widget.cell)) {
      return;
    }
    isOpenedPopup = true;
    if (widget.stateManager.selectDateCallback != null) {
      final sm = widget.stateManager;
      final date = await sm.selectDateCallback!(widget.cell, widget.column);
      isOpenedPopup = false;
      if (date != null) {
        handleSelected(
          widget.column.type.date.dateFormat.format(date),
        ); // Consider call onSelected
      }
    } else {
      TrinaGridDatePicker(
        context: context,
        initDate: TrinaDateTimeHelper.parseOrNullWithFormat(
          widget.cell.value,
          widget.column.type.date.format,
        ),
        startDate: widget.column.type.date.startDate,
        endDate: widget.column.type.date.endDate,
        dateFormat: widget.column.type.date.dateFormat,
        headerDateFormat: widget.column.type.date.headerDateFormat,
        onSelected: onSelected,
        itemHeight: widget.stateManager.rowTotalHeight,
        configuration: widget.stateManager.configuration.copyWith(
          selectingMode: TrinaGridSelectingMode.cell,
        ),
      );
    }
  }
}
