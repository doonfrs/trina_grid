import 'package:flutter/material.dart';
import 'package:trina_grid/src/model/trina_select_popup_menu_filter.dart';

/// A contract for column types that use a [TrinaSelectMenu] inside the popup.
///
/// This interface should be implemented by column types that want to use
/// [TrinaPopupCellStateWithMenu] for their cell's state.
abstract class TrinaColumnTypeHasMenuPopup {
  /// The icon to display in the popup cell.
  IconData? get popupIcon;

  /// {@macro TrinaSelectMenu.items}
  List<dynamic> get items;

  /// {@macro TrinaSelectMenu.enableFiltering}
  bool get enableMenuFiltering;

  /// {@macro TrinaSelectMenu.itemHeight}
  double get menuItemHeight;

  /// {@macro TrinaSelectMenu.maxHeight}
  double get menuMaxHeight;

  /// {@macro TrinaSelectMenu.enableSearch}
  bool get enableMenuSearch;

  /// {@macro TrinaSelectMenu.itemBuilder}
  Widget Function(dynamic item)? get menuItemBuilder;

  /// {@macro TrinaSelectMenu.filters}
  List<TrinaSelectMenuFilter> get menuFilters;

  /// {@macro TrinaSelectMenu.itemToString}
  String Function(dynamic item)? get itemToString;

  /// {@macro TrinaSelectMenu.itemToValue}
  dynamic Function(dynamic item)? get itemToValue;
}
