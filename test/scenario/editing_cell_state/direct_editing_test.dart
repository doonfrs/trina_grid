import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trina_grid/trina_grid.dart';

import '../../helper/column_helper.dart';
import '../../helper/row_helper.dart';

void main() {
  group('Direct Editing with keyboard', () {
    List<TrinaColumn> columns;

    late List<TrinaRow> rows;

    late TrinaGridStateManager stateManager;

    /// Builds A `TrinaGrid`
    buildGrid(WidgetTester tester) async {
      columns = ColumnHelper.textColumn('column', count: 2);

      rows = RowHelper.count(2, columns);

      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: TrinaGrid(
              columns: columns,
              rows: rows,
              onLoaded: (TrinaGridOnLoadedEvent event) {
                stateManager = event.stateManager;
                stateManager.setKeepFocus(true);
              },
            ),
          ),
        ),
      );
    }

    testWidgets(
      'When a character key is pressed, the cell should enter editing mode',
      (tester) async {
        await buildGrid(tester);

        // given
        // press on a cell to set it as current
        await tester.tap(find.text('column0 value 0'));
        await tester.pumpAndSettle();
        // The cell is not yet in editing mode, just has focus.
        expect(stateManager.isEditing, false);
        expect(stateManager.currentCell?.value, 'column0 value 0');

        // when
        await tester.sendKeyEvent(LogicalKeyboardKey.keyA);
        // We need to pump and settle to allow the Future.delayed to complete.
        await tester.pumpAndSettle();

        // then
        expect(stateManager.isEditing, true);
      },
    );
    testWidgets(
      'When a character key is pressed, '
      'the typed character should appear in the cell.',
      (tester) async {
        await buildGrid(tester);

        // given
        // press on a cell to set it as current
        await tester.tap(find.text('column0 value 0'));
        await tester.pumpAndSettle();

        // when
        await tester.sendKeyEvent(LogicalKeyboardKey.keyA);
        // We need to pump and settle to allow the Future.delayed to complete.
        await tester.pumpAndSettle();

        // assert text controller should contain the typed character.
        expect(stateManager.textEditingController!.text, 'a');
        // assert the displayed cell value is updated.
        expect(find.text('a'), findsOneWidget);
        // The underlying cell value should NOT have changed yet.
        expect(stateManager.currentCell?.value, 'column0 value 0');
      },
    );

    // This commented-out test fails due to a Flutter issue.
    // discussed in: https://github.com/flutter/flutter/issues/93873
    //
    // testWidgets(
    //     'When SHIFT + character is pressed, '
    //     'Then the cell value should be the character in uppercase.',
    //     (tester) async {
    //   await buildGrid(tester);

    //   // given
    //   // press on a cell to set it as current
    //   await tester.tap(find.text('column0 value 0'));
    //   await tester.pumpAndSettle();
    //   // The cell is not yet in editing mode, just has focus.
    //   expect(stateManager.isEditing, false);
    //   expect(stateManager.currentCell?.value, 'column0 value 0');

    //   // when
    //   // Pressing 'A' should trigger the character handling logic.
    //   await simulateKeyDownEvent(LogicalKeyboardKey.shiftLeft);
    //   await tester.sendKeyEvent(LogicalKeyboardKey.keyA);
    //   await simulateKeyUpEvent(LogicalKeyboardKey.shiftLeft);

    //   // // We need to pump and settle to allow the Future.delayed to complete.
    //   await tester.pumpAndSettle();

    //   // then
    //   // assert text controller should contain the typed character.
    //   expect(stateManager.isEditing, true);
    //   expect(stateManager.textEditingController!.text, 'A');
    //   // The underlying cell value should NOT have changed yet.
    //   expect(stateManager.currentCell?.value, 'column0 value 0');
    // });
  });
}
