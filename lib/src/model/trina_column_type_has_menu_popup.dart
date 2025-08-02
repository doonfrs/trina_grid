import 'package:flutter/material.dart';
import 'package:trina_grid/src/model/trina_select_popup_menu_filter.dart';

/// A contract for column types that use a menu popup for editing.
///
/// This interface should be implemented by column types that want to use
/// [TrinaPopupCellStateWithMenu] for their cell's state.
abstract class TrinaColumnTypeHasMenuPopup {
  /// The icon to display in the popup cell.
  IconData? get popupIcon;

  /// Whether to enable filtering in the popup menu.
  bool get enableMenuFiltering;

  /// The height of each item in the popup menu.
  double get menuItemHeight;

  /// The maximum height of the popup menu.
  double get menuMaxHeight;

  /// Whether to enable search in the popup menu.
  bool get enableMenuSearch;

  /// A builder for the items in the popup menu.
  Widget Function(dynamic item)? get menuItemBuilder;

  /// The filters to apply to the popup menu.
  List<TrinaSelectMenuFilter> get menuFilters;
}
