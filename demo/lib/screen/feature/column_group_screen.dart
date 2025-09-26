import 'package:flutter/material.dart';
import 'package:trina_grid/trina_grid.dart';

import '../../dummy_data/development.dart';
import '../../widget/trina_example_button.dart';
import '../../widget/trina_example_screen.dart';

class ColumnGroupScreen extends StatefulWidget {
  static const routeName = 'feature/column-group';

  const ColumnGroupScreen({super.key});

  @override
  _ColumnGroupScreenState createState() => _ColumnGroupScreenState();
}

class _ColumnGroupScreenState extends State<ColumnGroupScreen> {
  final List<TrinaColumn> columns = [];

  final List<TrinaRow> rows = [];

  final List<TrinaColumnGroup> columnGroups = [];

  late TrinaGridStateManager stateManager;

  @override
  void initState() {
    super.initState();

    columns.addAll([
      TrinaColumn(
        title: 'ExpandedColumn1',
        field: 'column1',
        type: TrinaColumnType.text(),
        titleTextAlign: TrinaColumnTextAlign.center,
        backgroundColor: Colors.red,
      ),
      TrinaColumn(
        title: 'Column2',
        field: 'column2',
        type: TrinaColumnType.text(),
        titleTextAlign: TrinaColumnTextAlign.center,
      ),
      TrinaColumn(
        title: 'Column3',
        field: 'column3',
        type: TrinaColumnType.text(),
        titleTextAlign: TrinaColumnTextAlign.center,
      ),
      TrinaColumn(
        title: 'Column4',
        field: 'column4',
        type: TrinaColumnType.text(),
        titleTextAlign: TrinaColumnTextAlign.center,
      ),
      TrinaColumn(
        title: 'Column5',
        field: 'column5',
        type: TrinaColumnType.text(),
        titleTextAlign: TrinaColumnTextAlign.center,
      ),
      TrinaColumn(
        title: 'Column6',
        field: 'column6',
        type: TrinaColumnType.text(),
        titleTextAlign: TrinaColumnTextAlign.center,
      ),
      TrinaColumn(
        title: 'Column7',
        field: 'column7',
        type: TrinaColumnType.text(),
        titleTextAlign: TrinaColumnTextAlign.center,
      ),
      TrinaColumn(
        title: 'ExpandedColumn8',
        field: 'column8',
        type: TrinaColumnType.text(),
        titleTextAlign: TrinaColumnTextAlign.center,
      ),
    ]);

    rows.addAll(DummyData.rowsByColumns(length: 100, columns: columns));

    columnGroups.addAll([
      TrinaColumnGroup(
        title: 'Expanded',
        fields: ['column1'],
        expandedColumn: true,
      ),
      TrinaColumnGroup(
        title: 'Group A',
        backgroundColor: Colors.teal,
        children: [
          TrinaColumnGroup(
            title: 'A - 1',
            fields: ['column2', 'column3'],
            backgroundColor: Colors.amber,
          ),
          TrinaColumnGroup(
            title: 'A - 2',
            backgroundColor: Colors.greenAccent,
            children: [
              TrinaColumnGroup(title: 'A - 2 - 1', fields: ['column4']),
              TrinaColumnGroup(title: 'A - 2 - 2', fields: ['column5']),
            ],
          ),
        ],
      ),
      TrinaColumnGroup(
        title: 'Group B',
        children: [
          TrinaColumnGroup(
            title: 'B - 1',
            children: [
              TrinaColumnGroup(
                title: 'B - 1 - 1',
                children: [
                  TrinaColumnGroup(title: 'B - 1 - 1 - 1', fields: ['column6']),
                  TrinaColumnGroup(title: 'B - 1 - 1 - 2', fields: ['column7']),
                ],
              ),
              TrinaColumnGroup(
                title: 'Expanded',
                fields: ['column8'],
                expandedColumn: true,
              ),
            ],
          ),
        ],
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return TrinaExampleScreen(
      title: 'Column group',
      topTitle: 'Column group',
      topContents: const [
        Text('You can group columns by any depth you want.'),
        Text(
          'You can also separate grouped columns by dragging and dropping columns.',
        ),
      ],
      topButtons: [
        TrinaExampleButton(
          url:
              'https://github.com/doonfrs/trina_grid/blob/master/demo/lib/screen/feature/column_group_screen.dart',
        ),
      ],
      body: TrinaGrid(
        columns: columns,
        rows: rows,
        columnGroups: columnGroups,
        onChanged: (TrinaGridOnChangedEvent event) {
          print(event);
        },
        onLoaded: (TrinaGridOnLoadedEvent event) {
          stateManager = event.stateManager;
          stateManager.setShowColumnFilter(true);
        },
        configuration: const TrinaGridConfiguration(),
      ),
    );
  }
}
