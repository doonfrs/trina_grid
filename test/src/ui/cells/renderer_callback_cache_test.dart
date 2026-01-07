import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:trina_grid/trina_grid.dart';
import 'package:trina_grid/src/ui/ui.dart';
import 'package:rxdart/rxdart.dart';

import '../../../helper/row_helper.dart';
import '../../../mock/shared_mocks.mocks.dart';

void main() {
  late MockTrinaGridStateManager stateManager;
  late MockTrinaGridScrollController scroll;
  late MockLinkedScrollControllerGroup horizontalScroll;
  late MockScrollController horizontalScrollController;
  late MockScrollController verticalScrollController;
  MockTrinaGridEventManager? eventManager;
  PublishSubject<TrinaNotifierEvent> streamNotifier;

  setUp(() {
    stateManager = MockTrinaGridStateManager();
    scroll = MockTrinaGridScrollController();
    horizontalScroll = MockLinkedScrollControllerGroup();
    horizontalScrollController = MockScrollController();
    verticalScrollController = MockScrollController();
    eventManager = MockTrinaGridEventManager();
    streamNotifier = PublishSubject<TrinaNotifierEvent>();
    when(stateManager.isRTL).thenReturn(false);
    when(stateManager.textDirection).thenReturn(TextDirection.ltr);
    when(stateManager.eventManager).thenReturn(eventManager);
    when(stateManager.streamNotifier).thenAnswer((_) => streamNotifier);
    when(stateManager.configuration).thenReturn(const TrinaGridConfiguration());
    when(stateManager.keyPressed).thenReturn(TrinaGridKeyPressed());
    when(stateManager.rowTotalHeight).thenReturn(
      RowHelper.resolveRowTotalHeight(stateManager.configuration.style),
    );
    when(stateManager.localeText).thenReturn(const TrinaGridLocaleText());
    when(stateManager.keepFocus).thenReturn(true);
    when(stateManager.hasFocus).thenReturn(true);
    when(stateManager.canRowDrag).thenReturn(true);
    when(stateManager.rowHeight).thenReturn(0);
    when(stateManager.currentSelectingRows).thenReturn([]);
    when(stateManager.scroll).thenReturn(scroll);
    when(scroll.maxScrollHorizontal).thenReturn(0);
    when(scroll.horizontal).thenReturn(horizontalScroll);
    when(scroll.bodyRowsHorizontal).thenReturn(horizontalScrollController);
    when(scroll.bodyRowsVertical).thenReturn(verticalScrollController);
    when(horizontalScrollController.offset).thenReturn(0);
    when(verticalScrollController.offset).thenReturn(0);
    when(stateManager.enabledRowGroups).thenReturn(false);
    when(stateManager.rowGroupDelegate).thenReturn(null);
  });

  group('Renderer callback caching (Issue #252)', () {
    testWidgets(
      'renderer callback should be cached and not called excessively on rebuilds',
      (WidgetTester tester) async {
        int callCount = 0;

        Widget renderer(TrinaColumnRendererContext context) {
          callCount++;
          return Text('Rendered: ${context.cell.value}');
        }

        final TrinaColumn column = TrinaColumn(
          title: 'column title',
          field: 'column_field_name',
          type: TrinaColumnType.text(),
          renderer: renderer,
        );

        final TrinaCell cell = TrinaCell(value: 'test value');
        final TrinaRow row = TrinaRow(cells: {'column_field_name': cell});

        // Set up mock to return false for isCurrentCell and isSelectedCell
        when(stateManager.isCurrentCell(any)).thenReturn(false);
        when(stateManager.isSelectedCell(any, any, any)).thenReturn(false);

        await tester.pumpWidget(
          MaterialApp(
            home: Material(
              child: TrinaDefaultCell(
                cell: cell,
                column: column,
                row: row,
                rowIdx: 0,
                stateManager: stateManager,
              ),
            ),
          ),
        );

        // Initial render should call the renderer once
        expect(callCount, 1);
        expect(find.text('Rendered: test value'), findsOneWidget);

        // Rebuild without changing cell value or selection state
        await tester.pumpWidget(
          MaterialApp(
            home: Material(
              child: TrinaDefaultCell(
                cell: cell,
                column: column,
                row: row,
                rowIdx: 0,
                stateManager: stateManager,
              ),
            ),
          ),
        );

        // Should not call renderer again (cached)
        expect(callCount, 1, reason: 'Renderer should be cached on rebuild');
      },
    );

    testWidgets('renderer cache should invalidate when cell value changes', (
      WidgetTester tester,
    ) async {
      int callCount = 0;

      Widget renderer(TrinaColumnRendererContext context) {
        callCount++;
        return Text('Rendered: ${context.cell.value}');
      }

      final TrinaColumn column = TrinaColumn(
        title: 'column title',
        field: 'column_field_name',
        type: TrinaColumnType.text(),
        renderer: renderer,
      );

      final TrinaCell cell = TrinaCell(value: 'initial value');
      final TrinaRow row = TrinaRow(cells: {'column_field_name': cell});

      when(stateManager.isCurrentCell(any)).thenReturn(false);
      when(stateManager.isSelectedCell(any, any, any)).thenReturn(false);

      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: TrinaDefaultCell(
              cell: cell,
              column: column,
              row: row,
              rowIdx: 0,
              stateManager: stateManager,
            ),
          ),
        ),
      );

      expect(callCount, 1);
      expect(find.text('Rendered: initial value'), findsOneWidget);

      // Change cell value
      cell.value = 'changed value';

      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: TrinaDefaultCell(
              cell: cell,
              column: column,
              row: row,
              rowIdx: 0,
              stateManager: stateManager,
            ),
          ),
        ),
      );

      // Should call renderer again because value changed
      expect(
        callCount,
        2,
        reason: 'Renderer should be called again when cell value changes',
      );
      expect(find.text('Rendered: changed value'), findsOneWidget);
    });

    testWidgets(
      'renderer cache should invalidate when isCurrentCell state changes',
      (WidgetTester tester) async {
        int callCount = 0;

        Widget renderer(TrinaColumnRendererContext context) {
          callCount++;
          final isCurrentCell = context.stateManager.isCurrentCell(
            context.cell,
          );
          return Text(
            'Rendered: ${context.cell.value}, Current: $isCurrentCell',
          );
        }

        final TrinaColumn column = TrinaColumn(
          title: 'column title',
          field: 'column_field_name',
          type: TrinaColumnType.text(),
          renderer: renderer,
        );

        final TrinaCell cell = TrinaCell(value: 'test value');
        final TrinaRow row = TrinaRow(cells: {'column_field_name': cell});

        // Initially not current cell
        when(stateManager.isCurrentCell(any)).thenReturn(false);
        when(stateManager.isSelectedCell(any, any, any)).thenReturn(false);

        await tester.pumpWidget(
          MaterialApp(
            home: Material(
              child: TrinaDefaultCell(
                cell: cell,
                column: column,
                row: row,
                rowIdx: 0,
                stateManager: stateManager,
              ),
            ),
          ),
        );

        expect(callCount, 1);
        expect(
          find.text('Rendered: test value, Current: false'),
          findsOneWidget,
        );

        // Change to current cell
        when(stateManager.isCurrentCell(any)).thenReturn(true);

        await tester.pumpWidget(
          MaterialApp(
            home: Material(
              child: TrinaDefaultCell(
                cell: cell,
                column: column,
                row: row,
                rowIdx: 0,
                stateManager: stateManager,
              ),
            ),
          ),
        );

        // Should call renderer again because isCurrentCell state changed
        expect(
          callCount,
          2,
          reason: 'Renderer should be called again when isCurrentCell changes',
        );
        expect(
          find.text('Rendered: test value, Current: true'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'renderer cache should invalidate when isSelectedCell state changes',
      (WidgetTester tester) async {
        int callCount = 0;

        Widget renderer(TrinaColumnRendererContext context) {
          callCount++;
          final isSelected = context.stateManager.isSelectedCell(
            context.cell,
            context.column,
            context.rowIdx,
          );
          return Text('Rendered: ${context.cell.value}, Selected: $isSelected');
        }

        final TrinaColumn column = TrinaColumn(
          title: 'column title',
          field: 'column_field_name',
          type: TrinaColumnType.text(),
          renderer: renderer,
        );

        final TrinaCell cell = TrinaCell(value: 'test value');
        final TrinaRow row = TrinaRow(cells: {'column_field_name': cell});

        // Initially not selected
        when(stateManager.isCurrentCell(any)).thenReturn(false);
        when(stateManager.isSelectedCell(any, any, any)).thenReturn(false);

        await tester.pumpWidget(
          MaterialApp(
            home: Material(
              child: TrinaDefaultCell(
                cell: cell,
                column: column,
                row: row,
                rowIdx: 0,
                stateManager: stateManager,
              ),
            ),
          ),
        );

        expect(callCount, 1);
        expect(
          find.text('Rendered: test value, Selected: false'),
          findsOneWidget,
        );

        // Change to selected
        when(stateManager.isSelectedCell(any, any, any)).thenReturn(true);

        await tester.pumpWidget(
          MaterialApp(
            home: Material(
              child: TrinaDefaultCell(
                cell: cell,
                column: column,
                row: row,
                rowIdx: 0,
                stateManager: stateManager,
              ),
            ),
          ),
        );

        // Should call renderer again because isSelectedCell state changed
        expect(
          callCount,
          2,
          reason: 'Renderer should be called again when isSelectedCell changes',
        );
        expect(
          find.text('Rendered: test value, Selected: true'),
          findsOneWidget,
        );
      },
    );
  });

  group('Cross-cell dependency cache invalidation (Issue #268)', () {
    testWidgets(
      'renderer cache should invalidate when another cell in the same row changes',
      (WidgetTester tester) async {
        int callCount = 0;

        // Renderer that reads ANOTHER cell's value from the same row
        Widget renderer(TrinaColumnRendererContext context) {
          callCount++;
          final status = context.row.cells['status']?.value ?? 'unknown';
          return Text('Name: ${context.cell.value}, Status: $status');
        }

        final TrinaColumn nameColumn = TrinaColumn(
          title: 'Name',
          field: 'name',
          type: TrinaColumnType.text(),
          renderer: renderer,
        );

        // Create two cells in the same row
        final TrinaCell statusCell = TrinaCell(value: 'active');
        final TrinaCell nameCell = TrinaCell(value: 'John');
        final TrinaRow row = TrinaRow(
          cells: {'status': statusCell, 'name': nameCell},
        );

        when(stateManager.isCurrentCell(any)).thenReturn(false);
        when(stateManager.isSelectedCell(any, any, any)).thenReturn(false);

        await tester.pumpWidget(
          MaterialApp(
            home: Material(
              child: TrinaDefaultCell(
                cell: nameCell,
                column: nameColumn,
                row: row,
                rowIdx: 0,
                stateManager: stateManager,
              ),
            ),
          ),
        );

        // Initial render
        expect(callCount, 1);
        expect(find.text('Name: John, Status: active'), findsOneWidget);

        // Change the OTHER cell (status) - this simulates what changeCellValue does
        statusCell.value = 'inactive';
        row.incrementVersion();

        await tester.pumpWidget(
          MaterialApp(
            home: Material(
              child: TrinaDefaultCell(
                cell: nameCell,
                column: nameColumn,
                row: row,
                rowIdx: 0,
                stateManager: stateManager,
              ),
            ),
          ),
        );

        // Renderer should be called again because row version changed
        expect(
          callCount,
          2,
          reason:
              'Renderer should be called again when another cell in the row changes',
        );
        expect(find.text('Name: John, Status: inactive'), findsOneWidget);
      },
    );

    testWidgets(
      'renderer cache should NOT invalidate when cell in different row changes',
      (WidgetTester tester) async {
        int callCount = 0;

        Widget renderer(TrinaColumnRendererContext context) {
          callCount++;
          return Text('Value: ${context.cell.value}');
        }

        final TrinaColumn column = TrinaColumn(
          title: 'Name',
          field: 'name',
          type: TrinaColumnType.text(),
          renderer: renderer,
        );

        // Create two separate rows
        final TrinaCell cell1 = TrinaCell(value: 'Row 1');
        final TrinaRow row1 = TrinaRow(cells: {'name': cell1});

        final TrinaCell cell2 = TrinaCell(value: 'Row 2');
        final TrinaRow row2 = TrinaRow(cells: {'name': cell2});

        when(stateManager.isCurrentCell(any)).thenReturn(false);
        when(stateManager.isSelectedCell(any, any, any)).thenReturn(false);

        await tester.pumpWidget(
          MaterialApp(
            home: Material(
              child: TrinaDefaultCell(
                cell: cell1,
                column: column,
                row: row1,
                rowIdx: 0,
                stateManager: stateManager,
              ),
            ),
          ),
        );

        expect(callCount, 1);

        // Change cell in DIFFERENT row
        cell2.value = 'Row 2 Changed';
        row2.incrementVersion();

        await tester.pumpWidget(
          MaterialApp(
            home: Material(
              child: TrinaDefaultCell(
                cell: cell1,
                column: column,
                row: row1, // Still row1
                rowIdx: 0,
                stateManager: stateManager,
              ),
            ),
          ),
        );

        // Renderer should NOT be called again (different row)
        expect(
          callCount,
          1,
          reason: 'Renderer should not be called when a different row changes',
        );
      },
    );
  });
}
