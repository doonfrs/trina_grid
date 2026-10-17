// End to end tests for #303: the current row must stay visible after the
// grid loses focus to a form field next to it.
//
// While the grid has focus, the whole current row is painted with
// activatedColor. When focus moved to a text field outside the grid, the row
// went back to its normal color and only the current cell kept a tint
// (unfocusedSelectionColor), so it was hard to tell which row was selected.
//
// Run with:
//   cd example
//   flutter test integration_test/issue_303_unfocused_current_row_test.dart -d windows

// ignore_for_file: implementation_imports

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trina_grid/trina_grid.dart';

import 'e2e_harness.dart';

void main() {
  ensureE2EBinding();

  late TrinaGridStateManager stateManager;

  const outsideKey = ValueKey('outside-field');
  const activatedColor = Color(0xFFDCF5FF);
  const unfocusedColor = Color(0xFFFFE0B2);
  const rowColor = Colors.white;

  /// A form field next to a grid, like the screenshot in the report.
  Widget buildApp({
    Color? unfocusedSelectionColor,
    TrinaGridSelectingMode selectingMode = TrinaGridSelectingMode.cell,
  }) {
    final columns = [
      TrinaColumn(title: 'Name', field: 'name', type: TrinaColumnType.text()),
      TrinaColumn(title: 'City', field: 'city', type: TrinaColumnType.text()),
      TrinaColumn(title: 'Role', field: 'role', type: TrinaColumnType.text()),
    ];

    final rows = List.generate(10, (i) {
      return TrinaRow(
        cells: {
          'name': TrinaCell(value: 'N$i'),
          'city': TrinaCell(value: 'C$i'),
          'role': TrinaCell(value: 'R$i'),
        },
      );
    });

    return Row(
      children: [
        Expanded(
          child: TrinaGrid(
            columns: columns,
            rows: rows,
            configuration: TrinaGridConfiguration(
              style: TrinaGridStyleConfig(
                rowColor: rowColor,
                activatedColor: activatedColor,
                unfocusedSelectionColor: unfocusedSelectionColor,
              ),
            ),
            onLoaded: (event) {
              stateManager = event.stateManager;
              stateManager.setSelectingMode(selectingMode);
            },
          ),
        ),
        const SizedBox(width: 16),
        const SizedBox(
          width: 240,
          child: TextField(
            key: outsideKey,
            decoration: InputDecoration(labelText: 'Form field'),
          ),
        ),
      ],
    );
  }

  /// The color painted in an empty corner of a cell, away from its text and
  /// from the current cell border.
  Future<Color> cellBackground(
    WidgetTester tester, {
    required int row,
    required String field,
  }) {
    final rect = tester.getRect(
      findCell(row: stateManager.refRows[row], field: field),
    );

    return pixelColorAt(tester, Offset(rect.right - 10, rect.bottom - 6));
  }

  Future<void> expectCellColor(
    WidgetTester tester, {
    required int row,
    required String field,
    required Color expected,
    required String step,
  }) async {
    final actual = await cellBackground(tester, row: row, field: field);

    if (actual.toARGB32() == expected.toARGB32()) return;

    final screenshot = await takeScreenshot(tester, 'FAILED_$step');
    fail(
      'Cell "$field" of row $row is painted '
      '0x${actual.toARGB32().toRadixString(16)} after "$step", expected '
      '0x${expected.toARGB32().toRadixString(16)}.\n'
      'Screenshot: $screenshot',
    );
  }

  Future<void> selectRowThenFocusForm(WidgetTester tester) async {
    await tapCell(tester, row: stateManager.refRows[2], field: 'name');
    expect(stateManager.hasFocus, isTrue);
    expect(stateManager.currentRowIdx, 2);

    await tester.tap(find.byKey(outsideKey), kind: PointerDeviceKind.mouse);
    await settle(tester);
    expect(stateManager.hasFocus, isFalse);
  }

  for (final mode in [
    TrinaGridSelectingMode.cell,
    TrinaGridSelectingMode.row,
  ]) {
    testWidgets('with unfocusedSelectionColor, the whole current row keeps '
        'it after focus moves to a form field (${mode.name} mode)', (
      tester,
    ) async {
      await pumpGridApp(
        tester,
        buildApp(unfocusedSelectionColor: unfocusedColor, selectingMode: mode),
      );

      await tapCell(tester, row: stateManager.refRows[2], field: 'name');
      await expectCellColor(
        tester,
        row: 2,
        field: 'city',
        expected: activatedColor,
        step: 'focused_${mode.name}',
      );
      await takeScreenshot(tester, '303_focused_${mode.name}');

      await tester.tap(find.byKey(outsideKey), kind: PointerDeviceKind.mouse);
      await settle(tester);
      expect(stateManager.hasFocus, isFalse);

      await takeScreenshot(tester, '303_unfocused_${mode.name}');

      for (final field in ['name', 'city', 'role']) {
        await expectCellColor(
          tester,
          row: 2,
          field: field,
          expected: unfocusedColor,
          step: 'unfocused_${mode.name}_$field',
        );
      }

      // Other rows keep their normal color.
      await expectCellColor(
        tester,
        row: 3,
        field: 'city',
        expected: rowColor,
        step: 'unfocused_${mode.name}_other_row',
      );
    });
  }

  testWidgets('without unfocusedSelectionColor, the current row goes back to '
      'its normal color when the grid loses focus (unchanged)', (tester) async {
    await pumpGridApp(tester, buildApp());
    await selectRowThenFocusForm(tester);

    await takeScreenshot(tester, '303_unfocused_no_color');

    await expectCellColor(
      tester,
      row: 2,
      field: 'city',
      expected: rowColor,
      step: 'unfocused_no_color',
    );
  });

  testWidgets('the current row takes activatedColor again when the grid '
      'gets focus back', (tester) async {
    await pumpGridApp(
      tester,
      buildApp(unfocusedSelectionColor: unfocusedColor),
    );
    await selectRowThenFocusForm(tester);

    await tapCell(tester, row: stateManager.refRows[2], field: 'role');
    expect(stateManager.hasFocus, isTrue);

    await expectCellColor(
      tester,
      row: 2,
      field: 'city',
      expected: activatedColor,
      step: 'refocused',
    );
  });
}
