import 'package:flutter/material.dart';
import 'package:trina_grid/src/model/trina_select_menu_item.dart';
import 'package:trina_grid/trina_grid.dart';
import 'package:trina_grid/src/ui/cells/popup_cell.dart';
import 'package:trina_grid/src/ui/miscellaneous/trina_popup_cell_state_with_menu.dart';

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

class TrinaBooleanCellState
    extends TrinaPopupCellStateWithMenu<TrinaBooleanCell> {
  @override
  IconData? get popupMenuIcon => widget.column.type.boolean.popupIcon;

  @override
  List<TrinaSelectMenuItem> get menuItems {
    return [
      if (widget.column.type.boolean.allowEmpty)
        TrinaSelectMenuItem(value: null, label: '-'),
      TrinaSelectMenuItem(
          value: true, label: widget.column.type.boolean.trueText),
      TrinaSelectMenuItem(
          value: false, label: widget.column.type.boolean.falseText),
    ];
  }
}
