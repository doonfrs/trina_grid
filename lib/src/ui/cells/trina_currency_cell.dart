import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:trina_grid/trina_grid.dart';

import 'decimal_input_formatter.dart';
import 'text_cell.dart';

class TrinaCurrencyCell extends StatefulWidget implements TextCell {
  @override
  final TrinaGridStateManager stateManager;

  @override
  final TrinaCell cell;

  @override
  final TrinaColumn column;

  @override
  final TrinaRow row;

  const TrinaCurrencyCell({
    required this.stateManager,
    required this.cell,
    required this.column,
    required this.row,
    super.key,
  });

  @override
  TrinaCurrencyCellState createState() => TrinaCurrencyCellState();
}

class TrinaCurrencyCellState extends State<TrinaCurrencyCell>
    with TextCellState<TrinaCurrencyCell> {
  late final int decimalRange;

  late final bool activatedNegative;

  late final bool allowFirstDot;

  late final String decimalSeparator;

  @override
  late final TextInputType keyboardType;

  @override
  late final List<TextInputFormatter>? inputFormatters;

  @override
  void initState() {
    super.initState();

    final currencyColumn = widget.column.type.currency;

    decimalRange = currencyColumn.decimalPoint;

    activatedNegative = currencyColumn.negative;

    allowFirstDot = currencyColumn.allowFirstDot;

    decimalSeparator = currencyColumn.numberFormat.symbols.DECIMAL_SEP;

    inputFormatters = [
      DecimalTextInputFormatter(
        decimalRange: decimalRange,
        activatedNegativeValues: activatedNegative,
        allowFirstDot: allowFirstDot,
        decimalSeparator: decimalSeparator,
      ),
    ];

    keyboardType = TextInputType.numberWithOptions(
      decimal: decimalRange > 0,
      signed: activatedNegative,
    );
  }
}
