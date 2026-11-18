import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trina_grid/trina_grid.dart';

import '../../helper/test_helper_util.dart';

/// [TrinaColumn.measureWidth] lets [TrinaAutoSizeMode.fitContent] fit a column
/// whose renderer draws something other than the cell value as text.
void main() {
  // What the renderer paints for a cell holding a short code: the code plus a
  // looked-up name, far wider than the code alone.
  const names = {'C1': 'Acme Corporation International Holdings'};
  String rendered(Object? code) => '$code · ${names[code]}';

  const fitContent = TrinaGridConfiguration(
    columnSize: TrinaGridColumnSizeConfig(
      autoSizeMode: TrinaAutoSizeMode.fitContent,
      minFitContentWidth: 40,
    ),
  );

  /// Pumps a grid with a renderer column `code` and a `filler` column whose
  /// value alone overflows the grid, so no leftover width is shared back to
  /// `code` and its width is the fitted width.
  Future<TrinaColumn> pumpCodeColumn(
    WidgetTester tester, {
    TrinaColumnMeasureWidth? measureWidth,
    double minWidth = 30,
    String title = 'C',
  }) async {
    await TestHelperUtil.changeWidth(tester: tester, width: 400, height: 600);

    final code = TrinaColumn(
      title: title,
      field: 'code',
      width: 300,
      minWidth: minWidth,
      type: TrinaColumnType.text(),
      renderer: (ctx) => Text(rendered(ctx.cell.value)),
      measureWidth: measureWidth,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: TrinaGrid(
            columns: [
              code,
              TrinaColumn(
                title: 'filler',
                field: 'filler',
                width: 300,
                minWidth: 30,
                type: TrinaColumnType.text(),
              ),
            ],
            rows: [
              TrinaRow(
                cells: {
                  'code': TrinaCell(value: 'C1'),
                  'filler': TrinaCell(
                    value:
                        'a value long enough on its own to overflow the whole '
                        'grid several times over, so that the fitted widths '
                        'leave nothing at all to share out',
                  ),
                },
              ),
            ],
            configuration: fitContent,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    return code;
  }

  /// The width of [text] on one line, measured directly rather than through
  /// the grid, so the tests have an expected value the grid did not produce.
  double textWidth(String text, [TextStyle? style]) {
    return (TextPainter(
      text: TextSpan(
        text: text,
        style: style ?? const TrinaGridStyleConfig().cellTextStyle,
      ),
      textDirection: TextDirection.ltr,
    )..layout()).width;
  }

  double measureRendered(TrinaColumnMeasureContext ctx) {
    double widest = 0;
    for (final row in ctx.rows) {
      final width = ctx.measureText(rendered(row.cells['code']!.value));
      if (width > widest) widest = width;
    }
    return widest;
  }

  testWidgets(
    'Without measureWidth, a renderer column should be fitted to its value as '
    'text and be too narrow for what the renderer draws',
    (tester) async {
      final code = await pumpCodeColumn(tester);

      expect(code.width, lessThan(textWidth(rendered('C1'))));
    },
  );

  testWidgets(
    'With measureWidth, a renderer column should be wide enough for what the '
    'renderer draws plus the cell padding',
    (tester) async {
      final code = await pumpCodeColumn(tester, measureWidth: measureRendered);

      // Measured here, independently of measureText, so a measureText that
      // returned the wrong width would fail this rather than move the target.
      final drawn = textWidth(rendered('C1'));
      final padding = const TrinaGridStyleConfig().defaultCellPadding;
      expect(code.width, greaterThanOrEqualTo(drawn + padding.horizontal));
      // Fitted, not left at its starting width or widened by sharing. The
      // slack covers the menu icon and the 2px the fit adds to every value.
      expect(code.width, lessThan(drawn + padding.horizontal + 30));
    },
  );

  testWidgets(
    'measureText should measure with the style it is given, for text the '
    'renderer draws in a different style from the cells',
    (tester) async {
      const bigStyle = TextStyle(fontSize: 40);
      final code = await pumpCodeColumn(
        tester,
        measureWidth: (ctx) => ctx.measureText('C1', style: bigStyle),
      );

      // At the cell's 14px this would be a fraction of the width.
      expect(code.width, greaterThanOrEqualTo(textWidth('C1', bigStyle)));
    },
  );

  testWidgets('measureWidth should receive the column and the loaded rows', (
    tester,
  ) async {
    TrinaColumnMeasureContext? received;
    final code = await pumpCodeColumn(
      tester,
      measureWidth: (ctx) {
        received = ctx;
        return 0;
      },
    );

    expect(received, isNotNull);
    expect(received!.column, same(code));
    expect(received!.rows, hasLength(1));
    expect(received!.rows.first.cells['code']!.value, 'C1');
    expect(received!.stateManager.refRows, same(received!.rows));
  });

  testWidgets(
    'A renderer column with measureWidth should take minFitContentWidth as '
    'its floor rather than its own minWidth',
    (tester) async {
      final code = await pumpCodeColumn(
        tester,
        minWidth: 300,
        measureWidth: (_) => 0,
      );

      expect(code.width, lessThan(300));
    },
  );

  testWidgets(
    'A renderer column without measureWidth should keep its own minWidth as '
    'its floor',
    (tester) async {
      final code = await pumpCodeColumn(tester, minWidth: 300);

      expect(code.width, 300);
    },
  );

  testWidgets(
    'When measureWidth returns less than the title needs, the column should '
    'still be wide enough for its title',
    (tester) async {
      // Far wider than the 40px floor, so only the title can hold it there.
      const title = 'A column title much wider than the floor';
      final code = await pumpCodeColumn(
        tester,
        title: title,
        measureWidth: (_) => 0,
      );

      expect(
        code.width,
        greaterThanOrEqualTo(
          textWidth(title, const TrinaGridStyleConfig().columnTextStyle),
        ),
      );
    },
  );
}
