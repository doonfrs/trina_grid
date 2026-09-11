import 'package:flutter/material.dart';
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
            stateManager = e.stateManager;
            stateManager.setShowColumnFilter(true);
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

  Future<void> tapAndEnterTextColumnFilter(
    WidgetTester tester,
    String? enterText,
  ) async {
    final textField = findFilterTextField();

    // To receive focus, tap the text box twice.
    await tester.tap(textField);
    await tester.tap(textField);

    if (enterText != null) {
      await tester.enterText(textField, enterText);
    }
  }

  List<dynamic> filteredValues() {
    return stateManager.refRows.map((e) => e.cells['column']!.value).toList();
  }

  List<TrinaRow> buildRows() {
    return [
      TrinaRow(cells: {'column': TrinaCell(value: true)}),
      TrinaRow(cells: {'column': TrinaCell(value: false)}),
      TrinaRow(cells: {'column': TrinaCell(value: true)}),
      TrinaRow(cells: {'column': TrinaCell(value: false)}),
      TrinaRow(cells: {'column': TrinaCell(value: false)}),
    ];
  }

  group('Boolean Column Filtering Test', () {
    testWidgets('When filtering with the default trueText "Yes", '
        'only the true rows should be shown', (tester) async {
      final columns = [
        TrinaColumn(
          title: 'column',
          field: 'column',
          type: TrinaColumnType.boolean(),
        ),
      ];

      await tester.pumpWidget(buildGrid(columns: columns, rows: buildRows()));
      await tester.pump();

      await tapAndEnterTextColumnFilter(tester, 'Yes');
      await tester.pumpAndSettle(const Duration(seconds: 1));

      expect(filteredValues(), [true, true]);
    });

    testWidgets('When filtering with the default falseText "No", '
        'only the false rows should be shown', (tester) async {
      final columns = [
        TrinaColumn(
          title: 'column',
          field: 'column',
          type: TrinaColumnType.boolean(),
        ),
      ];

      await tester.pumpWidget(buildGrid(columns: columns, rows: buildRows()));
      await tester.pump();

      await tapAndEnterTextColumnFilter(tester, 'No');
      await tester.pumpAndSettle(const Duration(seconds: 1));

      expect(filteredValues(), [false, false, false]);
    });

    testWidgets('When filtering with a custom trueText, '
        'only the true rows should be shown', (tester) async {
      final columns = [
        TrinaColumn(
          title: 'column',
          field: 'column',
          type: TrinaColumnType.boolean(
            trueText: 'Enabled',
            falseText: 'Disabled',
          ),
        ),
      ];

      await tester.pumpWidget(buildGrid(columns: columns, rows: buildRows()));
      await tester.pump();

      await tapAndEnterTextColumnFilter(tester, 'Enabled');
      await tester.pumpAndSettle(const Duration(seconds: 1));

      expect(filteredValues(), [true, true]);
    });

    testWidgets('When filtering with the raw value "true", '
        'only the true rows should be shown', (tester) async {
      final columns = [
        TrinaColumn(
          title: 'column',
          field: 'column',
          type: TrinaColumnType.boolean(
            trueText: 'Enabled',
            falseText: 'Disabled',
          ),
        ),
      ];

      await tester.pumpWidget(buildGrid(columns: columns, rows: buildRows()));
      await tester.pump();

      await tapAndEnterTextColumnFilter(tester, 'true');
      await tester.pumpAndSettle(const Duration(seconds: 1));

      expect(filteredValues(), [true, true]);
    });
  });
}
