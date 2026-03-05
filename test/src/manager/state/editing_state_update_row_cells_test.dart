import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trina_grid/trina_grid.dart';

void main() {
  group('EditingState.updateRowCells', () {
    late TrinaGridStateManager stateManager;
    late List<TrinaColumn> columns;
    late List<TrinaRow> rows;

    setUp(() {
      columns = [
        TrinaColumn(title: 'Name', field: 'name', type: TrinaColumnType.text()),
        TrinaColumn(title: 'Age', field: 'age', type: TrinaColumnType.number()),
        TrinaColumn(
          title: 'Status',
          field: 'status',
          type: TrinaColumnType.text(),
        ),
      ];

      rows = [
        TrinaRow(
          cells: {
            'name': TrinaCell(value: 'Alice'),
            'age': TrinaCell(value: 30),
            'status': TrinaCell(value: 'active'),
          },
        ),
        TrinaRow(
          cells: {
            'name': TrinaCell(value: 'Bob'),
            'age': TrinaCell(value: 25),
            'status': TrinaCell(value: 'inactive'),
          },
        ),
      ];

      stateManager = TrinaGridStateManager(
        columns: columns,
        rows: rows,
        gridFocusNode: FocusNode(),
        scroll: TrinaGridScrollController(),
      );
    });

    test('should update multiple cells in a row', () {
      final row = rows[0];

      stateManager.updateRowCells(row, {'name': 'Charlie', 'age': 40});

      expect(row.cells['name']!.value, equals('Charlie'));
      expect(row.cells['age']!.value, equals(40));
      expect(row.cells['status']!.value, equals('active'));
    });

    test('should set row state to updated', () {
      final row = rows[0];

      stateManager.updateRowCells(row, {'name': 'Charlie'});

      expect(row.state, equals(TrinaRowState.updated));
    });

    test('should do nothing with empty values map', () {
      final row = rows[0];

      stateManager.updateRowCells(row, {});

      expect(row.cells['name']!.value, equals('Alice'));
    });

    test('should skip invalid field names', () {
      final row = rows[0];

      stateManager.updateRowCells(row, {
        'nonexistent_field': 'value',
        'name': 'Updated',
      });

      expect(row.cells['name']!.value, equals('Updated'));
    });

    test('should skip cells with same value', () {
      final row = rows[0];

      stateManager.updateRowCells(row, {
        'name': 'Alice', // same value
        'age': 99,
      });

      expect(row.cells['age']!.value, equals(99));
    });

    group('read-only columns', () {
      test('should skip read-only columns', () {
        final readOnlyColumns = [
          TrinaColumn(
            title: 'Name',
            field: 'name',
            type: TrinaColumnType.text(),
            readOnly: true,
          ),
          TrinaColumn(
            title: 'Age',
            field: 'age',
            type: TrinaColumnType.number(),
          ),
        ];

        final testRows = [
          TrinaRow(
            cells: {
              'name': TrinaCell(value: 'Alice'),
              'age': TrinaCell(value: 30),
            },
          ),
        ];

        final sm = TrinaGridStateManager(
          columns: readOnlyColumns,
          rows: testRows,
          gridFocusNode: FocusNode(),
          scroll: TrinaGridScrollController(),
          configuration: const TrinaGridConfiguration(
            columnSize: TrinaGridColumnSizeConfig(
              autoSizeMode: TrinaAutoSizeMode.none,
            ),
          ),
        );

        sm.updateRowCells(testRows[0], {'name': 'Updated', 'age': 40});

        expect(testRows[0].cells['name']!.value, equals('Alice'));
        expect(testRows[0].cells['age']!.value, equals(40));
      });
    });

    group('force parameter', () {
      test('should bypass checks when force is true', () {
        final readOnlyColumns = [
          TrinaColumn(
            title: 'Name',
            field: 'name',
            type: TrinaColumnType.text(),
            readOnly: true,
          ),
        ];

        final testRows = [
          TrinaRow(cells: {'name': TrinaCell(value: 'Alice')}),
        ];

        final sm = TrinaGridStateManager(
          columns: readOnlyColumns,
          rows: testRows,
          gridFocusNode: FocusNode(),
          scroll: TrinaGridScrollController(),
          configuration: const TrinaGridConfiguration(
            columnSize: TrinaGridColumnSizeConfig(
              autoSizeMode: TrinaAutoSizeMode.none,
            ),
          ),
        );

        sm.updateRowCells(testRows[0], {'name': 'Forced'}, force: true);

        expect(testRows[0].cells['name']!.value, equals('Forced'));
      });
    });

    group('validation', () {
      test('should skip cells that fail validation', () {
        final validatedColumns = [
          TrinaColumn(
            title: 'Name',
            field: 'name',
            type: TrinaColumnType.text(),
            validator: (value, context) {
              if (value == null || value.toString().isEmpty) {
                return 'Name cannot be empty';
              }
              return null;
            },
          ),
          TrinaColumn(
            title: 'Age',
            field: 'age',
            type: TrinaColumnType.number(),
          ),
        ];

        final testRows = [
          TrinaRow(
            cells: {
              'name': TrinaCell(value: 'Alice'),
              'age': TrinaCell(value: 30),
            },
          ),
        ];

        final sm = TrinaGridStateManager(
          columns: validatedColumns,
          rows: testRows,
          gridFocusNode: FocusNode(),
          scroll: TrinaGridScrollController(),
          configuration: const TrinaGridConfiguration(
            columnSize: TrinaGridColumnSizeConfig(
              autoSizeMode: TrinaAutoSizeMode.none,
            ),
          ),
        );

        sm.updateRowCells(testRows[0], {
          'name': '', // should fail validation
          'age': 40, // should succeed
        });

        expect(testRows[0].cells['name']!.value, equals('Alice'));
        expect(testRows[0].cells['age']!.value, equals(40));
      });

      test('should fire onValidationFailed callback', () {
        TrinaGridValidationEvent? validationEvent;

        final validatedColumns = [
          TrinaColumn(
            title: 'Name',
            field: 'name',
            type: TrinaColumnType.text(),
            validator: (value, context) {
              if (value == null || value.toString().isEmpty) {
                return 'Name cannot be empty';
              }
              return null;
            },
          ),
        ];

        final testRows = [
          TrinaRow(cells: {'name': TrinaCell(value: 'Alice')}),
        ];

        final sm = TrinaGridStateManager(
          columns: validatedColumns,
          rows: testRows,
          gridFocusNode: FocusNode(),
          scroll: TrinaGridScrollController(),
          configuration: const TrinaGridConfiguration(
            columnSize: TrinaGridColumnSizeConfig(
              autoSizeMode: TrinaAutoSizeMode.none,
            ),
          ),
          onValidationFailed: (event) {
            validationEvent = event;
          },
        );

        sm.updateRowCells(testRows[0], {'name': ''});

        expect(validationEvent, isNotNull);
        expect(validationEvent!.errorMessage, equals('Name cannot be empty'));
      });
    });

    group('change tracking', () {
      test('should track changes when enableChangeTracking is true', () {
        final sm = TrinaGridStateManager(
          columns: columns,
          rows: rows,
          gridFocusNode: FocusNode(),
          scroll: TrinaGridScrollController(),
        );
        sm.setChangeTracking(true);

        final cell = rows[0].cells['name']!;
        final originalValue = cell.value;

        sm.updateRowCells(rows[0], {'name': 'Updated'});

        expect(cell.isDirty, isTrue);
        expect(cell.originalValue, equals(originalValue));
      });
    });

    group('callbacks', () {
      test('should fire onChanged callbacks', () {
        final changedEvents = <TrinaGridOnChangedEvent>[];

        final sm = TrinaGridStateManager(
          columns: columns,
          rows: rows,
          gridFocusNode: FocusNode(),
          scroll: TrinaGridScrollController(),
          onChanged: (event) {
            changedEvents.add(event);
          },
        );

        sm.updateRowCells(rows[0], {'name': 'Updated', 'age': 99});

        expect(changedEvents.length, equals(2));
        expect(changedEvents[0].column.field, equals('name'));
        expect(changedEvents[0].value, equals('Updated'));
        expect(changedEvents[1].column.field, equals('age'));
        expect(changedEvents[1].value, equals(99));
      });

      test('should not fire callbacks when callOnChangedEvent is false', () {
        final changedEvents = <TrinaGridOnChangedEvent>[];

        final sm = TrinaGridStateManager(
          columns: columns,
          rows: rows,
          gridFocusNode: FocusNode(),
          scroll: TrinaGridScrollController(),
          onChanged: (event) {
            changedEvents.add(event);
          },
        );

        sm.updateRowCells(rows[0], {
          'name': 'Updated',
        }, callOnChangedEvent: false);

        expect(changedEvents.length, equals(0));
        expect(rows[0].cells['name']!.value, equals('Updated'));
      });

      test('should fire cell-level onChanged callback', () {
        TrinaGridOnChangedEvent? cellEvent;

        final testRows = [
          TrinaRow(
            cells: {
              'name': TrinaCell(
                value: 'Alice',
                onChanged: (event) {
                  cellEvent = event;
                },
              ),
              'age': TrinaCell(value: 30),
            },
          ),
        ];

        final sm = TrinaGridStateManager(
          columns: columns,
          rows: testRows,
          gridFocusNode: FocusNode(),
          scroll: TrinaGridScrollController(),
        );

        sm.updateRowCells(testRows[0], {'name': 'Updated'});

        expect(cellEvent, isNotNull);
        expect(cellEvent!.value, equals('Updated'));
        expect(cellEvent!.oldValue, equals('Alice'));
      });
    });
  });
}
