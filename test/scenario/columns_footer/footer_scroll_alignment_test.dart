import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trina_grid/trina_grid.dart';
import 'package:trina_grid/src/ui/ui.dart';

import '../../helper/column_helper.dart';
import '../../helper/row_helper.dart';
import '../../helper/test_helper_util.dart';

/// Regression tests for https://github.com/doonfrs/trina_grid/issues/402
///
/// The column footers did not reserve the trailing band the header and body
/// leave for the overlaid vertical scrollbar, so their maxScrollExtent was one
/// scrollbar width smaller. An animated or dragged scroll to the end clamped
/// the footers short of the body, shifting them against their columns.
void main() {
  late TrinaGridStateManager stateManager;
  late List<TrinaColumn> columns;

  Future<void> buildGrid(
    WidgetTester tester, {
    TrinaGridConfiguration configuration = const TrinaGridConfiguration(),
  }) async {
    await TestHelperUtil.changeWidth(tester: tester, width: 500, height: 400);

    columns = ColumnHelper.textColumn('column', count: 10, width: 200);

    for (final column in columns) {
      column.footerRenderer = (ctx) => TrinaAggregateColumnFooter(
        rendererContext: ctx,
        type: TrinaAggregateColumnType.count,
      );
    }

    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: TrinaGrid(
            columns: columns,
            rows: RowHelper.count(30, columns),
            configuration: configuration,
            onLoaded: (event) => stateManager = event.stateManager,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
  }

  ScrollPosition horizontalPositionIn(WidgetTester tester, Type widgetType) {
    final scrollable = find
        .descendant(
          of: find.byType(widgetType),
          matching: find.byWidgetPredicate(
            (w) => w is Scrollable && w.axisDirection == AxisDirection.right,
          ),
        )
        .first;

    return tester.state<ScrollableState>(scrollable).position;
  }

  double headerLeft(WidgetTester tester, TrinaColumn column) {
    return tester
        .getTopLeft(
          find.byWidgetPredicate(
            (w) => w is TrinaBaseColumn && w.column == column,
          ),
        )
        .dx;
  }

  double footerLeft(WidgetTester tester, TrinaColumn column) {
    return tester
        .getTopLeft(
          find.byWidgetPredicate(
            (w) => w is TrinaBaseColumnFooter && w.column == column,
          ),
        )
        .dx;
  }

  for (final showVertical in [true, false]) {
    group('showVertical: $showVertical', () {
      final configuration = TrinaGridConfiguration(
        scrollbar: TrinaGridScrollbarConfig(showVertical: showVertical),
      );

      testWidgets(
        'The footers should share the maxScrollExtent of the header and body',
        (tester) async {
          await buildGrid(tester, configuration: configuration);

          final body = stateManager.scroll.bodyRowsHorizontal!.position;
          final header = horizontalPositionIn(tester, TrinaBodyColumns);
          final footer = horizontalPositionIn(tester, TrinaBodyColumnsFooter);

          expect(header.maxScrollExtent, body.maxScrollExtent);
          expect(footer.maxScrollExtent, body.maxScrollExtent);
        },
      );

      testWidgets(
        'An animated scroll to the end should keep the footers aligned with '
        'their columns',
        (tester) async {
          await buildGrid(tester, configuration: configuration);

          final body = stateManager.scroll.bodyRowsHorizontal!;

          // animateTo moves the linked header and footer through setPixels,
          // which clamps each of them to its own scroll extent.
          body.animateTo(
            body.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.linear,
          );
          await tester.pumpAndSettle();

          final last = columns.last;

          expect(footerLeft(tester, last), headerLeft(tester, last));
        },
      );
    });
  }
}
