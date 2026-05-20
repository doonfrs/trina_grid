import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trina_grid/trina_grid.dart';

import '../../helper/column_helper.dart';
import '../../helper/row_helper.dart';

/// Regression test for https://github.com/doonfrs/trina_grid/issues/376
///
/// The filter popup is opened via `showDialog`, so it does not inherit a
/// `ShadTheme` from the host app. The filter-type column is a select cell
/// whose popup reads `ShadTheme.of(context)`; without a fallback, opening
/// it inside the filter popup crashes with "No ShadTheme ancestor".
void main() {
  late TrinaGridStateManager stateManager;

  Widget buildGrid({
    required List<TrinaColumn> columns,
    required List<TrinaRow> rows,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: TrinaGrid(
          columns: columns,
          rows: rows,
          onLoaded: (e) {
            stateManager = e.stateManager;
          },
        ),
      ),
    );
  }

  testWidgets(
    'Opening filter popup and changing filter type does not crash with missing ShadTheme',
    (tester) async {
      final columns = ColumnHelper.textColumn('column');
      final rows = RowHelper.count(3, columns);

      await tester.pumpWidget(buildGrid(columns: columns, rows: rows));
      await tester.pumpAndSettle();

      stateManager.showFilterPopup(
        tester.element(find.byType(TrinaGrid)),
        calledColumn: columns.first,
      );
      await tester.pumpAndSettle();

      // The popup opens with one filter row whose default type is "Contains".
      final containsFinder = find.text(const TrinaFilterTypeContains().title);
      expect(containsFinder, findsOneWidget);

      // Make the type cell current, enter editing, then open the select menu.
      // Filter columns do not enable auto-editing, so this requires F2 to
      // start editing and a second F2 to open the popup.
      await tester.tap(containsFinder);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.f2);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.f2);
      await tester.pumpAndSettle();

      // The select popup must render and must not have thrown a
      // missing-ShadTheme error while building.
      expect(find.byType(MenuAnchor), findsWidgets);
      expect(tester.takeException(), isNull);

      final equalsItem = find.widgetWithText(
        MenuItemButton,
        const TrinaFilterTypeEquals().title,
      );
      expect(equalsItem, findsOneWidget);

      await tester.tap(equalsItem);
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    },
  );
}
