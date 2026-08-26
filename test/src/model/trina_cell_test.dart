import 'package:flutter_test/flutter_test.dart';
import 'package:trina_grid/trina_grid.dart';

void main() {
  group('isReadOnly', () {
    /// Builds an initialized cell so [TrinaCell.isReadOnly] can resolve
    /// its column and row without going through the grid.
    TrinaCell makeCell({
      bool columnReadOnly = false,
      TrinaCheckReadOnly? columnCheckReadOnly,
      TrinaCheckReadOnly? rowCheckReadOnly,
      TrinaCheckReadOnly? cellCheckReadOnly,
    }) {
      final column = TrinaColumn(
        title: 'title',
        field: 'field',
        type: TrinaColumnType.text(),
        readOnly: columnReadOnly,
        checkReadOnly: columnCheckReadOnly,
      );

      final cell = TrinaCell(value: 'value', checkReadOnly: cellCheckReadOnly);

      final row = TrinaRow(
        cells: {'field': cell},
        checkReadOnly: rowCheckReadOnly,
      );

      cell.setColumn(column);
      cell.setRow(row);

      return cell;
    }

    test('When nothing is set'
        'then isReadOnly should return false.', () {
      expect(makeCell().isReadOnly, false);
    });

    test('When only the column readOnly is set'
        'then isReadOnly should return the column value.', () {
      expect(makeCell(columnReadOnly: true).isReadOnly, true);
    });

    test('When the column checkReadOnly is set'
        'then it should take precedence over the column readOnly.', () {
      expect(
        makeCell(
          columnReadOnly: true,
          columnCheckReadOnly: (_, _) => false,
        ).isReadOnly,
        false,
      );
    });

    test('When the row checkReadOnly is set'
        'then it should take precedence over the column.', () {
      expect(
        makeCell(
          columnReadOnly: false,
          columnCheckReadOnly: (_, _) => false,
          rowCheckReadOnly: (_, _) => true,
        ).isReadOnly,
        true,
      );

      expect(
        makeCell(
          columnReadOnly: true,
          columnCheckReadOnly: (_, _) => true,
          rowCheckReadOnly: (_, _) => false,
        ).isReadOnly,
        false,
      );
    });

    test('When the cell checkReadOnly is set'
        'then it should take precedence over the row and the column.', () {
      expect(
        makeCell(
          columnCheckReadOnly: (_, _) => false,
          rowCheckReadOnly: (_, _) => false,
          cellCheckReadOnly: (_, _) => true,
        ).isReadOnly,
        true,
      );

      expect(
        makeCell(
          columnReadOnly: true,
          columnCheckReadOnly: (_, _) => true,
          rowCheckReadOnly: (_, _) => true,
          cellCheckReadOnly: (_, _) => false,
        ).isReadOnly,
        false,
      );
    });

    test('When a callback is called'
        'then it should receive the owning row and cell.', () {
      late TrinaRow passedRow;
      late TrinaCell passedCell;

      final cell = makeCell(
        rowCheckReadOnly: (row, cell) {
          passedRow = row;
          passedCell = cell;
          return false;
        },
      );

      expect(cell.isReadOnly, false);
      expect(identical(passedCell, cell), true);
      expect(identical(passedRow, cell.row), true);
    });

    test(
      'When the cell is not initialized'
      'then resolveReadOnly should still resolve from the given row and column.',
      () {
        // The cell widgets are handed their row and column directly and build
        // before the cell back references are necessarily set, so this form must
        // not touch TrinaCell.row / TrinaCell.column.
        final column = TrinaColumn(
          title: 'title',
          field: 'field',
          type: TrinaColumnType.text(),
          readOnly: true,
        );

        final cell = TrinaCell(value: 'value');
        final row = TrinaRow(cells: {'field': cell});

        expect(cell.initialized, false);
        expect(cell.resolveReadOnly(row: row, column: column), true);
      },
    );
  });
}
