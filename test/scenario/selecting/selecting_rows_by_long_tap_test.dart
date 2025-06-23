import 'package:flutter_test/flutter_test.dart';

import '../../helper/build_grid_helper.dart';

void main() {
  final grid = BuildGridHelper();

  const columnTitle = 'column1';

  group('With 10 rows and selecting 3~5th row, ', () {
    selectRowsFrom3To5(String description,
        Future<void> Function(WidgetTester tester) testWithSelectedRowsFrom3To5,
        {bool? skip}) {
      const numberOfRows = 10;
      const startRowIdx = 3;
      const endRowIdx = 5;

      grid
          .buildSelectedRows(
        numberOfRows: numberOfRows,
        startRowIdx: startRowIdx,
        endRowIdx: endRowIdx,
      )
          .test(description, (tester) async {
        await testWithSelectedRowsFrom3To5(tester);
      }, skip: skip);
    }

    selectRowsFrom3To5(
      'When another row is long-tapped, the previous selected row should be invalidated and the long-tapped row should be selected.',
      (tester) async {
        await grid.selectRows(
          columnTitle: columnTitle,
          startRowIdx: 1,
          endRowIdx: 1,
          tester: tester,
        );

        expect(grid.stateManager.selectedRows.length, 1);

        expect(
          grid.stateManager.selectedRows[0],
          grid.stateManager.refRows[0],
        );
      },
    );
  });
}
