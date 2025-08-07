import 'package:flutter/material.dart';
import 'package:trina_grid/src/model/trina_column_type_has_menu_popup.dart';
import 'package:trina_grid/trina_grid.dart';

class TrinaColumnTypeBoolean
    with TrinaColumnTypeDefaultMixin
    implements TrinaColumnType, TrinaColumnTypeHasMenuPopup {
  TrinaColumnTypeBoolean({
    required this.defaultValue,
    required this.allowEmpty,
    required this.trueText,
    required this.falseText,
    required this.onItemSelected,
    this.width,
    this.popupIcon,
    this.menuItemBuilder,
  });

  @override
  final dynamic defaultValue;

  @override
  final IconData? popupIcon;

  final bool allowEmpty;
  final String trueText;
  final String falseText;
  final double? width;
  final Function(TrinaGridOnSelectedEvent event) onItemSelected;

  dynamic get value => defaultValue;

  @override
  bool get enableMenuFiltering => false;

  @override
  bool get enableMenuSearch => false;

  @override
  final Widget Function(dynamic item)? menuItemBuilder;

  @override
  double get menuMaxHeight => 300;

  @override
  double get menuItemHeight => 40;

  @override
  List<TrinaSelectMenuFilter> get menuFilters => [];

  @override
  List<bool> get items => [true, false];

  @override
  bool isValid(dynamic value) {
    if (allowEmpty && (value == null || (value is String && value.isEmpty))) {
      return true;
    }
    if (value is bool) return true;
    if (value is num) return true;
    if (value is String) {
      final lowercaseValue = value.toLowerCase();
      return lowercaseValue == 'true' ||
          lowercaseValue == 'false' ||
          lowercaseValue == '1' ||
          lowercaseValue == '0' ||
          (allowEmpty && value.isEmpty);
    }
    return false;
  }

  @override
  int compare(dynamic a, dynamic b) {
    final boolA = parseValue(a);
    final boolB = parseValue(b);

    if (boolA == boolB) return 0;
    if (boolA == null) return -1;
    if (boolB == null) return 1;
    return boolA ? 1 : -1;
  }

  @override
  dynamic makeCompareValue(dynamic value) {
    return parseValue(value);
  }

  dynamic parseValue(dynamic value) {
    if (value == null || (value is String && value.isEmpty)) {
      return allowEmpty ? null : false;
    }
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final lowercaseValue = value.toLowerCase();
      if (lowercaseValue == 'true' || lowercaseValue == '1') return true;
      if (lowercaseValue == 'false' || lowercaseValue == '0') return false;
    }
    return false;
  }

  String formatValue(dynamic value) {
    final boolValue = parseValue(value);
    if (boolValue == null) return '';
    return boolValue ? trueText : falseText;
  }

  @override
  // ignore: prefer_function_declarations_over_variables
  late final String Function(dynamic item)? itemToString = (item) {
    return switch (item) { true => trueText, false => falseText, _ => '-' };
  };

  @override
  // ignore: prefer_function_declarations_over_variables
  final Function(dynamic item)? itemToValue = (item) => item;
}
