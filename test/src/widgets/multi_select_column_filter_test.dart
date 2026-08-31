import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:trina_grid/src/widgets/filter_dropdown_field.dart';
import 'package:trina_grid/src/widgets/multi_select_column_filter.dart';
import 'package:trina_grid/trina_grid.dart';

import '../../mock/shared_mocks.mocks.dart';

void main() {
  late MockTrinaGridStateManager stateManager;
  late TrinaColumn column;
  late FocusNode focusNode;
  late MenuController menuController;
  late List<String> changedValues;

  const items = ['swimming', 'gym', 'reading'];
  const allLabel = 'ALL';
  const selectAllLabel = 'Select all';

  Future<void> buildFilter(
    WidgetTester tester, {
    String filterValue = '',
    bool enabled = true,
    bool caseSensitive = false,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 200,
            height: 45,
            child: MultiSelectColumnFilter(
              stateManager: stateManager,
              column: column,
              focusNode: focusNode,
              menuController: menuController,
              enabled: enabled,
              filterValue: filterValue,
              items: items,
              caseSensitive: caseSensitive,
              allLabel: allLabel,
              selectAllLabel: selectAllLabel,
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
      title: 'hobby',
      field: 'hobby',
      type: TrinaColumnType.select(items),
      width: 150,
    );
    focusNode = FocusNode();
    menuController = MenuController();
    changedValues = [];
  });

  tearDown(() {
    focusNode.dispose();
  });

  testWidgets('Should display ALL and no clear button without a filter', (
    tester,
  ) async {
    await buildFilter(tester);

    expect(find.text(allLabel), findsOneWidget);
    expect(find.byIcon(Icons.clear), findsNothing);
  });

  testWidgets(
    'Should display the selected items comma separated in the field',
    (tester) async {
      await buildFilter(tester, filterValue: 'gym\nswimming');

      expect(find.text('swimming, gym'), findsOneWidget);
    },
  );

  testWidgets('Opening the menu should show the select all toggle and items', (
    tester,
  ) async {
    await buildFilter(tester);

    await openMenu(tester);

    expect(find.text(selectAllLabel), findsOneWidget);
    // 3 item checkboxes + 1 select all checkbox.
    expect(find.byType(Checkbox), findsNWidgets(4));
    expect(menuController.isOpen, isTrue);
  });

  testWidgets('Checking an item should emit it and keep the menu open', (
    tester,
  ) async {
    await buildFilter(tester);

    await openMenu(tester);
    await tester.tap(find.text('swimming'));
    await tester.pumpAndSettle();

    expect(changedValues, ['swimming']);
    expect(menuController.isOpen, isTrue);
    expect(find.text(selectAllLabel), findsOneWidget);
  });

  testWidgets('Checking more items should emit them joined by a newline', (
    tester,
  ) async {
    await buildFilter(tester, filterValue: 'swimming');

    await openMenu(tester);
    await tester.tap(find.text('gym'));
    await tester.pumpAndSettle();

    // The emitted value preserves the items order.
    expect(changedValues, ['swimming\ngym']);
  });

  testWidgets('Unchecking the last checked item should emit an empty value', (
    tester,
  ) async {
    await buildFilter(tester, filterValue: 'swimming');

    await openMenu(tester);
    // .last : the field also displays the current selection text.
    await tester.tap(find.text('swimming').last);
    await tester.pumpAndSettle();

    expect(changedValues, ['']);
  });

  testWidgets('Select all should emit every item', (tester) async {
    await buildFilter(tester);

    await openMenu(tester);
    await tester.tap(find.text(selectAllLabel));
    await tester.pumpAndSettle();

    expect(changedValues, [items.join('\n')]);
  });

  testWidgets('Tapping select all when everything is selected should clear', (
    tester,
  ) async {
    await buildFilter(tester, filterValue: items.join('\n'));

    await openMenu(tester);
    await tester.tap(find.text(selectAllLabel));
    await tester.pumpAndSettle();

    expect(changedValues, ['']);
  });

  testWidgets('The select all checkbox should be tristate for a selection', (
    tester,
  ) async {
    await buildFilter(tester, filterValue: 'swimming');

    await openMenu(tester);

    final tristateCheckbox = find.byWidgetPredicate(
      (widget) => widget is Checkbox && widget.tristate,
    );

    expect(tristateCheckbox, findsOneWidget);
    expect(
      tester.widget<Checkbox>(tristateCheckbox).value,
      isNull,
      reason: 'a partial selection should render the tristate as null',
    );
  });

  testWidgets('The clear button should emit an empty value', (tester) async {
    await buildFilter(tester, filterValue: 'gym');

    await tester.tap(find.byIcon(Icons.clear));
    await tester.pumpAndSettle();

    expect(changedValues, ['']);
  });

  testWidgets(
    'A case insensitive filter value should check the matching item',
    (tester) async {
      await buildFilter(tester, filterValue: 'SWIMMING');

      await openMenu(tester);

      final checked = find.byWidgetPredicate(
        (widget) => widget is Checkbox && widget.value == true,
      );

      expect(checked, findsOneWidget);
    },
  );

  testWidgets(
    'A case sensitive filter value should not check a differently cased item',
    (tester) async {
      await buildFilter(tester, filterValue: 'SWIMMING', caseSensitive: true);

      await openMenu(tester);

      final checked = find.byWidgetPredicate(
        (widget) => widget is Checkbox && widget.value == true,
      );

      expect(checked, findsNothing);
    },
  );

  testWidgets('A disabled filter should not open the menu on tap', (
    tester,
  ) async {
    await buildFilter(tester, enabled: false);

    await tester.tap(find.byType(FilterDropdownField), warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(menuController.isOpen, isFalse);
    expect(find.text(selectAllLabel), findsNothing);
    expect(changedValues, isEmpty);
  });
}
