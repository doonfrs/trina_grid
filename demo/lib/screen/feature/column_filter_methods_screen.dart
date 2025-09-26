import 'package:flutter/material.dart';
import 'package:trina_grid/trina_grid.dart';

import '../../widget/trina_example_button.dart';
import '../../widget/trina_example_screen.dart';

class ColumnFilterMethodsScreen extends StatefulWidget {
  static const routeName = 'feature/column-filter-methods';

  const ColumnFilterMethodsScreen({super.key});

  @override
  _ColumnFilterMethodsScreenState createState() =>
      _ColumnFilterMethodsScreenState();
}

class _ColumnFilterMethodsScreenState extends State<ColumnFilterMethodsScreen> {
  final List<TrinaColumn> columns = [];
  final List<TrinaRow> rows = [];
  TrinaGridStateManager? stateManager;

  @override
  void initState() {
    super.initState();

    // Create columns
    columns.addAll([
      TrinaColumn(
        title: 'ID',
        field: 'id',
        type: TrinaColumnType.text(),
        width: 100,
        readOnly: true,
      ),
      TrinaColumn(
        title: 'Name',
        field: 'name',
        type: TrinaColumnType.text(),
        width: 150,
      ),
      TrinaColumn(
        title: 'Age',
        field: 'age',
        type: TrinaColumnType.number(),
        width: 80,
      ),
      TrinaColumn(
        title: 'Department',
        field: 'department',
        type: TrinaColumnType.select([
          'Engineering',
          'Sales',
          'HR',
          'Marketing',
        ]),
        width: 150,
      ),
      TrinaColumn(
        title: 'Active',
        field: 'active',
        type: TrinaColumnType.boolean(),
        width: 100,
      ),
      TrinaColumn(
        title: 'Salary',
        field: 'salary',
        type: TrinaColumnType.currency(format: '#,###.##'),
        width: 150,
      ),
    ]);

    // Create sample data
    final departments = ['Engineering', 'Sales', 'HR', 'Marketing'];
    final names = [
      'John',
      'Jane',
      'Bob',
      'Alice',
      'Charlie',
      'Diana',
      'Eve',
      'Frank',
    ];

    for (int i = 1; i <= 50; i++) {
      rows.add(
        TrinaRow(
          cells: {
            'id': TrinaCell(value: 'EMP-${i.toString().padLeft(3, '0')}'),
            'name': TrinaCell(
              value:
                  '${names[i % names.length]} ${i > names.length ? (i ~/ names.length) : ''}',
            ),
            'age': TrinaCell(value: 22 + (i % 40)),
            'department': TrinaCell(value: departments[i % departments.length]),
            'active': TrinaCell(value: i % 3 != 0), // ~67% active
            'salary': TrinaCell(value: 40000 + (i * 1500) + ((i % 5) * 5000)),
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return TrinaExampleScreen(
      title: 'Column Filter Methods',
      topTitle: 'Programmatic Column Filtering',
      topContents: const [
        Text(
          'Demonstrates the new setColumnFilter(), removeColumnFilter(), and clearAllColumnFilters() methods for programmatic filtering.',
        ),
        SizedBox(height: 10),
        Text('Click the buttons below to apply different filters dynamically:'),
      ],
      topButtons: [
        TrinaExampleButton(
          url:
              'https://github.com/doonfrs/trina_grid/blob/master/demo/lib/screen/feature/column_filter_methods_screen.dart',
        ),
      ],
      body: Column(
        children: [
          _filterButtons,
          const SizedBox(height: 10),
          _currentFiltersDisplay,
          const SizedBox(height: 10),
          Expanded(
            child: TrinaGrid(
              columns: columns,
              rows: rows,
              onLoaded: (TrinaGridOnLoadedEvent event) {
                stateManager = event.stateManager;
                stateManager?.setShowColumnFilter(true);
              },
              configuration: TrinaGridConfiguration(
                style: TrinaGridStyleConfig(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget get _filterButtons {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filter Controls:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                // Boolean filters
                ElevatedButton.icon(
                  onPressed: () {
                    stateManager?.setColumnFilter(
                      columnField: 'active',
                      filterType: const TrinaFilterTypeEquals(),
                      filterValue: true,
                    );
                    setState(() {});
                  },
                  icon: const Icon(Icons.check_circle, size: 16),
                  label: const Text('Active Only'),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    stateManager?.setColumnFilter(
                      columnField: 'active',
                      filterType: const TrinaFilterTypeEquals(),
                      filterValue: false,
                    );
                    setState(() {});
                  },
                  icon: const Icon(Icons.cancel, size: 16),
                  label: const Text('Inactive Only'),
                ),
                // Text filters
                ElevatedButton.icon(
                  onPressed: () {
                    stateManager?.setColumnFilter(
                      columnField: 'name',
                      filterType: const TrinaFilterTypeContains(),
                      filterValue: 'John',
                    );
                    setState(() {});
                  },
                  icon: const Icon(Icons.person_search, size: 16),
                  label: const Text('Names with "John"'),
                ),
                // Department filters
                ElevatedButton.icon(
                  onPressed: () {
                    stateManager?.setColumnFilter(
                      columnField: 'department',
                      filterType: const TrinaFilterTypeEquals(),
                      filterValue: 'Engineering',
                    );
                    setState(() {});
                  },
                  icon: const Icon(Icons.engineering, size: 16),
                  label: const Text('Engineering Dept'),
                ),
                // Numeric filters
                ElevatedButton.icon(
                  onPressed: () {
                    stateManager?.setColumnFilter(
                      columnField: 'salary',
                      filterType: const TrinaFilterTypeGreaterThan(),
                      filterValue: 60000,
                    );
                    setState(() {});
                  },
                  icon: const Icon(Icons.attach_money, size: 16),
                  label: const Text('Salary > 60k'),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    stateManager?.setColumnFilter(
                      columnField: 'age',
                      filterType: const TrinaFilterTypeLessThan(),
                      filterValue: 30,
                    );
                    setState(() {});
                  },
                  icon: const Icon(Icons.person, size: 16),
                  label: const Text('Age < 30'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                // Remove specific filters
                ElevatedButton.icon(
                  onPressed: () {
                    stateManager?.removeColumnFilter('active');
                    setState(() {});
                  },
                  icon: const Icon(Icons.remove_circle_outline, size: 16),
                  label: const Text('Remove Active Filter'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    stateManager?.removeColumnFilter('name');
                    setState(() {});
                  },
                  icon: const Icon(Icons.remove_circle_outline, size: 16),
                  label: const Text('Remove Name Filter'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                ),
                // Clear all
                ElevatedButton.icon(
                  onPressed: () {
                    stateManager?.clearAllColumnFilters();
                    setState(() {});
                  },
                  icon: const Icon(Icons.clear_all, size: 16),
                  label: const Text('Clear All Filters'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    _showCurrentFilters();
                  },
                  icon: const Icon(Icons.info_outline, size: 16),
                  label: const Text('Show Filter Info'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget get _currentFiltersDisplay {
    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Current Filters:',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            (stateManager?.filterRows.isEmpty ?? true)
                ? const Text(
                    'No filters applied',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.grey,
                    ),
                  )
                : Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: stateManager == null
                        ? []
                        : stateManager!.filterRows.map((filterRow) {
                            final column =
                                filterRow
                                    .cells[FilterHelper.filterFieldColumn]
                                    ?.value ??
                                'Unknown';
                            final value =
                                filterRow
                                    .cells[FilterHelper.filterFieldValue]
                                    ?.value ??
                                '';
                            final filterType =
                                filterRow
                                    .cells[FilterHelper.filterFieldType]
                                    ?.value ??
                                const TrinaFilterTypeContains();

                            return Chip(
                              label: Text(
                                '$column ${_getFilterTypeSymbol(filterType)} $value',
                              ),
                              deleteIcon: const Icon(Icons.close, size: 16),
                              onDeleted: () {
                                stateManager?.removeColumnFilter(column);
                                setState(() {});
                              },
                            );
                          }).toList(),
                  ),
          ],
        ),
      ),
    );
  }

  void _showCurrentFilters() {
    if (stateManager == null) return;

    final List<String> filterInfo = [];
    final List<String> columnFields = [
      'active',
      'name',
      'department',
      'salary',
      'age',
    ];

    for (String field in columnFields) {
      final filterValue = stateManager!.getColumnFilterValue(field);
      final filterType = stateManager!.getColumnFilterType(field);

      if (filterValue != null && filterType != null) {
        final typeSymbol = _getFilterTypeSymbol(filterType);
        filterInfo.add('$field $typeSymbol $filterValue');
      }
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Current Filter Information'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: filterInfo.isEmpty
              ? [const Text('No filters applied')]
              : filterInfo
                    .map(
                      (info) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Text('• $info'),
                      ),
                    )
                    .toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  String _getFilterTypeSymbol(TrinaFilterType filterType) {
    if (filterType is TrinaFilterTypeEquals) {
      return '=';
    } else if (filterType is TrinaFilterTypeContains) {
      return '⊃';
    } else if (filterType is TrinaFilterTypeGreaterThan) {
      return '>';
    } else if (filterType is TrinaFilterTypeLessThan) {
      return '<';
    } else if (filterType is TrinaFilterTypeGreaterThanOrEqualTo) {
      return '≥';
    } else if (filterType is TrinaFilterTypeLessThanOrEqualTo) {
      return '≤';
    } else if (filterType is TrinaFilterTypeStartsWith) {
      return 'starts with';
    } else if (filterType is TrinaFilterTypeEndsWith) {
      return 'ends with';
    } else {
      return '~';
    }
  }
}
