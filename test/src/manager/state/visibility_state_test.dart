import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:trina_grid/trina_grid.dart';

import '../../../helper/column_helper.dart';
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

    stateManager.setEventManager(
      TrinaGridEventManager(stateManager: stateManager),
    );

    if (layout != null) {
      stateManager.setLayout(layout);
    }

    return stateManager;
  }

  group('updateColumnStartPosition', () {
    testWidgets('When 5 non-frozen columns'
        'then startPosition of the columns should be set.', (
      widgetTester,
    ) async {
      const defaultWidth = TrinaGridSettings.columnWidth;

      final columns = ColumnHelper.textColumn(
        'column',
        count: 5,
        frozen: TrinaColumnFrozen.none,
      );

      final stateManager = createStateManager(columns: columns, rows: []);

      stateManager.updateVisibilityLayout();

      expect(stateManager.columns[0].startPosition, 0);
      expect(stateManager.columns[1].startPosition, defaultWidth * 1);
      expect(stateManager.columns[2].startPosition, defaultWidth * 2);
      expect(stateManager.columns[3].startPosition, defaultWidth * 3);
      expect(stateManager.columns[4].startPosition, defaultWidth * 4);
    });

    testWidgets(
      'Non-frozen 5 columns with modified width. The startPosition of the columns should be set',
      (widgetTester) async {
        const defaultWidth = 100.0;

        final columns = ColumnHelper.textColumn(
          'column',
          count: 5,
          width: defaultWidth,
          frozen: TrinaColumnFrozen.none,
        );

        final stateManager = createStateManager(columns: columns, rows: []);

        stateManager.updateVisibilityLayout();

        expect(stateManager.columns[0].startPosition, 0);
        expect(stateManager.columns[1].startPosition, defaultWidth * 1);
        expect(stateManager.columns[2].startPosition, defaultWidth * 2);
        expect(stateManager.columns[3].startPosition, defaultWidth * 3);
        expect(stateManager.columns[4].startPosition, defaultWidth * 4);
      },
    );

    testWidgets(
      'Non-frozen 5 columns with modified widths. The startPosition of the columns should be set',
      (widgetTester) async {
        final widths = <double>[100, 150, 80, 90, 200];

        final columns = ColumnHelper.textColumn(
          'column',
          count: 5,
          frozen: TrinaColumnFrozen.none,
        );

        for (int i = 0; i < columns.length; i += 1) {
          columns[i].width = widths[i];
        }

        final stateManager = createStateManager(columns: columns, rows: []);

        stateManager.updateVisibilityLayout();

        double startPosition = 0;

        expect(stateManager.columns[0].startPosition, startPosition);
        startPosition += widths[0];
        expect(stateManager.columns[1].startPosition, startPosition);
        startPosition += widths[1];
        expect(stateManager.columns[2].startPosition, startPosition);
        startPosition += widths[2];
        expect(stateManager.columns[3].startPosition, startPosition);
        startPosition += widths[3];
        expect(stateManager.columns[4].startPosition, startPosition);
      },
    );

    testWidgets('The grid width is sufficient. '
        '2 frozen columns on the left, 2 non-frozen columns, and 2 frozen columns on the right. '
        'The startPosition of the columns should be set.', (tester) async {
      const defaultWidth = TrinaGridSettings.columnWidth;

      final columns = [
        ...ColumnHelper.textColumn(
          'left',
          count: 2,
          frozen: TrinaColumnFrozen.start,
        ),
        ...ColumnHelper.textColumn(
          'body',
          count: 2,
          frozen: TrinaColumnFrozen.none,
        ),
        ...ColumnHelper.textColumn(
          'right',
          count: 2,
          frozen: TrinaColumnFrozen.end,
        ),
      ];

      final stateManager = createStateManager(columns: columns, rows: []);
      stateManager.setLayout(const BoxConstraints(maxWidth: 1300));
      expect(stateManager.showFrozenColumn, true);

      stateManager.updateVisibilityLayout();

      expect(stateManager.columns[0].startPosition, 0);
      expect(stateManager.columns[1].startPosition, defaultWidth * 1);

      expect(stateManager.columns[2].startPosition, 0);
      expect(stateManager.columns[3].startPosition, defaultWidth * 1);

      expect(stateManager.columns[4].startPosition, 0);
      expect(stateManager.columns[5].startPosition, defaultWidth * 1);
    });

    testWidgets('The grid width is insufficient. '
        '2 frozen columns on the left, 2 non-frozen columns, and 2 frozen columns on the right. '
        'The startPosition of the columns should be set.', (tester) async {
      const defaultWidth = TrinaGridSettings.columnWidth;

      final columns = [
        ...ColumnHelper.textColumn(
          'left',
          count: 2,
          frozen: TrinaColumnFrozen.start,
        ),
        ...ColumnHelper.textColumn(
          'body',
          count: 2,
          frozen: TrinaColumnFrozen.none,
        ),
        ...ColumnHelper.textColumn(
          'right',
          count: 2,
          frozen: TrinaColumnFrozen.end,
        ),
      ];

      final stateManager = createStateManager(columns: columns, rows: []);
      stateManager.setLayout(const BoxConstraints(maxWidth: 600));
      expect(stateManager.showFrozenColumn, false);

      stateManager.updateVisibilityLayout();

      expect(stateManager.columns[0].startPosition, 0);
      expect(stateManager.columns[1].startPosition, defaultWidth * 1);

      expect(stateManager.columns[2].startPosition, defaultWidth * 2);
      expect(stateManager.columns[3].startPosition, defaultWidth * 3);

      expect(stateManager.columns[4].startPosition, defaultWidth * 4);
      expect(stateManager.columns[5].startPosition, defaultWidth * 5);
    });

    testWidgets(
      'Hidden column 1, non-frozen columns 4. The startPosition of the columns should be set.',
      (widgetTester) async {
        const defaultWidth = TrinaGridSettings.columnWidth;

        final columns = ColumnHelper.textColumn(
          'column',
          count: 5,
          frozen: TrinaColumnFrozen.none,
        );

        columns[2].hide = true;

        final stateManager = createStateManager(columns: columns, rows: []);

        stateManager.updateVisibilityLayout();

        expect(stateManager.refColumns.originalList[0].startPosition, 0);
        expect(
          stateManager.refColumns.originalList[1].startPosition,
          defaultWidth * 1,
        );

        // Hidden column is set to 0 by default
        expect(stateManager.refColumns.originalList[2].startPosition, 0);

        expect(
          stateManager.refColumns.originalList[3].startPosition,
          defaultWidth * 2,
        );
        expect(
          stateManager.refColumns.originalList[4].startPosition,
          defaultWidth * 3,
        );
      },
    );

    testWidgets('applyViewportDimension should be called.', (
      widgetTester,
    ) async {
      final LinkedScrollControllerGroup horizontalScroll =
          MockLinkedScrollControllerGroup();

      final ScrollController rowsScroll = MockScrollController();

      final ScrollPosition scrollPosition = MockScrollPosition();

      when(rowsScroll.position).thenReturn(scrollPosition);

      when(rowsScroll.hasClients).thenReturn(true);

      when(rowsScroll.offset).thenReturn(0.0);

      when(scrollPosition.hasViewportDimension).thenReturn(true);

      when(scrollPosition.maxScrollExtent).thenReturn(0.0);

      final columns = ColumnHelper.textColumn(
        'column',
        count: 5,
        frozen: TrinaColumnFrozen.none,
      );

      final stateManager = createStateManager(
        columns: columns,
        rows: [],
        scroll: TrinaGridScrollController(horizontal: horizontalScroll),
        layout: const BoxConstraints(maxWidth: 800),
      );

      stateManager.scroll.setBodyRowsHorizontal(rowsScroll);

      // setLayout method is called once in applyViewportDimension.
      reset(horizontalScroll);

      stateManager.updateVisibilityLayout();

      final bodyWidth =
          stateManager.maxWidth! -
          stateManager.bodyLeftOffset -
          stateManager.bodyRightOffset;

      verify(horizontalScroll.applyViewportDimension(bodyWidth)).called(1);
    });

    testWidgets('If notify = true, notifyListeners should be called.', (
      widgetTester,
    ) async {
      final LinkedScrollControllerGroup horizontalScroll =
          MockLinkedScrollControllerGroup();

      final columns = ColumnHelper.textColumn(
        'column',
        count: 5,
        frozen: TrinaColumnFrozen.none,
      );

      final stateManager = createStateManager(
        columns: columns,
        rows: [],
        scroll: TrinaGridScrollController(horizontal: horizontalScroll),
        layout: const BoxConstraints(maxWidth: 800),
      );

      stateManager.updateVisibilityLayout(notify: true);

      verify(horizontalScroll.notifyListeners()).called(1);
    });

    testWidgets('If notify = false, notifyListeners should not be called.', (
      widgetTester,
    ) async {
      final LinkedScrollControllerGroup horizontalScroll =
          MockLinkedScrollControllerGroup();

      final columns = ColumnHelper.textColumn(
        'column',
        count: 5,
        frozen: TrinaColumnFrozen.none,
      );

      final stateManager = createStateManager(
        columns: columns,
        rows: [],
        scroll: TrinaGridScrollController(horizontal: horizontalScroll),
        layout: const BoxConstraints(maxWidth: 800),
      );

      stateManager.updateVisibilityLayout(notify: false);

      verifyNever(horizontalScroll.notifyListeners());
    });
  });
}
