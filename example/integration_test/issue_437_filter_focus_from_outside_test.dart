// End to end tests for #437: the first click into a column filter must keep
// the filter focused when the focus comes from a text field outside the grid.
//
// The grid's FocusScope calls setKeepFocus(true) when focus enters it, which
// requested focus on the grid node and so took it away from the filter field
// that had just been clicked. The user had to click a second time to type.
//
// Run with:
//   cd example
//   flutter test integration_test/issue_437_filter_focus_from_outside_test.dart -d windows

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

  const outsideKey = ValueKey('outside-field');

  /// A text field above a grid that shows the filter row, like the report.
  Widget buildApp({TrinaFilterColumnWidgetDelegate? filterDelegate}) {
    final columns = [
      TrinaColumn(
        title: 'Name',
        field: 'name',
        type: TrinaColumnType.text(),
        filterWidgetDelegate: filterDelegate,
      ),
      TrinaColumn(title: 'City', field: 'city', type: TrinaColumnType.text()),
    ];

    final rows = List.generate(20, (i) {
      return TrinaRow(
        cells: {
          'name': TrinaCell(value: i.isEven ? 'apple $i' : 'banana $i'),
          'city': TrinaCell(value: 'City $i'),
        },
      );
    });

    return Column(
      children: [
        const TextField(
          key: outsideKey,
          decoration: InputDecoration(labelText: 'Outside the grid'),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: TrinaGrid(
            columns: columns,
            rows: rows,
            onLoaded: (event) {
              stateManager = event.stateManager;
              stateManager.setShowColumnFilter(true);
            },
          ),
        ),
      ],
    );
  }

  Finder filterField(String field) {
    return find.descendant(
      of: find.byWidgetPredicate(
        (w) => w is TrinaColumnFilter && w.column.field == field,
      ),
      matching: find.byType(EditableText),
    );
  }

  FocusNode filterFocusNode(String field) {
    return stateManager.refColumns
        .firstWhere((c) => c.field == field)
        .filterFocusNode!;
  }

  Future<void> clickOutsideField(WidgetTester tester) async {
    await tester.tap(find.byKey(outsideKey), kind: PointerDeviceKind.mouse);
    await settle(tester);

    expect(
      tester
          .widget<EditableText>(
            find.descendant(
              of: find.byKey(outsideKey),
              matching: find.byType(EditableText),
            ),
          )
          .focusNode
          .hasPrimaryFocus,
      isTrue,
      reason: 'The outside text field should hold focus before the click',
    );
  }

  Future<void> expectFilterFocusedAndTyping(
    WidgetTester tester,
    String step,
  ) async {
    final focused = filterFocusNode('name').hasPrimaryFocus;

    if (!focused) {
      final screenshot = await takeScreenshot(tester, 'FAILED_$step');
      fail(
        'The "name" filter lost focus after "$step". Primary focus: '
        '${FocusManager.instance.primaryFocus}, grid focused: '
        '${stateManager.gridFocusNode.hasPrimaryFocus}, '
        'keepFocus: ${stateManager.keepFocus}.\n'
        'Screenshot: $screenshot',
      );
    }

    // Text input must land in the filter after the first tap.
    tester.testTextInput.enterText('ap');
    await settle(tester);

    expect(
      tester.widget<EditableText>(filterField('name')).controller.text,
      'ap',
      reason: 'Typed keys should go to the filter field',
    );

    await takeScreenshot(tester, '437_$step');
  }

  Widget builderFilter(
    FocusNode focusNode,
    TextEditingController controller,
    bool enabled,
    void Function(dynamic changed) handleOnChanged,
    TrinaGridStateManager stateManager,
  ) {
    return TextField(
      focusNode: focusNode,
      controller: controller,
      enabled: enabled,
      onChanged: handleOnChanged,
    );
  }

  // Desktop mouse clicks hid the bug: the text field asks for focus again
  // after the grid took it. Touch input (mobile, touch screens, and widget
  // tests) left the grid with the focus.
  for (final kind in [PointerDeviceKind.touch, PointerDeviceKind.mouse]) {
    testWidgets('a ${kind.name} tap into the default filter from an outside '
        'field keeps the filter focused', (tester) async {
      await pumpGridApp(tester, buildApp());
      await clickOutsideField(tester);

      await tester.tap(filterField('name'), kind: kind);
      await settle(tester);

      await expectFilterFocusedAndTyping(tester, 'default_filter_${kind.name}');
    });

    testWidgets('a ${kind.name} tap into a builder filter from an outside '
        'field keeps the filter focused', (tester) async {
      await pumpGridApp(
        tester,
        buildApp(
          filterDelegate: TrinaFilterColumnWidgetDelegate.builder(
            filterWidgetBuilder: builderFilter,
          ),
        ),
      );
      await clickOutsideField(tester);

      await tester.tap(filterField('name'), kind: kind);
      await settle(tester);

      await expectFilterFocusedAndTyping(tester, 'builder_filter_${kind.name}');
    });
  }

  testWidgets('a click into a filter while the grid has focus still keeps '
      'the filter focused', (tester) async {
    await pumpGridApp(tester, buildApp());

    await tapCell(tester, row: stateManager.refRows.first, field: 'city');
    expect(stateManager.gridFocusNode.hasPrimaryFocus, isTrue);

    await tester.tap(filterField('name'), kind: PointerDeviceKind.touch);
    await settle(tester);

    await expectFilterFocusedAndTyping(tester, 'from_grid');
  });

  testWidgets('a click into a cell from an outside field focuses the grid', (
    tester,
  ) async {
    await pumpGridApp(tester, buildApp());
    await clickOutsideField(tester);

    await tapCell(tester, row: stateManager.refRows.first, field: 'city');

    expect(stateManager.gridFocusNode.hasPrimaryFocus, isTrue);
    expect(stateManager.keepFocus, isTrue);
    expect(stateManager.currentCell?.column.field, 'city');

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await settle(tester);

    expect(stateManager.currentRowIdx, 1);
  });
}
