import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trina_grid/trina_grid.dart';

import '../../helper/column_helper.dart';
import '../../helper/row_helper.dart';

/// Tests for the per-row / per-cell text-style callbacks (issue #344).
void main() {
  Future<TrinaGridStateManager> pumpGrid(
    WidgetTester tester, {
    TrinaRowTextStyleCallback? rowTextStyleCallback,
    TrinaCellTextStyleCallback? cellTextStyleCallback,
    TrinaGridConfiguration configuration = const TrinaGridConfiguration(),
  }) async {
    final columns = ColumnHelper.textColumn('header', count: 3);
    final rows = RowHelper.count(3, columns);

    late TrinaGridStateManager stateManager;
    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: TrinaGrid(
            columns: columns,
            rows: rows,
            onLoaded: (event) => stateManager = event.stateManager,
            rowTextStyleCallback: rowTextStyleCallback,
            cellTextStyleCallback: cellTextStyleCallback,
            configuration: configuration,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return stateManager;
  }

  TextStyle styleForText(WidgetTester tester, String value) {
    final widget = tester.widget<Text>(find.text(value));
    return widget.style!;
  }

  testWidgets('rowTextStyleCallback applies to every cell in matched row', (
    tester,
  ) async {
    await pumpGrid(
      tester,
      rowTextStyleCallback: (ctx) =>
          ctx.rowIdx == 1 ? const TextStyle(color: Colors.red) : null,
    );

    expect(styleForText(tester, 'header0 value 1').color, Colors.red);
    expect(styleForText(tester, 'header1 value 1').color, Colors.red);
    expect(styleForText(tester, 'header2 value 1').color, Colors.red);
    expect(styleForText(tester, 'header0 value 0').color, isNot(Colors.red));
  });

  testWidgets('cellTextStyleCallback overrides rowTextStyleCallback per cell', (
    tester,
  ) async {
    await pumpGrid(
      tester,
      rowTextStyleCallback: (_) => const TextStyle(color: Colors.red),
      cellTextStyleCallback: (ctx) => ctx.column.field == 'header1'
          ? const TextStyle(color: Colors.green)
          : null,
    );

    expect(styleForText(tester, 'header0 value 0').color, Colors.red);
    expect(styleForText(tester, 'header1 value 0').color, Colors.green);
    expect(styleForText(tester, 'header2 value 0').color, Colors.red);
  });

  testWidgets('returning null falls back to configured cellTextStyle', (
    tester,
  ) async {
    const baseStyle = TextStyle(color: Color(0xFF112233), fontSize: 17);
    await pumpGrid(
      tester,
      configuration: const TrinaGridConfiguration(
        style: TrinaGridStyleConfig(cellTextStyle: baseStyle),
      ),
      rowTextStyleCallback: (_) => null,
      cellTextStyleCallback: (_) => null,
    );

    final style = styleForText(tester, 'header0 value 0');
    expect(style.color, baseStyle.color);
    expect(style.fontSize, baseStyle.fontSize);
  });
}
