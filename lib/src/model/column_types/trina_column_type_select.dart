import 'package:flutter/material.dart';
import 'package:trina_grid/src/helper/trina_general_helper.dart';
import 'package:trina_grid/src/model/trina_column_type_has_popup_icon.dart';
import 'package:trina_grid/trina_grid.dart';

class TrinaColumnTypeSelect
    with TrinaColumnTypeDefaultMixin
    implements TrinaColumnType, TrinaColumnTypeHasPopupIcon {
  @override
  final dynamic defaultValue;

  final List<dynamic> items;

  final Widget Function(dynamic item)? builder;

  final bool enableColumnFilter;
  final Function(TrinaGridOnSelectedEvent event) onItemSelected;

  final double? width;

  @override
  final IconData? popupIcon;

  const TrinaColumnTypeSelect({
    required this.onItemSelected,
    this.defaultValue,
    required this.items,
    required this.enableColumnFilter,
    this.popupIcon,
    this.builder,
    this.width,
  });

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
