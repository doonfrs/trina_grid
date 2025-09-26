import 'package:flutter/material.dart';
import 'package:trina_grid/trina_grid.dart';
import '../../widget/trina_example_button.dart';
import '../../widget/trina_example_screen.dart';

class MultiItemsDelegateDemoScreen extends StatefulWidget {
  static const routeName = '/multiitems-delegate-demo';

  const MultiItemsDelegateDemoScreen({super.key});

  @override
  State<MultiItemsDelegateDemoScreen> createState() =>
      _MultiItemsDelegateDemoScreenState();
}

class _MultiItemsDelegateDemoScreenState
    extends State<MultiItemsDelegateDemoScreen> {
  late List<TrinaColumn> columns;
  late List<TrinaRow> rows;

  @override
  void initState() {
    super.initState();
    columns = [
      TrinaColumn(
        title: 'ID',
        field: 'id',
        width: 70,
        type: TrinaColumnType.text(),
      ),
      TrinaColumn(
        title: 'Multi Filter',
        field: 'multi',
        width: 200,
        type: TrinaColumnType.text(),
        filterWidgetDelegate: const TrinaFilterColumnWidgetDelegate.multiItems(
          caseSensitive: false,
        ),
      ),
      TrinaColumn(
        title: 'Name',
        field: 'name',
        width: 200,
        type: TrinaColumnType.text(),
      ),
    ];
    rows = List.generate(30, (index) {
      return TrinaRow(
        cells: {
          'id': TrinaCell(value: index + 1),
          'multi': TrinaCell(value: 'Item ${index % 5}'),
          'name': TrinaCell(value: 'Name $index'),
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return TrinaExampleScreen(
      title: 'MultiItems Filter Delegate',
      topTitle: 'MultiItems Filter Delegate',
      topContents: const [
        Text(
          'This demo shows how to use the TrinaFilterColumnWidgetDelegate.multiItems to allow multi-line or multi-item filtering in a column.',
        ),
        SizedBox(height: 10),
        Text(
          'Try filtering the "Multi Filter" column with multiple lines or items.',
        ),
      ],
      topButtons: [
        TrinaExampleButton(
          url:
              'https://github.com/doonfrs/trina_grid/blob/master/demo/lib/screen/feature/multiitems_delegate_demo_screen.dart',
        ),
      ],
      body: TrinaGrid(
        columns: columns,
        rows: rows,
        onLoaded: (TrinaGridOnLoadedEvent event) {
          event.stateManager.setShowColumnFilter(true);
        },
        configuration: TrinaGridConfiguration(
          columnFilter: TrinaGridColumnFilterConfig(
            filters: const [
              ...FilterHelper.defaultFilters,
              TrinaFilterTypeMultiItems(caseSensitive: false),
            ],
            resolveDefaultColumnFilter: (column, resolver) {
              if (column.field == 'multi') {
                return const TrinaFilterTypeMultiItems(caseSensitive: false);
              }
              return resolver<TrinaFilterTypeContains>();
            },
          ),
        ),
      ),
    );
  }
}
