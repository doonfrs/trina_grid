import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trina_grid/trina_grid.dart';
import 'package:trina_grid/src/ui/ui.dart';

import '../../helper/column_helper.dart';
import '../../helper/row_helper.dart';

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

  testWidgets('When filtering with "contains" condition and value "value 1", '
      'only rows containing "value 1" should be shown', (tester) async {
    final columns = ColumnHelper.textColumn('column');

    final rows = RowHelper.count(20, columns);

    await tester.pumpWidget(buildGrid(columns: columns, rows: rows));

    await tester.pump();

    await tapAndEnterTextColumnFilter(tester, 'value 1');

    await tester.pumpAndSettle(const Duration(seconds: 1));

    expect(stateManager.refRows.length, 11);

    expect(find.text('column0 value 1'), findsOneWidget);
    expect(find.text('column0 value 10'), findsOneWidget);
    expect(find.text('column0 value 11'), findsOneWidget);
    expect(find.text('column0 value 12'), findsOneWidget);
    expect(find.text('column0 value 13'), findsOneWidget);
    expect(find.text('column0 value 14'), findsOneWidget);
    expect(find.text('column0 value 15'), findsOneWidget);
    expect(find.text('column0 value 16'), findsOneWidget);
    expect(find.text('column0 value 17'), findsOneWidget);
    expect(find.text('column0 value 18'), findsOneWidget);
    expect(find.text('column0 value 19'), findsOneWidget);
  });

  testWidgets('When filtering with "equals" condition and value "value 11", '
      'only rows with exact match should be shown', (tester) async {
    final columns = ColumnHelper.textColumn('column');

    final rows = RowHelper.count(20, columns);

    await tester.pumpWidget(buildGrid(columns: columns, rows: rows));

    await tester.pump();

    await tapAndEnterTextColumnFilter(tester, 'value 11');

    await tester.pumpAndSettle(const Duration(seconds: 1));

    expect(stateManager.refRows.length, 1);

    expect(find.text('column0 value 11'), findsOneWidget);
  });

  testWidgets(
    'When filtering with "starts with" condition and value "value 11", '
    'and then pressing Ctrl + A and backspace, all rows should be shown',
    (tester) async {
      final columns = ColumnHelper.textColumn('column');

      final rows = RowHelper.count(20, columns);

      await tester.pumpWidget(buildGrid(columns: columns, rows: rows));

      await tester.pump();

      await tapAndEnterTextColumnFilter(tester, 'value 11');

      await tester.pumpAndSettle(const Duration(seconds: 1));

      expect(stateManager.refRows.length, 1);

      expect(find.text('column0 value 11'), findsOneWidget);

      await tester.sendKeyDownEvent(LogicalKeyboardKey.control);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyA);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.control);
      await tester.pump();

      await tester.sendKeyEvent(LogicalKeyboardKey.backspace);

      await tester.pumpAndSettle(const Duration(seconds: 1));

      expect(stateManager.refRows.length, 20);

      expect(find.text('column0 value 0'), findsOneWidget);

      stateManager.moveScrollByRow(TrinaMoveDirection.down, 19);

      await tester.pump();

      expect(find.text('column0 value 19'), findsOneWidget);
    },
  );
}
