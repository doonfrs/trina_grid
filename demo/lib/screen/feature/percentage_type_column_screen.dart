import 'package:flutter/material.dart';
import 'package:trina_grid/trina_grid.dart';

import '../../widget/trina_example_button.dart';
import '../../widget/trina_example_screen.dart';

class PercentageTypeColumnScreen extends StatefulWidget {
  static const routeName = 'feature/percentage-type-column';

  const PercentageTypeColumnScreen({super.key});

  @override
  _PercentageTypeColumnScreenState createState() =>
      _PercentageTypeColumnScreenState();
}

class _PercentageTypeColumnScreenState
    extends State<PercentageTypeColumnScreen> {
  final List<TrinaColumn> columns = [];

  final List<TrinaRow> rows = [];

  @override
  void initState() {
    super.initState();

    columns.addAll([
      TrinaColumn(
        title: 'Standard',
        field: 'standard',
        readOnly: false,
        type: TrinaColumnType.percentage(),
      ),
      TrinaColumn(
        title: '1 decimal place',
        field: 'one_decimal',
        type: TrinaColumnType.percentage(
          decimalDigits: 1,
        ),
      ),
      TrinaColumn(
        title: 'No decimals',
        field: 'no_decimal',
        type: TrinaColumnType.percentage(
          decimalDigits: 0,
        ),
      ),
      TrinaColumn(
        title: 'Symbol before',
        field: 'symbol_before',
        type: TrinaColumnType.percentage(
          symbolPosition: PercentageSymbolPosition.before,
        ),
      ),
      TrinaColumn(
        title: 'No symbol',
        field: 'no_symbol',
        type: TrinaColumnType.percentage(
          showSymbol: false,
        ),
      ),
      TrinaColumn(
        title: 'Negative values',
        field: 'negative',
        type: TrinaColumnType.percentage(
          negative: true,
        ),
      ),
      TrinaColumn(
        title: 'Denmark locale',
        field: 'denmark_locale',
        type: TrinaColumnType.percentage(
          locale: 'da_DK',
        ),
      ),
      TrinaColumn(
        title: 'Decimal Input',
        field: 'decimal_input',
        type: TrinaColumnType.percentage(
          decimalInput: true,
          decimalDigits: 1,
        ),
      ),
    ]);

    rows.addAll([
      TrinaRow(
        cells: {
          'standard': TrinaCell(value: 0.42),
          'one_decimal': TrinaCell(value: 0.426),
          'no_decimal': TrinaCell(value: 0.75),
          'symbol_before': TrinaCell(value: 0.38),
          'no_symbol': TrinaCell(value: 0.95),
          'negative': TrinaCell(value: -0.12),
          'denmark_locale': TrinaCell(value: 0.485),
          'decimal_input': TrinaCell(value: 42),
        },
      ),
      TrinaRow(
        cells: {
          'standard': TrinaCell(value: 0.05),
          'one_decimal': TrinaCell(value: 0.168),
          'no_decimal': TrinaCell(value: 0.5),
          'symbol_before': TrinaCell(value: 0.22),
          'no_symbol': TrinaCell(value: 0.33),
          'negative': TrinaCell(value: -0.32),
          'denmark_locale': TrinaCell(value: 0.749),
          'decimal_input': TrinaCell(value: 5),
        },
      ),
      TrinaRow(
        cells: {
          'standard': TrinaCell(value: 1.0),
          'one_decimal': TrinaCell(value: 0.995),
          'no_decimal': TrinaCell(value: 0.25),
          'symbol_before': TrinaCell(value: 0.85),
          'no_symbol': TrinaCell(value: 0.64),
          'negative': TrinaCell(value: -0.05),
          'denmark_locale': TrinaCell(value: 0.332),
          'decimal_input': TrinaCell(value: 100),
        },
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return TrinaExampleScreen(
      title: 'Percentage type column',
      topTitle: 'Percentage type column',
      topContents: const [
        Text('A column to display and edit percentage values.'),
        Text('You can customize decimal places, symbol position, and more.'),
        Text(
            'With decimalInput=true, the column internally stores values as decimals (0.42)'),
        Text(
            'but allows users to input and view values as whole percentages (42%).'),
      ],
      topButtons: [
        TrinaExampleButton(
          url:
              'https://github.com/doonfrs/trina_grid/blob/master/demo/lib/screen/feature/percentage_type_column_screen.dart',
        ),
      ],
      body: TrinaGrid(
        columns: columns,
        rows: rows,
        onLoaded: (event) {
          event.stateManager
              .setSelectingMode(TrinaGridSelectingMode.cellWithCtrl);
          event.stateManager.setEditing(true);
          event.stateManager.setAutoEditing(true);
        },
        onChanged: (TrinaGridOnChangedEvent event) {
          print(event);
        },
        configuration: const TrinaGridConfiguration(
          style: TrinaGridStyleConfig(
            gridBackgroundColor: Colors.white,
            rowColor: Colors.white,
          ),
        ),
      ),
    );
  }
}
