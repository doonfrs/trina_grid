// End to end tests for #46: onSelected must fire when rows are selected in
// the setups from the report, normal mode with row selecting and multiSelect.
//
// Run with:
//   cd example
//   flutter test integration_test/issue_46_on_selected_test.dart -d windows

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trina_grid/trina_grid.dart';

import 'e2e_harness.dart';

void main() {
  ensureE2EBinding();

  late TrinaGridStateManager stateManager;
  late List<TrinaGridOnSelectedEvent> events;

  /// The grid from the report: an ID, Name and Role column.
  Widget buildGrid({
    TrinaGridMode mode = TrinaGridMode.normal,
    TrinaGridSelectingMode? selectingMode,
  }) {
    final columns = [
      TrinaColumn(
        title: 'ID',
        field: 'id',
        type: TrinaColumnType.number(),
        width: 80,
      ),
      TrinaColumn(title: 'Name', field: 'name', type: TrinaColumnType.text()),
      TrinaColumn(title: 'Role', field: 'role', type: TrinaColumnType.text()),
    ];

    final rows = List.generate(5, (i) {
      return TrinaRow(
        cells: {
          'id': TrinaCell(value: i + 1),
          'name': TrinaCell(value: 'Name $i'),
          'role': TrinaCell(value: 'Role $i'),
        },
      );
    });

    return TrinaGrid(
      columns: columns,
      rows: rows,
      mode: mode,
      onLoaded: (event) {
        stateManager = event.stateManager;
        if (selectingMode != null) {
          stateManager.setSelectingMode(selectingMode);
        }
      },
      onSelected: events.add,
    );
  }

  Future<void> clickRow(WidgetTester tester, int row, String field) async {
    await tester.tap(
      findCell(row: stateManager.refRows[row], field: field),
      kind: PointerDeviceKind.mouse,
    );
    await settle(tester);
  }

  List<int> selectedIdx(TrinaGridOnSelectedEvent event) {
    return event.selectedRows!.map(stateManager.refRows.indexOf).toList()
      ..sort();
  }

  setUp(() => events = []);

  group('normal mode with row selecting (the code in the report)', () {
    testWidgets('a click on a row fires onSelected with that row', (
      tester,
    ) async {
      await pumpGridApp(
        tester,
        buildGrid(selectingMode: TrinaGridSelectingMode.row),
      );
      expect(events, isEmpty);

      await clickRow(tester, 1, 'name');

      expect(events, hasLength(1));
      expect(events.last.row, stateManager.refRows[1]);

      await clickRow(tester, 3, 'role');

      expect(events, hasLength(2));
      expect(events.last.row, stateManager.refRows[3]);

      await takeScreenshot(tester, '46_normal_row_click');
    });

    testWidgets('a Shift click selects the range and fires onSelected', (
      tester,
    ) async {
      await pumpGridApp(
        tester,
        buildGrid(selectingMode: TrinaGridSelectingMode.row),
      );

      await clickRow(tester, 1, 'name');
      final count = events.length;

      await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
      await clickRow(tester, 3, 'name');
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
      await settle(tester);

      expect(events.length, greaterThan(count));
      expect(selectedIdx(events.last), [1, 2, 3]);

      await takeScreenshot(tester, '46_normal_row_shift_click');
    });

    testWidgets('a Ctrl click adds a row and fires onSelected', (tester) async {
      await pumpGridApp(
        tester,
        buildGrid(selectingMode: TrinaGridSelectingMode.row),
      );

      await clickRow(tester, 1, 'name');
      final count = events.length;

      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await clickRow(tester, 3, 'name');
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await settle(tester);

      expect(events.length, greaterThan(count));
      expect(selectedIdx(events.last), contains(3));
    });

    testWidgets('a long press selects the row and fires onSelected', (
      tester,
    ) async {
      await pumpGridApp(
        tester,
        buildGrid(selectingMode: TrinaGridSelectingMode.row),
      );

      await tester.longPress(
        findCell(row: stateManager.refRows[2], field: 'name'),
      );
      await settle(tester);

      expect(events, isNotEmpty);
      expect(selectedIdx(events.last), [2]);
    });
  });

  testWidgets('multiSelect mode: each click fires onSelected with every '
      'selected row', (tester) async {
    await pumpGridApp(tester, buildGrid(mode: TrinaGridMode.multiSelect));

    // enableAutoSelectFirstRow (on by default) selects the first row on load.
    expect(stateManager.currentSelectingRows, [stateManager.refRows[0]]);
    expect(events, isEmpty);

    await clickRow(tester, 1, 'name');

    expect(events, hasLength(1));
    expect(selectedIdx(events.last), [0, 1]);

    await clickRow(tester, 3, 'name');

    expect(events, hasLength(2));
    expect(selectedIdx(events.last), [0, 1, 3]);

    // A second click on a selected row unselects it.
    await clickRow(tester, 1, 'role');

    expect(events, hasLength(3));
    expect(selectedIdx(events.last), [0, 3]);

    await takeScreenshot(tester, '46_multi_select');
  });
}
