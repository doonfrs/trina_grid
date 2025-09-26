import 'package:flutter/material.dart';
import 'package:trina_grid/trina_grid.dart';
import 'package:intl/intl.dart' as intl;

import '../../widget/trina_example_button.dart';
import '../../widget/trina_example_screen.dart';

class DateTimeColumnScreen extends StatefulWidget {
  static const routeName = 'feature/date-time-column';

  const DateTimeColumnScreen({super.key});

  @override
  State<DateTimeColumnScreen> createState() => _DateTimeColumnScreenState();
}

class _DateTimeColumnScreenState extends State<DateTimeColumnScreen> {
  final List<TrinaColumn> columns = [];

  final List<TrinaRow> rows = [];

  late final TrinaGridStateManager stateManager;

  @override
  void initState() {
    super.initState();

    var now = DateTime.now();
    now = DateTime(now.year, now.month, now.day, now.hour, now.minute);
    final yesterday = now.subtract(const Duration(days: 1));
    final tomorrow = now.add(const Duration(days: 1));
    final nextWeek = now.add(const Duration(days: 7));

    // Define date formats - use ISO standard format to ensure proper parsing
    const dateTimeFormat = 'yyyy-MM-dd HH:mm';

    columns.addAll([
      TrinaColumn(
        title: 'ID',
        field: 'id',
        type: TrinaColumnType.text(),
        width: 80,
        readOnly: true,
      ),
      TrinaColumn(
        title: 'Default Format',
        field: 'default_format',
        type: TrinaColumnType.dateTime(format: dateTimeFormat),
        width: 180,
      ),
      TrinaColumn(
        title: 'Custom Format',
        field: 'custom_format',
        type: TrinaColumnType.dateTime(
          format: 'MM/dd/yyyy HH:mm',
          headerFormat: 'MMMM yyyy',
        ),
        width: 180,
      ),
      TrinaColumn(
        title: 'With Date Range',
        field: 'with_range',
        type: TrinaColumnType.dateTime(
          startDate: yesterday,
          endDate: nextWeek,
          format: dateTimeFormat,
        ),
        width: 180,
      ),
      TrinaColumn(
        title: 'Custom Icon',
        field: 'custom_icon',
        type: TrinaColumnType.dateTime(
          popupIcon: Icons.calendar_today,
          format: dateTimeFormat,
        ),
        width: 180,
      ),
      TrinaColumn(
        title: '24h Format',
        field: '24h_format',
        type: TrinaColumnType.dateTime(format: dateTimeFormat),
        width: 180,
      ),
      TrinaColumn(
        title: '12h Format',
        field: '12h_format',
        type: TrinaColumnType.dateTime(format: 'yyyy-MM-dd hh:mm'),
        width: 180,
      ),
    ]);

    // Create datetime cells - make sure to use standard ISO format for proper parsing
    final dateTimeFormatter = intl.DateFormat(dateTimeFormat);

    // Add rows with properly formatted date values
    rows.addAll([
      TrinaRow(
        cells: {
          'id': TrinaCell(value: '1'),
          'default_format': TrinaCell(value: dateTimeFormatter.format(now)),
          'custom_format': TrinaCell(value: dateTimeFormatter.format(now)),
          'with_range': TrinaCell(value: dateTimeFormatter.format(now)),
          'custom_icon': TrinaCell(value: dateTimeFormatter.format(now)),
          '24h_format': TrinaCell(value: dateTimeFormatter.format(now)),
          '12h_format': TrinaCell(value: dateTimeFormatter.format(now)),
        },
      ),
      TrinaRow(
        cells: {
          'id': TrinaCell(value: '2'),
          'default_format': TrinaCell(
            value: dateTimeFormatter.format(yesterday),
          ),
          'custom_format': TrinaCell(
            value: dateTimeFormatter.format(yesterday),
          ),
          'with_range': TrinaCell(value: dateTimeFormatter.format(yesterday)),
          'custom_icon': TrinaCell(value: dateTimeFormatter.format(yesterday)),
          '24h_format': TrinaCell(value: dateTimeFormatter.format(yesterday)),
          '12h_format': TrinaCell(value: dateTimeFormatter.format(yesterday)),
        },
      ),
      TrinaRow(
        cells: {
          'id': TrinaCell(value: '3'),
          'default_format': TrinaCell(
            value: dateTimeFormatter.format(tomorrow),
          ),
          'custom_format': TrinaCell(value: dateTimeFormatter.format(tomorrow)),
          'with_range': TrinaCell(value: dateTimeFormatter.format(tomorrow)),
          'custom_icon': TrinaCell(value: dateTimeFormatter.format(tomorrow)),
          '24h_format': TrinaCell(value: dateTimeFormatter.format(tomorrow)),
          '12h_format': TrinaCell(value: dateTimeFormatter.format(tomorrow)),
        },
      ),
      TrinaRow(
        cells: {
          'id': TrinaCell(value: '4'),
          'default_format': TrinaCell(
            value: dateTimeFormatter.format(nextWeek),
          ),
          'custom_format': TrinaCell(value: dateTimeFormatter.format(nextWeek)),
          'with_range': TrinaCell(value: dateTimeFormatter.format(nextWeek)),
          'custom_icon': TrinaCell(value: dateTimeFormatter.format(nextWeek)),
          '24h_format': TrinaCell(value: dateTimeFormatter.format(nextWeek)),
          '12h_format': TrinaCell(value: dateTimeFormatter.format(nextWeek)),
        },
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return TrinaExampleScreen(
      title: 'DateTime Column Type',
      topTitle: 'DateTime Column Type',
      topContents: const [
        Text('A column to enter both date and time values in a single field.'),
        Text(
          'First select a date, then select a time to set the complete datetime value.',
        ),
        Text('Supports various format options and date/time constraints.'),
      ],
      topButtons: [
        TrinaExampleButton(
          url:
              'https://github.com/doonfrs/trina_grid/blob/master/demo/lib/screen/feature/date_time_column_screen.dart',
        ),
      ],
      body: TrinaGrid(
        configuration: TrinaGridConfiguration(
          style: TrinaGridStyleConfig(
            rowHeight: 40,
            cellTextStyle: const TextStyle(fontSize: 12),
          ),
        ),
        columns: columns,
        rows: rows,
        onLoaded: (TrinaGridOnLoadedEvent event) {
          stateManager = event.stateManager;
        },
        onChanged: (TrinaGridOnChangedEvent event) {
          print('Changed: ${event.value} (${event.value.runtimeType})');
        },
      ),
    );
  }
}
