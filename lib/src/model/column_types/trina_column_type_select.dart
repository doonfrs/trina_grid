import 'package:flutter/material.dart';
import 'package:trina_grid/src/helper/trina_general_helper.dart';
import 'package:trina_grid/src/model/trina_column_type_has_menu_popup.dart';
import 'package:trina_grid/trina_grid.dart';

class TrinaColumnTypeSelect
    with TrinaColumnTypeDefaultMixin
    implements TrinaColumnType, TrinaColumnTypeHasMenuPopup {
  const TrinaColumnTypeSelect({
    required this.onItemSelected,
    required this.items,
    required this.enableColumnFilter,
    this.defaultValue,
    this.menuFilters = const [],
    this.popupIcon,
    this.builder,
    this.width,
    this.menuItemHeight = 40,
    this.menuMaxHeight = 300,
    this.enableMenuFiltering = true,
    this.enableMenuSearch = true,
  });

  @override
  final dynamic defaultValue;

  @override
  final List<TrinaSelectMenuFilter> menuFilters;

  @override
  final IconData? popupIcon;

  @override
  final bool enableMenuFiltering;

  @override
  final bool enableMenuSearch;

  @override
  final double menuMaxHeight;

  @override
  final double menuItemHeight;

  @override
  Widget Function(dynamic item)? get menuItemBuilder => builder;

  final List<dynamic> items;

  final Widget Function(dynamic item)? builder;

  final bool enableColumnFilter;

  final Function(TrinaGridOnSelectedEvent event) onItemSelected;

  /// The width of the popup menu.
  ///
  /// if null, the width of the column will be used.
  final double? width;

  @override
  bool isValid(dynamic value) => items.contains(value) == true;

  @override
  int compare(dynamic a, dynamic b) {
    return TrinaGeneralHelper.compareWithNull(a, b, () {
      return items.indexOf(a).compareTo(items.indexOf(b));
    });
  }

  @override
  dynamic makeCompareValue(dynamic v) {
    return v;
  }
}
