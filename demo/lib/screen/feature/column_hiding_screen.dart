import 'package:flutter/material.dart';
import 'package:trina_grid/trina_grid.dart';

import '../../widget/trina_example_button.dart';
import '../../widget/trina_example_screen.dart';

class ColumnHidingScreen extends StatefulWidget {
  static const routeName = 'feature/column-hiding';

  const ColumnHidingScreen({super.key});

  @override
  _ColumnHidingScreenState createState() => _ColumnHidingScreenState();
}

class _ColumnHidingScreenState extends State<ColumnHidingScreen> {
  final List<TrinaColumn> columns = [];

  final List<TrinaRow> rows = [];

  late TrinaGridStateManager stateManager;

  @override
  void initState() {
    super.initState();

    columns.addAll([
      TrinaColumn(
        title: 'Column A',
        field: 'column_a',
        type: TrinaColumnType.text(),
      ),
      TrinaColumn(
        title: 'Column B',
        field: 'column_b',
        type: TrinaColumnType.text(),
      ),
      TrinaColumn(
        title: 'Column C',
        field: 'column_c',
        type: TrinaColumnType.text(),
      ),
    ]);

    rows.addAll([
      TrinaRow(
        cells: {
          'column_a': TrinaCell(value: 'a1'),
          'column_b': TrinaCell(value: 'b1'),
          'column_c': TrinaCell(value: 'c1'),
        },
      ),
      TrinaRow(
        cells: {
          'column_a': TrinaCell(value: 'a2'),
          'column_b': TrinaCell(value: 'b2'),
          'column_c': TrinaCell(value: 'c2'),
        },
      ),
      TrinaRow(
        cells: {
          'column_a': TrinaCell(value: 'a3'),
          'column_b': TrinaCell(value: 'b3'),
          'column_c': TrinaCell(value: 'c3'),
        },
      ),
    ]);
  }

  void handleToggleColumnA() {
    TrinaColumn firstColumn = stateManager.refColumns.originalList.first;

    stateManager.hideColumn(firstColumn, !firstColumn.hide);
  }

  void handleShowPopup(BuildContext context) {
    stateManager.showSetColumnsPopup(context);
  }

  @override
  Widget build(BuildContext context) {
    return TrinaExampleScreen(
      title: 'Column hiding',
      topTitle: 'Column hiding',
      topContents: const [
        Text('You can hide or un-hide the column.'),
        Text(
          'Hide or un-hide columns with the Hide column and Set Columns items in the menu on the right of the column title.',
        ),
        Text(
          'You can directly change the hidden state of a column with hideColumn of stateManager or call a popup with showSetColumnsPopup.',
        ),
      ],
      topButtons: [
        TrinaExampleButton(
          url:
              'https://github.com/doonfrs/trina_grid/blob/master/demo/lib/screen/feature/column_hiding_screen.dart',
        ),
      ],
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Wrap(
              spacing: 10,
              children: [
                ElevatedButton(
                  onPressed: handleToggleColumnA,
                  child: const Text('Toggle hide Column A'),
                ),
                ElevatedButton(
                  child: const Text('Show Popup'),
                  onPressed: () {
                    handleShowPopup(context);
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: TrinaGrid(
              columns: columns,
              rows: rows,
              onLoaded: (TrinaGridOnLoadedEvent event) {
                stateManager = event.stateManager;
              },
            ),
          ),
        ],
      ),
    );
  }
}
