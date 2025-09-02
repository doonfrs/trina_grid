import 'package:flutter/material.dart';
import 'package:trina_grid/src/ui/miscellaneous/trina_popup_cell_state_with_menu.dart';
import 'package:trina_grid/src/ui/widgets/trina_dropdown_menu.dart';
import 'package:trina_grid/trina_grid.dart';

import 'popup_cell.dart';

class TrinaSelectCell<T> extends StatefulWidget implements PopupCell {
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
  TrinaSelectCellState<T> createState() => TrinaSelectCellState<T>();
}

class TrinaSelectCellState<T>
    extends TrinaPopupCellStateWithMenu<TrinaSelectCell<T>> {
  TrinaColumnTypeSelect<T> get _column => widget.column.type.asSelect();

  @override
  IconData? get popupMenuIcon => _column.popupIcon;

  @override
  List<T> get menuItems => _column.items;

  @override
  TrinaDropdownMenu<T> buildMenu() {
    return TrinaDropdownMenu.variant(
      _column.menuVariant,
      items: menuItems,
      filters: _column.menuFilters,
      emptyFilterResultBuilder: _column.menuEmptyFilterResultBuilder,
      emptySearchResultBuilder: _column.menuEmptySearchResultBuilder,
      itemToString: _column.itemToString,
      onItemSelected: (item) {
        _column.onItemSelected?.call(item);

        handleSelected(item);
        menuController.close();
      },
      width: _column.menuWidth ?? widget.column.width,
      initialValue: widget.cell.value,
      itemHeight: _column.menuItemHeight,
      maxHeight: _column.menuMaxHeight,
      itemBuilder: _column.menuItemBuilder,
      itemToValue: _column.itemToValue,
    );
  }
}
