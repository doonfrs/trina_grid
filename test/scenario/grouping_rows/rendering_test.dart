// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trina_grid/trina_grid.dart';
import 'package:trina_grid/src/ui/ui.dart';

import '../../helper/column_helper.dart';
import '../../helper/test_helper_util.dart';

void main() {
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

  late TrinaGridStateManager stateManager;

  Future<void> buildGrid({
    required WidgetTester tester,
    required List<TrinaColumn> columns,
    required List<TrinaRow> rows,
    required TrinaRowGroupDelegate delegate,
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
              stateManager.setRowGroup(delegate);
            },
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
  }

  group('Row Grouping Rendering Test', () {
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

    testWidgets(
      'When showFirstExpandableIcon is true, expand icon should be rendered in the first cell',
      (tester) async {
        await buildGrid(
          tester: tester,
          columns: columns,
          rows: rows,
          delegate: TrinaRowGroupTreeDelegate(
            resolveColumnDepth: (column) =>
                int.parse(column.field.replaceAll('column', '')) - 1,
            showText: (cell) => true,
            showFirstExpandableIcon: true,
          ),
        );

        final B_CELL = find.ancestor(
          of: find.text('B'),
          matching: find.byType(TrinaDefaultCell),
        );

        final E_CELL = find.ancestor(
          of: find.text('E'),
          matching: find.byType(TrinaDefaultCell),
        );

        final B_EXPAND_ICON = find.descendant(
          of: B_CELL,
          matching: find.byType(IconButton),
        );

        final E_EXPAND_ICON = find.descendant(
          of: E_CELL,
          matching: find.byType(IconButton),
        );

        expect(B_EXPAND_ICON, findsOneWidget);
        expect(E_EXPAND_ICON, findsOneWidget);

        await tester.tap(B_EXPAND_ICON);
        await tester.pumpAndSettle();

        // Normal row
        {
          final B1_ROW = stateManager.refRows[2];
          expect(B1_ROW.cells.values.first.value, 'B1');

          final B1_CELL = find.ancestor(
            of: find.text('B1'),
            matching: find.byType(TrinaDefaultCell),
          );

          final B1_EXPAND_ICON = find.descendant(
            of: B1_CELL,
            matching: find.byType(IconButton),
          );

          final B1_SIZED_BOX = find
              .descendant(of: B1_CELL, matching: find.byType(SizedBox))
              .first;

          final B1_SIZED_BOX_WIDGET =
              B1_SIZED_BOX.evaluate().first.widget as SizedBox;

          final gap = stateManager.style.iconSize * 1.5;
          // Normal rows have indentation of (depth + 1) * gap
          final depth = B1_ROW.depth + 1;

          expect(B1_CELL, findsOneWidget);
          expect(B1_EXPAND_ICON, findsNothing);
          expect(B1_SIZED_BOX_WIDGET.width, gap * depth);
        }

        // Group row
        {
          final B4_ROW = stateManager.refRows[5];
          expect(B4_ROW.cells.values.first.value, 'B4');

          final B4_CELL = find.ancestor(
            of: find.text('B4'),
            matching: find.byType(TrinaDefaultCell),
          );

          final B4_EXPAND_ICON = find.descendant(
            of: B4_CELL,
            matching: find.byType(IconButton),
          );

          final B4_SIZED_BOX = find
              .descendant(of: B4_CELL, matching: find.byType(SizedBox))
              .first;

          final B4_SIZED_BOX_WIDGET =
              B4_SIZED_BOX.evaluate().first.widget as SizedBox;

          final gap = stateManager.style.iconSize * 1.5;
          final depth = B4_ROW.depth;

          expect(B4_CELL, findsOneWidget);
          expect(B4_EXPAND_ICON, findsOneWidget);
          expect(B4_SIZED_BOX_WIDGET.width, gap * depth);
        }
      },
    );

    testWidgets('When B row is expanded, child rows should be rendered', (
      tester,
    ) async {
      rows[1].type.group.setExpanded(true);

      await buildGrid(
        tester: tester,
        columns: columns,
        rows: rows,
        delegate: TrinaRowGroupTreeDelegate(
          resolveColumnDepth: (column) =>
              int.parse(column.field.replaceAll('column', '')) - 1,
          showText: (cell) => true,
          showFirstExpandableIcon: true,
        ),
      );

      expect(find.text('B1'), findsOneWidget);
      expect(find.text('B2'), findsOneWidget);
      expect(find.text('B3'), findsOneWidget);
      expect(find.text('B4'), findsOneWidget);
    });

    testWidgets(
      'When B and B4 rows are expanded, child rows should be rendered',
      (tester) async {
        rows[1].type.group.setExpanded(true);
        rows[1].type.group.children[3].type.group.setExpanded(true);

        await buildGrid(
          tester: tester,
          columns: columns,
          rows: rows,
          delegate: TrinaRowGroupTreeDelegate(
            resolveColumnDepth: (column) =>
                int.parse(column.field.replaceAll('column', '')) - 1,
            showText: (cell) => true,
            showFirstExpandableIcon: true,
          ),
        );

        expect(find.text('B1'), findsOneWidget);
        expect(find.text('B2'), findsOneWidget);
        expect(find.text('B3'), findsOneWidget);
        expect(find.text('B4'), findsOneWidget);

        expect(find.text('B41'), findsOneWidget);
        expect(find.text('B42'), findsOneWidget);
        expect(find.text('B43'), findsOneWidget);
      },
    );
  });

  group('Row Grouping by Column Test', () {
    late List<TrinaColumn> columns;

    late List<TrinaRow> rows;

    setUp(() {
      columns = ColumnHelper.textColumn('column', count: 5, start: 1);

      rows = [
        createRow('A', 'a1', 'a1-1', 'a1-1', 'a1-1', columns),
        createRow('A', 'a1', 'a1-2', 'a1-2', 'a1-2', columns),
        createRow('A', 'a2', 'a2-1', 'a2-1', 'a2-1', columns),
        createRow('A', 'a2', 'a2-2', 'a2-2', 'a2-2', columns),
        createRow('A', 'a2', 'a2-3', 'a2-3', 'a2-3', columns),
        createRow('A', 'a3', 'a3-1', 'a3-1', 'a3-1', columns),
        createRow('B', 'b1', 'b1-1', 'b1-1', 'b1-1', columns),
        createRow('B', 'b1', 'b1-2', 'b1-2', 'b1-2', columns),
        createRow('B', 'b2', 'b2-1', 'b2-1', 'b2-1', columns),
        createRow('B', 'b2', 'b2-2', 'b2-2', 'b2-2', columns),
        createRow('B', 'b2', 'b2-3', 'b2-3', 'b2-3', columns),
        createRow('B', 'b3', 'b3-1', 'b3-1', 'b3-1', columns),
      ];
    });

    testWidgets(
      'When showFirstExpandableIcon is true, expand icon should be rendered in the first column',
      (tester) async {
        await buildGrid(
          tester: tester,
          columns: columns,
          rows: rows,
          delegate: TrinaRowGroupByColumnDelegate(
            columns: [columns[0], columns[1]],
            showFirstExpandableIcon: true,
          ),
        );

        // 2 columns to groupBy, then force the expand icon to the first column
        // hide the second column
        stateManager.hideColumn(columns[1], true);
        await tester.pumpAndSettle();

        final A_CELL = find.ancestor(
          of: find.text('A'),
          matching: find.byType(TrinaDefaultCell),
        );

        final A_CELL_OFFSET = tester.getTopLeft(A_CELL);

        final A_EXPAND_ICON = find.descendant(
          of: A_CELL,
          matching: find.byType(IconButton),
        );

        expect(A_CELL, findsOneWidget);
        expect(A_EXPAND_ICON, findsOneWidget);

        await tester.tap(A_EXPAND_ICON);
        await tester.pumpAndSettle();

        final A1_CELL = find.ancestor(
          of: find.text('a1'),
          matching: find.byType(TrinaDefaultCell),
        );

        final A1_EXPAND_ICON = find.descendant(
          of: A1_CELL,
          matching: find.byType(IconButton),
        );

        expect(A1_CELL, findsOneWidget);
        expect(A1_EXPAND_ICON, findsOneWidget);
        expect(tester.getTopLeft(A1_CELL).dx, A_CELL_OFFSET.dx);
      },
    );

    testWidgets(
      'When showFirstExpandableIcon is false, expand icon should be rendered in the correct column',
      (tester) async {
        await buildGrid(
          tester: tester,
          columns: columns,
          rows: rows,
          delegate: TrinaRowGroupByColumnDelegate(
            columns: [columns[0], columns[1]],
            showFirstExpandableIcon: false,
          ),
        );

        final A_CELL = find.ancestor(
          of: find.text('A'),
          matching: find.byType(TrinaDefaultCell),
        );

        final A_CELL_OFFSET = tester.getTopLeft(A_CELL);

        final A_EXPAND_ICON = find.descendant(
          of: A_CELL,
          matching: find.byType(IconButton),
        );

        expect(A_CELL, findsOneWidget);
        expect(A_EXPAND_ICON, findsOneWidget);

        await tester.tap(A_EXPAND_ICON);
        await tester.pumpAndSettle();

        final A1_CELL = find.ancestor(
          of: find.text('a1'),
          matching: find.byType(TrinaDefaultCell),
        );

        final A1_EXPAND_ICON = find.descendant(
          of: A1_CELL,
          matching: find.byType(IconButton),
        );

        expect(A1_CELL, findsOneWidget);
        expect(A1_EXPAND_ICON, findsOneWidget);
        expect(
          tester.getTopLeft(A1_CELL).dx,
          A_CELL_OFFSET.dx + TrinaGridSettings.columnWidth,
        );
      },
    );
  });
}
