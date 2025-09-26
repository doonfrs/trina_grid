import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:trina_grid/src/ui/cells/trina_currency_cell.dart';
import 'package:trina_grid/trina_grid.dart';

class TrinaColumnTypeCurrency
    with TrinaColumnTypeDefaultMixin, TrinaColumnTypeWithNumberFormat
    implements TrinaColumnType, TrinaColumnTypeHasFormat<String?> {
  @override
  final dynamic defaultValue;

  @override
  final bool negative;

  @override
  final bool applyFormatOnInit;

  @override
  final bool allowFirstDot;

  @override
  final String? format;

  @override
  final String? locale;

  final String? name;

  final String? symbol;

  TrinaColumnTypeCurrency({
    this.defaultValue,
    required this.negative,
    required this.format,
    required this.applyFormatOnInit,
    required this.allowFirstDot,
    required this.locale,
    this.name,
    this.symbol,
    int? decimalDigits,
  }) : numberFormat = intl.NumberFormat.currency(
         locale: locale,
         name: name,
         symbol: symbol,
         decimalDigits: decimalDigits,
         customPattern: format,
       ) {
    decimalPoint = numberFormat.decimalDigits ?? 0;
  }

  @override
  final intl.NumberFormat numberFormat;

  @override
  late final int decimalPoint;

  @override
  Widget buildCell(
    TrinaGridStateManager stateManager,
    TrinaCell cell,
    TrinaColumn column,
    TrinaRow row,
  ) {
    return TrinaCurrencyCell(
      stateManager: stateManager,
      cell: cell,
      column: column,
      row: row,
    );
  }
}
