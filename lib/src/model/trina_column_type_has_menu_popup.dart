import 'package:flutter/material.dart';
import 'package:trina_grid/src/model/trina_dropdown_menu_filter.dart';
import 'package:trina_grid/src/ui/widgets/trina_dropdown_menu.dart';

/// A contract for column types that use a [TrinaDropdownMenu] inside the popup.
///
/// This interface should be implemented by column types that want to use
/// [TrinaPopupCellStateWithMenu] for their cell's state.
abstract class TrinaColumnTypeHasMenuPopup<T> {
  /// The icon to display in the popup cell.
  IconData? get popupIcon;

  /// {@macro TrinaDropdownMenu.items}
  List<T> get items;

  /// {@macro TrinaDropdownMenu.variant}
  TrinaDropdownMenuVariant get menuVariant;

  /// {@macro TrinaDropdownMenu.itemHeight}
  double get menuItemHeight;

  /// {@macro TrinaDropdownMenu.maxHeight}
  double get menuMaxHeight;

  /// {@macro TrinaDropdownMenu.width}
  double? get menuWidth;

  /// {@macro TrinaDropdownMenu.itemBuilder}
  ItemBuilder<T>? get menuItemBuilder;

  /// {@macro TrinaDropdownMenu.filters}
  List<TrinaDropdownMenuFilter> get menuFilters;

  /// {@macro TrinaDropdownMenu.itemToString}
  String Function(T item)? get itemToString;

  /// {@macro TrinaDropdownMenu.filtersInitiallyExpanded}
  bool get menuFiltersInitiallyExpanded;

  /// {@macro TrinaDropdownMenu.itemToValue}
  dynamic Function(T item)? get itemToValue;

  /// {@macro TrinaDropdownMenu.emptyFilterResultBuilder}
  WidgetBuilder? get menuEmptyFilterResultBuilder;

  /// {@macro TrinaDropdownMenu.emptySearchResultBuilder}
  WidgetBuilder? get menuEmptySearchResultBuilder;

  /// A callback invoked when a value is selected from the popup menu.
  ///
  /// The callback receives the newly selected value.
  void Function(T item)? get onItemSelected;
}
