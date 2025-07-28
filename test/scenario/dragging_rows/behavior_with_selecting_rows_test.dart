import 'package:flutter_test/flutter_test.dart';

import '../../helper/build_grid_helper.dart';
import '../../helper/column_helper.dart';

void main() {
  final grid = BuildGridHelper();

  final columns = ColumnHelper.textColumn('column', count: 1, start: 1);

  columns.first.enableRowDrag = true;

  grid
      .buildSelectedRows(
    numberOfRows: 10,
    startRowIdx: 3,
    endRowIdx: 5,
    columns: columns,
  )
      .test(
          'When the drag icon of an unselected row is dragged, '
          'the existing selection should be invalidated and the dragged row should be selected, '
          'and dragging should not occur.', (WidgetTester tester) async {
    final existsSelectingRows = [...grid.stateManager.selectedRows];

    final dragRowCellValue =
        grid.stateManager.refRows[0].cells['column1']!.value;

    final targetRowCellValue =
        grid.stateManager.refRows[1].cells['column1']!.value;

    expect(dragRowCellValue, 'column1 value 1');

    expect(targetRowCellValue, 'column1 value 2');

    final dragRow = find.text(dragRowCellValue);

    final targetRow = find.text(targetRowCellValue);

    await grid.gesture.down(tester.getCenter(dragRow));

    await tester.longPress(dragRow);

    await grid.gesture.moveTo(
      tester.getCenter(targetRow),
      timeStamp: const Duration(milliseconds: 10),
    );

    await grid.gesture.up();

    await tester.pumpAndSettle();

    expect(grid.stateManager.selectedRows.length, 2);

    expect(
      existsSelectingRows.contains(grid.stateManager.selectedRows[0]),
      false,
    );

    expect(
      existsSelectingRows.contains(grid.stateManager.selectedRows[1]),
      false,
    );

    expect(
      grid.stateManager.selectedRows[0].cells['column1']!.value,
      dragRowCellValue,
    );

    expect(
      grid.stateManager.selectedRows[1].cells['column1']!.value,
      targetRowCellValue,
    );
  });
}
