import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trina_grid/src/ui/cells/trina_date_time_cell.dart';
import 'package:trina_grid/src/ui/widgets/trina_date_picker.dart';
import 'package:trina_grid/src/ui/widgets/trina_time_picker.dart';
import 'package:trina_grid/trina_grid.dart';

import '../../../helper/test_helper_util.dart';

void main() {
  const defaultCellValue = '2023-01-09 00:00';
  late TrinaCell cell;

  final okButtonFinder = find.widgetWithText(TextButton, 'OK');

  final hourFieldFinder = find.byWidgetPredicate(
    (widget) => widget is TextField && widget.decoration?.helperText == 'Hour',
  );
  final minuteFieldFinder = find.byWidgetPredicate(
    (widget) =>
        widget is TextField && widget.decoration?.helperText == 'Minute',
  );

  TrinaColumn getColumn({
    IconData? popupIcon = Icons.event_available,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return TrinaColumn(
      title: 'column title',
      field: 'column_field_name',
      enableAutoEditing: true,
      type: TrinaColumnType.dateTime(
        popupIcon: popupIcon,
        startDate: startDate,
        endDate: endDate,
      ),
    );
  }

  Future<void> buildCellAndEdit(
    WidgetTester tester, {
    TrinaColumn? column,
    TrinaCell? trinaCell,
  }) async {
    column ??= getColumn();

    cell = trinaCell ?? TrinaCell(value: defaultCellValue);

    final TrinaRow row = TrinaRow(cells: {column.field: cell});

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TrinaGrid(columns: [column], rows: [row]),
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

  group('TrinaDateTimeCell', () {
    group('popup icon rendering', () {
      testWidgets('Default icon should be rendered', (tester) async {
        await buildCellAndEdit(tester);
        expect(find.byIcon(Icons.event_available), findsOneWidget);
      });

      testWidgets('Custom icon should be rendered', (tester) async {
        final customIcon = Icons.add;
        await buildCellAndEdit(
          tester,
          column: getColumn(popupIcon: customIcon),
        );

        expect(find.byIcon(customIcon), findsOneWidget);
      });

      testWidgets('No icon should be rendered when popupIcon is null', (
        tester,
      ) async {
        await buildCellAndEdit(tester, column: getColumn(popupIcon: null));

        expect(
          find.descendant(
            of: find.byType(TrinaDateTimeCell),
            matching: find.byType(Icon),
          ),
          findsNothing,
        );
      });
    });
    testWidgets('should open popup on tap', (WidgetTester tester) async {
      await TestHelperUtil.changeWidth(tester: tester, width: 450, height: 600);

      await buildCellAndEdit(tester);
      await openPopup(tester);

      expect(find.byType(TrinaDatePicker), findsOneWidget);
      expect(find.byType(TrinaTimePicker), findsOneWidget);
    });

    testWidgets('OK button should be disabled when hour is invalid', (
      tester,
    ) async {
      final column = getColumn(
        startDate: DateTime(2023, 1, 10, 10, 0),
        endDate: DateTime(2023, 1, 12, 12, 0),
      );
      await buildCellAndEdit(
        tester,
        column: column,
        trinaCell: TrinaCell(value: '2023-01-11 11:00'),
      );
      await openPopup(tester);

      // Enter an invalid hour
      await tester.enterText(hourFieldFinder, '25');
      await tester.pump();

      // OK button should be disabled
      expect(tester.widget<TextButton>(okButtonFinder).onPressed, isNull);

      // Enter a valid hour
      await tester.enterText(hourFieldFinder, '11');
      await tester.pump();

      // OK button should be enabled
      expect(tester.widget<TextButton>(okButtonFinder).onPressed, isNotNull);
    });
    testWidgets('OK button should be disabled when minute is invalid', (
      tester,
    ) async {
      final okButtonFinder = find.widgetWithText(TextButton, 'OK');
      final column = getColumn(
        startDate: DateTime(2023, 1, 10, 10, 0),
        endDate: DateTime(2023, 1, 12, 12, 0),
      );
      await buildCellAndEdit(
        tester,
        column: column,
        trinaCell: TrinaCell(value: '2023-01-11 11:00'),
      );
      await openPopup(tester);

      // Enter an invalid minute
      await tester.enterText(minuteFieldFinder, '88');
      await tester.pump();

      // OK button should be disabled
      expect(tester.widget<TextButton>(okButtonFinder).onPressed, isNull);

      // Enter a valid minute
      await tester.enterText(minuteFieldFinder, '11');
      await tester.pump();

      // OK button should be enabled
      expect(tester.widget<TextButton>(okButtonFinder).onPressed, isNotNull);
    });
    testWidgets('Tapping Cancel button should close popup', (tester) async {
      final cancelTextButtonFinder = find.widgetWithText(TextButton, 'Cancel');
      await buildCellAndEdit(tester);
      await openPopup(tester);
      await tester.tap(cancelTextButtonFinder);
      await tester.pumpAndSettle();

      expect(find.byType(TrinaTimePicker), findsNothing);
      expect(find.byType(TrinaDatePicker), findsNothing);
    });
    testWidgets('Tapping outside the popup should close popup', (tester) async {
      await buildCellAndEdit(tester);
      await openPopup(tester);
      // Tap at the top-left corner of the screen, far from typical popup position
      await tester.tapAt(Offset(1, 1));
      await tester.pumpAndSettle();

      expect(find.byType(TrinaTimePicker), findsNothing);
      expect(find.byType(TrinaDatePicker), findsNothing);
    });

    testWidgets('pressing Escape key should close popup', (tester) async {
      await buildCellAndEdit(tester);
      await openPopup(tester);

      // Press the escape key
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();

      // Verify the popup is closed
      expect(find.byType(TrinaTimePicker), findsNothing);
      expect(find.byType(TrinaDatePicker), findsNothing);
    });
  });

  group('Value Update', () {
    testWidgets(
      'should update cell value when a new date and time are selected',
      (tester) async {
        await buildCellAndEdit(tester);
        await openPopup(tester);

        // Select a new date
        await tester.tap(find.text('15'));
        await tester.pump();

        // Select a new time
        await tester.enterText(hourFieldFinder, '14');
        await tester.pump();
        await tester.enterText(minuteFieldFinder, '45');
        await tester.pump();

        // Click OK
        await tester.tap(okButtonFinder);
        await tester.pumpAndSettle();

        // Verify the cell value is updated
        expect(cell.value, '2023-01-15 14:45');
      },
    );
  });

  group('Date-Based Validation', () {
    testWidgets(
      'selecting a date before startDate should not change the value',
      (tester) async {
        final column = getColumn(
          startDate: DateTime(2023, 1, 10),
          endDate: DateTime(2023, 1, 20),
        );
        await buildCellAndEdit(
          tester,
          column: column,
          trinaCell: TrinaCell(value: '2023-01-15 12:00'),
        );
        await openPopup(tester);

        // Attempt to select a date before startDate
        await tester.tap(find.text('5'));
        await tester.pumpAndSettle();

        // Click OK
        await tester.tap(okButtonFinder);
        await tester.pumpAndSettle();

        // Verify the cell value has not changed
        expect(cell.value, '2023-01-15 12:00');
      },
    );

    testWidgets('selecting a date after endDate should not change the value', (
      tester,
    ) async {
      final column = getColumn(
        startDate: DateTime(2023, 1, 10),
        endDate: DateTime(2023, 1, 20),
      );
      await buildCellAndEdit(
        tester,
        column: column,
        trinaCell: TrinaCell(value: '2023-01-15 12:00'),
      );
      await openPopup(tester);

      // Attempt to select a date after endDate
      await tester.tap(find.text('25'));
      await tester.pumpAndSettle();

      // Click OK
      await tester.tap(okButtonFinder);
      await tester.pumpAndSettle();

      // Verify the cell value has not changed
      expect(cell.value, '2023-01-15 12:00');
    });
  });

  group('Initial Value Fallback', () {
    testWidgets(
      'should fall back to DateTime.now() when cell value is invalid',
      (tester) async {
        final now = DateTime.now();
        final column = getColumn(
          startDate: now.subtract(const Duration(days: 1)),
          endDate: now.add(const Duration(days: 1)),
        );
        // Invalid cell value
        await buildCellAndEdit(
          tester,
          column: column,
          trinaCell: TrinaCell(value: 'invalid-date'),
        );
        await openPopup(tester);

        // The picker should show today's date
        expect(find.text(now.day.toString()), findsOneWidget);
      },
    );

    testWidgets(
      'should fall back to startDate when cell value and DateTime.now() are invalid',
      (tester) async {
        final now = DateTime.now();
        final startDate = now.add(const Duration(days: 5));
        final column = getColumn(
          startDate: startDate,
          endDate: startDate.add(const Duration(days: 5)),
        );
        // Invalid cell value
        await buildCellAndEdit(
          tester,
          column: column,
          trinaCell: TrinaCell(value: 'invalid-date'),
        );
        await openPopup(tester);

        // The picker should show the start date
        expect(find.text(startDate.day.toString()), findsOneWidget);
      },
    );

    testWidgets('should have OK button disabled when all fallbacks are invalid', (
      tester,
    ) async {
      final now = DateTime.now();
      final endDate = now.subtract(const Duration(days: 5));
      final column = getColumn(startDate: null, endDate: endDate);
      // Invalid cell value
      await buildCellAndEdit(
        tester,
        column: column,
        trinaCell: TrinaCell(value: 'invalid-date'),
      );
      await openPopup(tester);

      // OK button should be disabled because no valid initial date could be determined
      expect(tester.widget<TextButton>(okButtonFinder).onPressed, isNull);
    });
  });
}
