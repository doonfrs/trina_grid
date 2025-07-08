import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:trina_grid/trina_grid.dart';
import 'package:trina_grid/src/ui/ui.dart';

import '../../../helper/trina_widget_test_helper.dart';
import '../../../helper/row_helper.dart';
import '../../../mock/shared_mocks.mocks.dart';

const selectItems = ['a', 'b', 'c'];

void main() {
  late MockTrinaGridStateManager stateManager;

  setUp(() {
    stateManager = MockTrinaGridStateManager();

    when(stateManager.configuration).thenReturn(
      const TrinaGridConfiguration(
        enterKeyAction: TrinaGridEnterKeyAction.toggleEditing,
        enableMoveDownAfterSelecting: false,
      ),
    );
    when(stateManager.keyPressed).thenReturn(TrinaGridKeyPressed());
    when(stateManager.columnHeight).thenReturn(
      stateManager.configuration.style.columnHeight,
    );
    when(stateManager.rowHeight).thenReturn(
      stateManager.configuration.style.rowHeight,
    );
    when(stateManager.headerHeight).thenReturn(
      stateManager.configuration.style.columnHeight,
    );
    when(stateManager.rowTotalHeight).thenReturn(
        RowHelper.resolveRowTotalHeight(stateManager.configuration.style));
    when(stateManager.localeText).thenReturn(const TrinaGridLocaleText());
    when(stateManager.keepFocus).thenReturn(true);
    when(stateManager.hasFocus).thenReturn(true);
  });

  group('Suffix icon rendering', () {
    final TrinaCell cell = TrinaCell(value: 'A');

    final TrinaRow row = TrinaRow(
      cells: {
        'column_field_name': cell,
      },
    );

    testWidgets('Default dropdown icon should be rendered', (tester) async {
      final TrinaColumn column = TrinaColumn(
        title: 'column title',
        field: 'column_field_name',
        type: TrinaColumnType.select(['A']),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: TrinaSelectCell(
              stateManager: stateManager,
              cell: cell,
              column: column,
              row: row,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.arrow_drop_down), findsOneWidget);
    });

    testWidgets('Custom icon should be rendered', (tester) async {
      final TrinaColumn column = TrinaColumn(
        title: 'column title',
        field: 'column_field_name',
        type: TrinaColumnType.select(
          ['A'],
          popupIcon: Icons.add,
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: TrinaSelectCell(
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

    testWidgets('When popupIcon is null, icon should not be rendered',
        (tester) async {
      final TrinaColumn column = TrinaColumn(
        title: 'column title',
        field: 'column_field_name',
        type: TrinaColumnType.select(
          ['A'],
          popupIcon: null,
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: TrinaSelectCell(
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

  group(
    'When enterKeyAction is TrinaGridEnterKeyAction.toggleEditing and '
    'enableMoveDownAfterSelecting is false',
    () {
      final TrinaColumn column = TrinaColumn(
        title: 'column title',
        field: 'column_field_name',
        type: TrinaColumnType.select(selectItems),
      );

      final TrinaCell cell = TrinaCell(value: selectItems.first);

      final TrinaRow row = TrinaRow(
        cells: {
          'column_field_name': cell,
        },
      );

      final cellWidget =
          TrinaWidgetTestHelper('Build and tap cell.', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Material(
              child: TrinaSelectCell(
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

      cellWidget.test('Pressing F2 should open the popup', (tester) async {
        await tester.sendKeyEvent(LogicalKeyboardKey.f2);

        expect(find.byType(TrinaGrid), findsOneWidget);
      });

      cellWidget.test(
          'After closing popup with ESC and pressing F2 again, popup should reopen',
          (tester) async {
        await tester.sendKeyEvent(LogicalKeyboardKey.f2);

        expect(find.byType(TrinaGrid), findsOneWidget);

        await tester.sendKeyEvent(LogicalKeyboardKey.escape);

        await tester.pumpAndSettle();

        expect(find.byType(TrinaGrid), findsNothing);

        await tester.sendKeyEvent(LogicalKeyboardKey.f2);

        await tester.pumpAndSettle();

        expect(find.byType(TrinaGrid), findsOneWidget);
      });

      cellWidget.test(
          'After selecting an item with arrow keys and enter, popup should be displayed again',
          (tester) async {
        await tester.sendKeyEvent(LogicalKeyboardKey.f2);

        expect(find.byType(TrinaGrid), findsOneWidget);

        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);

        await tester.pumpAndSettle();

        expect(find.byType(TrinaGrid), findsNothing);
        expect(find.text(selectItems[1]), findsNothing);

        await tester.sendKeyEvent(LogicalKeyboardKey.f2);

        await tester.pumpAndSettle();

        expect(find.byType(TrinaGrid), findsOneWidget);
      });
    },
  );

  group('Popup grid selection mode', () {
    makeSelectCell({bool selectWithSingleTap = false}) {
      TrinaColumn column = TrinaColumn(
        title: 'column title',
        field: 'column_field_name',
        type: TrinaColumnType.select(
          selectItems,
          selectWithSingleTap: selectWithSingleTap,
        ),
      );

      TrinaCell cell = TrinaCell(value: selectItems.first);

      final TrinaRow row = TrinaRow(cells: {'column_field_name': cell});

      return TrinaWidgetTestHelper('Create TrinaSelectCell', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Material(
              child: TrinaSelectCell(
                stateManager: stateManager,
                cell: cell,
                column: column,
                row: row,
              ),
            ),
          ),
        );
      });
    }

    makeSelectCell(selectWithSingleTap: false).test(
      'When selectWithSingleTap is false, grid selection mode should be cellWithCtrl',
      (tester) async {
        await tester.tap(find.byType(TextField));
        await tester.pumpAndSettle();
        final popupGrid = tester.widget<TrinaGrid>(find.byType(TrinaGrid));
        expect(
          popupGrid.configuration.selectingMode,
          TrinaGridSelectingMode.cellWithCtrl,
        );
      },
    );
    makeSelectCell(selectWithSingleTap: true).test(
      'When selectWithSingleTap is true, grid selection mode should be cellWithSingleTap',
      (tester) async {
        await tester.tap(find.byType(TextField));
        await tester.pumpAndSettle();
        final popupGrid = tester.widget<TrinaGrid>(find.byType(TrinaGrid));
        expect(
          popupGrid.configuration.selectingMode,
          TrinaGridSelectingMode.cellWithSingleTap,
        );
      },
    );
  });
}
