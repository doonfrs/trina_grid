import 'package:flutter/material.dart';
import 'package:trina_grid/src/ui/widgets/trina_dropdown_menu.dart';
import 'package:trina_grid/trina_grid.dart';

/// Defines the behavior and properties of a `TrinaColumn`.
///
/// The column type determines how the data in a cell is parsed, validated,
/// compared for sorting, and rendered in both view and edit modes.
///
/// Use the factory constructors like [TrinaColumnType.text],
/// [TrinaColumnType.number], or [TrinaColumnType.select] to create
/// pre-configured column types.
abstract interface class TrinaColumnType {
  /// The default value for a new cell in a column of this type.
  dynamic get defaultValue;

  /// Creates a column for plain text.
  factory TrinaColumnType.text({
    /// {@macro TrinaColumnType.defaultValue}
    dynamic defaultValue = '',
  }) {
    return TrinaColumnTypeText(defaultValue: defaultValue);
  }

  /// Creates a column for numeric values.
  ///
  /// - [format]: A `NumberFormat` string (e.g., '#,###', '#,###.###').
  /// - [negative]: Whether to allow negative numbers.
  /// - [applyFormatOnInit]: Whether to apply the format when the editor loads.
  /// - [allowFirstDot]: Allows a leading dot for negative number entry on
  ///   certain keyboards.
  /// - [locale]: The locale for number formatting.
  factory TrinaColumnType.number({
    /// {@macro TrinaColumnType.defaultValue}
    dynamic defaultValue = 0,
    bool negative = true,
    String format = '#,###',
    bool applyFormatOnInit = true,
    bool allowFirstDot = false,
    String? locale,
  }) {
    return TrinaColumnTypeNumber(
      defaultValue: defaultValue,
      format: format,
      negative: negative,
      applyFormatOnInit: applyFormatOnInit,
      allowFirstDot: allowFirstDot,
      locale: locale,
    );
  }

  /// Creates a column for currency values.
  ///
  /// - [format]: A `NumberFormat` string (e.g., '#,###', '#,###.###').
  /// - [negative]: Whether to allow negative numbers.
  /// - [applyFormatOnInit]: Whether to apply the format when the editor loads.
  /// - [allowFirstDot]: Allows a leading dot for negative number entry.
  /// - [locale]: The locale for currency formatting.
  /// - [name]: The currency name (e.g., 'USD').
  /// - [symbol]: The currency symbol (e.g., '$').
  /// - [decimalDigits]: The number of decimal places.
  factory TrinaColumnType.currency({
    /// {@macro TrinaColumnType.defaultValue}
    dynamic defaultValue = 0,
    bool negative = true,
    String? format,
    bool applyFormatOnInit = true,
    bool allowFirstDot = false,
    String? locale,
    String? name,
    String? symbol,
    int? decimalDigits,
  }) {
    return TrinaColumnTypeCurrency(
      defaultValue: defaultValue,
      format: format,
      negative: negative,
      applyFormatOnInit: applyFormatOnInit,
      allowFirstDot: allowFirstDot,
      locale: locale,
      name: name,
      symbol: symbol,
      decimalDigits: decimalDigits,
    );
  }

  /// Creates a column for percentage values.
  ///
  /// - [decimalDigits]: The number of decimal places to display.
  /// - [showSymbol]: Whether to show the '%' symbol.
  /// - [symbolPosition]: The position of the '%' symbol.
  /// - [negative]: Whether to allow negative numbers.
  /// - [applyFormatOnInit]: Whether to apply the format when the editor loads.
  /// - [allowFirstDot]: Allows a leading dot for negative number entry.
  /// - [locale]: The locale for number formatting.
  /// - [decimalInput]: If true, input '50' is treated as 50% (0.5).
  factory TrinaColumnType.percentage({
    /// {@macro TrinaColumnType.defaultValue}
    dynamic defaultValue = 0,
    int decimalDigits = 2,
    bool showSymbol = true,
    PercentageSymbolPosition symbolPosition = PercentageSymbolPosition.after,
    bool negative = true,
    bool applyFormatOnInit = true,
    bool allowFirstDot = false,
    String? locale,
    bool decimalInput = false,
  }) {
    return TrinaColumnTypePercentage(
      defaultValue: defaultValue,
      decimalDigits: decimalDigits,
      showSymbol: showSymbol,
      symbolPosition: symbolPosition,
      negative: negative,
      applyFormatOnInit: applyFormatOnInit,
      allowFirstDot: allowFirstDot,
      locale: locale,
      decimalInput: decimalInput,
    );
  }

  /// Creates a column with a simple dropdown selection list.
  ///
  /// This is a basic dropdown without search or filtering. For more advanced
  /// options, see [TrinaColumnType.selectWithSearch] or
  /// [TrinaColumnType.selectWithFilters].
  ///
  /// - [items]: The list of values to display in the popup menu.
  /// - [onItemSelected]: A callback invoked when an item is selected.
  /// - [enableColumnFilter]: Whether to enable the default column filter UI.
  /// - [popupIcon]: The icon used to open the selection menu.
  ///
  /// ### Popup Menu Properties
  ///
  /// These properties are ignored if [TrinaColumn.editCellRenderer]
  ///  or [TrinaGridStateManager.editCellRenderer] is provided.
  ///
  /// - [menuItemBuilder]:
  ///   {@macro TrinaDropdownMenu.itemBuilder}
  /// - [menuItemHeight]:
  ///   {@macro TrinaDropdownMenu.itemHeight}
  /// - [menuMaxHeight]:
  ///   {@macro TrinaDropdownMenu.maxHeight}
  /// - [menuWidth]:
  ///   {@macro TrinaDropdownMenu.width}
  /// - [itemToString]:
  ///   {@macro TrinaDropdownMenu.itemToString}
  /// - [itemToValue]:
  ///   {@macro TrinaDropdownMenu.itemToValue}
  ///
  static TrinaColumnType select<T>(
    List<T> items, {
    void Function(T item)? onItemSelected,
    T? defaultValue,
    bool enableColumnFilter = false,
    IconData? popupIcon = Icons.arrow_drop_down,
    double? menuWidth,
    double menuItemHeight = 40,
    double menuMaxHeight = 300,
    ItemBuilder<T>? menuItemBuilder,
    String Function(T item)? itemToString,
    dynamic Function(T item)? itemToValue,
  }) {
    return TrinaColumnTypeSelect<T>(
      menuVariant: TrinaDropdownMenuVariant.select,
      onItemSelected: onItemSelected,
      defaultValue: defaultValue,
      items: items,
      enableColumnFilter: enableColumnFilter,
      popupIcon: popupIcon,
      menuItemBuilder: menuItemBuilder,
      menuWidth: menuWidth,
      menuItemHeight: menuItemHeight,
      menuMaxHeight: menuMaxHeight,
      itemToString: itemToString,
      itemToValue: itemToValue,
    );
  }

  /// Creates a column with a searchable dropdown selection list.
  ///
  /// - [items]: The list of values to display in the popup menu.
  /// - [itemToString]: **Required.** A function to convert an item to its string
  ///   representation for searching.
  /// - [onItemSelected]: A callback invoked when an item is selected.
  /// - [enableColumnFilter]: Whether to enable the default column filter UI.
  /// - [popupIcon]: The icon used to open the selection menu.
  ///
  /// ### Popup Menu Properties
  /// These properties are ignored if [TrinaColumn.editCellRenderer]
  ///  or [TrinaGridStateManager.editCellRenderer] is provided.
  ///
  /// - [menuEmptySearchResultBuilder]:
  ///   {@macro TrinaDropdownMenu.emptySearchResultBuilder}
  /// - [menuItemBuilder]:
  ///   {@macro TrinaDropdownMenu.itemBuilder}
  /// - [menuItemHeight]:
  ///   {@macro TrinaDropdownMenu.itemHeight}
  /// - [menuMaxHeight]:
  ///   {@macro TrinaDropdownMenu.maxHeight}
  /// - [menuWidth]:
  ///   {@macro TrinaDropdownMenu.width}
  /// - [itemToString]:
  ///   {@macro TrinaDropdownMenu.itemToString}
  /// - [itemToValue]:
  ///   {@macro TrinaDropdownMenu.itemToValue}
  static TrinaColumnType selectWithSearch<T>(
    List<T> items, {
    required String Function(T item) itemToString,
    T? defaultValue,
    bool enableColumnFilter = false,
    IconData? popupIcon = Icons.arrow_drop_down,
    ItemBuilder<T>? menuItemBuilder,
    double? menuWidth,
    double menuItemHeight = 40,
    double menuMaxHeight = 300,
    void Function(T item)? onItemSelected,
    WidgetBuilder? menuEmptySearchResultBuilder,
    dynamic Function(T item)? itemToValue,
  }) {
    return TrinaColumnTypeSelect<T>(
      onItemSelected: onItemSelected,
      defaultValue: defaultValue,
      items: items,
      menuVariant: TrinaDropdownMenuVariant.selectWithSearch,
      enableColumnFilter: enableColumnFilter,
      popupIcon: popupIcon,
      menuItemBuilder: menuItemBuilder,
      menuWidth: menuWidth,
      menuItemHeight: menuItemHeight,
      menuMaxHeight: menuMaxHeight,
      itemToString: itemToString,
      itemToValue: itemToValue,
      menuEmptySearchResultBuilder: menuEmptySearchResultBuilder,
    );
  }

  /// Creates a column with a dropdown list that has advanced filtering.
  ///
  /// - [items]: The list of values to display in the popup menu.
  /// - [onItemSelected]: A callback invoked when an item is selected.
  /// - [enableColumnFilter]: Whether to enable the default column filter UI.
  /// - [popupIcon]: The icon used to open the selection menu.
  ///
  /// ### Popup Menu Properties
  ///
  /// These properties are ignored if [TrinaColumn.editCellRenderer]
  ///  or [TrinaGridStateManager.editCellRenderer] is provided.
  ///
  /// - [menuFilters]:
  ///   {@macro TrinaDropdownMenu.filters}
  /// - [menuEmptyFilterResultBuilder]:
  ///   {@macro TrinaDropdownMenu.emptyFilterResultBuilder}
  /// - [menuItemBuilder]:
  ///   {@macro TrinaDropdownMenu.itemBuilder}
  /// - [menuItemHeight]:
  ///   {@macro TrinaDropdownMenu.itemHeight}
  /// - [menuMaxHeight]:
  ///   {@macro TrinaDropdownMenu.maxHeight}
  /// - [menuWidth]:
  ///   {@macro TrinaDropdownMenu.width}
  /// - [itemToString]:
  ///   {@macro TrinaDropdownMenu.itemToString}
  /// - [itemToValue]:
  ///   {@macro TrinaDropdownMenu.itemToValue}
  static TrinaColumnType selectWithFilters<T>(
    List<T> items, {
    required List<TrinaDropdownMenuFilter> menuFilters,
    T? defaultValue,
    bool enableColumnFilter = false,
    IconData? popupIcon = Icons.arrow_drop_down,
    ItemBuilder<T>? menuItemBuilder,
    WidgetBuilder? menuEmptyFilterResultBuilder,
    double? menuWidth,
    double menuItemHeight = 40,
    double menuMaxHeight = 300,
    bool menuFiltersInitiallyExpanded = true,
    void Function(T item)? onItemSelected,
    String Function(T item)? itemToString,
    dynamic Function(T item)? itemToValue,
  }) {
    return TrinaColumnTypeSelect<T>(
      items: items,
      menuVariant: TrinaDropdownMenuVariant.selectWithFilters,
      defaultValue: defaultValue,
      menuFilters: menuFilters,
      onItemSelected: onItemSelected,
      menuEmptyFilterResultBuilder: menuEmptyFilterResultBuilder,
      enableColumnFilter: enableColumnFilter,
      popupIcon: popupIcon,
      menuFiltersInitiallyExpanded: menuFiltersInitiallyExpanded,
      menuItemBuilder: menuItemBuilder,
      menuWidth: menuWidth,
      menuItemHeight: menuItemHeight,
      menuMaxHeight: menuMaxHeight,
      itemToString: itemToString,
      itemToValue: itemToValue,
    );
  }

  /// Creates a column for date values.
  ///
  /// - [startDate]: The earliest selectable date.
  /// - [endDate]: The latest selectable date.
  /// - [format]: The `DateFormat` string for displaying the date.
  /// - [headerFormat]: The `DateFormat` string for the date picker header.
  /// - [applyFormatOnInit]: Whether to apply the format when the editor loads.
  /// - [popupIcon]: The icon used to open the date picker.
  /// - [closePopupOnSelection]: If true, the popup closes after a date is selected.
  factory TrinaColumnType.date({
    dynamic defaultValue = '',
    DateTime? startDate,
    DateTime? endDate,
    String format = 'yyyy-MM-dd',
    String headerFormat = 'yyyy-MM',
    bool applyFormatOnInit = true,
    IconData? popupIcon = Icons.date_range,
    bool closePopupOnSelection = false,
  }) {
    return TrinaColumnTypeDate(
      defaultValue: defaultValue,
      startDate: startDate,
      endDate: endDate,
      format: format,
      headerFormat: headerFormat,
      applyFormatOnInit: applyFormatOnInit,
      popupIcon: popupIcon,
      closePopupOnSelection: closePopupOnSelection,
    );
  }

  /// Creates a column for time values.
  ///
  /// - [popupIcon]: The icon used to open the time picker.
  /// - [autoFocusMode]: Determines which field receives focus when the picker opens.
  /// - [saveAndClosePopupWithEnter]: If true, Enter saves and closes the popup.
  /// - [minTime]: The minimum selectable time.
  /// - [maxTime]: The maximum selectable time.
  factory TrinaColumnType.time({
    dynamic defaultValue = '00:00',
    IconData? popupIcon = Icons.access_time,
    TrinaTimePickerAutoFocusMode autoFocusMode =
        TrinaTimePickerAutoFocusMode.hourField,
    bool saveAndClosePopupWithEnter = true,
    TimeOfDay minTime = const TimeOfDay(hour: 0, minute: 0),
    TimeOfDay maxTime = const TimeOfDay(hour: 23, minute: 59),
  }) {
    return TrinaColumnTypeTime(
      defaultValue: defaultValue,
      popupIcon: popupIcon,
      autoFocusMode: autoFocusMode,
      saveAndClosePopupWithEnter: saveAndClosePopupWithEnter,
      minTime: minTime,
      maxTime: maxTime,
    );
  }

  /// Creates a column for combined date and time values.
  ///
  /// - [startDate]: The earliest selectable date.
  /// - [endDate]: The latest selectable date.
  /// - [format]: The `DateFormat` string for displaying the date and time.
  /// - [headerFormat]: The `DateFormat` string for the date picker header.
  /// - [applyFormatOnInit]: Whether to apply the format when the editor loads.
  /// - [popupIcon]: The icon used to open the date & time picker.
  factory TrinaColumnType.dateTime({
    dynamic defaultValue = '',
    DateTime? startDate,
    DateTime? endDate,
    String format = 'yyyy-MM-dd HH:mm',
    String headerFormat = 'yyyy-MM',
    bool applyFormatOnInit = true,
    IconData? popupIcon = Icons.event_available,
  }) {
    return TrinaColumnTypeDateTime(
      defaultValue: defaultValue,
      startDate: startDate,
      endDate: endDate,
      format: format,
      headerFormat: headerFormat,
      applyFormatOnInit: applyFormatOnInit,
      popupIcon: popupIcon,
    );
  }

  /// Creates a column for boolean (`true`/`false`) values.
  ///
  /// - [allowEmpty]: If true, `null` or empty string are considered valid values.
  /// - [trueText]: The text to display for `true`.
  /// - [falseText]: The text to display for `false`.
  /// - [onItemSelected]: A callback invoked when an item is selected.
  /// - [menuWidth]: The width of the dropdown menu.
  /// - [popupIcon]: The icon to display in the popup cell.
  /// - [menuItemBuilder]: A function to provide a custom widget for each item in the list.
  factory TrinaColumnType.boolean({
    dynamic defaultValue = false,
    bool allowEmpty = false,
    String trueText = 'Yes',
    String falseText = 'No',
    double? menuWidth,
    IconData? popupIcon,
    Widget Function(dynamic item)? menuItemBuilder,
    void Function(dynamic item)? onItemSelected,
  }) {
    return TrinaColumnTypeBoolean(
      defaultValue: defaultValue,
      allowEmpty: allowEmpty,
      trueText: trueText,
      falseText: falseText,
      menuWidth: menuWidth,
      popupIcon: popupIcon,
      menuItemBuilder: menuItemBuilder,
      onItemSelected: onItemSelected,
    );
  }

  /// Creates a column for custom or complex data types.
  ///
  /// Use this when your cell values are maps, custom objects, or any type
  /// not covered by the built-in column types.
  ///
  /// - [defaultValue]: The default value for new cells. Defaults to `null`.
  /// - [isValid]: An optional callback to validate cell values. If not
  ///   provided, all values are considered valid.
  /// - [compare]: An optional callback to compare two values for sorting.
  ///   If not provided, values are compared using `toString()`.
  /// - [toDisplayString]: An optional callback to convert a value to its
  ///   display text. If not provided, `value.toString()` is used.
  factory TrinaColumnType.custom({
    dynamic defaultValue,
    bool Function(dynamic value)? isValid,
    int Function(dynamic a, dynamic b)? compare,
    String Function(dynamic value)? toDisplayString,
  }) {
    return TrinaColumnTypeCustom(
      defaultValue: defaultValue,
      isValid: isValid,
      compare: compare,
      toDisplayString: toDisplayString,
    );
  }

  /// Determines if [value] is valid for this column type.
  bool isValid(dynamic value);

  /// Compares two values for sorting.
  ///
  /// Must return:
  /// - A negative integer if `a` is less than `b`.
  /// - Zero if `a` is equal to `b`.
  /// - A positive integer if `a` is greater than `b`.
  int compare(dynamic a, dynamic b);

  /// Converts a cell value into a comparable format before sorting.
  ///
  /// For example, for a date column, this might convert a formatted string
  /// into a `DateTime` object.
  dynamic makeCompareValue(dynamic v);

  /// Intercepts and potentially transforms a cell's value before it is updated.
  ///
  /// Return a tuple of `(bool, dynamic)`.
  /// If the first element is `true`, the second element will be used as the
  /// new cell value.
  /// If `false`, the original `newValue` is used.
  (bool, dynamic) filteredValue({dynamic newValue, dynamic oldValue});

  Widget buildCell(
    TrinaGridStateManager stateManager,
    TrinaCell cell,
    TrinaColumn column,
    TrinaRow row,
  );
}

/// A mixin that provides a default implementation for [TrinaColumnType.filteredValue].
///
/// The default implementation is a pass-through that does not alter the value.
mixin TrinaColumnTypeDefaultMixin {
  (bool, dynamic) filteredValue({dynamic newValue, dynamic oldValue}) =>
      (false, newValue);
}
