// End to end tests for #168: a right click on a row must report where the
// pointer was, so the app can open a context menu right there.
//
// Run with:
//   cd example
//   flutter test integration_test/issue_168_row_context_menu_test.dart -d windows

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trina_grid/trina_grid.dart';

import 'e2e_harness.dart';

void main() {
  ensureE2EBinding();

  late TrinaGridStateManager stateManager;

  testWidgets('a right click on a cell reports the pointer position and '
      'opens a menu there', (tester) async {
    final events = <TrinaGridOnRowSecondaryTapEvent>[];

    final columns = [
      TrinaColumn(title: 'Name', field: 'name', type: TrinaColumnType.text()),
      TrinaColumn(title: 'City', field: 'city', type: TrinaColumnType.text()),
    ];

    final rows = List.generate(8, (i) {
      return TrinaRow(
        cells: {
          'name': TrinaCell(value: 'Name $i'),
          'city': TrinaCell(value: 'City $i'),
        },
      );
    });

    await pumpGridApp(
      tester,
      Builder(
        builder: (context) {
          return TrinaGrid(
            columns: columns,
            rows: rows,
            onLoaded: (event) => stateManager = event.stateManager,
            onRowSecondaryTap: (event) {
              events.add(event);
              showMenu<String>(
                context: context,
                position: RelativeRect.fromLTRB(
                  event.offset.dx,
                  event.offset.dy,
                  event.offset.dx,
                  event.offset.dy,
                ),
                items: const [
                  PopupMenuItem(value: 'view', child: Text('View details')),
                  PopupMenuItem(value: 'delete', child: Text('Delete row')),
                ],
              );
            },
          );
        },
      ),
    );

    final cellRect = tester.getRect(
      findCell(row: stateManager.refRows[4], field: 'city'),
    );
    final clickAt = cellRect.topLeft + const Offset(37, 9);

    await tester.tapAt(
      clickAt,
      kind: PointerDeviceKind.mouse,
      buttons: kSecondaryMouseButton,
    );
    await settle(tester);

    expect(events, hasLength(1));
    expect(events.single.row, stateManager.refRows[4]);
    expect(events.single.cell.column.field, 'city');
    expect(events.single.offset.dx, closeTo(clickAt.dx, 0.5));
    expect(events.single.offset.dy, closeTo(clickAt.dy, 0.5));

    // The menu is drawn in the Navigator overlay, outside the screenshot
    // boundary, so check where it opened instead of taking a screenshot.
    final menuTopLeft = tester.getTopLeft(
      find
          .ancestor(
            of: find.text('View details'),
            matching: find.byType(Material),
          )
          .last,
    );
    expect((menuTopLeft - clickAt).distance, lessThan(24));
  });
}
