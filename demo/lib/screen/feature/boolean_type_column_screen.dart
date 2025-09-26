import 'package:flutter/material.dart';
import 'package:trina_grid/trina_grid.dart';

import '../../widget/trina_example_button.dart';
import '../../widget/trina_example_screen.dart';

class BooleanTypeColumnScreen extends StatefulWidget {
  static const routeName = 'feature/boolean-type-column';

  const BooleanTypeColumnScreen({super.key});

  @override
  _BooleanTypeColumnScreenState createState() =>
      _BooleanTypeColumnScreenState();
}

class _BooleanTypeColumnScreenState extends State<BooleanTypeColumnScreen> {
  final List<TrinaColumn> columns = [];
  final List<TrinaRow> rows = [];
  late TrinaGridStateManager stateManager;

  @override
  void initState() {
    super.initState();

    // Create columns
    columns.addAll([
      TrinaColumn(
        title: 'ID',
        field: 'id',
        type: TrinaColumnType.text(),
        width: 100,
        readOnly: true,
      ),
      TrinaColumn(
        title: 'Name',
        field: 'name',
        type: TrinaColumnType.text(),
        width: 150,
      ),
      TrinaColumn(
        title: 'Age',
        field: 'age',
        type: TrinaColumnType.number(),
        width: 80,
      ),
      TrinaColumn(
        title: 'Job',
        field: 'job',
        type: TrinaColumnType.select(['test', 'test2']),
        width: 200,
      ),
      TrinaColumn(
        title: 'Active',
        field: 'active',
        type: TrinaColumnType.boolean(),
      ),
      TrinaColumn(
        title: 'Active Allow Empty',
        field: 'active_allow_empty',
        type: TrinaColumnType.boolean(allowEmpty: true),
      ),
      TrinaColumn(
        title: 'Salary',
        field: 'salary',
        type: TrinaColumnType.currency(format: '#,###.##'),
        width: 150,
      ),
      TrinaColumn(
        title: 'Join Date',
        field: 'joinDate',
        type: TrinaColumnType.date(),
        width: 150,
      ),
    ]);

    // Create rows
    for (int i = 1; i <= 20; i++) {
      rows.add(
        TrinaRow(
          cells: {
            'id': TrinaCell(value: 'EMP-$i'),
            'name': TrinaCell(value: 'Employee $i'),
            'age': TrinaCell(value: 25 + (i % 20)),
            'job': TrinaCell(
              value: i % 3 == 0
                  ? 'Developer'
                  : (i % 3 == 1 ? 'Designer' : 'Manager'),
            ),
            'active': TrinaCell(value: i % 2 == 0),
            'active_allow_empty': TrinaCell(value: i % 2 == 0),
            'salary': TrinaCell(value: 50000 + (i * 1000)),
            'joinDate': TrinaCell(
              value: DateTime(2020, (i % 12) + 1, (i % 28) + 1),
            ),
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return TrinaExampleScreen(
      title: 'Boolean Type Column',
      topTitle: 'Boolean Type Column',
      topContents: const [
        Text(
          'Boolean type column is a column that displays a boolean value as a checkbox. You can customize the checkbox appearance and behavior.',
        ),
        SizedBox(height: 10),
      ],
      topButtons: [
        TrinaExampleButton(
          url:
              'https://github.com/doonfrs/trina_grid/blob/master/demo/lib/screen/feature/boolean_type_column_screen.dart',
        ),
      ],
      body: Column(
        children: [
          _headerButtons,
          Expanded(
            child: TrinaGrid(
              columns: columns,
              rows: rows,
              onLoaded: (TrinaGridOnLoadedEvent event) {
                stateManager = event.stateManager;
                stateManager.setShowColumnFilter(true);
              },
              configuration: TrinaGridConfiguration(
                style: TrinaGridStyleConfig(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget get _headerButtons {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          ElevatedButton(
            onPressed: () {
              print(stateManager.rows.first.cells['active']?.value);
            },
            child: const Text('Check Field Value'),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: () {
              stateManager.changeCellValue(
                stateManager.rows.first.cells['active']!,
                !stateManager.rows.first.cells['active']?.value,
              );
            },
            child: const Text('Change Boolean Value'),
          ),
        ],
      ),
    );
  }
}
