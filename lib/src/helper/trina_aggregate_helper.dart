import 'package:collection/collection.dart'
    show IterableExtension, IterableNumberExtension;
import 'package:trina_grid/trina_grid.dart';

class TrinaAggregateHelper {
  static num? sum({
    required Iterable<TrinaRow> rows,
    required TrinaColumn column,
    TrinaAggregateFilter? filter,
  }) {
    if (column.type is! TrinaColumnTypeWithNumberFormat ||
        !_hasColumnField(rows: rows, column: column)) {
      return 0;
    }

    final numberColumn = column.type as TrinaColumnTypeWithNumberFormat;

    final foundItems = filter != null
        ? rows.where((row) => filter(row.cells[column.field]!))
        : rows;

    final Iterable<num> numbers = foundItems
        .map((e) => e.cells[column.field]?.value as num?)
        .nonNulls;

    return numbers.isNotEmpty
        ? numberColumn.toNumber(numberColumn.applyFormat(numbers.sum))
        : null;
  }

  static num? average({
    required Iterable<TrinaRow> rows,
    required TrinaColumn column,
    TrinaAggregateFilter? filter,
  }) {
    if (column.type is! TrinaColumnTypeWithNumberFormat ||
        !_hasColumnField(rows: rows, column: column)) {
      return 0;
    }

    final numberColumn = column.type as TrinaColumnTypeWithNumberFormat;

    final foundItems = filter != null
        ? rows.where((row) => filter(row.cells[column.field]!))
        : rows;

    final Iterable<num> numbers = foundItems
        .map((e) => e.cells[column.field]?.value as num?)
        .nonNulls;

    return numbers.isNotEmpty
        ? numberColumn.toNumber(numberColumn.applyFormat(numbers.average))
        : null;
  }

  static num? min({
    required Iterable<TrinaRow> rows,
    required TrinaColumn column,
    TrinaAggregateFilter? filter,
  }) {
    if (column.type is! TrinaColumnTypeWithNumberFormat ||
        !_hasColumnField(rows: rows, column: column)) {
      return null;
    }

    final foundItems = filter != null
        ? rows.where((row) => filter(row.cells[column.field]!))
        : rows;

    final Iterable<num> mapValues = foundItems.map(
      (e) => e.cells[column.field]!.value,
    );

    return mapValues.minOrNull;
  }

  static num? max({
    required Iterable<TrinaRow> rows,
    required TrinaColumn column,
    TrinaAggregateFilter? filter,
  }) {
    if (column.type is! TrinaColumnTypeWithNumberFormat ||
        !_hasColumnField(rows: rows, column: column)) {
      return null;
    }

    final foundItems = filter != null
        ? rows.where((row) => filter(row.cells[column.field]!))
        : rows;

    final Iterable<num> mapValues = foundItems.map(
      (e) => e.cells[column.field]!.value,
    );

    return mapValues.maxOrNull;
  }

  static int count({
    required Iterable<TrinaRow> rows,
    required TrinaColumn column,
    TrinaAggregateFilter? filter,
  }) {
    if (!_hasColumnField(rows: rows, column: column)) {
      return 0;
    }

    final foundItems = filter != null
        ? rows.where((row) => filter(row.cells[column.field]!))
        : rows;

    return foundItems.length;
  }

  static bool _hasColumnField({
    required Iterable<TrinaRow> rows,
    required TrinaColumn column,
  }) {
    return rows.firstOrNull?.cells.containsKey(column.field) == true;
  }
}
