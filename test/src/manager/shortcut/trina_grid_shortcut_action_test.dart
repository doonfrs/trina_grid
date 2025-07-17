import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:trina_grid/trina_grid.dart';

import '../../../helper/column_helper.dart';
import '../../../mock/shared_mocks.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MockTrinaGridStateManager stateManager = MockTrinaGridStateManager();
  final TrinaCell currentCell = TrinaCell(value: 'value');

  TrinaKeyManagerEvent getTrinaKeyEvent(KeyEvent keyEvent) {
    return TrinaKeyManagerEvent(
      focusNode: stateManager.gridFocusNode,
      event: keyEvent,
    );
  }

  group('Action should call handleOnSelectedIfNotPopup', () {
    setUp(() {
      // Default mocks for stateManager
      when(stateManager.configuration).thenReturn(TrinaGridConfiguration());
      when(stateManager.currentCell).thenReturn(currentCell);
      when(stateManager.isEditing).thenReturn(false);
      when(stateManager.gridFocusNode).thenReturn(FocusNode());
      when(stateManager.mode).thenReturn(TrinaGridMode.normal);
      when(stateManager.currentCellPosition).thenReturn(
        const TrinaGridCellPosition(columnIdx: 0, rowIdx: 0),
      );
    });

    final arrowUpKeyEvent = getTrinaKeyEvent(
      KeyDownEvent(
        physicalKey: PhysicalKeyboardKey.arrowUp,
        logicalKey: LogicalKeyboardKey.arrowUp,
        timeStamp: Duration(milliseconds: 10),
      ),
    );
    final arrowRightKeyEvent = getTrinaKeyEvent(
      KeyDownEvent(
        physicalKey: PhysicalKeyboardKey.arrowRight,
        logicalKey: LogicalKeyboardKey.arrowRight,
        timeStamp: Duration(milliseconds: 10),
      ),
    );
    final tapKeyEvent = getTrinaKeyEvent(
      KeyDownEvent(
        physicalKey: PhysicalKeyboardKey.tab,
        logicalKey: LogicalKeyboardKey.tab,
        timeStamp: Duration(milliseconds: 10),
      ),
    );

    /// A helper function to test the behavior of [TrinaGridShortcutAction.execute]
    ///
    /// [keyEvent] is the [TrinaKeyManagerEvent] to be passed to [action.execute]
    void testAction(
        TrinaGridShortcutAction action, TrinaKeyManagerEvent keyEvent) {
      test(
          'when currentCell is not null, handleOnSelectedIfNotPopup should be called.',
          () {
        // Arrange
        when(stateManager.currentCell).thenReturn(currentCell);
        final keyEvent = getTrinaKeyEvent(arrowRightKeyEvent.event);
        // Act
        action.execute(keyEvent: keyEvent, stateManager: stateManager);

        // Assert
        verify(stateManager.handleOnSelectedIfNotPopup()).called(1);
      });
    }

    void testActionWithNullCurrentCell(
        TrinaGridShortcutAction action, TrinaKeyManagerEvent keyEvent) {
      test(
          'when currentCell is null, handleOnSelectedIfNotPopup should not be called.',
          () {
        // Arrange
        when(stateManager.currentCell).thenReturn(null);
        final keyEvent = getTrinaKeyEvent(arrowRightKeyEvent.event);
        // Act
        action.execute(keyEvent: keyEvent, stateManager: stateManager);

        // Assert
        verifyNever(stateManager.handleOnSelectedIfNotPopup());
      });
    }

    group('TrinaGridActionMoveCellFocus', () {
      const direction = TrinaMoveDirection.right;
      const action = TrinaGridActionMoveCellFocus(direction);
      testAction(action, arrowRightKeyEvent);
      testActionWithNullCurrentCell(action, arrowRightKeyEvent);
    });

    group('TrinaGridActionMoveCellFocusByPage', () {
      setUp(() {
        when(stateManager.rowTotalHeight).thenReturn(100);
        when(stateManager.rowContainerHeight).thenReturn(130);
      });
      const action = TrinaGridActionMoveCellFocusByPage(TrinaMoveDirection.up);
      testAction(action, arrowUpKeyEvent);
    });
    group('TrinaGridActionDefaultTab', () {
      const action = TrinaGridActionDefaultTab();
      final keyEvent = getTrinaKeyEvent(tapKeyEvent.event);
      testAction(action, keyEvent);
      testActionWithNullCurrentCell(action, keyEvent);
    });
    group('TrinaGridActionMoveCellFocusToEdge, TrinaMoveDirection.down', () {
      const action =
          TrinaGridActionMoveCellFocusToEdge(TrinaMoveDirection.down);
      final keyEvent = getTrinaKeyEvent(tapKeyEvent.event);
      testAction(action, keyEvent);
    });
    group('TrinaGridActionMoveCellFocusToEdge, TrinaMoveDirection.up', () {
      const action = TrinaGridActionMoveCellFocusToEdge(TrinaMoveDirection.up);
      final keyEvent = getTrinaKeyEvent(tapKeyEvent.event);
      testAction(action, keyEvent);
    });
  });
  group('TrinaGridActionDefaultEnterKey', () {
    const action = TrinaGridActionDefaultEnterKey();
    MockTrinaGridStateManager stateManager = MockTrinaGridStateManager();
    final TrinaCell currentCell = TrinaCell(value: 'value');
    final columns = ColumnHelper.textColumn('text');
    final rows = [
      TrinaRow(cells: {'text0': currentCell})
    ];
    currentCell.setColumn(columns.first);
    currentCell.setRow(rows.first);

    final enterKeyEvent = getTrinaKeyEvent(KeyDownEvent(
      physicalKey: PhysicalKeyboardKey.enter,
      logicalKey: LogicalKeyboardKey.enter,
      timeStamp: Duration(milliseconds: 10),
    ));

    setUp(() {
      clearInteractions(stateManager);
      when(stateManager.configuration).thenReturn(TrinaGridConfiguration());
      when(stateManager.currentCell).thenReturn(currentCell);
      when(stateManager.gridFocusNode).thenReturn(FocusNode());
      when(stateManager.mode).thenReturn(TrinaGridMode.normal);
      when(stateManager.currentRowIdx).thenReturn(0);
      when(stateManager.currentCellPosition).thenReturn(
        const TrinaGridCellPosition(columnIdx: 0, rowIdx: 0),
      );

      when(stateManager.rows).thenReturn(rows);
      when(stateManager.refRows).thenReturn(FilteredList(initialList: rows));
      when(stateManager.refColumns)
          .thenReturn(FilteredList(initialList: columns));
    });

    group('enterKeyAction is `select`', () {
      setUp(() {
        when(stateManager.configuration).thenReturn(
          TrinaGridConfiguration(
              enterKeyAction: TrinaGridEnterKeyAction.select),
        );
      });
      test('it should call handleOnSelected', () {
        action.execute(keyEvent: enterKeyEvent, stateManager: stateManager);

        verify(stateManager.handleOnSelected()).called(1);
      });

      test(
        'When currentCell == null, '
        'it should not call toggleRowSelection or toggleCellSelection',
        () {
          when(stateManager.currentCell).thenReturn(null);
          // act
          action.execute(keyEvent: enterKeyEvent, stateManager: stateManager);
          // assert
          verifyNever(
            stateManager.toggleRowSelection(any, notify: anyNamed('notify')),
          );
          verifyNever(
            stateManager.toggleCellSelection(any, notify: anyNamed('notify')),
          );
        },
      );
      test(
        'when selectingMode.isRow == true, '
        'currentCell != null, '
        'it should call toggleRowSelection',
        () {
          when(stateManager.selectingMode)
              .thenReturn(TrinaGridSelectingMode.row);
          when(stateManager.currentCell).thenReturn(currentCell);
          // act
          action.execute(keyEvent: enterKeyEvent, stateManager: stateManager);
          // assert
          verify(
            stateManager.toggleRowSelection(any, notify: anyNamed('notify')),
          ).called(1);
          verifyNever(
            stateManager.toggleCellSelection(any, notify: anyNamed('notify')),
          );
        },
      );
      test(
        'when selectingMode.isRow == false, '
        'currentCell != null, '
        'it should call toggleCellSelection',
        () {
          when(stateManager.selectingMode)
              .thenReturn(TrinaGridSelectingMode.cell);
          when(stateManager.currentCell).thenReturn(currentCell);
          // act
          action.execute(keyEvent: enterKeyEvent, stateManager: stateManager);
          // assert
          verify(
            stateManager.toggleCellSelection(any, notify: anyNamed('notify')),
          ).called(1);
          verifyNever(
            stateManager.toggleRowSelection(any, notify: anyNamed('notify')),
          );
        },
      );
    });

    group('Cell movement behavior', () {
      test(
          'should not move cell when not editing and column enableEditingMode is true',
          () {
        final config = TrinaGridConfiguration(
          enterKeyAction: TrinaGridEnterKeyAction.editingAndMoveDown,
        );
        when(stateManager.configuration).thenReturn(config);
        when(stateManager.isEditing).thenReturn(false);
        expect(stateManager.currentCell!.column.enableEditingMode, true);
        // act
        action.execute(keyEvent: enterKeyEvent, stateManager: stateManager);

        verifyNever(
          stateManager.moveCurrentCell(any, notify: anyNamed('notify')),
        );
      });
      test(
          'it should move cell when editing and column enableEditingMode is true',
          () {
        final config = TrinaGridConfiguration(
          enterKeyAction: TrinaGridEnterKeyAction.editingAndMoveDown,
        );
        when(stateManager.configuration).thenReturn(config);
        when(stateManager.isEditing).thenReturn(true);
        expect(stateManager.currentCell!.column.enableEditingMode, true);
        // act
        action.execute(keyEvent: enterKeyEvent, stateManager: stateManager);

        verify(
          stateManager.moveCurrentCell(TrinaMoveDirection.down,
              notify: anyNamed('notify')),
        ).called(1);
      });
      test(
          'it should move cell when column enableEditingMode is false and isEditing is false',
          () {
        final col = TrinaColumn(
          title: 'title',
          field: 'field',
          enableEditingMode: false,
          type: TrinaColumnType.text(),
        );
        when(stateManager.isEditing).thenReturn(false);
        when(stateManager.currentColumn).thenReturn(col);
        // act
        action.execute(keyEvent: enterKeyEvent, stateManager: stateManager);

        verify(
          stateManager.moveCurrentCell(any, notify: anyNamed('notify')),
        ).called(1);
      });
    });
    group('Selection handling', () {
      setUp(() {
        when(stateManager.onSelected).thenReturn((_) {});
      });

      test(
          'when selectingMode is not disabled, '
          'selectedCells is not empty, '
          'it should call clearCurrentSelecting and handleOnSelected', () {
        expect(stateManager.selectingMode != TrinaGridSelectingMode.disabled,
            isTrue);
        when(stateManager.selectedCells).thenReturn([currentCell]);

        action.execute(keyEvent: enterKeyEvent, stateManager: stateManager);

        verify(stateManager.clearCurrentSelecting()).called(1);
        verify(stateManager.handleOnSelected()).called(1);
      });
      test(
          'when selectingMode is not disabled, '
          'selectedRows is not empty, '
          'it should call clearCurrentSelecting and handleOnSelected', () {
        expect(stateManager.selectingMode != TrinaGridSelectingMode.disabled,
            isTrue);
        when(stateManager.selectedRows).thenReturn([rows.first]);

        action.execute(keyEvent: enterKeyEvent, stateManager: stateManager);

        verify(stateManager.clearCurrentSelecting()).called(1);
        verify(stateManager.handleOnSelected()).called(1);
      });

      test('should not clear selection when selection mode disabled', () {
        when(stateManager.selectingMode)
            .thenReturn(TrinaGridSelectingMode.disabled);

        action.execute(keyEvent: enterKeyEvent, stateManager: stateManager);

        verifyNever(stateManager.clearCurrentSelecting());
        verifyNever(stateManager.handleOnSelected());
      });

      test(
          'when both selectedCells and selectedRows are empty, '
          'it should not call clearCurrentSelecting and handleOnSelected', () {
        when(stateManager.selectedCells).thenReturn([]);
        when(stateManager.selectedRows).thenReturn([]);

        action.execute(keyEvent: enterKeyEvent, stateManager: stateManager);

        verifyNever(stateManager.clearCurrentSelecting());
        verifyNever(stateManager.handleOnSelected());
      });
    });

    group('enterKeyAction configurations', () {
      test('should toggle editing when enterKeyAction is toggleEditing', () {
        final config = TrinaGridConfiguration(
          enterKeyAction: TrinaGridEnterKeyAction.toggleEditing,
        );
        when(stateManager.configuration).thenReturn(config);

        action.execute(keyEvent: enterKeyEvent, stateManager: stateManager);

        verify(stateManager.toggleEditing(notify: false)).called(1);
      });

      test('should move cell down when enterKeyAction is editingAndMoveDown',
          () {
        final config = TrinaGridConfiguration(
          enterKeyAction: TrinaGridEnterKeyAction.editingAndMoveDown,
        );
        when(stateManager.configuration).thenReturn(config);
        when(stateManager.isEditing).thenReturn(true);

        action.execute(keyEvent: enterKeyEvent, stateManager: stateManager);

        verify(
          stateManager.moveCurrentCell(TrinaMoveDirection.down, notify: false),
        ).called(1);
      });
    });
  });
}
