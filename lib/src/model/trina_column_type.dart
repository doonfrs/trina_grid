import 'package:flutter/material.dart';
import 'package:trina_grid/trina_grid.dart';

abstract interface class TrinaColumnType {
  dynamic get defaultValue;

  /// Set as a string column.
  factory TrinaColumnType.text({dynamic defaultValue = ''}) {
    return TrinaColumnTypeText(defaultValue: defaultValue);
  }

  /// Set to numeric column.
  ///
  /// [format]
  /// '#,###' (Comma every three digits)
  /// '#,###.###' (Allow three decimal places)
  ///
  /// [negative] Allow negative numbers
  ///
  /// [applyFormatOnInit] When the editor loads, it resets the value to [format].
  ///
  /// [allowFirstDot] When accepting negative numbers, a dot is allowed at the beginning.
  /// This option is required on devices where the .- symbol works with one button.
  ///
  /// [locale] Specifies the numeric locale of the column.
  /// If not specified, the default locale is used.
  factory TrinaColumnType.number({
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

  /// Set to currency column.
  ///
  /// [format]
  /// '#,###' (Comma every three digits)
  /// '#,###.###' (Allow three decimal places)
  ///
  /// [negative] Allow negative numbers
  ///
  /// [applyFormatOnInit] When the editor loads, it resets the value to [format].
  ///
  /// [allowFirstDot] When accepting negative numbers, a dot is allowed at the beginning.
  /// This option is required on devices where the .- symbol works with one button.
  ///
  /// [locale] Specifies the currency locale of the column.
  /// If not specified, the default locale is used.
  factory TrinaColumnType.currency({
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

  /// Set to percentage column.
  ///
  /// [decimalDigits] Number of decimal places to display.
  ///
  /// [showSymbol] Whether to show the % symbol.
  ///
  /// [symbolPosition] Position of % symbol (before/after).
  ///
  /// [negative] Allow negative numbers.
  ///
  /// [applyFormatOnInit] When the editor loads, it resets the value to the format.
  ///
  /// [allowFirstDot] When accepting negative numbers, a dot is allowed at the beginning.
  /// This option is required on devices where the .- symbol works with one button.
  ///
  /// [locale] Specifies the numeric locale of the column.
  /// If not specified, the default locale is used.
  ///
  /// [decimalInput] When true, the user can input values like 50 instead of 0.5 for 50%.
  factory TrinaColumnType.percentage({
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

  /// Provides a selection list and sets it as a selection column.
  ///
  /// - [items] The list of values to be displayed in the popup menu.
  /// - [popupIcon] Set the suffixIcon in the cell. Tapping this icon will open a selection popup.
  ///   If this value is set to `null`, the icon does not appear.
  ///
  /// Properties of the default popup menu (ignored when [TrinaColumn.editCellRenderer] or [TrinaGridStateManager.editCellRenderer] is set):
  ///
  /// - [builder] A widget builder to customize the appearance of each item in the popup menu.
  /// - [enableMenuFiltering] Enables a filtering section in the popup.
  /// - [menuFilters] A list of filters that can be applied to the items.
  /// - [menuItemHeight] The height of each item in the popup menu.
  /// - [menuMaxHeight] The maximum height of the popup menu.
  /// - [width] The width of the popup menu. If null, the column width is used.
  /// - [itemToString] A function that returns the string representation of an item.
  /// - [itemToValue] A function that returns a unique value for an item.
  ///   Used for filtering and for identifying the [currentValue]. If not provided, the item object itself is used.
  static TrinaColumnType select(
    List items, {
    final Function(TrinaGridOnSelectedEvent event)? onItemSelected,
    dynamic defaultValue = '',
    bool enableColumnFilter = false,
    IconData? popupIcon = Icons.arrow_drop_down,
    Widget Function(dynamic item)? builder,
    double? width,
    double menuItemHeight = 40,
    double menuMaxHeight = 300,
    bool enableMenuFiltering = false,
    List<TrinaSelectMenuFilter> menuFilters = const [],
    String Function(dynamic item)? itemToString,
    dynamic Function(dynamic item)? itemToValue,
  }) {
    return TrinaColumnTypeSelect(
      onItemSelected: onItemSelected ?? (event) {},
      defaultValue: defaultValue,
      items: items,
      menuFilters: menuFilters,
      enableMenuSearch: false,
      enableMenuFiltering: enableMenuFiltering,
      enableColumnFilter: enableColumnFilter,
      popupIcon: popupIcon,
      menuItemBuilder: builder,
      width: width,
      menuItemHeight: menuItemHeight,
      menuMaxHeight: menuMaxHeight,
      itemToString: itemToString,
      itemToValue: itemToValue,
    );
  }

  /// Provides a selection list with search.
  ///
  /// - [items] The list of values to be displayed in the popup menu.
  /// - [popupIcon] Set the suffixIcon in the cell. Tapping this icon will open a selection popup.
  ///   If this value is set to `null`, the icon does not appear.
  ///
  /// Properties of the default popup menu (ignored when [TrinaColumn.editCellRenderer] or [TrinaGridStateManager.editCellRenderer] is set):
  ///
  /// - [itemToString] A function that returns the string representation of an item, used for searching and default display.
  ///   This parameter is required for search functionality.
  /// - [menuItemBuilder] A widget builder to customize the appearance of each item in the popup menu.
  /// - [enableMenuFiltering] Enables a filtering section in the popup.
  /// - [menuFilters] A list of filters that can be applied to the items.
  /// - [menuItemHeight] The height of each item in the popup menu.
  /// - [menuMaxHeight] The maximum height of the popup menu.
  /// - [menuWidth] The width of the popup menu. If null, the column width is used.
  /// - [itemToValue] A function that returns a unique value for an item.
  ///   Used for filtering and for identifying the [currentValue]. If not provided, the item object itself is used.
  static TrinaColumnType selectWithSearch(
    List items, {
    required String Function(dynamic item) itemToString,
    final Function(TrinaGridOnSelectedEvent event)? onItemSelected,
    dynamic defaultValue = '',
    bool enableColumnFilter = false,
    IconData? popupIcon = Icons.arrow_drop_down,
    Widget Function(dynamic item)? menuItemBuilder,
    double? menuWidth,
    double menuItemHeight = 40,
    double menuMaxHeight = 300,
    bool enableMenuFiltering = false,
    List<TrinaSelectMenuFilter> menuFilters = const [],
    dynamic Function(dynamic item)? itemToValue,
  }) {
    return TrinaColumnTypeSelect(
      onItemSelected: onItemSelected ?? (event) {},
      defaultValue: defaultValue,
      items: items,
      menuFilters: menuFilters,
      enableMenuSearch: true,
      enableMenuFiltering: enableMenuFiltering,
      enableColumnFilter: enableColumnFilter,
      popupIcon: popupIcon,
      menuItemBuilder: menuItemBuilder,
      width: menuWidth,
      menuItemHeight: menuItemHeight,
      menuMaxHeight: menuMaxHeight,
      itemToString: itemToString,
      itemToValue: itemToValue,
    );
  }

  /// Set as a date column.
  ///
  /// [startDate] Range start date (If there is no value, Can select the date without limit)
  ///
  /// [endDate] Range end date
  ///
  /// [format] 'yyyy-MM-dd' (2020-01-01)
  ///
  /// [headerFormat] 'yyyy-MM' (2020-01)
  /// Display year and month in header in date picker popup.
  ///
  /// [applyFormatOnInit] When the editor loads, it resets the value to [format].
  ///
  /// Set the suffixIcon in the [popupIcon] cell. Tap this icon to open the date selection popup.
  /// The default icon is displayed, and if this value is set to null , the icon does not appear.
  ///
  /// [closePopupOnSelection] specify if the popup should be closed when a date is selected.
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

  /// A column for the time type.
  ///
  /// Set the suffixIcon in the [popupIcon] cell. Tap this icon to open the time selection popup.
  /// The default icon is displayed, and if this value is set to null , the icon does not appear.
  ///
  /// - [autoFocusMode] Determines which field receives focus when the time picker opens.
  /// - [saveAndClosePopupWithEnter] When true, pressing Enter saves the time and closes the popup.
  /// - [minTime] The minimum selectable time. Defaults to 0:00.
  /// - [maxTime] The maximum selectable time. Defaults to 23:59.
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

  /// Set as a datetime column combining date and time.
  ///
  /// [startDate] Range start date (If there is no value, Can select the date without limit)
  ///
  /// [endDate] Range end date
  ///
  /// [format] 'yyyy-MM-dd HH:mm' (2020-01-01 15:30)
  ///
  /// [headerFormat] 'yyyy-MM' (2020-01)
  /// Display year and month in header in date picker popup.
  ///
  /// [applyFormatOnInit] When the editor loads, it resets the value to [format].
  ///
  /// Set the suffixIcon in the [popupIcon] cell. Tap this icon to open the date & time selection popup.
  /// The default icon is displayed, and if this value is set to null , the icon does not appear.
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

  /// Set to boolean column.
  ///
  /// [allowEmpty] determines if null/empty values are allowed
  /// [trueText] text to display for true values (defaults to "Yes")
  /// [falseText] text to display for false values (defaults to "No")
  factory TrinaColumnType.boolean({
    dynamic defaultValue = false,
    bool allowEmpty = false,
    String trueText = 'Yes',
    String falseText = 'No',
    double? width,
    IconData? popupIcon,
    Widget Function(dynamic item)? builder,
    Function(TrinaGridOnSelectedEvent event)? onItemSelected,
  }) {
    return TrinaColumnTypeBoolean(
      defaultValue: defaultValue,
      allowEmpty: allowEmpty,
      trueText: trueText,
      falseText: falseText,
      width: width,
      popupIcon: popupIcon,
      menuItemBuilder: builder,
      onItemSelected: onItemSelected ?? (event) {},
    );
  }

  bool isValid(dynamic value);

  int compare(dynamic a, dynamic b);

  dynamic makeCompareValue(dynamic v);

  /// If returns (true, correctedValue) then the correctedValue will be applied to the cell,
  /// see EditingState.changeCellValue() and CellState.filteredCellValue()
  (bool, dynamic) filteredValue({dynamic newValue, dynamic oldValue});
}

mixin TrinaColumnTypeDefaultMixin {
  (bool, dynamic) filteredValue({dynamic newValue, dynamic oldValue}) =>
      (false, newValue);
}
