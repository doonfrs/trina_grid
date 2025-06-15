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

  final trinaGrid = TrinaWidgetTestHelper(
    'TrinaGrid with enabled Change Tracking is created',
    (tester) async {
      columns = [
        ...ColumnHelper.textColumn('header', count: 5),
      ];

      rows = RowHelper.count(1, columns);
      cell = rows.first.cells.values.first;
      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: TrinaGrid(
              columns: columns,
              rows: rows,
              onLoaded: (TrinaGridOnLoadedEvent event) {
                stateManager = event.stateManager;
                stateManager!.setAutoEditing(true);
                stateManager!.setSelectingMode(TrinaGridSelectingMode.cell);
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
      (tester) async {
        expect(cell.oldValue, null);
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
        'when cell value is changed without committing then changed to the initial value, the `cell.isDirty` should be false',
        (tester) async {
      final initialValue = cell.value;
      final cellFinder = find.byKey(cell.key).first;
      await tester.tap(cellFinder);
      await tester.pumpAndSettle();
      // 1st change
      await tester.enterText(cellFinder, 'New');
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      // Assert
      expect(cell.isDirty, true);
      // 2nd change to the initial value
      await tester.enterText(cellFinder, initialValue);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      // Assert
      expect(cell.isDirty, false);
    });
    trinaGrid.test(
        'when cell value is changed without committing then changed to the initial value, the `cell.oldValue` should be null',
        (tester) async {
      final initialValue = cell.value;
      final cellFinder = find.byKey(cell.key).first;
      await tester.tap(cellFinder);
      await tester.pumpAndSettle();
      // 1st change
      await tester.enterText(cellFinder, 'New');
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      // Assert
      expect(cell.oldValue, initialValue);
      // 2nd change to the initial value
      await tester.enterText(cellFinder, initialValue);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      // Assert
      expect(cell.oldValue, null);
    });
    trinaGrid.test(
      'when a cell with value equal to `null` is changed, the `cell.isDirty` should be `true` and `cell.oldValue` should be `null`',
      (tester) async {
        final cellFinder = find.byKey(cell.key).first;
        await tester.tap(cellFinder);
        await tester.pumpAndSettle();
        cell.trackChange();
        // set cell value to null
        cell.value = null;
        expect(cell.isDirty, true);
        cell.commitChanges();
        expect(cell.isDirty, false);
        // change cell value from null to 'New'
        await tester.enterText(cellFinder, 'New');
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pumpAndSettle();
        // Assert cell is dirty after changing the value
        expect(cell.isDirty, true);
        // Assert old value is null after changing the value
        expect(cell.oldValue, null);
      },
    );
    group('Pasting Into Table', () {
      trinaGrid
          .test('after pasting into a cell, the `cell.isDirty` should be true',
              (tester) async {
        final cellFinder = find.byKey(cell.key).first;
        await tester.tap(cellFinder);
        await tester.pumpAndSettle();

        stateManager!.pasteCellValue([
          ['New']
        ]);
        // Assert old value is null after paste into cell
        expect(cell.isDirty, true);
      });
      trinaGrid.test(
          'after pasting into a cell with null value, the `cell.isDirty` should be `true` and `cell.oldValue` should be `null`',
          (tester) async {
        final cellFinder = find.byKey(cell.key).first;
        await tester.tap(cellFinder);
        await tester.pumpAndSettle();

        cell.trackChange();
        // set cell value to null
        cell.value = null;
        expect(cell.isDirty, true);
        cell.commitChanges();
        expect(cell.isDirty, false);
        // change cell value from null to 'New'
        stateManager!.pasteCellValue([
          ['New']
        ]);

        // Assert
        expect(cell.isDirty, true);
        expect(cell.oldValue, null);
      });
      trinaGrid.test(
          'after pasting into a cell, the `cell.oldValue` should be the initial cell value',
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
        'after a dirty-cell revertChanges is called, the `cell.isDirty` should be false',
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
        'after a dirty-cell revertChanges is called, the `cell.oldValue` should be null',
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
  });

  group('Committing changes', () {
    trinaGrid.test(
        'after a dirty-cell commitChanges is called, the `cell.isDirty` should be false',
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
    trinaGrid.test(
        'when a dirty-cell commitChanges is called, the `cell.oldValue` should be null',
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
