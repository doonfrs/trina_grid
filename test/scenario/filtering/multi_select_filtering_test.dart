import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trina_grid/src/ui/ui.dart';
import 'package:trina_grid/src/widgets/filter_dropdown_field.dart';
import 'package:trina_grid/src/widgets/multi_select_column_filter.dart';
import 'package:trina_grid/trina_grid.dart';

void main() {
  late TrinaGridStateManager stateManager;

  const hobbies = ['swimming', 'gym', 'reading'];

  List<TrinaColumn> columns() => [
    TrinaColumn(title: 'Name', field: 'name', type: TrinaColumnType.text()),
    TrinaColumn(
      title: 'Hobby',
      field: 'hobby',
      type: TrinaColumnType.select(hobbies),
    ),
  ];

  // user0 (swimming), user1 (gym), user2 (reading), user3 (swimming), ...
  // 3 rows per hobby.
  List<TrinaRow> rows() => List<TrinaRow>.generate(9, (i) {
    return TrinaRow(
      cells: {
        'name': TrinaCell(value: 'user$i'),
        'hobby': TrinaCell(value: hobbies[i % 3]),
      },
    );
  });

  Widget buildGrid() {
    return MaterialApp(
      home: Material(
        child: TrinaGrid(
          columns: columns(),
          rows: rows(),
          onLoaded: (TrinaGridOnLoadedEvent event) {
            stateManager = event.stateManager;
            stateManager.setShowColumnFilter(true);
          },
        ),
      ),
    );
  }

  Finder findMultiSelectFilterField() {
    return find.descendant(
      of: find.byType(TrinaColumnFilter),
      matching: find.byType(FilterDropdownField),
    );
  }

  Finder findNameFilterTextField() {
    return find.descendant(
      of: find.byType(TrinaColumnFilter),
      matching: find.byType(TextField),
    );
  }

  Future<void> openHobbyFilterMenu(WidgetTester tester) async {
    await tester.tap(findMultiSelectFilterField());
    await tester.pumpAndSettle();
  }

  /// Taps a hobby checkbox in the open dropdown menu.
  ///
  /// The hobby text is also rendered by the grid cells, and the menu is
  /// rendered on top of them, so the last match is the menu item.
  Future<void> tapHobbyInMenu(WidgetTester tester, String hobby) async {
    await tester.tap(find.text(hobby).last);
    await tester.pumpAndSettle();
  }

  testWidgets(
    'A select column should render the multi-select filter instead of a text field',
    (WidgetTester tester) async {
      await tester.pumpWidget(buildGrid());
      await tester.pumpAndSettle();

      expect(find.byType(MultiSelectColumnFilter), findsOneWidget);
      expect(findNameFilterTextField(), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(FilterDropdownField),
          matching: find.text('ALL'),
        ),
        findsOneWidget,
      );
    },
  );

  testWidgets('Checking one item should filter to its rows and stay open', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildGrid());
    await tester.pumpAndSettle();

    await openHobbyFilterMenu(tester);
    await tapHobbyInMenu(tester, 'swimming');

    expect(stateManager.refRows.length, 3);
    expect(find.text('user0'), findsOneWidget);
    expect(find.text('user1'), findsNothing);
    // The menu stays open after a toggle.
    expect(find.text('Select all'), findsOneWidget);
  });

  testWidgets('Checking more items should filter to the union of the rows', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildGrid());
    await tester.pumpAndSettle();

    await openHobbyFilterMenu(tester);
    await tapHobbyInMenu(tester, 'swimming');
    await tapHobbyInMenu(tester, 'gym');

    expect(stateManager.refRows.length, 6);
    expect(find.text('user0'), findsOneWidget);
    expect(find.text('user1'), findsOneWidget);
    expect(find.text('user2'), findsNothing);
  });

  testWidgets('Unchecking every item should clear the filter', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildGrid());
    await tester.pumpAndSettle();

    await openHobbyFilterMenu(tester);
    await tapHobbyInMenu(tester, 'swimming');
    expect(stateManager.refRows.length, 3);

    await tapHobbyInMenu(tester, 'swimming');

    expect(stateManager.refRows.length, 9);
    expect(stateManager.filterRows, isEmpty);
  });

  testWidgets('Select all should filter to every row', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildGrid());
    await tester.pumpAndSettle();

    await openHobbyFilterMenu(tester);
    await tester.tap(find.text('Select all'));
    await tester.pumpAndSettle();

    expect(stateManager.refRows.length, 9);
    expect(stateManager.filterRows, isNotEmpty);
  });

  testWidgets(
    'Tapping select all when everything is selected should clear the filter',
    (WidgetTester tester) async {
      await tester.pumpWidget(buildGrid());
      await tester.pumpAndSettle();

      await openHobbyFilterMenu(tester);
      await tester.tap(find.text('Select all'));
      await tester.pumpAndSettle();
      expect(stateManager.refRows.length, 9);

      await tester.tap(find.text('Select all'));
      await tester.pumpAndSettle();

      expect(stateManager.refRows.length, 9);
      expect(stateManager.filterRows, isEmpty);
    },
  );

  testWidgets('The field clear button should clear the filter', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildGrid());
    await tester.pumpAndSettle();

    await openHobbyFilterMenu(tester);
    await tapHobbyInMenu(tester, 'gym');
    // Close the menu to reach the field clear button.
    await tester.tap(findMultiSelectFilterField());
    await tester.pumpAndSettle();
    expect(stateManager.refRows.length, 3);

    await tester.tap(find.byIcon(Icons.clear));
    await tester.pumpAndSettle();

    expect(stateManager.refRows.length, 9);
    expect(stateManager.filterRows, isEmpty);
  });

  testWidgets(
    'The multi-select filter should combine with a text filter on another column',
    (WidgetTester tester) async {
      await tester.pumpWidget(buildGrid());
      await tester.pumpAndSettle();

      await openHobbyFilterMenu(tester);
      await tapHobbyInMenu(tester, 'gym');

      // The checkbox menu keeps the focus, so tapping the text field first
      // closes it (consumed outside tap) and the second tap focuses it.
      final textField = findNameFilterTextField();
      await tester.tap(textField);
      await tester.pumpAndSettle();
      await tester.tap(textField);
      await tester.pumpAndSettle();

      await tester.enterText(textField, 'user2');
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // user2 has hobby 'reading', so combined with 'gym' nothing matches.
      expect(stateManager.refRows.length, 0);

      await tester.enterText(findNameFilterTextField(), 'user1');
      await tester.pumpAndSettle(const Duration(seconds: 1));

      expect(stateManager.refRows.length, 1);
      expect(stateManager.refRows.first.cells['name']!.value, 'user1');
    },
  );

  testWidgets(
    'A select column with enableColumnFilter false should keep the text filter',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: TrinaGrid(
              columns: [
                TrinaColumn(
                  title: 'Name',
                  field: 'name',
                  type: TrinaColumnType.text(),
                ),
                TrinaColumn(
                  title: 'Hobby',
                  field: 'hobby',
                  type: TrinaColumnType.select(
                    hobbies,
                    enableColumnFilter: false,
                  ),
                ),
              ],
              rows: rows(),
              onLoaded: (TrinaGridOnLoadedEvent event) {
                stateManager = event.stateManager;
                stateManager.setShowColumnFilter(true);
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(MultiSelectColumnFilter), findsNothing);
      expect(findNameFilterTextField(), findsNWidgets(2));
    },
  );

  testWidgets(
    'A multiSelect delegate should force the checkbox filter on a text column',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: TrinaGrid(
              columns: [
                TrinaColumn(
                  title: 'Name',
                  field: 'name',
                  type: TrinaColumnType.text(),
                  filterWidgetDelegate:
                      const TrinaFilterColumnWidgetDelegate.multiSelect(
                        multiSelectItems: ['user0', 'user1'],
                      ),
                ),
                TrinaColumn(
                  title: 'Hobby',
                  field: 'hobby',
                  type: TrinaColumnType.select(hobbies),
                ),
              ],
              rows: rows(),
              onLoaded: (TrinaGridOnLoadedEvent event) {
                stateManager = event.stateManager;
                stateManager.setShowColumnFilter(true);
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // The name column uses the forced multi-select filter...
      expect(find.byType(MultiSelectColumnFilter), findsNWidgets(2));

      // ...and filtering through it works.
      await tester.tap(
        find
            .descendant(
              of: find.byType(MultiSelectColumnFilter),
              matching: find.byType(FilterDropdownField),
            )
            .first,
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('user0').last);
      await tester.pumpAndSettle();

      expect(stateManager.refRows.length, 1);
      expect(stateManager.refRows.first.cells['name']!.value, 'user0');
    },
  );
}
