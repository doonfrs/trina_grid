import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:trina_grid/trina_grid.dart';
import 'package:trina_grid/src/ui/ui.dart';

import '../helper/column_helper.dart';
import '../helper/row_helper.dart';
import '../helper/test_helper_util.dart';
import '../matcher/trina_object_matcher.dart';
import '../mock/mock_methods.dart';

void main() {
  const buttonText = 'open grid popup';

  const columnWidth = TrinaGridSettings.columnWidth;

  late TrinaGridStateManager stateManager;

  Future<void> build({
    required WidgetTester tester,
    List<TrinaColumn> columns = const [],
    List<TrinaRow> rows = const [],
    List<TrinaColumnGroup>? columnGroups,
    TrinaOnChangedEventCallback? onChanged,
    TrinaOnSelectedEventCallback? onSelected,
    TrinaOnSortedEventCallback? onSorted,
    TrinaOnRowCheckedEventCallback? onRowChecked,
    TrinaOnRowDoubleTapEventCallback? onRowDoubleTap,
    TrinaOnRowSecondaryTapEventCallback? onRowSecondaryTap,
    TrinaOnRowsMovedEventCallback? onRowsMoved,
    TrinaOnActiveCellChangedEventCallback? onActiveCellChanged,
    TrinaOnColumnsMovedEventCallback? onColumnsMoved,
    CreateHeaderCallBack? createHeader,
    CreateFooterCallBack? createFooter,
    Widget? noRowsWidget,
    TrinaRowColorCallback? rowColorCallback,
    TrinaCellColorCallback? cellColorCallback,
    TrinaColumnMenuDelegate? columnMenuDelegate,
    TrinaGridConfiguration configuration = const TrinaGridConfiguration(),
    TrinaGridMode mode = TrinaGridMode.normal,
    TextDirection textDirection = TextDirection.ltr,
  }) async {
    await TestHelperUtil.changeWidth(tester: tester, width: 1000, height: 450);

    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: Directionality(
            textDirection: textDirection,
            child: Builder(
              builder: (BuildContext context) {
                return TextButton(
                  onPressed: () {
                    TrinaGridPopup(
                      context: context,
                      columns: columns,
                      rows: rows,
                      columnGroups: columnGroups,
                      onLoaded: (event) => stateManager = event.stateManager,
                      onChanged: onChanged,
                      onSelected: onSelected,
                      onSorted: onSorted,
                      onRowChecked: onRowChecked,
                      onRowDoubleTap: onRowDoubleTap,
                      onRowSecondaryTap: onRowSecondaryTap,
                      onRowsMoved: onRowsMoved,
                      onActiveCellChanged: onActiveCellChanged,
                      onColumnsMoved: onColumnsMoved,
                      createHeader: createHeader,
                      createFooter: createFooter,
                      noRowsWidget: noRowsWidget,
                      rowColorCallback: rowColorCallback,
                      cellColorCallback: cellColorCallback,
                      columnMenuDelegate: columnMenuDelegate,
                      configuration: configuration,
                      mode: mode,
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
  }

  testWidgets('When Directionality is ltr, '
      'stateManager.isLTR and isRTL should be applied', (tester) async {
    final columns = ColumnHelper.textColumn('title', count: 10);
    final rows = RowHelper.count(10, columns);

    await build(
      tester: tester,
      columns: columns,
      rows: rows,
      textDirection: TextDirection.ltr,
    );

    await tester.tap(find.text(buttonText));

    await tester.pumpAndSettle();

    expect(stateManager.isLTR, true);
    expect(stateManager.isRTL, false);
  });

  testWidgets('When Directionality is rtl, '
      'stateManager.isLTR and isRTL should be applied', (tester) async {
    final columns = ColumnHelper.textColumn('title', count: 10);
    final rows = RowHelper.count(10, columns);

    await build(
      tester: tester,
      columns: columns,
      rows: rows,
      textDirection: TextDirection.rtl,
    );

    await tester.tap(find.text(buttonText));

    await tester.pumpAndSettle();

    expect(stateManager.isLTR, false);
    expect(stateManager.isRTL, true);
  });

  testWidgets(
    'When Directionality is rtl, column positions should be RTL applied',
    (tester) async {
      final columns = ColumnHelper.textColumn('title', count: 10);
      final rows = RowHelper.count(10, columns);

      await build(
        tester: tester,
        columns: columns,
        rows: rows,
        textDirection: TextDirection.rtl,
      );

      await tester.tap(find.text(buttonText));

      await tester.pumpAndSettle();

      final firstColumn = find.text('title0');
      final firstStartPosition = tester.getTopRight(firstColumn);

      final secondColumn = find.text('title1');
      final secondStartPosition = tester.getTopRight(secondColumn);

      stateManager.moveScrollByColumn(TrinaMoveDirection.right, 8);
      await tester.pumpAndSettle();

      final scrollOffset = stateManager.scroll.horizontal!.offset;

      final lastColumn = find.text('title9');
      final lastStartPosition = tester.getTopRight(lastColumn);

      // The first column's dx is located on the rightmost and is the largest, and the second column is the width of the column.
      expect(firstStartPosition.dx - secondStartPosition.dx, columnWidth);

      // The last column is located at the position where the scroll is subtracted from the width of the 9 columns before it.
      expect(
        firstStartPosition.dx - lastStartPosition.dx,
        (columnWidth * 9) - scrollOffset,
      );
    },
  );

  testWidgets('When Directionality is rtl, cell positions should be RTL applied', (
    tester,
  ) async {
    final columns = ColumnHelper.textColumn('title', count: 10);
    final rows = RowHelper.count(10, columns);

    await build(
      tester: tester,
      columns: columns,
      rows: rows,
      textDirection: TextDirection.rtl,
    );

    await tester.tap(find.text(buttonText));

    await tester.pumpAndSettle();

    final firstCell = find.text('title0 value 0');
    final firstStartPosition = tester.getTopRight(firstCell);

    final secondCell = find.text('title1 value 0');
    final secondStartPosition = tester.getTopRight(secondCell);

    stateManager.moveScrollByColumn(TrinaMoveDirection.right, 8);
    await tester.pumpAndSettle();

    final scrollOffset = stateManager.scroll.horizontal!.offset;

    final lastCell = find.text('title9 value 0');
    final lastStartPosition = tester.getTopRight(lastCell);

    // The first cell's dx is located on the rightmost and is the largest, and the second cell is the width of the column.
    expect(firstStartPosition.dx - secondStartPosition.dx, columnWidth);

    // The last cell is located at the position where the scroll is subtracted from the width of the 9 cells before it.
    expect(
      firstStartPosition.dx - lastStartPosition.dx,
      (columnWidth * 9) - scrollOffset,
    );
  });

  testWidgets('Cell value changes should trigger the onChanged callback', (
    tester,
  ) async {
    final columns = ColumnHelper.textColumn('title', count: 10);
    final rows = RowHelper.count(10, columns);

    TrinaGridOnChangedEvent? event;

    await build(
      tester: tester,
      columns: columns,
      rows: rows,
      onChanged: (e) => event = e,
    );

    await tester.tap(find.text(buttonText));
    await tester.pumpAndSettle();

    final cell = find.text('title0 value 0');
    await tester.tap(cell);
    await tester.pump();
    await tester.tap(cell);
    await tester.pump();
    await tester.enterText(cell, 'test value');
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();

    expect(event, isNotNull);
    expect(event!.value, 'test value');
    expect(event!.columnIdx, 0);
    expect(event!.rowIdx, 0);
  });

  testWidgets(
    'In select mode, double-tapping a row should trigger the onSelected callback',
    (tester) async {
      final columns = ColumnHelper.textColumn('title', count: 10);
      final rows = RowHelper.count(10, columns);

      TrinaGridOnSelectedEvent? event;

      await build(
        tester: tester,
        columns: columns,
        rows: rows,
        onSelected: (e) => event = e,
        mode: TrinaGridMode.select,
      );

      await tester.tap(find.text(buttonText));
      await tester.pumpAndSettle();

      final cell = find.text('title1 value 3');
      await tester.tap(cell);
      await tester.pump();
      await tester.tap(cell);
      await tester.pump();

      expect(event, isNotNull);
      expect(event!.rowIdx, 3);
      expect(event!.cell!.value, 'title1 value 3');
    },
  );

  testWidgets(
    'In selectWithOneTap mode, tapping a row should trigger the onSelected callback',
    (tester) async {
      final columns = ColumnHelper.textColumn('title', count: 10);
      final rows = RowHelper.count(10, columns);

      TrinaGridOnSelectedEvent? event;

      await build(
        tester: tester,
        columns: columns,
        rows: rows,
        onSelected: (e) => event = e,
        mode: TrinaGridMode.selectWithOneTap,
      );

      await tester.tap(find.text(buttonText));
      await tester.pumpAndSettle();

      final cell = find.text('title2 value 4');
      await tester.tap(cell);
      await tester.pump();

      expect(event, isNotNull);
      expect(event!.rowIdx, 4);
      expect(event!.cell!.value, 'title2 value 4');
    },
  );

  testWidgets('Tapping a column should trigger the onSorted callback', (
    tester,
  ) async {
    final columns = ColumnHelper.textColumn('title', count: 10);
    final rows = RowHelper.count(10, columns);

    TrinaGridOnSortedEvent? event;

    await build(
      tester: tester,
      columns: columns,
      rows: rows,
      onSorted: (e) => event = e,
    );

    await tester.tap(find.text(buttonText));
    await tester.pumpAndSettle();

    final cell = find.text('title2');
    await tester.tap(cell);
    await tester.pump();

    expect(event, isNotNull);
    expect(event!.column.title, 'title2');
    expect(event!.column.sort, TrinaColumnSort.ascending);
    expect(event!.oldSort, TrinaColumnSort.none);

    await tester.tap(cell);
    await tester.pump();

    expect(event, isNotNull);
    expect(event!.column.title, 'title2');
    expect(event!.column.sort, TrinaColumnSort.descending);
    expect(event!.oldSort, TrinaColumnSort.ascending);

    await tester.tap(cell);
    await tester.pump();

    expect(event, isNotNull);
    expect(event!.column.title, 'title2');
    expect(event!.column.sort, TrinaColumnSort.none);
    expect(event!.oldSort, TrinaColumnSort.descending);
  });

  testWidgets('When TrinaColumn.enableRowChecked is true, '
      'checking a cell checkbox should trigger the onRowChecked callback', (
    tester,
  ) async {
    final columns = ColumnHelper.textColumn('title', count: 10);
    final rows = RowHelper.count(10, columns);

    columns[0].enableRowChecked = true;

    TrinaGridOnRowCheckedEvent? event;

    await build(
      tester: tester,
      columns: columns,
      rows: rows,
      onRowChecked: (e) => event = e,
    );

    await tester.tap(find.text(buttonText));
    await tester.pumpAndSettle();

    final cell = find.text('title0 value 1');
    final checkbox = find.descendant(
      of: find.ancestor(of: cell, matching: find.byType(TrinaBaseCell)),
      matching: find.byType(Checkbox),
    );
    await tester.tap(checkbox);
    await tester.pump();

    expect(event, isNotNull);
    expect(event!.rowIdx, 1);
    expect(event!.isChecked, true);
    expect(event!.isAll, false);
    expect(event!.isRow, true);
  });

  testWidgets(
    'Double-tapping a cell should trigger the onRowDoubleTap callback',
    (tester) async {
      final columns = ColumnHelper.textColumn('title', count: 10);
      final rows = RowHelper.count(10, columns);

      TrinaGridOnRowDoubleTapEvent? event;

      await build(
        tester: tester,
        columns: columns,
        rows: rows,
        onRowDoubleTap: (e) => event = e,
      );

      await tester.tap(find.text(buttonText));
      await tester.pumpAndSettle();

      final cell = find.text('title2 value 2');
      await tester.tap(cell);
      await tester.pump(kDoubleTapMinTime);
      await tester.tap(cell);
      await tester.pumpAndSettle();

      expect(event, isNotNull);
      expect(event!.rowIdx, 2);
      expect(event!.cell.value, 'title2 value 2');
    },
  );

  testWidgets(
    'Secondary button tap should trigger the onRowSecondaryTap callback',
    (tester) async {
      final columns = ColumnHelper.textColumn('title', count: 10);
      final rows = RowHelper.count(10, columns);

      TrinaGridOnRowSecondaryTapEvent? event;

      await build(
        tester: tester,
        columns: columns,
        rows: rows,
        onRowSecondaryTap: (e) => event = e,
      );

      await tester.tap(find.text(buttonText));
      await tester.pumpAndSettle();

      final cell = find.text('title3 value 5');
      await tester.tap(cell, buttons: kSecondaryButton);
      await tester.pump();

      expect(event, isNotNull);
      expect(event!.rowIdx, 5);
      expect(event!.cell.value, 'title3 value 5');
    },
  );

  testWidgets('Dragging a row should trigger the onRowsMoved callback', (
    tester,
  ) async {
    final columns = ColumnHelper.textColumn('title', count: 10);
    final rows = RowHelper.count(10, columns);

    columns[0].enableRowDrag = true;

    TrinaGridOnRowsMovedEvent? event;

    await build(
      tester: tester,
      columns: columns,
      rows: rows,
      onRowsMoved: (e) => event = e,
    );

    await tester.tap(find.text(buttonText));
    await tester.pumpAndSettle();

    final cell = find.text('title0 value 0');
    final dragIcon = find.descendant(
      of: find.ancestor(of: cell, matching: find.byType(TrinaBaseCell)),
      matching: find.byType(Icon),
    );
    // When dragging a row, the row height is 45 * 2 (2 rows below)
    await tester.drag(dragIcon, const Offset(0, 90));
    await tester.pump();

    expect(event, isNotNull);
    expect(event!.idx, 2);
    expect(event!.rows.length, 1);
    expect(event!.rows[0].cells['title0']!.value, 'title0 value 0');
  });

  testWidgets('createHeader widget should be rendered', (tester) async {
    final columns = ColumnHelper.textColumn('title', count: 10);
    final rows = RowHelper.count(10, columns);

    final headerKey = GlobalKey();

    await build(
      tester: tester,
      columns: columns,
      rows: rows,
      createHeader: (_) => ColoredBox(color: Colors.cyan, key: headerKey),
    );

    await tester.tap(find.text(buttonText));
    await tester.pumpAndSettle();

    final header = find.byKey(headerKey);
    expect(header, findsOneWidget);
  });

  testWidgets('createFooter widget should be rendered', (tester) async {
    final columns = ColumnHelper.textColumn('title', count: 10);
    final rows = RowHelper.count(10, columns);

    final footerKey = GlobalKey();

    await build(
      tester: tester,
      columns: columns,
      rows: rows,
      createFooter: (_) => ColoredBox(color: Colors.cyan, key: footerKey),
    );

    await tester.tap(find.text(buttonText));
    await tester.pumpAndSettle();

    final footer = find.byKey(footerKey);
    expect(footer, findsOneWidget);
  });

  testWidgets('rowColorCallback should be applied', (tester) async {
    final columns = ColumnHelper.textColumn('title', count: 10);
    final rows = RowHelper.count(10, columns);

    await build(
      tester: tester,
      columns: columns,
      rows: rows,
      configuration: const TrinaGridConfiguration(
        style: TrinaGridStyleConfig(enableRowColorAnimation: true),
      ),
      rowColorCallback: (context) {
        return context.rowIdx % 2 == 0 ? Colors.pink : Colors.cyan;
      },
    );

    await tester.tap(find.text(buttonText));
    await tester.pumpAndSettle();

    final containers = find
        .descendant(
          of: find.byType(TrinaBaseRow),
          matching: find.byType(AnimatedContainer),
        )
        .evaluate();

    final colors = containers.map(
      (e) =>
          ((e.widget as AnimatedContainer).decoration as BoxDecoration).color,
    );

    expect(colors.elementAt(0), Colors.pink);
    expect(colors.elementAt(1), Colors.cyan);
    expect(colors.elementAt(2), Colors.pink);
    expect(colors.elementAt(3), Colors.cyan);
  });

  testWidgets('When columnMenuDelegate is set, column menu should be changed', (
    tester,
  ) async {
    final columns = ColumnHelper.textColumn('title', count: 10);
    final rows = RowHelper.count(10, columns);

    await build(
      tester: tester,
      columns: columns,
      rows: rows,
      columnMenuDelegate: _TestColumnMenu(),
    );

    await tester.tap(find.text(buttonText));
    await tester.pumpAndSettle();

    final column = find.text('title0');
    final menuIcon = find.descendant(
      of: find.ancestor(of: column, matching: find.byType(TrinaBaseColumn)),
      matching: find.byType(TrinaGridColumnIcon),
    );

    await tester.tap(menuIcon);
    await tester.pump();

    expect(find.text('test menu 1'), findsOneWidget);
    expect(find.text('test menu 2'), findsOneWidget);
  });

  testWidgets(
    'Left-fixing a column should trigger the onColumnsMoved callback',
    (tester) async {
      final mock = MockMethods();
      final columns = ColumnHelper.textColumn('column', count: 10);
      final rows = RowHelper.count(10, columns);

      await build(
        tester: tester,
        columns: columns,
        rows: rows,
        onColumnsMoved: mock.oneParamReturnVoid<TrinaGridOnColumnsMovedEvent>,
      );

      await tester.tap(find.text(buttonText));
      await tester.pumpAndSettle();

      stateManager.toggleFrozenColumn(columns[1], TrinaColumnFrozen.start);
      await tester.pump();

      verify(
        mock.oneParamReturnVoid(
          TrinaObjectMatcher<TrinaGridOnColumnsMovedEvent>(
            rule: (e) {
              return e.idx == 1 && e.visualIdx == 0 && e.columns.length == 1;
            },
          ),
        ),
      ).called(1);
    },
  );

  testWidgets(
    'Right-fixing a column should trigger the onColumnsMoved callback',
    (tester) async {
      final mock = MockMethods();
      final columns = ColumnHelper.textColumn('column', count: 10);
      final rows = RowHelper.count(10, columns);

      await build(
        tester: tester,
        columns: columns,
        rows: rows,
        onColumnsMoved: mock.oneParamReturnVoid<TrinaGridOnColumnsMovedEvent>,
      );

      await tester.tap(find.text(buttonText));
      await tester.pumpAndSettle();

      stateManager.toggleFrozenColumn(columns[1], TrinaColumnFrozen.end);
      await tester.pump();

      verify(
        mock.oneParamReturnVoid(
          TrinaObjectMatcher<TrinaGridOnColumnsMovedEvent>(
            rule: (e) {
              return e.idx == 1 && e.visualIdx == 9 && e.columns.length == 1;
            },
          ),
        ),
      ).called(1);
    },
  );

  testWidgets('Dragging a column should trigger the onColumnsMoved callback', (
    tester,
  ) async {
    final mock = MockMethods();
    final columns = ColumnHelper.textColumn('column', count: 10);
    final rows = RowHelper.count(10, columns);

    await build(
      tester: tester,
      columns: columns,
      rows: rows,
      onColumnsMoved: mock.oneParamReturnVoid<TrinaGridOnColumnsMovedEvent>,
    );

    await tester.tap(find.text(buttonText));
    await tester.pumpAndSettle();

    final sampleColumn = find.text('column1');

    await tester.drag(sampleColumn, const Offset(400, 0));

    await tester.pumpAndSettle(const Duration(milliseconds: 300));

    verify(
      mock.oneParamReturnVoid(
        TrinaObjectMatcher<TrinaGridOnColumnsMovedEvent>(
          rule: (e) {
            return e.idx == 3 && e.visualIdx == 3 && e.columns.length == 1;
          },
        ),
      ),
    ).called(1);
  });

  group('noRowsWidget', () {
    testWidgets('When there are no rows, noRowsWidget should be rendered', (
      tester,
    ) async {
      final columns = ColumnHelper.textColumn('column', count: 10);
      final rows = <TrinaRow>[];
      const noRowsWidget = Center(
        key: ValueKey('NoRowsWidget'),
        child: Text('There are no rows.'),
      );

      await build(
        tester: tester,
        columns: columns,
        rows: rows,
        noRowsWidget: noRowsWidget,
      );

      await tester.tap(find.text(buttonText));
      await tester.pumpAndSettle();

      expect(find.byKey(noRowsWidget.key!), findsOneWidget);
    });

    testWidgets('When rows are deleted, noRowsWidget should be rendered', (
      tester,
    ) async {
      final columns = ColumnHelper.textColumn('column', count: 10);
      final rows = RowHelper.count(10, columns);
      const noRowsWidget = Center(
        key: ValueKey('NoRowsWidget'),
        child: Text('There are no rows.'),
      );

      await build(
        tester: tester,
        columns: columns,
        rows: rows,
        noRowsWidget: noRowsWidget,
      );

      await tester.tap(find.text(buttonText));
      await tester.pumpAndSettle();

      expect(find.byKey(noRowsWidget.key!), findsNothing);

      stateManager.removeAllRows();

      await tester.pump(const Duration(milliseconds: 350));

      expect(find.byKey(noRowsWidget.key!), findsOneWidget);
    });

    testWidgets('When rows are added, noRowsWidget should not be rendered', (
      tester,
    ) async {
      final columns = ColumnHelper.textColumn('column', count: 10);
      final rows = <TrinaRow>[];
      const noRowsWidget = Center(
        key: ValueKey('NoRowsWidget'),
        child: Text('There are no rows.'),
      );

      await build(
        tester: tester,
        columns: columns,
        rows: rows,
        noRowsWidget: noRowsWidget,
      );

      await tester.tap(find.text(buttonText));
      await tester.pumpAndSettle();

      expect(find.byKey(noRowsWidget.key!), findsOneWidget);

      stateManager.appendNewRows();

      await tester.pumpAndSettle(const Duration(milliseconds: 350));

      expect(find.byKey(noRowsWidget.key!), findsNothing);
    });
  });
}

class _TestColumnMenu implements TrinaColumnMenuDelegate {
  @override
  List<PopupMenuEntry> buildMenuItems({
    required TrinaGridStateManager stateManager,
    required TrinaColumn column,
  }) {
    return [
      const PopupMenuItem(
        value: 'test1',
        height: 36,
        enabled: true,
        child: Text('test menu 1'),
      ),
      const PopupMenuItem(
        value: 'test2',
        height: 36,
        enabled: true,
        child: Text('test menu 2'),
      ),
    ];
  }

  @override
  void onSelected({
    required BuildContext context,
    required TrinaGridStateManager stateManager,
    required TrinaColumn column,
    required bool mounted,
    required selected,
  }) {}
}
