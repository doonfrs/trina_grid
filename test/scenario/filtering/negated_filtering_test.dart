import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trina_grid/trina_grid.dart';

/// The Does not contain and Not equals filter types, applied through the grid.
void main() {
  late TrinaGridStateManager stateManager;

  final columns = [
    TrinaColumn(title: 'name', field: 'name', type: TrinaColumnType.text()),
    TrinaColumn(
      title: 'amount',
      field: 'amount',
      type: TrinaColumnType.number(),
    ),
  ];

  List<TrinaRow> buildRows() {
    return [
      TrinaRow(
        cells: {
          'name': TrinaCell(value: 'apple'),
          'amount': TrinaCell(value: 1000),
        },
      ),
      TrinaRow(
        cells: {
          'name': TrinaCell(value: 'pineapple'),
          'amount': TrinaCell(value: 2000),
        },
      ),
      TrinaRow(
        cells: {
          'name': TrinaCell(value: 'banana'),
          'amount': TrinaCell(value: 300),
        },
      ),
    ];
  }

  Future<void> buildGrid(
    WidgetTester tester, {
    TrinaGridLocaleText localeText = const TrinaGridLocaleText(),
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: TrinaGrid(
            columns: columns,
            rows: buildRows(),
            configuration: TrinaGridConfiguration(localeText: localeText),
            onLoaded: (e) => stateManager = e.stateManager,
          ),
        ),
      ),
    );
  }

  List<String> filterBy(
    TrinaFilterType filterType,
    String value, {
    String? field,
  }) {
    stateManager.setFilterWithFilterRows([
      FilterHelper.createFilterRow(
        columnField: field,
        filterType: filterType,
        filterValue: value,
      ),
    ]);

    return stateManager.refRows
        .map((row) => row.cells['name']!.value as String)
        .toList();
  }

  tearDown(() {
    // updateLocale writes the static filter type names, reset them.
    TrinaGridConfiguration().updateLocale();
  });

  testWidgets('Does not contain on a column keeps the other rows', (
    tester,
  ) async {
    await buildGrid(tester);

    expect(
      filterBy(const TrinaFilterTypeDoesNotContain(), 'APPLE', field: 'name'),
      ['banana'],
    );
  });

  testWidgets('Not equals on a number column matches the displayed value', (
    tester,
  ) async {
    await buildGrid(tester);

    expect(
      filterBy(const TrinaFilterTypeNotEquals(), '1,000', field: 'amount'),
      ['pineapple', 'banana'],
    );
    expect(
      filterBy(const TrinaFilterTypeNotEquals(), '1000', field: 'amount'),
      ['pineapple', 'banana'],
    );
  });

  testWidgets('Does not contain on all columns keeps the rows where no '
      'column contains the search', (tester) async {
    await buildGrid(tester);

    expect(filterBy(const TrinaFilterTypeDoesNotContain(), '000'), ['banana']);
    expect(filterBy(const TrinaFilterTypeDoesNotContain(), 'pine'), [
      'apple',
      'banana',
    ]);
  });

  testWidgets('An empty search does not filter out every row', (tester) async {
    await buildGrid(tester);

    expect(filterBy(const TrinaFilterTypeDoesNotContain(), ''), [
      'apple',
      'pineapple',
      'banana',
    ]);
  });

  testWidgets('Both types are offered by default and follow the locale', (
    tester,
  ) async {
    await buildGrid(tester, localeText: const TrinaGridLocaleText.german());

    final filters = stateManager.configuration.columnFilter.filters;

    expect(filters.whereType<TrinaFilterTypeNotEquals>(), hasLength(1));
    expect(filters.whereType<TrinaFilterTypeDoesNotContain>(), hasLength(1));
    expect(const TrinaFilterTypeNotEquals().title, 'Ist ungleich');
    expect(const TrinaFilterTypeDoesNotContain().title, 'Beinhaltet nicht');
  });
}
