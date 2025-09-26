import 'package:flutter/material.dart';
import 'package:trina_grid/trina_grid.dart';

import '../../widget/trina_example_button.dart';
import '../../widget/trina_example_screen.dart';

class NumberTypeColumnScreen extends StatefulWidget {
  static const routeName = 'feature/number-type-column';

  const NumberTypeColumnScreen({super.key});

  @override
  _NumberTypeColumnScreenState createState() => _NumberTypeColumnScreenState();
}

class _NumberTypeColumnScreenState extends State<NumberTypeColumnScreen> {
  final List<TrinaColumn> columns = [];

  final List<TrinaRow> rows = [];

  @override
  void initState() {
    super.initState();

    columns.addAll([
      TrinaColumn(
        title: 'Negative true',
        field: 'negative_true',
        type: TrinaColumnType.number(),
      ),
      TrinaColumn(
        title: 'Negative false',
        field: 'negative_false',
        type: TrinaColumnType.number(negative: false),
      ),
      TrinaColumn(
        title: '2 decimal places',
        field: 'two_decimal',
        type: TrinaColumnType.number(format: '#,###.##'),
      ),
      TrinaColumn(
        title: '3 decimal places',
        field: 'three_decimal',
        type: TrinaColumnType.number(format: '#,###.###'),
      ),
      TrinaColumn(
        title: '3 decimal places with denmark locale',
        field: 'three_decimal_with_denmark_locale',
        type: TrinaColumnType.number(format: '#,###.###', locale: 'da_DK'),
      ),
    ]);

    rows.addAll([
      TrinaRow(
        cells: {
          'negative_true': TrinaCell(value: -12345),
          'negative_false': TrinaCell(value: 12345),
          'two_decimal': TrinaCell(value: 12345.12),
          'three_decimal': TrinaCell(value: 12345.123),
          'three_decimal_with_denmark_locale': TrinaCell(value: 12345678.123),
        },
      ),
      TrinaRow(
        cells: {
          'negative_true': TrinaCell(value: -12345),
          'negative_false': TrinaCell(value: 12345),
          'two_decimal': TrinaCell(value: 12345.12),
          'three_decimal': TrinaCell(value: 12345.123),
          'three_decimal_with_denmark_locale': TrinaCell(value: 12345678.123),
        },
      ),
      TrinaRow(
        cells: {
          'negative_true': TrinaCell(value: -12345),
          'negative_false': TrinaCell(value: 12345),
          'two_decimal': TrinaCell(value: 12345.12),
          'three_decimal': TrinaCell(value: 12345.123),
          'three_decimal_with_denmark_locale': TrinaCell(value: 12345678.123),
        },
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return TrinaExampleScreen(
      title: 'Number type column',
      topTitle: 'Number type column',
      topContents: const [Text('A column to enter a number value.')],
      topButtons: [
        TrinaExampleButton(
          url:
              'https://github.com/doonfrs/trina_grid/blob/master/demo/lib/screen/feature/number_type_column_screen.dart',
        ),
      ],
      body: TrinaGrid(
        columns: columns,
        rows: rows,
        onChanged: (TrinaGridOnChangedEvent event) {
          print(event);
        },
      ),
    );
  }
}
