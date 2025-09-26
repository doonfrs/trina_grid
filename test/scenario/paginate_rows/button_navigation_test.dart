import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trina_grid/trina_grid.dart';
import 'package:trina_grid/src/ui/ui.dart';

import '../../helper/column_helper.dart';
import '../../helper/trina_widget_test_helper.dart';
import '../../helper/row_helper.dart';

void fillNumbers(List<TrinaRow> rows, String columnName) {
  int num = -1;

  for (var element in rows) {
    element.cells[columnName]?.value = ++num;
  }
}

List<TextButton> buttonsToWidgets(Finder pageButtons) {
  return pageButtons
      .evaluate()
      .map((e) => e.widget)
      .cast<TextButton>()
      .toList();
}

String? textFromTextButton(TextButton button) {
  return (button.child as Text).data;
}

TextStyle textStyleFromTextButton(TextButton button) {
  return (button.child as Text).style as TextStyle;
}

void main() {
  group('Pagination Button Navigation Test', () {
    List<TrinaColumn> columns;

    List<TrinaRow> rows;

    late TrinaGridStateManager stateManager;

    late Finder pageButtons;

    late Color defaultButtonColor;

    late Color activateButtonColor;

    const headerName = 'header0';

    final grid = TrinaWidgetTestHelper('100 rows and default page size 40', (
      tester,
    ) async {
      columns = [...ColumnHelper.textColumn('header', count: 1)];

      rows = RowHelper.count(100, columns);

      fillNumbers(rows, headerName);

      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: TrinaGrid(
              columns: columns,
              rows: rows,
              onLoaded: (TrinaGridOnLoadedEvent event) {
                stateManager = event.stateManager;
              },
              createFooter: (s) => TrinaPagination(s),
            ),
          ),
        ),
      );

      pageButtons = find.byType(TextButton);

      defaultButtonColor = stateManager.configuration.style.iconColor;

      activateButtonColor =
          stateManager.configuration.style.activatedBorderColor;
    });

    grid.test('TrinaPagination widget should be rendered.', (tester) async {
      expect(find.byType(TrinaPagination), findsOneWidget);
    });

    grid.test('Three pagination buttons should be rendered.', (tester) async {
      expect(pageButtons, findsNWidgets(3));
    });

    grid.test('Pagination buttons should be rendered as 1, 2, 3.', (
      tester,
    ) async {
      List<TextButton> pageButtonsAsTextButton = buttonsToWidgets(pageButtons);

      expect(textFromTextButton(pageButtonsAsTextButton[0]), '1');
      expect(textFromTextButton(pageButtonsAsTextButton[1]), '2');
      expect(textFromTextButton(pageButtonsAsTextButton[2]), '3');
    });

    grid.test('The first pagination button should be activated.', (
      tester,
    ) async {
      List<TextButton> pageButtonsAsTextButton = buttonsToWidgets(pageButtons);

      final style1 = textStyleFromTextButton(pageButtonsAsTextButton[0]);

      expect(style1.color, activateButtonColor);
    });

    grid.test(
      'The second and third pagination buttons should not be activated.',
      (tester) async {
        List<TextButton> pageButtonsAsTextButton = buttonsToWidgets(
          pageButtons,
        );

        final style2 = textStyleFromTextButton(pageButtonsAsTextButton[1]);

        final style3 = textStyleFromTextButton(pageButtonsAsTextButton[2]);

        expect(style2.color, defaultButtonColor);

        expect(style3.color, defaultButtonColor);
      },
    );

    grid.test('Cell values of 100 rows should be set from 0 to 99.', (
      tester,
    ) async {
      // Set cell values in order from 0 to 99 for testing.
      final rows = stateManager.refRows.originalList;

      expect(rows[0].cells[headerName]!.value, 0);

      expect(rows[50].cells[headerName]!.value, 50);

      expect(rows[99].cells[headerName]!.value, 99);
    });

    grid.test('The first page should render 40 rows.', (tester) async {
      final rows = stateManager.rows;

      expect(rows.first.cells[headerName]!.value, 0);

      expect(rows.last.cells[headerName]!.value, 39);

      expect(rows.length, 40);
    });

    grid.test(
      'When clicking the second pagination button, the second button should be activated.',
      (tester) async {
        await tester.tap(pageButtons.at(1));

        await tester.pumpAndSettle(const Duration(milliseconds: 300));

        List<TextButton> pageButtonsAsTextButton = buttonsToWidgets(
          pageButtons,
        );

        final style1 = textStyleFromTextButton(pageButtonsAsTextButton[0]);

        expect(style1.color, defaultButtonColor);

        final style2 = textStyleFromTextButton(pageButtonsAsTextButton[1]);

        expect(style2.color, activateButtonColor);
      },
    );

    grid.test(
      'When clicking the second pagination button, the current rows should render cell values from 40 to 79.',
      (tester) async {
        await tester.tap(pageButtons.at(1));

        await tester.pumpAndSettle(const Duration(milliseconds: 300));

        final rows = stateManager.rows;

        expect(rows.length, 40);

        expect(rows.first.cells[headerName]!.value, 40);

        expect(rows.last.cells[headerName]!.value, 79);
      },
    );

    grid.test(
      'When clicking the third pagination button, the third button should be activated.',
      (tester) async {
        await tester.tap(pageButtons.at(2));

        await tester.pumpAndSettle(const Duration(milliseconds: 300));

        List<TextButton> pageButtonsAsTextButton = buttonsToWidgets(
          pageButtons,
        );

        final style1 = textStyleFromTextButton(pageButtonsAsTextButton[0]);

        expect(style1.color, defaultButtonColor);

        final style2 = textStyleFromTextButton(pageButtonsAsTextButton[1]);

        expect(style2.color, defaultButtonColor);

        final style3 = textStyleFromTextButton(pageButtonsAsTextButton[2]);

        expect(style3.color, activateButtonColor);
      },
    );

    grid.test(
      'When clicking the third pagination button, the current rows should render cell values from 80 to 99.',
      (tester) async {
        await tester.tap(pageButtons.at(2));

        await tester.pumpAndSettle(const Duration(milliseconds: 300));

        final rows = stateManager.rows;

        expect(rows.length, 20);

        expect(rows.first.cells[headerName]!.value, 80);

        expect(rows.last.cells[headerName]!.value, 99);
      },
    );

    grid.test('Alt + Page Down/Up key combination should navigate pages.', (
      tester,
    ) async {
      await tester.tap(find.byType(TrinaBaseCell).first);

      await tester.pump();

      expect(stateManager.page, 1);

      await tester.sendKeyDownEvent(LogicalKeyboardKey.alt);
      await tester.sendKeyEvent(LogicalKeyboardKey.pageDown);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.alt);

      await tester.pumpAndSettle();

      expect(stateManager.page, 2);

      await tester.sendKeyDownEvent(LogicalKeyboardKey.alt);
      await tester.sendKeyEvent(LogicalKeyboardKey.pageDown);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.alt);

      await tester.pumpAndSettle();

      expect(stateManager.page, 3);

      // Clicking next page on the last page should still be on the last page.
      await tester.sendKeyDownEvent(LogicalKeyboardKey.alt);
      await tester.sendKeyEvent(LogicalKeyboardKey.pageDown);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.alt);

      await tester.pumpAndSettle();

      expect(stateManager.page, 3);

      await tester.sendKeyDownEvent(LogicalKeyboardKey.alt);
      await tester.sendKeyEvent(LogicalKeyboardKey.pageUp);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.alt);

      await tester.pumpAndSettle();

      expect(stateManager.page, 2);

      await tester.sendKeyDownEvent(LogicalKeyboardKey.alt);
      await tester.sendKeyEvent(LogicalKeyboardKey.pageUp);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.alt);

      await tester.pumpAndSettle();

      expect(stateManager.page, 1);

      // Clicking previous page on the first page should still be on the first page.
      await tester.sendKeyDownEvent(LogicalKeyboardKey.alt);
      await tester.sendKeyEvent(LogicalKeyboardKey.pageUp);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.alt);

      await tester.pumpAndSettle();

      expect(stateManager.page, 1);
    });
  });
}
