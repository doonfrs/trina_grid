import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trina_grid/trina_grid.dart';
import 'package:trina_grid/src/ui/ui.dart';

/// #437: entering a column filter from a text field outside the grid must
/// keep the filter focused, instead of the grid taking the focus.
void main() {
  late TrinaGridStateManager stateManager;

  const outsideKey = ValueKey('outside-field');

  Widget buildApp({TrinaFilterColumnWidgetDelegate? filterDelegate}) {
    return MaterialApp(
      home: Material(
        child: Column(
          children: [
            const TextField(key: outsideKey),
            Expanded(
              child: TrinaGrid(
                columns: [
                  TrinaColumn(
                    title: 'name',
                    field: 'name',
                    type: TrinaColumnType.text(),
                    filterWidgetDelegate: filterDelegate,
                  ),
                  TrinaColumn(
                    title: 'city',
                    field: 'city',
                    type: TrinaColumnType.text(),
                  ),
                ],
                rows: [
                  for (final name in ['apple', 'banana', 'apricot'])
                    TrinaRow(
                      cells: {
                        'name': TrinaCell(value: name),
                        'city': TrinaCell(value: 'city'),
                      },
                    ),
                ],
                onLoaded: (event) {
                  stateManager = event.stateManager;
                  stateManager.setShowColumnFilter(true);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Finder filterField() {
    return find.descendant(
      of: find.byWidgetPredicate(
        (w) => w is TrinaColumnFilter && w.column.field == 'name',
      ),
      matching: find.byType(EditableText),
    );
  }

  FocusNode filterFocusNode() => stateManager.refColumns.first.filterFocusNode!;

  Future<void> focusOutsideField(WidgetTester tester) async {
    await tester.tap(find.byKey(outsideKey));
    await tester.pumpAndSettle();

    expect(stateManager.gridFocusNode.hasFocus, isFalse);
  }

  List<String> names() {
    return stateManager.refRows
        .map((row) => row.cells['name']!.value as String)
        .toList();
  }

  testWidgets('A tap into the default filter keeps the filter focused', (
    tester,
  ) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();
    await focusOutsideField(tester);

    await tester.tap(filterField());
    await tester.pumpAndSettle();

    expect(filterFocusNode().hasPrimaryFocus, isTrue);
    expect(stateManager.gridFocusNode.hasPrimaryFocus, isFalse);
    expect(stateManager.keepFocus, isFalse);

    tester.testTextInput.enterText('ap');
    await tester.pumpAndSettle(const Duration(seconds: 1));

    expect(names(), ['apple', 'apricot']);
  });

  testWidgets('enterText into the default filter filters the rows', (
    tester,
  ) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();
    await focusOutsideField(tester);

    await tester.enterText(filterField(), 'ban');
    await tester.pumpAndSettle(const Duration(seconds: 1));

    expect(filterFocusNode().hasPrimaryFocus, isTrue);
    expect(names(), ['banana']);
  });

  testWidgets('A tap into a builder filter keeps the filter focused', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildApp(
        filterDelegate: TrinaFilterColumnWidgetDelegate.builder(
          filterWidgetBuilder:
              (focusNode, controller, enabled, handleOnChanged, _) {
                return TextField(
                  focusNode: focusNode,
                  controller: controller,
                  enabled: enabled,
                  onChanged: handleOnChanged,
                );
              },
        ),
      ),
    );
    await tester.pumpAndSettle();
    await focusOutsideField(tester);

    await tester.tap(filterField());
    await tester.pumpAndSettle();

    expect(filterFocusNode().hasPrimaryFocus, isTrue);
    expect(stateManager.gridFocusNode.hasPrimaryFocus, isFalse);
  });

  testWidgets('A builder filter with its own focus node stays focused', (
    tester,
  ) async {
    final ownFocusNode = FocusNode();
    addTearDown(ownFocusNode.dispose);

    await tester.pumpWidget(
      buildApp(
        filterDelegate: TrinaFilterColumnWidgetDelegate.builder(
          filterWidgetBuilder:
              (focusNode, controller, enabled, handleOnChanged, _) {
                return Focus(
                  focusNode: focusNode,
                  skipTraversal: true,
                  child: TextField(
                    focusNode: ownFocusNode,
                    controller: controller,
                    onChanged: handleOnChanged,
                  ),
                );
              },
        ),
      ),
    );
    await tester.pumpAndSettle();
    await focusOutsideField(tester);

    await tester.tap(filterField());
    await tester.pumpAndSettle();

    expect(ownFocusNode.hasPrimaryFocus, isTrue);
    expect(stateManager.gridFocusNode.hasPrimaryFocus, isFalse);
  });

  testWidgets('A tap into a cell from outside still focuses the grid', (
    tester,
  ) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();
    await focusOutsideField(tester);

    await tester.tap(find.text('banana'));
    await tester.pumpAndSettle();

    expect(stateManager.gridFocusNode.hasPrimaryFocus, isTrue);
    expect(stateManager.keepFocus, isTrue);
    expect(stateManager.currentCell?.value, 'banana');

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pumpAndSettle();

    expect(stateManager.currentCell?.value, 'apricot');
  });
}
