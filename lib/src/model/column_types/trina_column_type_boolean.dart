import 'package:flutter/material.dart';
import 'package:trina_grid/src/model/trina_column_type_has_menu_popup.dart';
import 'package:trina_grid/src/ui/cells/trina_boolean_cell.dart';
import 'package:trina_grid/src/ui/widgets/trina_dropdown_menu.dart';
import 'package:trina_grid/trina_grid.dart';

/// A column type for handling boolean (`true`/`false`) data.
///
/// This type provides mechanisms for parsing, validating, comparing, and
/// formatting boolean values. It can interpret various inputs like `true`,
/// `false`, `1`, `0`, 'true', 'false', and empty values.
class TrinaColumnTypeBoolean
    with TrinaColumnTypeDefaultMixin
    implements TrinaColumnType, TrinaColumnTypeHasMenuPopup<bool?> {
  /// Creates a boolean column type with customizable behavior.
  TrinaColumnTypeBoolean({
    required this.defaultValue,
    required this.trueText,
    required this.falseText,
    this.allowEmpty = false,
    this.onItemSelected,
    this.menuWidth,
    this.popupIcon,
    this.menuItemBuilder,
  });

  @override
  final dynamic defaultValue;

  @override
  final IconData? popupIcon;

  /// If `true`, `null` or an empty string are considered valid values.
  final bool allowEmpty;

  /// The text to display for a `true` value.
  final String trueText;

  /// The text to display for a `false` value.
  final String falseText;

  /// {@macro TrinaColumnTypeHasMenuPopup.onItemSelected}
  @override
  final void Function(bool?)? onItemSelected;

  dynamic get value => defaultValue;

  /// {@macro TrinaDropdownMenu.width}
  ///
  /// if null, [TrinaColumn.width] will be used.
  @override
  final double? menuWidth;

  @override
  TrinaDropdownMenuVariant get menuVariant => TrinaDropdownMenuVariant.select;

  @override
  final ItemBuilder<bool?>? menuItemBuilder;

  @override
  double get menuMaxHeight => 300;

  @override
  double get menuItemHeight => 40;

  @override
  List<TrinaDropdownMenuFilter> get menuFilters => [];

  @override
  List<bool> get items => [true, false];

  @override
  WidgetBuilder? get menuEmptyFilterResultBuilder => null;

  @override
  WidgetBuilder? get menuEmptySearchResultBuilder => null;

  @override
  bool get menuFiltersInitiallyExpanded => false;

  /// Checks if a value is a valid boolean representation.
  ///
  /// Considers `bool`, `num`, and specific `String` values ('true', 'false',
  /// '1', '0'). Also respects the [allowEmpty] flag.
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

  /// Compares two values, treating them as booleans.
  ///
  /// `null` values are considered smaller than `false`, and `false` is smaller
  /// than `true`.
  @override
  int compare(dynamic a, dynamic b) {
    final boolA = parseValue(a);
    final boolB = parseValue(b);

    if (boolA == boolB) return 0;
    if (boolA == null) return -1;
    if (boolB == null) return 1;
    return boolA ? 1 : -1;
  }

  /// Converts a value into a comparable boolean representation.
  @override
  dynamic makeCompareValue(dynamic value) {
    return parseValue(value);
  }

  /// Parses a dynamic value into a `bool` or `null`.
  ///
  /// Handles `bool`, `num` (0 is false, others are true), and `String`
  /// ('true', '1' are true; 'false', '0' are false).
  /// Returns `null` for empty values if [allowEmpty] is true.
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

  /// Formats a boolean value into its string representation.
  ///
  /// Uses [trueText] and [falseText]. Returns an empty string for `null`.
  String formatValue(dynamic value) {
    final boolValue = parseValue(value);
    if (boolValue == null) return '';
    return boolValue ? trueText : falseText;
  }

  @override
  late final String Function(dynamic item)? itemToString = _itemToString;

  String _itemToString(dynamic item) {
    return switch (item) {
      true => trueText,
      false => falseText,
      _ => '-',
    };
  }

  @override
  final Function(dynamic item)? itemToValue = null;

  @override
  Widget buildCell(
    TrinaGridStateManager stateManager,
    TrinaCell cell,
    TrinaColumn column,
    TrinaRow row,
  ) {
    return TrinaBooleanCell(
      stateManager: stateManager,
      cell: cell,
      column: column,
      row: row,
    );
  }
}
