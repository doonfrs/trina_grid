import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trina_grid/src/ui/cells/trina_date_cell.dart';
import 'package:trina_grid/trina_grid.dart';

void main() {
  late TrinaCell cell;
  late TrinaColumn column;

  final okButtonFinder = find.widgetWithText(TextButton, 'OK');

  Future<void> buildCellAndEdit(
    WidgetTester tester, {
    String initialCellValue = '2020-01-01',
    String dateFormat = 'yyyy-MM-dd',
    DateTime? startDate,
    DateTime? endDate,
    IconData? popupIcon = Icons.date_range,
    bool closePopupOnSelection = false,
  }) async {
    column = TrinaColumn(
      title: 'column title',
      field: 'column_field_name',
      enableAutoEditing: true,
      type: TrinaColumnType.date(
        popupIcon: popupIcon,
        format: dateFormat,
        startDate: startDate,
        endDate: endDate,
        closePopupOnSelection: closePopupOnSelection,
      ),
    );

    cell = TrinaCell(value: initialCellValue);

    final TrinaRow row = TrinaRow(cells: {column.field: cell});

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TrinaGrid(
            columns: [column],
            rows: [row],
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    await tester.tap(find.text(cell.value));
    await tester.pump();
  }

  Future<void> openPopup(WidgetTester tester) async {
    await tester.tap(find.text(cell.value));
    await tester.pumpAndSettle();
  }

  group('Suffix icon rendering', () {
    testWidgets('Default date icon should be rendered', (tester) async {
      await buildCellAndEdit(tester);
      expect(find.byIcon(Icons.date_range), findsOneWidget);
    });

    testWidgets('Custom icon should be rendered', (tester) async {
      await buildCellAndEdit(
        tester,
        initialCellValue: '2020-01-01',
        popupIcon: Icons.add,
      );
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets(
      'When popupIcon is null, icon should not be rendered',
      (tester) async {
        await buildCellAndEdit(
          tester,
          initialCellValue: '2020-01-01',
          popupIcon: null,
        );
        expect(
          find.descendant(
            of: find.byType(TrinaDateCell),
            matching: find.byType(Icon),
          ),
          findsNothing,
        );
      },
    );
  });

  group('Selection with Keyboard ', () {
    testWidgets(
      'when initial date is 2020-01-01, '
      'navigating to 2019-12-31 and pressing enter '
      'then OK button,should update cell value to 2019-12-31',
      (tester) async {
        await buildCellAndEdit(
          tester,
          initialCellValue: '2020-01-01',
        );
        await openPopup(tester);

        // first tap to focus the day widget
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
        await tester.pumpAndSettle();
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pump();
        await tester.tap(okButtonFinder);
        await tester.pumpAndSettle();

        expect(cell.value, '2019-12-31');
      },
    );

    testWidgets(
      'when initial date is 2020-1-31, '
      'navigating to 2020-2-1 and pressing enter '
      'then OK button, should update cell value to 2020-2-1',
      (tester) async {
        await buildCellAndEdit(
          tester,
          initialCellValue: '2020-01-31',
        );
        await openPopup(tester);

        // first arrow key to focus the current day in calendar
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
        await tester.pumpAndSettle();

        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pump();
        await tester.tap(okButtonFinder);
        await tester.pumpAndSettle();

        expect(cell.value, '2020-02-01');
      },
    );
  });

  group('Format yyyy-MM-dd', () {
    testWidgets(
      'Pressing left arrow and enter should not select a date before startDate',
      (tester) async {
        await buildCellAndEdit(
          tester,
          initialCellValue: '2020-12-01',
          startDate: DateTime.parse('2020-12-01'),
        );
        await openPopup(tester);

        // first arrow key to focus the current day in calendar
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
        await tester.pumpAndSettle();
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.tap(okButtonFinder);
        await tester.pumpAndSettle();

        expect(cell.value, '2020-12-01');
      },
    );
  });

  group('closePopupOnSelection', () {
    testWidgets(
      'when closePopupOnSelection is true, '
      'tapping a date should close the popup and update the cell value',
      (tester) async {
        await buildCellAndEdit(
          tester,
          initialCellValue: '2020-01-01',
          closePopupOnSelection: true,
        );
        await openPopup(tester);

        await tester.tap(find.text('3'));
        await tester.pumpAndSettle();

        expect(find.byType(CalendarDatePicker), findsNothing);
        expect(cell.value, '2020-01-03');
      },
    );

    testWidgets(
      'when closePopupOnSelection is true, '
      'OK and Cancel buttons should not be rendered',
      (tester) async {
        await buildCellAndEdit(
          tester,
          initialCellValue: '2020-01-01',
          closePopupOnSelection: true,
        );
        await openPopup(tester);

        expect(okButtonFinder, findsNothing);
        expect(find.widgetWithText(TextButton, 'Cancel'), findsNothing);
      },
    );

    testWidgets(
      'when closePopupOnSelection is false, '
      'tapping a date should not close the popup',
      (tester) async {
        await buildCellAndEdit(
          tester,
          initialCellValue: '2020-01-01',
          closePopupOnSelection: false,
        );
        await openPopup(tester);

        await tester.tap(find.text('3'));
        await tester.pumpAndSettle();

        expect(find.byType(CalendarDatePicker), findsOneWidget);
      },
    );

    testWidgets(
      'when closePopupOnSelection is false, '
      'OK and Cancel buttons should be rendered',
      (tester) async {
        await buildCellAndEdit(
          tester,
          initialCellValue: '2020-01-01',
          closePopupOnSelection: false,
        );
        await openPopup(tester);

        expect(okButtonFinder, findsOneWidget);
        expect(find.widgetWithText(TextButton, 'Cancel'), findsOneWidget);
      },
    );
  });
}
