import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trina_grid/trina_grid.dart';

import '../../helper/row_helper.dart';

void main() {
  group('refreshReadOnly', () {
    late List<TrinaColumn> columns;
    late List<TrinaRow> rows;
    late TrinaGridStateManager stateManager;

    const readOnlyColor = Color(0xFFFF0000);
    const defaultColor = Color(0xFF00FF00);

    /// [checkReadOnly] intentionally depends on state outside the row, which is
    /// the case the memoized read-only styling cannot detect on its own.
    buildGrid(WidgetTester tester, bool Function() locked) async {
      columns = [
        TrinaColumn(
          title: 'column',
          field: 'column',
          type: TrinaColumnType.text(),
          checkReadOnly: (row, cell) => locked(),
        ),
      ];

      rows = RowHelper.count(2, columns);

      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: TrinaGrid(
              columns: columns,
              rows: rows,
              configuration: const TrinaGridConfiguration(
                style: TrinaGridStyleConfig(
                  cellReadonlyColor: readOnlyColor,
                  cellDefaultColor: defaultColor,
                ),
              ),
              onLoaded: (TrinaGridOnLoadedEvent event) {
                stateManager = event.stateManager;
                stateManager.setKeepFocus(true);
              },
            ),
          ),
        ),
      );
    }

    /// The background color of the cell holding [text].
    Color? cellColor(WidgetTester tester, String text) {
      final decoratedBox = tester.widget<DecoratedBox>(
        find
            .ancestor(of: find.text(text), matching: find.byType(DecoratedBox))
            .first,
      );

      return (decoratedBox.decoration as BoxDecoration).color;
    }

    testWidgets(
      'Calling refreshReadOnly should re-evaluate the read-only styling '
      'when checkReadOnly depends on state outside the row',
      (tester) async {
        bool locked = false;

        await buildGrid(tester, () => locked);

        expect(cellColor(tester, 'column value 1'), defaultColor);

        // Without the refresh the memoized styling stays stale, because
        // neither the cell value nor the row version changed.
        locked = true;
        stateManager.notifyListeners();
        await tester.pumpAndSettle();

        expect(cellColor(tester, 'column value 1'), defaultColor);

        stateManager.refreshReadOnly();
        await tester.pumpAndSettle();

        expect(cellColor(tester, 'column value 1'), readOnlyColor);

        // And back again.
        locked = false;
        stateManager.refreshReadOnly();
        await tester.pumpAndSettle();

        expect(cellColor(tester, 'column value 1'), defaultColor);
      },
    );

    testWidgets('Read-only enforcement should be live without any refresh', (
      tester,
    ) async {
      bool locked = false;

      await buildGrid(tester, () => locked);

      await tester.tap(find.text('column value 0'));
      await tester.pumpAndSettle();

      // Editable while unlocked.
      await tester.sendKeyEvent(LogicalKeyboardKey.keyA);
      await tester.pumpAndSettle();
      expect(stateManager.isEditing, true);

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(stateManager.isEditing, false);

      // Blocked as soon as the callback flips, with no refresh call.
      locked = true;

      await tester.sendKeyEvent(LogicalKeyboardKey.keyB);
      await tester.pumpAndSettle();
      expect(stateManager.isEditing, false);
    });
  });
}
