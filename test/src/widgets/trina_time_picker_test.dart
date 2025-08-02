import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trina_grid/src/trina_grid_enums.dart';
import 'package:trina_grid/src/ui/widgets/trina_time_picker.dart';

void main() {
  const defaultInitialTime = TimeOfDay(hour: 12, minute: 30);
  TimeOfDay? currentTime;

  final hourFieldFinder = find.byWidgetPredicate(
    (widget) => widget is TextField && widget.decoration?.helperText == 'Hour',
  );
  final minuteFieldFinder = find.byWidgetPredicate(
    (widget) =>
        widget is TextField && widget.decoration?.helperText == 'Minute',
  );

  const invalidHourText = 'Invalid hour';
  const invalidMinuteText = 'Invalid minute';
  const minTimeErrorText = 'Min time is 00:00';
  const maxTimeErrorText = 'Max time is 23:59';

  String? getHourFieldValue(WidgetTester tester) {
    return tester.widget<TextField>(hourFieldFinder).controller?.text;
  }

  String? getMinuteFieldValue(WidgetTester tester) {
    return tester.widget<TextField>(minuteFieldFinder).controller?.text;
  }

  Future<void> buildWidget(
    WidgetTester tester, {
    TimeOfDay initialTime = defaultInitialTime,
    TrinaTimePickerAutoFocusMode autoFocusMode =
        TrinaTimePickerAutoFocusMode.hourField,
    TimeOfDay minTime = const TimeOfDay(hour: 0, minute: 0),
    TimeOfDay maxTime = const TimeOfDay(hour: 23, minute: 59),
    void Function(TimeOfDay time)? onChanged,
    void Function(TimeOfDay time)? onEnterKeyEvent,
    FocusNode? hourFocusNode,
    FocusNode? minuteFocusNode,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TrinaTimePicker(
            autoFocusMode: autoFocusMode,
            minTime: minTime,
            maxTime: maxTime,
            initialTime: initialTime,
            maxTimeErrorText: maxTimeErrorText,
            minTimeErrorText: minTimeErrorText,
            invalidHourText: invalidHourText,
            invalidMinuteText: invalidMinuteText,
            onChanged: (time) {
              currentTime = time;
              onChanged?.call(time);
            },
            onEnterKeyEvent: onEnterKeyEvent,
            hourFocusNode: hourFocusNode,
            minuteFocusNode: minuteFocusNode,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
  }

  setUp(() {
    currentTime = null;
  });

  group('TrinaTimePicker', () {
    group('initialization', () {
      testWidgets('should display the initial time', (tester) async {
        await buildWidget(tester);
        expect(getHourFieldValue(tester), '12');
        expect(getMinuteFieldValue(tester), '30');
      });

      testWidgets('should focus hour field when autoFocusMode is hourField', (
        tester,
      ) async {
        final hourFocusNode = FocusNode();
        await buildWidget(
          tester,
          autoFocusMode: TrinaTimePickerAutoFocusMode.hourField,
          hourFocusNode: hourFocusNode,
        );
        expect(hourFocusNode.hasFocus, isTrue);
      });

      testWidgets(
        'should focus minute field when autoFocusMode is minuteField',
        (tester) async {
          final minuteFocusNode = FocusNode();
          await buildWidget(
            tester,
            autoFocusMode: TrinaTimePickerAutoFocusMode.minuteField,
            minuteFocusNode: minuteFocusNode,
          );
          expect(minuteFocusNode.hasFocus, isTrue);
        },
      );

      testWidgets('should not focus any field when autoFocusMode is none', (
        tester,
      ) async {
        final hourFocusNode = FocusNode();
        final minuteFocusNode = FocusNode();
        await buildWidget(
          tester,
          autoFocusMode: TrinaTimePickerAutoFocusMode.none,
          hourFocusNode: hourFocusNode,
          minuteFocusNode: minuteFocusNode,
        );
        expect(hourFocusNode.hasFocus, isFalse);
        expect(minuteFocusNode.hasFocus, isFalse);
      });
    });

    group('selecting with arrow keys', () {
      group('autoFocusMode is hourField, initial time is 12:30', () {
        testWidgets('Pressing down arrow twice, should select 10:30', (
          tester,
        ) async {
          await buildWidget(
            tester,
            autoFocusMode: TrinaTimePickerAutoFocusMode.hourField,
          );

          await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
          await tester.pump();
          await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
          await tester.pump();

          expect(getHourFieldValue(tester), '10');
          expect(getMinuteFieldValue(tester), '30');
          expect(currentTime, const TimeOfDay(hour: 10, minute: 30));
        });
        testWidgets('Pressing up arrow twice should select 14:30', (
          tester,
        ) async {
          await buildWidget(
            tester,
            autoFocusMode: TrinaTimePickerAutoFocusMode.hourField,
          );

          await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
          await tester.pump();
          await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
          await tester.pump();

          expect(getHourFieldValue(tester), '14');
          expect(getMinuteFieldValue(tester), '30');
          expect(currentTime, const TimeOfDay(hour: 14, minute: 30));
        });
        testWidgets('pressing TAB should focus minute field', (tester) async {
          final minuteFocusNode = FocusNode();
          await buildWidget(
            tester,
            autoFocusMode: TrinaTimePickerAutoFocusMode.hourField,
            minuteFocusNode: minuteFocusNode,
          );

          await tester.sendKeyEvent(LogicalKeyboardKey.tab);
          await tester.pump();

          expect(minuteFocusNode.hasFocus, isTrue);
        });
      });

      group('autoFocusMode is minuteField, initial time is 12:30', () {
        testWidgets('Pressing down arrow twice should select 12:28', (
          tester,
        ) async {
          await buildWidget(
            tester,
            autoFocusMode: TrinaTimePickerAutoFocusMode.minuteField,
          );

          await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
          await tester.pump();
          await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
          await tester.pump();

          expect(getHourFieldValue(tester), '12');
          expect(getMinuteFieldValue(tester), '28');
          expect(currentTime, const TimeOfDay(hour: 12, minute: 28));
        });
        testWidgets('Pressing up arrow twice should select 12:32', (
          tester,
        ) async {
          await buildWidget(
            tester,
            autoFocusMode: TrinaTimePickerAutoFocusMode.minuteField,
          );

          await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
          await tester.pump();
          await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
          await tester.pump();

          expect(getHourFieldValue(tester), '12');
          expect(getMinuteFieldValue(tester), '32');
          expect(currentTime, const TimeOfDay(hour: 12, minute: 32));
        });
        testWidgets('pressing SHIFT+TAB should focus hour field', (
          tester,
        ) async {
          final hourFocusNode = FocusNode();
          await buildWidget(
            tester,
            autoFocusMode: TrinaTimePickerAutoFocusMode.minuteField,
            hourFocusNode: hourFocusNode,
          );

          await tester.sendKeyDownEvent(LogicalKeyboardKey.shift);
          await tester.sendKeyEvent(LogicalKeyboardKey.tab);
          await tester.sendKeyUpEvent(LogicalKeyboardKey.shift);
          await tester.pump();

          expect(hourFocusNode.hasFocus, isTrue);
        });
      });
    });

    group('text input', () {
      testWidgets('entering valid hour should update time', (tester) async {
        await buildWidget(tester);
        await tester.enterText(hourFieldFinder, '15');
        await tester.pump();
        expect(currentTime, const TimeOfDay(hour: 15, minute: 30));
      });

      testWidgets('entering valid minute should update time', (tester) async {
        await buildWidget(tester);
        await tester.enterText(minuteFieldFinder, '45');
        await tester.pumpAndSettle();
        expect(currentTime, const TimeOfDay(hour: 12, minute: 45));
      });

      testWidgets('entering invalid hour should show error', (tester) async {
        await buildWidget(tester);
        await tester.enterText(hourFieldFinder, '24');
        await tester.pumpAndSettle();
        expect(find.text(invalidHourText), findsOneWidget);
      });

      testWidgets('entering invalid minute should show error', (tester) async {
        await buildWidget(tester);
        await tester.enterText(minuteFieldFinder, '60');
        await tester.pumpAndSettle();
        expect(find.text(invalidMinuteText), findsOneWidget);
      });
    });

    group('min/max time validation', () {
      group('hour field validation with arrow keys', () {
        testWidgets(
          'Pressing up arrow when hour is at maxTime should not change hour',
          (tester) async {
            const initialHour = 12;
            await buildWidget(
              tester,
              autoFocusMode: TrinaTimePickerAutoFocusMode.hourField,
              minTime: const TimeOfDay(hour: 10, minute: 0),
              maxTime: const TimeOfDay(hour: 12, minute: 0),
              initialTime: const TimeOfDay(hour: initialHour, minute: 0),
            );

            await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
            await tester.pump();

            expect(getHourFieldValue(tester), initialHour.toString());
          },
        );

        testWidgets(
          'Pressing down arrow when hour is at minTime should not change hour',
          (tester) async {
            const initialHour = 10;
            await buildWidget(
              tester,
              autoFocusMode: TrinaTimePickerAutoFocusMode.hourField,
              minTime: const TimeOfDay(hour: 10, minute: 0),
              maxTime: const TimeOfDay(hour: 12, minute: 0),
              initialTime: const TimeOfDay(hour: initialHour, minute: 30),
            );

            await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
            await tester.pump();

            expect(getHourFieldValue(tester), initialHour.toString());
          },
        );

        testWidgets(
          'Pressing up arrow when hour is within range should increment hour',
          (tester) async {
            const initialHour = 11;
            await buildWidget(
              tester,
              autoFocusMode: TrinaTimePickerAutoFocusMode.hourField,
              minTime: const TimeOfDay(hour: 10, minute: 0),
              maxTime: const TimeOfDay(hour: 12, minute: 0),
              initialTime: TimeOfDay(hour: initialHour, minute: 0),
            );

            // act
            await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
            await tester.pump();

            // assert
            expect(getHourFieldValue(tester), '${initialHour + 1}');
          },
        );

        testWidgets(
          'Pressing down arrow when hour is within range should decrement hour',
          (tester) async {
            const initialHour = 11;
            await buildWidget(
              tester,
              autoFocusMode: TrinaTimePickerAutoFocusMode.hourField,
              minTime: const TimeOfDay(hour: 10, minute: 0),
              maxTime: const TimeOfDay(hour: 12, minute: 0),
              initialTime: TimeOfDay(hour: initialHour, minute: 30),
            );

            // act
            await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
            await tester.pump();

            // assert
            expect(getHourFieldValue(tester), '${initialHour - 1}');
          },
        );
      });
      group('minute field validation with arrow keys', () {
        testWidgets(
          'Pressing up arrow when minute is at maxTime should not change minute',
          (tester) async {
            const initialMinute = 15;
            await buildWidget(
              tester,
              autoFocusMode: TrinaTimePickerAutoFocusMode.minuteField,
              minTime: const TimeOfDay(hour: 10, minute: 0),
              maxTime: const TimeOfDay(hour: 10, minute: 15),
              initialTime: const TimeOfDay(hour: 10, minute: initialMinute),
            );

            await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
            await tester.pump();

            expect(getMinuteFieldValue(tester), initialMinute.toString());
          },
        );

        testWidgets(
          'Pressing down arrow when minute is at minTime should not change minute',
          (tester) async {
            const initialMinute = 10;
            await buildWidget(
              tester,
              autoFocusMode: TrinaTimePickerAutoFocusMode.minuteField,
              minTime: const TimeOfDay(hour: 10, minute: 10),
              maxTime: const TimeOfDay(hour: 10, minute: 15),
              initialTime: const TimeOfDay(hour: 10, minute: initialMinute),
            );

            await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
            await tester.pump();

            expect(getMinuteFieldValue(tester), initialMinute.toString());
          },
        );
        testWidgets(
          'Pressing up arrow when minute is within range should increment minute',
          (tester) async {
            const initialMinute = 2;
            await buildWidget(
              tester,
              autoFocusMode: TrinaTimePickerAutoFocusMode.minuteField,
              minTime: const TimeOfDay(hour: 10, minute: 0),
              maxTime: const TimeOfDay(hour: 10, minute: 5),
              initialTime: TimeOfDay(hour: 10, minute: initialMinute),
            );

            // act
            await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
            await tester.pump();

            // assert
            expect(getMinuteFieldValue(tester), '0${initialMinute + 1}');
          },
        );

        testWidgets(
          'Pressing down arrow when minute is within range should decrement minute',
          (tester) async {
            const initialMinute = 2;
            await buildWidget(
              tester,
              autoFocusMode: TrinaTimePickerAutoFocusMode.minuteField,
              minTime: const TimeOfDay(hour: 10, minute: 0),
              maxTime: const TimeOfDay(hour: 10, minute: 5),
              initialTime: TimeOfDay(hour: 10, minute: initialMinute),
            );

            // act
            await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
            await tester.pump();

            // assert
            expect(getMinuteFieldValue(tester), '0${initialMinute - 1}');
          },
        );
      });

      group('text input validation', () {
        testWidgets('entering hour less than minTime should show error', (
          tester,
        ) async {
          await buildWidget(
            tester,
            minTime: const TimeOfDay(hour: 10, minute: 0),
          );
          await tester.enterText(hourFieldFinder, '9');
          await tester.pumpAndSettle();

          expect(find.text(minTimeErrorText), findsOneWidget);
        });

        testWidgets('entering hour greater than maxTime should show error', (
          tester,
        ) async {
          await buildWidget(
            tester,
            maxTime: const TimeOfDay(hour: 14, minute: 0),
          );
          await tester.enterText(hourFieldFinder, '15');
          await tester.pumpAndSettle();
          expect(find.text(maxTimeErrorText), findsOneWidget);
        });
      });
    });

    group('callbacks', () {
      testWidgets('onChanged is called when time is changed via arrows', (
        tester,
      ) async {
        TimeOfDay? newTime;
        await buildWidget(tester, onChanged: (time) => newTime = time);

        await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
        await tester.pump();

        expect(newTime, const TimeOfDay(hour: 13, minute: 30));
      });

      testWidgets('onChanged is called when time is changed via text input', (
        tester,
      ) async {
        TimeOfDay? newTime;
        await buildWidget(tester, onChanged: (time) => newTime = time);

        await tester.enterText(hourFieldFinder, '14');
        await tester.pump();

        expect(newTime, const TimeOfDay(hour: 14, minute: 30));
      });

      testWidgets('onEnterKeyEvent is called when Enter is pressed', (
        tester,
      ) async {
        TimeOfDay? enteredTime;
        await buildWidget(
          tester,
          onEnterKeyEvent: (time) => enteredTime = time,
        );

        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pump();

        expect(enteredTime, defaultInitialTime);
      });
    });

    group('wrapping behavior', () {
      testWidgets(
        'incrementing hour from 23 should not wrap to 0 if not in range',
        (tester) async {
          await buildWidget(
            tester,
            initialTime: const TimeOfDay(hour: 23, minute: 30),
            maxTime: const TimeOfDay(hour: 23, minute: 59),
          );
          await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
          await tester.pump();
          expect(getHourFieldValue(tester), '23');
        },
      );

      testWidgets(
        'decrementing hour from 0 should not wrap to 23 if not in range',
        (tester) async {
          await buildWidget(
            tester,
            initialTime: const TimeOfDay(hour: 0, minute: 30),
            minTime: const TimeOfDay(hour: 0, minute: 0),
          );
          await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
          await tester.pump();
          expect(getHourFieldValue(tester), '00');
        },
      );

      testWidgets(
        'incrementing minute from 59 should not wrap to 0 if not in range',
        (tester) async {
          await buildWidget(
            tester,
            initialTime: const TimeOfDay(hour: 12, minute: 59),
            maxTime: const TimeOfDay(hour: 12, minute: 59),
            autoFocusMode: TrinaTimePickerAutoFocusMode.minuteField,
          );
          await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
          await tester.pump();
          expect(getMinuteFieldValue(tester), '59');
        },
      );

      testWidgets(
        'decrementing minute from 0 should not wrap to 59 if not in range',
        (tester) async {
          await buildWidget(
            tester,
            initialTime: const TimeOfDay(hour: 12, minute: 0),
            minTime: const TimeOfDay(hour: 12, minute: 0),
            autoFocusMode: TrinaTimePickerAutoFocusMode.minuteField,
          );
          await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
          await tester.pump();
          expect(getMinuteFieldValue(tester), '00');
        },
      );
    });
  });
}
