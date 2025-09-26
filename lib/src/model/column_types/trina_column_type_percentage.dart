import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:trina_grid/src/ui/cells/trina_percentage_cell.dart';
import 'package:trina_grid/trina_grid.dart';

class TrinaColumnTypePercentage
    with TrinaColumnTypeDefaultMixin, TrinaColumnTypeWithNumberFormat
    implements TrinaColumnType, TrinaColumnTypeHasFormat<String> {
  @override
  final dynamic defaultValue;

  @override
  final bool negative;

  @override
  final bool applyFormatOnInit;

  @override
  final bool allowFirstDot;

  @override
  final String? locale;

  @override
  final String format;

  final int decimalDigits;

  final bool showSymbol;

  final PercentageSymbolPosition symbolPosition;

  /// If true, the input value is treated as the actual percentage (e.g., 50 for 50%)
  /// If false (default), the input value is treated as a decimal (e.g., 0.5 for 50%)
  final bool decimalInput;

  TrinaColumnTypePercentage({
    this.defaultValue = 0,
    this.negative = true,
    this.decimalDigits = 2,
    this.showSymbol = true,
    this.symbolPosition = PercentageSymbolPosition.after,
    this.applyFormatOnInit = true,
    this.allowFirstDot = false,
    this.locale,
    this.decimalInput = false,
  }) : format = decimalDigits > 0 ? '#,##0.${'0' * decimalDigits}' : '#,##0',
       // Create a NumberFormat WITHOUT the % symbol to avoid automatic multiplication
       numberFormat = decimalDigits > 0
           ? intl.NumberFormat('#,##0.${'0' * decimalDigits}', locale)
           : intl.NumberFormat('#,##0', locale),
       decimalPoint = decimalDigits;

  @override
  final intl.NumberFormat numberFormat;

  @override
  final int decimalPoint;

  @override
  String applyFormat(dynamic value) {
    // If it's already a properly formatted percentage string, return it as is
    if (value is String &&
        ((value.endsWith('%') &&
                symbolPosition == PercentageSymbolPosition.after) ||
            (value.startsWith('%') &&
                symbolPosition == PercentageSymbolPosition.before))) {
      return value;
    }

    // Parse the input value to a number
    num? parsedValue = value is num
        ? value
        : num.tryParse(
            value.toString().replaceAll(numberFormat.symbols.DECIMAL_SEP, '.'),
          );

    if (parsedValue == null) {
      return '';
    }

    // Apply negative check
    if (negative == false && parsedValue < 0) {
      parsedValue = 0;
    }

    // When decimalInput is true, we assume the input is already in percentage form (e.g., 42 for 42%)
    // so we don't multiply by 100
    // When decimalInput is false, we assume the input is in decimal form (e.g., 0.42 for 42%)
    // so we do multiply by 100
    String formatted;
    if (decimalInput) {
      formatted = numberFormat.format(parsedValue);
    } else {
      formatted = numberFormat.format(parsedValue * 100);
    }

    // Add the percentage symbol based on position if showSymbol is true
    if (showSymbol) {
      if (symbolPosition == PercentageSymbolPosition.before) {
        return '%$formatted';
      } else {
        return '$formatted%';
      }
    }

    return formatted;
  }

  @override
  dynamic toNumber(String formatted) {
    // Remove the percentage symbol and other non-numeric characters
    String match = '0-9\\-${numberFormat.symbols.DECIMAL_SEP}';
    if (negative) {
      match += numberFormat.symbols.MINUS_SIGN;
    }

    formatted = formatted
        .replaceAll(RegExp('[^$match]'), '')
        .replaceFirst(numberFormat.symbols.DECIMAL_SEP, '.');

    final num formattedNumber = num.tryParse(formatted) ?? 0;

    // Convert to appropriate storage format:
    // - If decimalInput is true, we don't divide by 100 since the value is already in percentage form
    // - If decimalInput is false, we divide by 100 to convert from percentage to decimal
    if (decimalInput) {
      return formattedNumber;
    } else {
      return formattedNumber / 100;
    }
  }

  @override
  Widget buildCell(
    TrinaGridStateManager stateManager,
    TrinaCell cell,
    TrinaColumn column,
    TrinaRow row,
  ) {
    return TrinaPercentageCell(
      stateManager: stateManager,
      cell: cell,
      column: column,
      row: row,
    );
  }
}

/// Defines the position of the percentage symbol.
enum PercentageSymbolPosition {
  /// Symbol appears before the number (e.g. %50.00)
  before,

  /// Symbol appears after the number (e.g. 50.00%)
  after,
}
