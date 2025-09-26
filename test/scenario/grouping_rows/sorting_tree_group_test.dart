// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trina_grid/trina_grid.dart';
import 'package:trina_grid/src/ui/ui.dart';

import '../../helper/test_helper_util.dart';

void main() {
  late TrinaGridStateManager stateManager;

  Future<void> buildGrid({
    required WidgetTester tester,
    required List<TrinaColumn> columns,
    required List<TrinaRow> rows,
    Widget Function(TrinaGridStateManager)? createFooter,
  }) async {
    await TestHelperUtil.changeWidth(tester: tester, width: 1200, height: 800);

    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: TrinaGrid(
            columns: columns,
            rows: rows,
            createFooter: createFooter,
            onLoaded: (TrinaGridOnLoadedEvent event) {
              stateManager = event.stateManager;
              stateManager.setRowGroup(
                TrinaRowGroupTreeDelegate(
                  resolveColumnDepth: (column) =>
                      int.parse(column.field.replaceAll('column', '')) - 1,
                  showText: (cell) => true,
                ),
              );
            },
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
  }

  group('Grouping by 3 depths.', () {
    late List<TrinaColumn> columns;

    late List<TrinaRow> rows;

    setUp(() {
      columns = [
        TrinaColumn(
          title: 'column1',
          field: 'column1',
          type: TrinaColumnType.text(),
        ),
        TrinaColumn(
          title: 'column2',
          field: 'column2',
          type: TrinaColumnType.text(),
        ),
        TrinaColumn(
          title: 'column3',
          field: 'column3',
          type: TrinaColumnType.text(),
        ),
        TrinaColumn(
          title: 'column4',
          field: 'column4',
          type: TrinaColumnType.text(),
        ),
        TrinaColumn(
          title: 'column5',
          field: 'column5',
          type: TrinaColumnType.text(),
        ),
      ];

      rows = [
        createRow('A', 'a1', 'a2', 'a3', 'a4', columns),
        createGroup('B', 'b1', 'b2', 'b3', 'b4', columns, [
          createRow('B1', 'b1-1', 'b1-2', 'b1-3', 'b1-3', columns),
          createRow('B2', 'b2-1', 'b2-2', 'b2-3', 'b2-4', columns),
          createRow('B3', 'b3-1', 'b3-2', 'b3-3', 'b3-4', columns),
          createGroup('B4', 'b4-1', 'b4-2', 'b4-3', 'b4-4', columns, [
            createRow('B41', 'b41-1', 'b41-2', 'b41-3', 'b41-4', columns),
            createRow('B42', 'b42-1', 'b42-2', 'b42-3', 'b42-4', columns),
            createGroup('B43', 'b43-1', 'b43-2', 'b43-3', 'b43-4', columns, [
              createRow(
                'B431',
                'b431-1',
                'b431-2',
                'b431-3',
                'b431-4',
                columns,
              ),
              createRow(
                'B432',
                'b432-1',
                'b432-2',
                'b432-3',
                'b432-4',
                columns,
              ),
            ]),
          ]),
        ]),
        createRow('C', 'c1', 'c2', 'c3', 'c4', columns),
        createRow('D', 'd1', 'd2', 'd3', 'd4', columns),
        createGroup('E', 'e1', 'e2', 'e3', 'e4', columns, [
          createRow('E1', 'e1-1', 'e1-2', 'e1-3', 'e1-4', columns),
          createRow('E2', 'e2-1', 'e2-2', 'e2-3', 'e2-4', columns),
        ]),
      ];
    });

    testWidgets('5 rows should be displayed.', (tester) async {
      await buildGrid(tester: tester, columns: columns, rows: rows);

      final A = find.text('A');
      final B = find.text('B');
      final C = find.text('C');
      final D = find.text('D');
      final E = find.text('E');

      expect(A, findsOneWidget);
      expect(B, findsOneWidget);
      expect(C, findsOneWidget);
      expect(D, findsOneWidget);
      expect(E, findsOneWidget);
    });

    testWidgets(
      'When the default order is applied, the order should be correct.',
      (tester) async {
        await buildGrid(tester: tester, columns: columns, rows: rows);

        final A = tester.getTopLeft(find.text('A'));
        final B = tester.getTopLeft(find.text('B'));
        final C = tester.getTopLeft(find.text('C'));
        final D = tester.getTopLeft(find.text('D'));
        final E = tester.getTopLeft(find.text('E'));

        expect(A.dy, lessThan(B.dy));
        expect(B.dy, lessThan(C.dy));
        expect(C.dy, lessThan(D.dy));
        expect(D.dy, lessThan(E.dy));
        expect(E.dy, greaterThan(D.dy));
      },
    );

    testWidgets(
      'When column1 is sorted in descending order, the order should change.',
      (tester) async {
        await buildGrid(tester: tester, columns: columns, rows: rows);

        await tester.tap(find.text('column1'));
        await tester.tap(find.text('column1'));
        await tester.pumpAndSettle();

        final A = tester.getTopLeft(find.text('A'));
        final B = tester.getTopLeft(find.text('B'));
        final C = tester.getTopLeft(find.text('C'));
        final D = tester.getTopLeft(find.text('D'));
        final E = tester.getTopLeft(find.text('E'));

        expect(E.dy, lessThan(D.dy));
        expect(D.dy, greaterThan(E.dy));
        expect(C.dy, greaterThan(D.dy));
        expect(B.dy, greaterThan(C.dy));
        expect(A.dy, greaterThan(B.dy));
      },
    );

    testWidgets(
      'When column2 is sorted in descending order, the order should change.',
      (tester) async {
        await buildGrid(tester: tester, columns: columns, rows: rows);

        await tester.tap(find.text('column2'));
        await tester.tap(find.text('column2'));
        await tester.pumpAndSettle();

        final A1 = tester.getTopLeft(find.text('a1'));
        final B1 = tester.getTopLeft(find.text('b1'));
        final C1 = tester.getTopLeft(find.text('c1'));
        final D1 = tester.getTopLeft(find.text('d1'));
        final E1 = tester.getTopLeft(find.text('e1'));

        expect(E1.dy, lessThan(D1.dy));
        expect(D1.dy, greaterThan(E1.dy));
        expect(C1.dy, greaterThan(D1.dy));
        expect(B1.dy, greaterThan(C1.dy));
        expect(A1.dy, greaterThan(B1.dy));
      },
    );

    testWidgets(
      'When B is expanded and column1 is sorted in descending order, the order should change.',
      (tester) async {
        await buildGrid(tester: tester, columns: columns, rows: rows);

        final GROUP_B_TOGGLE_BTN = find
            .descendant(
              of: find.ancestor(
                of: find.text('B'),
                matching: find.byType(TrinaDefaultCell),
              ),
              matching: find.byType(IconButton),
            )
            .first;
        await tester.tap(GROUP_B_TOGGLE_BTN);

        await tester.tap(find.text('column1'));
        await tester.tap(find.text('column1'));
        await tester.pumpAndSettle();

        final A = tester.getTopLeft(find.text('A'));
        final B = tester.getTopLeft(find.text('B'));
        final B1 = tester.getTopLeft(find.text('B1'));
        final B2 = tester.getTopLeft(find.text('B2'));
        final B3 = tester.getTopLeft(find.text('B3'));
        final B4 = tester.getTopLeft(find.text('B4'));
        final C = tester.getTopLeft(find.text('C'));
        final D = tester.getTopLeft(find.text('D'));
        final E = tester.getTopLeft(find.text('E'));

        expect(E.dy, lessThan(D.dy));
        expect(D.dy, lessThan(C.dy));
        expect(C.dy, lessThan(B.dy));
        expect(B.dy, lessThan(B4.dy));
        expect(B4.dy, lessThan(B3.dy));
        expect(B3.dy, lessThan(B2.dy));
        expect(B2.dy, lessThan(B1.dy));
        expect(B1.dy, lessThan(A.dy));
        expect(A.dy, greaterThan(B1.dy));
      },
    );

    testWidgets(
      'When column1 is sorted in descending order, B should be expanded and B1~4 should be sorted and displayed.',
      (tester) async {
        await buildGrid(tester: tester, columns: columns, rows: rows);

        await tester.tap(find.text('column1'));
        await tester.tap(find.text('column1'));
        await tester.pumpAndSettle();

        {
          final A = tester.getTopLeft(find.text('A'));
          final B = tester.getTopLeft(find.text('B'));
          final C = tester.getTopLeft(find.text('C'));
          final D = tester.getTopLeft(find.text('D'));
          final E = tester.getTopLeft(find.text('E'));

          expect(E.dy, lessThan(D.dy));
          expect(D.dy, greaterThan(E.dy));
          expect(C.dy, greaterThan(D.dy));
          expect(B.dy, greaterThan(C.dy));
          expect(A.dy, greaterThan(B.dy));
        }

        final GROUP_B_TOGGLE_BTN = find
            .descendant(
              of: find.ancestor(
                of: find.text('B'),
                matching: find.byType(TrinaDefaultCell),
              ),
              matching: find.byType(IconButton),
            )
            .first;
        await tester.tap(GROUP_B_TOGGLE_BTN);

        await tester.pumpAndSettle();

        {
          final A = tester.getTopLeft(find.text('A'));
          final B = tester.getTopLeft(find.text('B'));
          final B1 = tester.getTopLeft(find.text('B1'));
          final B2 = tester.getTopLeft(find.text('B2'));
          final B3 = tester.getTopLeft(find.text('B3'));
          final B4 = tester.getTopLeft(find.text('B4'));
          final C = tester.getTopLeft(find.text('C'));
          final D = tester.getTopLeft(find.text('D'));
          final E = tester.getTopLeft(find.text('E'));

          expect(E.dy, lessThan(D.dy));
          expect(D.dy, lessThan(C.dy));
          expect(C.dy, lessThan(B.dy));
          expect(B.dy, lessThan(B4.dy));
          expect(B4.dy, lessThan(B3.dy));
          expect(B3.dy, lessThan(B2.dy));
          expect(B2.dy, lessThan(B1.dy));
          expect(B1.dy, lessThan(A.dy));
          expect(A.dy, greaterThan(B1.dy));
        }
      },
    );

    testWidgets(
      'When column1 is filtered with b and sorted in descending order, '
      'when the filter is cleared, the order should change.',
      (tester) async {
        await buildGrid(tester: tester, columns: columns, rows: rows);

        stateManager.setShowColumnFilter(true);
        await tester.pumpAndSettle();

        final COLUMN1_FILTER = find.descendant(
          of: find.ancestor(
            of: find.text('column1'),
            matching: find.byType(TrinaBaseColumn),
          ),
          matching: find.byType(TextField),
        );
        await tester.tap(COLUMN1_FILTER);
        await tester.tap(COLUMN1_FILTER);
        await tester.enterText(COLUMN1_FILTER, 'b');
        await tester.pumpAndSettle(const Duration(seconds: 1));

        await tester.tap(find.byType(TrinaColumnTitle).first);
        await tester.tap(find.byType(TrinaColumnTitle).first);
        await tester.pumpAndSettle();
        expect(stateManager.getSortedColumn?.field, 'column1');

        {
          final A = find.text('A');
          final B = find.text('B');
          final C = find.text('C');
          final D = find.text('D');
          final E = find.text('E');

          expect(A, findsNothing);
          expect(B, findsOneWidget);
          expect(C, findsNothing);
          expect(D, findsNothing);
          expect(E, findsNothing);
        }

        stateManager.setFilter(null);
        await tester.pumpAndSettle();

        {
          final A = tester.getTopLeft(find.text('A'));
          final B = tester.getTopLeft(find.text('B'));
          final C = tester.getTopLeft(find.text('C'));
          final D = tester.getTopLeft(find.text('D'));
          final E = tester.getTopLeft(find.text('E'));

          expect(E.dy, lessThan(D.dy));
          expect(D.dy, greaterThan(E.dy));
          expect(C.dy, greaterThan(D.dy));
          expect(B.dy, greaterThan(C.dy));
          expect(A.dy, greaterThan(B.dy));
        }
      },
    );

    testWidgets(
      'When 2 rows are paginated, the order of the rows in the page should be sorted.',
      (tester) async {
        await buildGrid(
          tester: tester,
          columns: columns,
          rows: rows,
          createFooter: (s) {
            s.setPageSize(2);
            return TrinaPagination(s);
          },
        );

        {
          final A = find.text('A');
          final B = find.text('B');
          final C = find.text('C');
          final D = find.text('D');
          final E = find.text('E');

          expect(A, findsOneWidget);
          expect(B, findsOneWidget);

          expect(C, findsNothing);
          expect(D, findsNothing);
          expect(E, findsNothing);
        }

        await tester.tap(find.byType(TrinaColumnTitle).at(2));
        await tester.tap(find.byType(TrinaColumnTitle).at(2));
        await tester.pumpAndSettle();
        expect(stateManager.getSortedColumn?.field, 'column3');

        {
          final A = find.text('A');
          final B = find.text('B');
          final C = find.text('C');
          final D = find.text('D');
          final E = find.text('E');

          expect(E, findsOneWidget);
          expect(D, findsOneWidget);
          expect(tester.getTopLeft(E).dy, lessThan(tester.getTopLeft(D).dy));

          expect(C, findsNothing);
          expect(B, findsNothing);
          expect(A, findsNothing);
        }

        {
          stateManager.setPage(2);
          await tester.pumpAndSettle();

          final A = find.text('A');
          final B = find.text('B');
          final C = find.text('C');
          final D = find.text('D');
          final E = find.text('E');

          expect(E, findsNothing);
          expect(D, findsNothing);

          expect(C, findsOneWidget);
          expect(B, findsOneWidget);
          expect(tester.getTopLeft(C).dy, lessThan(tester.getTopLeft(B).dy));

          expect(A, findsNothing);
        }

        {
          stateManager.setPage(3);
          await tester.pumpAndSettle();

          final A = find.text('A');
          final B = find.text('B');
          final C = find.text('C');
          final D = find.text('D');
          final E = find.text('E');

          expect(E, findsNothing);
          expect(D, findsNothing);
          expect(C, findsNothing);
          expect(B, findsNothing);

          expect(A, findsOneWidget);
        }
      },
    );
  });
}

TrinaRow createRow(
  String value1,
  String value2,
  String value3,
  String value4,
  String value5,
  List<TrinaColumn> columns, [
  TrinaRowType? type,
]) {
  final Map<String, TrinaCell> cells = {};

  final row = TrinaRow(cells: cells, type: type);

  cells['column1'] = TrinaCell(value: value1)
    ..setRow(row)
    ..setColumn(columns[0]);
  cells['column2'] = TrinaCell(value: value2)
    ..setRow(row)
    ..setColumn(columns[1]);
  cells['column3'] = TrinaCell(value: value3)
    ..setRow(row)
    ..setColumn(columns[2]);
  cells['column4'] = TrinaCell(value: value4)
    ..setRow(row)
    ..setColumn(columns[3]);
  cells['column5'] = TrinaCell(value: value5)
    ..setRow(row)
    ..setColumn(columns[4]);

  return row;
}

TrinaRow createGroup(
  String value1,
  String value2,
  String value3,
  String value4,
  String value5,
  List<TrinaColumn> columns,
  List<TrinaRow> children,
) {
  return createRow(
    value1,
    value2,
    value3,
    value4,
    value5,
    columns,
    TrinaRowType.group(children: FilteredList(initialList: children)),
  );
}
