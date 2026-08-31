import 'package:flutter/material.dart';
import 'package:trina_grid/trina_grid.dart';
import '../../widget/trina_example_button.dart';
import '../../widget/trina_example_screen.dart';

/// Demonstrates the automatic filter widget modes resolved from the column
/// type: a text filter for text columns, an ALL / True / False dropdown for
/// boolean columns and a checkbox multi-select dropdown for select columns.
class ColumnFilterModesScreen extends StatefulWidget {
  static const routeName = '/column-filter-modes';

  const ColumnFilterModesScreen({super.key});

  @override
  State<ColumnFilterModesScreen> createState() =>
      _ColumnFilterModesScreenState();
}

class _ColumnFilterModesScreenState extends State<ColumnFilterModesScreen> {
  static const hobbies = ['swimming', 'gym', 'reading', 'cycling', 'gaming'];

  late List<TrinaColumn> columns;
  late List<TrinaRow> rows;

  @override
  void initState() {
    super.initState();

    columns = [
      // Text column: keeps the regular text filter.
      TrinaColumn(title: 'Name', field: 'name', type: TrinaColumnType.text()),
      // Boolean column: renders the ALL / True / False dropdown filter.
      TrinaColumn(
        title: 'Is Active',
        field: 'is_active',
        width: 130,
        type: TrinaColumnType.boolean(),
      ),
      // Select column: renders the checkbox multi-select filter with the
      // column items.
      TrinaColumn(
        title: 'Hobby',
        field: 'hobby',
        type: TrinaColumnType.select(hobbies),
      ),
      // Opt out of the automatic resolution and keep the text filter:
      //
      // TrinaColumn(
      //   ...,
      //   filterWidgetDelegate:
      //       const TrinaFilterColumnWidgetDelegate.textField(),
      // ),
    ];

    rows = List<TrinaRow>.generate(30, (index) {
      return TrinaRow(
        cells: {
          'name': TrinaCell(value: 'User $index'),
          'is_active': TrinaCell(value: index.isEven),
          'hobby': TrinaCell(value: hobbies[index % hobbies.length]),
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return TrinaExampleScreen(
      title: 'Column Filter Modes',
      topTitle: 'Column Filter Modes',
      topContents: const [
        Text(
          'The filter row widget is resolved automatically from the column type:',
        ),
        SizedBox(height: 10),
        Text(
          '• Text columns render the regular text filter.\n'
          '• Boolean columns render an ALL / True / False dropdown.\n'
          '• Select columns render a checkbox multi-select dropdown '
          '(live filtering, with a Select all toggle).',
        ),
        SizedBox(height: 10),
        Text(
          'Use TrinaFilterColumnWidgetDelegate.textField to opt out, or '
          'booleanSelect / multiSelect to force a mode on any column. '
          'Select columns can also opt out with enableColumnFilter: false.',
        ),
      ],
      topButtons: [
        TrinaExampleButton(
          url:
              'https://github.com/doonfrs/trina_grid/blob/master/demo/lib/screen/feature/column_filter_modes_screen.dart',
        ),
      ],
      body: TrinaGrid(
        columns: columns,
        rows: rows,
        onLoaded: (TrinaGridOnLoadedEvent event) {
          event.stateManager.setShowColumnFilter(true);
        },
      ),
    );
  }
}
