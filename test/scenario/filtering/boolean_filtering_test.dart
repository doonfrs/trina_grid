import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trina_grid/src/ui/ui.dart';
import 'package:trina_grid/src/widgets/boolean_column_filter.dart';
import 'package:trina_grid/src/widgets/filter_dropdown_field.dart';
import 'package:trina_grid/trina_grid.dart';

void main() {
  late TrinaGridStateManager stateManager;

  List<TrinaColumn> columns() => [
    TrinaColumn(title: 'Name', field: 'name', type: TrinaColumnType.text()),
    TrinaColumn(
      title: 'Is Active',
      field: 'is_active',
      type: TrinaColumnType.boolean(),
    ),
  ];

  // user0 (true), user1 (false), user2 (true), ... 5 true and 5 false rows.
  List<TrinaRow> rows() => List<TrinaRow>.generate(10, (i) {
    return TrinaRow(
      cells: {
        'name': TrinaCell(value: 'user$i'),
        'is_active': TrinaCell(value: i.isEven),
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

  Finder findBooleanFilterField() {
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

  Future<void> openBooleanFilterMenu(WidgetTester tester) async {
    await tester.tap(findBooleanFilterField());
    await tester.pumpAndSettle();
  }

  testWidgets(
    'A boolean column should render the boolean filter dropdown instead of a text field',
    (WidgetTester tester) async {
      await tester.pumpWidget(buildGrid());
      await tester.pumpAndSettle();

      expect(findBooleanFilterField(), findsOneWidget);
      expect(find.byType(BooleanColumnFilter), findsOneWidget);
      // The text column keeps its text filter.
      expect(findNameFilterTextField(), findsOneWidget);
      // The boolean filter displays ALL by default.
      expect(
        find.descendant(
          of: find.byType(FilterDropdownField),
          matching: find.text('ALL'),
        ),
        findsOneWidget,
      );
    },
  );

  testWidgets('Filtering by True should keep only the active rows', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildGrid());
    await tester.pumpAndSettle();

    await openBooleanFilterMenu(tester);
    await tester.tap(find.text('True'));
    await tester.pumpAndSettle();

    expect(stateManager.refRows.length, 5);
    expect(find.text('user0'), findsOneWidget);
    expect(find.text('user1'), findsNothing);
    expect(
      find.descendant(
        of: find.byType(FilterDropdownField),
        matching: find.text('True'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('Filtering by False should keep only the inactive rows', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildGrid());
    await tester.pumpAndSettle();

    await openBooleanFilterMenu(tester);
    await tester.tap(find.text('False'));
    await tester.pumpAndSettle();

    expect(stateManager.refRows.length, 5);
    expect(find.text('user1'), findsOneWidget);
    expect(find.text('user0'), findsNothing);
  });

  testWidgets('Switching the filter to False after True', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildGrid());
    await tester.pumpAndSettle();

    await openBooleanFilterMenu(tester);
    await tester.tap(find.text('True'));
    await tester.pumpAndSettle();

    await openBooleanFilterMenu(tester);
    await tester.tap(find.text('False'));
    await tester.pumpAndSettle();

    expect(stateManager.refRows.length, 5);
    expect(find.text('user1'), findsOneWidget);
    expect(find.text('user0'), findsNothing);
  });

  testWidgets('Selecting ALL should clear the boolean filter', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildGrid());
    await tester.pumpAndSettle();

    await openBooleanFilterMenu(tester);
    await tester.tap(find.text('True'));
    await tester.pumpAndSettle();
    expect(stateManager.refRows.length, 5);

    await openBooleanFilterMenu(tester);
    await tester.tap(find.text('ALL'));
    await tester.pumpAndSettle();

    expect(stateManager.refRows.length, 10);
    expect(stateManager.filterRows, isEmpty);
  });

  testWidgets(
    'The boolean filter should combine with a text filter on another column',
    (WidgetTester tester) async {
      await tester.pumpWidget(buildGrid());
      await tester.pumpAndSettle();

      await openBooleanFilterMenu(tester);
      await tester.tap(find.text('True'));
      await tester.pumpAndSettle();

      await tester.enterText(findNameFilterTextField(), 'user4');
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // user4 is an even (active) row, so both filters match only it.
      expect(stateManager.refRows.length, 1);
      expect(find.text('user0'), findsNothing);
    },
  );

  testWidgets(
    'An explicit text field delegate should opt out of the boolean dropdown',
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
                  title: 'Is Active',
                  field: 'is_active',
                  type: TrinaColumnType.boolean(),
                  filterWidgetDelegate:
                      const TrinaFilterColumnWidgetDelegate.textField(),
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

      expect(findBooleanFilterField(), findsNothing);
      // Both columns render a text filter now.
      expect(findNameFilterTextField(), findsNWidgets(2));
    },
  );
}
