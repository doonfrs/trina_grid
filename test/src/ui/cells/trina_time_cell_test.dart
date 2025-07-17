import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:trina_grid/trina_grid.dart';
import 'package:trina_grid/src/ui/ui.dart';

import '../../../helper/trina_widget_test_helper.dart';
import '../../../helper/row_helper.dart';
import '../../../mock/shared_mocks.mocks.dart';

void main() {
  late MockTrinaGridStateManager stateManager;

  setUp(() {
    const configuration = TrinaGridConfiguration();
    stateManager = MockTrinaGridStateManager();
    when(stateManager.configuration).thenReturn(configuration);
    when(stateManager.style).thenReturn(configuration.style);
    when(stateManager.keyPressed).thenReturn(TrinaGridKeyPressed());
    when(stateManager.rowTotalHeight).thenReturn(
        RowHelper.resolveRowTotalHeight(stateManager.configuration.style));
    when(stateManager.localeText).thenReturn(const TrinaGridLocaleText());
    when(stateManager.keepFocus).thenReturn(true);
    when(stateManager.hasFocus).thenReturn(true);
  });

  BoxDecoration getCellDecoration(Finder cell) {
    final container = find
        .ancestor(
          of: cell,
          matching: find.byType(DecoratedBox),
        )
        .first
        .evaluate()
        .first
        .widget as DecoratedBox;

    return container.decoration as BoxDecoration;
  }

  TextStyle getCellTextStyle(Finder cell) {
    final text = cell.first.evaluate().first.widget as Text;

    return text.style as TextStyle;
  }

  group('Suffix icon rendering', () {
    final TrinaCell cell = TrinaCell(value: '12:30');

    final TrinaRow row = TrinaRow(
      cells: {
        'column_field_name': cell,
      },
    );

    testWidgets('Default time icon should be rendered', (tester) async {
      final TrinaColumn column = TrinaColumn(
        title: 'column title',
        field: 'column_field_name',
        type: TrinaColumnType.time(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: TrinaTimeCell(
              stateManager: stateManager,
              cell: cell,
              column: column,
              row: row,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.access_time), findsOneWidget);
    });

    testWidgets('Custom icon should be rendered', (tester) async {
      final TrinaColumn column = TrinaColumn(
        title: 'column title',
        field: 'column_field_name',
        type: TrinaColumnType.time(
          popupIcon: Icons.add,
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: TrinaTimeCell(
              stateManager: stateManager,
              cell: cell,
              column: column,
              row: row,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('No icon should be rendered when popupIcon is null',
        (tester) async {
      final TrinaColumn column = TrinaColumn(
        title: 'column title',
        field: 'column_field_name',
        type: TrinaColumnType.time(
          popupIcon: null,
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: TrinaTimeCell(
              stateManager: stateManager,
              cell: cell,
              column: column,
              row: row,
            ),
          ),
        ),
      );

      expect(find.byType(Icon), findsNothing);
    });
  });

  testWidgets('Cell value should be displayed', (WidgetTester tester) async {
    // given
    final TrinaColumn column = TrinaColumn(
      title: 'column title',
      field: 'column_field_name',
      type: TrinaColumnType.time(),
    );

    final TrinaCell cell = TrinaCell(value: '12:30');

    final TrinaRow row = TrinaRow(
      cells: {
        'column_field_name': cell,
      },
    );

    // when
    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: TrinaTimeCell(
            stateManager: stateManager,
            cell: cell,
            column: column,
            row: row,
          ),
        ),
      ),
    );

    // then
    expect(find.text('12:30'), findsOneWidget);
  });

  group('When cell is editable', () {
    final TrinaColumn column = TrinaColumn(
      title: 'column title',
      field: 'column_field_name',
      type: TrinaColumnType.time(),
    );

    final TrinaCell cell = TrinaCell(value: '12:30');

    final TrinaRow row = TrinaRow(cells: {'column_field_name': cell});

    final tapCell = TrinaWidgetTestHelper('Tap cell', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: TrinaTimeCell(
              stateManager: stateManager,
              cell: cell,
              column: column,
              row: row,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(TextField));
    });

    tapCell.test('Hour and minute columns should be called', (tester) async {
      expect(find.text('Hour'), findsOneWidget);
      expect(find.text('Minute'), findsOneWidget);
    });

    tapCell.test('Select 12:28', (tester) async {
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);

      verify(stateManager.handleAfterSelectingRow(cell, '12:28')).called(1);
    });

    tapCell.test('Select 12:33', (tester) async {
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);

      verify(stateManager.handleAfterSelectingRow(cell, '12:33')).called(1);
    });

    tapCell.test('Select 12:29', (tester) async {
      await tester.tap(find.text('29'));
      await tester.pump(kDoubleTapMinTime);
      await tester.tap(find.text('29'));
      verify(stateManager.handleAfterSelectingRow(cell, '12:29')).called(1);
    });

    tapCell.test('Select 15:28', (tester) async {
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);

      verify(stateManager.handleAfterSelectingRow(cell, '15:28')).called(1);
    });

    group('Active and inactive color check', () {
      late Color activatedCellColor;
      late Color activatedTextColor;
      late Color inactivatedCellColor;
      late Color inactivatedTextColor;

      setUp(() {
        activatedCellColor =
            stateManager.configuration.style.activatedBorderColor;
        activatedTextColor =
            stateManager.configuration.style.gridBackgroundColor;
        inactivatedCellColor =
            stateManager.configuration.style.gridBackgroundColor;
        inactivatedTextColor =
            stateManager.configuration.style.cellTextStyle.color!;
      });

      tapCell.test(
        'When 12:30 is selected, color should be inactive for 12 and active for 30',
        (tester) async {
          final hour = find.text('12');
          final hourContainerDecoration = getCellDecoration(hour);
          final hourTextStyle = getCellTextStyle(hour);

          final minute = find.text('30');
          final minuteContainerDecoration = getCellDecoration(minute);
          final minuteTextStyle = getCellTextStyle(minute);

          expect(hourContainerDecoration.color, inactivatedCellColor);
          expect(hourTextStyle.color, inactivatedTextColor);

          expect(minuteContainerDecoration.color, activatedCellColor);
          expect(minuteTextStyle.color, activatedTextColor);

          await tester.sendKeyEvent(LogicalKeyboardKey.enter);
          verify(stateManager.handleAfterSelectingRow(cell, '12:30')).called(1);
        },
      );

      tapCell.test(
        'When 12:30 is selected and left arrow key is pressed, '
        'color should be active for 12 and inactive for 30',
        (tester) async {
          await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
          await tester.pumpAndSettle();

          final hour = find.text('12');
          final hourTextStyle = getCellTextStyle(hour);
          final hourContainerDecoration = getCellDecoration(hour);

          final minute = find.text('30');
          final minuteContainerDecoration = getCellDecoration(minute);
          final minuteTextStyle = getCellTextStyle(minute);

          expect(hourContainerDecoration.color, activatedCellColor);
          expect(hourTextStyle.color, activatedTextColor);

          expect(minuteContainerDecoration.color, inactivatedCellColor);
          expect(minuteTextStyle.color, inactivatedTextColor);

          await tester.sendKeyEvent(LogicalKeyboardKey.enter);
          verify(stateManager.handleAfterSelectingRow(cell, '12:30')).called(1);
        },
      );

      tapCell.test(
        'When 12:30 is selected and down arrow key is pressed, '
        'color should be inactive for 30 and active for 31',
        (tester) async {
          await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
          await tester.pumpAndSettle();

          final min30 = find.text('30');
          final min30ContainerDecoration = getCellDecoration(min30);
          final min30TextStyle = getCellTextStyle(min30);

          final min31 = find.text('31');
          final min31ContainerDecoration = getCellDecoration(min31);
          final min31TextStyle = getCellTextStyle(min31);

          expect(min30ContainerDecoration.color, inactivatedCellColor);
          expect(min30TextStyle.color, inactivatedTextColor);

          expect(min31ContainerDecoration.color, activatedCellColor);
          expect(min31TextStyle.color, activatedTextColor);

          await tester.sendKeyEvent(LogicalKeyboardKey.enter);
          verify(stateManager.handleAfterSelectingRow(cell, '12:31')).called(1);
        },
      );

      tapCell.test(
        'When 12:30 is selected and up arrow key is pressed, '
        'color should be inactive for 30 and active for 29',
        (tester) async {
          await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
          await tester.pumpAndSettle();

          final min30 = find.text('30');
          final min30ContainerDecoration = getCellDecoration(min30);
          final min30TextStyle = getCellTextStyle(min30);

          final min29 = find.text('29');
          final min29ContainerDecoration = getCellDecoration(min29);
          final min29TextStyle = getCellTextStyle(min29);

          expect(min30ContainerDecoration.color, inactivatedCellColor);
          expect(min30TextStyle.color, inactivatedTextColor);

          expect(min29ContainerDecoration.color, activatedCellColor);
          expect(min29TextStyle.color, activatedTextColor);

          await tester.sendKeyEvent(LogicalKeyboardKey.enter);
          verify(stateManager.handleAfterSelectingRow(cell, '12:29')).called(1);
        },
      );

      tapCell.test(
        'When 12:30 is selected and left arrow then up arrow keys are pressed, '
        'color should be inactive for 30 and active for 11 (11:30)',
        (tester) async {
          await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
          await tester.pumpAndSettle();
          await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
          await tester.pumpAndSettle();

          final min30 = find.text('30');
          final min30ContainerDecoration = getCellDecoration(min30);
          final min30TextStyle = getCellTextStyle(min30);

          final hour11 = find.text('11');
          final hour11ContainerDecoration = getCellDecoration(hour11);
          final hour11TextStyle = getCellTextStyle(hour11);

          expect(min30ContainerDecoration.color, inactivatedCellColor);
          expect(min30TextStyle.color, inactivatedTextColor);

          expect(hour11ContainerDecoration.color, activatedCellColor);
          expect(hour11TextStyle.color, activatedTextColor);

          await tester.sendKeyEvent(LogicalKeyboardKey.enter);
          verify(stateManager.handleAfterSelectingRow(cell, '11:30')).called(1);
        },
      );
    });
  });
}
