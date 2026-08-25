import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trina_grid/trina_grid.dart';
import 'package:trina_grid/src/widgets/trina_horizontal_scroll_bar.dart';
import 'package:trina_grid/src/widgets/trina_vertical_scroll_bar.dart';

import '../../helper/column_helper.dart';
import '../../helper/row_helper.dart';
import '../../helper/test_helper_util.dart';

/// Regression tests for https://github.com/doonfrs/trina_grid/issues/389
///
/// Scrolling driven by the keyboard used to stop short of the maximum scroll
/// extent, leaving the last row and the last column partially hidden under the
/// overlaid scrollbars, while the mouse wheel and the scrollbars reached the end
/// correctly.
void main() {
  late TrinaGridStateManager stateManager;

  Future<List<TrinaColumn>> buildGrid(
    WidgetTester tester, {
    int columnCount = 10,
    int rowCount = 30,
    double width = 500,
    double height = 400,
    double columnWidth = 200,
    TrinaGridConfiguration configuration = const TrinaGridConfiguration(),
    List<TrinaColumnGroup>? columnGroups,
    void Function(List<TrinaColumn> columns)? beforeBuild,
  }) async {
    await TestHelperUtil.changeWidth(
      tester: tester,
      width: width,
      height: height,
    );

    final columns = ColumnHelper.textColumn(
      'column',
      count: columnCount,
      width: columnWidth,
    );

    beforeBuild?.call(columns);

    final rows = RowHelper.count(rowCount, columns);

    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: TrinaGrid(
            columns: columns,
            columnGroups: columnGroups,
            rows: rows,
            configuration: configuration,
            onLoaded: (TrinaGridOnLoadedEvent event) {
              stateManager = event.stateManager;
              stateManager.setKeepFocus(true);
            },
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    return columns;
  }

  double horizontalOffset() => stateManager.scroll.bodyRowsHorizontal!.offset;

  double verticalOffset() => stateManager.scroll.bodyRowsVertical!.offset;

  group('Keyboard scrolling reaches the end of the grid', () {
    testWidgets(
      'Scrolling to the last column should land on the maximum scroll extent.',
      (tester) async {
        final columns = await buildGrid(tester);

        stateManager.moveScrollByColumn(
          TrinaMoveDirection.right,
          columns.length - 2,
        );
        await tester.pumpAndSettle();

        expect(
          horizontalOffset(),
          closeTo(stateManager.scroll.maxScrollHorizontal, 0.5),
        );
      },
    );

    testWidgets(
      'Moving to the last column with the arrow keys should land on the '
      'maximum scroll extent.',
      (tester) async {
        final columns = await buildGrid(tester);

        stateManager.setCurrentCell(
          stateManager.refRows.first.cells['column0'],
          0,
        );
        await tester.pumpAndSettle();

        for (int i = 0; i < columns.length - 1; i += 1) {
          await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
          await tester.pumpAndSettle();
        }

        expect(stateManager.currentColumn?.field, 'column9');
        expect(
          horizontalOffset(),
          closeTo(stateManager.scroll.maxScrollHorizontal, 0.5),
        );
      },
    );

    testWidgets(
      'Moving to the last column with the Tab key should land on the maximum '
      'scroll extent.',
      (tester) async {
        final columns = await buildGrid(tester);

        stateManager.setCurrentCell(
          stateManager.refRows.first.cells['column0'],
          0,
        );
        await tester.pumpAndSettle();

        for (int i = 0; i < columns.length - 1; i += 1) {
          await tester.sendKeyEvent(LogicalKeyboardKey.tab);
          await tester.pumpAndSettle();
        }

        expect(stateManager.currentColumn?.field, 'column9');
        expect(
          horizontalOffset(),
          closeTo(stateManager.scroll.maxScrollHorizontal, 0.5),
        );
      },
    );

    testWidgets(
      'Scrolling to the last row should land on the maximum scroll extent.',
      (tester) async {
        await buildGrid(tester);

        stateManager.moveScrollByRow(
          TrinaMoveDirection.down,
          stateManager.refRows.length - 2,
        );
        await tester.pumpAndSettle();

        expect(
          verticalOffset(),
          closeTo(stateManager.scroll.maxScrollVertical, 0.5),
        );
      },
    );

    testWidgets(
      'Moving to the last row with the arrow keys should land on the maximum '
      'scroll extent.',
      (tester) async {
        await buildGrid(tester, rowCount: 20);

        stateManager.setCurrentCell(
          stateManager.refRows.first.cells['column0'],
          0,
        );
        await tester.pumpAndSettle();

        for (int i = 0; i < stateManager.refRows.length - 1; i += 1) {
          await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
          await tester.pumpAndSettle();
        }

        expect(stateManager.currentRowIdx, stateManager.refRows.length - 1);
        expect(
          verticalOffset(),
          closeTo(stateManager.scroll.maxScrollVertical, 0.5),
        );
      },
    );

    testWidgets(
      'Moving to the last row with the PageDown key should land on the maximum '
      'scroll extent.',
      (tester) async {
        await buildGrid(tester, rowCount: 20);

        stateManager.setCurrentCell(
          stateManager.refRows.first.cells['column0'],
          0,
        );
        await tester.pumpAndSettle();

        for (int i = 0; i < 10; i += 1) {
          await tester.sendKeyEvent(LogicalKeyboardKey.pageDown);
          await tester.pumpAndSettle();
        }

        expect(stateManager.currentRowIdx, stateManager.refRows.length - 1);
        expect(
          verticalOffset(),
          closeTo(stateManager.scroll.maxScrollVertical, 0.5),
        );
      },
    );

    testWidgets(
      'The last column should be clear of the overlaid vertical scrollbar.',
      (tester) async {
        final columns = await buildGrid(tester);

        stateManager.moveScrollByColumn(
          TrinaMoveDirection.right,
          columns.length - 2,
        );
        await tester.pumpAndSettle();

        final lastCell = find.text('column9 value 0');
        final lastCellRight = tester.getTopRight(lastCell).dx;
        final scrollBarLeft = tester
            .getTopLeft(find.byType(TrinaVerticalScrollBar))
            .dx;

        expect(lastCellRight, lessThanOrEqualTo(scrollBarLeft + 0.5));
      },
    );

    testWidgets('The last row should be clear of the horizontal scrollbar.', (
      tester,
    ) async {
      await buildGrid(tester);

      stateManager.moveScrollByRow(
        TrinaMoveDirection.down,
        stateManager.refRows.length - 2,
      );
      await tester.pumpAndSettle();

      final lastCell = find.text('column0 value 29');
      final lastCellBottom = tester.getBottomLeft(lastCell).dy;
      final scrollBarTop = tester
          .getTopLeft(find.byType(TrinaHorizontalScrollBar))
          .dy;

      expect(lastCellBottom, lessThanOrEqualTo(scrollBarTop + 0.5));
    });
  });

  group('Keyboard scrolling with frozen columns', () {
    testWidgets(
      'Scrolling to the last row should land on the maximum scroll extent.',
      (tester) async {
        await buildGrid(
          tester,
          // Wide enough that the grid keeps the frozen columns visible.
          width: 900,
          beforeBuild: (columns) {
            columns.first.frozen = TrinaColumnFrozen.start;
            columns.last.frozen = TrinaColumnFrozen.end;
          },
        );

        expect(stateManager.showFrozenColumn, isTrue);

        stateManager.moveScrollByRow(
          TrinaMoveDirection.down,
          stateManager.refRows.length - 2,
        );
        await tester.pumpAndSettle();

        expect(
          verticalOffset(),
          closeTo(stateManager.scroll.maxScrollVertical, 0.5),
        );
      },
    );

    testWidgets('Ctrl + End should land on the maximum scroll extent.', (
      tester,
    ) async {
      await buildGrid(
        tester,
        // Wide enough that the grid keeps the frozen columns visible.
        width: 900,
        beforeBuild: (columns) {
          columns.first.frozen = TrinaColumnFrozen.start;
          columns.last.frozen = TrinaColumnFrozen.end;
        },
      );

      expect(stateManager.showFrozenColumn, isTrue);

      stateManager.setCurrentCell(
        stateManager.refRows.first.cells['column1'],
        0,
      );
      await tester.pumpAndSettle();

      await tester.sendKeyDownEvent(LogicalKeyboardKey.control);
      await tester.sendKeyEvent(LogicalKeyboardKey.end);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.control);
      await tester.pumpAndSettle();

      expect(
        verticalOffset(),
        closeTo(stateManager.scroll.maxScrollVertical, 0.5),
      );
    });
  });

  group('Keyboard scrolling with other scrollbar configurations', () {
    testWidgets(
      'With the vertical scrollbar hidden, the last column should still land on '
      'the maximum scroll extent.',
      (tester) async {
        final columns = await buildGrid(
          tester,
          configuration: const TrinaGridConfiguration(
            scrollbar: TrinaGridScrollbarConfig(showVertical: false),
          ),
        );

        stateManager.moveScrollByColumn(
          TrinaMoveDirection.right,
          columns.length - 2,
        );
        await tester.pumpAndSettle();

        expect(
          horizontalOffset(),
          closeTo(stateManager.scroll.maxScrollHorizontal, 0.5),
        );
      },
    );

    testWidgets(
      'With the horizontal scrollbar hidden, the last row should still land on '
      'the maximum scroll extent.',
      (tester) async {
        await buildGrid(
          tester,
          configuration: const TrinaGridConfiguration(
            scrollbar: TrinaGridScrollbarConfig(showHorizontal: false),
          ),
        );

        stateManager.moveScrollByRow(
          TrinaMoveDirection.down,
          stateManager.refRows.length - 2,
        );
        await tester.pumpAndSettle();

        expect(
          verticalOffset(),
          closeTo(stateManager.scroll.maxScrollVertical, 0.5),
        );
      },
    );

    testWidgets(
      'The reserved scrollbar band should follow a custom thickness.',
      (tester) async {
        final columns = await buildGrid(
          tester,
          configuration: const TrinaGridConfiguration(
            scrollbar: TrinaGridScrollbarConfig(thickness: 20),
          ),
        );

        stateManager.moveScrollByColumn(
          TrinaMoveDirection.right,
          columns.length - 2,
        );
        await tester.pumpAndSettle();

        expect(
          horizontalOffset(),
          closeTo(stateManager.scroll.maxScrollHorizontal, 0.5),
        );
      },
    );

    testWidgets(
      'A grid with a header, column groups, a column filter and a column footer '
      'should still land on the maximum scroll extent.',
      (tester) async {
        await buildGrid(
          tester,
          height: 600,
          columnGroups: [
            TrinaColumnGroup(
              title: 'group',
              fields: ['column0', 'column1', 'column2'],
            ),
          ],
          beforeBuild: (columns) {
            columns.first.footerRenderer = (context) => const Text('footer');
          },
        );

        stateManager.setShowColumnFilter(true);
        await tester.pumpAndSettle();

        stateManager.moveScrollByRow(
          TrinaMoveDirection.down,
          stateManager.refRows.length - 2,
        );
        await tester.pumpAndSettle();

        expect(
          verticalOffset(),
          closeTo(stateManager.scroll.maxScrollVertical, 0.5),
        );
      },
    );
  });

  group('Keyboard scrolling stays inside the scrollable range', () {
    testWidgets('Scrolling should never overshoot the maximum extent.', (
      tester,
    ) async {
      final columns = await buildGrid(tester);

      stateManager.moveScrollByColumn(
        TrinaMoveDirection.right,
        columns.length - 2,
      );
      stateManager.moveScrollByRow(
        TrinaMoveDirection.down,
        stateManager.refRows.length - 2,
      );
      await tester.pumpAndSettle();

      expect(
        horizontalOffset(),
        lessThanOrEqualTo(stateManager.scroll.maxScrollHorizontal),
      );
      expect(
        verticalOffset(),
        lessThanOrEqualTo(stateManager.scroll.maxScrollVertical),
      );
    });

    testWidgets('Scrolling back should reach the start of the grid.', (
      tester,
    ) async {
      final columns = await buildGrid(tester);

      stateManager.moveScrollByColumn(
        TrinaMoveDirection.right,
        columns.length - 2,
      );
      stateManager.moveScrollByRow(
        TrinaMoveDirection.down,
        stateManager.refRows.length - 2,
      );
      await tester.pumpAndSettle();

      stateManager.moveScrollByColumn(TrinaMoveDirection.left, 1);
      stateManager.moveScrollByRow(TrinaMoveDirection.up, 1);
      await tester.pumpAndSettle();

      expect(horizontalOffset(), closeTo(0, 0.5));
      expect(verticalOffset(), closeTo(0, 0.5));
    });

    testWidgets(
      'A grid that does not overflow should not scroll and should not throw.',
      (tester) async {
        await buildGrid(
          tester,
          columnCount: 2,
          rowCount: 3,
          columnWidth: 100,
          width: 800,
          height: 600,
        );

        stateManager.moveScrollByColumn(TrinaMoveDirection.right, 0);
        stateManager.moveScrollByRow(TrinaMoveDirection.down, 1);
        await tester.pumpAndSettle();

        expect(horizontalOffset(), closeTo(0, 0.5));
        expect(verticalOffset(), closeTo(0, 0.5));
      },
    );
  });
}
