// End to end tests for #46: onSelected must fire when a row is tapped in the
// setups from the report (normal mode with row selecting, and multiSelect).
//
// Run with:
//   cd example
//   flutter test integration_test/issue_46_on_selected_test.dart -d windows

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trina_grid/trina_grid.dart';

import 'e2e_harness.dart';

void main() {
  ensureE2EBinding();

  late TrinaGridStateManager stateManager;
  late List<TrinaGridOnSelectedEvent> events;

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

  setUp(() => events = []);

  testWidgets('normal mode with row selecting: tapping a row fires '
      'onSelected with that row', (tester) async {
    await pumpGridApp(
      tester,
      buildGrid(selectingMode: TrinaGridSelectingMode.row),
    );

    await tester.tap(
      findCell(row: stateManager.refRows[1], field: 'name'),
      kind: PointerDeviceKind.mouse,
    );
    await settle(tester);

    expect(events, hasLength(1));
    expect(events.last.row, stateManager.refRows[1]);

    await tester.tap(
      findCell(row: stateManager.refRows[3], field: 'role'),
      kind: PointerDeviceKind.mouse,
    );
    await settle(tester);

    expect(events, hasLength(2));
    expect(events.last.row, stateManager.refRows[3]);

    await takeScreenshot(tester, '46_normal_row_selecting');
  });

  testWidgets('multiSelect mode: tapping rows fires onSelected with the '
      'selected rows', (tester) async {
    await pumpGridApp(tester, buildGrid(mode: TrinaGridMode.multiSelect));

    await tester.tap(
      findCell(row: stateManager.refRows[1], field: 'name'),
      kind: PointerDeviceKind.mouse,
    );
    await settle(tester);

    // The select modes make the first row current on load
    // (enableAutoSelectFirstRow), so only check the tapped rows are reported.
    expect(events, isNotEmpty);
    expect(events.last.selectedRows, contains(stateManager.refRows[1]));
    final count = events.length;

    await tester.tap(
      findCell(row: stateManager.refRows[3], field: 'name'),
      kind: PointerDeviceKind.mouse,
    );
    await settle(tester);

    expect(events.length, greaterThan(count));
    expect(
      events.last.selectedRows,
      containsAll([stateManager.refRows[1], stateManager.refRows[3]]),
    );

    await takeScreenshot(tester, '46_multi_select');
  });
}
