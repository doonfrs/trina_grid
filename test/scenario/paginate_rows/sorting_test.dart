import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trina_grid/trina_grid.dart';
import 'package:trina_grid/src/ui/trina_base_cell.dart';

void main() {
  late TrinaGridStateManager stateManager;

  late List<TrinaColumn> columns;

  late List<TrinaRow> rows;

  Future<void> buildGrid(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: TrinaGrid(
            columns: columns,
            rows: rows,
            onLoaded: (TrinaGridOnLoadedEvent event) {
              stateManager = event.stateManager;
            },
            createFooter: (s) {
              s.setPageSize(3);
              return TrinaPagination(s);
            },
          ),
        ),
      ),
    );
  }

  Future<List<TrinaBaseCell>> getCells(WidgetTester tester, {int? page}) async {
    if (page != null) {
      await tester.tap(find.text('$page'));
      await tester.pump();
    }

    final cells = find
        .byType(TrinaBaseCell)
        .evaluate()
        .map((e) => e.widget)
        .cast<TrinaBaseCell>()
        .toList();

    return cells;
  }

  group('Sorting Test', () {
    setUp(() {
      columns = [
        TrinaColumn(
          title: 'date',
          field: 'date',
          type: TrinaColumnType.date(format: 'dd/MM/yyyy'),
        ),
      ];

      rows = [
        TrinaRow(cells: {'date': TrinaCell(value: DateTime(2022, 4, 1))}),
        TrinaRow(cells: {'date': TrinaCell(value: DateTime(2022, 2, 10))}),
        TrinaRow(cells: {'date': TrinaCell(value: DateTime(2022, 2, 2))}),
        TrinaRow(cells: {'date': TrinaCell(value: DateTime(2022, 2, 3))}),
        TrinaRow(cells: {'date': TrinaCell(value: DateTime(2022, 4, 3))}),
        TrinaRow(cells: {'date': TrinaCell(value: DateTime(2022, 3, 1))}),
        TrinaRow(cells: {'date': TrinaCell(value: DateTime(2022, 5, 1))}),
        TrinaRow(cells: {'date': TrinaCell(value: DateTime(2022, 1, 20))}),
        TrinaRow(cells: {'date': TrinaCell(value: DateTime(2022, 8, 2))}),
        TrinaRow(cells: {'date': TrinaCell(value: DateTime(2022, 8, 1))}),
      ];
    });

    group('Sorting by column tap', () {
      testWidgets(
        'When sorting is applied, rows should be sorted accordingly',
        (tester) async {
          await buildGrid(tester);
          await tester.tap(find.text('date'));
          await tester.pump();

          final List<TrinaBaseCell> cells = [];

          cells.addAll(await getCells(tester));
          cells.addAll(await getCells(tester, page: 2));
          cells.addAll(await getCells(tester, page: 3));
          cells.addAll(await getCells(tester, page: 4));

          expect(cells.length, 10);
          expect(cells[0].cell.value, '20/01/2022');
          expect(cells[1].cell.value, '02/02/2022');
          expect(cells[2].cell.value, '03/02/2022');
          expect(cells[3].cell.value, '10/02/2022');
          expect(cells[4].cell.value, '01/03/2022');
          expect(cells[5].cell.value, '01/04/2022');
          expect(cells[6].cell.value, '03/04/2022');
          expect(cells[7].cell.value, '01/05/2022');
          expect(cells[8].cell.value, '01/08/2022');
          expect(cells[9].cell.value, '02/08/2022');
        },
      );

      testWidgets(
        'When sorting is applied with pagination, rows should be sorted correctly',
        (tester) async {
          await buildGrid(tester);
          await tester.tap(find.text('date'));
          await tester.tap(find.text('date')); // descending
          await tester.pump();

          final List<TrinaBaseCell> cells = [];

          cells.addAll(await getCells(tester));
          cells.addAll(await getCells(tester, page: 2));
          cells.addAll(await getCells(tester, page: 3));
          cells.addAll(await getCells(tester, page: 4));

          expect(cells.length, 10);
          expect(cells[0].cell.value, '02/08/2022');
          expect(cells[1].cell.value, '01/08/2022');
          expect(cells[2].cell.value, '01/05/2022');
          expect(cells[3].cell.value, '03/04/2022');
          expect(cells[4].cell.value, '01/04/2022');
          expect(cells[5].cell.value, '01/03/2022');
          expect(cells[6].cell.value, '10/02/2022');
          expect(cells[7].cell.value, '03/02/2022');
          expect(cells[8].cell.value, '02/02/2022');
          expect(cells[9].cell.value, '20/01/2022');
        },
      );

      testWidgets(
        'When sorting is reversed, rows should be sorted in reverse order',
        (tester) async {
          await buildGrid(tester);
          await tester.tap(find.text('date'));
          await tester.tap(find.text('date')); // descending
          await tester.tap(find.text('date')); // none
          await tester.pump();

          final List<TrinaBaseCell> cells = [];

          cells.addAll(await getCells(tester));
          cells.addAll(await getCells(tester, page: 2));
          cells.addAll(await getCells(tester, page: 3));
          cells.addAll(await getCells(tester, page: 4));

          expect(cells.length, 10);
          expect(cells[0].cell.value, '01/04/2022');
          expect(cells[1].cell.value, '10/02/2022');
          expect(cells[2].cell.value, '02/02/2022');
          expect(cells[3].cell.value, '03/02/2022');
          expect(cells[4].cell.value, '03/04/2022');
          expect(cells[5].cell.value, '01/03/2022');
          expect(cells[6].cell.value, '01/05/2022');
          expect(cells[7].cell.value, '20/01/2022');
          expect(cells[8].cell.value, '02/08/2022');
          expect(cells[9].cell.value, '01/08/2022');
        },
      );
    });

    group('Sorting by state manager', () {
      testWidgets(
        'When sorting is applied, rows should be sorted accordingly',
        (tester) async {
          await buildGrid(tester);
          stateManager.sortAscending(stateManager.columns.first);
          await tester.pump();

          final List<TrinaBaseCell> cells = [];

          cells.addAll(await getCells(tester));
          cells.addAll(await getCells(tester, page: 2));
          cells.addAll(await getCells(tester, page: 3));
          cells.addAll(await getCells(tester, page: 4));

          expect(cells.length, 10);
          expect(cells[0].cell.value, '20/01/2022');
          expect(cells[1].cell.value, '02/02/2022');
          expect(cells[2].cell.value, '03/02/2022');
          expect(cells[3].cell.value, '10/02/2022');
          expect(cells[4].cell.value, '01/03/2022');
          expect(cells[5].cell.value, '01/04/2022');
          expect(cells[6].cell.value, '03/04/2022');
          expect(cells[7].cell.value, '01/05/2022');
          expect(cells[8].cell.value, '01/08/2022');
          expect(cells[9].cell.value, '02/08/2022');
        },
      );

      testWidgets(
        'When sorting is applied with pagination, rows should be sorted correctly',
        (tester) async {
          await buildGrid(tester);
          stateManager.sortDescending(stateManager.columns.first);
          await tester.pump();

          final List<TrinaBaseCell> cells = [];

          cells.addAll(await getCells(tester));
          cells.addAll(await getCells(tester, page: 2));
          cells.addAll(await getCells(tester, page: 3));
          cells.addAll(await getCells(tester, page: 4));

          expect(cells.length, 10);
          expect(cells[0].cell.value, '02/08/2022');
          expect(cells[1].cell.value, '01/08/2022');
          expect(cells[2].cell.value, '01/05/2022');
          expect(cells[3].cell.value, '03/04/2022');
          expect(cells[4].cell.value, '01/04/2022');
          expect(cells[5].cell.value, '01/03/2022');
          expect(cells[6].cell.value, '10/02/2022');
          expect(cells[7].cell.value, '03/02/2022');
          expect(cells[8].cell.value, '02/02/2022');
          expect(cells[9].cell.value, '20/01/2022');
        },
      );

      testWidgets(
        'When sorting is reversed, rows should be sorted in reverse order',
        (tester) async {
          await buildGrid(tester);
          stateManager.sortDescending(stateManager.columns.first);
          stateManager.toggleSortColumn(stateManager.columns.first);
          await tester.pump();

          final List<TrinaBaseCell> cells = [];

          cells.addAll(await getCells(tester));
          cells.addAll(await getCells(tester, page: 2));
          cells.addAll(await getCells(tester, page: 3));
          cells.addAll(await getCells(tester, page: 4));

          expect(cells.length, 10);
          expect(cells[0].cell.value, '01/04/2022');
          expect(cells[1].cell.value, '10/02/2022');
          expect(cells[2].cell.value, '02/02/2022');
          expect(cells[3].cell.value, '03/02/2022');
          expect(cells[4].cell.value, '03/04/2022');
          expect(cells[5].cell.value, '01/03/2022');
          expect(cells[6].cell.value, '01/05/2022');
          expect(cells[7].cell.value, '20/01/2022');
          expect(cells[8].cell.value, '02/08/2022');
          expect(cells[9].cell.value, '01/08/2022');
        },
      );
    });
  });
}
