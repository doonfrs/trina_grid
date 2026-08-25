import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:trina_grid/trina_grid.dart';

import '../../../helper/column_helper.dart';
import '../../../helper/row_helper.dart';
import '../../../mock/shared_mocks.mocks.dart';

void main() {
  TrinaGridStateManager createStateManager({
    required List<TrinaColumn> columns,
    required List<TrinaRow> rows,
    FocusNode? gridFocusNode,
    TrinaGridScrollController? scroll,
    BoxConstraints? layout,
    TrinaGridConfiguration configuration = const TrinaGridConfiguration(),
  }) {
    final stateManager = TrinaGridStateManager(
      columns: columns,
      rows: rows,
      gridFocusNode: gridFocusNode ?? MockFocusNode(),
      scroll: scroll ?? MockTrinaGridScrollController(),
      configuration: configuration,
    );

    stateManager.setEventManager(MockTrinaGridEventManager());

    if (layout != null) {
      stateManager.setLayout(layout);
    }

    return stateManager;
  }

  group('When there are frozen columns, needMovingScroll', () {
    late TrinaGridStateManager stateManager;

    List<TrinaColumn> columns;

    List<TrinaRow> rows;

    setUp(() {
      columns = [
        ...ColumnHelper.textColumn(
          'left',
          count: 3,
          frozen: TrinaColumnFrozen.start,
        ),
        ...ColumnHelper.textColumn('body', count: 3, width: 150),
        ...ColumnHelper.textColumn(
          'right',
          count: 3,
          frozen: TrinaColumnFrozen.end,
        ),
      ];

      rows = RowHelper.count(10, columns);

      stateManager = createStateManager(
        columns: columns,
        rows: rows,
        gridFocusNode: null,
        scroll: null,
        layout: const BoxConstraints(maxWidth: 300, maxHeight: 500),
      );

      stateManager.setGridGlobalOffset(Offset.zero);
    });

    testWidgets('When scroll offset.dx is less than bodyLeftScrollOffset'
        'but selectingMode is None, should return false.', (
      WidgetTester tester,
    ) async {
      stateManager.setSelectingMode(TrinaGridSelectingMode.none);

      expect(stateManager.selectingMode.isNone, true);

      expect(
        stateManager.needMovingScroll(
          Offset(stateManager.bodyLeftScrollOffset - 1, 0),
          TrinaMoveDirection.left,
        ),
        false,
      );
    });

    testWidgets(
      'When scroll offset.dx is less than bodyLeftScrollOffset, should return true.',
      (WidgetTester tester) async {
        expect(
          stateManager.needMovingScroll(
            Offset(stateManager.bodyLeftScrollOffset - 1, 0),
            TrinaMoveDirection.left,
          ),
          true,
        );
      },
    );

    testWidgets(
      'When scroll offset.dx is equal to bodyLeftScrollOffset, should return false.',
      (WidgetTester tester) async {
        expect(
          stateManager.needMovingScroll(
            Offset(stateManager.bodyLeftScrollOffset, 0),
            TrinaMoveDirection.left,
          ),
          false,
        );
      },
    );

    testWidgets(
      'When scroll offset.dx is greater than bodyLeftScrollOffset, should return false.',
      (WidgetTester tester) async {
        expect(
          stateManager.needMovingScroll(
            Offset(stateManager.bodyLeftScrollOffset + 1, 0),
            TrinaMoveDirection.left,
          ),
          false,
        );
      },
    );

    testWidgets('When scroll offset.dx is greater than bodyRightScrollOffset'
        'but selectingMode is None, should return false.', (
      WidgetTester tester,
    ) async {
      stateManager.setSelectingMode(TrinaGridSelectingMode.none);

      expect(stateManager.selectingMode.isNone, true);

      expect(
        stateManager.needMovingScroll(
          Offset(stateManager.bodyRightScrollOffset + 1, 0),
          TrinaMoveDirection.right,
        ),
        false,
      );
    });

    testWidgets(
      'When scroll offset.dx is greater than bodyRightScrollOffset, should return true.',
      (WidgetTester tester) async {
        expect(
          stateManager.needMovingScroll(
            Offset(stateManager.bodyRightScrollOffset + 1, 0),
            TrinaMoveDirection.right,
          ),
          true,
        );
      },
    );

    testWidgets(
      'When scroll offset.dx is equal to bodyRightScrollOffset, should return false.',
      (WidgetTester tester) async {
        expect(
          stateManager.needMovingScroll(
            Offset(stateManager.bodyRightScrollOffset, 0),
            TrinaMoveDirection.right,
          ),
          false,
        );
      },
    );

    testWidgets(
      'When scroll offset.dx is less than bodyRightScrollOffset, should return false.',
      (WidgetTester tester) async {
        expect(
          stateManager.needMovingScroll(
            Offset(stateManager.bodyRightScrollOffset - 1, 0),
            TrinaMoveDirection.right,
          ),
          false,
        );
      },
    );

    testWidgets(
      'When scroll offset.dy is less than bodyUpScrollOffset, should return true.',
      (WidgetTester tester) async {
        expect(
          stateManager.needMovingScroll(
            Offset(0, stateManager.bodyUpScrollOffset - 1),
            TrinaMoveDirection.up,
          ),
          true,
        );
      },
    );

    testWidgets(
      'When scroll offset.dy is equal to bodyUpScrollOffset, should return false.',
      (WidgetTester tester) async {
        expect(
          stateManager.needMovingScroll(
            Offset(0, stateManager.bodyUpScrollOffset),
            TrinaMoveDirection.up,
          ),
          false,
        );
      },
    );

    testWidgets(
      'When scroll offset.dy is greater than bodyUpScrollOffset, should return false.',
      (WidgetTester tester) async {
        expect(
          stateManager.needMovingScroll(
            Offset(0, stateManager.bodyUpScrollOffset + 1),
            TrinaMoveDirection.up,
          ),
          false,
        );
      },
    );

    testWidgets(
      'When scroll offset.dy is greater than bodyDownScrollOffset, should return true.',
      (WidgetTester tester) async {
        expect(
          stateManager.needMovingScroll(
            Offset(0, stateManager.bodyDownScrollOffset + 1),
            TrinaMoveDirection.down,
          ),
          true,
        );
      },
    );

    testWidgets(
      'When scroll offset.dy is equal to bodyDownScrollOffset, should return false.',
      (WidgetTester tester) async {
        expect(
          stateManager.needMovingScroll(
            Offset(0, stateManager.bodyDownScrollOffset),
            TrinaMoveDirection.down,
          ),
          false,
        );
      },
    );

    testWidgets(
      'When scroll offset.dy is less than bodyDownScrollOffset, should return false.',
      (WidgetTester tester) async {
        expect(
          stateManager.needMovingScroll(
            Offset(0, stateManager.bodyDownScrollOffset - 1),
            TrinaMoveDirection.down,
          ),
          false,
        );
      },
    );
  });

  group('When the body scroll controllers are not laid out', () {
    late TrinaGridStateManager stateManager;

    late MockTrinaGridScrollController scroll;

    late MockLinkedScrollControllerGroup vertical;

    late MockLinkedScrollControllerGroup horizontal;

    late List<TrinaColumn> columns;

    setUp(() {
      scroll = MockTrinaGridScrollController();
      vertical = MockLinkedScrollControllerGroup();
      horizontal = MockLinkedScrollControllerGroup();

      when(scroll.vertical).thenReturn(vertical);
      when(scroll.horizontal).thenReturn(horizontal);
      when(scroll.verticalOffset).thenReturn(0);
      when(scroll.horizontalOffset).thenReturn(0);
      when(vertical.offset).thenReturn(0);
      when(horizontal.offset).thenReturn(0);

      // Left unstubbed on purpose: a grid whose body lists have not been laid
      // out yet has no body scroll controller, so the scrolling logic has to
      // fall back to geometry computed from the configuration.
      expect(scroll.bodyRowsVertical, isNull);
      expect(scroll.bodyRowsHorizontal, isNull);

      columns = ColumnHelper.textColumn('column', count: 5, width: 200);

      stateManager = createStateManager(
        columns: columns,
        rows: RowHelper.count(20, columns),
        scroll: scroll,
        layout: const BoxConstraints(maxWidth: 500, maxHeight: 500),
      );

      stateManager.setGridGlobalOffset(Offset.zero);
    });

    test(
      'moveScrollByColumn should exclude the reserved vertical scrollbar band.',
      () {
        stateManager.moveScrollByColumn(TrinaMoveDirection.right, 3);

        final lastColumn = columns.last;

        final expectedOffset =
            lastColumn.startPosition +
            lastColumn.width -
            (500 -
                stateManager
                    .configuration
                    .scrollbar
                    .verticalScrollBarReservedWidth);

        verify(horizontal.jumpTo(expectedOffset)).called(1);
      },
    );

    test(
      'moveScrollByRow should fall back to the computed viewport height.',
      () {
        stateManager.moveScrollByRow(TrinaMoveDirection.down, 12);

        final style = stateManager.configuration.style;

        final rowTotalHeight =
            style.rowHeight + style.cellHorizontalBorderWidth;

        final viewportHeight =
            stateManager.columnRowContainerHeight -
            stateManager.columnGroupHeight -
            stateManager.columnHeight -
            stateManager.columnFilterHeight -
            stateManager.columnFooterHeight -
            style.cellHorizontalBorderWidth;

        // Rows 0 through 12 scrolled past, then the target row 13 has to fit
        // fully, including the border the list lays out beneath it.
        final expectedOffset =
            (13 * rowTotalHeight) + rowTotalHeight - viewportHeight;

        verify(vertical.jumpTo(expectedOffset)).called(1);
      },
    );
  });
}
