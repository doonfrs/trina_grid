import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trina_grid/trina_grid.dart';

void main() {
  late TrinaGridStateManager manager;

  Future<void> buildGrid(
    WidgetTester tester, {
    bool smooth = false,
    List<double?>? heights,
    bool wrapper = false,
    bool constantWrapper = false,
    bool frozenRows = false,
  }) async {
    final columns = [
      for (final frozen in TrinaColumnFrozen.values)
        TrinaColumn(
          title: frozen.name,
          field: frozen.name,
          width: 150,
          type: TrinaColumnType.text(),
          frozen: frozen,
        ),
    ];
    final rowHeights = heights ?? List<double?>.filled(100, null);
    final rows = [
      for (var i = 0; i < rowHeights.length; i++)
        TrinaRow(
          cells: {for (final c in columns) c.field: TrinaCell(value: 'row $i')},
          height: rowHeights[i],
          frozen: frozenRows && i == 0
              ? TrinaRowFrozen.start
              : frozenRows && i == rowHeights.length - 1
              ? TrinaRowFrozen.end
              : TrinaRowFrozen.none,
        ),
    ];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TrinaGrid(
            columns: columns,
            rows: rows,
            onLoaded: (event) => manager = event.stateManager,
            rowWrapper: wrapper
                ? (context, child, row, stateManager) => Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: constantWrapper ? 0 : 5,
                    ),
                    child: child,
                  )
                : null,
            configuration: TrinaGridConfiguration(
              rowWrapperIsConstantHeight: constantWrapper,
              style: const TrinaGridStyleConfig(rowHeight: 40),
              scrollbar: TrinaGridScrollbarConfig(
                smoothScrolling: smooth,
                // Isolate frozen-row geometry from the scrollbar footprint:
                // published 2.2.2 reserves it only in the body pane.
                showHorizontal: !frozenRows,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(manager.showFrozenColumn, isTrue);
  }

  void expectFixed(double height) {
    final slivers = find.byType(SliverFixedExtentList);
    expect(slivers, findsNWidgets(3));
    for (final sliver in slivers.evaluate()) {
      expect((sliver.widget as SliverFixedExtentList).itemExtent, height + 1);
    }
    expect(find.byType(SliverVariedExtentList), findsNothing);
  }

  void expectAligned(WidgetTester tester, TrinaRow row) {
    final bounds = [
      for (final prefix in ['body', 'left_frozen', 'right_frozen'])
        tester.getRect(find.byKey(ValueKey('${prefix}_row_${row.key}'))),
    ];
    for (final rect in bounds.skip(1)) {
      expect(rect.top, closeTo(bounds.first.top, 0.01));
      expect(rect.height, closeTo(bounds.first.height, 0.01));
    }
  }

  for (final smooth in [false, true]) {
    testWidgets('uniform rows use fixed extents (smooth: $smooth)', (
      tester,
    ) async {
      await buildGrid(tester, smooth: smooth);
      expectFixed(40);
      manager.scroll.bodyRowsVertical!.jumpTo(41 * 80);
      await tester.pumpAndSettle();
      expectAligned(tester, manager.refRows[80]);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('equal explicit heights use fixed extents', (tester) async {
    await buildGrid(tester, heights: List.filled(100, 60));
    expectFixed(60);
  });

  testWidgets('explicit default heights and empty lists use fixed extents', (
    tester,
  ) async {
    await buildGrid(tester, heights: [null, 40, null]);
    expectFixed(40);
    manager.removeAllRows();
    await tester.pumpAndSettle();
    expect(find.text('row 0'), findsNothing);
    expect(tester.takeException(), isNull);
    manager.appendRows([
      TrinaRow(
        cells: {
          for (final c in manager.columns) c.field: TrinaCell(value: 'new'),
        },
      ),
    ]);
    await tester.pumpAndSettle();
    expectFixed(40);
  });

  testWidgets('height changes and resets switch extent paths in every pane', (
    tester,
  ) async {
    await buildGrid(tester);
    expectFixed(40);
    manager.setRowHeight(2, 75);
    await tester.pumpAndSettle();
    expect(find.byType(SliverVariedExtentList), findsNWidgets(3));
    expect(find.byType(SliverFixedExtentList), findsNothing);
    expectAligned(tester, manager.refRows[3]);
    manager.resetRowHeight(2);
    await tester.pumpAndSettle();
    expectFixed(40);
    expectAligned(tester, manager.refRows[3]);
  });

  testWidgets('appended variable rows invalidate the fixed extent', (
    tester,
  ) async {
    await buildGrid(tester);
    final extra = TrinaRow(
      height: 80,
      cells: {
        for (final c in manager.columns) c.field: TrinaCell(value: 'new'),
      },
    );
    manager.appendRows([extra]);
    await tester.pumpAndSettle();
    expect(find.byType(SliverVariedExtentList), findsNWidgets(3));
    manager.removeRows([extra]);
    await tester.pumpAndSettle();
    expectFixed(40);
  });

  testWidgets('nonconstant wrappers keep natural layout in every pane', (
    tester,
  ) async {
    await buildGrid(tester, wrapper: true);
    expect(find.byType(SliverFixedExtentList), findsNothing);
    expect(find.byType(SliverVariedExtentList), findsNothing);
    expectAligned(tester, manager.refRows[3]);
    final first = tester.getTopLeft(find.text('row 0').first);
    final second = tester.getTopLeft(find.text('row 1').first);
    expect(second.dy - first.dy, 50);
  });

  testWidgets('constant wrappers allow fixed extents', (tester) async {
    await buildGrid(tester, wrapper: true, constantWrapper: true);
    expectFixed(40);
  });

  testWidgets('frozen row heights do not affect scrollable row extents', (
    tester,
  ) async {
    await buildGrid(
      tester,
      frozenRows: true,
      heights: [60, ...List<double?>.filled(100, null), 80],
    );
    expectFixed(40);
    manager.scroll.bodyRowsVertical!.jumpTo(41 * 70);
    await tester.pumpAndSettle();
    expectAligned(tester, manager.refRows[71]);
    expectAligned(tester, manager.refRows.first);
    expectAligned(tester, manager.refRows.last);
  });
}
