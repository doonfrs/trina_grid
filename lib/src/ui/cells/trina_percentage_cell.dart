import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:trina_grid/trina_grid.dart';

import 'decimal_input_formatter.dart';
import 'text_cell.dart';

class TrinaPercentageCell extends StatefulWidget implements TextCell {
  @override
  final TrinaGridStateManager stateManager;

  @override
  final TrinaCell cell;

  @override
  final TrinaColumn column;

  @override
  final TrinaRow row;

  const TrinaPercentageCell({
    required this.stateManager,
    required this.cell,
    required this.column,
    required this.row,
    super.key,
  });

  @override
  TrinaPercentageCellState createState() => TrinaPercentageCellState();
}

class TrinaPercentageCellState extends State<TrinaPercentageCell>
    with TextCellState<TrinaPercentageCell> {
  late final int decimalRange;

  late final bool activatedNegative;

  late final bool allowFirstDot;

  late final String decimalSeparator;

  late final bool decimalInput;

  @override
  late final TextInputType keyboardType;

  @override
  late final List<TextInputFormatter>? inputFormatters;

  @override
  void initState() {
    super.initState();

    final percentageColumn = widget.column.type as TrinaColumnTypePercentage;

    decimalRange = percentageColumn.decimalPoint;

    activatedNegative = percentageColumn.negative;

    allowFirstDot = percentageColumn.allowFirstDot;

    decimalSeparator = percentageColumn.numberFormat.symbols.DECIMAL_SEP;

    decimalInput = percentageColumn.decimalInput;

    inputFormatters = [
      DecimalTextInputFormatter(
        decimalRange: decimalRange > 0 ? decimalRange : 2,
        activatedNegativeValues: activatedNegative,
        allowFirstDot: true,
        decimalSeparator: decimalSeparator,
      ),
    ];

    keyboardType = TextInputType.numberWithOptions(
      decimal: true,
      signed: activatedNegative,
    );
  }
}
