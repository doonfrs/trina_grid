import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trina_grid/trina_grid.dart';

import '../helper/column_helper.dart';
import '../helper/trina_widget_test_helper.dart';
import '../helper/row_helper.dart';

void main() {
  testWidgets('When two grids are created, the cells should be displayed.', (
    WidgetTester tester,
  ) async {
    // given
    final gridAColumns = ColumnHelper.textColumn('headerA');
    final gridARows = RowHelper.count(3, gridAColumns);

    final gridBColumns = ColumnHelper.textColumn('headerB');
    final gridBRows = RowHelper.count(3, gridBColumns);

    // when
    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: TrinaDualGrid(
            gridPropsA: TrinaDualGridProps(
              columns: gridAColumns,
              rows: gridARows,
            ),
            gridPropsB: TrinaDualGridProps(
              columns: gridBColumns,
              rows: gridBRows,
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle(const Duration(seconds: 1));

    // then
    final gridACell1 = find.text('headerA0 value 0');
    expect(gridACell1, findsOneWidget);

    final gridACell2 = find.text('headerA0 value 1');
    expect(gridACell2, findsOneWidget);

    final gridACell3 = find.text('headerA0 value 2');
    expect(gridACell3, findsOneWidget);

    final gridBCell1 = find.text('headerB0 value 0');
    expect(gridBCell1, findsOneWidget);

    final gridBCell2 = find.text('headerB0 value 1');
    expect(gridBCell2, findsOneWidget);

    final gridBCell3 = find.text('headerB0 value 2');
    expect(gridBCell3, findsOneWidget);
  });

  testWidgets(
    'When Directionality is LTR, grid A should be on the left, and grid B should be on the right.',
    (WidgetTester tester) async {
      // given
      final gridAColumns = ColumnHelper.textColumn('headerA');
      final gridARows = RowHelper.count(3, gridAColumns);

      final gridBColumns = ColumnHelper.textColumn('headerB');
      final gridBRows = RowHelper.count(3, gridBColumns);

      // when
      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: TrinaDualGrid(
                gridPropsA: TrinaDualGridProps(
                  columns: gridAColumns,
                  rows: gridARows,
                ),
                gridPropsB: TrinaDualGridProps(
                  columns: gridBColumns,
                  rows: gridBRows,
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle(const Duration(seconds: 1));

      final gridAFirstColumn = find.text('headerA0');
      final gridBFirstColumn = find.text('headerB0');

      final gridAFistDx = tester.getTopRight(gridAFirstColumn).dx;
      final gridBFistDx = tester.getTopRight(gridBFirstColumn).dx;

      expect(gridAFistDx, lessThan(gridBFistDx));
    },
  );

  testWidgets(
    'When Directionality is RTL, grid A should be on the right, and grid B should be on the left.',
    (WidgetTester tester) async {
      // given
      final gridAColumns = ColumnHelper.textColumn('headerA');
      final gridARows = RowHelper.count(3, gridAColumns);

      final gridBColumns = ColumnHelper.textColumn('headerB');
      final gridBRows = RowHelper.count(3, gridBColumns);

      // when
      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: TrinaDualGrid(
                gridPropsA: TrinaDualGridProps(
                  columns: gridAColumns,
                  rows: gridARows,
                ),
                gridPropsB: TrinaDualGridProps(
                  columns: gridBColumns,
                  rows: gridBRows,
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle(const Duration(seconds: 1));

      final gridAFirstColumn = find.text('headerA0');
      final gridBFirstColumn = find.text('headerB0');

      final gridAFistDx = tester.getTopRight(gridAFirstColumn).dx;
      final gridBFistDx = tester.getTopRight(gridBFirstColumn).dx;

      expect(gridAFistDx, greaterThan(gridBFistDx));
    },
  );

  group('When the divider is created, the following tests should be performed.', () {
    GlobalKey gridAKey = GlobalKey();
    GlobalKey gridBKey = GlobalKey();

    dualGrid(
      TrinaDualGridDivider divider, {
      TrinaDualGridDisplay? display,
      TextDirection textDirection = TextDirection.ltr,
    }) {
      return TrinaWidgetTestHelper('Create Grid.', (tester) async {
        final gridAColumns = ColumnHelper.textColumn('headerA', count: 3);
        final gridARows = RowHelper.count(3, gridAColumns);

        final gridBColumns = ColumnHelper.textColumn('headerB', count: 3);
        final gridBRows = RowHelper.count(3, gridBColumns);

        await tester.pumpWidget(
          MaterialApp(
            home: Material(
              child: Directionality(
                textDirection: textDirection,
                child: TrinaDualGrid(
                  gridPropsA: TrinaDualGridProps(
                    columns: gridAColumns,
                    rows: gridARows,
                    key: gridAKey,
                  ),
                  gridPropsB: TrinaDualGridProps(
                    columns: gridBColumns,
                    rows: gridBRows,
                    key: gridBKey,
                  ),
                  divider: divider,
                  display: display,
                ),
              ),
            ),
          ),
        );
      });
    }

    dualGrid(const TrinaDualGridDivider()).test(
      'The Divider widget should be rendered.',
      (tester) async {
        final findDivider = find.byType(TrinaDualGridDividerWidget);

        expect(findDivider, findsOneWidget);
      },
    );

    dualGrid(const TrinaDualGridDivider()).test(
      'The Divider should be rendered with default colors.',
      (tester) async {
        final findDivider = find.byType(TrinaDualGridDividerWidget);

        final coloredBox = tester.widget<ColoredBox>(
          find.descendant(of: findDivider, matching: find.byType(ColoredBox)),
        );

        expect(coloredBox.color, Colors.white);

        final icon = tester.widget<Icon>(
          find.descendant(of: findDivider, matching: find.byType(Icon)),
        );

        expect(icon.color, const Color(0xFFA1A5AE));
      },
    );

    dualGrid(
      const TrinaDualGridDivider(
        backgroundColor: Colors.deepOrange,
        indicatorColor: Colors.indigoAccent,
      ),
    ).test('The Divider should be rendered with custom colors.', (
      tester,
    ) async {
      final findDivider = find.byType(TrinaDualGridDividerWidget);

      final coloredBox = tester.widget<ColoredBox>(
        find.descendant(of: findDivider, matching: find.byType(ColoredBox)),
      );

      expect(coloredBox.color, Colors.deepOrange);

      final icon = tester.widget<Icon>(
        find.descendant(of: findDivider, matching: find.byType(Icon)),
      );

      expect(icon.color, Colors.indigoAccent);
    });

    dualGrid(const TrinaDualGridDivider(show: false)).test(
      'When show is false, the Divider should not be rendered.',
      (tester) async {
        final findDivider = find.byType(TrinaDualGridDividerWidget);

        expect(findDivider, findsNothing);
      },
    );

    dualGrid(const TrinaDualGridDivider()).test(
      'When the Divider is dragged to the right, the position of the Divider should increase.',
      (tester) async {
        final findDivider = find.byType(TrinaDualGridDividerWidget);

        final firstCenter = tester.getCenter(findDivider);

        await tester.drag(findDivider, const Offset(100, 0));

        await tester.pump();

        final movedCenter = tester.getCenter(findDivider);

        expect(movedCenter.dx, firstCenter.dx + 100);
      },
    );

    dualGrid(const TrinaDualGridDivider()).test(
      'When the Divider is dragged to the left, the position of the Divider should increase.',
      (tester) async {
        final findDivider = find.byType(TrinaDualGridDividerWidget);

        final firstCenter = tester.getCenter(findDivider);

        await tester.drag(findDivider, const Offset(-100, 0));

        await tester.pump();

        final movedCenter = tester.getCenter(findDivider);

        expect(movedCenter.dx, firstCenter.dx - 100);
      },
    );

    dualGrid(const TrinaDualGridDivider()).test(
      'When the Divider is dragged to the right by 100, '
      'the left grid should increase by 100, '
      'and the right grid should decrease by 100.',
      (tester) async {
        final findDivider = find.byType(TrinaDualGridDividerWidget);

        final findGridA = find.byKey(gridAKey);
        final findGridB = find.byKey(gridBKey);

        final firstAWidth = tester.getSize(findGridA).width;
        final firstBWidth = tester.getSize(findGridB).width;

        await tester.drag(findDivider, const Offset(100, 0));

        await tester.pump();

        final movedAWidth = tester.getSize(findGridA).width;
        final movedBWidth = tester.getSize(findGridB).width;

        expect(movedAWidth, firstAWidth + 100);
        expect(movedBWidth, firstBWidth - 100);
      },
    );

    dualGrid(const TrinaDualGridDivider(), textDirection: TextDirection.rtl).test(
      'When Directionality is RTL, '
      'the position of the Divider should increase when dragged to the right by 100, '
      'GridB should increase by 100, '
      'and GridA should decrease by 100.',
      (tester) async {
        final findDivider = find.byType(TrinaDualGridDividerWidget);

        final findGridA = find.byKey(gridAKey);
        final findGridB = find.byKey(gridBKey);

        final firstAWidth = tester.getSize(findGridA).width;
        final firstBWidth = tester.getSize(findGridB).width;

        await tester.drag(findDivider, const Offset(100, 0));

        await tester.pump();

        final movedAWidth = tester.getSize(findGridA).width;
        final movedBWidth = tester.getSize(findGridB).width;

        expect(movedAWidth, firstAWidth - 100);
        expect(movedBWidth, firstBWidth + 100);
      },
    );

    dualGrid(const TrinaDualGridDivider()).test(
      'When the Divider is dragged to the left by 100, '
      'the left grid should increase by 100, '
      'and the right grid should decrease by 100.',
      (tester) async {
        final findDivider = find.byType(TrinaDualGridDividerWidget);

        final findGridA = find.byKey(gridAKey);
        final findGridB = find.byKey(gridBKey);

        final firstAWidth = tester.getSize(findGridA).width;
        final firstBWidth = tester.getSize(findGridB).width;

        await tester.drag(findDivider, const Offset(-100, 0));

        await tester.pump();

        final movedAWidth = tester.getSize(findGridA).width;
        final movedBWidth = tester.getSize(findGridB).width;

        expect(movedAWidth, firstAWidth - 100);
        expect(movedBWidth, firstBWidth + 100);
      },
    );

    dualGrid(const TrinaDualGridDivider(), textDirection: TextDirection.rtl).test(
      'When Directionality is RTL, '
      'the position of the Divider should increase when dragged to the left by 100, '
      'GridB should increase by 100, '
      'and GridA should decrease by 100.',
      (tester) async {
        final findDivider = find.byType(TrinaDualGridDividerWidget);

        final findGridA = find.byKey(gridAKey);
        final findGridB = find.byKey(gridBKey);

        final firstAWidth = tester.getSize(findGridA).width;
        final firstBWidth = tester.getSize(findGridB).width;

        await tester.drag(findDivider, const Offset(-100, 0));

        await tester.pump();

        final movedAWidth = tester.getSize(findGridA).width;
        final movedBWidth = tester.getSize(findGridB).width;

        expect(movedAWidth, firstAWidth + 100);
        expect(movedBWidth, firstBWidth - 100);
      },
    );
  });

  group('Grid cell movement test', () {
    TrinaGridStateManager? stateManagerA;
    TrinaGridStateManager? stateManagerB;

    group('Left grid', () {
      buildLeftGridCellSelected({
        TextDirection textDirection = TextDirection.ltr,
      }) {
        return TrinaWidgetTestHelper('First cell is selected', (tester) async {
          final gridAColumns = ColumnHelper.textColumn('headerA', count: 3);
          final gridARows = RowHelper.count(3, gridAColumns);

          final gridBColumns = ColumnHelper.textColumn('headerB', count: 3);
          final gridBRows = RowHelper.count(3, gridBColumns);

          await tester.pumpWidget(
            MaterialApp(
              home: Material(
                child: TrinaDualGrid(
                  gridPropsA: TrinaDualGridProps(
                    columns: gridAColumns,
                    rows: gridARows,
                    onLoaded: (TrinaGridOnLoadedEvent event) =>
                        stateManagerA = event.stateManager,
                  ),
                  gridPropsB: TrinaDualGridProps(
                    columns: gridBColumns,
                    rows: gridBRows,
                    onLoaded: (TrinaGridOnLoadedEvent event) =>
                        stateManagerB = event.stateManager,
                  ),
                ),
              ),
            ),
          );

          await tester.pump();

          await tester.tap(find.text('headerA0 value 0'));
        });
      }

      buildLeftGridCellSelected().test(
        'When moving to the right end and then pressing the right arrow key again, '
        'the focus should be transferred to the right grid.'
        'And then pressing the right arrow key again, '
        'the first cell of the right grid should be selected.',
        (tester) async {
          // 0 > 1
          await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
          await tester.pumpAndSettle();
          // 1 > 2
          await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
          await tester.pumpAndSettle();

          expect(stateManagerA!.gridFocusNode.hasFocus, isTrue);
          expect(stateManagerB!.gridFocusNode.hasFocus, isFalse);

          // 2 > right grid
          await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
          await tester.pumpAndSettle();

          expect(stateManagerA!.gridFocusNode.hasFocus, isFalse);
          expect(stateManagerB!.gridFocusNode.hasFocus, isTrue);

          // right grid > 0
          await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
          expect(stateManagerB!.currentCell!.value, 'headerB0 value 0');
        },
      );

      buildLeftGridCellSelected().test(
        'When moving to the right end and then pressing the tab key, '
        'the focus should be transferred to the right grid.'
        'And then pressing the tab key, '
        'the first cell of the right grid should be selected.',
        (tester) async {
          // 0 > 1
          await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
          await tester.pumpAndSettle();
          // 1 > 2
          await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
          await tester.pumpAndSettle();
          // 2 > right grid
          await tester.sendKeyEvent(LogicalKeyboardKey.tab);
          await tester.pumpAndSettle();

          expect(stateManagerA!.gridFocusNode.hasFocus, isFalse);
          expect(stateManagerB!.gridFocusNode.hasFocus, isTrue);

          // right grid > 0
          await tester.sendKeyEvent(LogicalKeyboardKey.tab);
          expect(stateManagerB!.currentCell!.value, 'headerB0 value 0');
        },
      );

      buildLeftGridCellSelected().test(
        'When moving to the right end and then pressing the tab key, '
        'the focus should be transferred to the right grid.'
        'And then pressing the tab key, '
        'the first cell of the right grid should be selected.'
        'And then pressing the tab key, '
        'the focus should be transferred back to the left grid.',
        (tester) async {
          // 0 > 1
          await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
          await tester.pumpAndSettle();
          // 1 > 2
          await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
          await tester.pumpAndSettle();
          // 2 > right grid
          await tester.sendKeyEvent(LogicalKeyboardKey.tab);
          await tester.pumpAndSettle();

          expect(stateManagerA!.gridFocusNode.hasFocus, isFalse);
          expect(stateManagerB!.gridFocusNode.hasFocus, isTrue);

          // right grid > 0
          await tester.sendKeyDownEvent(LogicalKeyboardKey.shift);
          await tester.pumpAndSettle();
          await tester.sendKeyEvent(LogicalKeyboardKey.tab);
          await tester.pumpAndSettle();
          await tester.sendKeyUpEvent(LogicalKeyboardKey.shift);
          await tester.pumpAndSettle();
          expect(stateManagerB!.currentCell!.value, 'headerB0 value 0');

          // right grid > left grid
          await tester.sendKeyDownEvent(LogicalKeyboardKey.shift);
          await tester.pumpAndSettle();
          await tester.sendKeyEvent(LogicalKeyboardKey.tab);
          await tester.pumpAndSettle();
          await tester.sendKeyUpEvent(LogicalKeyboardKey.shift);

          expect(stateManagerA!.gridFocusNode.hasFocus, isTrue);
          expect(stateManagerB!.gridFocusNode.hasFocus, isFalse);
        },
      );
    });
  });

  group('TrinaDualGridDisplayRatio', () {
    test('When ratio is 0, an assert error should be thrown', () {
      expect(() {
        TrinaDualGridDisplayRatio(ratio: 0);
      }, throwsA(isA<AssertionError>()));
    });

    test('When ratio is 1, an assert error should be thrown', () {
      expect(() {
        TrinaDualGridDisplayRatio(ratio: 1);
      }, throwsA(isA<AssertionError>()));
    });

    test('When ratio is 0.5, the width should be 5:5', () {
      var display = TrinaDualGridDisplayRatio(ratio: 0.5);

      const size = BoxConstraints(maxWidth: 200);

      expect(display.gridAWidth(size), 100);
      expect(display.gridBWidth(size), 100);
    });

    test('When ratio is 0.1, the width should be 1:9', () {
      var display = TrinaDualGridDisplayRatio(ratio: 0.1);

      const size = BoxConstraints(maxWidth: 200);

      expect(display.gridAWidth(size), 20);
      expect(display.gridBWidth(size), 180);
    });
  });

  group('TrinaDualGridDisplayFixedAndExpanded', () {
    test('When width is 100', () {
      var display = TrinaDualGridDisplayFixedAndExpanded(width: 100);

      const size = BoxConstraints(maxWidth: 200);

      expect(display.gridAWidth(size), 100);
      expect(display.gridBWidth(size), 100);
    });

    test('When width is 50', () {
      var display = TrinaDualGridDisplayFixedAndExpanded(width: 50);

      const size = BoxConstraints(maxWidth: 200);

      expect(display.gridAWidth(size), 50);
      expect(display.gridBWidth(size), 150);
    });
  });

  group('TrinaDualGridDisplayExpandedAndFixed', () {
    test('When width is 100', () {
      var display = TrinaDualGridDisplayExpandedAndFixed(width: 100);

      const size = BoxConstraints(maxWidth: 200);

      expect(display.gridAWidth(size), 100);
      expect(display.gridBWidth(size), 100);
    });

    test('When width is 50', () {
      var display = TrinaDualGridDisplayExpandedAndFixed(width: 50);

      const size = BoxConstraints(maxWidth: 200);

      expect(display.gridAWidth(size), 150);
      expect(display.gridBWidth(size), 50);
    });
  });
}
