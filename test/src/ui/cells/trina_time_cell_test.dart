import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trina_grid/src/ui/ui.dart';
import 'package:trina_grid/src/ui/widgets/trina_time_picker.dart';
import 'package:trina_grid/trina_grid.dart';

import '../../../helper/column_helper.dart';

void main() {
  final defaultCellValue = '12:30';
  late TrinaGridStateManager stateManager;
  late TrinaCell cell;

  TrinaColumn getColumn({
    IconData? popupIcon = Icons.access_time,
    TrinaTimePickerAutoFocusMode autoFocusMode =
        TrinaTimePickerAutoFocusMode.hourField,
    bool saveAndClosePopupWithEnter = true,
    TimeOfDay minTime = const TimeOfDay(hour: 0, minute: 0),
    TimeOfDay maxTime = const TimeOfDay(hour: 23, minute: 59),
  }) {
    return ColumnHelper.timeColumn(
      'time_column',
      autoFocusMode: autoFocusMode,
      saveAndClosePopupWithEnter: saveAndClosePopupWithEnter,
      minTime: minTime,
      maxTime: maxTime,
      popupIcon: popupIcon,
      enableAutoEditing: true,
    ).first;
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
          body: TrinaGrid(
            columns: [column],
            rows: [row],
            onLoaded: (event) {
              stateManager = event.stateManager;
            },
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    await tester.tap(find.text(cell.value));
    await tester.pump();
  }

  Future<void> openPopup(WidgetTester tester) async {
    await tester.tap(find.byIcon(cell.column.type.time.popupIcon!));
    await tester.pumpAndSettle();
  }

  group('Suffix icon rendering', () {
    testWidgets('Default icon should be rendered', (tester) async {
      await buildCellAndEdit(tester);
      expect(find.byIcon(Icons.access_time), findsOneWidget);
    });

    testWidgets('Custom icon should be rendered', (tester) async {
      final customIcon = Icons.add;
      await buildCellAndEdit(tester, column: getColumn(popupIcon: customIcon));

      expect(find.byIcon(customIcon), findsOneWidget);
    });

    testWidgets('No icon should be rendered when popupIcon is null', (
      tester,
    ) async {
      await buildCellAndEdit(tester, column: getColumn(popupIcon: null));

      expect(
        find.descendant(
            of: find.byType(TrinaTimeCell), matching: find.byType(Icon)),
        findsNothing,
      );
    });
  });

  testWidgets('Cell value should be displayed', (WidgetTester tester) async {
    // given
    await buildCellAndEdit(tester, trinaCell: TrinaCell(value: '12:30'));
    // assert
    expect(find.text('12:30'), findsOneWidget);
  });

  group('when popup is opened', () {
    final okTextButtonFinder = find.widgetWithText(TextButton, 'OK');
    final hourFieldFinder = find.byWidgetPredicate((widget) =>
        widget is TextField && widget.decoration?.helperText == 'Hour');
    final minuteFieldFinder = find.byWidgetPredicate((widget) =>
        widget is TextField && widget.decoration?.helperText == 'Minute');
    testWidgets('Tapping Cancel button should close popup', (tester) async {
      final cancelTextButtonFinder = find.widgetWithText(TextButton, 'Cancel');
      await buildCellAndEdit(tester);
      await openPopup(tester);
      await tester.tap(cancelTextButtonFinder);
      await tester.pumpAndSettle();

      expect(find.byType(TrinaTimePicker), findsNothing);
    });
    group('Enter key event', () {
      testWidgets(
        'when saveAndClosePopupWithEnter is true, should save and close popup',
        (tester) async {
          final column = getColumn(saveAndClosePopupWithEnter: true);
          await buildCellAndEdit(
            tester,
            column: column,
          );
          await openPopup(tester);
          const newHour = '11';
          const newMinute = '00';

          // act

          await tester.enterText(hourFieldFinder, newHour);
          await tester.enterText(minuteFieldFinder, newMinute);
          await tester.pump();

          await tester.sendKeyEvent(LogicalKeyboardKey.enter);
          await tester.pumpAndSettle();
          // assert

          expect(stateManager.currentCell?.value, '$newHour:$newMinute');
          expect(find.byType(TrinaTimePicker), findsNothing);
        },
      );
      testWidgets(
          'when saveAndClosePopupWithEnter is false, should not save and close popup',
          (tester) async {
        final column = getColumn(
          saveAndClosePopupWithEnter: false,
        );
        await buildCellAndEdit(
          tester,
          column: column,
          trinaCell: TrinaCell(value: defaultCellValue),
        );
        await openPopup(tester);

        // act

        await tester.enterText(hourFieldFinder, '11');
        await tester.pump();

        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pumpAndSettle();
        // assert
        expect(stateManager.currentCell?.value, defaultCellValue);
        expect(find.byType(TrinaTimePicker), findsOneWidget);
      });
    });
    group('Popup Buttons', () {
      testWidgets(
        'OK button should be disabled when time is invalid',
        (tester) async {
          final column = getColumn(
            minTime: const TimeOfDay(hour: 10, minute: 0),
            maxTime: const TimeOfDay(hour: 12, minute: 0),
          );
          await buildCellAndEdit(
            tester,
            column: column,
            trinaCell: TrinaCell(value: '11:00'),
          );
          await openPopup(tester);

          // Enter an invalid hour
          await tester.enterText(hourFieldFinder, '25');
          await tester.pump();

          // OK button should be disabled
          expect(
              tester.widget<TextButton>(okTextButtonFinder).onPressed, isNull);

          // Enter a valid hour
          await tester.enterText(hourFieldFinder, '11');
          await tester.pump();

          // OK button should be enabled
          expect(
            tester.widget<TextButton>(okTextButtonFinder).onPressed,
            isNotNull,
          );
        },
      );
      testWidgets(
        'OK button should be disabled when minute is invalid',
        (tester) async {
          final column = getColumn(
            minTime: const TimeOfDay(hour: 10, minute: 0),
            maxTime: const TimeOfDay(hour: 12, minute: 0),
          );
          await buildCellAndEdit(
            tester,
            column: column,
            trinaCell: TrinaCell(value: '11:00'),
          );
          await openPopup(tester);

          // Enter an invalid minute
          await tester.enterText(minuteFieldFinder, '65');
          await tester.pump();

          // OK button should be disabled
          expect(
            tester.widget<TextButton>(okTextButtonFinder).onPressed,
            isNull,
          );

          // Enter a valid minute
          await tester.enterText(minuteFieldFinder, '30');
          await tester.pump();

          // OK button should be enabled
          expect(
            tester.widget<TextButton>(okTextButtonFinder).onPressed,
            isNotNull,
          );
        },
      );
      testWidgets(
        'OK button should be disabled when time is out of min/max range',
        (tester) async {
          final column = getColumn(
            minTime: const TimeOfDay(hour: 10, minute: 0),
            maxTime: const TimeOfDay(hour: 12, minute: 0),
          );
          await buildCellAndEdit(
            tester,
            column: column,
            trinaCell: TrinaCell(value: '11:00'),
          );
          await openPopup(tester);

          // act

          // Enter a time before minTime
          await tester.enterText(hourFieldFinder, '09');
          await tester.pumpAndSettle();

          // OK button should be disabled
          expect(
            tester.widget<TextButton>(okTextButtonFinder).onPressed,
            isNull,
          );

          // Enter a time after maxTime
          await tester.enterText(hourFieldFinder, '13');
          await tester.pumpAndSettle();

          // OK button should be disabled
          expect(
            tester.widget<TextButton>(okTextButtonFinder).onPressed,
            isNull,
          );

          // Enter a valid time
          await tester.enterText(hourFieldFinder, '11');
          await tester.pump();

          // OK button should be enabled again
          expect(
            tester.widget<TextButton>(okTextButtonFinder).onPressed,
            isNotNull,
          );
        },
      );
      testWidgets('Pressing Ok button should close the popup', (tester) async {
        await buildCellAndEdit(
          tester,
        );
        await openPopup(tester);

        // act

        await tester.tap(find.text('OK'));
        await tester.pumpAndSettle();
        // assert
        expect(find.byType(TrinaTimePicker), findsNothing);
      });
      testWidgets(
        'When new time is valid, pressing OK should update cell value',
        (tester) async {
          await buildCellAndEdit(
            tester,
            trinaCell: TrinaCell(value: '10:00'),
            column: getColumn(
              minTime: const TimeOfDay(hour: 10, minute: 0),
              maxTime: const TimeOfDay(hour: 12, minute: 0),
            ),
          );
          await openPopup(tester);

          // act

          await tester.enterText(hourFieldFinder, '11');
          await tester.pump();

          await tester.tap(okTextButtonFinder);
          await tester.pumpAndSettle();
          // assert
          expect(stateManager.currentCell?.value, '11:00');
        },
      );
    });
  });
}
