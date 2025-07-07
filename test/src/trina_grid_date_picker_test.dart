import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart' as intl;
import 'package:mockito/mockito.dart';
import 'package:trina_grid/trina_grid.dart';
import 'package:trina_grid/src/ui/ui.dart';

import '../helper/trina_widget_test_helper.dart';
import '../matcher/trina_object_matcher.dart';
import '../mock/mock_methods.dart';

final now = DateTime.now();

final mockListener = MockMethods();

void main() {
  late TrinaGridStateManager stateManager;

  buildPopup({
    required String format,
    required String headerFormat,
    DateTime? initDate,
    DateTime? startDate,
    DateTime? endDate,
    TrinaOnLoadedEventCallback? onLoaded,
    TrinaOnSelectedEventCallback? onSelected,
    double? itemHeight,
    TrinaGridConfiguration? configuration,
    TextDirection textDirection = TextDirection.ltr,
  }) {
    final dateFormat = intl.DateFormat(format);

    final headerDateFormat = intl.DateFormat(headerFormat);

    return TrinaWidgetTestHelper('Build date picker.', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: Directionality(
              textDirection: textDirection,
              child: Builder(
                builder: (BuildContext context) {
                  return TextButton(
                    onPressed: () {
                      TrinaGridDatePicker(
                        context: context,
                        dateFormat: dateFormat,
                        headerDateFormat: headerDateFormat,
                        initDate: initDate,
                        startDate: startDate,
                        endDate: endDate,
                        onLoaded: onLoaded,
                        onSelected: onSelected,
                        itemHeight:
                            itemHeight ?? TrinaGridSettings.rowTotalHeight,
                        configuration:
                            configuration ?? const TrinaGridConfiguration(),
                      );
                    },
                    child: const Text('open date picker'),
                  );
                },
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(TextButton));

      await tester.pumpAndSettle();
    });
  }

  buildPopup(
    format: 'yyyy-MM-dd',
    headerFormat: 'yyyy-MM',
    onLoaded: (event) => stateManager = event.stateManager,
  ).test(
    'Directionality should be ltr by default',
    (tester) async {
      expect(stateManager.isLTR, true);
      expect(stateManager.isRTL, false);
    },
  );

  buildPopup(
    format: 'yyyy-MM-dd',
    headerFormat: 'yyyy-MM',
    onLoaded: (event) => stateManager = event.stateManager,
    textDirection: TextDirection.rtl,
  ).test(
    'When Directionality is rtl, it should be applied',
    (tester) async {
      expect(stateManager.isLTR, false);
      expect(stateManager.isRTL, true);
    },
  );

  buildPopup(
    format: 'yyyy-MM-dd',
    headerFormat: 'yyyy-MM',
    initDate: DateTime(2022, 7, 27),
    textDirection: TextDirection.rtl,
  ).test(
    'When Directionality is rtl, date cell positions should be applied in reverse of LTR',
    (tester) async {
      final day26 = find.ancestor(
        of: find.text('26'),
        matching: find.byType(TrinaBaseCell),
      );
      final day27 = find.ancestor(
        of: find.text('27'),
        matching: find.byType(TrinaBaseCell),
      );
      final day28 = find.ancestor(
        of: find.text('28'),
        matching: find.byType(TrinaBaseCell),
      );

      final day26Dx = tester.getTopRight(day26).dx;
      final day27Dx = tester.getTopRight(day27).dx;
      final day28Dx = tester.getTopRight(day28).dx;

      // When the width is 360, the columns and cells should be displayed in the correct width.
      expect(day26Dx - day27Dx, TrinaGridDatePicker.dateCellWidth);
      expect(day27Dx - day28Dx, TrinaGridDatePicker.dateCellWidth);
    },
  );

  buildPopup(
    format: 'yyyy-MM-dd',
    headerFormat: 'yyyy-MM',
    onLoaded: (event) => stateManager = event.stateManager,
  ).test(
    'DatePicker should not apply autoSizeMode and resizeMode',
    (tester) async {
      expect(stateManager.enableColumnsAutoSize, false);

      expect(stateManager.activatedColumnsAutoSize, false);

      expect(
        stateManager.columnSizeConfig.autoSizeMode,
        TrinaAutoSizeMode.none,
      );

      expect(
        stateManager.columnSizeConfig.resizeMode,
        TrinaResizeMode.none,
      );
    },
  );

  buildPopup(
    format: 'yyyy-MM-dd',
    headerFormat: 'yyyy-MM',
  ).test(
    'Widget should be created with the required height and width',
    (tester) async {
      final size = tester.getSize(find.byType(TrinaGrid));

      // 45 : default row width, 7 : Mon~Sun
      expect(size.width, greaterThan(45 * 7));

      // 6-week rows are displayed.
      double rowsHeight = 6 * TrinaGridSettings.rowTotalHeight;

      // itemHeight * 2 = Header Height + Column Height
      double popupHeight = (TrinaGridSettings.rowTotalHeight * 2) +
          rowsHeight +
          TrinaGridSettings.totalShadowLineWidth +
          TrinaGridSettings.gridInnerSpacing;

      expect(size.height, popupHeight);
    },
  );

  buildPopup(
    format: 'yyyy-MM-dd',
    headerFormat: 'yyyy-MM',
  ).test(
    'Year and month changing IconButtons should be displayed',
    (tester) async {
      expect(find.byType(IconButton), findsNWidgets(4));
    },
  );

  buildPopup(
    format: 'yyyy-MM-dd',
    headerFormat: 'yyyy-MM',
  ).test(
    'When initDate, startDate, and endDate are not provided, '
    'current month should be displayed',
    (tester) async {
      final headerFormat = intl.DateFormat('yyyy-MM');

      final currentYearMonth = headerFormat.format(now);

      const firstDay = '1';

      expect(find.text(currentYearMonth), findsOneWidget);

      expect(find.text(firstDay), findsOneWidget);
    },
  );

  buildPopup(
    format: 'yyyy-MM-dd',
    headerFormat: 'yyyy-MM',
    startDate: DateTime(2022, 5, 10),
  ).test(
    'When startDate is set, that month should be displayed',
    (tester) async {
      final headerFormat = intl.DateFormat('yyyy-MM');

      final currentYearMonth = headerFormat.format(DateTime(2022, 5, 10));

      expect(find.text(currentYearMonth), findsOneWidget);
    },
  );

  buildPopup(
    format: 'yyyy-MM-dd',
    headerFormat: 'yyyy-MM',
    initDate: DateTime(now.year, now.month, 20),
  ).test(
    'When initDate is set, that date should be selected',
    (tester) async {
      const selectedDay = '20';

      final selectedDayText = find.text(selectedDay).first;

      final selectedDayTextWidget =
          selectedDayText.first.evaluate().first.widget as Text;

      final selectedDayTextStyle = selectedDayTextWidget.style as TextStyle;

      expect(selectedDayText, findsOneWidget);

      expect(selectedDayTextStyle.color, Colors.white);

      final selectedDayWidget = find
          .ancestor(
            of: selectedDayText,
            matching: find.byType(DecoratedBox),
          )
          .first;

      final selectedDayContainer =
          selectedDayWidget.first.evaluate().first.widget as DecoratedBox;

      final decoration = selectedDayContainer.decoration as BoxDecoration;

      expect(selectedDayWidget, findsOneWidget);

      expect(decoration.color, Colors.lightBlue);
    },
  );

  buildPopup(
    format: 'yyyy-MM-dd',
    headerFormat: 'yyyy-MM',
    // This required so the cell of first-day-of-month is set as the current cell .
    initDate: DateTime(now.year, now.month, 1),
  ).test(
    'When selecting the 1st day of the current month and pressing the up arrow key, '
    'the previous month should be displayed',
    (tester) async {
      final headerFormat = intl.DateFormat('yyyy-MM');

      final currentMonthYear = headerFormat.format(now);

      expect(find.text(currentMonthYear), findsOneWidget);

      await tester.tap(find.text('2'));
      await tester.tap(find.text('1'));
      await tester.pumpAndSettle();

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pumpAndSettle();

      final expectDate = DateTime(now.year, now.month - 1);

      final expectMonthYear = headerFormat.format(expectDate);

      expect(find.text(expectMonthYear), findsOneWidget);
    },
  );

  buildPopup(
    format: 'yyyy-MM-dd',
    headerFormat: 'yyyy-MM',
    initDate: DateTime(2022, 6, 30),
  ).test(
    'When selecting June 30, 2022 and pressing the down arrow key, '
    'the next month should be displayed',
    (tester) async {
      final headerFormat = intl.DateFormat('yyyy-MM');

      final currentMonthYear = headerFormat.format(DateTime(2022, 6, 30));

      expect(find.text(currentMonthYear), findsOneWidget);

      await tester.sendKeyDownEvent(LogicalKeyboardKey.arrowDown);

      await tester.pumpAndSettle();

      final expectDate = DateTime(2022, 7);

      final expectMonthYear = headerFormat.format(expectDate);

      expect(find.text(expectMonthYear), findsOneWidget);
    },
  );

  buildPopup(
    format: 'yyyy-MM-dd',
    headerFormat: 'yyyy-MM',
    initDate: DateTime(2022, 6, 5),
  ).test(
    'When selecting June 5, 2022 and pressing the left arrow key, '
    'the previous year should be displayed',
    (tester) async {
      final headerFormat = intl.DateFormat('yyyy-MM');

      final currentMonthYear = headerFormat.format(DateTime(2022, 6, 5));

      expect(find.text(currentMonthYear), findsOneWidget);

      await tester.sendKeyDownEvent(LogicalKeyboardKey.arrowLeft);

      await tester.pump();

      final expectDate = DateTime(2021, 6);

      final expectMonthYear = headerFormat.format(expectDate);

      expect(find.text(expectMonthYear), findsOneWidget);
    },
  );

  buildPopup(
    format: 'yyyy-MM-dd',
    headerFormat: 'yyyy-MM',
    initDate: DateTime(2022, 6, 11),
  ).test(
    'When selecting June 11, 2022 and pressing the right arrow key, '
    'the next year should be displayed',
    (tester) async {
      final headerFormat = intl.DateFormat('yyyy-MM');

      final currentMonthYear = headerFormat.format(DateTime(2022, 6, 11));

      expect(find.text(currentMonthYear), findsOneWidget);

      await tester.sendKeyDownEvent(LogicalKeyboardKey.arrowRight);

      await tester.pump();

      final expectDate = DateTime(2023, 6);

      final expectMonthYear = headerFormat.format(expectDate);

      expect(find.text(expectMonthYear), findsOneWidget);
    },
  );

  buildPopup(
    format: 'yyyy-MM-dd',
    headerFormat: 'yyyy-MM',
    initDate: DateTime(2022, 6, 11),
    onSelected: mockListener.oneParamReturnVoid<TrinaGridOnSelectedEvent>,
  ).test(
    'When selecting(by double tap) June 11, 2022, '
    'onSelected callback should be called',
    (tester) async {
      await tester.tap(find.text('11'));
      await tester.pump(kDoubleTapMinTime);
      await tester.tap(find.text('11'));

      await tester.pumpAndSettle();

      verify(
        mockListener.oneParamReturnVoid(
            argThat(TrinaObjectMatcher<TrinaGridOnSelectedEvent>(rule: (event) {
          return event.lastSelectedCell?.value == '2022-06-11';
        }))),
      ).called(1);
    },
  );
  buildPopup(
    format: 'yyyy-MM-dd',
    headerFormat: 'yyyy-MM',
    initDate: DateTime(2022, 6, 11),
    onSelected: mockListener.oneParamReturnVoid<TrinaGridOnSelectedEvent>,
  ).test(
    'When selecting(by Enter Key) June 11, 2022, '
    'onSelected callback should be called',
    (tester) async {
      await tester.tap(find.text('11'));
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();

      verify(
        mockListener.oneParamReturnVoid(
            argThat(TrinaObjectMatcher<TrinaGridOnSelectedEvent>(rule: (event) {
          return event.lastSelectedCell?.value == '2022-06-11';
        }))),
      ).called(1);
    },
  );

  buildPopup(
    format: 'yyyy-MM-dd',
    headerFormat: 'yyyy-MM',
    initDate: DateTime(2022, 6, 11),
    onLoaded: mockListener.oneParamReturnVoid<TrinaGridOnLoadedEvent>,
  ).test(
    'When selecting June 11, 2022 and tapping, '
    'onLoaded callback should be called',
    (tester) async {
      await tester.tap(find.text('11'));

      await tester.pump();

      verify(
        mockListener.oneParamReturnVoid(
          argThat(
            isA<TrinaGridOnLoadedEvent>(),
          ),
        ),
      ).called(1);
    },
  );
}
