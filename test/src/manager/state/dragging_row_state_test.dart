import 'package:collection/collection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:trina_grid/trina_grid.dart';

import '../../../helper/column_helper.dart';
import '../../../helper/row_helper.dart';
import '../../../mock/mock_methods.dart';
import '../../../mock/shared_mocks.mocks.dart';

void main() {
  late List<TrinaColumn> columns;

  late List<TrinaRow> rows;

  late TrinaGridStateManager stateManager;

  MockMethods? listener;

  setUp(() {
    columns = [...ColumnHelper.textColumn('column', count: 1, width: 150)];

    rows = RowHelper.count(10, columns);

    stateManager = TrinaGridStateManager(
      columns: columns,
      rows: rows,
      gridFocusNode: MockFocusNode(),
      scroll: MockTrinaGridScrollController(),
    );

    listener = MockMethods();

    stateManager.addListener(listener!.noParamReturnVoid);
  });

  group('setIsDraggingRow', () {
    test('When the new isDragging value is the same as the current value, '
        'notifyListeners should not be called', () {
      // given
      expect(stateManager.isDraggingRow, isFalse);

      // when
      stateManager.setIsDraggingRow(false);

      // then
      verifyNever(listener!.noParamReturnVoid());
    });

    test('When the new isDragging value is different from the current value, '
        'notifyListeners should be called', () {
      // given
      expect(stateManager.isDraggingRow, isFalse);

      // when
      stateManager.setIsDraggingRow(true);

      // then
      expect(stateManager.isDraggingRow, isTrue);
      verify(listener!.noParamReturnVoid()).called(1);
    });

    test('When the new isDragging value is different but notify is false, '
        'notifyListeners should not be called', () {
      // given
      expect(stateManager.isDraggingRow, isFalse);

      // when
      stateManager.setIsDraggingRow(true, notify: false);

      // then
      expect(stateManager.isDraggingRow, isTrue);
      verifyNever(listener!.noParamReturnVoid());
    });

    test(
      'When setIsDraggingRow(false) is called, dragRows should NOT be cleared '
      'so they remain available for onAccept handlers (issue #225)',
      () {
        // given - simulate starting a drag with multiple rows selected
        stateManager.setIsDraggingRow(true, notify: false);
        stateManager.setDragRows([rows[1], rows[2]], notify: false);

        expect(stateManager.isDraggingRow, isTrue);
        expect(stateManager.dragRows.length, 2);

        // when - drag ends (pointer up)
        stateManager.setIsDraggingRow(false);

        // then - dragRows should still be available for onAccept to use
        expect(stateManager.isDraggingRow, isFalse);
        expect(stateManager.dragRows.length, 2);
        expect(stateManager.dragRows[0].key, rows[1].key);
        expect(stateManager.dragRows[1].key, rows[2].key);
      },
    );

    test(
      'When setIsDraggingRow(false) is called, dragTargetRowIdx should be cleared',
      () {
        // given
        stateManager.setIsDraggingRow(true, notify: false);
        stateManager.setDragTargetRowIdx(3, notify: false);

        expect(stateManager.isDraggingRow, isTrue);
        expect(stateManager.dragTargetRowIdx, 3);

        // when
        stateManager.setIsDraggingRow(false);

        // then - dragTargetRowIdx should be cleared
        expect(stateManager.dragTargetRowIdx, isNull);
      },
    );
  });

  group('setDragRows', () {
    test('The rows passed as arguments should be set in dragRows', () {
      // given
      expect(stateManager.dragRows, isEmpty);

      // when
      stateManager.setDragRows([rows[1], rows[2]]);

      // then
      expect(stateManager.dragRows.length, 2);
      expect(stateManager.dragRows[0].key, rows[1].key);
      expect(stateManager.dragRows[1].key, rows[2].key);
      verify(listener!.noParamReturnVoid()).called(1);
    });

    test('The rows passed as arguments should be set in dragRows, '
        'but when notify is false, notifyListeners should not be called', () {
      // given
      expect(stateManager.dragRows, isEmpty);

      // when
      stateManager.setDragRows([rows[1], rows[2]], notify: false);

      // then
      expect(stateManager.dragRows.length, 2);
      expect(stateManager.dragRows[0].key, rows[1].key);
      expect(stateManager.dragRows[1].key, rows[2].key);
      verifyNever(listener!.noParamReturnVoid());
    });
  });

  group('setDragTargetRowIdx', () {
    test('When the rowIdx passed as argument is the same as dragTargetRowIdx, '
        'notifyListeners should not be called', () {
      // given
      stateManager.setDragTargetRowIdx(1);
      expect(stateManager.dragTargetRowIdx, 1);

      // when
      clearInteractions(listener);
      stateManager.setDragTargetRowIdx(1);

      // then
      verifyNever(listener!.noParamReturnVoid());
    });

    test(
      'When the rowIdx passed as argument is different from dragTargetRowIdx, '
      'notifyListeners should be called',
      () {
        // given
        stateManager.setDragTargetRowIdx(1);
        expect(stateManager.dragTargetRowIdx, 1);

        // when
        clearInteractions(listener);
        stateManager.setDragTargetRowIdx(2);

        // then
        expect(stateManager.dragTargetRowIdx, 2);
        verify(listener!.noParamReturnVoid()).called(1);
      },
    );

    test(
      'When the rowIdx passed as argument is different from dragTargetRowIdx, '
      'but notify is false, notifyListeners should not be called',
      () {
        // given
        stateManager.setDragTargetRowIdx(1);
        expect(stateManager.dragTargetRowIdx, 1);

        // when
        clearInteractions(listener);
        stateManager.setDragTargetRowIdx(2, notify: false);

        // then
        expect(stateManager.dragTargetRowIdx, 2);
        verifyNever(listener!.noParamReturnVoid());
      },
    );
  });

  group('isRowIdxDragTarget', () {
    const int givenDragTargetRowIdx = 3;
    late List<TrinaRow> givenDragRows;

    setUp(() {
      givenDragRows = [rows[5], rows[6]];
      stateManager.setDragTargetRowIdx(givenDragTargetRowIdx);
      stateManager.setDragRows(givenDragRows);
    });

    test('When rowIdx is null, should return false', () {
      expect(stateManager.isRowIdxDragTarget(null), isFalse);
    });

    test('When rowIdx is less than the given rowIdx, should return false', () {
      expect(
        stateManager.isRowIdxDragTarget(givenDragTargetRowIdx - 1),
        isFalse,
      );
    });

    test('When rowIdx is greater than the given rowIdx + dragRows.length, '
        'should return false', () {
      expect(
        stateManager.isRowIdxDragTarget(
          givenDragTargetRowIdx + givenDragRows.length + 1,
        ),
        isFalse,
      );
    });

    test('When rowIdx is equal to the given rowIdx, should return true', () {
      expect(stateManager.isRowIdxDragTarget(givenDragTargetRowIdx), isTrue);
    });

    test('When rowIdx is greater than the given rowIdx and less than '
        'the given rowIdx + dragRows.length, should return true', () {
      const rowIdx = givenDragTargetRowIdx + 1;

      expect(rowIdx, greaterThan(givenDragTargetRowIdx));
      expect(rowIdx, lessThan(rowIdx + givenDragRows.length));

      expect(stateManager.isRowIdxDragTarget(rowIdx), isTrue);
    });
  });

  group('isRowIdxTopDragTarget', () {
    const int givenDragTargetRowIdx = 3;
    List<TrinaRow> givenDragRows;

    setUp(() {
      givenDragRows = [rows[5], rows[6]];
      stateManager.setDragTargetRowIdx(givenDragTargetRowIdx);
      stateManager.setDragRows(givenDragRows);
    });

    test('When rowIdx is null, should return false', () {
      expect(stateManager.isRowIdxTopDragTarget(null), isFalse);
    });

    test(
      'When rowIdx is not equal to dragTargetRowIdx, should return false',
      () {
        expect(stateManager.dragTargetRowIdx, isNot(2));
        expect(stateManager.isRowIdxTopDragTarget(2), isFalse);
      },
    );

    test('When rowIdx is equal to dragTargetRowIdx, should return true', () {
      expect(stateManager.dragTargetRowIdx, 3);
      expect(stateManager.isRowIdxTopDragTarget(3), isTrue);
    });
  });

  group('isRowIdxBottomDragTarget', () {
    const int givenDragTargetRowIdx = 3;
    List<TrinaRow> givenDragRows;

    setUp(() {
      givenDragRows = [rows[5], rows[6]];
      stateManager.setDragTargetRowIdx(givenDragTargetRowIdx);
      stateManager.setDragRows(givenDragRows);
    });

    test('When rowIdx is null, should return false', () {
      expect(stateManager.isRowIdxBottomDragTarget(null), isFalse);
    });

    test('When rowIdx is not equal to dragTargetRowIdx + dragRows.length - 1, '
        'should return false', () {
      const int rowIdx = 2;

      expect(
        rowIdx,
        isNot(
          stateManager.dragTargetRowIdx! + stateManager.dragRows.length - 1,
        ),
      );

      expect(stateManager.isRowIdxBottomDragTarget(rowIdx), isFalse);
    });

    test('When rowIdx is equal to dragTargetRowIdx + dragRows.length - 1, '
        'should return true', () {
      const int rowIdx = 4;

      expect(
        rowIdx,
        stateManager.dragTargetRowIdx! + stateManager.dragRows.length - 1,
      );

      expect(stateManager.isRowIdxBottomDragTarget(rowIdx), isTrue);
    });
  });

  group('isRowBeingDragged', () {
    const int givenDragTargetRowIdx = 3;
    List<TrinaRow> givenDragRows;

    setDrag() {
      givenDragRows = [rows[5], rows[6]];
      stateManager.setDragTargetRowIdx(givenDragTargetRowIdx);
      stateManager.setDragRows(givenDragRows);
    }

    setUp(setDrag);

    test('When rowKey is null, should return false', () {
      expect(stateManager.isRowBeingDragged(null), isFalse);
    });

    test('When isDragging is true and rowKey is not in dragRows, '
        'should return false', () {
      stateManager.setIsDraggingRow(true);
      setDrag();

      expect(stateManager.isDraggingRow, isTrue);

      expect(stateManager.isRowBeingDragged(rows[0].key), isFalse);
    });

    test('When rowKey is in dragRows, should return true', () {
      stateManager.setIsDraggingRow(true);
      setDrag();

      expect(stateManager.isDraggingRow, isTrue);

      expect(stateManager.isRowBeingDragged(rows[5].key), isTrue);
      expect(stateManager.isRowBeingDragged(rows[6].key), isTrue);
    });

    test('When rowKey is in dragRows but isDraggingRow is false, '
        'should return false', () {
      stateManager.setIsDraggingRow(false);
      setDrag();

      expect(stateManager.isDraggingRow, isFalse);
      expect(
        stateManager.dragRows.firstWhereOrNull(
          (element) => element.key == rows[5].key,
        ),
        isNot(isNull),
      );
      expect(
        stateManager.dragRows.firstWhereOrNull(
          (element) => element.key == rows[6].key,
        ),
        isNot(isNull),
      );

      expect(stateManager.isRowBeingDragged(rows[5].key), isFalse);
      expect(stateManager.isRowBeingDragged(rows[6].key), isFalse);
    });
  });
}
