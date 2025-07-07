import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trina_grid/trina_grid.dart';

import '../../helper/column_helper.dart';
import '../../helper/trina_widget_test_helper.dart';
import '../../helper/row_helper.dart';
import '../../mock/mock_methods.dart';

void main() {
  group('ESC Key Test', () {
    List<TrinaColumn> columns;

    List<TrinaRow> rows;

    TrinaGridStateManager? stateManager;

    late MockMethods mock = MockMethods();

    setUp(() {
      mock = MockMethods();
    });

    withTheCellSelected([TrinaGridMode mode = TrinaGridMode.normal]) {
      return TrinaWidgetTestHelper(
        '0, 0 cell is selected',
        (tester) async {
          columns = [
            ...ColumnHelper.textColumn('header', count: 10),
          ];

          rows = RowHelper.count(10, columns);

          await tester.pumpWidget(
            MaterialApp(
              home: Material(
                child: TrinaGrid(
                  columns: columns,
                  rows: rows,
                  onLoaded: (TrinaGridOnLoadedEvent event) {
                    stateManager = event.stateManager;
                  },
                  mode: mode,
                  onSelected: mock.oneParamReturnVoid,
                ),
              ),
            ),
          );

          await tester.pump();

          await tester.tap(find.text('header0 value 0'));
        },
      );
    }

    withTheCellSelected(TrinaGridMode.normal).test(
      'When the grid is in editing state, '
      'editing should be set to false.',
      (tester) async {
        expect(stateManager!.mode.isNormal, isTrue);

        stateManager!.setEditing(true);

        await tester.sendKeyEvent(LogicalKeyboardKey.escape);

        expect(stateManager!.isEditing, false);
      },
    );

    withTheCellSelected().test(
      'When the cell value has changed, '
      'the cell value should be restored to its original value.',
      (tester) async {
        expect(stateManager!.currentCell!.value, 'header0 value 0');

        await tester.sendKeyEvent(LogicalKeyboardKey.keyA);

        await tester.pumpAndSettle();

        expect(stateManager!.textEditingController!.text, 'a');

        await tester.sendKeyEvent(LogicalKeyboardKey.escape);

        expect(stateManager!.currentCell!.value, isNot('a'));

        expect(stateManager!.currentCell!.value, 'header0 value 0');
      },
    );
  });
}
