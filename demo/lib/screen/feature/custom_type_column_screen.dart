import 'package:flutter/material.dart';
import 'package:trina_grid/trina_grid.dart';

import '../../widget/trina_example_button.dart';
import '../../widget/trina_example_screen.dart';

class CustomTypeColumnScreen extends StatefulWidget {
  static const routeName = 'feature/custom-type-column';

  const CustomTypeColumnScreen({super.key});

  @override
  State<CustomTypeColumnScreen> createState() => _CustomTypeColumnScreenState();
}

class _Address {
  final String street;
  final String city;
  final String country;

  const _Address({
    required this.street,
    required this.city,
    required this.country,
  });

  @override
  String toString() => '$street, $city, $country';
}

class _CustomTypeColumnScreenState extends State<CustomTypeColumnScreen> {
  final List<TrinaColumn> columns = [];
  final List<TrinaRow> rows = [];
  late TrinaGridStateManager stateManager;

  static const _cities = [
    'New York',
    'London',
    'Tokyo',
    'Paris',
    'Berlin',
    'Sydney',
    'Toronto',
    'Dubai',
    'Singapore',
    'Mumbai',
  ];

  static const _streets = [
    '123 Main St',
    '456 Oak Ave',
    '789 Pine Rd',
    '321 Elm Blvd',
    '654 Maple Dr',
    '987 Cedar Ln',
    '147 Birch Way',
    '258 Walnut Ct',
    '369 Spruce Pl',
    '741 Willow St',
  ];

  static const _countries = [
    'USA',
    'UK',
    'Japan',
    'France',
    'Germany',
    'Australia',
    'Canada',
    'UAE',
    'Singapore',
    'India',
  ];

  @override
  void initState() {
    super.initState();

    columns.addAll([
      TrinaColumn(
        title: 'ID',
        field: 'id',
        type: TrinaColumnType.number(),
        width: 80,
        readOnly: true,
      ),
      TrinaColumn(
        title: 'Name',
        field: 'name',
        type: TrinaColumnType.text(),
        width: 150,
      ),
      TrinaColumn(
        title: 'Address (custom object)',
        field: 'address',
        type: TrinaColumnType.custom(
          defaultValue: const _Address(street: '', city: '', country: ''),
          toDisplayString: (value) {
            if (value is _Address) {
              return '${value.street}, ${value.city}';
            }
            return value.toString();
          },
          compare: (a, b) {
            if (a is _Address && b is _Address) {
              return a.city.compareTo(b.city);
            }
            return 0;
          },
          isValid: (value) => value is _Address,
        ),
        width: 250,
        readOnly: true,
      ),
      TrinaColumn(
        title: 'City (custom renderer)',
        field: 'city',
        type: TrinaColumnType.custom(
          toDisplayString: (value) {
            if (value is _Address) return value.city;
            return value.toString();
          },
          compare: (a, b) {
            if (a is _Address && b is _Address) {
              return a.city.compareTo(b.city);
            }
            return 0;
          },
        ),
        readOnly: true,
        width: 140,
        renderer: (rendererContext) {
          final address = rendererContext.cell.value;
          if (address is _Address) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  address.city,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
      TrinaColumn(
        title: 'Country (custom renderer)',
        field: 'country',
        type: TrinaColumnType.custom(
          toDisplayString: (value) {
            if (value is _Address) return value.country;
            return value.toString();
          },
        ),
        readOnly: true,
        width: 140,
        renderer: (rendererContext) {
          final address = rendererContext.cell.value;
          if (address is _Address) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Chip(
                  label: Text(
                    address.country,
                    style: const TextStyle(fontSize: 12),
                  ),
                  visualDensity: VisualDensity.compact,
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
      TrinaColumn(
        title: 'Tags (Map)',
        field: 'tags',
        type: TrinaColumnType.custom(
          defaultValue: const <String, dynamic>{},
          toDisplayString: (value) {
            if (value is Map) {
              return value.entries
                  .map((e) => '${e.key}: ${e.value}')
                  .join(', ');
            }
            return value.toString();
          },
        ),
        width: 200,
        readOnly: true,
      ),
    ]);

    for (int i = 0; i < 20; i++) {
      rows.add(
        TrinaRow(
          cells: {
            'id': TrinaCell(value: i + 1),
            'name': TrinaCell(value: 'Person ${i + 1}'),
            'address': TrinaCell(
              value: _Address(
                street: _streets[i % _streets.length],
                city: _cities[i % _cities.length],
                country: _countries[i % _countries.length],
              ),
            ),
            'city': TrinaCell(
              value: _Address(
                street: _streets[i % _streets.length],
                city: _cities[i % _cities.length],
                country: _countries[i % _countries.length],
              ),
            ),
            'country': TrinaCell(
              value: _Address(
                street: _streets[i % _streets.length],
                city: _cities[i % _cities.length],
                country: _countries[i % _countries.length],
              ),
            ),
            'tags': TrinaCell(
              value: {
                'role': i % 2 == 0 ? 'admin' : 'user',
                'level': (i % 5) + 1,
              },
            ),
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return TrinaExampleScreen(
      title: 'Custom Type Column',
      topTitle: 'Custom Type Column',
      topContents: const [
        Text(
          'Custom type columns allow storing complex objects (maps, custom classes, etc.) in cells. '
          'You can provide optional callbacks for validation, sorting, and display.',
        ),
        SizedBox(height: 10),
      ],
      topButtons: [
        TrinaExampleButton(
          url:
              'https://github.com/doonfrs/trina_grid/blob/master/demo/lib/screen/feature/custom_type_column_screen.dart',
        ),
      ],
      body: Column(
        children: [
          _headerButtons,
          Expanded(
            child: TrinaGrid(
              columns: columns,
              rows: rows,
              onLoaded: (TrinaGridOnLoadedEvent event) {
                stateManager = event.stateManager;
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget get _headerButtons {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          ElevatedButton(
            onPressed: () {
              final address = stateManager.rows.first.cells['address']?.value;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Address value type: ${address.runtimeType}\n'
                    'Value: $address',
                  ),
                ),
              );
            },
            child: const Text('Inspect First Row'),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: () {
              stateManager.changeCellValue(
                stateManager.rows.first.cells['address']!,
                const _Address(
                  street: '999 Updated Blvd',
                  city: 'Amsterdam',
                  country: 'Netherlands',
                ),
              );
            },
            child: const Text('Update First Address'),
          ),
        ],
      ),
    );
  }
}
