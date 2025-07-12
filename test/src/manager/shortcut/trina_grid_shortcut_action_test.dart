import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:trina_grid/trina_grid.dart';

import '../../../mock/shared_mocks.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('handleOnSelectedIfNotPopup', () {
    MockTrinaGridStateManager stateManager = MockTrinaGridStateManager();
    final TrinaCell currentCell = TrinaCell(value: 'value');
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
    getTrinaKeyEvent(KeyEvent keyEvent) {
      return TrinaKeyManagerEvent(
        focusNode: stateManager.gridFocusNode,
        event: keyEvent,
      );
    }

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
}
