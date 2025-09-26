import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trina_grid/trina_grid.dart';

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
  }

  testWidgets('When the left fixed column is added, it should be rendered.', (
    tester,
  ) async {
    final columns = ColumnHelper.textColumn('column', count: 10);

    final rows = RowHelper.count(10, columns);

    final columnToInsert = TrinaColumn(
      title: 'column10',
      field: 'column10',
      frozen: TrinaColumnFrozen.start,
      type: TrinaColumnType.text(defaultValue: 'column10 value new'),
    );

    await buildGrid(tester: tester, columns: columns, rows: rows);

    stateManager.insertColumns(5, [columnToInsert]);

    await tester.pump();

    expect(find.text('column10'), findsOneWidget);
    expect(find.text('column10 value new'), findsWidgets);
  });

  testWidgets('When the right fixed column is added, it should be rendered.', (
    tester,
  ) async {
    final columns = ColumnHelper.textColumn('column', count: 10);

    final rows = RowHelper.count(10, columns);

    final columnToInsert = TrinaColumn(
      title: 'column10',
      field: 'column10',
      frozen: TrinaColumnFrozen.end,
      type: TrinaColumnType.text(defaultValue: 'column10 value new'),
    );

    await buildGrid(tester: tester, columns: columns, rows: rows);

    stateManager.insertColumns(5, [columnToInsert]);

    await tester.pump();

    expect(find.text('column10'), findsOneWidget);
    expect(find.text('column10 value new'), findsWidgets);
  });

  testWidgets(
    'When the left fixed column is added, it should be rendered at the left end.',
    (tester) async {
      final columns = ColumnHelper.textColumn('column', count: 10);

      final rows = RowHelper.count(10, columns);

      final columnToInsert = TrinaColumn(
        title: 'column10',
        field: 'column10',
        frozen: TrinaColumnFrozen.start,
        type: TrinaColumnType.text(defaultValue: 'column10 value new'),
      );

      await buildGrid(tester: tester, columns: columns, rows: rows);

      stateManager.insertColumns(5, [columnToInsert]);

      await tester.pump();

      final Offset position = tester.getTopLeft(find.text('column10'));

      final Offset firstPosition = tester.getTopLeft(find.text('column0'));

      expect(position.dx, lessThan(firstPosition.dx));
    },
  );

  testWidgets(
    'When the right fixed column is added, it should be rendered at the right end.',
    (tester) async {
      final columns = ColumnHelper.textColumn('column', count: 10);

      final rows = RowHelper.count(10, columns);

      final columnToInsert = TrinaColumn(
        title: 'column10',
        field: 'column10',
        frozen: TrinaColumnFrozen.end,
        type: TrinaColumnType.text(defaultValue: 'column10 value new'),
      );

      await buildGrid(tester: tester, columns: columns, rows: rows);

      stateManager.insertColumns(5, [columnToInsert]);

      await tester.pump();

      final Offset position = tester.getTopLeft(find.text('column10'));

      // screen size 1200, column 5 is the last column shown.
      final Offset lastPosition = tester.getTopLeft(find.text('column4'));

      expect(position.dx, greaterThan(lastPosition.dx));
    },
  );
}
