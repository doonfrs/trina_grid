import 'package:flutter/material.dart';
import 'package:trina_grid/trina_grid.dart';

import '../../widget/trina_example_button.dart';
import '../../widget/trina_example_screen.dart';

class TextTypeColumnScreen extends StatefulWidget {
  static const routeName = 'feature/text-type-column';

  const TextTypeColumnScreen({super.key});

  @override
  _TextTypeColumnScreenState createState() => _TextTypeColumnScreenState();
}

class _TextTypeColumnScreenState extends State<TextTypeColumnScreen> {
  final List<TrinaColumn> columns = [];

  final List<TrinaRow> rows = [];

  @override
  void initState() {
    super.initState();

    columns.addAll([
      TrinaColumn(
        title: 'Editable',
        field: 'editable',
        type: TrinaColumnType.text(),
      ),
      TrinaColumn(
        title: 'Readonly',
        field: 'readonly',
        readOnly: true,
        type: TrinaColumnType.text(),
      ),
    ]);

    rows.addAll([
      TrinaRow(
        cells: {
          'editable': TrinaCell(value: 'a1'),
          'readonly': TrinaCell(value: 'b1'),
        },
      ),
      TrinaRow(
        cells: {
          'editable': TrinaCell(value: 'a1'),
          'readonly': TrinaCell(value: 'b1'),
        },
      ),
      TrinaRow(
        cells: {
          'editable': TrinaCell(value: 'a1'),
          'readonly': TrinaCell(value: 'b1'),
        },
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return TrinaExampleScreen(
      title: 'Text type column',
      topTitle: 'Text type column',
      topContents: const [Text('A column to enter a character value.')],
      topButtons: [
        TrinaExampleButton(
          url:
              'https://github.com/doonfrs/trina_grid/blob/master/demo/lib/screen/feature/text_type_column_screen.dart',
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
