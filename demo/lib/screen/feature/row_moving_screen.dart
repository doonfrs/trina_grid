import 'package:flutter/material.dart';
import 'package:trina_grid/trina_grid.dart';

import '../../dummy_data/development.dart';
import '../../widget/trina_example_button.dart';
import '../../widget/trina_example_screen.dart';

class RowMovingScreen extends StatefulWidget {
  static const routeName = 'feature/row-moving';

  const RowMovingScreen({super.key});

  @override
  _RowMovingScreenState createState() => _RowMovingScreenState();
}

class _RowMovingScreenState extends State<RowMovingScreen> {
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

  @override
  Widget build(BuildContext context) {
    return TrinaExampleScreen(
      title: 'Row moving',
      topTitle: 'Row moving',
      topContents: const [
        Text('You can move the row by dragging it.'),
        Text(
            'If enableRowDrag of the column property is set to true, an icon that can be dragged to the left of the cell value is created.'),
        Text('You can drag the icon to move the row up and down.'),
        Text('In Selecting Row mode, you can move all the selected rows.'),
        Text(
            'You can receive the moved rows passed to the onRowsMoved callback.'),
      ],
      topButtons: [
        TrinaExampleButton(
          url:
              'https://github.com/doonfrs/trina_grid/blob/master/demo/lib/screen/feature/row_moving_screen.dart',
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
        onRowsMoved: (TrinaGridOnRowsMovedEvent event) {
          // Moved index.
          // In the state of pagination, filtering, and sorting,
          // this is the index of the currently displayed row range.
          print(event.idx);

          // Shift (Control) + Click or Shift + Move keys
          // allows you to select multiple rows and move them at the same time.
          print(event.rows.first.cells['column1']!.value);
        },
      ),
    );
  }
}
