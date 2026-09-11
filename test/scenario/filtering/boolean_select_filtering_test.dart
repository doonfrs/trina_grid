import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trina_grid/src/ui/ui.dart';
import 'package:trina_grid/src/widgets/boolean_column_filter.dart';
import 'package:trina_grid/src/widgets/filter_dropdown_field.dart';
import 'package:trina_grid/trina_grid.dart';

void main() {
  late TrinaGridStateManager stateManager;

  // The default boolean column renders Yes / No, so the dropdown options of
  // the booleanSelect delegate are labeled the same way.
  const trueLabel = 'Yes';
  const falseLabel = 'No';

  List<TrinaColumn> columns({
    String trueText = trueLabel,
    String falseText = falseLabel,
  }) => [
    TrinaColumn(title: 'Name', field: 'name', type: TrinaColumnType.text()),
    TrinaColumn(
      title: 'Is Active',
      field: 'is_active',
      type: TrinaColumnType.boolean(trueText: trueText, falseText: falseText),
      filterWidgetDelegate:
          const TrinaFilterColumnWidgetDelegate.booleanSelect(),
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

  Widget buildGrid({List<TrinaColumn>? columns}) {
    return MaterialApp(
      home: Material(
        child: TrinaGrid(
          columns: columns ?? [],
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

  Finder findBooleanFilterFieldText(String text) {
    return find.descendant(
      of: find.byType(FilterDropdownField),
      matching: find.text(text),
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

  /// Taps an option in the open dropdown menu.
  ///
  /// The option labels are also rendered by the boolean cells (and ALL by the
  /// filter field), and the menu is rendered on top of them, so the last
  /// match is the menu item.
  Future<void> tapMenuOption(WidgetTester tester, String label) async {
    await tester.tap(find.text(label).last);
    await tester.pumpAndSettle();
  }

  testWidgets(
    'A boolean column with the booleanSelect delegate should render the dropdown instead of a text field',
    (WidgetTester tester) async {
      await tester.pumpWidget(buildGrid(columns: columns()));
      await tester.pumpAndSettle();

      expect(findBooleanFilterField(), findsOneWidget);
      expect(find.byType(BooleanColumnFilter), findsOneWidget);
      // The text column keeps its text filter.
      expect(findNameFilterTextField(), findsOneWidget);
      // The boolean filter displays ALL by default.
      expect(findBooleanFilterFieldText('ALL'), findsOneWidget);
    },
  );

  testWidgets(
    'The dropdown options should be labeled with the column trueText / falseText',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        buildGrid(
          columns: columns(trueText: 'Active', falseText: 'Inactive'),
        ),
      );
      await tester.pumpAndSettle();

      await openBooleanFilterMenu(tester);

      expect(find.text('True'), findsNothing);
      expect(find.text('False'), findsNothing);

      await tapMenuOption(tester, 'Active');

      expect(findBooleanFilterFieldText('Active'), findsOneWidget);
      expect(stateManager.refRows.length, 5);
      expect(find.text('user0'), findsOneWidget);
      expect(find.text('user1'), findsNothing);
    },
  );

  testWidgets('Filtering by the true option should keep only the active rows', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildGrid(columns: columns()));
    await tester.pumpAndSettle();

    await openBooleanFilterMenu(tester);
    await tapMenuOption(tester, trueLabel);

    expect(stateManager.refRows.length, 5);
    expect(find.text('user0'), findsOneWidget);
    expect(find.text('user1'), findsNothing);
    expect(findBooleanFilterFieldText(trueLabel), findsOneWidget);
  });

  testWidgets(
    'Filtering by the false option should keep only the inactive rows',
    (WidgetTester tester) async {
      await tester.pumpWidget(buildGrid(columns: columns()));
      await tester.pumpAndSettle();

      await openBooleanFilterMenu(tester);
      await tapMenuOption(tester, falseLabel);

      expect(stateManager.refRows.length, 5);
      expect(find.text('user1'), findsOneWidget);
      expect(find.text('user0'), findsNothing);
    },
  );

  testWidgets('Switching the filter to false after true', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildGrid(columns: columns()));
    await tester.pumpAndSettle();

    await openBooleanFilterMenu(tester);
    await tapMenuOption(tester, trueLabel);

    await openBooleanFilterMenu(tester);
    await tapMenuOption(tester, falseLabel);

    expect(stateManager.refRows.length, 5);
    expect(find.text('user1'), findsOneWidget);
    expect(find.text('user0'), findsNothing);
  });

  testWidgets('Selecting ALL should clear the boolean filter', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildGrid(columns: columns()));
    await tester.pumpAndSettle();

    await openBooleanFilterMenu(tester);
    await tapMenuOption(tester, trueLabel);
    expect(stateManager.refRows.length, 5);

    await openBooleanFilterMenu(tester);
    await tapMenuOption(tester, 'ALL');

    expect(stateManager.refRows.length, 10);
    expect(stateManager.filterRows, isEmpty);
  });

  testWidgets(
    'The boolean filter should combine with a text filter on another column',
    (WidgetTester tester) async {
      await tester.pumpWidget(buildGrid(columns: columns()));
      await tester.pumpAndSettle();

      await openBooleanFilterMenu(tester);
      await tapMenuOption(tester, trueLabel);

      await tester.enterText(findNameFilterTextField(), 'user4');
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // user4 is an even (active) row, so both filters match only it.
      expect(stateManager.refRows.length, 1);
      expect(find.text('user0'), findsNothing);
    },
  );

  testWidgets(
    'A boolean column without the delegate should keep the text filter',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        buildGrid(
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
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(findBooleanFilterField(), findsNothing);
      expect(find.byType(BooleanColumnFilter), findsNothing);
      // Both columns render a text filter.
      expect(findNameFilterTextField(), findsNWidgets(2));
    },
  );
}
