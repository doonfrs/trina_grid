import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trina_grid/trina_grid.dart';
import 'package:trina_grid/src/ui/ui.dart';

import '../../helper/column_helper.dart';
import '../../helper/row_helper.dart';
import '../../helper/test_helper_util.dart';

void main() {
  late List<TrinaColumn> columns;

  late List<TrinaRow> rows;

  late TrinaGridStateManager stateManager;

  setUp(() {
    columns = ColumnHelper.textColumn('column', count: 5);
    rows = [];
  });

  Future<void> buildGrid(
    WidgetTester tester, {
    int initialPage = 1,
    int? pageSizeToMove,
    bool initialFetch = true,
    bool fetchWithSorting = true,
    bool fetchWithFiltering = true,
    bool showColumnFilter = false,
    required TrinaLazyPaginationFetch fetch,
  }) async {
    await TestHelperUtil.changeWidth(tester: tester, width: 1200, height: 800);

    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: TrinaGrid(
            columns: columns,
            rows: rows,
            onLoaded: (TrinaGridOnLoadedEvent event) {
              stateManager = event.stateManager;
              if (showColumnFilter) {
                stateManager.setShowColumnFilter(true);
              }
            },
            createFooter: (s) => TrinaLazyPagination(
              initialPage: initialPage,
              initialFetch: initialFetch,
              fetchWithSorting: fetchWithSorting,
              fetchWithFiltering: fetchWithFiltering,
              pageSizeToMove: pageSizeToMove,
              fetch: fetch,
              stateManager: s,
            ),
          ),
        ),
      ),
    );
  }

  TrinaLazyPaginationFetch makeFetch({
    int pageSize = 20,
    int delayedMS = 20,
    required List<TrinaRow> fakeFetchedRows,
  }) {
    return (TrinaLazyPaginationRequest request) async {
      List<TrinaRow> tempList = fakeFetchedRows;

      if (request.filterRows.isNotEmpty) {
        final filter = FilterHelper.convertRowsToFilter(
          request.filterRows,
          stateManager.refColumns,
        );

        tempList = fakeFetchedRows.where(filter!).toList();
      }

      if (request.sortColumn != null && !request.sortColumn!.sort.isNone) {
        tempList = [...tempList];

        tempList.sort((a, b) {
          final sortA = request.sortColumn!.sort.isAscending ? a : b;
          final sortB = request.sortColumn!.sort.isAscending ? b : a;

          return request.sortColumn!.type.compare(
            sortA.cells[request.sortColumn!.field]!.valueForSorting,
            sortB.cells[request.sortColumn!.field]!.valueForSorting,
          );
        });
      }

      final page = request.page;
      final totalPage = (tempList.length / pageSize).ceil();
      final start = (page - 1) * pageSize;
      final end = start + pageSize;

      Iterable<TrinaRow> fetchedRows = tempList.getRange(
        max(0, start),
        min(tempList.length, end),
      );

      await Future.delayed(Duration(milliseconds: delayedMS));

      return Future.value(
        TrinaLazyPaginationResponse(
          totalPage: totalPage,
          rows: fetchedRows.toList(),
        ),
      );
    };
  }

  List<TextButton> buttonsToWidgets(Finder pageButtons) {
    return pageButtons
        .evaluate()
        .map((e) => e.widget)
        .cast<TextButton>()
        .toList();
  }

  String? textFromTextButton(TextButton button) {
    return (button.child as Text).data;
  }

  TextStyle textStyleFromTextButton(TextButton button) {
    return (button.child as Text).style as TextStyle;
  }

  Finder getPageButtons() {
    return find.byType(TextButton);
  }

  Finder findFilterTextField(String columnTitle) {
    return find.descendant(
      of: find.descendant(
        of: find.ancestor(
          of: find.text(columnTitle),
          matching: find.byType(TrinaBaseColumn),
        ),
        matching: find.byType(TrinaColumnFilter),
      ),
      matching: find.byType(TextField),
    );
  }

  Future<void> tapAndEnterTextColumnFilter(
    WidgetTester tester,
    String columnTitle,
    String? enterText,
  ) async {
    final textField = findFilterTextField(columnTitle);

    // To receive focus, tap the text box twice.
    await tester.tap(textField);
    await tester.tap(textField);

    if (enterText != null) {
      await tester.enterText(textField, enterText);
    }
  }

  group('Lazy Pagination Test', () {
    testWidgets(
      'When lazy loading is enabled, rows should be loaded incrementally',
      (tester) async {
        final dummyRows = RowHelper.count(90, columns);
        final fetch = makeFetch(fakeFetchedRows: dummyRows);

        await buildGrid(tester, fetch: fetch);
        await tester.pumpAndSettle(const Duration(milliseconds: 30));

        expect(stateManager.refRows.length, 20);

        expect(
          dummyRows.getRange(0, 20).map((e) => e.key),
          stateManager.refRows.map((e) => e.key),
        );

        expect(find.text('column0 value 0'), findsOneWidget);
        expect(find.text('column4 value 0'), findsOneWidget);
        expect(find.text('column0 value 7'), findsOneWidget);
        expect(find.text('column4 value 7'), findsOneWidget);
        expect(find.text('column0 value 15'), findsOneWidget);
        expect(find.text('column4 value 15'), findsOneWidget);

        await tester.tap(find.text('column0 value 14'));
        await tester.pumpAndSettle();
        await tester.sendKeyEvent(LogicalKeyboardKey.pageDown);
        await tester.pumpAndSettle();

        expect(find.text('column0 value 19'), findsOneWidget);
        expect(find.text('column4 value 19'), findsOneWidget);
      },
    );

    testWidgets('When initialFetch is false, no rows should be rendered', (
      tester,
    ) async {
      final dummyRows = RowHelper.count(90, columns);
      final fetch = makeFetch(fakeFetchedRows: dummyRows);

      await buildGrid(tester, fetch: fetch, initialFetch: false);
      await tester.pumpAndSettle(const Duration(milliseconds: 30));

      expect(stateManager.refRows.length, 0);
      expect(find.byType(TrinaBaseRow), findsNothing);
    });

    testWidgets(
      'When fetchWithSorting is true, sortOnlyEvent should be updated',
      (tester) async {
        final dummyRows = RowHelper.count(90, columns);
        final fetch = makeFetch(fakeFetchedRows: dummyRows);

        await buildGrid(
          tester,
          fetch: fetch,
          initialFetch: false,
          fetchWithSorting: true,
        );

        expect(stateManager.sortOnlyEvent, true);
      },
    );

    testWidgets(
      'When fetchWithFiltering is true, filterOnlyEvent should be updated',
      (tester) async {
        final dummyRows = RowHelper.count(90, columns);
        final fetch = makeFetch(fakeFetchedRows: dummyRows);

        await buildGrid(
          tester,
          fetch: fetch,
          initialFetch: false,
          fetchWithFiltering: true,
        );

        expect(stateManager.filterOnlyEvent, true);
      },
    );

    testWidgets(
      'When initialFetch is false and 20 rows are passed to TrinaGrid, 20 rows should be rendered',
      (tester) async {
        final dummyRows = RowHelper.count(90, columns);
        final fetch = makeFetch(fakeFetchedRows: dummyRows);

        rows = dummyRows.getRange(0, 20).toList();
        await buildGrid(tester, fetch: fetch, initialFetch: false);
        await tester.pumpAndSettle();

        expect(stateManager.refRows.length, 20);
        // The screen size displays 16 rows
        expect(find.byType(TrinaBaseRow), findsNWidgets(16));
      },
    );

    testWidgets('5 page buttons should be rendered', (tester) async {
      final dummyRows = RowHelper.count(90, columns);
      final fetch = makeFetch(fakeFetchedRows: dummyRows);

      rows = dummyRows.getRange(0, 20).toList();
      await buildGrid(tester, fetch: fetch);
      await tester.pumpAndSettle(const Duration(milliseconds: 30));

      List<TextButton> pageButtonsAsTextButton = buttonsToWidgets(
        getPageButtons(),
      );

      expect(pageButtonsAsTextButton.length, 5);
      expect(textFromTextButton(pageButtonsAsTextButton[0]), '1');
      expect(textFromTextButton(pageButtonsAsTextButton[1]), '2');
      expect(textFromTextButton(pageButtonsAsTextButton[2]), '3');
      expect(textFromTextButton(pageButtonsAsTextButton[3]), '4');
      expect(textFromTextButton(pageButtonsAsTextButton[4]), '5');
    });

    testWidgets('The first page button should be activated', (tester) async {
      final dummyRows = RowHelper.count(90, columns);
      final fetch = makeFetch(fakeFetchedRows: dummyRows);

      rows = dummyRows.getRange(0, 20).toList();
      await buildGrid(tester, fetch: fetch);
      await tester.pumpAndSettle(const Duration(milliseconds: 30));

      List<TextButton> pageButtonsAsTextButton = buttonsToWidgets(
        getPageButtons(),
      );

      expect((pageButtonsAsTextButton[0].child as Text).data, '1');

      final style1 = textStyleFromTextButton(pageButtonsAsTextButton[0]);

      expect(
        style1.color,
        stateManager.configuration.style.activatedBorderColor,
      );
    });

    testWidgets(
      'When the second page button is tapped, the corresponding rows should be rendered',
      (tester) async {
        final dummyRows = RowHelper.count(90, columns);
        final fetch = makeFetch(fakeFetchedRows: dummyRows);

        await buildGrid(tester, fetch: fetch);
        await tester.pumpAndSettle(const Duration(milliseconds: 30));

        expect(stateManager.refRows.length, 20);

        await tester.tap(getPageButtons().at(1));
        await tester.pumpAndSettle(const Duration(milliseconds: 30));

        expect(stateManager.refRows.length, 20);

        expect(find.text('column0 value 20'), findsOneWidget);
        expect(find.text('column4 value 20'), findsOneWidget);
        expect(find.text('column0 value 21'), findsOneWidget);
        expect(find.text('column4 value 21'), findsOneWidget);
        expect(find.text('column0 value 35'), findsOneWidget);
        expect(find.text('column4 value 35'), findsOneWidget);

        await tester.tap(find.text('column0 value 34'));
        await tester.pumpAndSettle();
        await tester.sendKeyEvent(LogicalKeyboardKey.pageDown);
        await tester.pumpAndSettle();

        expect(find.text('column0 value 39'), findsOneWidget);
        expect(find.text('column4 value 39'), findsOneWidget);
      },
    );

    testWidgets(
      'When initialPage is set to 3, the corresponding rows should be rendered',
      (tester) async {
        final dummyRows = RowHelper.count(90, columns);
        final fetch = makeFetch(fakeFetchedRows: dummyRows);

        await buildGrid(tester, fetch: fetch, initialPage: 3);
        await tester.pumpAndSettle(const Duration(milliseconds: 30));

        expect(stateManager.refRows.length, 20);

        expect(find.text('column0 value 40'), findsOneWidget);
        expect(find.text('column4 value 40'), findsOneWidget);
        expect(find.text('column0 value 41'), findsOneWidget);
        expect(find.text('column4 value 41'), findsOneWidget);
        expect(find.text('column0 value 55'), findsOneWidget);
        expect(find.text('column4 value 55'), findsOneWidget);

        await tester.tap(find.text('column0 value 54'));
        await tester.pumpAndSettle();
        await tester.sendKeyEvent(LogicalKeyboardKey.pageDown);
        await tester.pumpAndSettle();

        expect(find.text('column0 value 59'), findsOneWidget);
        expect(find.text('column4 value 59'), findsOneWidget);
      },
    );

    testWidgets(
      'When initialPage is set to 3, the third page button should be activated',
      (tester) async {
        final dummyRows = RowHelper.count(90, columns);
        final fetch = makeFetch(fakeFetchedRows: dummyRows);

        await buildGrid(tester, fetch: fetch, initialPage: 3);
        await tester.pumpAndSettle(const Duration(milliseconds: 30));

        List<TextButton> pageButtonsAsTextButton = buttonsToWidgets(
          getPageButtons(),
        );

        expect((pageButtonsAsTextButton[2].child as Text).data, '3');

        final style1 = textStyleFromTextButton(pageButtonsAsTextButton[2]);

        expect(
          style1.color,
          stateManager.configuration.style.activatedBorderColor,
        );
      },
    );

    testWidgets(
      'When filtering is applied, the filter icon should be rendered',
      (tester) async {
        final dummyRows = RowHelper.count(90, columns);
        final fetch = makeFetch(fakeFetchedRows: dummyRows);

        await buildGrid(tester, fetch: fetch, showColumnFilter: true);
        await tester.pumpAndSettle(const Duration(milliseconds: 30));

        expect(stateManager.hasFilter, false);

        await tapAndEnterTextColumnFilter(tester, 'column0', 'value');
        await tester.pumpAndSettle(const Duration(seconds: 1));

        expect(stateManager.hasFilter, true);
        expect(find.byIcon(Icons.filter_alt_outlined), findsOneWidget);
      },
    );
  });
}
