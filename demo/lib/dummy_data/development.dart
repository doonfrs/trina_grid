import 'dart:async';

import 'package:demo/dummy_data/words_multilingual.dart';
import 'package:faker/faker.dart';
import 'package:trina_grid/trina_grid.dart';

class DummyData {
  late List<TrinaColumn> columns;

  late List<TrinaRow> rows;

  DummyData(
    int columnLength,
    int rowLength, {
    List<int> leftFrozenColumnIndexes = const [],
    List<int> rightFrozenColumnIndexes = const [],
  }) {
    var faker = Faker();

    columns = List<int>.generate(columnLength, (index) => index).map((i) {
      return TrinaColumn(
        title: faker.food.cuisine(),
        field: i.toString(),
        readOnly: [1, 3, 5].contains(i),
        type: (int i) {
          if (i == 0) {
            return TrinaColumnType.number();
          } else if (i == 1) {
            return TrinaColumnType.currency();
          } else if (i == 2) {
            return TrinaColumnType.text();
          } else if (i == 3) {
            return TrinaColumnType.text();
          } else if (i == 4) {
            return TrinaColumnType.select(<String>[
              'One',
              'Two',
              'Three',
              'Four',
              'Five',
            ]);
          } else if (i == 5) {
            return TrinaColumnType.select(<String>[
              'One',
              'Two',
              'Three',
              'Four',
              'Five',
            ]);
          } else if (i == 6) {
            return TrinaColumnType.date();
          } else if (i == 7) {
            return TrinaColumnType.time();
          } else {
            return TrinaColumnType.text();
          }
        }(i),
        frozen: (int i) {
          if (leftFrozenColumnIndexes.contains(i)) {
            return TrinaColumnFrozen.start;
          }
          if (rightFrozenColumnIndexes.contains(i)) {
            return TrinaColumnFrozen.end;
          }
          return TrinaColumnFrozen.none;
        }(i),
      );
    }).toList();

    rows = rowsByColumns(length: rowLength, columns: columns);
  }

  static List<TrinaColumn> textColumns(int count) {
    return List<int>.generate(count, (index) => index).map((i) {
      return TrinaColumn(
        title: faker.food.cuisine(),
        field: i.toString(),
        type: TrinaColumnType.text(),
      );
    }).toList();
  }

  static List<TrinaRow> rowsByColumns({
    required int length,
    required List<TrinaColumn> columns,
  }) {
    return List<int>.generate(length, (index) => index).map((_) {
      return rowByColumns(columns);
    }).toList();
  }

  static TrinaRow rowByColumns(List<TrinaColumn> columns) {
    return TrinaRow(cells: _cellsByColumn(columns));
  }

  static dynamic valueByColumnType(TrinaColumn column) {
    if (column.type.isNumber || column.type.isCurrency) {
      return faker.randomGenerator.decimal(scale: 1000000000, min: -500000000);
    } else if (column.type.isSelect) {
      return (column.type.asSelect().items.toList()..shuffle()).first;
    } else if (column.type.isDate) {
      return DateTime.now()
          .add(Duration(days: faker.randomGenerator.integer(365, min: -365)))
          .toString();
    } else if (column.type.isTime) {
      final hour = faker.randomGenerator.integer(12).toString().padLeft(2, '0');
      final minute =
          faker.randomGenerator.integer(60).toString().padLeft(2, '0');
      return '$hour:$minute';
    } else {
      return faker.randomGenerator.element(multilingualWords);
    }
  }

  /// Repeat [chunkSize] as many times as [chunkCount] times.
  /// If chunkSize is 10 and chunkCount is 2,
  /// it repeats 10 rows twice and returns a total of 20 rows.
  static Future<List<TrinaRow>> fetchRows(
    List<TrinaColumn> columns, {
    int chunkCount = 100,
    int chunkSize = 100,
  }) {
    final Completer<List<TrinaRow>> completer = Completer();

    final List<TrinaRow> _rows = [];

    int count = 0;

    int totalRows = chunkSize * chunkCount;

    Timer.periodic(const Duration(milliseconds: 1), (timer) {
      if (count == chunkCount) {
        return;
      }

      ++count;

      Future(() {
        return DummyData.rowsByColumns(length: chunkSize, columns: columns);
      }).then((value) {
        _rows.addAll(value);

        if (_rows.length == totalRows) {
          completer.complete(_rows);

          timer.cancel();
        }
      });
    });

    return completer.future;
  }

  static List<TrinaRow> treeRowsByColumn({
    required List<TrinaColumn> columns,
    int count = 100,
    int? depth,
    List<int>? childCount,
  }) {
    assert(depth == null || depth >= 0);
    assert(childCount == null || childCount.length == depth);

    const defaultRandomDepth = 5;
    const defaultRandomChildCount = 10;

    TrinaRowType? generateType(int maxDepth, List<int> countOfChildren) {
      if (maxDepth < 1) return null;

      final TrinaRowType type = TrinaRowType.group(
        children: FilteredList(
          initialList: [],
        ),
      );
      List<TrinaRow>? currentChildren = type.group.children;
      List<List<TrinaRow>> childrenStack = [];
      List<List<TrinaRow>> childrenStackTemp = [];
      int currentDepth = 0;
      bool next = true;

      while (currentDepth < maxDepth || currentChildren != null) {
        bool isMax = currentDepth + 1 == maxDepth;
        next = childrenStack.isEmpty;

        if (currentChildren != null) {
          for (final _
              in List.generate(countOfChildren[currentDepth], (i) => i)) {
            final children = <TrinaRow>[];
            currentChildren.add(TrinaRow(
              cells: _cellsByColumn(columns),
              type: isMax
                  ? null
                  : TrinaRowType.group(
                      children: FilteredList(
                        initialList: children,
                      ),
                    ),
            ));

            if (!isMax) childrenStackTemp.add(children);
          }
        }

        if (next) {
          childrenStack = [...childrenStackTemp];
          childrenStackTemp = [];
        }

        currentChildren = childrenStack.isNotEmpty ? childrenStack.last : null;
        if (currentChildren != null) childrenStack.removeLast();

        if (next) ++currentDepth;
      }

      return type;
    }

    final rows = <TrinaRow>[];

    for (final _ in List.generate(count, (index) => index)) {
      TrinaRowType? type;

      final depthOrRandom = depth ??
          faker.randomGenerator.integer(
            defaultRandomDepth,
            min: 0,
          );

      final countOfChildren = childCount ??
          List.generate(depthOrRandom, (index) {
            return faker.randomGenerator.integer(
              defaultRandomChildCount,
              min: 0,
            );
          });

      type = depthOrRandom == 0
          ? null
          : generateType(depthOrRandom, countOfChildren);

      rows.add(
        TrinaRow(
          cells: _cellsByColumn(columns),
          type: type,
        ),
      );
    }

    return rows;
  }

  static Map<String, TrinaCell> _cellsByColumn(List<TrinaColumn> columns) {
    final cells = <String, TrinaCell>{};

    for (var column in columns) {
      cells[column.field] = TrinaCell(
        value: valueByColumnType(column),
      );
    }

    return cells;
  }
}
