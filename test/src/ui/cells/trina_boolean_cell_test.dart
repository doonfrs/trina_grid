import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:trina_grid/src/ui/cells/trina_boolean_cell.dart';
import 'package:trina_grid/trina_grid.dart';

import '../../../helper/row_helper.dart';
import '../../../helper/trina_widget_test_helper.dart';
import '../../../mock/shared_mocks.mocks.dart';

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
    // when(stateManager.localeText).thenReturn(const TrinaGridLocaleText());
    when(stateManager.keepFocus).thenReturn(true);
    when(stateManager.hasFocus).thenReturn(true);
  });

  group('TrinaBooleanCell ', () {
    makeDateCell() {
      TrinaColumn column = TrinaColumn(
        title: 'column title',
        field: 'column_field_name',
        type: TrinaColumnType.boolean(),
      );

      TrinaCell cell = TrinaCell(value: true);

      final TrinaRow row = TrinaRow(cells: {'column_field_name': cell});

      return TrinaWidgetTestHelper('Create TrinaDateCell ', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Material(
              child: TrinaBooleanCell(
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

    makeDateCell().test(
      'Grid selection mode should be cell',
      (tester) async {
        await tester.tap(find.byType(TextField));
        await tester.pumpAndSettle();
        final popupGrid = tester.widget<TrinaGrid>(find.byType(TrinaGrid));
        expect(
          popupGrid.configuration.selectingMode,
          TrinaGridSelectingMode.cell,
        );
      },
    );
  });
}
