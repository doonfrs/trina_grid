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
  /// If [enableColumnFilter] is true, column filtering is enabled in the selection popup.
  ///
  /// Set the suffixIcon in the [popupIcon] cell. Tapping this icon will open a selection popup.
  /// The default icon is displayed, and if this value is set to null , the icon does not appear.
  factory TrinaColumnType.select(
    List<dynamic> items, {
    final Function(TrinaGridOnSelectedEvent event)? onItemSelected,
    dynamic defaultValue = '',
    bool enableColumnFilter = false,
    IconData? popupIcon = Icons.arrow_drop_down,
    Widget Function(dynamic item)? builder,
    double? width,
  }) {
    return TrinaColumnTypeSelect(
      onItemSelected: onItemSelected ?? (event) {},
      defaultValue: defaultValue,
      items: items,
      enableColumnFilter: enableColumnFilter,
      popupIcon: popupIcon,
      builder: builder,
      width: width,
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
  factory TrinaColumnType.date({
    dynamic defaultValue = '',
    DateTime? startDate,
    DateTime? endDate,
    String format = 'yyyy-MM-dd',
    String headerFormat = 'yyyy-MM',
    bool applyFormatOnInit = true,
    IconData? popupIcon = Icons.date_range,
  }) {
    return TrinaColumnTypeDate(
      defaultValue: defaultValue,
      startDate: startDate,
      endDate: endDate,
      format: format,
      headerFormat: headerFormat,
      applyFormatOnInit: applyFormatOnInit,
      popupIcon: popupIcon,
    );
  }

  /// A column for the time type.
  ///
  /// Set the suffixIcon in the [popupIcon] cell. Tap this icon to open the time selection popup.
  /// The default icon is displayed, and if this value is set to null , the icon does not appear.
  factory TrinaColumnType.time({
    dynamic defaultValue = '00:00',
    IconData? popupIcon = Icons.access_time,
  }) {
    return TrinaColumnTypeTime(
      defaultValue: defaultValue,
      popupIcon: popupIcon,
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
      builder: builder,
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
