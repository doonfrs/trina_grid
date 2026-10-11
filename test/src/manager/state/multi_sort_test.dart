import 'package:flutter/material.dart';
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
  }) {
    return TrinaGridStateManager(
      columns: columns,
      rows: rows,
      gridFocusNode: FocusNode(),
      scroll: scroll,
      configuration: const TrinaGridConfiguration(),
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
        TrinaColumn(
          title: 'Name',
          field: 'name',
          type: TrinaColumnType.text(),
        ),
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
          .map((r) => '${r.cells['dept']!.value}_${r.cells['score']!.value}_${r.cells['name']!.value}')
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

    test('clearSorting resets all columns', () {
      stateManager.sortAscending(columns[0]);
      stateManager.sortDescending(columns[1], append: true);
      expect(stateManager.sortedColumns.length, 2);

      stateManager.clearSorting();
      expect(stateManager.sortedColumns.isEmpty, isTrue);
      expect(columns[0].sort.isNone, isTrue);
      expect(columns[0].sortPriority, 0);
      expect(columns[1].sort.isNone, isTrue);
      expect(columns[1].sortPriority, 0);
    });
  });
}
