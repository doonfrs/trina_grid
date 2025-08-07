import 'package:flutter/material.dart';
import 'package:trina_grid/trina_grid.dart';

import '../../widget/trina_example_button.dart';
import '../../widget/trina_example_screen.dart';

class TimeTypeColumnScreen extends StatefulWidget {
  static const routeName = 'feature/time-type-column';

  const TimeTypeColumnScreen({super.key});

  @override
  _TimeTypeColumnScreenState createState() => _TimeTypeColumnScreenState();
}

class _TimeTypeColumnScreenState extends State<TimeTypeColumnScreen> {
  final List<TrinaColumn> columns = [];

  final List<TrinaRow> rows = [];

  @override
  void initState() {
    super.initState();

    columns.addAll([
      TrinaColumn(
        title: 'Time (No constraints)',
        field: 'time_any',
        type: TrinaColumnType.time(),
      ),
      TrinaColumn(
        title: 'Time (Min: 5:00 PM)',
        field: 'min_time_at_5pm',
        type: TrinaColumnType.time(
          minTime: TimeOfDay(hour: 17, minute: 0),
        ),
      ),
      TrinaColumn(
        title: 'Time (Max: 9:00 AM)',
        field: 'max_time_at_9am',
        type: TrinaColumnType.time(
          maxTime: const TimeOfDay(hour: 9, minute: 0),
        ),
      ),
      TrinaColumn(
        title: 'Time (Min: 9:00 AM, Max: 5:00 PM)',
        field: 'min_9am_max_5pm',
        type: TrinaColumnType.time(
          minTime: const TimeOfDay(hour: 9, minute: 0),
          maxTime: const TimeOfDay(hour: 17, minute: 0),
        ),
      ),
    ]);

    rows.addAll([
      TrinaRow(
        cells: {
          'time_any': TrinaCell(value: '00:00'),
          'min_time_at_5pm': TrinaCell(value: '17:20'),
          'max_time_at_9am': TrinaCell(value: '09:00'),
          'min_9am_max_5pm': TrinaCell(value: '10:00'),
        },
      ),
      TrinaRow(
        cells: {
          'time_any': TrinaCell(value: '23:59'),
          'min_time_at_5pm': TrinaCell(value: '17:30'),
          'max_time_at_9am': TrinaCell(value: '08:30'),
          'min_9am_max_5pm': TrinaCell(value: '14:00'),
        },
      ),
      TrinaRow(
        cells: {
          'time_any': TrinaCell(value: '12:30'),
          'min_time_at_5pm': TrinaCell(value: '17:00'),
          'max_time_at_9am': TrinaCell(value: '06:30'),
          'min_9am_max_5pm': TrinaCell(value: '09:00'),
        },
      ),
      TrinaRow(
        cells: {
          'time_any': TrinaCell(value: '08:00'),
          'min_time_at_5pm': TrinaCell(value: '17:00'),
          'max_time_at_9am': TrinaCell(value: '04:00'),
          'min_9am_max_5pm': TrinaCell(value: '17:00'),
        },
      ),
      TrinaRow(
        cells: {
          'time_any': TrinaCell(value: '18:00'),
          'min_time_at_5pm': TrinaCell(value: '18:00'),
          'max_time_at_9am': TrinaCell(value: '06:00'),
          'min_9am_max_5pm': TrinaCell(value: '12:00'),
        },
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return TrinaExampleScreen(
      title: 'Time type column',
      topTitle: 'Time type column',
      topContents: const [
        Text('A column to enter a time value.'),
        Text('Move the hour and minute with the left and right arrow keys.'),
      ],
      topButtons: [
        TrinaExampleButton(
          url:
              'https://github.com/doonfrs/trina_grid/blob/master/demo/lib/screen/feature/time_type_column_screen.dart',
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
