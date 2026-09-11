import 'package:flutter/material.dart';
import 'package:trina_grid/trina_grid.dart';
import '../../widget/trina_example_button.dart';
import '../../widget/trina_example_screen.dart';

/// Demonstrates the opt-in dropdown filter widgets: the default text filter
/// on the name column, an ALL / Yes / No dropdown on the boolean column
/// through [TrinaFilterColumnWidgetDelegate.booleanSelect] and a checkbox
/// multi-select dropdown on the select column through
/// [TrinaFilterColumnWidgetDelegate.multiSelect].
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
      // Text column: the default text filter.
      TrinaColumn(title: 'Name', field: 'name', type: TrinaColumnType.text()),
      // Boolean column: opt in to the ALL / Yes / No dropdown filter. The
      // options are labeled with the column's trueText / falseText.
      TrinaColumn(
        title: 'Is Active',
        field: 'is_active',
        width: 130,
        type: TrinaColumnType.boolean(),
        filterWidgetDelegate:
            const TrinaFilterColumnWidgetDelegate.booleanSelect(),
      ),
      // Select column: opt in to the checkbox multi-select filter. The items
      // are taken from the column type.
      TrinaColumn(
        title: 'Hobby',
        field: 'hobby',
        type: TrinaColumnType.select(hobbies),
        filterWidgetDelegate:
            const TrinaFilterColumnWidgetDelegate.multiSelect(),
      ),
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
          'Columns keep the text filter by default. Opt in to a dropdown '
          'filter per column with TrinaColumn.filterWidgetDelegate:',
        ),
        SizedBox(height: 10),
        Text(
          '• booleanSelect(): ALL / Yes / No dropdown, labeled with the '
          'column\'s trueText / falseText.\n'
          '• multiSelect(): checkbox dropdown with live filtering and a '
          'Select all toggle. The items come from the select column, or from '
          'multiSelectItems on any other column.',
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
