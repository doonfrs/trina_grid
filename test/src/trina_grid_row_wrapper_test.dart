import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trina_grid/trina_grid.dart';

import '../helper/column_helper.dart';
import '../helper/row_helper.dart';

void main() {
  group('TrinaGrid rowWrapper', () {
    late List<TrinaColumn> columns;
    late List<TrinaRow> rows;

    setUp(() {
      columns = ColumnHelper.textColumn('header', count: 3);
      rows = RowHelper.count(3, columns);

      // Set specific values for testing
      rows[0].cells['header0']!.value = 'Row 1 Data';
      rows[1].cells['header0']!.value = 'Row 2 Data';
      rows[2].cells['header0']!.value = 'Row 3 Data';
    });

    testWidgets(
      'rowWrapper should receive correct parameters including rowData',
      (WidgetTester tester) async {
        // Captured parameters from rowWrapper callback
        BuildContext? capturedContext;
        Widget? capturedRowWidget;
        TrinaRow? capturedRowData;
        TrinaGridStateManager? capturedStateManager;
        int callCount = 0;

        await tester.pumpWidget(
          MaterialApp(
            home: Material(
              child: TrinaGrid(
                columns: columns,
                rows: rows,
                rowWrapper: (context, rowWidget, rowData, stateManager) {
                  callCount++;
                  capturedContext = context;
                  capturedRowWidget = rowWidget;
                  capturedRowData = rowData;
                  capturedStateManager = stateManager;

                  return Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.blue),
                    ),
                    child: rowWidget,
                  );
                },
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Verify rowWrapper was called
        expect(callCount, greaterThan(0));

        // Verify parameters are not null
        expect(capturedContext, isNotNull);
        expect(capturedRowWidget, isNotNull);
        expect(capturedRowData, isNotNull);
        expect(capturedStateManager, isNotNull);

        // Verify rowData contains expected cell data
        expect(capturedRowData!.cells, isNotEmpty);
        expect(capturedRowData!.cells.containsKey('header0'), isTrue);
      },
    );

    testWidgets(
      'rowWrapper should be called for each visible row with correct row data',
      (WidgetTester tester) async {
        final List<TrinaRow> capturedRowData = [];

        await tester.pumpWidget(
          MaterialApp(
            home: Material(
              child: TrinaGrid(
                columns: columns,
                rows: rows,
                rowWrapper: (context, rowWidget, rowData, stateManager) {
                  capturedRowData.add(rowData);

                  return Container(
                    decoration: BoxDecoration(
                      color: rowData.cells['header0']?.value == 'Row 1 Data'
                          ? Colors.red.withValues(alpha: 0.1)
                          : Colors.blue.withValues(alpha: 0.1),
                    ),
                    child: rowWidget,
                  );
                },
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Verify we captured row data for visible rows
        expect(capturedRowData, isNotEmpty);

        // Verify each captured row has the expected data
        final capturedValues = capturedRowData
            .map((row) => row.cells['header0']?.value)
            .toList();

        expect(capturedValues, contains('Row 1 Data'));
        expect(capturedValues, contains('Row 2 Data'));
        expect(capturedValues, contains('Row 3 Data'));

        // Verify the grid still displays the data correctly
        expect(find.text('Row 1 Data'), findsOneWidget);
        expect(find.text('Row 2 Data'), findsOneWidget);
        expect(find.text('Row 3 Data'), findsOneWidget);
      },
    );

    testWidgets('rowWrapper can apply conditional styling based on row data', (
      WidgetTester tester,
    ) async {
      bool firstRowFound = false;
      bool otherRowFound = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: TrinaGrid(
              columns: columns,
              rows: rows,
              rowWrapper: (context, rowWidget, rowData, stateManager) {
                final isFirstRow =
                    rowData.cells['header0']?.value == 'Row 1 Data';

                if (isFirstRow) {
                  firstRowFound = true;
                } else {
                  otherRowFound = true;
                }

                return Container(
                  decoration: BoxDecoration(
                    color: isFirstRow ? Colors.yellow : Colors.transparent,
                    border: Border.all(
                      color: isFirstRow ? Colors.red : Colors.grey,
                      width: isFirstRow ? 2 : 1,
                    ),
                  ),
                  child: rowWidget,
                );
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify conditional logic was executed for different rows
      expect(
        firstRowFound,
        isTrue,
        reason: 'First row should have been processed',
      );
      expect(
        otherRowFound,
        isTrue,
        reason: 'Other rows should have been processed',
      );

      // Verify the grid still displays the data correctly after wrapping
      expect(find.text('Row 1 Data'), findsOneWidget);
      expect(find.text('Row 2 Data'), findsOneWidget);
      expect(find.text('Row 3 Data'), findsOneWidget);
    });

    testWidgets('grid works correctly without rowWrapper', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: TrinaGrid(
              columns: columns,
              rows: rows,
              // No rowWrapper provided
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify grid renders correctly without rowWrapper
      expect(find.text('Row 1 Data'), findsOneWidget);
      expect(find.text('Row 2 Data'), findsOneWidget);
      expect(find.text('Row 3 Data'), findsOneWidget);
    });
  });
}
