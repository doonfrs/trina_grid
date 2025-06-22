import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:trina_grid/trina_grid.dart';

import '../../helper/column_helper.dart';
import '../../helper/trina_widget_test_helper.dart';
import '../../helper/row_helper.dart';
import '../../matcher/trina_object_matcher.dart';
import '../../mock/mock_methods.dart';

void main() {
  late TrinaGridStateManager stateManager;

  final MockMethods mock = MockMethods();

  setUp(() {
    reset(mock);
  });

  buildGrid({
    int numberOfRows = 10,
    void Function(TrinaGridOnLoadedEvent)? onLoaded,
    void Function(TrinaGridOnSelectedEvent)? onSelected,
  }) {
    // given
    final columns = ColumnHelper.textColumn('column');
    final rows = RowHelper.count(numberOfRows, columns);

    return TrinaWidgetTestHelper(
      'build with selecting rows.',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Material(
              child: TrinaGrid(
                mode: TrinaGridMode.selectWithOneTap,
                columns: columns,
                rows: rows,
                onLoaded: (TrinaGridOnLoadedEvent event) {
                  stateManager = event.stateManager;
                  if (onLoaded != null) onLoaded(event);
                },
                onSelected: onSelected,
              ),
            ),
          ),
        );
      },
    );
  }

  buildGrid().test(
    'When selectWithOneTap mode is executed, the first cell should be focused',
    (tester) async {
      expect(stateManager.currentCell, isNot(null));
      expect(stateManager.currentCellPosition?.rowIdx, 0);
      expect(stateManager.currentCellPosition?.columnIdx, 0);
    },
  );

  buildGrid(numberOfRows: 0).test(
    'When there are no rows, no error should occur and the grid should be focused',
    (tester) async {
      expect(stateManager.refRows.length, 0);
      expect(stateManager.currentCell, null);
      expect(stateManager.hasFocus, true);
    },
  );

  buildGrid(
    onLoaded: (e) => e.stateManager.setCurrentCell(
      e.stateManager.refRows[1].cells['column0'],
      1,
    ),
  ).test(
    'When selected in onLoaded, the second cell should be focused',
    (tester) async {
      expect(stateManager.currentCell, isNot(null));
      expect(stateManager.currentCellPosition?.rowIdx, 1);
      expect(stateManager.currentCellPosition?.columnIdx, 0);
    },
  );

  buildGrid(onSelected: mock.oneParamReturnVoid<TrinaGridOnSelectedEvent>).test(
    'When the first cell is selected, '
    'the first cell should be selected',
    (tester) async {
      expect(stateManager.currentCellPosition?.rowIdx, 0);

      await tester.tap(find.text('column0 value 0'));
      await tester.pump();

      verify(
        mock.oneParamReturnVoid(
            argThat(TrinaObjectMatcher<TrinaGridOnSelectedEvent>(rule: (event) {
          return event.row?.key == stateManager.refRows.first.key &&
              event.rowIdx == 0 &&
              event.cell?.key ==
                  stateManager.refRows.first.cells['column0']!.key &&
              event.selectedRows == null;
        }))),
      ).called(1);

      // In select mode, currentSelectingRows is not added.
      expect(stateManager.currentSelectingRows.length, 0);
    },
  );

  buildGrid(onSelected: mock.oneParamReturnVoid<TrinaGridOnSelectedEvent>).test(
    'When the second cell is selected, '
    'the second cell should be selected',
    (tester) async {
      expect(stateManager.currentCellPosition?.rowIdx, 0);

      await tester.tap(find.text('column0 value 1'));
      await tester.pump();

      verify(
        mock.oneParamReturnVoid(
            argThat(TrinaObjectMatcher<TrinaGridOnSelectedEvent>(rule: (event) {
          return event.row?.key == stateManager.refRows[1].key &&
              event.rowIdx == 1 &&
              event.cell?.key ==
                  stateManager.refRows[1].cells['column0']!.key &&
              event.selectedRows == null;
        }))),
      ).called(1);

      // In select mode, currentSelectingRows is not added.
      expect(stateManager.currentSelectingRows.length, 0);
    },
  );

  buildGrid(onSelected: mock.oneParamReturnVoid<TrinaGridOnSelectedEvent>).test(
    'When the third cell is selected, '
    'the third cell should be selected',
    (tester) async {
      expect(stateManager.currentCellPosition?.rowIdx, 0);

      await tester.sendKeyDownEvent(LogicalKeyboardKey.shift);
      await tester.tap(find.text('column0 value 2'));
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shift);
      await tester.pump();

      verify(
        mock.oneParamReturnVoid(
            argThat(TrinaObjectMatcher<TrinaGridOnSelectedEvent>(rule: (event) {
          return event.row?.key == stateManager.refRows[2].key &&
              event.rowIdx == 2 &&
              event.cell?.key ==
                  stateManager.refRows[2].cells['column0']!.key &&
              event.selectedRows == null;
        }))),
      ).called(1);

      // In select mode, currentSelectingRows is not added.
      expect(stateManager.currentSelectingRows.length, 0);
    },
  );

  buildGrid(onSelected: mock.oneParamReturnVoid<TrinaGridOnSelectedEvent>).test(
    'When the third cell is selected, '
    'the third cell should be selected',
    (tester) async {
      expect(stateManager.currentCellPosition?.rowIdx, 0);

      await tester.sendKeyDownEvent(LogicalKeyboardKey.control);
      await tester.tap(find.text('column0 value 2'));
      await tester.sendKeyUpEvent(LogicalKeyboardKey.control);
      await tester.pump();

      verify(
        mock.oneParamReturnVoid(
            argThat(TrinaObjectMatcher<TrinaGridOnSelectedEvent>(rule: (event) {
          return event.row?.key == stateManager.refRows[2].key &&
              event.rowIdx == 2 &&
              event.cell?.key ==
                  stateManager.refRows[2].cells['column0']!.key &&
              event.selectedRows == null;
        }))),
      ).called(1);

      // In select mode, currentSelectingRows is not added.
      expect(stateManager.currentSelectingRows.length, 0);
    },
  );

  buildGrid(onSelected: mock.oneParamReturnVoid<TrinaGridOnSelectedEvent>).test(
    'When the third cell is selected, '
    'the third cell should be selected',
    (tester) async {
      expect(stateManager.currentCellPosition?.rowIdx, 0);

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();

      verify(
        mock.oneParamReturnVoid(
            argThat(TrinaObjectMatcher<TrinaGridOnSelectedEvent>(rule: (event) {
          return event.row?.key == stateManager.refRows[2].key &&
              event.rowIdx == 2 &&
              event.cell?.key ==
                  stateManager.refRows[2].cells['column0']!.key &&
              event.selectedRows == null;
        }))),
      ).called(1);

      // In select mode, currentSelectingRows is not added.
      expect(stateManager.currentSelectingRows.length, 0);
    },
  );

  buildGrid(onSelected: mock.oneParamReturnVoid<TrinaGridOnSelectedEvent>).test(
    'When the third cell is selected, '
    'the third cell should be selected',
    (tester) async {
      expect(stateManager.currentCellPosition?.rowIdx, 0);

      await tester.sendKeyDownEvent(LogicalKeyboardKey.shift);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shift);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();

      expect(stateManager.currentCellPosition?.rowIdx, 0);

      verify(
        mock.oneParamReturnVoid(
            argThat(TrinaObjectMatcher<TrinaGridOnSelectedEvent>(rule: (event) {
          return event.row?.key == stateManager.refRows.first.key &&
              event.rowIdx == 0 &&
              event.cell?.key ==
                  stateManager.refRows.first.cells['column0']!.key &&
              event.selectedRows == null;
        }))),
      ).called(1);

      // In select mode, currentSelectingRows is not added.
      expect(stateManager.currentSelectingRows.length, 0);
    },
  );

  buildGrid(onSelected: mock.oneParamReturnVoid<TrinaGridOnSelectedEvent>).test(
    'When the first cell is selected, '
    'the first cell should be selected',
    (tester) async {
      expect(stateManager.currentCellPosition?.rowIdx, 0);

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();

      expect(stateManager.currentCellPosition?.rowIdx, 0);

      verify(
        mock.oneParamReturnVoid(
            argThat(TrinaObjectMatcher<TrinaGridOnSelectedEvent>(rule: (event) {
          return event.row == null &&
              event.rowIdx == null &&
              event.cell == null &&
              event.selectedRows == null;
        }))),
      ).called(1);

      // select mode does not add to currentSelectingRows
      expect(stateManager.currentSelectingRows.length, 0);
    },
  );
}
