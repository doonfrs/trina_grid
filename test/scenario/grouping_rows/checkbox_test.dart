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

  Finder findExpandIcon(String cellValue) {
    return find.descendant(
      of: find.ancestor(
        of: find.text(cellValue),
        matching: find.byType(TrinaDefaultCell),
      ),
      matching: find.byType(IconButton),
    );
  }

  Finder findAllCheckbox(String columnTitle) {
    return find.descendant(
      of: find.ancestor(
        of: find.text('column1'),
        matching: find.byType(TrinaColumnTitle),
      ),
      matching: find.byType(Checkbox),
    );
  }

  Checkbox findAllCheckboxWidget(String cellValue) {
    return findAllCheckbox(cellValue).first.evaluate().first.widget as Checkbox;
  }

  Finder findCheckbox(String cellValue) {
    return find.descendant(
      of: find.ancestor(
        of: find.text(cellValue),
        matching: find.byType(TrinaDefaultCell),
      ),
      matching: find.byType(Checkbox),
    );
  }

  Checkbox findCheckboxWidget(String cellValue) {
    return findCheckbox(cellValue).first.evaluate().first.widget as Checkbox;
  }

  group('Row Group Tree Delegate - 3 Level Grouping', () {
    late List<TrinaColumn> columns;

    late List<TrinaRow> rows;

    late TrinaRowGroupDelegate delegate;

    setUp(() {
      columns = [
        TrinaColumn(
          title: 'column1',
          field: 'column1',
          type: TrinaColumnType.text(),
          enableRowChecked: true,
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

      delegate = TrinaRowGroupTreeDelegate(
        resolveColumnDepth: (column) =>
            int.parse(column.field.replaceAll('column', '')) - 1,
        showText: (cell) => true,
      );
    });

    testWidgets(
      'When all checkboxes are checked, all groups and rows should be checked',
      (tester) async {
        await buildGrid(
          tester: tester,
          columns: columns,
          rows: rows,
          delegate: delegate,
        );

        final allCheckBox = findAllCheckbox('column1');
        expect(allCheckBox, findsOneWidget);

        await tester.tap(allCheckBox);
        await tester.pumpAndSettle();

        expect(findCheckboxWidget('A').value, true);
        expect(findCheckboxWidget('B').value, true);
        expect(findCheckboxWidget('C').value, true);
        expect(findCheckboxWidget('D').value, true);
        expect(findCheckboxWidget('E').value, true);
      },
    );

    testWidgets('When group E is checked, its child rows should be checked', (
      tester,
    ) async {
      await buildGrid(
        tester: tester,
        columns: columns,
        rows: rows,
        delegate: delegate,
      );

      // When all checkboxes are unchecked, the tristate is false
      expect(findAllCheckboxWidget('column1').value, false);

      await tester.tap(findCheckbox('E'));
      await tester.pumpAndSettle();

      // When one row is checked, the tristate is null
      expect(findAllCheckboxWidget('column1').value, null);

      expect(findCheckboxWidget('E').value, true);

      await tester.tap(findExpandIcon('E'));
      await tester.pumpAndSettle();

      expect(findCheckboxWidget('E1').value, true);
      expect(findCheckboxWidget('E2').value, true);
    });

    testWidgets(
      'When group E is checked and then row E1 is unchecked, the tristate of the all checkbox and group E checkbox should be null',
      (tester) async {
        await buildGrid(
          tester: tester,
          columns: columns,
          rows: rows,
          delegate: delegate,
        );

        await tester.tap(findCheckbox('E'));
        await tester.pumpAndSettle();

        await tester.tap(findExpandIcon('E'));
        await tester.pumpAndSettle();

        await tester.tap(findCheckbox('E1'));
        await tester.pumpAndSettle();

        expect(findAllCheckboxWidget('column1').value, null);
        expect(findCheckboxWidget('E').value, null);

        expect(findCheckboxWidget('E1').value, false);
        expect(findCheckboxWidget('E2').value, true);
      },
    );

    testWidgets(
      'When all checkboxes are checked and then a group is expanded, its child rows should be checked',
      (tester) async {
        await buildGrid(
          tester: tester,
          columns: columns,
          rows: rows,
          delegate: delegate,
        );

        final allCheckBox = findAllCheckbox('column1');
        expect(allCheckBox, findsOneWidget);

        await tester.tap(allCheckBox);
        await tester.pumpAndSettle();

        final B_GROUP_EXPAND_ICON = findExpandIcon('B');
        await tester.tap(B_GROUP_EXPAND_ICON);
        await tester.pumpAndSettle();

        expect(find.text('B1'), findsOneWidget);
        expect(find.text('B2'), findsOneWidget);
        expect(find.text('B3'), findsOneWidget);
        expect(find.text('B4'), findsOneWidget);
        expect(findCheckboxWidget('B1').value, true);
        expect(findCheckboxWidget('B2').value, true);
        expect(findCheckboxWidget('B3').value, true);
        expect(findCheckboxWidget('B4').value, true);

        // showFirstExpandableIcon is false, so the second column cell has an expand icon.
        final B4_GROUP_EXPAND_ICON = findExpandIcon('b4-1');
        await tester.tap(B4_GROUP_EXPAND_ICON);
        await tester.pumpAndSettle();

        expect(find.text('B41'), findsOneWidget);
        expect(find.text('B42'), findsOneWidget);
        expect(find.text('B43'), findsOneWidget);
        expect(findCheckboxWidget('B41').value, true);
        expect(findCheckboxWidget('B42').value, true);
        expect(findCheckboxWidget('B43').value, true);

        // showFirstExpandableIcon is false, so the third column cell has an expand icon.
        final B43_GROUP_EXPAND_ICON = findExpandIcon('b43-2');
        await tester.tap(B43_GROUP_EXPAND_ICON);
        await tester.pumpAndSettle();

        expect(find.text('B431'), findsOneWidget);
        expect(find.text('B432'), findsOneWidget);
        expect(findCheckboxWidget('B431').value, true);
        expect(findCheckboxWidget('B432').value, true);
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
