import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:trina_grid/trina_grid.dart';

import '../../../helper/column_helper.dart';
import '../../../matcher/trina_object_matcher.dart';
import '../../../mock/shared_mocks.mocks.dart';

void main() {
  late MockTrinaGridStateManager stateManager;
  late MockTrinaGridScrollController scroll;
  late MockLinkedScrollControllerGroup horizontalScroll;
  late MockScrollController horizontalScrollController;
  late MockLinkedScrollControllerGroup verticalScroll;
  late MockScrollController verticalScrollController;
  late MockTrinaGridEventManager eventManager;
  late TrinaGridKeyPressed keyPressed;
  late TrinaGridConfiguration configuration;

  eventBuilder({
    required TrinaGridGestureType gestureType,
    Offset? offset,
    TrinaCell? cell,
    TrinaColumn? column,
    int? rowIdx,
  }) => TrinaGridCellGestureEvent(
    gestureType: gestureType,
    offset: offset ?? Offset.zero,
    cell: cell ?? TrinaCell(value: 'value'),
    column:
        column ??
        TrinaColumn(
          title: 'column',
          field: 'column',
          type: TrinaColumnType.text(),
        ),
    rowIdx: rowIdx ?? 0,
  );

  setUp(() {
    stateManager = MockTrinaGridStateManager();
    scroll = MockTrinaGridScrollController();
    horizontalScroll = MockLinkedScrollControllerGroup();
    horizontalScrollController = MockScrollController();
    verticalScroll = MockLinkedScrollControllerGroup();
    verticalScrollController = MockScrollController();
    eventManager = MockTrinaGridEventManager();
    keyPressed = MockTrinaGridKeyPressed();
    configuration = const TrinaGridConfiguration();

    when(stateManager.eventManager).thenReturn(eventManager);
    when(stateManager.scroll).thenReturn(scroll);
    when(stateManager.isLTR).thenReturn(true);
    when(stateManager.keyPressed).thenReturn(keyPressed);
    when(stateManager.configuration).thenReturn(configuration);
    when(stateManager.isDragSelecting).thenReturn(false);
    when(scroll.horizontal).thenReturn(horizontalScroll);
    when(scroll.bodyRowsHorizontal).thenReturn(horizontalScrollController);
    when(scroll.vertical).thenReturn(verticalScroll);
    when(scroll.bodyRowsVertical).thenReturn(verticalScrollController);
    when(horizontalScrollController.offset).thenReturn(0.0);
    when(verticalScrollController.offset).thenReturn(0.0);
  });

  group('onTapUp', () {
    test('When, '
        'hasFocus = false, '
        'isCurrentCell = true, '
        'Then, '
        'setKeepFocus(true) should be called, '
        'isCurrentCell is true, '
        'return should be called.', () {
      // given
      when(stateManager.hasFocus).thenReturn(false);
      when(stateManager.isCurrentCell(any)).thenReturn(true);
      clearInteractions(stateManager);

      // when
      var event = eventBuilder(gestureType: TrinaGridGestureType.onTapUp);
      event.handler(stateManager);

      // then
      verify(stateManager.setKeepFocus(true)).called(1);
      // Methods that should not be called after return
      verifyNever(stateManager.setEditing(any));
      verifyNever(stateManager.setCurrentCell(any, any));
    });

    test('When, '
        'hasFocus = false, '
        'isCurrentCell = false, '
        'isSelectingInteraction = false, '
        'TrinaMode = normal, '
        'isEditing = true, '
        'Then, '
        'setKeepFocus(true) should be called, '
        'setCurrentCell should be called.', () {
      // given
      when(stateManager.hasFocus).thenReturn(false);
      when(stateManager.isCurrentCell(any)).thenReturn(false);
      when(stateManager.isSelectingInteraction()).thenReturn(false);
      when(stateManager.mode).thenReturn(TrinaGridMode.normal);
      when(stateManager.isEditing).thenReturn(true);
      clearInteractions(stateManager);

      final cell = TrinaCell(value: 'value');
      const rowIdx = 1;

      // when
      var event = eventBuilder(
        gestureType: TrinaGridGestureType.onTapUp,
        cell: cell,
        rowIdx: rowIdx,
      );
      event.handler(stateManager);

      // then
      verify(stateManager.setKeepFocus(true)).called(1);
      verify(stateManager.setCurrentCell(cell, rowIdx)).called(1);
      // Methods that should not be called after return
      verifyNever(stateManager.setEditing(any));
    });

    test('When, '
        'hasFocus = true, '
        'isCurrentCell = true, '
        'isSelectingInteraction = false, '
        'TrinaMode = normal, '
        'isEditing = false, '
        'Then, '
        'setEditing(true) should be called.', () {
      // given
      when(stateManager.hasFocus).thenReturn(true);
      when(stateManager.isCurrentCell(any)).thenReturn(true);
      when(stateManager.isSelectingInteraction()).thenReturn(false);
      when(stateManager.mode).thenReturn(TrinaGridMode.normal);
      when(stateManager.isEditing).thenReturn(false);
      clearInteractions(stateManager);

      final cell = TrinaCell(value: 'value');
      const rowIdx = 1;

      // when
      var event = eventBuilder(
        gestureType: TrinaGridGestureType.onTapUp,
        cell: cell,
        rowIdx: rowIdx,
      );
      event.handler(stateManager);

      // then
      verify(stateManager.setEditing(true)).called(1);
      // Methods that should not be called after return
      verifyNever(stateManager.setKeepFocus(true));
      verifyNever(stateManager.setCurrentCell(any, any));
    });

    test('When, '
        'hasFocus = true, '
        'isSelectingInteraction = true, '
        'keyPressed.shift = true, '
        'Then, '
        'setCurrentSelectingPosition should be called.', () {
      // given
      final column = ColumnHelper.textColumn('column').first;
      final cell = TrinaCell(value: 'value');
      const columnIdx = 1;
      const rowIdx = 1;

      when(stateManager.hasFocus).thenReturn(true);
      when(stateManager.isSelectingInteraction()).thenReturn(true);
      when(keyPressed.shift).thenReturn(true);
      when(stateManager.columnIndex(column)).thenReturn(columnIdx);
      clearInteractions(stateManager);

      // when
      var event = eventBuilder(
        gestureType: TrinaGridGestureType.onTapUp,
        cell: cell,
        rowIdx: rowIdx,
        column: column,
      );
      event.handler(stateManager);

      // then
      verify(
        stateManager.setCurrentSelectingPosition(
          cellPosition: const TrinaGridCellPosition(
            columnIdx: columnIdx,
            rowIdx: rowIdx,
          ),
        ),
      ).called(1);
      // Methods that should not be called after return
      verifyNever(stateManager.setKeepFocus(true));
      verifyNever(stateManager.toggleSelectingRow(any));
    });

    test('When, '
        'hasFocus = true, '
        'isSelectingInteraction = true, '
        'keyPressed.ctrl = true, '
        'Then, '
        'toggleSelectingRow should be called.', () {
      // given
      final cell = TrinaCell(value: 'value');
      const rowIdx = 1;

      when(stateManager.hasFocus).thenReturn(true);
      when(stateManager.isSelectingInteraction()).thenReturn(true);
      when(keyPressed.ctrl).thenReturn(true);
      clearInteractions(stateManager);

      // when
      var event = eventBuilder(
        gestureType: TrinaGridGestureType.onTapUp,
        cell: cell,
        rowIdx: rowIdx,
      );
      event.handler(stateManager);

      // then
      verify(stateManager.toggleSelectingRow(rowIdx)).called(1);
      // Methods that should not be called after return
      verifyNever(stateManager.setKeepFocus(true));
      verifyNever(
        stateManager.setCurrentSelectingPosition(
          cellPosition: anyNamed('cellPosition'),
        ),
      );
    });

    test('When, '
        'hasFocus = true, '
        'isSelectingInteraction = false, '
        'TrinaMode = select, '
        'isCurrentCell = true, '
        'Then, '
        'handleOnSelected should be called.', () {
      // given
      final cell = TrinaCell(value: 'value');
      const rowIdx = 1;

      when(stateManager.hasFocus).thenReturn(true);
      when(stateManager.isSelectingInteraction()).thenReturn(false);
      when(stateManager.mode).thenReturn(TrinaGridMode.select);
      when(stateManager.isCurrentCell(any)).thenReturn(true);
      clearInteractions(stateManager);

      // when
      var event = eventBuilder(
        gestureType: TrinaGridGestureType.onTapUp,
        cell: cell,
        rowIdx: rowIdx,
      );
      event.handler(stateManager);

      // then
      verify(stateManager.handleOnSelected()).called(1);
      // Methods that should not be called after return
      verifyNever(stateManager.setCurrentCell(any, any));
    });

    test('When, '
        'hasFocus = true, '
        'isSelectingInteraction = false, '
        'TrinaMode = select, '
        'isCurrentCell = false, '
        'Then, '
        'setCurrentCell should be called.', () {
      // given
      final cell = TrinaCell(value: 'value');
      const rowIdx = 1;

      when(stateManager.hasFocus).thenReturn(true);
      when(stateManager.isSelectingInteraction()).thenReturn(false);
      when(stateManager.mode).thenReturn(TrinaGridMode.select);
      when(stateManager.isCurrentCell(any)).thenReturn(false);
      clearInteractions(stateManager);

      // when
      var event = eventBuilder(
        gestureType: TrinaGridGestureType.onTapUp,
        cell: cell,
        rowIdx: rowIdx,
      );
      event.handler(stateManager);

      // then
      verify(stateManager.setCurrentCell(cell, rowIdx));
      // Methods that should not be called after return
      verifyNever(stateManager.handleOnSelected());
    });
  });

  group('onLongPressStart', () {
    test('When, '
        'isCurrentCell = false, '
        'Then, '
        'setCurrentCell, setSelecting should be called.', () {
      // given
      final cell = TrinaCell(value: 'value');
      const rowIdx = 1;

      when(stateManager.isCurrentCell(any)).thenReturn(false);
      when(stateManager.selectingMode).thenReturn(TrinaGridSelectingMode.cell);
      clearInteractions(stateManager);

      // when
      var event = eventBuilder(
        gestureType: TrinaGridGestureType.onLongPressStart,
        cell: cell,
        rowIdx: rowIdx,
      );
      event.handler(stateManager);

      // then
      verify(stateManager.isCurrentCell(cell));
      verify(stateManager.setCurrentCell(cell, rowIdx, notify: false));
      verify(stateManager.setSelecting(true));
    });

    test('When, '
        'isCurrentCell = true, '
        'Then, '
        'setCurrentCell should not be called.', () {
      // given
      final cell = TrinaCell(value: 'value');
      const rowIdx = 1;

      when(stateManager.isCurrentCell(any)).thenReturn(true);
      when(stateManager.selectingMode).thenReturn(TrinaGridSelectingMode.cell);
      clearInteractions(stateManager);

      // when
      var event = eventBuilder(
        gestureType: TrinaGridGestureType.onLongPressStart,
        cell: cell,
        rowIdx: rowIdx,
      );
      event.handler(stateManager);

      // then
      verifyNever(stateManager.setCurrentCell(cell, rowIdx, notify: false));
    });

    test('When, '
        'isCurrentCell = false, '
        'selectingMode = Row, '
        'Then, '
        'toggleSelectingRow should be called.', () {
      // given
      final cell = TrinaCell(value: 'value');
      const rowIdx = 1;

      when(stateManager.isCurrentCell(any)).thenReturn(false);
      when(stateManager.selectingMode).thenReturn(TrinaGridSelectingMode.row);
      clearInteractions(stateManager);

      // when
      var event = eventBuilder(
        gestureType: TrinaGridGestureType.onLongPressStart,
        cell: cell,
        rowIdx: rowIdx,
      );
      event.handler(stateManager);

      // then
      verify(stateManager.toggleSelectingRow(rowIdx));
    });
  });

  group('onLongPressMoveUpdate', () {
    test('When, '
        'isCurrentCell = false, '
        'selectingMode = Row, '
        'Then, '
        'setCurrentSelectingPositionWithOffset should be called.', () {
      // given
      const offset = Offset(2.0, 3.0);
      final cell = TrinaCell(value: 'value');
      const rowIdx = 1;

      when(stateManager.isCurrentCell(any)).thenReturn(false);
      when(stateManager.selectingMode).thenReturn(TrinaGridSelectingMode.row);
      clearInteractions(stateManager);

      // when
      var event = eventBuilder(
        gestureType: TrinaGridGestureType.onLongPressMoveUpdate,
        offset: offset,
        cell: cell,
        rowIdx: rowIdx,
      );
      event.handler(stateManager);

      // then
      verify(stateManager.setCurrentSelectingPositionWithOffset(offset));
      verify(
        eventManager.addEvent(
          argThat(
            TrinaObjectMatcher<TrinaGridScrollUpdateEvent>(
              rule: (event) {
                return event.offset == offset;
              },
            ),
          ),
        ),
      );
    });
  });

  group('onLongPressEnd', () {
    test('When, '
        'isCurrentCell = true, '
        'Then, '
        'setSelecting(false) should be called.', () {
      // given
      final cell = TrinaCell(value: 'value');
      const rowIdx = 1;

      // when
      when(stateManager.isCurrentCell(any)).thenReturn(true);

      var event = eventBuilder(
        gestureType: TrinaGridGestureType.onLongPressEnd,
        cell: cell,
        rowIdx: rowIdx,
      );
      event.handler(stateManager);

      // then
      verify(stateManager.setSelecting(false));
    });
  });
}
