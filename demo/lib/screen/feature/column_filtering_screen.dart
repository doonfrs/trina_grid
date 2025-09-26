import 'package:flutter/material.dart';
import 'package:trina_grid/trina_grid.dart';

import '../../dummy_data/development.dart';
import '../../widget/trina_example_button.dart';
import '../../widget/trina_example_screen.dart';

class ColumnFilteringScreen extends StatefulWidget {
  static const routeName = 'feature/column-filtering';

  const ColumnFilteringScreen({super.key});

  @override
  _ColumnFilteringScreenState createState() => _ColumnFilteringScreenState();
}

class _ColumnFilteringScreenState extends State<ColumnFilteringScreen> {
  final List<TrinaColumn> columns = [];

  final List<TrinaRow> rows = [];

  @override
  void initState() {
    super.initState();

    columns.addAll([
      TrinaColumn(title: 'Text', field: 'text', type: TrinaColumnType.text()),
      TrinaColumn(
        title: 'Number',
        field: 'number',
        type: TrinaColumnType.number(),
      ),
      TrinaColumn(title: 'Date', field: 'date', type: TrinaColumnType.date()),
      TrinaColumn(
        title: 'Disable',
        field: 'disable',
        type: TrinaColumnType.text(),
        enableFilterMenuItem: false,
      ),
      TrinaColumn(
        title: 'Select',
        field: 'select',
        type: TrinaColumnType.select(<String>['A', 'B', 'C', 'D', 'E', 'F']),
      ),
      TrinaColumn(title: 'Regex', field: 'regex', type: TrinaColumnType.text()),
    ]);

    rows.addAll(DummyData.rowsByColumns(length: 30, columns: columns));

    // Add some special pattern data for regex filtering examples
    for (var i = 0; i < 5; i++) {
      rows.add(
        TrinaRow(
          cells: {
            'text': TrinaCell(value: 'Text value ${i + 1}'),
            'number': TrinaCell(value: i + 100),
            'date': TrinaCell(value: '2025-05-${i + 1}'),
            'disable': TrinaCell(value: 'Disable value ${i + 1}'),
            'select': TrinaCell(value: ['A', 'B', 'C', 'D', 'E', 'F'][i % 6]),
            'regex': TrinaCell(value: 'user${i + 1}@example.com'),
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return TrinaExampleScreen(
      title: 'Column filtering',
      topTitle: 'Column filtering',
      topContents: const [
        Text('Filter rows by setting filters on columns.'),
        SizedBox(height: 10),
        Text(
          'Select the SetFilter menu from the menu that appears when you tap the icon on the right of the column',
        ),
        Text(
          'If the filter is set to all or complex conditions, TextField under the column is deactivated.',
        ),
        Text(
          'Also, like the Disable column, if enableFilterMenuItem is false, it is excluded from all column filtering conditions.',
        ),
        Text(
          'In the case of the Select column, it is a custom filter that can filter multiple filters with commas. (ex: a,b,c)',
        ),
        Text(
          'The Regex column demonstrates the new Regex filter type that allows filtering with regular expressions.',
        ),
        SizedBox(height: 10),
        Text('Check out the source to add custom filters.'),
      ],
      topButtons: [
        TrinaExampleButton(
          url:
              'https://github.com/doonfrs/trina_grid/blob/master/demo/lib/screen/feature/column_filtering_screen.dart',
        ),
      ],
      body: TrinaGrid(
        columns: columns,
        rows: rows,
        onLoaded: (TrinaGridOnLoadedEvent event) {
          event.stateManager.setShowColumnFilter(true);
        },
        onChanged: (TrinaGridOnChangedEvent event) {
          print(event);
        },
        configuration: TrinaGridConfiguration(
          /// If columnFilterConfig is not set, the default setting is applied.
          ///
          /// Return the value returned by resolveDefaultColumnFilter through the resolver function.
          /// Prevents errors returning filters that are not in the filters list.
          columnFilter: TrinaGridColumnFilterConfig(
            filters: const [
              ...FilterHelper.defaultFilters,
              // custom filter
              ClassYouImplemented(),
            ],
            resolveDefaultColumnFilter: (column, resolver) {
              if (column.field == 'text') {
                return resolver<TrinaFilterTypeContains>() as TrinaFilterType;
              } else if (column.field == 'number') {
                return resolver<TrinaFilterTypeGreaterThan>()
                    as TrinaFilterType;
              } else if (column.field == 'date') {
                return resolver<TrinaFilterTypeLessThan>() as TrinaFilterType;
              } else if (column.field == 'select') {
                return resolver<ClassYouImplemented>() as TrinaFilterType;
              } else if (column.field == 'regex') {
                return resolver<TrinaFilterTypeRegex>() as TrinaFilterType;
              }

              return resolver<TrinaFilterTypeContains>() as TrinaFilterType;
            },
          ),
        ),
      ),
    );
  }
}

class ClassYouImplemented implements TrinaFilterType {
  @override
  String get title => 'Custom contains';

  @override
  get compare =>
      ({
        required String? base,
        required String? search,
        required TrinaColumn? column,
      }) {
        var keys = search!.split(',').map((e) => e.toUpperCase()).toList();

        return keys.contains(base!.toUpperCase());
      };

  const ClassYouImplemented();
}
