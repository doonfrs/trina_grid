import 'package:flutter/material.dart';
import 'package:trina_grid/trina_grid.dart';

import '../../widget/trina_example_button.dart';
import '../../widget/trina_example_screen.dart';

class ThemeSwitchingScreen extends StatefulWidget {
  static const routeName = 'feature/theme-switching';

  const ThemeSwitchingScreen({super.key});

  @override
  _ThemeSwitchingScreenState createState() => _ThemeSwitchingScreenState();
}

class _ThemeSwitchingScreenState extends State<ThemeSwitchingScreen> {
  final List<TrinaColumn> columns = [];
  final List<TrinaRow> rows = [];
  bool isDarkMode = false;

  @override
  void initState() {
    super.initState();

    // Create columns
    columns.addAll([
      TrinaColumn(
        title: 'ID',
        field: 'id',
        type: TrinaColumnType.number(),
        width: 80,
      ),
      TrinaColumn(
        title: 'Name',
        field: 'name',
        type: TrinaColumnType.text(),
        width: 200,
      ),
      TrinaColumn(
        title: 'Status',
        field: 'status',
        type: TrinaColumnType.select(<String>[
          'Active',
          'Inactive',
          'Pending',
          'Completed',
          'Cancelled',
        ]),
        width: 120,
      ),
      TrinaColumn(
        title: 'Priority',
        field: 'priority',
        type: TrinaColumnType.select(<String>[
          'Low',
          'Medium',
          'High',
          'Critical',
        ]),
        width: 100,
      ),
      TrinaColumn(
        title: 'Date',
        field: 'date',
        type: TrinaColumnType.date(),
        width: 120,
      ),
      TrinaColumn(
        title: 'Amount',
        field: 'amount',
        type: TrinaColumnType.currency(),
        width: 120,
      ),
    ]);

    // Create many rows to trigger pagination
    final statuses = [
      'Active',
      'Inactive',
      'Pending',
      'Completed',
      'Cancelled',
    ];
    final priorities = ['Low', 'Medium', 'High', 'Critical'];
    final departments = [
      'Engineering',
      'Marketing',
      'Sales',
      'Support',
      'Finance',
      'HR',
      'Operations',
      'Legal',
      'Design',
      'Product',
      'Research',
      'Quality',
    ];

    for (int i = 1; i <= 200; i++) {
      final status = statuses[i % statuses.length];
      final priority = priorities[i % priorities.length];
      final department = departments[i % departments.length];

      rows.add(
        TrinaRow(
          cells: {
            'id': TrinaCell(value: i),
            'name': TrinaCell(value: '$department Task #$i'),
            'status': TrinaCell(value: status),
            'priority': TrinaCell(value: priority),
            'date': TrinaCell(
              value: DateTime.now().add(Duration(days: i % 60 - 30)),
            ),
            'amount': TrinaCell(value: (1000 + (i * 87.32)) % 25000),
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return TrinaExampleScreen(
      title: 'Theme Switching Demo',
      topTitle: 'Live Theme Switching with Pagination',
      topContents: [
        const Text('Test live theme switching with pagination controls.'),
        const SizedBox(height: 8),
        const Text(
          'Toggle between light and dark mode to see pagination theme updates in real-time.',
        ),
        const SizedBox(height: 8),
        const Text(
          'This demo shows 200 rows with pagination (25 rows per page).',
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            const Text('Current Theme: '),
            Switch(
              value: isDarkMode,
              onChanged: (value) {
                setState(() {
                  isDarkMode = value;
                });
              },
            ),
            Text(isDarkMode ? 'Dark Mode' : 'Light Mode'),
          ],
        ),
      ],
      topButtons: [
        TrinaExampleButton(
          url:
              'https://github.com/doonfrs/trina_grid/blob/master/demo/lib/screen/feature/theme_switching_screen.dart',
        ),
      ],
      body: AnimatedTheme(
        data: isDarkMode ? ThemeData.dark() : ThemeData.light(),
        duration: const Duration(milliseconds: 300),
        child: TrinaGrid(
          columns: columns,
          rows: rows,
          onChanged: (TrinaGridOnChangedEvent event) {
            print('Grid changed: $event');
          },
          configuration: isDarkMode
              ? const TrinaGridConfiguration.dark()
              : const TrinaGridConfiguration(),
          createFooter: (stateManager) {
            stateManager.setPageSize(25);
            return TrinaPagination(stateManager);
          },
        ),
      ),
    );
  }
}
