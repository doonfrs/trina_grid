import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
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

  /// The default editing widget for the popup cell.
  ///
  /// Resolved on every build so the popup honors the host
  /// [ShadTheme] colors (popover/border/radius) instead of
  /// hardcoded Material defaults.
  // Vertical chrome the MenuAnchor adds OUTSIDE our content SizedBox:
  //   - MenuStyle.padding (vertical 4 + 4) = 8
  //   - 1px border top + bottom            = 2
  // Plus a small safety budget for any rounding from Material's internal
  // wrappers. The popup container needs `content + _menuVerticalChrome` of
  // space, so MenuStyle.maximumSize must be raised by that amount —
  // otherwise content == _column.menuMaxHeight gets clipped and triggers an
  // unwanted scrollbar.
  static const double _menuVerticalChrome = 16.0;

  @override
  Widget get defaultEditWidget => Builder(
    builder: (context) {
      final shadTheme = ShadTheme.of(context);
      final shadColors = shadTheme.colorScheme;
      return MenuAnchor(
        alignmentOffset: const Offset(-10, 5),
        controller: menuController,
        consumeOutsideTap: true,
        style: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(shadColors.popover),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: shadTheme.radius,
              side: BorderSide(color: shadColors.border),
            ),
          ),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(vertical: 4),
          ),
          elevation: const WidgetStatePropertyAll(4),
          minimumSize: WidgetStatePropertyAll(
            Size(_column.menuWidth ?? widget.column.width, 0),
          ),
          maximumSize: WidgetStatePropertyAll(
            Size(double.infinity, _column.menuMaxHeight + _menuVerticalChrome),
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
                if (widget.column.checkReadOnly(widget.row, widget.cell)) {
                  return;
                }
                controller.isOpen ? controller.close() : controller.open();
              },
            ),
          );
        },
      );
    },
  );
}
