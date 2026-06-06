import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trina_grid/src/ui/columns/trina_column_title.dart';
import 'package:trina_grid/trina_grid.dart';

void main() {
  testWidgets(
    'Tapping the sort icon toggles the column sort direction (#379)',
    (tester) async {
      // A sortable column with no context menu and no resize handle: once the
      // column is sorted, the only header icon is the sort indicator, which
      // must itself be clickable so narrow columns can still be re-sorted.
      final column = TrinaColumn(
        title: 'ID',
        field: 'id',
        enableContextMenu: false,
        enableDropToResize: false,
        type: TrinaColumnType.number(),
      );

      late TrinaGridStateManager stateManager;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TrinaGrid(
              columns: [column],
              rows: [
                TrinaRow(cells: {'id': TrinaCell(value: 1)}),
                TrinaRow(cells: {'id': TrinaCell(value: 2)}),
                TrinaRow(cells: {'id': TrinaCell(value: 3)}),
              ],
              onLoaded: (event) => stateManager = event.stateManager,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // No sort yet, so the header shows no icon.
      expect(column.sort.isNone, isTrue);

      // Sort once so the ascending icon appears in the header.
      stateManager.toggleSortColumn(column);
      await tester.pumpAndSettle();
      expect(column.sort, TrinaColumnSort.ascending);

      // The icon is now visible; tapping it should toggle to descending
      // rather than be an inert button.
      final iconButton = find.descendant(
        of: find.byType(TrinaColumnTitle),
        matching: find.byType(IconButton),
      );
      expect(iconButton, findsOneWidget);

      await tester.tap(iconButton);
      await tester.pumpAndSettle();

      expect(column.sort, TrinaColumnSort.descending);
    },
  );

  testWidgets('Sort icon button is disabled when the context menu is enabled', (
    tester,
  ) async {
    // With the context menu enabled the tap is handled by the menu Listener,
    // so the IconButton itself must stay disabled (no enabled no-op button).
    final column = TrinaColumn(
      title: 'ID',
      field: 'id',
      type: TrinaColumnType.number(),
    );

    late TrinaGridStateManager stateManager;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TrinaGrid(
            columns: [column],
            rows: [
              TrinaRow(cells: {'id': TrinaCell(value: 1)}),
            ],
            onLoaded: (event) => stateManager = event.stateManager,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Sort so the icon is rendered.
    stateManager.toggleSortColumn(column);
    await tester.pumpAndSettle();

    final iconButton = tester.widget<IconButton>(
      find.descendant(
        of: find.byType(TrinaColumnTitle),
        matching: find.byType(IconButton),
      ),
    );

    expect(iconButton.onPressed, isNull);
  });
}
