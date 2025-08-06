import 'dart:math';

import 'package:trina_grid/trina_grid.dart';

class RowHelper {
  /// cell value format : '$columnFieldName value $rowIdx'
  static List<TrinaRow> count(
    int count,
    List<TrinaColumn>? columns, {
    bool checked = false,
    int start = 0,
  }) {
    return Iterable<int>.generate(count).map((rowIdx) {
      rowIdx += start;

      return TrinaRow(
        sortIdx: rowIdx,
        cells: Map.fromIterable(
          columns!,
          key: (dynamic column) => column.field.toString(),
          value: (dynamic column) {
            if ((column as TrinaColumn).type.isText) {
              return cellOfTextColumn(column, rowIdx);
            } else if (column.type.isDate) {
              return cellOfDateColumn(column, rowIdx);
            } else if (column.type.isTime) {
              return cellOfTimeColumn(column, rowIdx);
            } else if (column.type.isSelect) {
              return cellOfSelectColumn(column, rowIdx);
            } else if (column.type.isNumber || column.type.isCurrency) {
              return cellOfNumberColumn(column, rowIdx);
            } else if (column.type.isDateTime) {
              return cellOfDateTimeColumn(column, rowIdx);
            }

            throw Exception('Column is not implemented.');
          },
        ),
        checked: checked,
      );
    }).toList();
  }

  static TrinaCell cellOfTextColumn(TrinaColumn column, int rowIdx) {
    return TrinaCell(value: '${column.field} value $rowIdx');
  }

  static TrinaCell cellOfDateColumn(TrinaColumn column, int rowIdx) {
    return TrinaCell(
      value:
          DateTime.now().add(Duration(days: Random().nextInt(365))).toString(),
    );
  }

  static TrinaCell cellOfTimeColumn(TrinaColumn column, int rowIdx) {
    return TrinaCell(value: '00:00');
  }

  static TrinaCell cellOfSelectColumn(TrinaColumn column, int rowIdx) {
    return TrinaCell(
      value: (column.type.select.items.toList()..shuffle()).first,
    );
  }

  static TrinaCell cellOfNumberColumn(TrinaColumn column, int rowIdx) {
    return TrinaCell(value: Random().nextInt(10000));
  }

  static TrinaCell cellOfDateTimeColumn(TrinaColumn column, int rowIdx) {
    return TrinaCell(value: DateTime.now().toString());
  }

  static double resolveRowTotalHeight(TrinaGridStyleConfig style) {
    return style.rowHeight + style.cellHorizontalBorderWidth;
  }
}
