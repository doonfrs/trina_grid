import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trina_grid/trina_grid.dart';

import '../../helper/row_helper.dart';

void main() {
  group('checkReadOnly prevents keyboard editing', () {
    late List<TrinaColumn> columns;
    late List<TrinaRow> rows;
    late TrinaGridStateManager stateManager;

    buildGrid(
      WidgetTester tester, {
      required TrinaColumnCheckReadOnly checkReadOnly,
    }) async {
      columns = [
        TrinaColumn(
          title: 'editable',
          field: 'editable',
          type: TrinaColumnType.text(),
        ),
        TrinaColumn(
          title: 'conditionalReadOnly',
          field: 'conditionalReadOnly',
          type: TrinaColumnType.text(),
          checkReadOnly: checkReadOnly,
        ),
      ];

      rows = RowHelper.count(3, columns);

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
      'Cell with checkReadOnly returning true should not enter editing mode '
      'when a character key is pressed',
      (tester) async {
        await buildGrid(tester, checkReadOnly: (row, cell) => true);

        // Tap on the checkReadOnly column cell
        await tester.tap(find.text('conditionalReadOnly value 0'));
        await tester.pumpAndSettle();

        expect(stateManager.isEditing, false);
        expect(stateManager.currentCell?.value, 'conditionalReadOnly value 0');

        // Try to type a character
        await tester.sendKeyEvent(LogicalKeyboardKey.keyA);
        await tester.pumpAndSettle();

        // Should NOT enter editing mode
        expect(stateManager.isEditing, false);
      },
    );

    testWidgets(
      'Cell with checkReadOnly returning false should enter editing mode '
      'when a character key is pressed',
      (tester) async {
        await buildGrid(tester, checkReadOnly: (row, cell) => false);

        // Tap on the checkReadOnly column cell
        await tester.tap(find.text('conditionalReadOnly value 0'));
        await tester.pumpAndSettle();

        expect(stateManager.isEditing, false);

        // Type a character
        await tester.sendKeyEvent(LogicalKeyboardKey.keyA);
        await tester.pumpAndSettle();

        // Should enter editing mode
        expect(stateManager.isEditing, true);
      },
    );

    testWidgets(
      'checkReadOnly that depends on row index should correctly allow/block '
      'editing per row',
      (tester) async {
        // Only row at sortIdx 0 is read-only
        await buildGrid(tester, checkReadOnly: (row, cell) => row.sortIdx == 0);

        // Tap on first row (read-only) checkReadOnly column
        await tester.tap(find.text('conditionalReadOnly value 0'));
        await tester.pumpAndSettle();

        expect(stateManager.isEditing, false);

        // Try to type
        await tester.sendKeyEvent(LogicalKeyboardKey.keyA);
        await tester.pumpAndSettle();

        // Should NOT enter editing mode for row 0
        expect(stateManager.isEditing, false);

        // Now tap on second row (not read-only) checkReadOnly column
        await tester.tap(find.text('conditionalReadOnly value 1'));
        await tester.pumpAndSettle();

        expect(stateManager.isEditing, false);

        // Type a character
        await tester.sendKeyEvent(LogicalKeyboardKey.keyB);
        await tester.pumpAndSettle();

        // Should enter editing mode for row 1
        expect(stateManager.isEditing, true);
      },
    );

    testWidgets(
      'Static readOnly column should still prevent keyboard editing',
      (tester) async {
        columns = [
          TrinaColumn(
            title: 'staticReadOnly',
            field: 'staticReadOnly',
            type: TrinaColumnType.text(),
            readOnly: true,
          ),
          TrinaColumn(
            title: 'editable',
            field: 'editable',
            type: TrinaColumnType.text(),
          ),
        ];

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

        // Tap on static readOnly column cell
        await tester.tap(find.text('staticReadOnly value 0'));
        await tester.pumpAndSettle();

        expect(stateManager.isEditing, false);

        // Try to type
        await tester.sendKeyEvent(LogicalKeyboardKey.keyA);
        await tester.pumpAndSettle();

        // Should NOT enter editing mode
        expect(stateManager.isEditing, false);
      },
    );
  });
}
