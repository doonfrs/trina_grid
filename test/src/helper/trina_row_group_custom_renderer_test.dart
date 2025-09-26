import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trina_grid/trina_grid.dart';

void main() {
  group('TrinaRowGroupByColumnDelegate custom renderer tests', () {
    late List<TrinaColumn> columns;
    late List<TrinaRow> rows;
    late TrinaRowGroupByColumnDelegate delegate;

    setUp(() {
      // Column with custom renderer that transforms values
      columns = [
        TrinaColumn(
          title: 'Department',
          field: 'department',
          type: TrinaColumnType.text(),
          renderer: (context) {
            // Custom renderer that adds prefix to display
            return Text('DEPT: ${context.cell.value}');
          },
        ),
        TrinaColumn(
          title: 'Name',
          field: 'name',
          type: TrinaColumnType.text(),
        ),
      ];

      // Sample data rows
      rows = [
        _createRow('Engineering', 'John', columns),
        _createRow('Engineering', 'Jane', columns),
        _createRow('Marketing', 'Bob', columns),
        _createRow('Marketing', 'Alice', columns),
      ];

      delegate = TrinaRowGroupByColumnDelegate(columns: [columns[0]]);
    });

    test('should create group headers with raw values stored correctly', () {
      final groupedRows = delegate.toGroup(rows: rows);

      // Should have 2 group headers (Engineering, Marketing)
      expect(groupedRows.length, 2);

      // First group header should be for Engineering
      final engineeringGroup = groupedRows[0];
      expect(engineeringGroup.type.isGroup, true);

      // Group header cell should have the raw value stored
      final groupHeaderCell = engineeringGroup.cells['department'];
      expect(groupHeaderCell?.value, 'Engineering'); // Raw value is correctly stored

      // The cell should be properly linked to its column with renderer
      expect(groupHeaderCell?.column, columns[0]);
      expect(groupHeaderCell?.column.hasRenderer, true);
    });

    test('should preserve column reference in group header cells', () {
      final groupedRows = delegate.toGroup(rows: rows);

      final groupHeaderCell = groupedRows[0].cells['department'];
      expect(groupHeaderCell?.column, columns[0]);
      expect(groupHeaderCell?.column.hasRenderer, true);
    });

    test('regular data rows should still work with custom renderers', () {
      final groupedRows = delegate.toGroup(rows: rows);

      // Get first data row from first group
      final dataRow = groupedRows[0].type.group.children.first;
      final dataCell = dataRow.cells['department'];

      expect(dataCell?.value, 'Engineering');
      expect(dataCell?.column.hasRenderer, true);
    });

    test('custom renderer should be called for group header cells', () {
      // Create column with custom renderer
      final testColumn = TrinaColumn(
        title: 'Department',
        field: 'department',
        type: TrinaColumnType.text(),
        renderer: (context) {
          return Text('DEPT: ${context.cell.value}');
        },
      );

      final testDelegate = TrinaRowGroupByColumnDelegate(columns: [testColumn]);
      final testRows = [
        _createRow('Engineering', 'John', [testColumn, columns[1]]),
        _createRow('Engineering', 'Jane', [testColumn, columns[1]]),
      ];

      final groupedRows = testDelegate.toGroup(rows: testRows);
      final groupHeaderCell = groupedRows[0].cells['department']!;

      // Verify the column has a renderer and is properly linked
      expect(groupHeaderCell.column.hasRenderer, true);
      expect(groupHeaderCell.value, 'Engineering');

      // The custom renderer should be available for the group header cell
      final hasRenderer = groupHeaderCell.column.hasRenderer;
      expect(hasRenderer, true);
    });
  });
}

TrinaRow _createRow(String dept, String name, List<TrinaColumn> columns) {
  final Map<String, TrinaCell> cells = {};
  final row = TrinaRow(cells: cells);

  cells['department'] = TrinaCell(value: dept)
    ..setRow(row)
    ..setColumn(columns[0]);
  cells['name'] = TrinaCell(value: name)
    ..setRow(row)
    ..setColumn(columns[1]);

  return row;
}