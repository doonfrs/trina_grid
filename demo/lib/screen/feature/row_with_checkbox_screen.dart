import 'package:flutter/material.dart';
import 'package:trina_grid/trina_grid.dart';

import '../../dummy_data/development.dart';
import '../../widget/trina_example_button.dart';
import '../../widget/trina_example_screen.dart';

class RowWithCheckboxScreen extends StatefulWidget {
  static const routeName = 'feature/row-with-checkbox';

  const RowWithCheckboxScreen({super.key});

  @override
  _RowWithCheckboxScreenState createState() => _RowWithCheckboxScreenState();
}

class _RowWithCheckboxScreenState extends State<RowWithCheckboxScreen> {
  final List<TrinaColumn> columns = [];

  final List<TrinaRow> rows = [];

  late TrinaGridStateManager stateManager;

  @override
  void initState() {
    super.initState();

    columns.addAll([
      TrinaColumn(
        title: 'column1',
        field: 'column1',
        type: TrinaColumnType.text(),
        enableRowDrag: true,
        enableRowChecked: true,
      ),
      TrinaColumn(
        title: 'column2',
        field: 'column2',
        type: TrinaColumnType.text(),
      ),
      TrinaColumn(
        title: 'column3',
        field: 'column3',
        type: TrinaColumnType.text(),
      ),
      TrinaColumn(
        title: 'column4',
        field: 'column4',
        type: TrinaColumnType.text(),
      ),
      TrinaColumn(
        title: 'column5',
        field: 'column5',
        type: TrinaColumnType.text(),
      ),
    ]);

    rows.addAll(DummyData.rowsByColumns(length: 15, columns: columns));
  }

  void handleOnRowChecked(TrinaGridOnRowCheckedEvent event) {
    if (event.isRow) {
      // or event.isAll
      print('Toggled A Row.');
      print(event.row?.cells['column1']?.value);
    } else {
      print('Toggled All Rows.');
      print(stateManager.checkedRows.length);
    }
  }

  @override
  Widget build(BuildContext context) {
    return TrinaExampleScreen(
      title: 'Row with checkbox',
      topTitle: 'Row with checkbox',
      topContents: const [
        Text('You can select rows with checkbox.'),
        Text(
            'If you set the enableRowChecked property of a column to true, a checkbox appears in the cell of that column.'),
      ],
      topButtons: [
        TrinaExampleButton(
          url:
              'https://github.com/doonfrs/trina_grid/blob/master/demo/lib/screen/feature/row_with_checkbox_screen.dart',
        ),
      ],
      body: TrinaGrid(
        columns: columns,
        rows: rows,
        onChanged: (TrinaGridOnChangedEvent event) {
          print(event);
        },
        onLoaded: (TrinaGridOnLoadedEvent event) {
          event.stateManager
              .setSelectingMode(TrinaGridSelectingMode.rowWithSingleTap);

          stateManager = event.stateManager;
        },
        onRowChecked: handleOnRowChecked,
        // configuration: TrinaConfiguration.dark(),
      ),
    );
  }
}
