import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trina_grid/trina_grid.dart';

void main() {
  group('EditingState.changeCellValue validate parameter', () {
    late TrinaGridStateManager stateManager;
    late List<TrinaColumn> columns;
    late List<TrinaRow> rows;

    setUp(() {
      columns = [
        TrinaColumn(
          title: 'Boolean Column',
          field: 'bool_field',
          type: TrinaColumnType.boolean(
            allowEmpty: false, // This will reject null values when validating
          ),
        ),
        TrinaColumn(
          title: 'Number Column',
          field: 'num_field',
          type: TrinaColumnType.number(),
        ),
        TrinaColumn(
          title: 'Text Column',
          field: 'text_field',
          type: TrinaColumnType.text(),
          validator: (value, context) {
            // Custom validator that rejects empty strings
            if (value == null || value.toString().isEmpty) {
              return 'Text cannot be empty';
            }
            return null;
          },
        ),
      ];

      rows = [
        TrinaRow(
          cells: {
            'bool_field': TrinaCell(value: true),
            'num_field': TrinaCell(value: 42),
            'text_field': TrinaCell(value: 'Initial Text'),
          },
        ),
        TrinaRow(
          cells: {
            'bool_field': TrinaCell(value: false),
            'num_field': TrinaCell(value: 100),
            'text_field': TrinaCell(value: 'Second Row'),
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

    group('Boolean field validation', () {
      test('should reject null value when validate is true (default)', () {
        final cell = rows[0].cells['bool_field']!;
        final originalValue = cell.value;

        // Try to set null with validation (should fail)
        stateManager.changeCellValue(
          cell,
          null,
          // validate: true is default
        );

        // Value should remain unchanged because validation failed
        expect(cell.value, equals(originalValue));
        expect(cell.value, isNot(null));
      });

      test('should accept null value when validate is false', () {
        final cell = rows[0].cells['bool_field']!;

        // Set null without validation (should succeed)
        stateManager.changeCellValue(cell, null, validate: false);

        // Value should be changed to null
        expect(cell.value, isNull);
      });

      test(
        'should accept valid boolean values regardless of validate parameter',
        () {
          final cell = rows[0].cells['bool_field']!;

          // With validation (should succeed)
          stateManager.changeCellValue(cell, false, validate: true);
          expect(cell.value, equals(false));

          // Without validation (should also succeed)
          stateManager.changeCellValue(cell, true, validate: false);
          expect(cell.value, equals(true));
        },
      );
    });

    group('Number field validation', () {
      test('should convert invalid number to 0 when validate is true', () {
        final cell = rows[0].cells['num_field']!;

        // Try to set invalid number with validation
        // It will pass validation but get converted to 0 during casting
        stateManager.changeCellValue(cell, 'not_a_number', validate: true);

        // Value should be converted to 0 (the default for invalid numbers)
        expect(cell.value, equals(0));
      });

      test('should accept invalid value as-is when validate is false', () {
        final cell = rows[0].cells['num_field']!;

        // Set invalid value without validation (should succeed without casting)
        stateManager.changeCellValue(
          cell,
          'bypassed_validation',
          validate: false,
        );

        // Value should be stored as-is without type casting
        expect(cell.value, equals('bypassed_validation'));
      });

      test(
        'should properly validate negative numbers when negative is false',
        () {
          // Create a column that doesn't allow negative numbers
          final nonNegativeColumn = TrinaColumn(
            title: 'Non-negative Number',
            field: 'non_neg',
            type: TrinaColumnType.number(negative: false),
          );

          final testRow = TrinaRow(cells: {'non_neg': TrinaCell(value: 10)});

          final testStateManager = TrinaGridStateManager(
            columns: [nonNegativeColumn],
            rows: [testRow],
            gridFocusNode: FocusNode(),
            scroll: TrinaGridScrollController(),
          );

          final cell = testRow.cells['non_neg']!;

          // Try to set negative number with validation (should fail)
          testStateManager.changeCellValue(cell, -5, validate: true);

          // Value should be converted to 0 (since negative is not allowed)
          expect(cell.value, equals(0));

          // But with validation bypassed, it should accept the negative value
          testStateManager.changeCellValue(cell, -5, validate: false);

          expect(cell.value, equals(-5));
        },
      );
    });

    group('Custom validator', () {
      test(
        'should reject empty string when validate is true with custom validator',
        () {
          final cell = rows[0].cells['text_field']!;
          final originalValue = cell.value;

          // Try to set empty string with validation (should fail due to custom validator)
          stateManager.changeCellValue(cell, '', validate: true);

          // Value should remain unchanged
          expect(cell.value, equals(originalValue));
        },
      );

      test(
        'should accept empty string when validate is false, bypassing custom validator',
        () {
          final cell = rows[0].cells['text_field']!;

          // Set empty string without validation (should succeed)
          stateManager.changeCellValue(cell, '', validate: false);

          // Value should be changed to empty string
          expect(cell.value, equals(''));
        },
      );
    });

    group('Validation failed callback', () {
      test('should trigger onValidationFailed when validation fails', () {
        TrinaGridValidationEvent? capturedEvent;

        stateManager = TrinaGridStateManager(
          columns: columns,
          rows: rows,
          gridFocusNode: FocusNode(),
          scroll: TrinaGridScrollController(),
          onValidationFailed: (event) {
            capturedEvent = event;
          },
        );

        final cell = rows[0].cells['bool_field']!;

        // Try to set null with validation (should fail and trigger callback)
        stateManager.changeCellValue(cell, null, validate: true);

        // Validation failed callback should have been called
        expect(capturedEvent, isNotNull);
        expect(capturedEvent!.column.field, equals('bool_field'));
        expect(capturedEvent!.value, isNull);
        expect(capturedEvent!.errorMessage, isNotNull);
      });

      test('should not trigger onValidationFailed when validate is false', () {
        TrinaGridValidationEvent? capturedEvent;

        stateManager = TrinaGridStateManager(
          columns: columns,
          rows: rows,
          gridFocusNode: FocusNode(),
          scroll: TrinaGridScrollController(),
          onValidationFailed: (event) {
            capturedEvent = event;
          },
        );

        final cell = rows[0].cells['bool_field']!;

        // Set null without validation (should not trigger callback)
        stateManager.changeCellValue(cell, null, validate: false);

        // Validation failed callback should NOT have been called
        expect(capturedEvent, isNull);
        // But the value should have changed
        expect(cell.value, isNull);
      });
    });

    group('Change tracking with validation bypass', () {
      test('should track changes even when validation is bypassed', () {
        stateManager = TrinaGridStateManager(
          columns: columns,
          rows: rows,
          gridFocusNode: FocusNode(),
          scroll: TrinaGridScrollController(),
        );

        // Enable change tracking
        stateManager.setChangeTracking(true);

        final cell = rows[0].cells['bool_field']!;
        final originalValue = cell.value;

        // Set invalid value without validation
        stateManager.changeCellValue(cell, null, validate: false);

        // Change should be tracked
        expect(cell.isDirty, isTrue);
        expect(cell.oldValue, equals(originalValue));
        expect(cell.value, isNull);
      });
    });

    group('OnChanged callback with validation bypass', () {
      test(
        'should trigger onChanged callback regardless of validate parameter',
        () {
          int onChangedCallCount = 0;
          TrinaGridOnChangedEvent? lastEvent;

          stateManager = TrinaGridStateManager(
            columns: columns,
            rows: rows,
            gridFocusNode: FocusNode(),
            scroll: TrinaGridScrollController(),
            onChanged: (event) {
              onChangedCallCount++;
              lastEvent = event;
            },
          );

          final cell = rows[0].cells['bool_field']!;

          // Test with validation bypassed
          stateManager.changeCellValue(cell, null, validate: false);

          expect(onChangedCallCount, equals(1));
          expect(lastEvent, isNotNull);
          expect(lastEvent!.value, isNull);
          expect(lastEvent!.cell, equals(cell));

          // Test with validation enabled (should fail, no callback)
          onChangedCallCount = 0;
          stateManager.changeCellValue(cell, 'invalid_bool', validate: true);

          // Should not trigger onChanged because validation failed
          expect(onChangedCallCount, equals(0));
        },
      );
    });

    group('Edge cases', () {
      test('validate parameter should default to true when not specified', () {
        final cell = rows[0].cells['bool_field']!;
        final originalValue = cell.value;

        // Call without specifying validate parameter
        stateManager.changeCellValue(cell, null);

        // Should behave as if validate: true (validation should prevent the change)
        expect(cell.value, equals(originalValue));
      });

      test('force parameter should work independently of validate parameter', () {
        final cell = rows[0].cells['bool_field']!;

        // Make cell read-only
        columns[0].readOnly = true;

        // Try to change with validate: false but without force (should fail due to readOnly)
        stateManager.changeCellValue(cell, null, validate: false, force: false);
        expect(cell.value, isNot(null));

        // Try with both validate: false and force: true (should succeed)
        stateManager.changeCellValue(cell, null, validate: false, force: true);
        expect(cell.value, isNull);
      });
    });
  });
}
