// End to end tests for the multi-column sort priority badges added in #436.
// Columns that set `sort:` in their constructors must be numbered in order,
// so every header shows its own priority badge.
//
// Run with:
//   cd example
//   flutter test integration_test/issue_436_multi_sort_priority_test.dart -d windows
//
// ignore_for_file: implementation_imports

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trina_grid/src/ui/ui.dart';
import 'package:trina_grid/trina_grid.dart';

import 'e2e_harness.dart';

void main() {
  ensureE2EBinding();

  late TrinaGridStateManager stateManager;
  late List<TrinaColumn> columns;

  Widget buildGrid({
    TrinaColumnSort deptSort = TrinaColumnSort.ascending,
    TrinaColumnSort scoreSort = TrinaColumnSort.descending,
  }) {
    columns = [
      TrinaColumn(
        title: 'Department',
        field: 'dept',
        type: TrinaColumnType.text(),
        sort: deptSort,
      ),
      TrinaColumn(
        title: 'Score',
        field: 'score',
        type: TrinaColumnType.number(),
        sort: scoreSort,
      ),
      TrinaColumn(title: 'Name', field: 'name', type: TrinaColumnType.text()),
    ];

    final rows = List.generate(5, (i) {
      return TrinaRow(
        cells: {
          'dept': TrinaCell(value: i.isEven ? 'Sales' : 'Engineering'),
          'score': TrinaCell(value: 70 + i * 5),
          'name': TrinaCell(value: 'Name $i'),
        },
      );
    });

    return TrinaGrid(
      columns: columns,
      rows: rows,
      configuration: const TrinaGridConfiguration(enableMultiColumnSort: true),
      onLoaded: (event) => stateManager = event.stateManager,
    );
  }

  Finder findTitle(String field) {
    return find.byWidgetPredicate(
      (w) => w is TrinaColumnTitle && w.column.field == field,
    );
  }

  /// The priority badge text drawn in the header of [field], or null when the
  /// header shows no badge.
  String? badgeOf(String field) {
    final texts = find.descendant(
      of: find.descendant(
        of: findTitle(field),
        matching: find.byType(TrinaGridColumnIcon),
      ),
      matching: find.byType(Text),
    );

    if (texts.evaluate().isEmpty) return null;

    return (texts.evaluate().single.widget as Text).data;
  }

  testWidgets('columns sorted in their constructors get badges 1 and 2', (
    tester,
  ) async {
    await pumpGridApp(tester, buildGrid());
    await takeScreenshot(tester, '436_constructor_sorts');

    expect(stateManager.sortedColumns.map((c) => c.field), ['dept', 'score']);
    expect(badgeOf('dept'), '1');
    expect(badgeOf('score'), '2');
    expect(badgeOf('name'), isNull);
  });

  testWidgets('a Shift click on a third header appends it as priority 3', (
    tester,
  ) async {
    await pumpGridApp(tester, buildGrid());

    await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
    await tester.tap(find.text('Name'), kind: PointerDeviceKind.mouse);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
    await settle(tester);
    await takeScreenshot(tester, '436_shift_click_third');

    expect(stateManager.sortedColumns.map((c) => c.field), [
      'dept',
      'score',
      'name',
    ]);
    expect(badgeOf('dept'), '1');
    expect(badgeOf('score'), '2');
    expect(badgeOf('name'), '3');
  });

  testWidgets('a single column sorted in its constructor shows no badge', (
    tester,
  ) async {
    await pumpGridApp(tester, buildGrid(scoreSort: TrinaColumnSort.none));
    await takeScreenshot(tester, '436_single_constructor_sort');

    expect(stateManager.sortedColumns.map((c) => c.field), ['dept']);
    expect(columns[0].sortPriority, 1);
    expect(badgeOf('dept'), isNull);
    expect(badgeOf('score'), isNull);
  });
}
