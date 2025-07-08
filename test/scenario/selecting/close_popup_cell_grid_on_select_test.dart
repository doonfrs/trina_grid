import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trina_grid/trina_grid.dart';

import '../../helper/column_helper.dart';
import '../../helper/row_helper.dart';

void main() {
  Future<void> build({
    required WidgetTester tester,
    required List<TrinaColumn> columns,
    required List<TrinaRow> rows,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: TrinaGrid(columns: columns, rows: rows),
        ),
      ),
    );
  }

  testCase({
    required TrinaColumn column,
    required dynamic valueToSelect,
    required bool assertPopupShouldClose,
  }) async {
    final rows = RowHelper.count(1, [column]);
    testWidgets(
      assertPopupShouldClose
          ? 'WHEN selectWithSingleTap is true, '
              'tapping a cell should close the popup.'
          : 'WHEN selectWithSingleTap is false, '
              'tapping a cell should not close the popup.',
      (tester) async {
        await build(
          columns: [column],
          rows: rows,
          tester: tester,
        );
        final cell = rows.first.cells.values.first;
        final cellValue =
            cell.column.formattedValueForDisplay(cell.value).toString();

        await tester.tap(find.text(cellValue)); // set as current cell
        await tester.pump();
        await tester.tap(find.text(cellValue)); // enter edit mode
        await tester.pump();
        await tester.tap(find.text(cellValue)); // open popup
        await tester.pumpAndSettle(Duration(milliseconds: 500));

        expect(find.byType(TrinaGrid), findsNWidgets(2));
        valueToSelect = column.formattedValueForDisplayInEditing(valueToSelect);
        await tester.tap(find.text(valueToSelect).first, warnIfMissed: false);
        await tester.pumpAndSettle(Duration(milliseconds: 500));
        assertPopupShouldClose
            ? expect(find.byType(TrinaGrid), findsOneWidget)
            : expect(find.byType(TrinaGrid), findsNWidgets(2));
      },
    );
  }

  group('popup cell in a TrinaSelectColumn, ', () {
    testCase(
      assertPopupShouldClose: true,
      column: ColumnHelper.selectColumn(
        'select',
        items: ['one', 'two', 'three'],
        enableAutoEditing: false,
        selectWithSingleTap: true,
      ),
      valueToSelect: 'two',
    );
    testCase(
      assertPopupShouldClose: false,
      column: ColumnHelper.selectColumn(
        'select',
        items: ['one', 'two', 'three'],
        enableAutoEditing: false,
        selectWithSingleTap: false,
      ),
      valueToSelect: 'two',
    );
  });
  group('popup cell in a TrinaBooleanColumn, ', () {
    testCase(
      assertPopupShouldClose: true,
      column: ColumnHelper.booleanColumn('boolean', selectWithSingleTap: true),
      valueToSelect: true,
    );
    testCase(
      assertPopupShouldClose: false,
      column: ColumnHelper.booleanColumn('boolean', selectWithSingleTap: false),
      valueToSelect: false,
    );
  });
  group('popup cell in a TrinaDateColumn, ', () {
    final startingDate = DateTime.now();
    final valueToSelect =
        startingDate.add(const Duration(days: 1)).day.toString();
    testCase(
      assertPopupShouldClose: true,
      column: ColumnHelper.dateColumn(
        'date',
        startDate: startingDate,
        selectWithSingleTap: true,
      ).first,
      valueToSelect: valueToSelect,
    );
    testCase(
      assertPopupShouldClose: false,
      column: ColumnHelper.dateColumn(
        'date',
        selectWithSingleTap: false,
        startDate: startingDate,
      ).first,
      valueToSelect: valueToSelect,
    );
  });
}
