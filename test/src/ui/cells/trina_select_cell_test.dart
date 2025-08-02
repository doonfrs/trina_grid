import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trina_grid/src/ui/cells/trina_select_cell.dart';
import 'package:trina_grid/src/ui/widgets/trina_select_menu.dart';
import 'package:trina_grid/trina_grid.dart';

const selectItems = ['a', 'b', 'c'];

void main() {
  late TrinaCell cell;
  late TrinaColumn column;

  Future<void> buildCellAndEdit(
    WidgetTester tester, {
    String? initialCellValue,
    List<String> items = selectItems,
    IconData? popupIcon = Icons.arrow_drop_down,
    bool enableAutoEditing = true,
    bool enableSearch = false,
    bool enableFiltering = false,
  }) async {
    column = TrinaColumn(
      title: 'column title',
      field: 'column_field_name',
      enableAutoEditing: enableAutoEditing,
      type: TrinaColumnType.select(
        items,
        popupIcon: popupIcon,
        enableMenuSearch: enableSearch,
        enableMenuFiltering: enableFiltering,
      ),
    );

    cell = TrinaCell(value: initialCellValue ?? items.first);

    final TrinaRow row = TrinaRow(cells: {column.field: cell});

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TrinaGrid(
            columns: [column],
            rows: [row],
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    await tester.tap(find.text(cell.value));
    await tester.pump();
  }

  Future<void> openPopup(WidgetTester tester) async {
    await tester.tap(find.text(cell.value));
    await tester.pumpAndSettle();
  }

  group('Search Functionality', () {
    final searchFieldFinder = find.byWidgetPredicate((widget) =>
        widget is TextField && widget.decoration?.hintText == 'Search...');

    testWidgets('should filter items based on search text', (tester) async {
      await buildCellAndEdit(tester, enableSearch: true);
      await openPopup(tester);

      await tester.enterText(searchFieldFinder, 'a');
      await tester.pumpAndSettle();

      expect(find.widgetWithText(MenuItemButton, 'a'), findsOneWidget);
      expect(find.widgetWithText(MenuItemButton, 'b'), findsNothing);
      expect(find.widgetWithText(MenuItemButton, 'c'), findsNothing);
    });

    testWidgets('should filter items case-insensitively', (tester) async {
      await buildCellAndEdit(tester, enableSearch: true);
      await openPopup(tester);

      await tester.enterText(searchFieldFinder, 'A'); // Uppercase 'A'
      await tester.pumpAndSettle();

      expect(find.widgetWithText(MenuItemButton, 'a'), findsOneWidget);
      expect(find.widgetWithText(MenuItemButton, 'b'), findsNothing);
    });

    testWidgets('should display "No matches" when no items match search',
        (tester) async {
      await buildCellAndEdit(tester, enableSearch: true);
      await openPopup(tester);

      await tester.enterText(searchFieldFinder, 'xyz');
      await tester.pumpAndSettle();

      expect(find.text('No matches'), findsOneWidget);
      expect(find.widgetWithText(MenuItemButton, 'a'), findsNothing);
    });

    testWidgets('should show all items when search is cleared', (tester) async {
      await buildCellAndEdit(tester, enableSearch: true);
      await openPopup(tester);

      await tester.enterText(searchFieldFinder, 'a');
      await tester.pumpAndSettle();
      expect(find.widgetWithText(MenuItemButton, 'a'), findsOneWidget);
      expect(find.widgetWithText(MenuItemButton, 'b'), findsNothing);
      expect(find.widgetWithText(MenuItemButton, 'c'), findsNothing);

      await tester.enterText(searchFieldFinder, ''); // Clear search

      await tester.pumpAndSettle(); // Wait for search debounce
      await tester.pumpAndSettle(); // wait for items to be shown

      expect(find.widgetWithText(MenuItemButton, 'a'), findsOneWidget);
      expect(find.widgetWithText(MenuItemButton, 'b'), findsOneWidget);
      expect(find.widgetWithText(MenuItemButton, 'c'), findsOneWidget);
    });
  });

  group('Suffix icon rendering', () {
    testWidgets('Default dropdown icon should be rendered', (tester) async {
      await buildCellAndEdit(tester);
      expect(find.byIcon(Icons.arrow_drop_down), findsOneWidget);
    });

    testWidgets('Custom icon should be rendered', (tester) async {
      await buildCellAndEdit(tester, popupIcon: Icons.add);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('When popupIcon is null, icon should not be rendered',
        (tester) async {
      await buildCellAndEdit(tester, popupIcon: null);
      expect(
        find.descendant(
          of: find.byType(TrinaSelectCell),
          matching: find.byType(Icon),
        ),
        findsNothing,
      );
    });
  });

  group('Popup interaction', () {
    testWidgets('Pressing F2 should open the popup', (tester) async {
      await buildCellAndEdit(tester);
      await tester.sendKeyEvent(LogicalKeyboardKey.f2);
      await tester.pumpAndSettle();
      expect(find.byType(MenuAnchor), findsOneWidget);
    });

    testWidgets(
        'After closing popup with ESC and pressing F2 again, popup should reopen',
        (tester) async {
      await buildCellAndEdit(tester);

      // Open popup
      await tester.sendKeyEvent(LogicalKeyboardKey.f2);
      await tester.pumpAndSettle();
      expect(find.byType(TrinaSelectMenu), findsOneWidget);

      // Close popup with escape
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.byType(TrinaSelectMenu), findsNothing);

      // Reopen popup
      await tester.sendKeyEvent(LogicalKeyboardKey.f2);
      await tester.pumpAndSettle();
      expect(find.byType(TrinaSelectMenu), findsOneWidget);
    });

    testWidgets(
      'After selecting an item with arrow keys and enter, value should be updated',
      (tester) async {
        await buildCellAndEdit(tester);
        expect(find.byType(TrinaSelectMenu), findsNothing);

        // Open popup
        await tester.sendKeyEvent(LogicalKeyboardKey.f2);
        await tester.pumpAndSettle();
        expect(find.byType(TrinaSelectMenu), findsOneWidget);

        // Select next item and press enter
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pumpAndSettle();

        // Verify popup is closed and value is updated
        expect(find.byType(TrinaSelectMenu), findsNothing);
        expect(cell.value, selectItems[1]);
      },
    );
  });
}
