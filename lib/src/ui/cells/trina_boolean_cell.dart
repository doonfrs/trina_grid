import 'package:flutter/material.dart';
import 'package:trina_grid/src/ui/widgets/trina_dropdown_menu.dart';
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
  TrinaColumnTypeBoolean get _column => widget.column.type.boolean;

  @override
  IconData? get popupMenuIcon => widget.column.type.boolean.popupIcon;

  @override
  List<bool?> get menuItems {
    return [if (_column.allowEmpty) null, true, false];
  }

  @override
  TrinaDropdownMenu<bool?> buildMenu() {
    return TrinaDropdownMenu(
      items: menuItems,
      itemHeight: _column.menuItemHeight,
      maxHeight: _column.menuMaxHeight,
      width: _column.menuWidth ?? widget.column.width,
      initialValue: widget.cell.value,
      itemBuilder: _column.menuItemBuilder,
      itemToString: _column.itemToString,
      itemToValue: _column.itemToValue,
      onItemSelected: (value) {
        _column.onItemSelected?.call(value);
        handleSelected(value);
        menuController.close();
      },
    );
  }
}
