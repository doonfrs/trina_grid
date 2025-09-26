import 'package:flutter/material.dart';
import 'package:trina_grid/src/model/trina_column_type_has_menu_popup.dart';
import 'package:trina_grid/src/ui/cells/popup_cell.dart';
import 'package:trina_grid/src/ui/widgets/trina_default_popup_cell_editing_widget.dart';
import 'package:trina_grid/src/ui/widgets/trina_dropdown_menu.dart';

/// Abstract state for popup cells that use a [MenuAnchor] for selection.
abstract class TrinaPopupCellStateWithMenu<T extends PopupCell> extends State<T>
    with PopupCellState<T> {
  /// The list of menu items to display in the menu.
  List<dynamic> get menuItems;

  TrinaColumnTypeHasMenuPopup get _column =>
      widget.column.type as TrinaColumnTypeHasMenuPopup;

  /// The icon to use for the popup menu.
  @override
  IconData? get popupMenuIcon => _column.popupIcon;

  /// Controller for the menu anchor.
  late final menuController = MenuController();

  /// Opens the popup menu.
  @override
  void openPopup(BuildContext context) {
    if (menuController.isOpen == false) {
      menuController.open();
    }
  }

  /// Closes the popup menu.
  @override
  void closePopup(BuildContext context) {
    if (menuController.isOpen) {
      menuController.close();
    }
  }

  /// Builds a [TrinaDropdownMenu] widget to be displayed inside the [MenuAnchor].
  @protected
  TrinaDropdownMenu buildMenu();

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
        minimumSize: WidgetStatePropertyAll(
          Size(_column.menuWidth ?? widget.column.width, 0),
        ),
        maximumSize: WidgetStatePropertyAll(
          Size(double.infinity, _column.menuMaxHeight),
        ),
        alignment: Alignment.bottomLeft,
      ),
      menuChildren: [buildMenu()],
      builder: (context, controller, child) {
        return Focus(
          onKeyEvent: (node, event) =>
              handleOpeningPopupWithKeyboard(node, event, controller.isOpen),
          focusNode: textFocus,
          child: TrinaDefaultPopupCellEditingWidget(
            popupMenuIcon: popupMenuIcon,
            controller: textController,
            stateManager: widget.stateManager,
            onTap: () {
              if (widget.column.readOnly) {
                return;
              }
              controller.isOpen ? controller.close() : controller.open();
            },
          ),
        );
      },
    );
  }

  /// The default editing widget for the popup cell.
  @override
  late final Widget defaultEditWidget;
}
