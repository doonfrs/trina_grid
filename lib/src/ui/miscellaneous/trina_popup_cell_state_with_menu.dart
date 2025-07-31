import 'package:flutter/material.dart';
import 'package:trina_grid/src/model/trina_column_type_has_menu_popup.dart';
import 'package:trina_grid/src/model/trina_select_menu_item.dart';
import 'package:trina_grid/src/ui/cells/popup_cell.dart';
import 'package:trina_grid/src/ui/widgets/trina_default_popup_cell_editing_widget.dart';
import 'package:trina_grid/src/ui/widgets/trina_select_menu.dart';

/// Abstract state for popup cells that use a [MenuAnchor] for selection.
abstract class TrinaPopupCellStateWithMenu<T extends PopupCell> extends State<T>
    with PopupCellState<T> {
  /// The list of menu items to display in the menu.
  List<TrinaSelectMenuItem> get menuItems;

  TrinaColumnTypeHasMenuPopup get _column =>
      widget.column.type as TrinaColumnTypeHasMenuPopup;

  @override

  /// The icon to use for the popup menu.
  IconData? get popupMenuIcon => _column.popupIcon;

  /// Controller for the menu anchor.
  late final menuController = MenuController();

  @override

  /// Opens the popup menu.
  void openPopup(BuildContext context) {
    if (menuController.isOpen == false) {
      menuController.open();
    }
  }

  @override

  /// Closes the popup menu.
  void closePopup(BuildContext context) {
    if (menuController.isOpen) {
      menuController.close();
    }
  }

  /// Builds the widget to be displayed inside the menu.
  ///
  /// Subclasses can override this method to add custom widgets to the menu
  /// or to replace the default [TrinaSelectMenu] entirely.
  @protected
  Widget buildMenu() {
    return TrinaSelectMenu(
      menuItems: menuItems,
      enableFiltering: _column.enableMenuFiltering,
      itemHeight: _column.menuItemHeight,
      maxHeight: _column.menuMaxHeight,
      enableSearch: _column.enableMenuSearch,
      onItemSelected: (value) {
        handleSelected(value);
        menuController.close();
      },
      itemBuilder: _column.menuItemBuilder,
      width: widget.column.width,
      currentValue: widget.cell.value,
      isDarkMode: widget.stateManager.style.isDarkStyle,
      filters: _column.menuFilters,
    );
  }

  @override
  void initState() {
    super.initState();

    // Build the default editing widget using a menu anchor and menu items.
    defaultEditWidget = MenuAnchor(
      alignmentOffset: const Offset(-10, 5),
      controller: menuController,
      consumeOutsideTap: true,
      style: MenuStyle(
        backgroundColor: widget.stateManager.style.isDarkStyle
            ? WidgetStatePropertyAll(Colors.grey.shade900)
            : const WidgetStatePropertyAll(Colors.white),
        fixedSize: WidgetStatePropertyAll(Size.fromWidth(widget.column.width)),
        alignment: Alignment.bottomLeft,
      ),
      menuChildren: [
        buildMenu(),
      ],
      builder: (context, controller, child) {
        return Focus(
          onKeyEvent: (node, event) =>
              handleOpeningPopupWithKeyboard(node, event, controller.isOpen),
          focusNode: textFocus,
          child: TrinaDefaultPopupCellEditingWidget(
            popupMenuIcon: popupMenuIcon,
            controller: textController,
            onTap: () =>
                controller.isOpen ? controller.close() : controller.open(),
          ),
        );
      },
    );
  }

  @override

  /// The default editing widget for the popup cell.
  late final Widget defaultEditWidget;
}
