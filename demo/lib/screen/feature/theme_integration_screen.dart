import 'package:flutter/material.dart';
import 'package:trina_grid/trina_grid.dart';

import '../../widget/trina_example_button.dart';
import '../../widget/trina_example_screen.dart';

class ThemeIntegrationScreen extends StatefulWidget {
  static const routeName = 'feature/theme-integration';

  const ThemeIntegrationScreen({super.key});

  @override
  State<ThemeIntegrationScreen> createState() => _ThemeIntegrationScreenState();
}

class _ThemeIntegrationScreenState extends State<ThemeIntegrationScreen> {
  final List<TrinaColumn> columns = [];

  final List<TrinaRow> rows = [];

  static const Map<String, Color> _seeds = {
    'Indigo': Colors.indigo,
    'Deep purple': Colors.deepPurple,
    'Teal': Colors.teal,
    'Orange': Colors.orange,
    'Pink': Colors.pink,
  };

  String _seedName = 'Indigo';

  Brightness _brightness = Brightness.light;

  @override
  void initState() {
    super.initState();

    columns.addAll([
      TrinaColumn(
        title: 'ID',
        field: 'id',
        type: TrinaColumnType.number(),
        width: 80,
        frozen: TrinaColumnFrozen.start,
      ),
      TrinaColumn(
        title: 'Name',
        field: 'name',
        type: TrinaColumnType.text(),
        width: 150,
        enableRowChecked: true,
      ),
      TrinaColumn(
        title: 'Status',
        field: 'status',
        type: TrinaColumnType.select(<String>[
          'Active',
          'Inactive',
          'Pending',
          'Completed',
        ]),
        width: 130,
      ),
      TrinaColumn(
        title: 'Date',
        field: 'date',
        type: TrinaColumnType.date(),
        width: 130,
      ),
      TrinaColumn(
        title: 'Amount',
        field: 'amount',
        type: TrinaColumnType.currency(),
        width: 140,
        readOnly: true,
      ),
    ]);

    const statuses = ['Active', 'Inactive', 'Pending', 'Completed'];

    for (int i = 1; i <= 40; i += 1) {
      rows.add(
        TrinaRow(
          cells: {
            'id': TrinaCell(value: i),
            'name': TrinaCell(value: 'Item $i'),
            'status': TrinaCell(value: statuses[i % statuses.length]),
            'date': TrinaCell(
              value: DateTime.now().add(Duration(days: i % 30 - 15)),
            ),
            'amount': TrinaCell(value: (5000 + (i * 123.45)) % 50000),
          },
        ),
      );
    }
  }

  ThemeData get _theme => ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: _seeds[_seedName]!,
      brightness: _brightness,
    ),
  );

  Widget _buildControls() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Wrap(
        spacing: 16,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          const Text('Seed color:'),
          DropdownButton<String>(
            value: _seedName,
            items: _seeds.keys
                .map(
                  (name) => DropdownMenuItem<String>(
                    value: name,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: _seeds[name],
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(name),
                      ],
                    ),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value == null) return;
              setState(() => _seedName = value);
            },
          ),
          const Text('Brightness:'),
          SegmentedButton<Brightness>(
            segments: const [
              ButtonSegment(value: Brightness.light, label: Text('Light')),
              ButtonSegment(value: Brightness.dark, label: Text('Dark')),
            ],
            selected: {_brightness},
            onSelectionChanged: (selection) {
              setState(() => _brightness = selection.first);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TrinaExampleScreen(
      title: 'Material theme integration',
      topTitle: 'Material theme integration',
      topContents: const [
        Text(
          'TrinaGridConfiguration.fromTheme(context) derives the grid colors from the ambient Material ColorScheme.',
        ),
        SizedBox(height: 8),
        Text(
          'Change the seed color or the brightness below and the whole grid follows, including the column menu, the filter popup and the select and date editors.',
        ),
        SizedBox(height: 8),
        Text(
          'This is opt-in. TrinaGridConfiguration() and TrinaGridConfiguration.dark() keep their fixed palettes.',
        ),
      ],
      topButtons: [
        TrinaExampleButton(
          url:
              'https://github.com/doonfrs/trina_grid/blob/master/demo/lib/screen/feature/theme_integration_screen.dart',
        ),
      ],
      body: Theme(
        data: _theme,
        child: Builder(
          builder: (themedContext) {
            return ColoredBox(
              color: Theme.of(themedContext).colorScheme.surfaceContainerLowest,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildControls(),
                    Expanded(
                      child: TrinaGrid(
                        key: ValueKey('$_seedName-$_brightness'),
                        columns: columns,
                        rows: rows,
                        configuration:
                            TrinaGridConfiguration.fromTheme(
                              themedContext,
                            ).copyWith(
                              columnFilter: const TrinaGridColumnFilterConfig(
                                filters: [...FilterHelper.defaultFilters],
                              ),
                            ),
                        onLoaded: (event) {
                          event.stateManager.setShowColumnFilter(true);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
