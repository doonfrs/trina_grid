import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trina_grid/trina_grid.dart';
import 'package:trina_grid/src/ui/ui.dart';

import '../../helper/column_helper.dart';
import '../../helper/row_helper.dart';
import '../../helper/test_helper_util.dart';

/// Regression tests for https://github.com/doonfrs/trina_grid/issues/403 and
/// https://github.com/doonfrs/trina_grid/issues/304
///
/// No column paints the band the header reserves for the vertical scrollbar,
/// nor the space after the last column when the columns are narrower than the
/// grid. [TrinaGridStyleConfig.columnBackgroundColor] fills the whole header.
void main() {
  const fill = Color(0xFFBBDEFB);

  late TrinaGridStateManager stateManager;

  Future<void> buildGrid(
    WidgetTester tester, {
    required int columnCount,
    Color? columnBackgroundColor = fill,
    bool showColumnFilter = false,
  }) async {
    await TestHelperUtil.changeWidth(tester: tester, width: 800, height: 400);

    final columns = ColumnHelper.textColumn(
      'column',
      count: columnCount,
      width: 150,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: TrinaGrid(
            columns: columns,
            rows: RowHelper.count(30, columns),
            configuration: TrinaGridConfiguration(
              style: TrinaGridStyleConfig(
                columnBackgroundColor: columnBackgroundColor,
              ),
            ),
            onLoaded: (event) {
              stateManager = event.stateManager;
              stateManager.setShowColumnFilter(showColumnFilter);
            },
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
  }

  Finder findFill() {
    return find.byWidgetPredicate((w) => w is ColoredBox && w.color == fill);
  }

  testWidgets('The fill should span the full grid width under a header with '
      'columns narrower than the grid', (tester) async {
    await buildGrid(tester, columnCount: 2);

    final header = tester.getRect(find.byType(TrinaBodyColumns));
    final body = tester.getRect(find.byType(TrinaBodyRows));

    expect(findFill(), findsOneWidget);

    final rect = tester.getRect(findFill());

    expect(header.right, lessThan(body.right - 100));
    expect(rect.left, body.left);
    expect(rect.right, body.right);
    expect(rect.top, header.top);
    expect(rect.height, header.height);
  });

  testWidgets('The fill should cover the band reserved for the vertical '
      'scrollbar at the end of the header', (tester) async {
    await buildGrid(tester, columnCount: 10);

    stateManager.scroll.bodyRowsHorizontal!.jumpTo(
      stateManager.scroll.maxScrollHorizontal,
    );
    await tester.pumpAndSettle();

    final header = tester.getRect(find.byType(TrinaBodyColumns));
    final rect = tester.getRect(findFill());
    final band = stateManager.configuration.scrollbar.effectiveThickness;

    expect(band, greaterThan(0));
    expect(rect.left, lessThanOrEqualTo(header.right - band));
    expect(rect.right, greaterThanOrEqualTo(header.right));
    expect(rect.height, header.height);
  });

  testWidgets('The fill should also cover the filter row', (tester) async {
    await buildGrid(tester, columnCount: 2, showColumnFilter: true);

    final rect = tester.getRect(findFill());

    expect(
      rect.height,
      stateManager.columnHeight + stateManager.columnFilterHeight,
    );
  });

  testWidgets('The fill should be painted below the column titles', (
    tester,
  ) async {
    await buildGrid(tester, columnCount: 2);

    final fillElement = findFill().evaluate().single;
    final titleElement = find.byType(TrinaBaseColumn).evaluate().first;

    // Children of the grid layout paint in order, so the fill has to come
    // before the header in the element tree.
    var fillFirst = false;
    var seen = 0;
    void visit(Element e) {
      if (seen == 2) return;
      if (e == fillElement) {
        fillFirst = seen == 0;
        seen++;
      } else if (e == titleElement) {
        seen++;
      }
      e.visitChildren(visit);
    }

    tester.binding.rootElement!.visitChildren(visit);

    expect(fillFirst, isTrue);
  });

  testWidgets('Without columnBackgroundColor nothing is added', (tester) async {
    await buildGrid(tester, columnCount: 2, columnBackgroundColor: null);

    expect(findFill(), findsNothing);
  });

  test('copyWith and == should carry columnBackgroundColor', () {
    const style = TrinaGridStyleConfig();

    final copied = style.copyWith(columnBackgroundColor: fill);

    expect(copied.columnBackgroundColor, fill);
    expect(copied, isNot(style));
    expect(copied, style.copyWith(columnBackgroundColor: fill));
    expect(
      copied.hashCode,
      style.copyWith(columnBackgroundColor: fill).hashCode,
    );
    expect(
      const TrinaGridStyleConfig.dark(
        columnBackgroundColor: fill,
      ).copyWith().columnBackgroundColor,
      fill,
    );
  });
}
