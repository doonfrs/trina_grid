import 'package:flutter/material.dart';
import 'package:trina_grid/trina_grid.dart';

import '../../widget/trina_example_button.dart';
import '../../widget/trina_example_screen.dart';

/// A screen that demonstrates the various configurations of the
/// [TrinaColumnType.select], which provides a dropdown-style menu for
/// selecting values in a cell.
class SelectionTypeColumnScreen extends StatefulWidget {
  static const routeName = 'feature/selection-type-column';

  const SelectionTypeColumnScreen({super.key});

  @override
  _SelectionTypeColumnScreenState createState() =>
      _SelectionTypeColumnScreenState();
}

class _SelectionTypeColumnScreenState extends State<SelectionTypeColumnScreen> {
  final List<TrinaColumn> columns = [];

  final List<TrinaRow> rows = [];

  @override
  void initState() {
    super.initState();

    columns.addAll([
      // A basic select column with a simple list of items.
      TrinaColumn(
        title: 'Basic',
        field: 'select_a',
        type: TrinaColumnType.select(<String>[
          'One',
          'Two',
          'Three',
        ], enableColumnFilter: true),
      ),
      // A select column that includes a search field in its dropdown menu.
      TrinaColumn(
        title: 'With search',
        field: 'select_b',
        type: TrinaColumnType.selectWithSearch(
          <String>[
            'Mercury',
            'Venus',
            'Earth',
            'Mars',
            'Jupiter',
            'Saturn',
            'Uranus',
            'Neptune',
            'Trina',
            'Pluto',
            'Haumea',
            'Eris',
          ],
          itemToString: (item) => item, // item is already a string
          enableColumnFilter: true,
        ),
      ),
      // A select column with advanced filtering options in the menu.
      TrinaColumn(
        title: 'With filters',
        field: 'select_c',
        type: TrinaColumnType.selectWithFilters(
          <String>['100', '101', '5', '10', '50', '30', '20', '1000'],
          menuFilters: [
            TrinaDropdownMenuFilter.equals,
            TrinaDropdownMenuFilter.greaterThan,
            TrinaDropdownMenuFilter.contains,
            TrinaDropdownMenuFilter.greaterThanOrEqualTo,
          ],
        ),
      ),
      // A select column that uses a custom builder to render each item
      // in the dropdown list.
      TrinaColumn(
        title: 'With custom builder',
        field: 'select_d',
        type: TrinaColumnType.select(
          <String>['Arabic', 'English', 'Chinese', 'French', 'German'],
          menuItemBuilder: (item) => Row(
            children: [
              const Icon(Icons.language, size: 20),
              const SizedBox(width: 4),
              Text(item),
            ],
          ),
        ),
      ),
      // A select column that provides a custom widget to display when
      // filtering yields no results.
      TrinaColumn(
        title: 'With custom empty filter result builder',
        field: 'select_e',
        type: TrinaColumnType.selectWithFilters(
          <String>['America', 'Africa', 'Australia', 'Asia', 'Antarctic'],
          menuFilters: [TrinaDropdownMenuFilter.startsWith],
          menuEmptyFilterResultBuilder: (context) => SizedBox(
            height: 45,
            child: Row(
              children: [
                const Icon(Icons.filter_list_rounded, size: 20),
                const SizedBox(width: 4),
                Flexible(child: Text('No countries match the filter')),
              ],
            ),
          ),
          enableColumnFilter: true,
        ),
      ),
      // A select column that provides a custom widget for the cell when it
      // enters edit mode.
      TrinaColumn(
        title: 'With editCellRenderer',
        field: 'select_f',
        editCellRenderer:
            (
              defaultEditCellWidget,
              cell,
              controller,
              focusNode,
              handleSelected,
            ) {
              return DropdownButton<String>(
                value: cell.value,
                hint: Text(cell.value),
                items: cell.column.type
                    .asSelect()
                    .items
                    .map(
                      (e) => DropdownMenuItem<String>(value: e, child: Text(e)),
                    )
                    .toList(),
                onChanged: (value) {
                  handleSelected?.call(value);
                },
              );
            },
        type: TrinaColumnType.select(<String>['One', 'Two', 'Three']),
      ),
    ]);

    rows.addAll([
      TrinaRow(
        cells: {
          'select_a': TrinaCell(value: 'One'),
          'select_b': TrinaCell(value: 'Saturn'),
          'select_c': TrinaCell(value: '100'),
          'select_d': TrinaCell(value: 'French'),
          'select_e': TrinaCell(value: 'Africa'),
          'select_f': TrinaCell(value: 'One'),
        },
      ),
      TrinaRow(
        cells: {
          'select_a': TrinaCell(value: 'Two'),
          'select_b': TrinaCell(value: 'Trina'),
          'select_c': TrinaCell(value: '50'),
          'select_d': TrinaCell(value: 'English'),
          'select_e': TrinaCell(value: 'America'),
          'select_f': TrinaCell(value: 'Two'),
        },
      ),
      TrinaRow(
        cells: {
          'select_a': TrinaCell(value: 'Three'),
          'select_b': TrinaCell(value: 'Mars'),
          'select_c': TrinaCell(value: '10'),
          'select_d': TrinaCell(value: 'Arabic'),
          'select_e': TrinaCell(value: 'Asia'),
          'select_f': TrinaCell(value: 'Three'),
        },
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return TrinaExampleScreen(
      title: 'Selection type column',
      topTitle: 'Selection type column',
      topContents: const [
        Text('A column to enter a selection value.'),
        Text(
          'The sorting of the Selection column is based on the order of the Select items.',
        ),
      ],
      topButtons: [
        TrinaExampleButton(
          url:
              'https://github.com/doonfrs/trina_grid/blob/master/demo/lib/screen/feature/selection_type_column_screen.dart',
        ),
      ],
      body: TrinaGrid(
        columns: columns,
        rows: rows,
        onChanged: (TrinaGridOnChangedEvent event) {
          print(event);
        },
        configuration: const TrinaGridConfiguration(
          // If you don't want to move to the next line after selecting the pop-up item, uncomment it.
          // enableMoveDownAfterSelecting: false,
        ),
      ),
    );
  }
}
