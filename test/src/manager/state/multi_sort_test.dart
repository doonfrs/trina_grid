import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:trina_grid/trina_grid.dart';

import '../../../mock/shared_mocks.mocks.dart';

void main() {
  final TrinaGridScrollController scroll = MockTrinaGridScrollController();
  final LinkedScrollControllerGroup horizontal =
      MockLinkedScrollControllerGroup();
  final ScrollController scrollController = MockScrollController();
  final ScrollPosition scrollPosition = MockScrollPosition();
  final TrinaGridEventManager eventManager = MockTrinaGridEventManager();

  when(scroll.horizontal).thenReturn(horizontal);
  when(scroll.horizontalOffset).thenReturn(0);
  when(scroll.maxScrollHorizontal).thenReturn(0);
  when(scroll.bodyRowsHorizontal).thenReturn(scrollController);
  when(scrollController.hasClients).thenReturn(true);
  when(scrollController.offset).thenReturn(0);
  when(scrollController.position).thenReturn(scrollPosition);
  when(scrollPosition.viewportDimension).thenReturn(0.0);
  when(scrollPosition.hasViewportDimension).thenReturn(true);

  TrinaGridStateManager createStateManager({
    required List<TrinaColumn> columns,
    required List<TrinaRow> rows,
    TrinaGridConfiguration configuration = const TrinaGridConfiguration(),
  }) {
    return TrinaGridStateManager(
      columns: columns,
      rows: rows,
      gridFocusNode: FocusNode(),
      scroll: scroll,
      configuration: configuration,
    )..setEventManager(eventManager);
  }

  group('Multi-column sorting tests', () {
    late TrinaGridStateManager stateManager;
    late List<TrinaColumn> columns;
    late List<TrinaRow> rows;

    setUp(() {
      columns = [
        TrinaColumn(
          title: 'Department',
          field: 'dept',
          type: TrinaColumnType.text(),
        ),
        TrinaColumn(
          title: 'Score',
          field: 'score',
          type: TrinaColumnType.number(),
        ),
        TrinaColumn(title: 'Name', field: 'name', type: TrinaColumnType.text()),
      ];

      // Sample data with ties
      rows = [
        TrinaRow(
          sortIdx: 0,
          cells: {
            'dept': TrinaCell(value: 'Sales'),
            'score': TrinaCell(value: 80),
            'name': TrinaCell(value: 'Alice'),
          },
        ),
        TrinaRow(
          sortIdx: 1,
          cells: {
            'dept': TrinaCell(value: 'Engineering'),
            'score': TrinaCell(value: 95),
            'name': TrinaCell(value: 'Bob'),
          },
        ),
        TrinaRow(
          sortIdx: 2,
          cells: {
            'dept': TrinaCell(value: 'Engineering'),
            'score': TrinaCell(value: 90),
            'name': TrinaCell(value: 'Charlie'),
          },
        ),
        TrinaRow(
          sortIdx: 3,
          cells: {
            'dept': TrinaCell(value: 'Engineering'),
            'score': TrinaCell(value: 95),
            'name': TrinaCell(value: 'Adam'),
          },
        ),
        TrinaRow(
          sortIdx: 4,
          cells: {
            'dept': TrinaCell(value: 'Sales'),
            'score': TrinaCell(value: 70),
            'name': TrinaCell(value: 'David'),
          },
        ),
      ];

      stateManager = createStateManager(columns: columns, rows: rows);
    });

    test('Single sort without append resets previous sorts', () {
      stateManager.sortAscending(columns[0]);
      expect(columns[0].sort.isAscending, isTrue);
      expect(columns[0].sortPriority, 1);
      expect(stateManager.sortedColumns.length, 1);

      stateManager.sortAscending(columns[1]);
      expect(columns[0].sort.isNone, isTrue);
      expect(columns[0].sortPriority, 0);
      expect(columns[1].sort.isAscending, isTrue);
      expect(columns[1].sortPriority, 1);
      expect(stateManager.sortedColumns.length, 1);
    });

    test('Multi-column sort with append orders correctly', () {
      // 1st sort: Dept ascending (Engineering then Sales)
      stateManager.sortAscending(columns[0]);
      // 2nd sort: Score descending (higher score first within same dept)
      stateManager.sortDescending(columns[1], append: true);
      // 3rd sort: Name ascending (alphabetical tie-breaker)
      stateManager.sortAscending(columns[2], append: true);

      expect(stateManager.sortedColumns.length, 3);
      expect(columns[0].sortPriority, 1);
      expect(columns[1].sortPriority, 2);
      expect(columns[2].sortPriority, 3);

      final result = stateManager.rows
          .map(
            (r) =>
                '${r.cells['dept']!.value}_${r.cells['score']!.value}_${r.cells['name']!.value}',
          )
          .toList();

      expect(result, [
        'Engineering_95_Adam',
        'Engineering_95_Bob',
        'Engineering_90_Charlie',
        'Sales_80_Alice',
        'Sales_70_David',
      ]);
    });

    test('toggleSortColumn with multiSort appends sorting', () {
      // Toggle col 0: None -> Ascending
      stateManager.toggleSortColumn(columns[0], multiSort: true);
      expect(columns[0].sort.isAscending, isTrue);
      expect(columns[0].sortPriority, 1);

      // Toggle col 1: None -> Ascending
      stateManager.toggleSortColumn(columns[1], multiSort: true);
      expect(columns[1].sort.isAscending, isTrue);
      expect(columns[1].sortPriority, 2);
      expect(stateManager.sortedColumns.length, 2);

      // Toggle col 1 again: Ascending -> Descending
      stateManager.toggleSortColumn(columns[1], multiSort: true);
      expect(columns[1].sort.isDescending, isTrue);
      expect(columns[1].sortPriority, 2);

      // Toggle col 1 again: Descending -> None
      stateManager.toggleSortColumn(columns[1], multiSort: true);
      expect(columns[1].sort.isNone, isTrue);
      expect(columns[1].sortPriority, 0);
      expect(stateManager.sortedColumns.length, 1);
      expect(stateManager.sortedColumns.first.field, 'dept');
    });

    testWidgets(
      'toggleSortColumn with enableMultiColumnSort respects Shift key',
      (tester) async {
        final multiSortManager = createStateManager(
          columns: columns,
          rows: rows,
          configuration: const TrinaGridConfiguration(
            enableMultiColumnSort: true,
          ),
        );

        // Sort col 0 normally
        multiSortManager.toggleSortColumn(columns[0]);
        expect(columns[0].sort.isAscending, isTrue);
        expect(columns[0].sortPriority, 1);

        // Press Shift and sort col 1
        await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
        multiSortManager.toggleSortColumn(columns[1]);
        expect(columns[0].sort.isAscending, isTrue);
        expect(columns[0].sortPriority, 1);
        expect(columns[1].sort.isAscending, isTrue);
        expect(columns[1].sortPriority, 2);
        expect(multiSortManager.sortedColumns.length, 2);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
      },
    );

    testWidgets(
      'toggleSortColumn with enableMultiColumnSort false ignores Shift key',
      (tester) async {
        final standardManager = createStateManager(
          columns: columns,
          rows: rows,
          configuration: const TrinaGridConfiguration(
            enableMultiColumnSort: false,
          ),
        );

        // Sort col 0 normally
        standardManager.toggleSortColumn(columns[0]);
        expect(columns[0].sort.isAscending, isTrue);
        expect(columns[0].sortPriority, 1);

        // Press Shift and sort col 1 - should reset col 0 since enableMultiColumnSort is false
        await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
        standardManager.toggleSortColumn(columns[1]);
        expect(columns[0].sort.isNone, isTrue);
        expect(columns[0].sortPriority, 0);
        expect(columns[1].sort.isAscending, isTrue);
        expect(columns[1].sortPriority, 1);
        expect(standardManager.sortedColumns.length, 1);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
      },
    );

    test(
      'clearSorting resets all columns and notifies with clearSorting hashCode',
      () {
        stateManager.sortAscending(columns[0]);
        stateManager.sortDescending(columns[1], append: true);
        expect(stateManager.sortedColumns.length, 2);

        // Verify defaultRowsFilter includes clearSorting.hashCode
        final rowsFilter = TrinaNotifierFilterResolverDefault.defaultRowsFilter(
          stateManager,
        );
        expect(rowsFilter.contains(stateManager.clearSorting.hashCode), isTrue);

        final footerFilter =
            TrinaNotifierFilterResolverDefault.defaultAggregateColumnFooterFilter(
              stateManager,
            );
        expect(
          footerFilter.contains(stateManager.clearSorting.hashCode),
          isTrue,
        );

        stateManager.clearSorting();
        expect(stateManager.sortedColumns.isEmpty, isTrue);
        expect(columns[0].sort.isNone, isTrue);
        expect(columns[0].sortPriority, 0);
        expect(columns[1].sort.isNone, isTrue);
        expect(columns[1].sortPriority, 0);
      },
    );

    test(
      'Column sorted via constructor receives priority 1 and increments when more join',
      () {
        final initialSortedCol = TrinaColumn(
          title: 'Initial',
          field: 'initial',
          type: TrinaColumnType.text(),
          sort: TrinaColumnSort.ascending,
        );

        final secondCol = TrinaColumn(
          title: 'Second',
          field: 'second',
          type: TrinaColumnType.text(),
        );

        final manager = createStateManager(
          columns: [initialSortedCol, secondCol],
          rows: [
            TrinaRow(
              cells: {
                'initial': TrinaCell(value: 'A'),
                'second': TrinaCell(value: '1'),
              },
            ),
            TrinaRow(
              cells: {
                'initial': TrinaCell(value: 'B'),
                'second': TrinaCell(value: '2'),
              },
            ),
          ],
        );

        expect(initialSortedCol.sortPriority, 1);
        expect(manager.sortedColumns.length, 1);
        expect(manager.sortedColumns.first.field, 'initial');

        // Append second column
        manager.sortDescending(secondCol, append: true);
        expect(initialSortedCol.sortPriority, 1);
        expect(secondCol.sortPriority, 2);
        expect(manager.sortedColumns.length, 2);
        expect(manager.sortedColumns[0].field, 'initial');
        expect(manager.sortedColumns[1].field, 'second');
      },
    );

    test(
      'Columns sorted in their constructors are numbered in column order',
      () {
        final sortedColumns = [
          TrinaColumn(
            title: 'Department',
            field: 'dept',
            type: TrinaColumnType.text(),
            sort: TrinaColumnSort.ascending,
          ),
          TrinaColumn(
            title: 'Score',
            field: 'score',
            type: TrinaColumnType.number(),
            sort: TrinaColumnSort.descending,
          ),
          TrinaColumn(
            title: 'Name',
            field: 'name',
            type: TrinaColumnType.text(),
          ),
        ];

        final manager = createStateManager(columns: sortedColumns, rows: rows);

        expect(sortedColumns[0].sortPriority, 1);
        expect(sortedColumns[1].sortPriority, 2);
        expect(sortedColumns[2].sortPriority, 0);
        expect(manager.sortedColumns.map((c) => c.field), ['dept', 'score']);

        // A column appended later goes after both.
        manager.sortAscending(sortedColumns[2], append: true);
        expect(sortedColumns[2].sortPriority, 3);
      },
    );

    test(
      'Constructor sorts without a priority come after the ones that set it',
      () {
        final mixedColumns = [
          TrinaColumn(
            title: 'Department',
            field: 'dept',
            type: TrinaColumnType.text(),
            sort: TrinaColumnSort.ascending,
          ),
          TrinaColumn(
            title: 'Score',
            field: 'score',
            type: TrinaColumnType.number(),
            sort: TrinaColumnSort.descending,
            sortPriority: 1,
          ),
          TrinaColumn(
            title: 'Name',
            field: 'name',
            type: TrinaColumnType.text(),
          ),
        ];

        final manager = createStateManager(columns: mixedColumns, rows: rows);

        expect(mixedColumns[1].sortPriority, 1);
        expect(mixedColumns[0].sortPriority, 2);
        expect(manager.sortedColumns.map((c) => c.field), ['score', 'dept']);
      },
    );

    testWidgets('Columns sorted in their constructors show badges 1 and 2', (
      tester,
    ) async {
      final sortedColumns = [
        TrinaColumn(
          title: 'Department',
          field: 'dept',
          type: TrinaColumnType.text(),
          sort: TrinaColumnSort.ascending,
        ),
        TrinaColumn(
          title: 'Score',
          field: 'score',
          type: TrinaColumnType.number(),
          sort: TrinaColumnSort.descending,
        ),
        TrinaColumn(title: 'Name', field: 'name', type: TrinaColumnType.text()),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TrinaGrid(
              columns: sortedColumns,
              rows: rows,
              configuration: const TrinaGridConfiguration(
                enableMultiColumnSort: true,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('1'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
    });

    test(
      'TrinaLazyPaginationRequest and TrinaInfinityScrollRowsRequest carry sortedColumns',
      () {
        stateManager.sortAscending(columns[0]);
        stateManager.sortDescending(columns[1], append: true);

        final lazyRequest = TrinaLazyPaginationRequest(
          page: 1,
          pageSize: 20,
          sortColumn: stateManager.getSortedColumn,
          sortedColumns: stateManager.sortedColumns,
        );

        expect(lazyRequest.sortColumn?.field, 'dept');
        expect(lazyRequest.sortedColumns.length, 2);
        expect(lazyRequest.sortedColumns[0].field, 'dept');
        expect(lazyRequest.sortedColumns[1].field, 'score');

        final scrollRequest = TrinaInfinityScrollRowsRequest(
          sortColumn: stateManager.getSortedColumn,
          sortedColumns: stateManager.sortedColumns,
        );

        expect(scrollRequest.sortColumn?.field, 'dept');
        expect(scrollRequest.sortedColumns.length, 2);
        expect(scrollRequest.sortedColumns[0].field, 'dept');
        expect(scrollRequest.sortedColumns[1].field, 'score');
      },
    );

    testWidgets(
      'Priority badges appear and update when columns join and leave compound sort',
      (tester) async {
        late TrinaGridStateManager stateManager;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TrinaGrid(
                columns: columns,
                rows: rows,
                configuration: const TrinaGridConfiguration(
                  enableMultiColumnSort: true,
                ),
                onLoaded: (event) => stateManager = event.stateManager,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // No badges initially
        expect(find.text('1'), findsNothing);
        expect(find.text('2'), findsNothing);

        // Tap column 0 (Department) -> single sort, no badge
        await tester.tap(find.text('Department'));
        await tester.pumpAndSettle();
        expect(columns[0].sort.isAscending, isTrue);
        expect(stateManager.sortedColumns.length, 1);
        expect(find.text('1'), findsNothing);

        // Shift-tap column 1 (Score) -> multi sort, column 0 gets badge 1, column 1 gets badge 2
        await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
        await tester.tap(find.text('Score'));
        await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
        await tester.pumpAndSettle();

        expect(stateManager.sortedColumns.length, 2);
        expect(columns[0].sortPriority, 1);
        expect(columns[1].sortPriority, 2);
        expect(find.text('1'), findsOneWidget);
        expect(find.text('2'), findsOneWidget);

        // Shift-tap column 2 (Name) -> column 2 gets badge 3
        await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
        await tester.tap(find.text('Name'));
        await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
        await tester.pumpAndSettle();

        expect(stateManager.sortedColumns.length, 3);
        expect(find.text('1'), findsOneWidget);
        expect(find.text('2'), findsOneWidget);
        expect(find.text('3'), findsOneWidget);

        // Clear sorting -> badges disappear
        stateManager.clearSorting();
        await tester.pumpAndSettle();

        expect(stateManager.sortedColumns.isEmpty, isTrue);
        expect(find.text('1'), findsNothing);
        expect(find.text('2'), findsNothing);
        expect(find.text('3'), findsNothing);
      },
    );
  });
}
