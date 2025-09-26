import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trina_grid/trina_grid.dart';

import '../helper/column_helper.dart';
import '../helper/row_helper.dart';
import '../helper/test_helper_util.dart';

void main() {
  const columnWidth = TrinaGridSettings.columnWidth;

  const ValueKey<String> sortableGestureKey = ValueKey(
    'ColumnTitleSortableGesture',
  );

  testWidgets('When Directionality is rtl, rtl state should be applied', (
    WidgetTester tester,
  ) async {
    // given
    late final TrinaGridStateManager stateManager;
    final columns = ColumnHelper.textColumn('header');
    final rows = RowHelper.count(3, columns);

    // when
    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: TrinaGrid(
              columns: columns,
              rows: rows,
              onLoaded: (e) => stateManager = e.stateManager,
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(stateManager.isLTR, false);
    expect(stateManager.isRTL, true);
  });

  testWidgets(
    'When Directionality is rtl, columns should be positioned according to their frozen state',
    (WidgetTester tester) async {
      // given
      await TestHelperUtil.changeWidth(
        tester: tester,
        width: 1400,
        height: 600,
      );
      final columns = ColumnHelper.textColumn('header', count: 6);
      final rows = RowHelper.count(3, columns);

      columns[0].frozen = TrinaColumnFrozen.start;
      columns[1].frozen = TrinaColumnFrozen.end;
      columns[2].frozen = TrinaColumnFrozen.start;
      columns[3].frozen = TrinaColumnFrozen.end;

      // when
      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: TrinaGrid(columns: columns, rows: rows),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final firstStartColumn = find.text('header0');
      final secondStartColumn = find.text('header2');
      final firstBodyColumn = find.text('header4');
      final secondBodyColumn = find.text('header5');
      final firstEndColumn = find.text('header1');
      final secondEndColumn = find.text('header3');

      final firstStartColumnDx = tester.getTopRight(firstStartColumn).dx;
      final secondStartColumnDx = tester.getTopRight(secondStartColumn).dx;
      final firstBodyColumnDx = tester.getTopRight(firstBodyColumn).dx;
      final secondBodyColumnDx = tester.getTopRight(secondBodyColumn).dx;
      // Check position of frozen.end column from left due to total width causing center gap
      final firstEndColumnDx = tester.getTopLeft(firstEndColumn).dx;
      final secondEndColumnDx = tester.getTopLeft(secondEndColumn).dx;

      double expectOffset = columnWidth;
      expect(firstStartColumnDx - secondStartColumnDx, expectOffset);

      expectOffset = columnWidth + TrinaGridSettings.gridBorderWidth;
      expect(secondStartColumnDx - firstBodyColumnDx, expectOffset);

      expectOffset = columnWidth;
      expect(firstBodyColumnDx - secondBodyColumnDx, expectOffset);

      // end column should be positioned to the left of center column
      expect(firstEndColumnDx, lessThan(secondBodyColumnDx - columnWidth));

      expectOffset = columnWidth;
      expect(firstEndColumnDx - secondEndColumnDx, expectOffset);
    },
  );

  testWidgets('When createFooter is set, footer should be displayed', (
    WidgetTester tester,
  ) async {
    // given
    final columns = ColumnHelper.textColumn('header');
    final rows = RowHelper.count(3, columns);

    // when
    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: TrinaGrid(
            columns: columns,
            rows: rows,
            createFooter: (stateManager) {
              return const Text('Footer widget.');
            },
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // then
    final footer = find.text('Footer widget.');
    expect(footer, findsOneWidget);
  });

  testWidgets('When TrinaPagination is set in header, it should be rendered', (
    WidgetTester tester,
  ) async {
    // given
    final columns = ColumnHelper.textColumn('header');
    final rows = RowHelper.count(3, columns);

    // when
    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: TrinaGrid(
            columns: columns,
            rows: rows,
            createHeader: (stateManager) {
              return TrinaPagination(stateManager);
            },
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // then
    final found = find.byType(TrinaPagination);
    expect(found, findsOneWidget);
  });

  testWidgets('Cell values should be displayed', (WidgetTester tester) async {
    // given
    final columns = ColumnHelper.textColumn('header');
    final rows = RowHelper.count(3, columns);

    // when
    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: TrinaGrid(columns: columns, rows: rows),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // then
    final cell1 = find.text('header0 value 0');
    expect(cell1, findsOneWidget);

    final cell2 = find.text('header0 value 1');
    expect(cell2, findsOneWidget);

    final cell3 = find.text('header0 value 2');
    expect(cell3, findsOneWidget);
  });

  testWidgets('Tapping header should trigger sorting', (
    WidgetTester tester,
  ) async {
    // given
    final columns = ColumnHelper.textColumn('header');
    final rows = RowHelper.count(3, columns);

    // when
    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: TrinaGrid(columns: columns, rows: rows),
        ),
      ),
    );

    await tester.pumpAndSettle();

    Finder sortableGesture = find.descendant(
      of: find.byKey(columns.first.key),
      matching: find.byKey(sortableGestureKey),
    );

    // then
    await tester.tap(sortableGesture);
    // Ascending
    expect(rows[0].cells['header0']!.value, 'header0 value 0');
    expect(rows[1].cells['header0']!.value, 'header0 value 1');
    expect(rows[2].cells['header0']!.value, 'header0 value 2');

    await tester.tap(sortableGesture);
    // Descending
    expect(rows[0].cells['header0']!.value, 'header0 value 2');
    expect(rows[1].cells['header0']!.value, 'header0 value 1');
    expect(rows[2].cells['header0']!.value, 'header0 value 0');

    await tester.tap(sortableGesture);
    // Original
    expect(rows[0].cells['header0']!.value, 'header0 value 0');
    expect(rows[1].cells['header0']!.value, 'header0 value 1');
    expect(rows[2].cells['header0']!.value, 'header0 value 2');
  });

  testWidgets('Without frozen columns, '
      'move column 0 to position 2', (WidgetTester tester) async {
    // given
    List<TrinaColumn> columns = [
      ...ColumnHelper.textColumn('body', count: 10, width: 100),
    ];

    List<TrinaRow> rows = RowHelper.count(10, columns);

    TrinaGridStateManager? stateManager;

    // when
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

    // when
    stateManager!.moveColumn(column: columns[0], targetColumn: columns[2]);

    // then
    expect(columns[0].title, 'body1');
    expect(columns[1].title, 'body2');
    expect(columns[2].title, 'body0');
  });

  // ... rest of the code remains the same ...
}
