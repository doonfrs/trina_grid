import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trina_grid/src/ui/trina_base_cell.dart';
import 'package:trina_grid/trina_grid.dart';

import '../../helper/column_helper.dart';
import '../../helper/trina_widget_test_helper.dart';
import '../../helper/row_helper.dart';

void main() {
  late List<TrinaColumn> columns;

  late List<TrinaRow> rows;

  TrinaGridStateManager? stateManager;
  late TrinaCell cell;

  /// cell with `null` initial value
  late TrinaCell nullCell;

  final trinaGrid = TrinaWidgetTestHelper(
    'TrinaGrid with enabled Change Tracking is created',
    (tester) async {
      columns = [
        ...ColumnHelper.textColumn('header', count: 5),
      ];

      rows = RowHelper.count(1, columns);
      rows.first.cells[columns[2].field] = TrinaCell(value: null);

      nullCell = rows.first.cells.values.toList()[2];
      cell = rows.first.cells.values.first;

      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: TrinaGrid(
              columns: columns,
              rows: rows,
              configuration: TrinaGridConfiguration(
                enterKeyAction: TrinaGridEnterKeyAction.editingAndMoveRight,
              ),
              onLoaded: (TrinaGridOnLoadedEvent event) {
                stateManager = event.stateManager;
                stateManager!.setAutoEditing(true);
                stateManager!.setChangeTracking(true);
              },
            ),
          ),
        ),
      );
    },
  );
  group('Change Tracking Test', () {
    trinaGrid.test(
      'when cell value is not changed, the `cell.oldValue` should be null',
      (tester) async => expect(cell.oldValue, null),
    );
    trinaGrid.test(
      'when `cell.trackChange()` is called, `cell.isDirty` should be false',
      (tester) async {
        nullCell.trackChange();
        expect(nullCell.isDirty, false);

        cell.trackChange();
        expect(cell.isDirty, false);
      },
    );

    trinaGrid.test(
        'when cell value is changed, the cell color should be equal to `stateManager.configuration.style.cellDirtyColor`',
        (tester) async {
      final cellFinder = find.byType(TrinaBaseCell).first;
      await tester.tap(cellFinder);
      await tester.pumpAndSettle();

      await tester.enterText(cellFinder, 'New');
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();

      final decoration = tester
          .widget<DecoratedBox>(find.descendant(
              of: cellFinder, matching: find.byType(DecoratedBox)))
          .decoration as BoxDecoration;
      expect(
          decoration.color, stateManager!.configuration.style.cellDirtyColor);
    });

    trinaGrid
        .test('when cell value is changed, the `cell.isDirty` should be true',
            (tester) async {
      final cellFinder = find.byKey(cell.key).first;
      await tester.tap(cellFinder);
      await tester.pumpAndSettle();

      // assert cell is not dirty
      expect(cell.isDirty, false);

      const newCellValue = 'New';
      await tester.enterText(cellFinder, newCellValue);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      // Assert
      expect(cell.isDirty, true);
    });
    trinaGrid.test(
        'when cell value is changed, the `cell.oldValue` should be equal to the cell initial value',
        (tester) async {
      final cellFinder = find.byKey(cell.key).first;
      await tester.tap(cellFinder);
      await tester.pumpAndSettle();
      final initialValue = cell.value;

      await tester.enterText(cellFinder, 'New');
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      // Assert
      expect(cell.oldValue, initialValue);
    });
    trinaGrid.test(
        'when cell value is changed without committing then changed to its initial value, the cell should be clean',
        (tester) async {
      final initialValue = cell.value;
      final cellFinder = find.byKey(cell.key).first;

      // 1st change
      await tester.tap(cellFinder);
      await tester.pumpAndSettle();
      await tester.enterText(cellFinder, 'New');
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(cell.isDirty, true);

      // 2nd change back to the initial value
      await tester.tap(cellFinder);
      await tester.pumpAndSettle();
      await tester.enterText(cellFinder, initialValue);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();

      // Assert cell isn't dirty
      expect(cell.isDirty, false);
    });

    trinaGrid.test(
      'when a cell with value equal to `null` is changed, `cell.oldValue` should be `null`',
      (tester) async {
        final cellFinder = find.byKey(nullCell.key).first;
        await tester.tap(cellFinder);
        await tester.pumpAndSettle();
        expect(nullCell.isDirty, false);

        // change cell value from null to 'New'
        await tester.enterText(cellFinder, 'New');
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pumpAndSettle();

        expect(nullCell.isDirty, true);
        // Assert old value is null after changing the value
        expect(nullCell.oldValue, null);
      },
    );
    group('Pasting Into Table', () {
      trinaGrid
          .test('after pasting text into a cell, `cell.isDirty` should be true',
              (tester) async {
        final cellFinder = find.byKey(cell.key).first;
        await tester.tap(cellFinder);
        await tester.pumpAndSettle();
        // paste into current cell
        stateManager!.pasteCellValue([
          ['New']
        ]);
        // Assert old value is null after paste into cell
        expect(cell.isDirty, true);
      });
      trinaGrid.test(
          'after pasting text into a cell with `null` value, `cell.isDirty` should be `true`',
          (tester) async {
        final cellFinder = find.byKey(nullCell.key).first;
        await tester.tap(cellFinder);
        await tester.pumpAndSettle();

        expect(nullCell.isDirty, false);
        // change cell value from null to 'New'
        stateManager!.pasteCellValue([
          ['New']
        ]);
        // Assert
        expect(nullCell.isDirty, true);
      });
      trinaGrid.test(
          'after pasting text into a cell, the `cell.oldValue` should be set to cell initial value',
          (tester) async {
        final initialValue = cell.value;
        final cellFinder = find.byKey(cell.key).first;
        await tester.tap(cellFinder);
        await tester.pumpAndSettle();

        stateManager!.pasteCellValue([
          ['New']
        ]);
        // Assert old value is the initial value
        expect(cell.oldValue, initialValue);
      });
    });
  });
  group('Reverting changes', () {
    trinaGrid.test(
        'after reverting cell changes, the `cell.isDirty` should be false',
        (tester) async {
      final cellFinder = find.byKey(cell.key).first;
      await tester.tap(cellFinder);
      await tester.pumpAndSettle();

      await tester.enterText(cellFinder, 'New');
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      stateManager!.revertChanges();
      // Assert old value is null after reverting changes
      expect(cell.isDirty, false);
    });
    trinaGrid.test(
        'after reverting cell changes, the `cell.oldValue` should be null',
        (tester) async {
      final cellFinder = find.byKey(cell.key).first;
      await tester.tap(cellFinder);
      await tester.pumpAndSettle();

      await tester.enterText(cellFinder, 'New');
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      stateManager!.revertChanges();
      // Assert old value is null after reverting changes
      expect(cell.oldValue, null);
    });
    trinaGrid.test(
        'after reverting cell changes, the `cell.value` should equal its initial value',
        (tester) async {
      final initialValue = cell.value;
      final cellFinder = find.byKey(cell.key).first;
      await tester.tap(cellFinder);
      await tester.pumpAndSettle();

      await tester.enterText(cellFinder, 'New');
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();

      stateManager!.revertChanges();
      // Assert old value is null after reverting changes
      expect(cell.value, initialValue);
    });
    trinaGrid.test(
        'reverting changes should change the cell color back to its initial color',
        (tester) async {
      final cellFinder = find.byKey(cell.key).first;

      decoration() => tester
          .widget<DecoratedBox>(find.descendant(
              of: cellFinder, matching: find.byType(DecoratedBox)))
          .decoration as BoxDecoration;

      final initialCellColor = decoration().color;

      await tester.tap(cellFinder);
      await tester.pumpAndSettle();
      await tester.enterText(cellFinder, 'New');
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();

      expect(
          decoration().color, stateManager!.configuration.style.cellDirtyColor);

      stateManager!.revertChanges();
      await tester.pumpAndSettle();

      expect(decoration().color, initialCellColor);
    });
    trinaGrid.test(
        'calling `stateManager.revertChanges()` should revert all dirty cells changes',
        (tester) async {
      // We have to select the 1st cell in 1st row
      await tester.tap(find.byKey(cell.key));
      await tester.pumpAndSettle();

      // Then enter new values in first row cells one by one
      for (var cell in rows.first.cells.values) {
        final cellFinder = find.byKey(cell.key).first;
        await tester.enterText(cellFinder, 'New');
        // this is necessary to submit the new value
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pumpAndSettle();
        expect(cell.isDirty, true);
      }
      stateManager!.revertChanges();
      // assert all cells changes were reverted
      expect(
        stateManager!.rows.first.cells.values.every((cell) {
          return !cell.isDirty && cell.value == cell.originalValue;
        }),
        true,
      );
    });
  });

  group('Committing changes', () {
    trinaGrid.test(
        'committing changes should change the cell color back to its initial color',
        (tester) async {
      final cellFinder = find.byKey(cell.key).first;

      decoration() => tester
          .widget<DecoratedBox>(find.descendant(
              of: cellFinder, matching: find.byType(DecoratedBox)))
          .decoration as BoxDecoration;

      final initialCellColor = decoration().color;

      await tester.tap(cellFinder);
      await tester.pumpAndSettle();
      await tester.enterText(cellFinder, 'New');
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();

      expect(
          decoration().color, stateManager!.configuration.style.cellDirtyColor);

      stateManager!.commitChanges();
      await tester.pumpAndSettle();

      expect(decoration().color, initialCellColor);
    });
    trinaGrid.test(
      'calling `stateManager.commitChanges()` should commit all dirty cells changes',
      (tester) async {
        // We have to select the 1st cell in 1st row
        await tester.tap(find.byKey(cell.key));
        await tester.pumpAndSettle();

        // Then enter new values in first row cells one by one
        for (var cell in rows.first.cells.values) {
          final cellFinder = find.byKey(cell.key).first;
          await tester.enterText(cellFinder, 'New');
          // necessary to submit the new value
          await tester.sendKeyEvent(LogicalKeyboardKey.enter);
          await tester.pumpAndSettle();
          expect(cell.isDirty, true);
        }
        stateManager!.commitChanges();
        // assert all cells changes were committed
        expect(
          rows.first.cells.values
              .every((cell) => !cell.isDirty && cell.value == 'New'),
          true,
        );
      },
    );
    trinaGrid.test(
        'after committing cell changes, the `cell.isDirty` should be false',
        (tester) async {
      final cellFinder = find.byKey(cell.key).first;
      await tester.tap(cellFinder);
      await tester.pumpAndSettle();

      // assert cell is not dirty before committing
      expect(cell.isDirty, false);

      await tester.enterText(cellFinder, 'New');
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();

      // Assert cell is dirty after changing the value & before committing
      expect(cell.isDirty, true);

      stateManager!.commitChanges();
      // Assert cell is not dirty after commitChanges
      expect(cell.isDirty, false);
    });
    trinaGrid
        .test('after committing cell changes, `cell.oldValue` should be null',
            (tester) async {
      final cellFinder = find.byKey(cell.key).first;
      await tester.tap(cellFinder);
      await tester.pumpAndSettle();

      await tester.enterText(cellFinder, 'New');
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();

      stateManager!.commitChanges();
      // Assert old value is null after committing changes
      expect(cell.oldValue, null);
    });
  });
}
