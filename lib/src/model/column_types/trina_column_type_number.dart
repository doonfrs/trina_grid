import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:trina_grid/src/ui/cells/trina_number_cell.dart';
import 'package:trina_grid/trina_grid.dart';

class TrinaColumnTypeNumber
    with TrinaColumnTypeDefaultMixin, TrinaColumnTypeWithNumberFormat
    implements TrinaColumnType, TrinaColumnTypeHasFormat<String> {
  @override
  final dynamic defaultValue;

  @override
  final bool negative;

  @override
  final String format;

  @override
  final bool applyFormatOnInit;

  @override
  final bool allowFirstDot;

  @override
  final String? locale;

  TrinaColumnTypeNumber({
    this.defaultValue,
    required this.negative,
    required this.format,
    required this.applyFormatOnInit,
    required this.allowFirstDot,
    required this.locale,
  }) : numberFormat = intl.NumberFormat(format, locale);

  @override
  final intl.NumberFormat numberFormat;

  @override
  int get decimalPoint => numberFormat.maximumFractionDigits;

  @override
  Widget buildCell(
    TrinaGridStateManager stateManager,
    TrinaCell cell,
    TrinaColumn column,
    TrinaRow row,
  ) {
    return TrinaNumberCell(
      stateManager: stateManager,
      cell: cell,
      column: column,
      row: row,
    );
  }
}
