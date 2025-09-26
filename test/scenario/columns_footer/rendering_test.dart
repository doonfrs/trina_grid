import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trina_grid/trina_grid.dart';
import 'package:trina_grid/src/ui/ui.dart';

import '../../helper/column_helper.dart';
import '../../helper/row_helper.dart';
import '../../helper/test_helper_util.dart';

void main() {
  late TrinaGridStateManager stateManager;

  buildGrid({
    required WidgetTester tester,
    required List<TrinaColumn> columns,
    required List<TrinaRow> rows,
  }) async {
    await TestHelperUtil.changeWidth(tester: tester, width: 1200, height: 800);

    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: TrinaGrid(
            columns: columns,
            rows: rows,
            onLoaded: (TrinaGridOnLoadedEvent event) {
              stateManager = event.stateManager;
            },
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
  }

  testWidgets(
    'When footerRenderer is not set, column footer widgets should not be rendered',
    (tester) async {
      final columns = [
        ...ColumnHelper.textColumn(
          'left',
          count: 2,
          frozen: TrinaColumnFrozen.start,
        ),
        ...ColumnHelper.textColumn('body', count: 2),
        ...ColumnHelper.textColumn(
          'right',
          count: 2,
          frozen: TrinaColumnFrozen.end,
        ),
      ];

      final rows = RowHelper.count(3, columns);

      await buildGrid(tester: tester, columns: columns, rows: rows);

      expect(find.byType(TrinaLeftFrozenColumnsFooter), findsNothing);
      expect(find.byType(TrinaBodyColumnsFooter), findsNothing);
      expect(find.byType(TrinaRightFrozenColumnsFooter), findsNothing);
      expect(find.byType(TrinaBaseColumnFooter), findsNothing);
    },
  );

  testWidgets(
    'When footerRenderer is not set, setShowColumnFooter is called with true, '
    'column footer widgets should be rendered.',
    (tester) async {
      final columns = [
        ...ColumnHelper.textColumn(
          'left',
          count: 2,
          frozen: TrinaColumnFrozen.start,
        ),
        ...ColumnHelper.textColumn('body', count: 2),
        ...ColumnHelper.textColumn(
          'right',
          count: 2,
          frozen: TrinaColumnFrozen.end,
        ),
      ];

      final rows = RowHelper.count(3, columns);

      await buildGrid(tester: tester, columns: columns, rows: rows);

      stateManager.setShowColumnFooter(true);

      await tester.pumpAndSettle();

      expect(find.byType(TrinaLeftFrozenColumnsFooter), findsOneWidget);
      expect(find.byType(TrinaBodyColumnsFooter), findsOneWidget);
      expect(find.byType(TrinaRightFrozenColumnsFooter), findsOneWidget);
      expect(find.byType(TrinaBaseColumnFooter), findsNWidgets(6));
    },
  );

  testWidgets(
    'When footerRenderer is set, column footer widgets should be rendered',
    (tester) async {
      final columns = [
        ...ColumnHelper.textColumn(
          'left',
          count: 2,
          frozen: TrinaColumnFrozen.start,
          footerRenderer: (ctx) => Text(ctx.column.title),
        ),
        ...ColumnHelper.textColumn('body', count: 2),
        ...ColumnHelper.textColumn(
          'right',
          count: 2,
          frozen: TrinaColumnFrozen.end,
        ),
      ];

      final rows = RowHelper.count(3, columns);

      await buildGrid(tester: tester, columns: columns, rows: rows);

      expect(find.byType(TrinaLeftFrozenColumnsFooter), findsOneWidget);
      expect(find.byType(TrinaBodyColumnsFooter), findsOneWidget);
      expect(find.byType(TrinaRightFrozenColumnsFooter), findsOneWidget);
      expect(find.byType(TrinaBaseColumnFooter), findsNWidgets(6));
    },
  );
}
