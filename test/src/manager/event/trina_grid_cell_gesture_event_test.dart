import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:trina_grid/trina_grid.dart';

import '../../../helper/column_helper.dart';
import '../../../matcher/trina_object_matcher.dart';
import '../../../mock/mock_methods.dart';
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

  eventBuilder({
    required TrinaGridGestureType gestureType,
    Offset? offset,
    TrinaCell? cell,
    TrinaColumn? column,
    int? rowIdx,
  }) =>
      TrinaGridCellGestureEvent(
        gestureType: gestureType,
        offset: offset ?? Offset.zero,
        cell: cell ?? TrinaCell(value: 'value'),
        column: column ??
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

    when(stateManager.eventManager).thenReturn(eventManager);
    when(stateManager.scroll).thenReturn(scroll);
    when(stateManager.isLTR).thenReturn(true);
    when(stateManager.keyPressed).thenReturn(keyPressed);
    when(scroll.horizontal).thenReturn(horizontalScroll);
    when(scroll.bodyRowsHorizontal).thenReturn(horizontalScrollController);
    when(scroll.vertical).thenReturn(verticalScroll);
    when(scroll.bodyRowsVertical).thenReturn(verticalScrollController);
    when(horizontalScrollController.offset).thenReturn(0.0);
    when(verticalScrollController.offset).thenReturn(0.0);
    when(stateManager.onDoubleTap).thenReturn((event) {});
    when(stateManager.onRowSecondaryTap).thenReturn((event) {});
    when(stateManager.selectingMode).thenReturn(TrinaGridSelectingMode.cell);
  });

  group('onTapUp', () {
    test(
      'When, '
      'hasFocus = false, '
      'isCurrentCell = true, '
      'Then, '
      'setKeepFocus(true) should be called, '
      'isCurrentCell is true, '
      'return should be called.',
      () {
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
      },
    );

    test(
      'When, '
      'hasFocus = false, '
      'isCurrentCell = false, '
      'isSelectingInteraction = false, '
      'TrinaMode = normal, '
      'isEditing = true, '
      'Then, '
      'setKeepFocus(true) should be called, '
      'setCurrentCell should be called.',
      () {
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
      },
    );

    test(
      'When, '
      'hasFocus = true, '
      'isCurrentCell = true, '
      'isSelectingInteraction = false, '
      'stateManager.isSelectingInteraction() = false, '
      'TrinaMode = normal, '
      'isEditing = false, '
      'Then, '
      'setEditing(true) should be called.',
      () {
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
      },
    );

    test(
      'When, '
      'hasFocus = true, '
      'isSelectingInteraction = true, '
      'keyPressed.shift = true, '
      'Then, '
      'setCurrentSelectingPosition should be called.',
      () {
        // given
        final column = ColumnHelper.textColumn('column').first;
        final cell = TrinaCell(value: 'value');
        const columnIdx = 1;
        const rowIdx = 1;
        final cellPosition =
            TrinaGridCellPosition(rowIdx: rowIdx, columnIdx: columnIdx);

        when(stateManager.hasFocus).thenReturn(true);
        when(stateManager.currentCellPosition).thenReturn(cellPosition);
        when(stateManager.currentSelectingPosition).thenReturn(cellPosition);
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
          stateManager.setCurrentSelectingPosition(cellPosition: cellPosition),
        ).called(1);
        // Methods that should not be called after return
        verifyNever(stateManager.setKeepFocus(true));
        verifyNever(stateManager.toggleRowSelection(any));
      },
    );

    test(
      'When, '
      'hasFocus = true, '
      'isSelectingInteraction = true, '
      'keyPressed.ctrl = true, '
      'selectingMode = TrinaGridSelectingMode.row, '
      'Then, '
      'toggleRowSelection should be called.',
      () {
        // given
        final cell = TrinaCell(value: 'value');
        const rowIdx = 1;

        when(stateManager.hasFocus).thenReturn(true);
        when(stateManager.selectingMode).thenReturn(TrinaGridSelectingMode.row);
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
        verify(
          stateManager.toggleRowSelection(rowIdx),
        ).called(1);
        // Methods that should not be called after return
        verifyNever(stateManager.setKeepFocus(true));
      },
    );

    test(
      'When, '
      'hasFocus = true, '
      'isSelectingInteraction = false, '
      'isCurrentCell = true, '
      'selectingMode is TrinaGridSelectingMode.cell, '
      'Then, '
      'handleOnSelected should NOT be called.',
      () {
        // given
        final cell = TrinaCell(value: 'value');
        const rowIdx = 1;

        when(stateManager.hasFocus).thenReturn(true);
        when(stateManager.isSelectingInteraction()).thenReturn(false);
        when(stateManager.selectingMode)
            .thenReturn(TrinaGridSelectingMode.cell);
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
        verifyNever(stateManager.handleOnSelected());
        // Methods that should not be called after return
        verifyNever(stateManager.setCurrentCell(any, any));
      },
    );

    test(
      'When, '
      'hasFocus = true, '
      'isSelectingInteraction = false, '
      'isCurrentCell = false, '
      'Then, '
      'setCurrentCell should be called.',
      () {
        // given
        final cell = TrinaCell(value: 'value');
        const rowIdx = 1;

        when(stateManager.hasFocus).thenReturn(true);
        when(stateManager.selectingMode).thenReturn(TrinaGridSelectingMode.row);
        when(stateManager.isSelectingInteraction()).thenReturn(false);
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
      },
    );
    test(
      'When, '
      'hasFocus = true, '
      'isSelectingInteraction = false, '
      'selectingMode = TrinaGridSelectingMode.row, '
      'isCurrentCell = false, '
      'mode is not TrinaGridMode.popup, '
      'Then, '
      'handleOnSelected should be called.',
      () {
        // given
        final cell = TrinaCell(value: 'value');
        const rowIdx = 1;

        when(stateManager.hasFocus).thenReturn(true);
        when(stateManager.selectingMode).thenReturn(TrinaGridSelectingMode.row);
        when(stateManager.isSelectingInteraction()).thenReturn(false);
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
        verify(stateManager.handleOnSelected()).called(1);
      },
    );
  });

  group('onLongPressStart', () {
    test(
      'When, '
      'isCurrentCell = false, '
      'Then, '
      'setCurrentCell, setSelecting should be called.',
      () {
        // given
        final cell = TrinaCell(value: 'value');
        const rowIdx = 1;

        when(stateManager.isCurrentCell(any)).thenReturn(false);

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
      },
    );

    test(
      'When, '
      'isCurrentCell = true, '
      'Then, '
      'setCurrentCell should not be called.',
      () {
        // given
        final cell = TrinaCell(value: 'value');
        const rowIdx = 1;

        when(stateManager.isCurrentCell(any)).thenReturn(true);

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
      },
    );
  });

  group('onLongPressMoveUpdate', () {
    final TrinaGridCellPosition anchorPosition =
        const TrinaGridCellPosition(columnIdx: 1, rowIdx: 1);

    void setUpMocksForLongPressMoveUpdate({
      required TrinaGridCellPosition? previousSelectingPosition,
      required TrinaGridCellPosition? newSelectingPosition,
      required TrinaGridSelectingMode selectingMode,
      required Offset offset,
    }) {
      when(stateManager.isCurrentCell(any)).thenReturn(false);
      when(stateManager.selectingMode).thenReturn(selectingMode);
      when(stateManager.currentCellPosition).thenReturn(anchorPosition);
      when(stateManager.setCurrentSelectingPositionWithOffset(offset))
          .thenReturn(null);
      when(stateManager.currentSelectingPosition).thenReturnInOrder([
        previousSelectingPosition,
        newSelectingPosition,
      ]);
      clearInteractions(stateManager);
    }

    test(
      'When selectingMode is row, '
      'and the position is not changed, '
      'Then selectRowsInRange should not be called.',
      () {
        // given
        const offset = Offset(2.0, 3.0);
        final cell = TrinaCell(value: 'value');
        const rowIdx = 1;
        final position = const TrinaGridCellPosition(columnIdx: 1, rowIdx: 1);

        setUpMocksForLongPressMoveUpdate(
          previousSelectingPosition: position,
          newSelectingPosition: null,
          selectingMode: TrinaGridSelectingMode.row,
          offset: offset,
        );

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
        verifyNever(stateManager.selectRowsInRange(any, any));
        verify(eventManager.addEvent(argThat(
            TrinaObjectMatcher<TrinaGridScrollUpdateEvent>(rule: (event) {
          return event.offset == offset;
        }))));
      },
    );

    test(
      'When selectingMode is row, '
      'and the row position is changed, '
      'Then selectRowsInRange should be called.',
      () {
        // given
        const offset = Offset(2.0, 3.0);
        final cell = TrinaCell(value: 'value');
        const rowIdx = 1;
        final newPosition =
            const TrinaGridCellPosition(columnIdx: 1, rowIdx: 2);

        setUpMocksForLongPressMoveUpdate(
          previousSelectingPosition: anchorPosition,
          newSelectingPosition: newPosition,
          selectingMode: TrinaGridSelectingMode.row,
          offset: offset,
        );

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
        verify(stateManager.selectRowsInRange(
          anchorPosition.rowIdx,
          newPosition.rowIdx,
        )).called(1);
        verify(eventManager.addEvent(argThat(
            TrinaObjectMatcher<TrinaGridScrollUpdateEvent>(rule: (event) {
          return event.offset == offset;
        }))));
      },
    );

    test(
      'When selectingMode is cell, '
      'and the position is not changed, '
      'Then selectCellsInRange should not be called.',
      () {
        // given
        const offset = Offset(2.0, 3.0);
        final cell = TrinaCell(value: 'value');
        const rowIdx = 1;
        final position = const TrinaGridCellPosition(columnIdx: 1, rowIdx: 1);

        setUpMocksForLongPressMoveUpdate(
          previousSelectingPosition: position,
          newSelectingPosition: null,
          selectingMode: TrinaGridSelectingMode.cell,
          offset: offset,
        );

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
        verifyNever(stateManager.selectCellsInRange(any, any));
        verify(eventManager.addEvent(argThat(
            TrinaObjectMatcher<TrinaGridScrollUpdateEvent>(rule: (event) {
          return event.offset == offset;
        }))));
      },
    );

    test(
      'When selectingMode is cell, '
      'and the row position is changed, '
      'Then selectCellsInRange should be called.',
      () {
        // given
        const offset = Offset(2.0, 3.0);
        final cell = TrinaCell(value: 'value');
        const rowIdx = 1;
        final newPosition =
            const TrinaGridCellPosition(columnIdx: 1, rowIdx: 2);

        setUpMocksForLongPressMoveUpdate(
          previousSelectingPosition: anchorPosition,
          newSelectingPosition: newPosition,
          selectingMode: TrinaGridSelectingMode.cell,
          offset: offset,
        );

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
        verify(stateManager.selectCellsInRange(
          anchorPosition,
          newPosition,
        )).called(1);
        verify(eventManager.addEvent(argThat(
            TrinaObjectMatcher<TrinaGridScrollUpdateEvent>(rule: (event) {
          return event.offset == offset;
        }))));
      },
    );

    test(
      'When selectingMode is cell, '
      'and the column position is changed, '
      'Then selectCellsInRange should be called.',
      () {
        // given
        const offset = Offset(2.0, 3.0);
        final cell = TrinaCell(value: 'value');
        const rowIdx = 1;
        final newPosition =
            const TrinaGridCellPosition(columnIdx: 2, rowIdx: 1);

        setUpMocksForLongPressMoveUpdate(
          previousSelectingPosition: anchorPosition,
          newSelectingPosition: newPosition,
          selectingMode: TrinaGridSelectingMode.cell,
          offset: offset,
        );

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

        verify(stateManager.selectCellsInRange(
          anchorPosition,
          newPosition,
        )).called(1);
        verify(eventManager.addEvent(argThat(
            TrinaObjectMatcher<TrinaGridScrollUpdateEvent>(rule: (event) {
          return event.offset == offset;
        }))));
      },
    );

    test(
      'When anchorPosition is null, '
      'Then any selection method should not be called.',
      () {
        // given
        const offset = Offset(2.0, 3.0);
        final cell = TrinaCell(value: 'value');
        const rowIdx = 1;

        when(stateManager.isCurrentCell(any)).thenReturn(false);
        when(stateManager.currentCellPosition).thenReturn(null);
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
        verifyNever(stateManager.selectRowsInRange(any, any));
        verifyNever(stateManager.selectCellsInRange(any, any));
        verify(eventManager.addEvent(argThat(
            TrinaObjectMatcher<TrinaGridScrollUpdateEvent>(rule: (event) {
          return event.offset == offset;
        }))));
      },
    );
  });

  group('onLongPressEnd', () {
    test(
      'When, '
      'isCurrentCell = true, '
      'Then, '
      'setSelecting(false) should be called.',
      () {
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
      },
    );
  });

  group('onDoubleTap', () {
    test(
      'When, '
      'mode is popup, '
      'selectingMode is TrinaGridSelectingMode.row, '
      'Then, '
      'toggleRowSelection and handleOnSelected should be called.',
      () {
        // given
        final cell = TrinaCell(value: 'value');
        const rowIdx = 1;

        when(stateManager.mode).thenReturn(TrinaGridMode.popup);
        when(stateManager.selectingMode.isEnabled).thenReturn(true);
        when(stateManager.onDoubleTap).thenReturn(null);
        when(stateManager.selectingMode).thenReturn(TrinaGridSelectingMode.row);
        clearInteractions(stateManager);

        // when
        var event = eventBuilder(
          gestureType: TrinaGridGestureType.onDoubleTap,
          cell: cell,
          rowIdx: rowIdx,
        );
        event.handler(stateManager);

        // then
        verify(stateManager.toggleRowSelection(rowIdx)).called(1);
        verify(stateManager.handleOnSelected()).called(1);
      },
    );
    test(
      'When, '
      'mode is popup, '
      'selectingMode is TrinaGridSelectingMode.cell '
      'Then, '
      'toggleCellSelection and handleOnSelected should be called.',
      () {
        // given
        final cell = TrinaCell(value: 'value');
        const rowIdx = 1;

        when(stateManager.mode).thenReturn(TrinaGridMode.popup);
        when(stateManager.selectingMode.isEnabled).thenReturn(true);
        when(stateManager.onDoubleTap).thenReturn(null);
        when(stateManager.selectingMode)
            .thenReturn(TrinaGridSelectingMode.cell);
        clearInteractions(stateManager);

        // when
        var event = eventBuilder(
          gestureType: TrinaGridGestureType.onDoubleTap,
          cell: cell,
          rowIdx: rowIdx,
        );
        event.handler(stateManager);

        // then
        verify(stateManager.toggleCellSelection(cell)).called(1);
        verify(stateManager.handleOnSelected()).called(1);
      },
    );

    testDoubleTapCurrentCellToEdit(TrinaGridSelectingMode selectingMode) {
      return test(
        'When, '
        'autoEditing is false, '
        'selectingMode is ${selectingMode.name}, '
        'isCurrentCell is true, '
        'Then, '
        'setEditing(true) should be called.',
        () {
          // given
          final cell = TrinaCell(value: 'value');
          const rowIdx = 1;

          when(stateManager.mode).thenReturn(TrinaGridMode.normal);
          when(stateManager.selectingMode).thenReturn(selectingMode);
          when(stateManager.autoEditing).thenReturn(false);
          when(stateManager.onDoubleTap).thenReturn(null);
          when(stateManager.isCurrentCell(cell)).thenReturn(true);

          clearInteractions(stateManager);

          // when
          var event = eventBuilder(
            gestureType: TrinaGridGestureType.onDoubleTap,
            cell: cell,
            rowIdx: rowIdx,
          );
          event.handler(stateManager);

          // then
          verify(stateManager.setEditing(true)).called(1);
          verifyNever(stateManager.setCurrentCell(any, any));
        },
      );
    }

    testDoubleTapCurrentCellToEdit(TrinaGridSelectingMode.cell);
    testDoubleTapCurrentCellToEdit(TrinaGridSelectingMode.row);

    testDoubleTapNotCurrentCell(TrinaGridSelectingMode selectingMode) {
      return test(
        'When, '
        'autoEditing is false, '
        'selectingMode is ${selectingMode.name}, '
        'isCurrentCell is false, '
        'Then, '
        'setCurrentCell should be called.',
        () {
          // given
          final cell = TrinaCell(value: 'value');
          const rowIdx = 1;

          when(stateManager.mode).thenReturn(TrinaGridMode.normal);
          when(stateManager.selectingMode).thenReturn(selectingMode);
          when(stateManager.autoEditing).thenReturn(false);
          when(stateManager.onDoubleTap).thenReturn(null);
          when(stateManager.isCurrentCell(cell)).thenReturn(false);
          clearInteractions(stateManager);

          // when
          var event = eventBuilder(
            gestureType: TrinaGridGestureType.onDoubleTap,
            cell: cell,
            rowIdx: rowIdx,
          );
          event.handler(stateManager);

          // then
          verify(stateManager.setCurrentCell(cell, rowIdx)).called(1);
          verifyNever(stateManager.setEditing(any));
        },
      );
    }

    testDoubleTapNotCurrentCell(TrinaGridSelectingMode.cell);
    testDoubleTapNotCurrentCell(TrinaGridSelectingMode.row);

    test(
      'When, '
      'autoEditing is true, '
      'Then, '
      'setEditing, setCurrentCell should NOT be called.',
      () {
        // given``
        final cell = TrinaCell(value: 'value');
        const rowIdx = 1;

        when(stateManager.mode).thenReturn(TrinaGridMode.normal);
        when(stateManager.autoEditing).thenReturn(true);
        when(stateManager.onDoubleTap).thenReturn(null);
        when(stateManager.isCurrentCell(cell)).thenReturn(true);

        clearInteractions(stateManager);

        // when
        var event = eventBuilder(
          gestureType: TrinaGridGestureType.onDoubleTap,
          cell: cell,
          rowIdx: rowIdx,
        );
        event.handler(stateManager);

        // then
        verifyNever(stateManager.setEditing(any));
        verifyNever(stateManager.setCurrentCell(any, any));
      },
    );
    test(
      'When, '
      'stateManager.onDoubleTap is not null'
      'Then, '
      'onDoubleTap should be called.',
      () {
        final mock = MockMethods();
        // given
        final cell = TrinaCell(value: 'value');
        final row = TrinaRow(cells: {'cell1': cell});
        const rowIdx = 1;

        when(stateManager.onDoubleTap)
            .thenReturn(mock.oneParamReturnVoid<TrinaGridOnDoubleTapEvent>);
        clearInteractions(stateManager);
        when(stateManager.getRowByIdx(rowIdx)).thenReturn(row);

        // when
        var event = eventBuilder(
          gestureType: TrinaGridGestureType.onDoubleTap,
          cell: cell,
          rowIdx: rowIdx,
        );
        event.handler(stateManager);

        // then
        verify(mock.oneParamReturnVoid(
          TrinaObjectMatcher<TrinaGridOnDoubleTapEvent>(rule: (event) {
            return event.rowIdx == rowIdx &&
                event.cell.value == 'value' &&
                event.row == row;
          }),
        )).called(1);
      },
    );
    test(
      'When, '
      'stateManager.onDoubleTap is null'
      'Then, '
      'onDoubleTap should NOT be called.',
      () {
        final mock = MockMethods();
        // given
        final cell = TrinaCell(value: 'value');
        final row = TrinaRow(cells: {'cell1': cell});
        const rowIdx = 1;

        when(stateManager.onDoubleTap)
            .thenReturn(mock.oneParamReturnVoid<TrinaGridOnDoubleTapEvent>);
        clearInteractions(stateManager);
        when(stateManager.getRowByIdx(rowIdx)).thenReturn(row);

        // when
        var event = eventBuilder(
          gestureType: TrinaGridGestureType.onDoubleTap,
          cell: cell,
          rowIdx: rowIdx,
        );
        event.handler(stateManager);

        // then
        verifyNever(mock.oneParamReturnVoid<TrinaGridOnDoubleTapEvent>(
            TrinaGridOnDoubleTapEvent(row: row, rowIdx: rowIdx, cell: cell)));
      },
    );
  });

  group('onSecondaryTap', () {
    test(
      'When, '
      'stateManager.onRowSecondaryTap is not null'
      'Then, '
      'onRowSecondaryTap should be called.',
      () {
        final mock = MockMethods();
        // given
        final cell = TrinaCell(value: 'value');
        final row = TrinaRow(cells: {'cell1': cell});
        const rowIdx = 1;

        when(stateManager.onRowSecondaryTap).thenReturn(
            mock.oneParamReturnVoid<TrinaGridOnRowSecondaryTapEvent>);
        clearInteractions(stateManager);
        when(stateManager.getRowByIdx(rowIdx)).thenReturn(row);

        // when
        var event = eventBuilder(
          gestureType: TrinaGridGestureType.onSecondaryTap,
          cell: cell,
          rowIdx: rowIdx,
        );
        event.handler(stateManager);

        // then
        verify(mock.oneParamReturnVoid(
          TrinaObjectMatcher<TrinaGridOnRowSecondaryTapEvent>(rule: (event) {
            return event.rowIdx == rowIdx &&
                event.row.cells['cell1']!.value == 'value';
          }),
        )).called(1);
      },
    );
    test(
      'When, '
      'stateManager.onRowSecondaryTap is null'
      'Then, '
      'onRowSecondaryTap should NOT be called.',
      () {
        final mock = MockMethods();
        // given
        final cell = TrinaCell(value: 'value');
        final row = TrinaRow(cells: {'cell1': cell});
        const rowIdx = 1;

        when(stateManager.onRowSecondaryTap).thenReturn(null);
        clearInteractions(stateManager);
        when(stateManager.getRowByIdx(rowIdx)).thenReturn(row);

        // when
        var event = eventBuilder(
          gestureType: TrinaGridGestureType.onSecondaryTap,
          cell: cell,
          rowIdx: rowIdx,
        );
        event.handler(stateManager);

        // then
        verifyNever(mock.oneParamReturnVoid(
          TrinaObjectMatcher<TrinaGridOnRowSecondaryTapEvent>(rule: (event) {
            return event.rowIdx == rowIdx &&
                event.row.cells['cell1']!.value == 'value';
          }),
        ));
      },
    );
  });
}
