import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trina_grid/src/ui/trina_base_cell.dart';
import 'package:trina_grid/trina_grid.dart';

import '../../helper/column_helper.dart';
import '../../helper/row_helper.dart';

/// Verifies how cell decoration responds to grid focus changes and the
/// [TrinaGridStyleConfig.unfocusedSelectionColor] option.
void main() {
  Future<TrinaGridStateManager> pumpGrid(
    WidgetTester tester, {
    Color? unfocusedSelectionColor,
    TrinaGridSelectingMode selectingMode = TrinaGridSelectingMode.cell,
  }) async {
    late TrinaGridStateManager stateManager;
    final columns = ColumnHelper.textColumn('header', count: 3);
    final rows = RowHelper.count(3, columns);

    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: TrinaGrid(
            columns: columns,
            rows: rows,
            configuration: TrinaGridConfiguration(
              style: TrinaGridStyleConfig(
                unfocusedSelectionColor: unfocusedSelectionColor,
              ),
            ),
            onLoaded: (event) {
              stateManager = event.stateManager;
              stateManager.setSelectingMode(selectingMode);
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return stateManager;
  }

  Color? cellColorAt(WidgetTester tester, int index) {
    final cellFinder = find.byType(TrinaBaseCell).at(index);
    final decoration =
        tester
                .widget<DecoratedBox>(
                  find.descendant(
                    of: cellFinder,
                    matching: find.byType(DecoratedBox),
                  ),
                )
                .decoration
            as BoxDecoration;
    return decoration.color;
  }

  testWidgets(
    'current cell falls back to gridBackgroundColor on focus loss when '
    'unfocusedSelectionColor is not configured',
    (tester) async {
      final stateManager = await pumpGrid(tester);
      final defaultGridBg = stateManager.style.gridBackgroundColor;

      await tester.tap(find.byType(TrinaBaseCell).first);
      await tester.pumpAndSettle();

      stateManager.setKeepFocus(false);
      await tester.pumpAndSettle();

      expect(cellColorAt(tester, 0), defaultGridBg);
    },
  );

  testWidgets(
    'current cell uses unfocusedSelectionColor on focus loss when configured',
    (tester) async {
      const configured = Color(0xFF8E44AD);
      final stateManager = await pumpGrid(
        tester,
        unfocusedSelectionColor: configured,
      );

      await tester.tap(find.byType(TrinaBaseCell).first);
      await tester.pumpAndSettle();

      stateManager.setKeepFocus(false);
      await tester.pumpAndSettle();

      expect(cellColorAt(tester, 0), configured);
    },
  );

  testWidgets('multi-cell selection uses unfocusedSelectionColor on focus loss', (
    tester,
  ) async {
    const configured = Color(0xFF8E44AD);
    final stateManager = await pumpGrid(
      tester,
      unfocusedSelectionColor: configured,
    );

    stateManager.setCurrentCell(stateManager.rows[0].cells['header0'], 0);
    stateManager.setCurrentSelectingPosition(
      cellPosition: const TrinaGridCellPosition(columnIdx: 1, rowIdx: 1),
    );
    await tester.pumpAndSettle();

    stateManager.setKeepFocus(false);
    await tester.pumpAndSettle();

    // Cell at row 1, column 1 is selected (not current). Index = row * cols + col.
    expect(cellColorAt(tester, 1 * 3 + 1), configured);
  });

  testWidgets('multi-cell selection keeps activatedColor on focus loss when '
      'unfocusedSelectionColor is not configured (regression guard)', (
    tester,
  ) async {
    final stateManager = await pumpGrid(tester);
    final activated = stateManager.style.activatedColor;

    stateManager.setCurrentCell(stateManager.rows[0].cells['header0'], 0);
    stateManager.setCurrentSelectingPosition(
      cellPosition: const TrinaGridCellPosition(columnIdx: 1, rowIdx: 1),
    );
    await tester.pumpAndSettle();

    stateManager.setKeepFocus(false);
    await tester.pumpAndSettle();

    expect(cellColorAt(tester, 1 * 3 + 1), activated);
  });
}
