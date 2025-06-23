import 'package:flutter_test/flutter_test.dart';
import 'package:trina_grid/trina_grid.dart';

import '../../helper/build_grid_helper.dart';

void main() {
  final grid = BuildGridHelper();

  group('TrinaGridSelectingMode.cell', () {
    final fiveByFiveGrid = grid.build(
      numberOfColumns: 5,
      numberOfRows: 5,
      startColumnIndex: 0,
      selectingMode: TrinaGridSelectingMode.cellWithSingleTap,
    );

    fiveByFiveGrid.test(
      'When cells (1, 1) and (2, 4) are selected, '
      '8 cells should be selected.',
      (tester) async {
        await grid.selectCells(
          startCellValue: 'column1 value 1',
          endCellValue: 'column2 value 4',
          tester: tester,
        );

        final selected = [
          // @formatter:off
          ['column1', 1], ['column2', 1],
          ['column1', 2], ['column2', 2],
          ['column1', 3], ['column2', 3],
          ['column1', 4], ['column2', 4],
          // @formatter:on
        ];

        final length = grid.stateManager.currentSelectingPositionList.length;

        expect(length, 8);

        for (int i = 0; i < length; i += 1) {
          expect(
            grid.stateManager.currentSelectingPositionList[i],
            TrinaGridSelectingCellPosition(
              field: selected[i][0] as String,
              rowIdx: selected[i][1] as int,
            ),
          );
        }
      },
    );

    fiveByFiveGrid.test(
      'When cells (1, 1) and (2, 1) are selected, '
      '2 cells should be selected.',
      (tester) async {
        await grid.selectCells(
          startCellValue: 'column1 value 1',
          endCellValue: 'column2 value 1',
          tester: tester,
        );

        final selected = [
          // @formatter:off
          ['column1', 1], ['column2', 1],
          ['column1', 2], ['column2', 2],
          // @formatter:on
        ];

        final length = grid.stateManager.currentSelectingPositionList.length;

        expect(length, 2);

        for (int i = 0; i < length; i += 1) {
          expect(
            grid.stateManager.currentSelectingPositionList[i],
            TrinaGridSelectingCellPosition(
              field: selected[i][0] as String,
              rowIdx: selected[i][1] as int,
            ),
          );
        }
      },
    );
  });

  group('TrinaGridSelectingMode.horizontal', () {
    final fiveByFiveGrid = grid.build(
      numberOfColumns: 5,
      numberOfRows: 5,
      startColumnIndex: 0,
      selectingMode: TrinaGridSelectingMode.horizontal,
    );

    fiveByFiveGrid.test(
      'When cells (1, 0) and (0, 1) are selected, '
      '5 cells should be selected.',
      (tester) async {
        await grid.selectCells(
          startCellValue: 'column1 value 0',
          endCellValue: 'column0 value 1',
          tester: tester,
        );

        final selected = [
          // @formatter:off
          ['column1', 0], ['column2', 0], ['column3', 0], ['column4', 0],
          ['column0', 1],
          // @formatter:on
        ];

        final length = grid.stateManager.currentSelectingPositionList.length;

        expect(length, 5);

        for (int i = 0; i < length; i += 1) {
          expect(
            grid.stateManager.currentSelectingPositionList[i],
            TrinaGridSelectingCellPosition(
              field: selected[i][0] as String,
              rowIdx: selected[i][1] as int,
            ),
          );
        }
      },
    );

    fiveByFiveGrid.test(
      'When cells (0, 1) and (1, 0) are selected, '
      '5 cells should be selected.',
      (tester) async {
        await grid.selectCells(
          startCellValue: 'column0 value 1',
          endCellValue: 'column1 value 0',
          tester: tester,
        );

        final selected = [
          // @formatter:off
          ['column1', 0], ['column2', 0], ['column3', 0], ['column4', 0],
          ['column0', 1],
          // @formatter:on
        ];

        final length = grid.stateManager.currentSelectingPositionList.length;

        expect(length, 5);

        for (int i = 0; i < length; i += 1) {
          expect(
            grid.stateManager.currentSelectingPositionList[i],
            TrinaGridSelectingCellPosition(
              field: selected[i][0] as String,
              rowIdx: selected[i][1] as int,
            ),
          );
        }
      },
    );

    fiveByFiveGrid.test(
      'When cells (0, 1) and (0, 1) are selected, '
      '1 cell should be selected.',
      (tester) async {
        await grid.selectCells(
          startCellValue: 'column0 value 1',
          endCellValue: 'column0 value 1',
          tester: tester,
        );

        final selected = [
          // @formatter:off
          ['column0', 1],
          // @formatter:on
        ];

        final length = grid.stateManager.currentSelectingPositionList.length;

        expect(length, 1);

        for (int i = 0; i < length; i += 1) {
          expect(
            grid.stateManager.currentSelectingPositionList[i],
            TrinaGridSelectingCellPosition(
              field: selected[i][0] as String,
              rowIdx: selected[i][1] as int,
            ),
          );
        }
      },
    );

    fiveByFiveGrid.test(
      'When cells (0, 1) and (1, 1) are selected, '
      '2 cells should be selected.',
      (tester) async {
        await grid.selectCells(
          startCellValue: 'column0 value 1',
          endCellValue: 'column1 value 1',
          tester: tester,
        );

        final selected = [
          // @formatter:off
          ['column0', 1], ['column1', 1],
          // @formatter:on
        ];

        final length = grid.stateManager.currentSelectingPositionList.length;

        expect(length, 2);

        for (int i = 0; i < length; i += 1) {
          expect(
            grid.stateManager.currentSelectingPositionList[i],
            TrinaGridSelectingCellPosition(
              field: selected[i][0] as String,
              rowIdx: selected[i][1] as int,
            ),
          );
        }
      },
    );

    fiveByFiveGrid.test(
      'When cells (1, 1) and (0, 1) are selected, '
      '2 cells should be selected.',
      (tester) async {
        await grid.selectCells(
          startCellValue: 'column1 value 1',
          endCellValue: 'column0 value 1',
          tester: tester,
        );

        final selected = [
          // @formatter:off
          ['column0', 1], ['column1', 1],
          // @formatter:on
        ];

        final length = grid.stateManager.currentSelectingPositionList.length;

        expect(length, 2);

        for (int i = 0; i < length; i += 1) {
          expect(
            grid.stateManager.currentSelectingPositionList[i],
            TrinaGridSelectingCellPosition(
              field: selected[i][0] as String,
              rowIdx: selected[i][1] as int,
            ),
          );
        }
      },
    );
  });
}
