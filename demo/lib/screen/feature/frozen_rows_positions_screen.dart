import 'package:flutter/material.dart';
import 'package:trina_grid/trina_grid.dart';

import '../../widget/trina_example_button.dart';
import '../../widget/trina_example_screen.dart';

class FrozenRowsPositionsScreen extends StatefulWidget {
  static const routeName = 'feature/frozen-rows-positions';

  const FrozenRowsPositionsScreen({super.key});

  @override
  State<FrozenRowsPositionsScreen> createState() =>
      _FrozenRowsPositionsScreenState();
}

class _FrozenRowsPositionsScreenState extends State<FrozenRowsPositionsScreen> {
  late final List<TrinaColumn> columns;
  late final List<TrinaRow> rows;

  @override
  void initState() {
    super.initState();

    // Create columns
    columns = [
      TrinaColumn(
        title: 'ID',
        field: 'id',
        type: TrinaColumnType.number(),
        width: 80,
        enableColumnDrag: false,
        enableSorting: false,
        enableContextMenu: false,
      ),
      TrinaColumn(
        title: 'Name',
        field: 'name',
        type: TrinaColumnType.text(),
        enableFilterMenuItem: true,
      ),
      TrinaColumn(
        title: 'Age',
        field: 'age',
        type: TrinaColumnType.number(),
        enableFilterMenuItem: true,
      ),
      TrinaColumn(
        title: 'Role',
        field: 'role',
        type: TrinaColumnType.text(),
        enableFilterMenuItem: true,
      ),
      TrinaColumn(
        title: 'Department',
        field: 'department',
        type: TrinaColumnType.text(),
        enableFilterMenuItem: true,
      ),
      TrinaColumn(
        title: 'Status',
        field: 'status',
        type: TrinaColumnType.text(),
        enableFilterMenuItem: true,
      ),
    ];

    // Create rows with different frozen positions
    rows = [
      // Row frozen before title (appears above column titles)
      TrinaRow(
        frozen: TrinaRowFrozen.beforeTitle,
        cells: {
          'id': TrinaCell(value: 'BT1'),
          'name': TrinaCell(value: '📌 FROZEN BEFORE TITLE'),
          'age': TrinaCell(value: '---'),
          'role': TrinaCell(value: 'This row appears above column titles'),
          'department': TrinaCell(value: '---'),
          'status': TrinaCell(value: 'Special'),
        },
      ),

      // Row frozen before filter (appears between titles and filters)
      TrinaRow(
        frozen: TrinaRowFrozen.beforeFilter,
        cells: {
          'id': TrinaCell(value: 'BF1'),
          'name': TrinaCell(value: '🔍 FROZEN BEFORE FILTER'),
          'age': TrinaCell(value: '---'),
          'role':
              TrinaCell(value: 'This row appears between titles and filters'),
          'department': TrinaCell(value: '---'),
          'status': TrinaCell(value: 'Special'),
        },
      ),

      // Row frozen at start (traditional frozen row at top of data area)
      TrinaRow(
        frozen: TrinaRowFrozen.start,
        cells: {
          'id': TrinaCell(value: 'S1'),
          'name': TrinaCell(value: '⬆️ FROZEN AT START'),
          'age': TrinaCell(value: '---'),
          'role': TrinaCell(value: 'Traditional frozen row at top'),
          'department': TrinaCell(value: '---'),
          'status': TrinaCell(value: 'Frozen'),
        },
      ),

      // Regular scrollable rows
      ...List.generate(30, (index) {
        return TrinaRow(
          cells: {
            'id': TrinaCell(value: index + 1),
            'name': TrinaCell(value: 'User ${index + 1}'),
            'age': TrinaCell(value: 20 + (index % 40)),
            'role': TrinaCell(
                value: index % 3 == 0
                    ? 'Developer'
                    : index % 3 == 1
                        ? 'Designer'
                        : 'Manager'),
            'department':
                TrinaCell(value: index % 2 == 0 ? 'Engineering' : 'Product'),
            'status': TrinaCell(
                value: index % 4 == 0
                    ? 'Active'
                    : index % 4 == 1
                        ? 'On Leave'
                        : index % 4 == 2
                            ? 'Remote'
                            : 'In Office'),
          },
        );
      }),

      // Row frozen at end (traditional frozen row at bottom)
      TrinaRow(
        frozen: TrinaRowFrozen.end,
        cells: {
          'id': TrinaCell(value: 'E1'),
          'name': TrinaCell(value: '⬇️ FROZEN AT END'),
          'age': TrinaCell(value: '---'),
          'role': TrinaCell(value: 'Traditional frozen row at bottom'),
          'department': TrinaCell(value: '---'),
          'status': TrinaCell(value: 'Frozen'),
        },
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return TrinaExampleScreen(
      title: 'Frozen Rows Positions',
      topTitle: 'Frozen Rows at Different Positions',
      topContents: const [
        Text(
          'This demo shows the new frozen row positions:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Text('• beforeTitle: Row appears above column titles'),
        Text('• beforeFilter: Row appears between titles and filters'),
        Text('• start: Traditional frozen row at top of data area'),
        Text('• end: Traditional frozen row at bottom of data area'),
        SizedBox(height: 8),
        Text(
          'Try scrolling and filtering to see how frozen rows behave!',
          style: TextStyle(fontStyle: FontStyle.italic),
        ),
      ],
      topButtons: [
        TrinaExampleButton(
          url:
              'https://github.com/doonfrs/trina_grid/blob/master/doc/features/frozen-rows.md',
        ),
      ],
      body: TrinaGrid(
        columns: columns,
        rows: rows,
        configuration: TrinaGridConfiguration(
          style: const TrinaGridStyleConfig(
            enableColumnBorderVertical: true,
            enableColumnBorderHorizontal: true,
            enableRowColorAnimation: true,
            gridBorderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          columnFilter: TrinaGridColumnFilterConfig(
            filters: FilterHelper.defaultFilters,
            resolveDefaultColumnFilter: (column, resolver) {
              return resolver<TrinaDropdownMenuFilter>()!;
            },
          ),
        ),
        onLoaded: (TrinaGridOnLoadedEvent event) {
          // Show column filters by default
          event.stateManager.setShowColumnFilter(true);
        },
      ),
    );
  }
}
