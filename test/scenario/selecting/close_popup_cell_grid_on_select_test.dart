import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trina_grid/trina_grid.dart';

import '../../helper/column_helper.dart';
import '../../helper/row_helper.dart';

void main() {
  Future<void> buildAndOpenPopup({
    required WidgetTester tester,
    required TrinaColumn column,
    required List<TrinaRow> rows,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: TrinaGrid(columns: [column], rows: rows),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final cell = rows.first.cells.values.first;
    final cellValue = cell.column.formattedValueForDisplay(cell.value);

    // Open the popup
    await tester.tap(find.text(cellValue)); // Set as current cell
    await tester.pump();
    await tester.tap(find.text(cellValue)); // Enter edit mode
    await tester.pump();
    await tester.tap(find.text(cellValue)); // Open popup
    await tester.pumpAndSettle();

    // Ensure the popup grid is visible
    expect(find.byType(TrinaGrid), findsNWidgets(2),
        reason: 'A second grid for the popup should be visible.');
  }

  void runTestCase({
    required String testName,
    required TrinaColumn column,
    required dynamic valueToSelect,
    required bool shouldPopupClose,
  }) {
    testWidgets(testName, (tester) async {
      final rows = RowHelper.count(1, [column]);

      await buildAndOpenPopup(
        tester: tester,
        column: column,
        rows: rows,
      );

      final formattedValue =
          column.formattedValueForDisplayInEditing(valueToSelect);

      // Find the popup grid and tap the value
      final popupGrid = find.byType(TrinaGrid).last;
      await tester.tap(find.descendant(
        of: popupGrid,
        matching: find.text(formattedValue),
      ));
      await tester.pumpAndSettle(Duration(seconds: 1));

      // Assert whether the popup closed
      if (shouldPopupClose) {
        expect(find.byType(TrinaGrid), findsOneWidget,
            reason: 'Popup grid should have closed after selection.');
      } else {
        expect(find.byType(TrinaGrid), findsNWidgets(2),
            reason: 'Popup grid should remain open after selection.');
      }
    });
  }

  group('TrinaSelectColumn popup', () {
    runTestCase(
      testName:
          'When selectWithSingleTap is true, tapping a value should close the popup.',
      shouldPopupClose: true,
      column: ColumnHelper.selectColumn(
        'select',
        items: ['one', 'two', 'three'],
        enableAutoEditing: false,
        selectWithSingleTap: true,
      ),
      valueToSelect: 'two',
    );

    runTestCase(
      testName:
          'When selectWithSingleTap is false, tapping a value should not close the popup.',
      shouldPopupClose: false,
      column: ColumnHelper.selectColumn(
        'select',
        items: ['one', 'two', 'three'],
        enableAutoEditing: false,
        selectWithSingleTap: false,
      ),
      valueToSelect: 'two',
    );
  });

  group('TrinaBooleanColumn popup', () {
    runTestCase(
      testName:
          'When selectWithSingleTap is true, tapping a value should close the popup.',
      shouldPopupClose: true,
      column: ColumnHelper.booleanColumn('boolean',
          initialValue: true, selectWithSingleTap: true),
      valueToSelect: true,
    );

    runTestCase(
      testName:
          'When selectWithSingleTap is false, tapping a value should not close the popup.',
      shouldPopupClose: false,
      column: ColumnHelper.booleanColumn(
        'boolean',
        initialValue: true,
        selectWithSingleTap: false,
      ),
      valueToSelect: true,
    );
  });

  group('TrinaDateColumn popup', () {
    final startingDate = DateTime.now();
    final valueToSelect =
        startingDate.add(const Duration(days: 1)).day.toString();

    runTestCase(
      testName:
          'When selectWithSingleTap is true, tapping a value should close the popup.',
      shouldPopupClose: true,
      column: ColumnHelper.dateColumn(
        'date',
        startDate: startingDate,
        selectWithSingleTap: true,
      ).first,
      valueToSelect: valueToSelect,
    );

    runTestCase(
      testName:
          'When selectWithSingleTap is false, tapping a value should not close the popup.',
      shouldPopupClose: false,
      column: ColumnHelper.dateColumn(
        'date',
        selectWithSingleTap: false,
        startDate: startingDate,
      ).first,
      valueToSelect: valueToSelect,
    );
  });
}
