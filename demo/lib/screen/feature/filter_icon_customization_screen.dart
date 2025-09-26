import 'package:flutter/material.dart';
import 'package:trina_grid/trina_grid.dart';
import '../../dummy_data/dummy_data.dart';

class FilterIconCustomizationScreen extends StatefulWidget {
  static const routeName = '/filter-icon-customization';

  const FilterIconCustomizationScreen({super.key});

  @override
  State<FilterIconCustomizationScreen> createState() =>
      _FilterIconCustomizationScreenState();
}

class _FilterIconCustomizationScreenState
    extends State<FilterIconCustomizationScreen> {
  late List<TrinaColumn> columns;
  late List<TrinaRow> rows;
  late TrinaGridStateManager stateManager;
  Icon? currentFilterIcon = const Icon(Icons.filter_alt_outlined);

  @override
  void initState() {
    super.initState();

    columns = [
      TrinaColumn(
        title: 'ID',
        field: 'id',
        frozen: TrinaColumnFrozen.start,
        width: 70,
        type: TrinaColumnType.text(),
      ),
      TrinaColumn(
        title: 'Name',
        field: 'name',
        width: 200,
        type: TrinaColumnType.text(),
      ),
      TrinaColumn(title: 'Age', field: 'age', type: TrinaColumnType.number()),
      TrinaColumn(
        title: 'Role',
        field: 'role',
        width: 200,
        type: TrinaColumnType.text(),
      ),
      TrinaColumn(
        title: 'Joined Date',
        field: 'joined_date',
        width: 200,
        type: TrinaColumnType.date(),
      ),
      TrinaColumn(
        title: 'Salary',
        field: 'salary',
        width: 150,
        type: TrinaColumnType.currency(),
      ),
      TrinaColumn(
        title: 'Active',
        field: 'active',
        width: 100,
        type: TrinaColumnType.boolean(),
      ),
    ];

    rows = DummyData.generateEmployeeData(50);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Filter Icon Customization'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('Filter Icon Customization'),
                    content: const Text(
                      'This demo shows how to customize the filter icon that appears '
                      'next to column titles when filtering is applied.\n\n'
                      'Apply a filter to any column, then use the controls below '
                      'the grid to change the filter icon or hide it completely.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('OK'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Apply a filter to any column to see the filter icon appear.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Filter Icon Customization',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.filter_alt_outlined),
                  label: const Text('Default Icon'),
                  onPressed: () {
                    setState(() {
                      currentFilterIcon = const Icon(Icons.filter_alt_outlined);
                    });
                  },
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.search),
                  label: const Text('Search Icon'),
                  onPressed: () {
                    setState(() {
                      currentFilterIcon = const Icon(Icons.search);
                    });
                  },
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.filter_list),
                  label: const Text('Filter List Icon'),
                  onPressed: () {
                    setState(() {
                      currentFilterIcon = const Icon(Icons.filter_list);
                    });
                  },
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.tune),
                  label: const Text('Tune Icon'),
                  onPressed: () {
                    setState(() {
                      currentFilterIcon = const Icon(Icons.tune);
                    });
                  },
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.visibility_off),
                  label: const Text('Hide Icon'),
                  onPressed: () {
                    setState(() {
                      currentFilterIcon = null;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TrinaGrid(
                columns: columns,
                rows: rows,
                onLoaded: (TrinaGridOnLoadedEvent event) {
                  stateManager = event.stateManager;
                  stateManager.setShowColumnFilter(true);
                },
                configuration: TrinaGridConfiguration(
                  style: TrinaGridStyleConfig(filterIcon: currentFilterIcon),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
