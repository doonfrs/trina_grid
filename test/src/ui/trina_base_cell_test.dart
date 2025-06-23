import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:trina_grid/trina_grid.dart';
import 'package:trina_grid/src/ui/ui.dart';
import 'package:rxdart/rxdart.dart';

import '../../helper/row_helper.dart';
import '../../helper/trina_widget_test_helper.dart';
import '../../matcher/trina_object_matcher.dart';
import '../../mock/shared_mocks.mocks.dart';

void main() {
  late MockTrinaGridStateManager stateManager;
  late MockTrinaCellMergeManager mockCellMergeManager;
  MockTrinaGridEventManager? eventManager;
  PublishSubject<TrinaNotifierEvent> streamNotifier;
  final resizingNotifier = ChangeNotifier();

  setUp(() {
    const configuration = TrinaGridConfiguration();
    stateManager = MockTrinaGridStateManager();
    mockCellMergeManager = MockTrinaCellMergeManager();
    eventManager = MockTrinaGridEventManager();
    streamNotifier = PublishSubject<TrinaNotifierEvent>();
    when(stateManager.streamNotifier).thenAnswer((_) => streamNotifier);
    when(stateManager.eventManager).thenReturn(eventManager);
    when(stateManager.resizingChangeNotifier).thenReturn(resizingNotifier);
    when(stateManager.configuration).thenReturn(configuration);
    when(stateManager.style).thenReturn(configuration.style);
    when(stateManager.keyPressed).thenReturn(TrinaGridKeyPressed());
    when(stateManager.rowHeight).thenReturn(
      stateManager.configuration.style.rowHeight,
    );
    when(stateManager.columnHeight).thenReturn(
      stateManager.configuration.style.columnHeight,
    );
    when(stateManager.columnFilterHeight).thenReturn(
      stateManager.configuration.style.columnHeight,
    );
    when(stateManager.rowTotalHeight).thenReturn(
        RowHelper.resolveRowTotalHeight(stateManager.configuration.style));
    when(stateManager.localeText).thenReturn(const TrinaGridLocaleText());
    when(stateManager.gridFocusNode).thenReturn(FocusNode());
    when(stateManager.keepFocus).thenReturn(true);
    when(stateManager.hasFocus).thenReturn(true);
    when(stateManager.selectingMode)
        .thenReturn(TrinaGridSelectingMode.cellWithSingleTap);
    when(stateManager.canRowDrag).thenReturn(true);
    when(stateManager.isSelectedCell(any, any, any)).thenReturn(false);
    when(stateManager.enabledRowGroups).thenReturn(false);
    when(stateManager.rowGroupDelegate).thenReturn(null);

    // Add stubs for cell merge manager
    when(stateManager.refColumns).thenReturn(FilteredList(initialList: []));
    when(stateManager.refRows).thenReturn(FilteredList(initialList: []));
    when(stateManager.cellMergeManager).thenReturn(mockCellMergeManager);
    when(mockCellMergeManager.shouldRenderCell(any)).thenReturn(true);
  });

  Widget buildApp({
    required TrinaCell cell,
    required TrinaColumn column,
    required TrinaRow row,
    required int rowIdx,
  }) {
    return MaterialApp(
      home: Material(
        child: TrinaBaseCell(
          cell: cell,
          column: column,
          rowIdx: rowIdx,
          row: row,
          stateManager: stateManager,
        ),
      ),
    );
  }

  testWidgets(
      'WHEN If it is not CurrentCell or not in Editing state'
      'THEN Text widget should be rendered', (WidgetTester tester) async {
    // given
    final TrinaCell cell = TrinaCell(value: 'cell value');

    final TrinaColumn column = TrinaColumn(
      title: 'header',
      field: 'header',
      type: TrinaColumnType.text(),
    );

    final TrinaRow row = TrinaRow(
      cells: {
        'header': cell,
      },
    );

    const rowIdx = 0;

    // when
    when(stateManager.isCurrentCell(any)).thenReturn(false);
    when(stateManager.isSelectedCell(any, any, any)).thenReturn(false);
    when(stateManager.isEditing).thenReturn(false);

    await tester.pumpWidget(
      buildApp(
        cell: cell,
        column: column,
        rowIdx: rowIdx,
        row: row,
      ),
    );

    // then
    expect(find.text('cell value'), findsOneWidget);
    expect(find.byType(TrinaSelectCell), findsNothing);
    expect(find.byType(TrinaNumberCell), findsNothing);
    expect(find.byType(TrinaDateCell), findsNothing);
    expect(find.byType(TrinaTimeCell), findsNothing);
    expect(find.byType(TrinaTextCell), findsNothing);
  });

  testWidgets(
      'WHEN If it is CurrentCell and not in Editing state'
      'THEN Text widget should be rendered', (WidgetTester tester) async {
    // given
    final TrinaCell cell = TrinaCell(value: 'cell value');

    final TrinaColumn column = TrinaColumn(
      title: 'header',
      field: 'header',
      type: TrinaColumnType.text(),
    );

    final TrinaRow row = TrinaRow(
      cells: {
        'header': cell,
      },
    );

    const rowIdx = 0;

    // when
    when(stateManager.isCurrentCell(any)).thenReturn(true);
    when(stateManager.isEditing).thenReturn(false);

    await tester.pumpWidget(
      buildApp(
        cell: cell,
        column: column,
        rowIdx: rowIdx,
        row: row,
      ),
    );

    // then
    expect(find.text('cell value'), findsOneWidget);
    expect(find.byType(TrinaSelectCell), findsNothing);
    expect(find.byType(TrinaNumberCell), findsNothing);
    expect(find.byType(TrinaDateCell), findsNothing);
    expect(find.byType(TrinaTimeCell), findsNothing);
    expect(find.byType(TrinaTextCell), findsNothing);
  });

  testWidgets(
      'WHEN If it is CurrentCell and in Editing state'
      'THEN [TextCellWidget] should be rendered', (WidgetTester tester) async {
    // given
    final TrinaCell cell = TrinaCell(value: 'cell value');

    final TrinaColumn column = TrinaColumn(
      title: 'header',
      field: 'header',
      type: TrinaColumnType.text(),
    );

    final TrinaRow row = TrinaRow(
      cells: {
        'header': cell,
      },
    );

    const rowIdx = 0;

    // when
    when(stateManager.isCurrentCell(any)).thenReturn(true);
    when(stateManager.isEditing).thenReturn(true);

    await tester.pumpWidget(
      buildApp(
        cell: cell,
        column: column,
        rowIdx: rowIdx,
        row: row,
      ),
    );

    // then
    expect(find.text('cell value'), findsOneWidget);
    expect(find.byType(TrinaSelectCell), findsNothing);
    expect(find.byType(TrinaNumberCell), findsNothing);
    expect(find.byType(TrinaDateCell), findsNothing);
    expect(find.byType(TrinaTimeCell), findsNothing);
    expect(find.byType(TrinaTextCell), findsOneWidget);
  });

  testWidgets(
      'WHEN If it is CurrentCell and in Editing state'
      'THEN [TimeCellWidget] should be rendered', (WidgetTester tester) async {
    // given
    final TrinaCell cell = TrinaCell(value: '00:00');

    final TrinaColumn column = TrinaColumn(
      title: 'header',
      field: 'header',
      type: TrinaColumnType.time(),
    );

    final TrinaRow row = TrinaRow(
      cells: {
        'header': cell,
      },
    );

    const rowIdx = 0;

    // when
    when(stateManager.isCurrentCell(any)).thenReturn(true);
    when(stateManager.isEditing).thenReturn(true);

    await tester.pumpWidget(
      buildApp(
        cell: cell,
        column: column,
        rowIdx: rowIdx,
        row: row,
      ),
    );

    // then
    expect(find.text('00:00'), findsOneWidget);
    expect(find.byType(TrinaSelectCell), findsNothing);
    expect(find.byType(TrinaNumberCell), findsNothing);
    expect(find.byType(TrinaDateCell), findsNothing);
    expect(find.byType(TrinaTimeCell), findsOneWidget);
    expect(find.byType(TrinaTextCell), findsNothing);
  });

  testWidgets(
      'WHEN If it is CurrentCell and in Editing state'
      'THEN [DateCellWidget] should be rendered', (WidgetTester tester) async {
    // given
    final TrinaCell cell = TrinaCell(value: '2020-01-01');

    final TrinaColumn column = TrinaColumn(
      title: 'header',
      field: 'header',
      type: TrinaColumnType.date(),
    );

    final TrinaRow row = TrinaRow(
      cells: {
        'header': cell,
      },
    );

    const rowIdx = 0;

    // when
    when(stateManager.isCurrentCell(any)).thenReturn(true);
    when(stateManager.isEditing).thenReturn(true);

    await tester.pumpWidget(
      buildApp(
        cell: cell,
        column: column,
        rowIdx: rowIdx,
        row: row,
      ),
    );

    // then
    expect(find.text('2020-01-01'), findsOneWidget);
    expect(find.byType(TrinaSelectCell), findsNothing);
    expect(find.byType(TrinaNumberCell), findsNothing);
    expect(find.byType(TrinaDateCell), findsOneWidget);
    expect(find.byType(TrinaTimeCell), findsNothing);
    expect(find.byType(TrinaTextCell), findsNothing);
  });

  testWidgets(
      'WHEN If it is CurrentCell and in Editing state'
      'THEN [NumberCellWidget] should be rendered',
      (WidgetTester tester) async {
    // given
    final TrinaCell cell = TrinaCell(value: 1234);

    final TrinaColumn column = TrinaColumn(
      title: 'header',
      field: 'header',
      type: TrinaColumnType.number(),
    );

    final TrinaRow row = TrinaRow(
      cells: {
        'header': cell,
      },
    );

    const rowIdx = 0;

    // when
    when(stateManager.isCurrentCell(any)).thenReturn(true);
    when(stateManager.isEditing).thenReturn(true);

    await tester.pumpWidget(
      buildApp(
        cell: cell,
        column: column,
        rowIdx: rowIdx,
        row: row,
      ),
    );

    // then
    expect(find.text('1234'), findsOneWidget);
    expect(find.byType(TrinaSelectCell), findsNothing);
    expect(find.byType(TrinaNumberCell), findsOneWidget);
    expect(find.byType(TrinaDateCell), findsNothing);
    expect(find.byType(TrinaTimeCell), findsNothing);
    expect(find.byType(TrinaTextCell), findsNothing);
  });

  testWidgets(
      'WHEN If it is CurrentCell and in Editing state'
      'THEN [SelectCellWidget] should be rendered',
      (WidgetTester tester) async {
    // given
    final TrinaCell cell = TrinaCell(value: 'one');

    final TrinaColumn column = TrinaColumn(
      title: 'header',
      field: 'header',
      type: TrinaColumnType.select(<String>['one', 'two', 'three']),
    );

    final TrinaRow row = TrinaRow(
      cells: {
        'header': cell,
      },
    );

    const rowIdx = 0;

    // when
    when(stateManager.isCurrentCell(any)).thenReturn(true);
    when(stateManager.isEditing).thenReturn(true);

    await tester.pumpWidget(
      buildApp(
        cell: cell,
        column: column,
        rowIdx: rowIdx,
        row: row,
      ),
    );

    // then
    expect(find.text('one'), findsOneWidget);
    expect(find.byType(TrinaSelectCell), findsOneWidget);
    expect(find.byType(TrinaNumberCell), findsNothing);
    expect(find.byType(TrinaDateCell), findsNothing);
    expect(find.byType(TrinaTimeCell), findsNothing);
    expect(find.byType(TrinaTextCell), findsNothing);
  });

  testWidgets(
    'Tapping a cell should trigger TrinaCellGestureEvent with OnTapUp',
    (WidgetTester tester) async {
      // given
      final TrinaCell cell = TrinaCell(value: 'one');

      final TrinaColumn column = TrinaColumn(
        title: 'header',
        field: 'header',
        type: TrinaColumnType.text(),
      );

      final TrinaRow row = TrinaRow(
        cells: {
          'header': cell,
        },
      );

      const rowIdx = 0;

      // when
      when(stateManager.isCurrentCell(any)).thenReturn(false);
      when(stateManager.isEditing).thenReturn(false);
      when(stateManager.isSelectedCell(any, any, any)).thenReturn(false);

      await tester.pumpWidget(
        buildApp(
          cell: cell,
          column: column,
          rowIdx: rowIdx,
          row: row,
        ),
      );

      Finder gesture = find.byType(GestureDetector);

      await tester.tap(gesture);

      verify(eventManager!.addEvent(
        argThat(TrinaObjectMatcher<TrinaGridCellGestureEvent>(rule: (object) {
          return object.gestureType.isOnTapUp &&
              object.cell.key == cell.key &&
              object.column.key == column.key &&
              object.rowIdx == rowIdx;
        })),
      )).called(1);
    },
  );

  testWidgets(
    'Long pressing a cell should trigger TrinaCellGestureEvent with OnLongPressStart',
    (WidgetTester tester) async {
      // given
      final TrinaCell cell = TrinaCell(value: 'one');

      final TrinaColumn column = TrinaColumn(
        title: 'header',
        field: 'header',
        type: TrinaColumnType.text(),
      );

      final TrinaRow row = TrinaRow(
        cells: {
          'header': cell,
        },
      );

      const rowIdx = 0;

      // when
      when(stateManager.isCurrentCell(any)).thenReturn(false);
      when(stateManager.isEditing).thenReturn(false);
      when(stateManager.isSelectedCell(any, any, any)).thenReturn(false);

      await tester.pumpWidget(
        buildApp(
          cell: cell,
          column: column,
          rowIdx: rowIdx,
          row: row,
        ),
      );

      Finder gesture = find.byType(GestureDetector);

      await tester.longPress(gesture);

      verify(eventManager!.addEvent(
        argThat(TrinaObjectMatcher<TrinaGridCellGestureEvent>(rule: (object) {
          return object.gestureType.isOnLongPressStart &&
              object.cell.key == cell.key &&
              object.column.key == column.key &&
              object.rowIdx == rowIdx;
        })),
      )).called(1);
    },
  );

  testWidgets(
    'Moving after long pressing a cell should trigger TrinaCellGestureEvent with OnLongPressMoveUpdate',
    (WidgetTester tester) async {
      // given
      final TrinaCell cell = TrinaCell(value: 'one');

      final TrinaColumn column = TrinaColumn(
        title: 'header',
        field: 'header',
        type: TrinaColumnType.text(),
      );

      final TrinaRow row = TrinaRow(
        cells: {
          'header': cell,
        },
      );

      const rowIdx = 0;

      when(stateManager.isCurrentCell(any)).thenReturn(true);
      when(stateManager.isEditing).thenReturn(false);
      when(stateManager.selectingMode)
          .thenReturn(TrinaGridSelectingMode.rowWithSingleTap);

      when(stateManager.isSelectingInteraction()).thenReturn(false);
      when(stateManager.needMovingScroll(any, any)).thenReturn(false);

      // when
      await tester.pumpWidget(
        buildApp(
          cell: cell,
          column: column,
          rowIdx: rowIdx,
          row: row,
        ),
      );

      // then
      final TestGesture gesture =
          await tester.startGesture(const Offset(100, 18));

      await tester.pump(const Duration(milliseconds: 500));

      await gesture.moveBy(const Offset(50, 0));

      await gesture.up();

      await tester.pump();

      await tester.pumpAndSettle(const Duration(milliseconds: 800));

      verify(eventManager!.addEvent(
        argThat(TrinaObjectMatcher<TrinaGridCellGestureEvent>(rule: (object) {
          return object.gestureType.isOnLongPressMoveUpdate &&
              object.cell.key == cell.key &&
              object.column.key == column.key &&
              object.rowIdx == rowIdx;
        })),
      )).called(1);
    },
  );

  group('DefaultCellWidget rendering conditions', () {
    TrinaCell cell;

    TrinaColumn? column;

    int rowIdx;

    aCell({
      bool isCurrentCell = true,
      bool isEditing = false,
      bool readOnly = false,
      bool enableEditingMode = true,
    }) {
      return TrinaWidgetTestHelper('a cell.', (tester) async {
        when(stateManager.isCurrentCell(any)).thenReturn(isCurrentCell);
        when(stateManager.isEditing).thenReturn(isEditing);
        when(stateManager.isSelectedCell(any, any, any)).thenReturn(false);
        when(stateManager.hasFocus).thenReturn(true);

        cell = TrinaCell(value: 'one');

        column = TrinaColumn(
          title: 'header',
          field: 'header',
          readOnly: readOnly,
          type: TrinaColumnType.text(),
          enableEditingMode: enableEditingMode,
        );

        final TrinaRow row = TrinaRow(
          cells: {
            'header': cell,
          },
        );

        rowIdx = 0;

        await tester.pumpWidget(
          buildApp(
            cell: cell,
            column: column!,
            rowIdx: rowIdx,
            row: row,
          ),
        );

        await tester.pumpAndSettle(const Duration(seconds: 1));
      });
    }

    aCell(isCurrentCell: false).test(
      'If not currentCell, DefaultCellWidget should be rendered',
      (tester) async {
        expect(find.byType(TrinaDefaultCell), findsOneWidget);
      },
    );

    aCell(isEditing: false).test(
      'If isEditing is false, DefaultCellWidget should be rendered',
      (tester) async {
        expect(find.byType(TrinaDefaultCell), findsOneWidget);
      },
    );

    aCell(enableEditingMode: false).test(
      'If enableEditingMode is false, DefaultCellWidget should be rendered',
      (tester) async {
        expect(find.byType(TrinaDefaultCell), findsOneWidget);
      },
    );

    aCell(isCurrentCell: true, isEditing: true, enableEditingMode: true).test(
      'If isCurrentCell, isEditing, and enableEditingMode are true, '
      'DefaultCellWidget should not be rendered',
      (tester) async {
        expect(find.byType(TrinaDefaultCell), findsNothing);
      },
    );
  });

  group('configuration', () {
    TrinaCell cell;

    TrinaColumn? column;

    int rowIdx;

    aCellWithConfiguration(
      TrinaGridConfiguration configuration, {
      bool isCurrentCell = true,
      bool isSelectedCell = false,
      bool readOnly = false,
    }) {
      return TrinaWidgetTestHelper('a cell.', (tester) async {
        when(stateManager.isCurrentCell(any)).thenReturn(isCurrentCell);
        when(stateManager.isSelectedCell(any, any, any))
            .thenReturn(isSelectedCell);
        when(stateManager.style).thenReturn(configuration.style);
        when(stateManager.hasFocus).thenReturn(true);
        when(stateManager.isEditing).thenReturn(true);

        cell = TrinaCell(value: 'one');

        column = TrinaColumn(
          title: 'header',
          field: 'header',
          readOnly: readOnly,
          type: TrinaColumnType.text(),
        );

        final TrinaRow row = TrinaRow(
          cells: {
            'header': cell,
          },
        );

        rowIdx = 0;

        when(stateManager.configuration).thenReturn(configuration);

        await tester.pumpWidget(
          buildApp(
            cell: cell,
            column: column!,
            rowIdx: rowIdx,
            row: row,
          ),
        );

        await tester.pumpAndSettle(const Duration(seconds: 1));
      });
    }

    aCellInsideTrinaBaseRow(
      TrinaGridConfiguration configuration, {
      bool isCurrentCell = true,
      bool isSelectedCell = false,
      bool readOnly = false,
    }) {
      return TrinaWidgetTestHelper('a cell inside TrinaBaseRow.',
          (tester) async {
        when(stateManager.isCurrentCell(any)).thenReturn(isCurrentCell);
        when(stateManager.isSelectedCell(any, any, any))
            .thenReturn(isSelectedCell);
        when(stateManager.style).thenReturn(configuration.style);
        when(stateManager.hasFocus).thenReturn(true);
        when(stateManager.isEditing).thenReturn(true);

        cell = TrinaCell(value: 'one');

        column = TrinaColumn(
          title: 'header',
          field: 'header',
          readOnly: readOnly,
          type: TrinaColumnType.text(),
        );

        final TrinaRow row = TrinaRow(
          cells: {
            'header': cell,
          },
        );

        rowIdx = 0;

        when(stateManager.configuration).thenReturn(configuration);

        await tester.pumpWidget(
          MaterialApp(
            home: Material(
              child: TrinaBaseRow(
                rowIdx: rowIdx,
                row: row,
                columns: [column!],
                stateManager: stateManager,
              ),
            ),
          ),
        );

        await tester.pumpAndSettle(const Duration(seconds: 1));
      });
    }

    aCellWithConfiguration(
      const TrinaGridConfiguration(
        style: TrinaGridStyleConfig(
          enableCellBorderVertical: false,
          borderColor: Colors.deepOrange,
        ),
      ),
      readOnly: true,
    ).test(
      'If readOnly is true, should be set the color to cellColorInReadOnlyState.',
      (tester) async {
        expect(column!.readOnly, true);

        final target = find.descendant(
          of: find.byType(GestureDetector),
          matching: find.byType(DecoratedBox),
        );

        final container = target.evaluate().first.widget as DecoratedBox;

        final BoxDecoration decoration = container.decoration as BoxDecoration;

        final Color? color = decoration.color;

        expect(
          color,
          stateManager.configuration.style.cellColorInReadOnlyState,
        );
      },
    );

    aCellWithConfiguration(
      const TrinaGridConfiguration(
        style: TrinaGridStyleConfig(
          enableCellBorderVertical: true,
          borderColor: Colors.deepOrange,
        ),
      ),
      isCurrentCell: false,
      isSelectedCell: false,
    ).test(
      'If isCurrentCell, isSelectedCell are false '
      'and enableColumnBorder is true, '
      'should be set the border.',
      (tester) async {
        final target = find.descendant(
          of: find.byType(GestureDetector),
          matching: find.byType(DecoratedBox),
        );

        final container = target.evaluate().first.widget as DecoratedBox;

        final BoxDecoration decoration = container.decoration as BoxDecoration;

        final BorderDirectional border = decoration.border as BorderDirectional;

        expect(
          border.end.color,
          stateManager.configuration.style.borderColor,
        );
      },
    );

    aCellWithConfiguration(
      const TrinaGridConfiguration(
        style: TrinaGridStyleConfig(
          enableCellBorderVertical: false,
          borderColor: Colors.deepOrange,
        ),
      ),
      isCurrentCell: false,
      isSelectedCell: false,
    ).test(
      'If isCurrentCell, isSelectedCell are false '
      'and enableColumnBorder is false, '
      'should not be set the border.',
      (tester) async {
        final target = find.descendant(
          of: find.byType(GestureDetector),
          matching: find.byType(DecoratedBox),
        );

        final container = target.evaluate().first.widget as DecoratedBox;

        final BoxDecoration decoration = container.decoration as BoxDecoration;

        final BorderDirectional? border =
            decoration.border as BorderDirectional?;

        expect(border, isNull);
      },
    );

    aCellInsideTrinaBaseRow(
      const TrinaGridConfiguration(
        style: TrinaGridStyleConfig(enableCellBorderHorizontal: true),
      ),
      isCurrentCell: false,
      isSelectedCell: false,
    ).test(
        'When enableCellBorderHorizontal is true, cell height should equal stateManager.rowHeight',
        (tester) async {
      final cellFinder = find.byType(TrinaBaseCell).first;

      final size = tester.getSize(cellFinder);
      expect(size.height, TrinaGridSettings.rowHeight);
    });
    aCellInsideTrinaBaseRow(
      const TrinaGridConfiguration(
        style: TrinaGridStyleConfig(enableCellBorderHorizontal: false),
      ),
    ).test(
        'When enableCellBorderHorizontal is false, cell height should equal stateManager.rowTotalHeight',
        (tester) async {
      final cellFinder = find.byType(TrinaBaseCell).first;

      final size = tester.getSize(cellFinder);
      expect(size.height, stateManager.rowTotalHeight);
    });
  });
}
