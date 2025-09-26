import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:trina_grid/trina_grid.dart';
import 'package:trina_grid/src/ui/ui.dart';
import 'package:rxdart/rxdart.dart';

import '../../../helper/trina_widget_test_helper.dart';
import '../../../helper/row_helper.dart';
import '../../../helper/test_helper_util.dart';
import '../../../matcher/trina_object_matcher.dart';
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
    when(stateManager.isCurrentCell(any)).thenReturn(false);
    when(stateManager.enabledRowGroups).thenReturn(false);
    when(stateManager.rowGroupDelegate).thenReturn(null);
  });

  group('Default Cell Test', () {
    final TrinaColumn column = TrinaColumn(
      title: 'column title',
      field: 'column_field_name',
      type: TrinaColumnType.text(),
    );

    final TrinaCell cell = TrinaCell(value: 'default cell value');

    final TrinaRow row = TrinaRow(cells: {'column_field_name': cell});

    final cellWidget = TrinaWidgetTestHelper('cell widget', (tester) async {
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
    });

    cellWidget.test('Text widget should be rendered', (tester) async {
      expect(find.byType(Text), findsOneWidget);
      expect(find.text('default cell value'), findsOneWidget);
    });

    cellWidget.test(
      'enableRowDrag is false by default, so Draggable widget should not be rendered',
      (tester) async {
        expect(find.byType(Draggable), findsNothing);
      },
    );

    cellWidget.test(
      'enableRowChecked is false by default, so Checkbox widget should not be rendered',
      (tester) async {
        expect(find.byType(Checkbox), findsNothing);
      },
    );
  });

  group('renderer', () {
    buildCellWidgetWithRenderer(
      Widget Function(TrinaColumnRendererContext) renderer,
    ) {
      final TrinaColumn column = TrinaColumn(
        title: 'column title',
        field: 'column_field_name',
        type: TrinaColumnType.text(),
        renderer: renderer,
      );

      final TrinaCell cell = TrinaCell(value: 'default cell value');

      final TrinaRow row = TrinaRow(cells: {'column_field_name': cell});

      return TrinaWidgetTestHelper('cell widget', (tester) async {
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
      });
    }

    final renderText = buildCellWidgetWithRenderer((
      TrinaColumnRendererContext rendererContext,
    ) {
      return const Text('renderer value');
    });

    renderText.test('Widget returned by renderer should be displayed', (
      tester,
    ) async {
      expect(find.text('renderer value'), findsOneWidget);
    });

    final renderTextWithCellValue = buildCellWidgetWithRenderer((
      TrinaColumnRendererContext rendererContext,
    ) {
      return Text(rendererContext.cell.value.toString());
    });

    renderTextWithCellValue.test(
      'Widget returned by renderer should be displayed with cell value',
      (tester) async {
        expect(find.text('default cell value'), findsOneWidget);
      },
    );
  });

  group('enableRowDrag', () {
    final TrinaColumn column = TrinaColumn(
      title: 'column title',
      field: 'column_field_name',
      type: TrinaColumnType.text(),
      enableRowDrag: true,
    );

    final TrinaCell cell = TrinaCell(value: 'default cell value');

    final TrinaRow row = TrinaRow(cells: {'column_field_name': cell});

    cellWidget({bool? canRowDrag}) {
      return TrinaWidgetTestHelper('cell widget', (tester) async {
        when(stateManager.canRowDrag).thenReturn(canRowDrag!);

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
      });
    }

    cellWidget(canRowDrag: true).test(
      'When canRowDrag is true, Draggable widget should be rendered',
      (tester) async {
        expect(
          find.byType(TestHelperUtil.typeOf<Draggable<TrinaRow>>()),
          findsOneWidget,
        );
      },
    );

    cellWidget(canRowDrag: false).test(
      'When canRowDrag is false, Draggable widget should not be rendered',
      (tester) async {
        expect(
          find.byType(TestHelperUtil.typeOf<Draggable<TrinaRow>>()),
          findsNothing,
        );
      },
    );

    cellWidget(canRowDrag: true).test(
      'Dragging the Draggable icon should trigger TrinaGridScrollUpdateEvent',
      (tester) async {
        const offset = Offset(0.0, 100);

        when(stateManager.getRowByIdx(any)).thenReturn(row);
        when(stateManager.isSelectedRow(any)).thenReturn(false);
        when(stateManager.isSelecting).thenReturn(false);

        await tester.drag(find.byType(Icon), offset);

        verify(stateManager.setIsDraggingRow(true, notify: false)).called(1);

        verify(stateManager.setDragRows([row])).called(1);

        verify(
          eventManager!.addEvent(
            argThat(
              TrinaObjectMatcher<TrinaGridScrollUpdateEvent>(
                rule: (object) {
                  return true;
                },
              ),
            ),
          ),
        ).called(greaterThan(1));

        verify(stateManager.getRowIdxByOffset(any)).called(greaterThan(1));

        verify(stateManager.setDragTargetRowIdx(any)).called(greaterThan(1));
      },
    );
  });

  group('enableRowChecked', () {
    TrinaRow? row;

    buildCellWidget(bool checked) {
      return TrinaWidgetTestHelper('cell widget', (tester) async {
        final TrinaColumn column = TrinaColumn(
          title: 'column title',
          field: 'column_field_name',
          type: TrinaColumnType.text(),
          enableRowChecked: true,
        );

        final TrinaCell cell = TrinaCell(value: 'default cell value');

        row = TrinaRow(cells: {}, checked: checked);

        when(stateManager.getRowByIdx(any)).thenReturn(row);

        await tester.pumpWidget(
          MaterialApp(
            home: Material(
              child: TrinaDefaultCell(
                cell: cell,
                column: column,
                row: row!,
                rowIdx: 0,
                stateManager: stateManager,
              ),
            ),
          ),
        );
      });
    }

    final checkedCellWidget = buildCellWidget(true);

    checkedCellWidget.test('Checkbox widget should be rendered', (
      tester,
    ) async {
      expect(find.byType(Checkbox), findsOneWidget);
    });

    checkedCellWidget.test('Tapping the Checkbox should toggle its value', (
      tester,
    ) async {
      await tester.tap(find.byType(Checkbox));

      expect(row!.checked, isTrue);

      verify(stateManager.setRowChecked(row, false)).called(1);
    });

    final uncheckedCellWidget = buildCellWidget(false);

    uncheckedCellWidget.test('Tapping the Checkbox should toggle its value', (
      tester,
    ) async {
      await tester.tap(find.byType(Checkbox));

      expect(row!.checked, isFalse);

      verify(stateManager.setRowChecked(row, true)).called(1);
    });
  });
}
