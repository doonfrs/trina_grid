import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trina_grid/trina_grid.dart';

import '../../helper/column_helper.dart';
import '../../helper/row_helper.dart';
import '../../helper/test_helper_util.dart';

void main() {
  group('TrinaGrid fitContent', () {
    late List<TrinaColumn> columns;
    late List<TrinaRow> rows;

    setUp(() {
      columns = ColumnHelper.textColumn('column', count: 3);
      rows = RowHelper.count(3, columns);
    });

    // For the no-header / no-footer / no-filter case the outer grid height
    // is the inner CustomMultiChildLayout content plus 2 * gridPadding from
    // _GridContainer's outer Padding.
    //
    // Inner content (no header/footer/groups/filter):
    //   columnHeight                        (column titles)
    // + gridBorderWidth                     (column-row divider)
    // + rows * (rowHeight + cellHorizontalBorderWidth)
    double expectedHeightFor(int rowCount) {
      const style = TrinaGridStyleConfig();
      final inner =
          style.columnHeight +
          style.gridBorderWidth +
          rowCount * (style.rowHeight + style.cellHorizontalBorderWidth);
      return inner + 2 * style.gridPadding;
    }

    testWidgets(
      'sizes itself to its content inside an unbounded Column without throwing',
      (tester) async {
        await TestHelperUtil.changeWidth(
          tester: tester,
          width: 800,
          height: 1000,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Material(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 50, child: Placeholder()),
                    TrinaGrid(columns: columns, rows: rows, fitContent: true),
                    const SizedBox(height: 50, child: Placeholder()),
                  ],
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);

        final gridSize = tester.getSize(find.byType(TrinaGrid));
        expect(gridSize.height, expectedHeightFor(3));
      },
    );

    testWidgets(
      'works inside IntrinsicHeight without throwing the LayoutBuilder error',
      (tester) async {
        await TestHelperUtil.changeWidth(
          tester: tester,
          width: 800,
          height: 1000,
        );

        // IntrinsicHeight only kicks in when its parent supplies loose
        // height — wrap in SingleChildScrollView so this exercises the
        // scenario from issue #218 where IntrinsicHeight previously threw
        // "LayoutBuilder does not support returning intrinsic dimensions".
        await tester.pumpWidget(
          MaterialApp(
            home: Material(
              child: SingleChildScrollView(
                child: IntrinsicHeight(
                  child: TrinaGrid(
                    columns: columns,
                    rows: rows,
                    fitContent: true,
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);

        final gridSize = tester.getSize(find.byType(TrinaGrid));
        expect(gridSize.height, expectedHeightFor(3));
      },
    );

    testWidgets('honors per-row TrinaRow.height when fitContent is enabled', (
      tester,
    ) async {
      await TestHelperUtil.changeWidth(
        tester: tester,
        width: 800,
        height: 1000,
      );

      // Replace the second row with a custom 100px row.
      rows[1] = TrinaRow(cells: rows[1].cells, height: 100);

      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: SingleChildScrollView(
              child: TrinaGrid(columns: columns, rows: rows, fitContent: true),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      const style = TrinaGridStyleConfig();
      final inner =
          style.columnHeight +
          style.gridBorderWidth +
          // two default rows + one 100px row
          2 * (style.rowHeight + style.cellHorizontalBorderWidth) +
          (100 + style.cellHorizontalBorderWidth);
      final expected = inner + 2 * style.gridPadding;

      final gridSize = tester.getSize(find.byType(TrinaGrid));
      expect(gridSize.height, expected);
    });

    testWidgets('fitContent: false (default) still expands to parent height', (
      tester,
    ) async {
      await TestHelperUtil.changeWidth(tester: tester, width: 800, height: 600);

      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: SizedBox(
              height: 600,
              child: TrinaGrid(columns: columns, rows: rows),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final gridSize = tester.getSize(find.byType(TrinaGrid));
      expect(gridSize.height, 600);
    });
  });
}
