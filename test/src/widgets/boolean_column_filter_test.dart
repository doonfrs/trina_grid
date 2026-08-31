import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:trina_grid/src/widgets/boolean_column_filter.dart';
import 'package:trina_grid/src/widgets/filter_dropdown_field.dart';
import 'package:trina_grid/trina_grid.dart';

import '../../mock/shared_mocks.mocks.dart';

void main() {
  late MockTrinaGridStateManager stateManager;
  late TrinaColumn column;
  late FocusNode focusNode;
  late MenuController menuController;
  late List<String> changedValues;

  const allLabel = 'ALL';
  const trueLabel = 'True';
  const falseLabel = 'False';

  Future<void> buildFilter(
    WidgetTester tester, {
    String filterValue = '',
    bool enabled = true,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 200,
            height: 45,
            child: BooleanColumnFilter(
              stateManager: stateManager,
              column: column,
              focusNode: focusNode,
              menuController: menuController,
              enabled: enabled,
              filterValue: filterValue,
              allLabel: allLabel,
              trueLabel: trueLabel,
              falseLabel: falseLabel,
              onChanged: changedValues.add,
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
  }

  Future<void> openMenu(WidgetTester tester) async {
    await tester.tap(find.byType(FilterDropdownField));
    await tester.pumpAndSettle();
  }

  setUp(() {
    stateManager = MockTrinaGridStateManager();
    const configuration = TrinaGridConfiguration();
    when(stateManager.configuration).thenReturn(configuration);
    when(stateManager.style).thenReturn(configuration.style);

    column = TrinaColumn(
      title: 'is_active',
      field: 'is_active',
      type: TrinaColumnType.boolean(),
      width: 150,
    );
    focusNode = FocusNode();
    menuController = MenuController();
    changedValues = [];
  });

  tearDown(() {
    focusNode.dispose();
  });

  testWidgets('Should display ALL when there is no filter', (tester) async {
    await buildFilter(tester);

    expect(
      find.descendant(
        of: find.byType(FilterDropdownField),
        matching: find.text(allLabel),
      ),
      findsOneWidget,
    );
  });

  testWidgets('Should display True / False for the matching filter value', (
    tester,
  ) async {
    await buildFilter(tester, filterValue: 'true');

    expect(
      find.descendant(
        of: find.byType(FilterDropdownField),
        matching: find.text(trueLabel),
      ),
      findsOneWidget,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 200,
            height: 45,
            child: BooleanColumnFilter(
              stateManager: stateManager,
              column: column,
              focusNode: focusNode,
              menuController: menuController,
              enabled: true,
              filterValue: 'false',
              allLabel: allLabel,
              trueLabel: trueLabel,
              falseLabel: falseLabel,
              onChanged: changedValues.add,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.descendant(
        of: find.byType(FilterDropdownField),
        matching: find.text(falseLabel),
      ),
      findsOneWidget,
    );
  });

  testWidgets('Tapping the field should call setKeepFocus with false', (
    tester,
  ) async {
    await buildFilter(tester);

    await tester.tap(find.byType(FilterDropdownField));
    await tester.pump();

    verify(stateManager.setKeepFocus(false)).called(1);
  });

  testWidgets('Opening the menu should show ALL, True and False options', (
    tester,
  ) async {
    await buildFilter(tester);

    await openMenu(tester);

    expect(find.text(trueLabel), findsOneWidget);
    expect(find.text(falseLabel), findsOneWidget);
    // The field itself also displays ALL.
    expect(find.text(allLabel), findsNWidgets(2));
  });

  testWidgets('Selecting True should emit true', (tester) async {
    await buildFilter(tester);

    await openMenu(tester);
    await tester.tap(find.text(trueLabel));
    await tester.pumpAndSettle();

    expect(changedValues, ['true']);
    // The menu closes after a selection.
    expect(find.text(falseLabel), findsNothing);
  });

  testWidgets('Selecting False should emit false', (tester) async {
    await buildFilter(tester);

    await openMenu(tester);
    await tester.tap(find.text(falseLabel));
    await tester.pumpAndSettle();

    expect(changedValues, ['false']);
  });

  testWidgets('Selecting ALL should emit an empty value to clear the filter', (
    tester,
  ) async {
    await buildFilter(tester, filterValue: 'true');

    await openMenu(tester);
    await tester.tap(find.text(allLabel).last);
    await tester.pumpAndSettle();

    expect(changedValues, ['']);
  });

  testWidgets('The current value option should be checked in the menu', (
    tester,
  ) async {
    await buildFilter(tester, filterValue: 'false');

    await openMenu(tester);

    final checkedItem = find.ancestor(
      of: find.byIcon(Icons.check),
      matching: find.byType(MenuItemButton),
    );

    expect(checkedItem, findsOneWidget);
    expect(
      find.descendant(of: checkedItem, matching: find.text(falseLabel)),
      findsOneWidget,
    );
  });

  testWidgets('A disabled filter should not open the menu on tap', (
    tester,
  ) async {
    await buildFilter(tester, enabled: false);

    await tester.tap(find.byType(FilterDropdownField), warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(menuController.isOpen, isFalse);
    expect(find.text(trueLabel), findsNothing);
    expect(changedValues, isEmpty);
  });
}
