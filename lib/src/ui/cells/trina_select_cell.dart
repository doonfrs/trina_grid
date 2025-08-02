import 'package:flutter/material.dart';
import 'package:trina_grid/src/model/trina_select_menu_item.dart';
import 'package:trina_grid/src/ui/miscellaneous/trina_popup_cell_state_with_menu.dart';
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

class TrinaSelectCellState
    extends TrinaPopupCellStateWithMenu<TrinaSelectCell> {
  @override
  IconData? get popupMenuIcon => widget.column.type.select.popupIcon;

  @override
  List<TrinaSelectMenuItem> get menuItems => widget.column.type.select.items
      .map((item) => TrinaSelectMenuItem(value: item))
      .toList(growable: false);
}
