import 'package:flutter/material.dart';
import 'package:trina_grid/trina_grid.dart';

import '../../dummy_data/development.dart';
import '../../widget/trina_example_button.dart';
import '../../widget/trina_example_screen.dart';

class CopyAndPasteScreen extends StatefulWidget {
  static const routeName = 'feature/copy-and-paste';

  const CopyAndPasteScreen({super.key});

  @override
  _CopyAndPasteScreenState createState() => _CopyAndPasteScreenState();
}

class _CopyAndPasteScreenState extends State<CopyAndPasteScreen> {
  final List<TrinaColumn> columns = [];

  final List<TrinaRow> rows = [];

  @override
  void initState() {
    super.initState();

    columns.addAll([
      TrinaColumn(
        title: 'column 1',
        field: 'column_1',
        type: TrinaColumnType.text(),
      ),
      TrinaColumn(
        title: 'column 2',
        field: 'column_2',
        type: TrinaColumnType.text(),
      ),
      TrinaColumn(
        title: 'column 3',
        field: 'column_3',
        type: TrinaColumnType.text(),
      ),
      TrinaColumn(
        title: 'column 4',
        field: 'column_4',
        type: TrinaColumnType.text(),
      ),
      TrinaColumn(
        title: 'column 5',
        field: 'column_5',
        type: TrinaColumnType.text(),
      ),
    ]);

    rows.addAll(DummyData.rowsByColumns(length: 30, columns: columns));
  }

  @override
  Widget build(BuildContext context) {
    return TrinaExampleScreen(
      title: 'Copy and Paste',
      topTitle: 'Copy and Paste',
      topContents: const [
        Text(
          'Copy and paste are operated depending on the cell and row selection status.',
        ),
      ],
      topButtons: [
        TrinaExampleButton(
          url:
              'https://github.com/doonfrs/trina_grid/blob/master/demo/lib/screen/feature/copy_and_paste_screen.dart',
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
