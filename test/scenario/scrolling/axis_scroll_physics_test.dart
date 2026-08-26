import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trina_grid/trina_grid.dart';

import '../../helper/column_helper.dart';
import '../../helper/row_helper.dart';
import '../../helper/test_helper_util.dart';

/// Tests for https://github.com/doonfrs/trina_grid/issues/270
///
/// `scrollPhysics` applies to both axes at once, so blocking the grid's
/// vertical scrolling used to block horizontal scrolling with it.
/// `horizontalScrollPhysics` and `verticalScrollPhysics` let each axis be
/// controlled on its own.
void main() {
  late TrinaGridStateManager stateManager;

  Future<void> buildGrid(
    WidgetTester tester, {
    ScrollPhysics? scrollPhysics,
    ScrollPhysics? horizontalScrollPhysics,
    ScrollPhysics? verticalScrollPhysics,
    int frozenStartColumns = 0,
    bool smoothScrolling = true,
  }) async {
    await TestHelperUtil.changeWidth(tester: tester, width: 500, height: 400);

    final columns = ColumnHelper.textColumn('column', count: 10, width: 200);

    for (int i = 0; i < frozenStartColumns; i += 1) {
      columns[i].frozen = TrinaColumnFrozen.start;
    }

    final rows = RowHelper.count(50, columns);

    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: TrinaGrid(
            columns: columns,
            rows: rows,
            scrollPhysics: scrollPhysics,
            horizontalScrollPhysics: horizontalScrollPhysics,
            verticalScrollPhysics: verticalScrollPhysics,
            configuration: TrinaGridConfiguration(
              scrollbar: TrinaGridScrollbarConfig(
                smoothScrolling: smoothScrolling,
              ),
            ),
            onLoaded: (TrinaGridOnLoadedEvent event) {
              stateManager = event.stateManager;
            },
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
  }

  Future<double> dragHorizontally(WidgetTester tester) async {
    await tester.drag(find.byType(TrinaGrid), const Offset(-200, 0));
    await tester.pumpAndSettle();
    return stateManager.scroll.horizontal!.offset;
  }

  Future<double> dragVertically(WidgetTester tester) async {
    await tester.drag(find.byType(TrinaGrid), const Offset(0, -200));
    await tester.pumpAndSettle();
    return stateManager.scroll.vertical!.offset;
  }

  testWidgets('With verticalScrollPhysics set to NeverScrollableScrollPhysics, '
      'horizontal scrolling should work and vertical scrolling should not.', (
    tester,
  ) async {
    await buildGrid(
      tester,
      verticalScrollPhysics: const NeverScrollableScrollPhysics(),
    );

    expect(await dragHorizontally(tester), greaterThan(0));
    expect(await dragVertically(tester), 0);
  });

  testWidgets(
    'With horizontalScrollPhysics set to NeverScrollableScrollPhysics, '
    'vertical scrolling should work and horizontal scrolling should not.',
    (tester) async {
      await buildGrid(
        tester,
        horizontalScrollPhysics: const NeverScrollableScrollPhysics(),
      );

      expect(await dragVertically(tester), greaterThan(0));
      expect(await dragHorizontally(tester), 0);
    },
  );

  testWidgets('With verticalScrollPhysics blocked and a frozen start column, '
      'dragging over the frozen area should not scroll vertically.', (
    tester,
  ) async {
    await buildGrid(
      tester,
      verticalScrollPhysics: const NeverScrollableScrollPhysics(),
      frozenStartColumns: 1,
    );

    // The frozen column occupies the leading 200px of the grid.
    await tester.dragFrom(const Offset(60, 200), const Offset(0, -200));
    await tester.pumpAndSettle();

    expect(stateManager.scroll.vertical!.offset, 0);
  });

  testWidgets(
    'With smooth scrolling disabled, per axis physics should still apply.',
    (tester) async {
      await buildGrid(
        tester,
        verticalScrollPhysics: const NeverScrollableScrollPhysics(),
        smoothScrolling: false,
      );

      expect(await dragHorizontally(tester), greaterThan(0));
      expect(await dragVertically(tester), 0);
    },
  );

  testWidgets(
    'Without any physics passed, both axes should scroll as before.',
    (tester) async {
      await buildGrid(tester);

      expect(await dragHorizontally(tester), greaterThan(0));
      expect(await dragVertically(tester), greaterThan(0));
    },
  );

  testWidgets('scrollPhysics on its own should still block both axes.', (
    tester,
  ) async {
    await buildGrid(
      tester,
      scrollPhysics: const NeverScrollableScrollPhysics(),
    );

    expect(await dragHorizontally(tester), 0);
    expect(await dragVertically(tester), 0);
  });

  testWidgets('Per axis physics should take precedence over scrollPhysics.', (
    tester,
  ) async {
    await buildGrid(
      tester,
      scrollPhysics: const NeverScrollableScrollPhysics(),
      horizontalScrollPhysics: const ClampingScrollPhysics(),
    );

    expect(await dragHorizontally(tester), greaterThan(0));
    expect(await dragVertically(tester), 0);
  });

  testWidgets(
    'Changing the physics after the grid is built should take effect.',
    (tester) async {
      await TestHelperUtil.changeWidth(tester: tester, width: 500, height: 400);

      final columns = ColumnHelper.textColumn('column', count: 10, width: 200);
      final rows = RowHelper.count(50, columns);

      late StateSetter setOuterState;
      ScrollPhysics? vertical;

      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: StatefulBuilder(
              builder: (context, setState) {
                setOuterState = setState;
                return TrinaGrid(
                  columns: columns,
                  rows: rows,
                  verticalScrollPhysics: vertical,
                  onLoaded: (TrinaGridOnLoadedEvent event) {
                    stateManager = event.stateManager;
                  },
                );
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Starts unrestricted.
      expect(await dragVertically(tester), greaterThan(0));

      // Block the vertical axis without rebuilding the grid from scratch.
      setOuterState(() => vertical = const NeverScrollableScrollPhysics());
      await tester.pumpAndSettle();

      final blockedFrom = stateManager.scroll.vertical!.offset;
      await tester.drag(find.byType(TrinaGrid), const Offset(0, -200));
      await tester.pumpAndSettle();
      expect(stateManager.scroll.vertical!.offset, blockedFrom);

      // And release it again.
      setOuterState(() => vertical = null);
      await tester.pumpAndSettle();

      await tester.drag(find.byType(TrinaGrid), const Offset(0, -200));
      await tester.pumpAndSettle();
      expect(stateManager.scroll.vertical!.offset, greaterThan(blockedFrom));
    },
  );

  testWidgets(
    'A grid inside a scrolling page should hand vertical drags to the page '
    'while keeping its own horizontal scrolling.',
    (tester) async {
      await TestHelperUtil.changeWidth(tester: tester, width: 500, height: 400);

      final columns = ColumnHelper.textColumn('column', count: 10, width: 200);
      final rows = RowHelper.count(50, columns);
      final outerScroll = ScrollController();
      addTearDown(outerScroll.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: ListView(
              controller: outerScroll,
              children: [
                const SizedBox(height: 200),
                TrinaGrid(
                  columns: columns,
                  rows: rows,
                  fitContent: true,
                  verticalScrollPhysics: const NeverScrollableScrollPhysics(),
                  onLoaded: (TrinaGridOnLoadedEvent event) {
                    stateManager = event.stateManager;
                  },
                ),
                const SizedBox(height: 2000),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // `fitContent` makes the grid taller than the viewport, so its center is
      // off-screen. Drag from a point that is inside the grid's rows area.
      const insideGrid = Offset(250, 350);

      // A vertical drag over the grid scrolls the page, not the grid.
      await tester.dragFrom(insideGrid, const Offset(0, -150));
      await tester.pumpAndSettle();

      expect(outerScroll.offset, greaterThan(0));
      expect(stateManager.scroll.vertical!.offset, 0);

      // The grid keeps its own horizontal scrolling.
      final outerOffsetBefore = outerScroll.offset;
      await tester.dragFrom(insideGrid, const Offset(-200, 0));
      await tester.pumpAndSettle();

      expect(stateManager.scroll.horizontal!.offset, greaterThan(0));
      expect(outerScroll.offset, outerOffsetBefore);
    },
  );
}
