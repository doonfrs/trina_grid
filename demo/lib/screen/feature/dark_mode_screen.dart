import 'package:flutter/material.dart';
import 'package:trina_grid/trina_grid.dart';

import '../../widget/trina_example_button.dart';
import '../../widget/trina_example_screen.dart';

class DarkModeScreen extends StatefulWidget {
  static const routeName = 'feature/dark-mode';

  const DarkModeScreen({super.key});

  @override
  _DarkModeScreenState createState() => _DarkModeScreenState();
}

class _DarkModeScreenState extends State<DarkModeScreen> {
  final List<TrinaColumn> columns = [];

  final List<TrinaRow> rows = [];

  @override
  void initState() {
    super.initState();

    // Create columns with selection and date/time types for testing popups
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
        width: 150,
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
        title: 'Time',
        field: 'time',
        type: TrinaColumnType.time(),
        width: 100,
      ),
      TrinaColumn(
        title: 'Amount',
        field: 'amount',
        type: TrinaColumnType.currency(),
        width: 120,
      ),
    ]);

    // Create sample rows - enough to trigger pagination
    final statuses = [
      'Active',
      'Inactive',
      'Pending',
      'Completed',
      'Cancelled',
    ];
    final priorities = ['Low', 'Medium', 'High', 'Critical'];
    final projectNames = [
      'Alpha',
      'Beta',
      'Gamma',
      'Delta',
      'Epsilon',
      'Zeta',
      'Eta',
      'Theta',
      'Iota',
      'Kappa',
      'Lambda',
      'Mu',
      'Nu',
      'Xi',
      'Omicron',
      'Pi',
      'Rho',
      'Sigma',
      'Tau',
      'Upsilon',
      'Phi',
      'Chi',
      'Psi',
      'Omega',
    ];

    for (int i = 1; i <= 150; i++) {
      final status = statuses[i % statuses.length];
      final priority = priorities[i % priorities.length];
      final projectName = projectNames[i % projectNames.length];

      rows.add(
        TrinaRow(
          cells: {
            'id': TrinaCell(value: i),
            'name': TrinaCell(value: 'Project $projectName $i'),
            'status': TrinaCell(value: status),
            'priority': TrinaCell(value: priority),
            'date': TrinaCell(
              value: DateTime.now().add(Duration(days: i % 30 - 15)),
            ),
            'time': TrinaCell(
              value:
                  '${(8 + (i % 10)).toString().padLeft(2, '0')}:${(i % 6 * 10).toString().padLeft(2, '0')}',
            ),
            'amount': TrinaCell(value: (5000 + (i * 123.45)) % 50000),
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return TrinaExampleScreen(
      title: 'Dark mode',
      topTitle: 'Dark mode',
      topContents: const [
        Text('Change the entire theme of the grid to Dark.'),
        SizedBox(height: 8),
        Text(
          'Click on Status, Priority, Date, or Time columns to test dark mode popups.',
        ),
        SizedBox(height: 8),
        Text(
          'This demo shows 150 rows with pagination (20 rows per page) to test theme switching with pagination controls.',
        ),
      ],
      topButtons: [
        TrinaExampleButton(
          url:
              'https://github.com/doonfrs/trina_grid/blob/master/demo/lib/screen/feature/dark_mode_screen.dart',
        ),
      ],
      body: Theme(
        data: ThemeData.dark(),
        child: TrinaGrid(
          columns: columns,
          rows: rows,
          onChanged: (TrinaGridOnChangedEvent event) {
            print(event);
          },
          configuration: const TrinaGridConfiguration.dark(),
          createFooter: (stateManager) {
            stateManager.setPageSize(20);
            return TrinaPagination(stateManager);
          },
        ),
      ),
    );
  }
}
