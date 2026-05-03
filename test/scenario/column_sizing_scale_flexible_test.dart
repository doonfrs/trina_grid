import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trina_grid/trina_grid.dart';

void main() {
  group('Column Sizing - Scale Only Flexible Columns', () {
    testWidgets(
      'With scaleOnlyFlexibleColumns: true, explicit-width columns stay fixed while flexible columns scale',
      (WidgetTester tester) async {
        const double gridWidth = 600.0;
        const double explicitWidth = 80.0;

        final List<TrinaColumn> columns = [
          TrinaColumn(
            title: 'ID',
            field: 'id',
            type: TrinaColumnType.number(),
            width: explicitWidth, // Explicit width
          ),
          TrinaColumn(
            title: 'Name',
            field: 'name',
            type: TrinaColumnType.text(),
            // No explicit width - should scale
          ),
          TrinaColumn(
            title: 'Email',
            field: 'email',
            type: TrinaColumnType.text(),
            // No explicit width - should scale
          ),
        ];

        final List<TrinaRow> rows = [
          TrinaRow(
            cells: {
              'id': TrinaCell(value: 1),
              'name': TrinaCell(value: 'Alice'),
              'email': TrinaCell(value: 'alice@example.com'),
            },
          ),
        ];

        final widget = MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: gridWidth,
              height: 600,
              child: TrinaGrid(
                columns: columns,
                rows: rows,
                configuration: const TrinaGridConfiguration(
                  columnSize: TrinaGridColumnSizeConfig(
                    autoSizeMode: TrinaAutoSizeMode.scale,
                    scaleOnlyFlexibleColumns: true,
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.pumpWidget(widget);
        await tester.pumpAndSettle();

        // The ID column should be at its explicit width (80)
        expect(columns[0].width, equals(explicitWidth));

        // The Name and Email columns should share the remaining space proportionally
        // Available width accounts for scrollbar and padding (~16px), so 600 - 16 = 584
        // Remaining after ID = 584 - 80 = 504
        // Each flexible column should get 504 / 2 = 252
        const expectedFlexibleWidth = 252.0;

        expect(columns[1].width, closeTo(expectedFlexibleWidth, 1.0));
        expect(columns[2].width, closeTo(expectedFlexibleWidth, 1.0));
      },
    );

    testWidgets(
      'With scaleOnlyFlexibleColumns: false (default), all columns scale',
      (WidgetTester tester) async {
        const double gridWidth = 600.0;

        final List<TrinaColumn> columns = [
          TrinaColumn(
            title: 'ID',
            field: 'id',
            type: TrinaColumnType.number(),
            width: 80.0, // Explicit width
          ),
          TrinaColumn(
            title: 'Name',
            field: 'name',
            type: TrinaColumnType.text(),
            // Default width
          ),
          TrinaColumn(
            title: 'Email',
            field: 'email',
            type: TrinaColumnType.text(),
            // Default width
          ),
        ];

        final List<TrinaRow> rows = [
          TrinaRow(
            cells: {
              'id': TrinaCell(value: 1),
              'name': TrinaCell(value: 'Alice'),
              'email': TrinaCell(value: 'alice@example.com'),
            },
          ),
        ];

        final widget = MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: gridWidth,
              height: 600,
              child: TrinaGrid(
                columns: columns,
                rows: rows,
                configuration: const TrinaGridConfiguration(
                  columnSize: TrinaGridColumnSizeConfig(
                    autoSizeMode: TrinaAutoSizeMode.scale,
                    scaleOnlyFlexibleColumns: false, // Default behavior
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.pumpWidget(widget);
        await tester.pumpAndSettle();

        // All columns should scale proportionally based on their initial widths
        // Total initial width = 80 + 200 + 200 = 480
        // Available width = 584 (accounting for scrollbar and padding)
        // Scale factor = 584 / 480 = 1.21666...
        // ID column: 80 * 1.21666... = 97.33
        // Name column: 200 * 1.21666... = 243.33
        // Email column: 200 * 1.21666... = 243.33

        expect(columns[0].width, closeTo(97.33, 1.0));
        expect(columns[1].width, closeTo(243.33, 1.0));
        expect(columns[2].width, closeTo(243.33, 1.0));
      },
    );

    testWidgets('hasExplicitWidth is set correctly on columns', (
      WidgetTester tester,
    ) async {
      final List<TrinaColumn> columns = [
        TrinaColumn(
          title: 'ID',
          field: 'id',
          type: TrinaColumnType.number(),
          width: 80.0, // Explicit width
        ),
        TrinaColumn(
          title: 'Name',
          field: 'name',
          type: TrinaColumnType.text(),
          // No explicit width
        ),
      ];

      // Column with explicit width should have hasExplicitWidth = true
      expect(columns[0].hasExplicitWidth, isTrue);

      // Column without explicit width should have hasExplicitWidth = false
      expect(columns[1].hasExplicitWidth, isFalse);
    });
  });
}
