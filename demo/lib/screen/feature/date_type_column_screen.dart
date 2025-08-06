import 'package:flutter/material.dart';
import 'package:trina_grid/trina_grid.dart';

import '../../widget/trina_example_button.dart';
import '../../widget/trina_example_screen.dart';

class DateTypeColumnScreen extends StatefulWidget {
  static const routeName = 'feature/date-type-column';

  const DateTypeColumnScreen({super.key});

  @override
  _DateTypeColumnScreenState createState() => _DateTypeColumnScreenState();
}

class _DateTypeColumnScreenState extends State<DateTypeColumnScreen> {
  final List<TrinaColumn> columns = [];

  final List<TrinaRow> rows = [];

  @override
  void initState() {
    super.initState();

    columns.addAll([
      TrinaColumn(
        title: 'yyyy-MM-dd',
        field: 'yyyy_mm_dd',
        type: TrinaColumnType.date(),
      ),
      TrinaColumn(
        title: 'MM/dd/yyyy',
        field: 'mm_dd_yyyy',
        type: TrinaColumnType.date(
          format: 'MM/dd/yyyy',
        ),
      ),
      TrinaColumn(
        title: 'with StartDate',
        field: 'with_start_date',
        type: TrinaColumnType.date(
          startDate: DateTime.parse('2020-01-01'),
        ),
      ),
      TrinaColumn(
        title: 'with EndDate',
        field: 'with_end_date',
        type: TrinaColumnType.date(
          endDate: DateTime.parse('2020-01-01'),
        ),
      ),
      TrinaColumn(
        title: 'with Both',
        field: 'with_both',
        type: TrinaColumnType.date(
          startDate: DateTime.parse('2020-01-01'),
          endDate: DateTime.parse('2020-01-31'),
        ),
      ),
      TrinaColumn(
        title: 'custom',
        field: 'custom',
        type: TrinaColumnType.date(format: 'yyyy年 MM月 dd日'),
      ),
      TrinaColumn(
        title: 'Close popup on selection',
        field: 'close_popup_on_selection',
        type: TrinaColumnType.date(closePopupOnSelection: true),
      ),
    ]);

    rows.addAll([
      TrinaRow(
        cells: {
          'yyyy_mm_dd': TrinaCell(value: '2020-06-30'),
          'mm_dd_yyyy': TrinaCell(value: '2020-06-30'),
          'with_start_date': TrinaCell(value: '2020-01-01'),
          'with_end_date': TrinaCell(value: '2020-01-01'),
          'with_both': TrinaCell(value: '2020-01-01'),
          'custom': TrinaCell(value: '2020-01-01'),
          'close_popup_on_selection': TrinaCell(value: '2020-01-01'),
        },
      ),
      TrinaRow(
        cells: {
          'yyyy_mm_dd': TrinaCell(value: '2020-07-01'),
          'mm_dd_yyyy': TrinaCell(value: '2019-07-01'),
          'with_start_date': TrinaCell(value: '2020-01-01'),
          'with_end_date': TrinaCell(value: '2020-01-01'),
          'with_both': TrinaCell(value: '2020-01-01'),
          'custom': TrinaCell(value: '2020-01-01'),
          'close_popup_on_selection': TrinaCell(value: '2020-01-01'),
        },
      ),
      TrinaRow(
        cells: {
          'yyyy_mm_dd': TrinaCell(value: '2020-07-02'),
          'mm_dd_yyyy': TrinaCell(value: '2020-07-02'),
          'with_start_date': TrinaCell(value: '2020-01-01'),
          'with_end_date': TrinaCell(value: '2020-01-01'),
          'with_both': TrinaCell(value: '2020-01-01'),
          'custom': TrinaCell(value: '2020-01-01'),
          'close_popup_on_selection': TrinaCell(value: '2020-01-01'),
        },
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return TrinaExampleScreen(
      title: 'Date type column',
      topTitle: 'Date type column',
      topContents: const [
        Text('A column to enter a date value.'),
        Text('The arrow keys at the left and right end change the year.'),
        Text('The arrow keys at the upper and lower ends change the month.'),
      ],
      topButtons: [
        TrinaExampleButton(
          url:
              'https://github.com/doonfrs/trina_grid/blob/master/demo/lib/screen/feature/date_type_column_screen.dart',
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
