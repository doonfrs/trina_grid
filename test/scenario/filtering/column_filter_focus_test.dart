import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:trina_grid/trina_grid.dart';
import 'package:trina_grid/src/ui/ui.dart';

void main() {
  late TrinaGridStateManager stateManager;

  Widget buildGrid({
    required List<TrinaColumn> columns,
    required List<TrinaRow> rows,
  }) {
    return MaterialApp(
      home: Material(
        child: TrinaGrid(
          columns: columns,
          rows: rows,
          onLoaded: (e) {
            e.stateManager.setShowColumnFilter(true);
            stateManager = e.stateManager;
          },
        ),
      ),
    );
  }

  Finder findFilterTextField() {
    return find.descendant(
      of: find.byType(TrinaColumnFilter),
      matching: find.byType(TextField),
    );
  }

  testWidgets(
    'Filter focus + character key should NOT enable editing',
    (tester) async {
      final columns = <TrinaColumn>[
        TrinaColumn(title: 'Text', field: 'text', type: TrinaColumnType.text()),
      ];
      final rows = <TrinaRow>[
        TrinaRow(cells: {'text': TrinaCell(value: 'Text value 0')}),
        TrinaRow(cells: {'text': TrinaCell(value: 'Text value 1')}),
      ];

      await tester.pumpWidget(buildGrid(columns: columns, rows: rows));
      await tester.pumpAndSettle();

      // Click a grid cell once to establish currentCell
      await tester.tap(find.text('Text value 0'));
      await tester.pumpAndSettle();

      // Focus the column filter TextField
      final filter = findFilterTextField();
      expect(filter, findsOneWidget);
      await tester.tap(filter);
      await tester.pumpAndSettle();

      // Attach keyboard and send a character key event
      await tester.showKeyboard(filter);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyA);
      await tester.pumpAndSettle();

      // Grid should NOT enter editing from a character key when filter has focus
      expect(stateManager.isEditing, isFalse);
    },
  );
}
