import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trina_grid/trina_grid.dart';
import 'package:trina_grid/src/ui/ui.dart';

import '../../helper/column_helper.dart';
import '../../helper/trina_widget_test_helper.dart';
import '../../helper/row_helper.dart';

void main() {
  group('When there are no hidden columns', () {
    late List<TrinaColumn> columns;

    late List<TrinaRow> rows;

    late TrinaGridStateManager stateManager;

    final withTenColumns = TrinaWidgetTestHelper(
      'When 10 columns are created',
      (tester) async {
        columns = [...ColumnHelper.textColumn('header', count: 10)];

        rows = RowHelper.count(10, columns);

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
      },
    );

    withTenColumns.test(
      'When hideColumn is called to hide header1, the header1 column should be hidden.',
      (tester) async {
        var column = find.text('header1');

        expect(column, findsOneWidget);

        stateManager.hideColumn(columns[1], true);

        await tester.pumpAndSettle();

        expect(column, findsNothing);
      },
    );

    withTenColumns.test(
      'When showSetColumnsPopup is called, the column settings popup should be called.',
      (tester) async {
        stateManager.showSetColumnsPopup(stateManager.gridFocusNode.context!);

        await tester.pumpAndSettle();

        var columnTitleOfPopup = find.text(
          stateManager.configuration.localeText.setColumnsTitle,
        );

        expect(columnTitleOfPopup, findsOneWidget);
      },
    );

    withTenColumns.test(
      'When the all checkbox is clicked in the column settings popup, all columns should be hidden.',
      (tester) async {
        stateManager.showSetColumnsPopup(stateManager.gridFocusNode.context!);

        await tester.pumpAndSettle();

        final allCheckbox = find.descendant(
          of: find.byType(TrinaBaseColumn),
          matching: find.byType(TrinaScaledCheckbox),
        );

        await tester.tap(allCheckbox, warnIfMissed: false);

        await tester.pump();

        expect(stateManager.refColumns.length, 0);
      },
    );

    withTenColumns.test(
      'When the header0 checkbox is clicked in the column settings popup, the header0 column should be hidden.',
      (tester) async {
        stateManager.showSetColumnsPopup(stateManager.gridFocusNode.context!);

        await tester.pumpAndSettle();

        final columnTitleOfPopup = find.text(
          stateManager.configuration.localeText.setColumnsTitle,
        );

        final firstColumnCell = find
            .descendant(
              of: find.ancestor(
                of: columnTitleOfPopup,
                matching: find.byType(TrinaGrid),
              ),
              matching: find.byType(TrinaBaseCell),
            )
            .first;

        final firstColumnTitle =
            (firstColumnCell.evaluate().first.widget as TrinaBaseCell)
                .cell
                .value;

        final headerCheckbox0 = find.descendant(
          of: firstColumnCell,
          matching: find.byType(TrinaScaledCheckbox),
        );

        await tester.tap(headerCheckbox0, warnIfMissed: false);

        await tester.pump();

        expect(stateManager.refColumns.length, 9);

        expect(
          stateManager.refColumns
              .where((e) => e.title == firstColumnTitle)
              .length,
          0,
        );
      },
    );

    withTenColumns.test(
      'When the header0 column is hidden, tap the header0 checkbox to show the column',
      (tester) async {
        stateManager.hideColumn(stateManager.refColumns.first, true);

        await tester.pumpAndSettle();

        expect(stateManager.refColumns.length, 9);

        stateManager.showSetColumnsPopup(stateManager.gridFocusNode.context!);

        await tester.pumpAndSettle();

        final columnTitleOfPopup = find.text(
          stateManager.configuration.localeText.setColumnsTitle,
        );

        final firstColumnCell = find
            .descendant(
              of: find.ancestor(
                of: columnTitleOfPopup,
                matching: find.byType(TrinaGrid),
              ),
              matching: find.byType(TrinaBaseCell),
            )
            .first;

        final firstColumnTitle =
            (firstColumnCell.evaluate().first.widget as TrinaBaseCell)
                .cell
                .value;

        final headerCheckbox0 = find.descendant(
          of: firstColumnCell,
          matching: find.byType(TrinaScaledCheckbox),
        );

        await tester.tap(headerCheckbox0, warnIfMissed: false);

        await tester.pump();

        expect(stateManager.refColumns.length, 10);

        expect(
          stateManager.refColumns
              .where((e) => e.title == firstColumnTitle)
              .length,
          1,
        );
      },
    );

    withTenColumns.test(
      'When all columns are hidden, tap the all checkbox in the column settings popup to show all columns',
      (tester) async {
        stateManager.hideColumns(stateManager.refColumns, true);

        await tester.pumpAndSettle();

        expect(stateManager.refColumns.length, 0);

        stateManager.showSetColumnsPopup(stateManager.gridFocusNode.context!);

        await tester.pumpAndSettle();

        final allCheckbox = find.descendant(
          of: find.byType(TrinaBaseColumn),
          matching: find.byType(TrinaScaledCheckbox),
        );

        await tester.tap(allCheckbox, warnIfMissed: false);

        await tester.pump();

        expect(stateManager.refColumns.length, 10);
      },
    );
  });

  group('When there are no hidden columns', () {
    List<TrinaColumn> columns;

    List<TrinaRow> rows;

    TrinaGridStateManager? stateManager;

    final withTenColumns = TrinaWidgetTestHelper(
      '10 columns are created and columns 0, 5 are hidden',
      (tester) async {
        columns = [...ColumnHelper.textColumn('header', count: 10)];

        rows = RowHelper.count(10, columns);

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

        stateManager!.hideColumn(columns[0], true, notify: false);
        stateManager!.hideColumn(columns[5], true);
      },
    );

    withTenColumns.test(
      'When the header0 column is hidden, tap the header0 checkbox to show the column',
      (tester) async {
        var column = find.text('header0');

        expect(column, findsNothing);

        stateManager!.hideColumn(
          stateManager!.refColumns.originalList[0],
          false,
        );

        await tester.pumpAndSettle(const Duration(milliseconds: 300));

        expect(column, findsOneWidget);
      },
    );
  });
}
