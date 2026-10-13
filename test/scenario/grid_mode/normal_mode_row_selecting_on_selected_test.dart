import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trina_grid/trina_grid.dart';

import '../../helper/column_helper.dart';
import '../../helper/row_helper.dart';

/// onSelected in [TrinaGridMode.normal] with [TrinaGridSelectingMode.row],
/// the setup from #46.
void main() {
  late TrinaGridStateManager stateManager;
  late List<TrinaGridOnSelectedEvent> events;

  Future<void> pumpGrid(WidgetTester tester) async {
    events = [];
    final columns = ColumnHelper.textColumn('column', count: 2);
    final rows = RowHelper.count(5, columns);

    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: TrinaGrid(
            columns: columns,
            rows: rows,
            onLoaded: (event) {
              stateManager = event.stateManager;
              stateManager.setSelectingMode(TrinaGridSelectingMode.row);
            },
            onSelected: events.add,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  List<int> selectedIdx(TrinaGridOnSelectedEvent event) {
    return event.selectedRows!.map(stateManager.refRows.indexOf).toList()
      ..sort();
  }

  testWidgets('a tap on a row fires onSelected with that row', (tester) async {
    await pumpGrid(tester);
    expect(events, isEmpty);

    await tester.tap(find.text('column0 value 1'));
    await tester.pumpAndSettle();

    expect(events, hasLength(1));
    expect(events.last.row, stateManager.refRows[1]);

    await tester.tap(find.text('column1 value 3'));
    await tester.pumpAndSettle();

    expect(events, hasLength(2));
    expect(events.last.row, stateManager.refRows[3]);
  });

  testWidgets('a Shift tap selects the range and fires onSelected', (
    tester,
  ) async {
    await pumpGrid(tester);

    await tester.tap(find.text('column0 value 1'));
    await tester.pumpAndSettle();
    final count = events.length;

    await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
    await tester.tap(find.text('column0 value 3'));
    await tester.pumpAndSettle();
    await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);

    expect(events.length, greaterThan(count));
    expect(selectedIdx(events.last), [1, 2, 3]);
  });

  testWidgets('a long press selects the row and fires onSelected', (
    tester,
  ) async {
    await pumpGrid(tester);

    await tester.longPress(find.text('column0 value 2'));
    await tester.pumpAndSettle();

    expect(events, isNotEmpty);
    expect(selectedIdx(events.last), [2]);
  });
}
