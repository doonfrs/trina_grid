import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trina_grid/trina_grid.dart';

import '../../helper/column_helper.dart';
import '../../helper/trina_widget_test_helper.dart';
import '../../helper/row_helper.dart';

void main() {
  group('F2 Key Test', () {
    List<TrinaColumn> columns;

    List<TrinaRow> rows;

    TrinaGridStateManager? stateManager;

    final withTheCellSelected = TrinaWidgetTestHelper(
      'With the cell selected',
      (tester) async {
        columns = [...ColumnHelper.textColumn('header', count: 10)];

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
              ),
            ),
          ),
        );

        await tester.pump();

        await tester.tap(find.text('header0 value 0'));
      },
    );

    withTheCellSelected.test(
      'When F2 is pressed in non-editing state, cell should enter edit mode',
      (tester) async {
        expect(stateManager!.isEditing, false);

        await tester.sendKeyEvent(LogicalKeyboardKey.f2);

        expect(stateManager!.isEditing, true);
      },
    );
  });
}
