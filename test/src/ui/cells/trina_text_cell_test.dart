import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:trina_grid/trina_grid.dart';
import 'package:trina_grid/src/ui/ui.dart';

import '../../../mock/shared_mocks.mocks.dart';

void main() {
  late TrinaGridStateManager stateManager;

  setUp(() {
    stateManager = MockTrinaGridStateManager();
    when(stateManager.configuration).thenReturn(const TrinaGridConfiguration());
    when(stateManager.localeText).thenReturn(const TrinaGridLocaleText());
    when(stateManager.keepFocus).thenReturn(true);
    when(stateManager.hasFocus).thenReturn(true);
    when(stateManager.isEditing).thenReturn(true);
  });

  testWidgets('Cell value should be displayed', (WidgetTester tester) async {
    // given
    final TrinaColumn column = TrinaColumn(
      title: 'column title',
      field: 'column_field_name',
      type: TrinaColumnType.text(),
    );

    final TrinaCell cell = TrinaCell(value: 'text value');

    final TrinaRow row = TrinaRow(cells: {'column_field_name': cell});

    when(stateManager.currentColumn).thenReturn(column);

    // when
    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: TrinaTextCell(
            stateManager: stateManager,
            cell: cell,
            column: column,
            row: row,
          ),
        ),
      ),
    );

    // then
    expect(find.text('text value'), findsOneWidget);
  });
}
