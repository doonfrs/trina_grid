import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trina_grid/trina_grid.dart';

/// Regression tests for issue #423.
///
/// The cell editors and the filter row are Material widgets, so they assert a
/// [Material] ancestor. Apps built on the standalone material_ui package have
/// none of the SDK type (their Material is a different class), so the grid
/// must provide one itself when the host has none.
void main() {
  late TrinaGridStateManager stateManager;

  Widget buildGrid() {
    return TrinaGrid(
      columns: [
        TrinaColumn(title: 'Name', field: 'name', type: TrinaColumnType.text()),
      ],
      rows: [
        TrinaRow(cells: {'name': TrinaCell(value: 'value')}),
      ],
      onLoaded: (event) => stateManager = event.stateManager,
    );
  }

  Finder gridMaterial() {
    return find.descendant(
      of: find.byType(TrinaGrid),
      matching: find.byWidgetPredicate(
        (widget) =>
            widget is Material && widget.type == MaterialType.transparency,
      ),
    );
  }

  group('Material ancestor (#423)', () {
    testWidgets('the filter row builds without a host Material', (
      tester,
    ) async {
      await tester.pumpWidget(MaterialApp(home: buildGrid()));

      stateManager.setShowColumnFilter(true);
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('a cell can be edited without a host Material', (tester) async {
      await tester.pumpWidget(MaterialApp(home: buildGrid()));

      stateManager.setCurrentCell(stateManager.rows.first.cells['name'], 0);
      stateManager.setEditing(true);
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('the provided Material keeps the ambient text style', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DefaultTextStyle(
            style: const TextStyle(fontSize: 31),
            child: buildGrid(),
          ),
        ),
      );

      final material = tester.widget<Material>(gridMaterial().first);
      expect(material.textStyle?.fontSize, 31);
    });

    testWidgets('no Material is added when the host provides one', (
      tester,
    ) async {
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: buildGrid())));

      expect(gridMaterial(), findsNothing);
    });
  });
}
