import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trina_grid/trina_grid.dart';

import '../helper/column_helper.dart';
import '../helper/row_helper.dart';
import '../helper/test_helper_util.dart';

void main() {
  const buttonText = 'open grid popup';

  const columnWidth = TrinaGridSettings.columnWidth;

  testWidgets(
    'When Directionality is RTL, columns should be positioned according to RTL layout.',
    (WidgetTester tester) async {
      // given
      await TestHelperUtil.changeWidth(
        tester: tester,
        width: 1200,
        height: 600,
      );

      final gridAColumns = ColumnHelper.textColumn('headerA', count: 3);
      final gridARows = RowHelper.count(3, gridAColumns);

      final gridBColumns = ColumnHelper.textColumn('headerB', count: 3);
      final gridBRows = RowHelper.count(3, gridBColumns);

      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Builder(
                builder: (BuildContext context) {
                  return TextButton(
                    onPressed: () {
                      TrinaDualGridPopup(
                        context: context,
                        gridPropsA: TrinaDualGridProps(
                          columns: gridAColumns,
                          rows: gridARows,
                        ),
                        gridPropsB: TrinaDualGridProps(
                          columns: gridBColumns,
                          rows: gridBRows,
                        ),
                      );
                    },
                    child: const Text(buttonText),
                  );
                },
              ),
            ),
          ),
        ),
      );

      // when
      await tester.tap(find.byType(TextButton));

      await tester.pumpAndSettle();

      // then
      final gridAColumn1 = find.text('headerA0');
      final gridAColumn2 = find.text('headerA1');
      final gridAColumn3 = find.text('headerA2');
      final gridBColumn1 = find.text('headerB0');
      final gridBColumn2 = find.text('headerB1');
      final gridBColumn3 = find.text('headerB2');

      final gridAColumn1Dx = tester.getTopRight(gridAColumn1).dx;
      final gridAColumn2Dx = tester.getTopRight(gridAColumn2).dx;
      final gridAColumn3Dx = tester.getTopRight(gridAColumn3).dx;
      final gridBColumn1Dx = tester.getTopRight(gridBColumn1).dx;
      final gridBColumn2Dx = tester.getTopRight(gridBColumn2).dx;
      final gridBColumn3Dx = tester.getTopRight(gridBColumn3).dx;

      expect(gridAColumn1Dx - gridAColumn2Dx, columnWidth);
      expect(gridAColumn2Dx - gridAColumn3Dx, columnWidth);

      // Check only if the last column of gridA is positioned to the left of the first column of gridB,
      // not checking the position relative to scrolling based on grid width.
      expect(gridBColumn1Dx, lessThan(gridAColumn3Dx));
      expect(gridBColumn1Dx - gridBColumn2Dx, columnWidth);
      expect(gridBColumn2Dx - gridBColumn3Dx, columnWidth);
    },
  );

  testWidgets(
    'When the grid popup is called, the cell values should be displayed.',
    (WidgetTester tester) async {
      // given
      final gridAColumns = ColumnHelper.textColumn('headerA');
      final gridARows = RowHelper.count(3, gridAColumns);

      final gridBColumns = ColumnHelper.textColumn('headerB');
      final gridBRows = RowHelper.count(3, gridBColumns);

      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: Builder(
              builder: (BuildContext context) {
                return TextButton(
                  onPressed: () {
                    TrinaDualGridPopup(
                      context: context,
                      gridPropsA: TrinaDualGridProps(
                        columns: gridAColumns,
                        rows: gridARows,
                      ),
                      gridPropsB: TrinaDualGridProps(
                        columns: gridBColumns,
                        rows: gridBRows,
                      ),
                    );
                  },
                  child: const Text(buttonText),
                );
              },
            ),
          ),
        ),
      );

      // when
      await tester.tap(find.byType(TextButton));

      await tester.pumpAndSettle();

      // then
      final gridACell1 = find.text('headerA0 value 0');
      expect(gridACell1, findsOneWidget);

      final gridBCell1 = find.text('headerB0 value 0');
      expect(gridBCell1, findsOneWidget);
    },
  );
}
