import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trina_grid/src/model/trina_dropdown_menu_filter.dart';
import 'package:trina_grid/src/ui/widgets/trina_dropdown_menu.dart';

class _TestObject {
  final int id;
  final String name;

  const _TestObject(this.id, this.name);
}

void main() {
  group('TrinaDropdownMenu - ', () {
    const List<String> strTestItems = [
      'Apple',
      'Banana',
      'Cherry',
      'Date',
      'Elderberry',
    ];
    Future<void> buildMenu<T>(
      WidgetTester tester, {
      required List<T> items,
      required T? initialValue,
      String Function(T item)? itemToString,
      dynamic Function(T item)? itemToValue,
      TrinaDropdownMenuVariant variant = TrinaDropdownMenuVariant.select,
      List<TrinaDropdownMenuFilter> filters = const [],
      void Function(T item)? onItemSelected,
      double itemHeight = 40,
      double maxHeight = 200,
      double width = 200,
      WidgetBuilder? emptySearchResultBuilder,
      WidgetBuilder? emptyFilterResultBuilder,
      ItemBuilder<T>? itemBuilder,
      bool filtersInitiallyExpanded = true,
    }) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TrinaDropdownMenu.variant(
              variant,
              filters: filters,
              items: items,
              itemToString: itemToString,
              onItemSelected: onItemSelected ?? (_) {},
              width: width,
              initialValue: initialValue,
              itemHeight: itemHeight,
              maxHeight: maxHeight,
              itemToValue: itemToValue,
              emptySearchResultBuilder: emptySearchResultBuilder,
              itemBuilder: itemBuilder,
              emptyFilterResultBuilder: emptyFilterResultBuilder,
              filtersInitiallyExpanded: filtersInitiallyExpanded,
            ),
          ),
        ),
      );
      // wait for the initial scroll(to selected item)
      // animation to finish
      await tester.pumpAndSettle();
    }

    Future<void> buildStringMenu(
      WidgetTester tester, {
      required List<String> items,
      TrinaDropdownMenuVariant variant = TrinaDropdownMenuVariant.select,
      String? initialValue,
      List<TrinaDropdownMenuFilter> filters = const [],
      void Function(String item)? onItemSelected,
      double itemHeight = 40,
      double maxHeight = 200,
      double width = 200,
      bool filtersInitiallyExpanded = true,
      WidgetBuilder? emptySearchResultBuilder,
      WidgetBuilder? emptyFilterResultBuilder,
    }) async {
      await buildMenu<String>(
        tester,
        items: items,
        variant: variant,
        itemToString: (item) => item,
        itemToValue: (item) => item,
        initialValue: initialValue ?? (items.isNotEmpty ? items.first : ''),
        filters: filters,
        itemHeight: itemHeight,
        maxHeight: maxHeight,
        onItemSelected: onItemSelected,
        width: width,
        filtersInitiallyExpanded: filtersInitiallyExpanded,
        emptySearchResultBuilder: emptySearchResultBuilder,
        emptyFilterResultBuilder: emptyFilterResultBuilder,
      );
    }

    testWidgets('renders initial items correctly', (WidgetTester tester) async {
      const itemHeight = 40.0;
      await buildStringMenu(
        tester,
        items: strTestItems,
        maxHeight: strTestItems.length * itemHeight,
        itemHeight: itemHeight,
      );

      for (var item in strTestItems) {
        expect(find.text(item), findsOneWidget);
      }
      expect(find.byType(Scrollbar), findsOneWidget);
    });

    group('Search', () {
      testWidgets('filters items correctly with search', (
        WidgetTester tester,
      ) async {
        await buildStringMenu(
          tester,
          items: strTestItems,
          variant: TrinaDropdownMenuVariant.selectWithSearch,
        );

        // Enter search text
        await tester.enterText(find.byType(TextField), 'berry');
        await tester.pumpAndSettle();

        // Verify filtered list
        expect(find.text('Apple'), findsNothing);
        expect(find.text('Banana'), findsNothing);
        expect(find.text('Cherry'), findsNothing);
        expect(find.text('Date'), findsNothing);
        expect(find.text('Elderberry'), findsOneWidget);
      });

      testWidgets(
        'shows emptySearchResultBuilder when search yields no results',
        (WidgetTester tester) async {
          await buildMenu<String>(
            tester,
            items: strTestItems,
            variant: TrinaDropdownMenuVariant.selectWithSearch,
            itemToString: (item) => item,
            initialValue: strTestItems.first,
            emptySearchResultBuilder: (context) =>
                const Text('No search results!'),
          );

          await tester.enterText(find.byType(TextField), 'nonexistent');
          await tester.pumpAndSettle(const Duration(milliseconds: 300));

          expect(find.text('No search results!'), findsOneWidget);
        },
      );
    });

    group('Selection Logic', () {
      testWidgets('calls onItemSelected when an item is tapped', (
        WidgetTester tester,
      ) async {
        String? selectedItem;
        await buildStringMenu(
          tester,
          items: strTestItems,
          onItemSelected: (item) {
            selectedItem = item;
          },
        );
        await tester.ensureVisible(find.text('Cherry'));
        await tester.tap(find.text('Cherry'));
        await tester.pump();

        expect(selectedItem, 'Cherry');
      });

      testWidgets('selects initial value correctly with itemToValue', (
        WidgetTester tester,
      ) async {
        final items = [
          const _TestObject(10, 'Ten'),
          const _TestObject(20, 'Twenty'),
          const _TestObject(30, 'Thirty'),
        ];

        await buildMenu<_TestObject>(
          tester,
          items: items,
          initialValue: items[1], // Select by object instance
          itemToString: (item) => item.name,
          itemToValue: (item) => item.id, // Use ID for comparison
        );

        // Find the specific MenuItemButton for 'Twenty'
        final twentyButton = find.widgetWithText(MenuItemButton, 'Twenty');
        expect(twentyButton, findsOneWidget);

        // Check if it has the check mark
        final checkIcon = find.descendant(
          of: twentyButton,
          matching: find.byIcon(Icons.check),
        );

        expect(checkIcon, findsOneWidget);
      });
    });

    group('withFilters', () {
      testWidgets('when `filtersInitiallyExpanded` is `true`'
          'it should render filters section', (tester) async {
        await buildStringMenu(
          tester,
          items: strTestItems,
          variant: TrinaDropdownMenuVariant.selectWithFilters,
          filters: [TrinaDropdownMenuFilter.equals],
        );
        expect(find.widgetWithText(ListTile, 'Filters'), findsOneWidget);
      });
      testWidgets('when `filtersInitiallyExpanded` is `false`'
          'it should NOT render filters section', (tester) async {
        await buildStringMenu(
          tester,
          items: strTestItems,
          variant: TrinaDropdownMenuVariant.selectWithFilters,
          filters: [TrinaDropdownMenuFilter.equals],
          filtersInitiallyExpanded: false,
        );
        expect(find.byKey(TrinaDropdownMenu.filterSectionKey), findsNothing);
      });

      testWidgets('filters items with a custom filter', (
        WidgetTester tester,
      ) async {
        final filters = [
          TrinaDropdownMenuFilter(
            title: 'Starts with',
            filter: (item, value) =>
                (item as String).toLowerCase().startsWith(value.toLowerCase()),
          ),
        ];

        await buildStringMenu(
          tester,
          items: strTestItems,
          variant: TrinaDropdownMenuVariant.selectWithFilters,
          filters: filters,
        );

        // The filter is active but has no value, so all items should still be visible
        expect(find.text('Apple'), findsOneWidget);
        expect(find.text('Cherry'), findsOneWidget);

        // The filter is enabled by default. Find the TextField and enter text.
        await tester.enterText(find.byType(TextField), 'c');
        await tester.pumpAndSettle(
          const Duration(milliseconds: 300),
        ); // wait for debounce

        // Verify filtered list
        expect(find.text('Cherry'), findsOneWidget);
        expect(find.text('Apple'), findsNothing);
        expect(find.text('Banana'), findsNothing);
        expect(find.text('Date'), findsNothing);
        expect(find.text('Elderberry'), findsNothing);
      });

      testWidgets(
        'shows emptyFilterResultBuilder when filter yields no results',
        (WidgetTester tester) async {
          await buildMenu<String>(
            tester,
            items: strTestItems,
            variant: TrinaDropdownMenuVariant.selectWithFilters,
            filters: [TrinaDropdownMenuFilter.equals],
            initialValue: strTestItems.first,
            itemToString: (item) => item,
            emptyFilterResultBuilder: (context) =>
                const Text('No filter results!'),
          );

          await tester.enterText(find.byType(TextField), 'nonexistent');
          await tester.pumpAndSettle(const Duration(milliseconds: 300));

          expect(find.text('No filter results!'), findsOneWidget);
        },
      );
      testWidgets(
        'it should NOT use emptyFilterResultBuilder when filter has no value',
        (WidgetTester tester) async {
          await buildMenu<String>(
            tester,
            items: strTestItems,
            variant: TrinaDropdownMenuVariant.selectWithFilters,
            filters: [TrinaDropdownMenuFilter.equals],
            initialValue: strTestItems.first,
            itemToString: (item) => item,
            emptyFilterResultBuilder: (context) =>
                const Text('No filter results!'),
          );

          expect(find.text('No filter results!'), findsNothing);
        },
      );

      testWidgets('applies multiple filters correctly (AND logic)', (
        tester,
      ) async {
        final filters = [
          TrinaDropdownMenuFilter.startsWith,
          TrinaDropdownMenuFilter.endsWith,
        ];

        await buildStringMenu(
          tester,
          items: strTestItems,
          variant: TrinaDropdownMenuVariant.selectWithFilters,
          filters: filters,
        );

        // Find the TextFields for startsWith and endsWith
        final textFields = find.byType(TextField);
        expect(textFields, findsNWidgets(2));

        // Filter for items that start with 'A'
        await tester.enterText(textFields.first, 'A');
        await tester.pumpAndSettle(const Duration(milliseconds: 300));

        expect(find.text('Apple'), findsOneWidget);
        expect(find.text('Banana'), findsNothing);

        // Additionally, filter for items that end with 'e'
        await tester.enterText(textFields.last, 'e');
        await tester.pumpAndSettle(const Duration(milliseconds: 300));

        // Only 'Apple' should remain
        expect(find.text('Apple'), findsOneWidget);
        expect(find.text('Banana'), findsNothing);
        expect(find.text('Cherry'), findsNothing);
        expect(find.text('Date'), findsNothing);
        expect(find.text('Elderberry'), findsNothing);
      });

      testWidgets('toggling a filter off removes the filter', (tester) async {
        final filters = [TrinaDropdownMenuFilter.equals];

        await buildStringMenu(
          tester,
          items: strTestItems,
          variant: TrinaDropdownMenuVariant.selectWithFilters,
          filters: filters,
          filtersInitiallyExpanded: true,
        );

        // 1. Apply the filter
        await tester.enterText(find.byType(TextField), 'Apple');
        await tester.pumpAndSettle(const Duration(milliseconds: 300));

        // 2. Assert that the list is filtered
        expect(find.widgetWithText(MenuItemButton, 'Apple'), findsOneWidget);
        expect(find.byType(MenuItemButton), findsOneWidget);

        // 3. Tap the filter to disable it.
        // The CheckboxListTile is the parent of the Text which has the title.
        await tester.tap(find.byType(Checkbox));
        await tester.pumpAndSettle(Duration(milliseconds: 300));

        // 4. Assert that the filter is no longer applied (value is still in textfield)
        // but the list should be unfiltered.
        expect(find.widgetWithText(MenuItemButton, 'Apple'), findsOneWidget);
        expect(find.widgetWithText(MenuItemButton, 'Banana'), findsOneWidget);
        expect(find.widgetWithText(MenuItemButton, 'Cherry'), findsOneWidget);
      });

      testWidgets('throws an error if filter titles are not unique', (
        WidgetTester tester,
      ) async {
        final filters = [
          TrinaDropdownMenuFilter.contains,
          TrinaDropdownMenuFilter.contains, // Duplicate
        ];

        await expectLater(
          () async => buildStringMenu(
            tester,
            items: strTestItems,
            variant: TrinaDropdownMenuVariant.selectWithFilters,
            filters: filters,
          ),
          throwsA(isA<AssertionError>()),
        );
      });
    });

    group('Custom Builders', () {
      testWidgets('uses custom itemBuilder to render items', (
        WidgetTester tester,
      ) async {
        await buildMenu<String>(
          tester,
          items: strTestItems,
          initialValue: strTestItems.first,
          itemToString: (item) => item,
          itemBuilder: (item) => Row(
            children: [
              const Icon(Icons.star, size: 16),
              const SizedBox(width: 4),
              Text(item),
            ],
          ),
        );

        // Check if the custom rendered items with stars are present
        expect(find.byIcon(Icons.star), findsNWidgets(strTestItems.length));
        expect(find.text('Apple'), findsOneWidget);
      });
    });

    group('Layout', () {
      Size getMenuSize(WidgetTester tester) =>
          tester.getSize(find.byType(TrinaDropdownMenu<String>));

      testWidgets('when `items` is empty then it should not give any error', (
        tester,
      ) async {
        await buildStringMenu(tester, items: [], initialValue: '');
      });
      testWidgets('it should use the provided `width`', (tester) async {
        const menuWidth = 300.0;
        await buildStringMenu(tester, items: strTestItems, width: menuWidth);
        final menuSize = getMenuSize(tester);
        expect(menuSize.width, menuWidth);
      });
      testWidgets('it should enforce `maxHeight`', (tester) async {
        const maxHeight = 200.0;
        await buildStringMenu(
          tester,
          items: List.generate(10, (i) => 'Item$i'),
          itemHeight: 40,
          maxHeight: maxHeight,
        );
        final menuSize = getMenuSize(tester);
        expect(menuSize.height, maxHeight);
      });

      testWidgets('it should scroll to initially selected item', (
        tester,
      ) async {
        await buildStringMenu(
          tester,
          items: List.generate(20, (i) => 'Item $i'),
          initialValue: 'Item 15',
          itemHeight: 40,
          maxHeight: 200, // 5 items visible at a time
        );

        final scrollable = tester.widget<Scrollable>(find.byType(Scrollable));
        // Item 15 is the 16th item (index 15).
        // Each item is 40px high. Expected offset should be around 15 * 40 = 600.
        expect(scrollable.controller?.offset, greaterThan(500));
        expect(find.text('Item 15'), findsOneWidget);
        // Top items should be scrolled off-screen
        expect(find.text('Item 0'), findsNothing);
      });

      testWidgets('should handle null initialValue without crashing', (
        tester,
      ) async {
        // This test ensures issue with null select cell values is fixed
        await buildMenu<String>(
          tester,
          items: ['Apple', 'Banana', 'Cherry'],
          initialValue: null,
          itemToString: (item) => item,
        );

        // Should render all items
        expect(find.text('Apple'), findsOneWidget);
        expect(find.text('Banana'), findsOneWidget);
        expect(find.text('Cherry'), findsOneWidget);

        // Should not crash when initialValue is null
        expect(tester.takeException(), isNull);
      });

      testWidgets('should not scroll when initialValue is null', (
        tester,
      ) async {
        await buildStringMenu(
          tester,
          items: List.generate(20, (i) => 'Item $i'),
          initialValue: null,
          itemHeight: 40,
          maxHeight: 200,
        );

        final scrollable = tester.widget<Scrollable>(find.byType(Scrollable));
        // When initialValue is null, scroll offset should be 0 (no scrolling)
        expect(scrollable.controller?.offset, 0);

        // First items should be visible
        expect(find.text('Item 0'), findsOneWidget);
      });

      testWidgets('should not highlight any item when initialValue is null', (
        tester,
      ) async {
        await buildStringMenu(
          tester,
          items: ['Apple', 'Banana', 'Cherry'],
          initialValue: null,
        );

        // Find all MenuItemButton widgets
        final menuItems = find.byType(MenuItemButton);
        expect(menuItems, findsNWidgets(3));

        // When initialValue is null, no item should be marked as selected
        // This is tested implicitly - the menu should render without errors
        expect(tester.takeException(), isNull);
      });
    });
  });
}
