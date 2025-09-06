import 'package:flutter/material.dart';
import 'package:trina_grid/trina_grid.dart';

import '../../dummy_data/development.dart';
import '../../widget/trina_example_button.dart';
import '../../widget/trina_example_screen.dart';

class ColumnFilteringPopupScreen extends StatefulWidget {
  static const routeName = 'feature/column-filtering-popup-custom';

  const ColumnFilteringPopupScreen({super.key});

  @override
  _ColumnFilteringPopupScreenState createState() => _ColumnFilteringPopupScreenState();
}

enum FilterMode {
  filter,
  highlight,
}

class _ColumnFilteringPopupScreenState extends State<ColumnFilteringPopupScreen> {
  final List<TrinaColumn> columns = [];

  final List<TrinaRow> rows = [];

  late TrinaGridStateManager stateManager;

  FilterMode filterMode = FilterMode.filter;
  List<TrinaRow> filterRows = [];
  List<TrinaRow> filteredList = [];

  @override
  void initState() {
    super.initState();

    columns.addAll([
      TrinaColumn(
        title: 'Text',
        field: 'text',
        type: TrinaColumnType.text(),
      ),
      TrinaColumn(
        title: 'Number',
        field: 'number',
        type: TrinaColumnType.number(),
      ),
      TrinaColumn(
        title: 'Date',
        field: 'date',
        type: TrinaColumnType.date(),
      ),
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
      TrinaColumn(
        title: 'Regex',
        field: 'regex',
        type: TrinaColumnType.text(),
      ),
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
      title: 'Column filtering popup',
      topTitle: 'Column filtering popup',
      topContents: const [
        Text('Custom column filtering popup.'),
        SizedBox(
          height: 10,
        ),
        Text('Check out the source to custom filter popup.'),
      ],
      topButtons: [
        TrinaExampleButton(
          url:
              'https://github.com/doonfrs/trina_grid/blob/master/demo/lib/screen/feature/column_filtering_popup_screen.dart',
        ),
      ],
      body: TrinaGrid(
        columns: columns,
        rows: rows,
        onLoaded: (TrinaGridOnLoadedEvent event) {
          stateManager = event.stateManager;
          stateManager.setShowColumnFilter(true);
          stateManager.setFilterOnlyEvent(true);
          stateManager.eventManager?.listener((event) {
            if (event is TrinaGridSetColumnFilterEvent) {
              filterRows = event.filterRows;
              print('receive filterRows: $filterRows');
              var enabledFilterColumnFields =
                  stateManager.refColumns.where((element) => element.enableFilterMenuItem).toList();
              var filter = FilterHelper.convertRowsToFilter(filterRows, enabledFilterColumnFields);
              switch (filterMode) {
                case FilterMode.filter:
                  stateManager.refRows.setFilter(filter);
                  stateManager.resetCurrentState(notify: false);
                  stateManager.notifyListeners(true, stateManager.setFilter.hashCode);
                case FilterMode.highlight:
                  var srcList = FilteredList(initialList: stateManager.refRows);
                  srcList.setFilter(filter);
                  setState(() {
                    filteredList = srcList.filteredList;
                  });
              }
            }
          });
        },
        rowColorCallback: (rowColorContext) {
          if (filteredList.contains(rowColorContext.row)) {
            return Colors.orange;
          }
          return Colors.white;
        },
        onChanged: (TrinaGridOnChangedEvent event) {
          print(event);
        },
        configuration: TrinaGridConfiguration(
          filterPopupConfig: TrinaGridFilterPopupConfig(
            headerIconSpacing: 8.0,
            headerAddIconBuilder: (context) =>
                Tooltip(message: 'add filter', child: Icon(Icons.add, color: Colors.green, size: 24)),
            headerRemoveIconBuilder: (context) =>
                Tooltip(message: 'remove filter', child: Icon(Icons.remove, color: Colors.green, size: 24)),
            headerClearIconBuilder: (context) =>
                Tooltip(message: 'add filter', child: Icon(Icons.clear_all, color: Colors.red, size: 24)),
            headerAppendBuilder: (context) {
              return Row(
                children: [
                  StatefulBuilder(
                    builder: (context, setState) {
                      return RadioGroup<FilterMode>(
                          groupValue: filterMode,
                          onChanged: (value) {
                            if (value == null) return;
                            setState(() {
                              filterMode = value;
                              if (value == FilterMode.filter) {
                                filteredList = [];
                              } else {
                                stateManager.refRows.setFilter(null);
                              }
                              stateManager.eventManager
                                    ?.addEvent(TrinaGridSetColumnFilterEvent(filterRows: filterRows));
                            });
                          },
                          child: Row(
                            children: [
                              Radio(value: FilterMode.filter),
                              Text('Filter'),
                              Radio(value: FilterMode.highlight),
                              Text('Highlight'),
                            ],
                          ));
                    },
                  ),
                  Spacer(),
                  IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: Icon(Icons.close))
                ],
              );
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
  get compare => ({
        required String? base,
        required String? search,
        required TrinaColumn? column,
      }) {
        var keys = search!.split(',').map((e) => e.toUpperCase()).toList();

        return keys.contains(base!.toUpperCase());
      };

  const ClassYouImplemented();
}
