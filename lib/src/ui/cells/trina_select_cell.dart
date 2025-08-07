import 'package:flutter/material.dart';
import 'package:trina_grid/src/ui/miscellaneous/trina_popup_cell_state_with_menu.dart';
import 'package:trina_grid/src/ui/widgets/trina_select_menu.dart';
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
  TrinaColumnTypeSelect get _column => widget.column.type.select;

  @override
  IconData? get popupMenuIcon => _column.popupIcon;

  @override
  late final List menuItems = _column.items;

  @override
  TrinaSelectMenu buildMenu() {
    return TrinaSelectMenu(
      items: menuItems,
      enableFiltering: _column.enableMenuFiltering,
      itemHeight: _column.menuItemHeight,
      maxHeight: _column.menuMaxHeight,
      enableSearch: _column.enableMenuSearch,
      itemBuilder: _column.menuItemBuilder,
      width: widget.column.width,
      initialValue: widget.cell.value,
      filters: _column.menuFilters,
      onItemSelected: (value) {
        handleSelected(value);
        menuController.close();
      },
    );
  }
}
