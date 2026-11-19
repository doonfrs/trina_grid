import 'package:material_ui/material_ui.dart';
import 'package:trina_grid/trina_grid.dart';

import '../../widget/trina_example_button.dart';
import '../../widget/trina_example_screen.dart';

class ColumnSortingScreen extends StatefulWidget {
  static const routeName = 'feature/column-sorting';

  const ColumnSortingScreen({super.key});

  @override
  _ColumnSortingScreenState createState() => _ColumnSortingScreenState();
}

class _ColumnSortingScreenState extends State<ColumnSortingScreen> {
  final List<TrinaColumn> columns = [];

  final List<TrinaRow> rows = [];

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

  @override
  Widget build(BuildContext context) {
    return TrinaExampleScreen(
      title: 'Column sorting',
      topTitle: 'Column sorting',
      topContents: const [
        Text('Ascending or Descending by clicking on the column heading.'),
      ],
      topButtons: [
        TrinaExampleButton(
          url:
              'https://github.com/doonfrs/trina_grid/blob/master/demo/lib/screen/feature/column_sorting_screen.dart',
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
