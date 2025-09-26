// ignore_for_file: non_constant_identifier_names

import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trina_grid/trina_grid.dart';

import '../../../mock/shared_mocks.mocks.dart';

void main() {
  TrinaGridStateManager createStateManager({
    required List<TrinaColumn> columns,
    required List<TrinaRow> rows,
  }) {
    WidgetsFlutterBinding.ensureInitialized();

    final stateManager = TrinaGridStateManager(
      columns: columns,
      rows: rows,
      gridFocusNode: MockFocusNode(),
      scroll: MockTrinaGridScrollController(),
    );

    stateManager.setEventManager(MockTrinaGridEventManager());
    stateManager.setLayout(const BoxConstraints());

    return stateManager;
  }

  group('No delegate', () {
    test('If there is no delegate, hasRowGroups should return false.', () {
      final stateManager = createStateManager(columns: [], rows: []);

      expect(stateManager.hasRowGroups, false);
    });

    test('If there is no delegate, enabledRowGroups should return false.', () {
      final stateManager = createStateManager(columns: [], rows: []);

      expect(stateManager.enabledRowGroups, false);
    });

    test('If there is no delegate, rowGroupDelegate should return null.', () {
      final stateManager = createStateManager(columns: [], rows: []);

      expect(stateManager.rowGroupDelegate, null);
    });

    test(
      'If there is no delegate, iterateMainRowGroup should return an empty list.',
      () {
        final rows = [
          TrinaRow(cells: {}),
          TrinaRow(cells: {}),
          TrinaRow(cells: {}),
          TrinaRow(cells: {}),
          TrinaRow(cells: {}),
        ];

        final stateManager = createStateManager(columns: [], rows: rows);

        expect(stateManager.iterateAllMainRowGroup.length, 5);
      },
    );

    group('[Group row (3 children), Normal row, Normal row]', () {
      late TrinaGridStateManager stateManager;

      late TrinaRow groupedRow;

      late FilteredList<TrinaRow> children;

      late List<TrinaRow> rows;

      setUp(() {
        children = FilteredList(
          initialList: [
            TrinaRow(cells: {}, sortIdx: 10),
            TrinaRow(cells: {}, sortIdx: 11),
            TrinaRow(cells: {}, sortIdx: 12),
          ],
        );

        groupedRow = TrinaRow(
          cells: {},
          type: TrinaRowType.group(children: children),
          sortIdx: 0,
        );

        setParent(e) => e.setParent(groupedRow);

        children.forEach(setParent);

        rows = [
          groupedRow,
          TrinaRow(cells: {}, sortIdx: 1),
          TrinaRow(cells: {}, sortIdx: 2),
        ];

        stateManager = createStateManager(columns: [], rows: rows);
      });

      test('iterateMainRowGroup.length should return 3.', () {
        expect(stateManager.iterateAllMainRowGroup.length, 3);
      });

      test('iterateRowGroup.length should return 1.', () {
        expect(stateManager.iterateAllRowGroup.length, 1);
      });

      test('iterateRowAndGroup should return 6.', () {
        final rowAndGroup = stateManager.iterateAllRowAndGroup;
        expect(rowAndGroup.length, 6);
        expect(rowAndGroup.elementAt(0).sortIdx, 0);
        expect(rowAndGroup.elementAt(1).sortIdx, 10);
        expect(rowAndGroup.elementAt(2).sortIdx, 11);
        expect(rowAndGroup.elementAt(3).sortIdx, 12);
        expect(rowAndGroup.elementAt(4).sortIdx, 1);
        expect(rowAndGroup.elementAt(5).sortIdx, 2);
      });

      test('iterateRow.length should return 5.', () {
        expect(stateManager.iterateAllRow.length, 5);
      });

      test('refRows should return 3.', () {
        final List<bool> result = [];

        addResult(e) => result.add(stateManager.isMainRow(e));

        stateManager.refRows.forEach(addResult);

        expect(result.length, 3);
        expect(result, [true, true, true]);
      });

      test('children should return false.', () {
        final List<bool> result = [];

        addResult(e) => result.add(stateManager.isMainRow(e));

        children.forEach(addResult);

        expect(result.length, 3);
        expect(result, [false, false, false]);
      });

      test('refRows should return false.', () {
        final List<bool> result = [];

        addResult(e) => result.add(stateManager.isNotMainGroupedRow(e));

        stateManager.refRows.forEach(addResult);

        expect(result.length, 3);
        expect(result, [false, false, false]);
      });

      test('children should return true.', () {
        final List<bool> result = [];

        addResult(e) => result.add(stateManager.isNotMainGroupedRow(e));

        children.forEach(addResult);

        expect(result.length, 3);
        expect(result, [true, true, true]);
      });

      test('children should return false.', () {
        final List<bool> result = [];

        addResult(e) => result.add(stateManager.isExpandedGroupedRow(e));

        children.forEach(addResult);

        expect(result.length, 3);
        expect(result, [false, false, false]);
      });

      test(
        'If groupedRow is expanded, isExpandedGroupedRow should return true.',
        () {
          groupedRow.type.group.setExpanded(true);

          expect(stateManager.isExpandedGroupedRow(groupedRow), true);
        },
      );

      test(
        'If groupedRow is not expanded, isExpandedGroupedRow should return false.',
        () {
          groupedRow.type.group.setExpanded(false);

          expect(stateManager.isExpandedGroupedRow(groupedRow), false);
        },
      );
    });
  });

  /// A
  ///   - 1
  ///     - 001
  ///   - 2
  ///     - 002
  /// B
  ///   - 1
  ///     - 003
  ///     - 004
  ///   - 2
  ///     - 005
  group('Grouping by 2 columns - TrinaRowGroupByColumnDelegate.', () {
    late List<TrinaColumn> columns;

    late List<TrinaRow> rows;

    late TrinaGridStateManager stateManager;

    TrinaRow createRow(String value1, String value2, String value3) {
      return TrinaRow(
        cells: {
          'column1': TrinaCell(value: value1),
          'column2': TrinaCell(value: value2),
          'column3': TrinaCell(value: value3),
        },
      );
    }

    setUp(() {
      columns = [
        TrinaColumn(
          title: 'column1',
          field: 'column1',
          type: TrinaColumnType.text(),
        ),
        TrinaColumn(
          title: 'column2',
          field: 'column2',
          type: TrinaColumnType.text(),
        ),
        TrinaColumn(
          title: 'column3',
          field: 'column3',
          type: TrinaColumnType.text(),
        ),
      ];

      rows = [
        TrinaRow(
          cells: {
            'column1': TrinaCell(value: 'A'),
            'column2': TrinaCell(value: '1'),
            'column3': TrinaCell(value: '001'),
          },
        ),
        TrinaRow(
          cells: {
            'column1': TrinaCell(value: 'A'),
            'column2': TrinaCell(value: '2'),
            'column3': TrinaCell(value: '002'),
          },
        ),
        TrinaRow(
          cells: {
            'column1': TrinaCell(value: 'B'),
            'column2': TrinaCell(value: '1'),
            'column3': TrinaCell(value: '003'),
          },
        ),
        TrinaRow(
          cells: {
            'column1': TrinaCell(value: 'B'),
            'column2': TrinaCell(value: '1'),
            'column3': TrinaCell(value: '004'),
          },
        ),
        TrinaRow(
          cells: {
            'column1': TrinaCell(value: 'B'),
            'column2': TrinaCell(value: '2'),
            'column3': TrinaCell(value: '005'),
          },
        ),
      ];

      stateManager = createStateManager(columns: columns, rows: rows);

      stateManager.setRowGroup(
        TrinaRowGroupByColumnDelegate(columns: [columns[0], columns[1]]),
      );
    });

    test('When there is a row group, return true.', () {
      expect(stateManager.hasRowGroups, true);
    });

    test('When there is a row group, return true.', () {
      expect(stateManager.enabledRowGroups, true);
    });

    test('When there is a row group, return true.', () {
      expect(
        stateManager.rowGroupDelegate is TrinaRowGroupByColumnDelegate,
        true,
      );
    });

    test('When there a  re no row groups, return an empty list.', () {
      final mainRowGroup = stateManager.iterateAllMainRowGroup.toList();

      expect(mainRowGroup.length, 2);
    });

    test('When there is a row group, return 6 rows.', () {
      final mainRowGroup = stateManager.iterateAllRowGroup.toList();

      expect(mainRowGroup.length, 6);
    });

    test('When there is a row group, return 11 rows.', () {
      final mainRowGroup = stateManager.iterateAllRowAndGroup.toList();

      expect(mainRowGroup.length, 11);
    });

    test('When there is a row group, return 5 rows.', () {
      final mainRowGroup = stateManager.iterateAllRow.toList();

      expect(mainRowGroup.length, 5);
    });

    test(
      'If all columns are removed and new columns are added, the cells of the existing rows should be added.',
      () {
        stateManager.removeColumns(columns);

        expect(stateManager.refColumns.originalList.length, 0);
        expect(stateManager.refRows.originalList.length, 5);

        for (final row in stateManager.refRows.originalList) {
          // The parent of the grouped column should be null.
          expect(row.parent, null);
          expect(row.cells['column1'], null);
          expect(row.cells['column2'], null);
          expect(row.cells['column3'], null);
        }

        stateManager.insertColumns(0, [
          TrinaColumn(
            title: 'column4',
            field: 'column4',
            type: TrinaColumnType.text(),
          ),
        ]);

        expect(stateManager.refColumns.originalList.length, 1);
        expect(stateManager.refRows.originalList.length, 5);

        final rowAndGroup = stateManager.iterateAllRowAndGroup.toList();

        expect(rowAndGroup.length, 5);
        for (final row in rowAndGroup) {
          expect(row.cells['column1'], null);
          expect(row.cells['column2'], null);
          expect(row.cells['column3'], null);
          expect(row.cells['column4'], isNot(null));
        }
      },
    );

    test('If the first row is expanded, refRows should return 4 rows.', () {
      final firstRowGroup = stateManager.refRows.first;

      stateManager.toggleExpandedRowGroup(rowGroup: firstRowGroup);

      expect(firstRowGroup.type.group.expanded, true);
      expect(stateManager.refRows.length, 4);
    });

    test(
      'If the first row is expanded and then collapsed, refRows should return 2 rows.',
      () {
        final firstRowGroup = stateManager.refRows.first;

        stateManager.toggleExpandedRowGroup(rowGroup: firstRowGroup);

        expect(firstRowGroup.type.group.expanded, true);
        expect(stateManager.refRows.length, 4);

        stateManager.toggleExpandedRowGroup(rowGroup: firstRowGroup);

        expect(firstRowGroup.type.group.expanded, false);
        expect(stateManager.refRows.length, 2);
      },
    );

    test('First row and its first child are expanded, '
        'refRows should return 5 rows.', () {
      final firstRowGroup = stateManager.refRows.first;
      final firstRowGroupFirstChild = firstRowGroup.type.group.children.first;

      stateManager.toggleExpandedRowGroup(rowGroup: firstRowGroup);
      stateManager.toggleExpandedRowGroup(rowGroup: firstRowGroupFirstChild);

      expect(firstRowGroup.type.group.expanded, true);
      expect(firstRowGroupFirstChild.type.group.expanded, true);
      expect(stateManager.refRows.length, 5);
    });

    test('First row and its first child are expanded, '
        'refRows should return 2 rows.', () {
      final firstRowGroup = stateManager.refRows.first;
      final firstRowGroupFirstChild = firstRowGroup.type.group.children.first;

      stateManager.toggleExpandedRowGroup(rowGroup: firstRowGroup);
      stateManager.toggleExpandedRowGroup(rowGroup: firstRowGroupFirstChild);

      expect(firstRowGroup.type.group.expanded, true);
      expect(firstRowGroupFirstChild.type.group.expanded, true);
      expect(stateManager.refRows.length, 5);

      stateManager.toggleExpandedRowGroup(rowGroup: firstRowGroup);
      expect(firstRowGroup.type.group.expanded, false);
      expect(stateManager.refRows.length, 2);

      stateManager.toggleExpandedRowGroup(rowGroup: firstRowGroup);
      expect(firstRowGroup.type.group.expanded, true);
      expect(stateManager.refRows.length, 5);
    });

    test('refRows should be grouped by the 2 columns set.', () {
      final firstGroupField = columns[0].field;

      expect(stateManager.refRows.length, 2);

      expect(stateManager.refRows[0].type.isGroup, true);
      expect(stateManager.refRows[0].cells[firstGroupField]!.value, 'A');

      expect(stateManager.refRows[1].type.isGroup, true);
      expect(stateManager.refRows[1].cells[firstGroupField]!.value, 'B');
    });

    group('First group.', () {
      late FilteredList<TrinaRow> aGroupChildren;

      setUp(() {
        aGroupChildren = stateManager.refRows[0].type.group.children;
      });

      test('Children should be grouped by the second column.', () {
        final secondGroupField = columns[1].field;

        expect(aGroupChildren.length, 2);

        expect(aGroupChildren[0].type.isGroup, true);
        expect(aGroupChildren[0].cells[secondGroupField]!.value, '1');

        expect(aGroupChildren[1].type.isGroup, true);
        expect(aGroupChildren[1].cells[secondGroupField]!.value, '2');
      });

      test('Children should have 1 child each.', () {
        final normalColumnField = columns[2].field;

        final aGroupFirstChildren = aGroupChildren[0].type.group.children;
        expect(aGroupFirstChildren.length, 1);
        expect(aGroupFirstChildren[0].type.isNormal, true);
        expect(aGroupFirstChildren[0].cells[normalColumnField]!.value, '001');

        final aGroupSecondChildren = aGroupChildren[1].type.group.children;
        expect(aGroupSecondChildren.length, 1);
        expect(aGroupSecondChildren[0].type.isNormal, true);
        expect(aGroupSecondChildren[0].cells[normalColumnField]!.value, '002');
      });
    });

    group('Second group.', () {
      late FilteredList<TrinaRow> bGroupChildren;

      setUp(() {
        bGroupChildren = stateManager.refRows[1].type.group.children;
      });

      test('Children should be grouped by the second column.', () {
        final secondGroupField = columns[1].field;

        expect(bGroupChildren.length, 2);

        expect(bGroupChildren[0].type.isGroup, true);
        expect(bGroupChildren[0].cells[secondGroupField]!.value, '1');

        expect(bGroupChildren[1].type.isGroup, true);
        expect(bGroupChildren[1].cells[secondGroupField]!.value, '2');
      });

      test('Children should have 2 children each.', () {
        final normalColumnField = columns[2].field;

        final bGroupFirstChildren = bGroupChildren[0].type.group.children;
        expect(bGroupFirstChildren.length, 2);
        expect(bGroupFirstChildren[0].type.isNormal, true);
        expect(bGroupFirstChildren[0].cells[normalColumnField]!.value, '003');
        expect(bGroupFirstChildren[1].type.isNormal, true);
        expect(bGroupFirstChildren[1].cells[normalColumnField]!.value, '004');

        final bGroupSecondChildren = bGroupChildren[1].type.group.children;
        expect(bGroupSecondChildren.length, 1);
        expect(bGroupSecondChildren[0].type.isNormal, true);
        expect(bGroupSecondChildren[0].cells[normalColumnField]!.value, '005');
      });
    });

    test('If column1 is filtered by A value, 1 row should be returned.', () {
      stateManager.setFilter((row) => row.cells['column1']!.value == 'A');

      expect(stateManager.refRows.length, 1);
    });

    test(
      'If the first row is expanded and then filtered by column1 value A, 3 rows should be returned.',
      () {
        final firstRowGroup = stateManager.refRows.first;

        stateManager.toggleExpandedRowGroup(rowGroup: firstRowGroup);

        stateManager.setFilter((row) => row.cells['column1']!.value == 'A');

        // First row + first row's 2 children = 3 rows
        expect(stateManager.refRows.length, 3);
      },
    );

    test(
      'If two rows are expanded and the  n filtered by column2 value 1, 4 rows should be returned.',
      () {
        final firstRowGroup = stateManager.refRows[0];
        final secondRowGroup = stateManager.refRows[1];

        stateManager.toggleExpandedRowGroup(rowGroup: firstRowGroup);
        stateManager.toggleExpandedRowGroup(rowGroup: secondRowGroup);
        expect(stateManager.refRows.length, 6);

        stateManager.setFilter((row) => row.cells['column2']!.value == '1');

        expect(stateManager.refRows.length, 4);
      },
    );

    test(
      'If column1 is sorted in descending order, the order of the two rows should be reversed.',
      () {
        expect(stateManager.refRows[0].cells['column1']!.value, 'A');
        expect(stateManager.refRows[1].cells['column1']!.value, 'B');

        // Ascending
        stateManager.toggleSortColumn(columns[0]);
        // Descending
        stateManager.toggleSortColumn(columns[0]);

        expect(stateManager.refRows[0].cells['column1']!.value, 'B');
        expect(stateManager.refRows[1].cells['column1']!.value, 'A');
      },
    );

    test(
      'If the second row is expanded and then sorted in descending order, the order of the two children should be reversed.',
      () {
        final secondRowGroup = stateManager.refRows[1];

        stateManager.toggleExpandedRowGroup(rowGroup: secondRowGroup);

        final secondRowGroupFirstChild = secondRowGroup.type.group.children[0];
        stateManager.toggleExpandedRowGroup(rowGroup: secondRowGroupFirstChild);

        final secondRowGroupSecondChild = secondRowGroup.type.group.children[1];
        stateManager.toggleExpandedRowGroup(
          rowGroup: secondRowGroupSecondChild,
        );

        {
          final fistChild = secondRowGroupFirstChild.type.group.children[0];
          expect(fistChild.cells['column3']!.value, '003');

          final secondChild = secondRowGroupFirstChild.type.group.children[1];
          expect(secondChild.cells['column3']!.value, '004');
        }

        // Ascending
        stateManager.toggleSortColumn(columns[2]);
        // Descending
        stateManager.toggleSortColumn(columns[2]);

        {
          final fistChild = secondRowGroupFirstChild.type.group.children[0];
          expect(fistChild.cells['column3']!.value, '004');

          final secondChild = secondRowGroupFirstChild.type.group.children[1];
          expect(secondChild.cells['column3']!.value, '003');
        }
      },
    );

    test(
      'If a row with column2 value 3 is added to the first row, the first row should have 3 children.',
      () {
        final rowToAdd = TrinaRow(
          cells: {
            'column1': TrinaCell(value: 'A'),
            'column2': TrinaCell(value: '3'),
            'column3': TrinaCell(value: '006'),
          },
        );

        expect(stateManager.refRows.first.type.group.children.length, 2);

        stateManager.insertRows(0, [rowToAdd]);

        expect(stateManager.refRows.first.type.group.children.length, 3);
      },
    );

    test(
      'Adding a row with column2 value 3 to the first row should set the parent of the added child.',
      () {
        final rowToAdd = TrinaRow(
          cells: {
            'column1': TrinaCell(value: 'A'),
            'column2': TrinaCell(value: '3'),
            'column3': TrinaCell(value: '006'),
          },
        );

        stateManager.insertRows(0, [rowToAdd]);

        expect(rowToAdd.parent?.cells['column2']!.value, '3');
        expect(rowToAdd.parent?.parent, stateManager.refRows.first);
      },
    );

    test(
      'Adding a row with column2 value 3 to the first row should set the parent of the added child.',
      () {
        final rowToAdd = TrinaRow(
          cells: {
            'column1': TrinaCell(value: 'A'),
            'column2': TrinaCell(value: '3'),
            'column3': TrinaCell(value: '006'),
          },
        );

        stateManager.toggleSortColumn(columns.first);

        stateManager.insertRows(0, [rowToAdd]);

        expect(rowToAdd.parent?.cells['column2']!.value, '3');
        expect(rowToAdd.parent?.parent, stateManager.refRows.first);
      },
    );

    test('prependRows with column2 value 3, '
        'added child should have parent set.', () {
      final rowToAdd = TrinaRow(
        cells: {
          'column1': TrinaCell(value: 'A'),
          'column2': TrinaCell(value: '3'),
          'column3': TrinaCell(value: '006'),
        },
      );

      stateManager.toggleSortColumn(columns.first);

      stateManager.prependRows([rowToAdd]);

      expect(rowToAdd.parent?.cells['column2']!.value, '3');
      expect(rowToAdd.parent?.parent, stateManager.refRows.first);
    });

    test('appendRows with column2 value 3, '
        'added child should have parent set.', () {
      final rowToAdd = TrinaRow(
        cells: {
          'column1': TrinaCell(value: 'A'),
          'column2': TrinaCell(value: '3'),
          'column3': TrinaCell(value: '006'),
        },
      );

      stateManager.toggleSortColumn(columns.first);

      stateManager.appendRows([rowToAdd]);

      expect(rowToAdd.parent?.cells['column2']!.value, '3');
      expect(rowToAdd.parent?.parent, stateManager.refRows.first);
    });

    test('First row and its children should be removed.', () {
      final firstRowGroup = stateManager.refRows.first;

      expect(stateManager.iterateAllRowAndGroup.length, 11);

      stateManager.removeRows([firstRowGroup]);

      expect(stateManager.iterateAllRowAndGroup.length, 6);
    });

    test('If column1 is removed, column2 should be grouped again.', () {
      final firstColumn = stateManager.refColumns.first;

      stateManager.removeColumns([firstColumn]);

      expect(stateManager.refRows.length, 2);

      {
        final rowGroup = stateManager.refRows[0];
        expect(rowGroup.cells['column2']!.value, '1');
        expect(rowGroup.type.group.children.length, 3);
      }

      {
        final rowGroup = stateManager.refRows[1];
        expect(rowGroup.cells['column2']!.value, '2');
        expect(rowGroup.type.group.children.length, 2);
      }
    });

    test('If column1 is hidden, column2 should be grouped again.', () {
      final firstColumn = stateManager.refColumns.first;

      stateManager.hideColumn(firstColumn, true);

      expect(stateManager.refRows.length, 2);

      {
        final rowGroup = stateManager.refRows[0];
        expect(rowGroup.cells['column2']!.value, '1');
        expect(rowGroup.type.group.children.length, 3);
      }

      {
        final rowGroup = stateManager.refRows[1];
        expect(rowGroup.cells['column2']!.value, '2');
        expect(rowGroup.type.group.children.length, 2);
      }
    });

    test(
      'If column1 is hidden and then unhidden, column1 should be grouped again.',
      () {
        final firstColumn = stateManager.refColumns.first;

        stateManager.hideColumn(firstColumn, true);

        expect(stateManager.refRows.length, 2);

        {
          final rowGroup = stateManager.refRows[0];
          expect(rowGroup.cells['column2']!.value, '1');
          expect(rowGroup.type.group.children.length, 3);
        }

        {
          final rowGroup = stateManager.refRows[1];
          expect(rowGroup.cells['column2']!.value, '2');
          expect(rowGroup.type.group.children.length, 2);
        }

        stateManager.hideColumn(firstColumn, false);

        {
          final rowGroup = stateManager.refRows[0];
          expect(rowGroup.cells['column1']!.value, 'A');
          expect(rowGroup.type.group.children.length, 2);
        }

        {
          final rowGroup = stateManager.refRows[1];
          expect(rowGroup.cells['column1']!.value, 'B');
          expect(rowGroup.type.group.children.length, 2);
        }
      },
    );

    group('insertRows', () {
      test('When inserting a row at index 0, the row should be added.', () {
        /// Before
        /// 0. A [V]
        /// 1. B
        /// After
        /// 0. C (1 > 006) [V]
        /// 1. A
        /// 2. B
        expect(stateManager.refRows.length, 2);
        expect(stateManager.refRows[0].cells['column1']!.value, 'A');
        expect(stateManager.refRows[1].cells['column1']!.value, 'B');

        stateManager.insertRows(0, [createRow('C', '1', '006')]);

        expect(stateManager.refRows.length, 3);
        expect(stateManager.refRows[0].cells['column1']!.value, 'C');
        expect(stateManager.refRows[1].cells['column1']!.value, 'A');
        expect(stateManager.refRows[2].cells['column1']!.value, 'B');

        final GROUP_C = stateManager.refRows[0];
        final GROUP_C_1 = GROUP_C.type.group.children.first;
        expect(GROUP_C_1.parent, GROUP_C);
        expect(GROUP_C_1.type.group.children.first.parent, GROUP_C_1);
      });

      test('Inserting row at index 2 should add the row.', () {
        /// Before
        /// 0. A
        /// 1. B
        /// 2. [V]
        /// After
        /// 0. A
        /// 1. B
        /// 2. C (1 > 006) [V]
        expect(stateManager.refRows.length, 2);
        expect(stateManager.refRows[0].cells['column1']!.value, 'A');
        expect(stateManager.refRows[1].cells['column1']!.value, 'B');

        stateManager.insertRows(2, [createRow('C', '1', '006')]);

        expect(stateManager.refRows.length, 3);
        expect(stateManager.refRows[0].cells['column1']!.value, 'A');
        expect(stateManager.refRows[1].cells['column1']!.value, 'B');
        expect(stateManager.refRows[2].cells['column1']!.value, 'C');

        final GROUP_C = stateManager.refRows[2];
        final GROUP_C_1 = GROUP_C.type.group.children.first;
        expect(GROUP_C_1.parent, GROUP_C);
        expect(GROUP_C_1.type.group.children.first.parent, GROUP_C_1);
      });

      test('Inserting row at index 1 should add the row.', () {
        /// Before
        /// 0. A
        /// 1. B [V]
        /// 2.   - 1
        /// 3.     - 003
        /// 4.     - 004
        /// 5.   - 2
        /// After
        /// 0. A
        /// 1. C (1 > 006) [V]
        /// 2. B
        /// 3.   - 1
        /// 4.     - 003
        /// 5.     - 004
        /// 6.   - 2
        final GROUP_B = stateManager.refRows[1];
        final GROUP_B_1 = GROUP_B.type.group.children.first;
        stateManager.toggleExpandedRowGroup(rowGroup: GROUP_B);
        stateManager.toggleExpandedRowGroup(rowGroup: GROUP_B_1);

        expect(stateManager.refRows.length, 6);
        expect(stateManager.refRows[0].cells['column1']!.value, 'A');
        expect(stateManager.refRows[1].cells['column1']!.value, 'B');
        expect(stateManager.refRows[2].cells['column2']!.value, '1');
        expect(stateManager.refRows[3].cells['column3']!.value, '003');
        expect(stateManager.refRows[4].cells['column3']!.value, '004');
        expect(stateManager.refRows[5].cells['column2']!.value, '2');

        stateManager.insertRows(1, [createRow('C', '1', '006')]);

        expect(stateManager.refRows.length, 7);
        expect(stateManager.refRows[0].cells['column1']!.value, 'A');
        expect(stateManager.refRows[1].cells['column1']!.value, 'C');
        expect(stateManager.refRows[2].cells['column1']!.value, 'B');
        expect(stateManager.refRows[3].cells['column2']!.value, '1');
        expect(stateManager.refRows[4].cells['column3']!.value, '003');
        expect(stateManager.refRows[5].cells['column3']!.value, '004');
        expect(stateManager.refRows[6].cells['column2']!.value, '2');

        final GROUP_C = stateManager.refRows[1];
        final GROUP_C_1 = GROUP_C.type.group.children.first;
        expect(GROUP_C_1.parent, GROUP_C);
        expect(GROUP_C_1.type.group.children.first.parent, GROUP_C_1);
      });

      test('Inserting row at index 5 should add the row.', () {
        /// Before
        /// 0. A
        /// 1. B
        /// 2.   - 1
        /// 3.   - 2
        /// 4.     - 005
        /// 5. [V]
        /// After
        /// 0. A
        /// 1. B
        /// 2.   - 1
        /// 3.   - 2
        /// 4.     - 005
        /// 5. C [V]
        final GROUP_B = stateManager.refRows[1];
        final GROUP_B_2 = GROUP_B.type.group.children.last;
        stateManager.toggleExpandedRowGroup(rowGroup: GROUP_B);
        stateManager.toggleExpandedRowGroup(rowGroup: GROUP_B_2);

        expect(stateManager.refRows.length, 5);
        expect(stateManager.refRows[0].cells['column1']!.value, 'A');
        expect(stateManager.refRows[1].cells['column1']!.value, 'B');
        expect(stateManager.refRows[2].cells['column2']!.value, '1');
        expect(stateManager.refRows[3].cells['column2']!.value, '2');
        expect(stateManager.refRows[4].cells['column3']!.value, '005');

        stateManager.insertRows(5, [createRow('C', '1', '006')]);

        expect(stateManager.refRows.length, 6);
        expect(stateManager.refRows[0].cells['column1']!.value, 'A');
        expect(stateManager.refRows[1].cells['column1']!.value, 'B');
        expect(stateManager.refRows[2].cells['column2']!.value, '1');
        expect(stateManager.refRows[3].cells['column2']!.value, '2');
        expect(stateManager.refRows[4].cells['column3']!.value, '005');
        expect(stateManager.refRows[5].cells['column1']!.value, 'C');
      });

      test('Inserting row at index 5 should add the row.', () {
        /// Before
        /// 0. A
        /// 1. B
        /// 2.   - 1
        /// 3.   - 2
        /// 4.     - 005
        /// 5. [V]
        /// After
        /// 0. A
        /// 1. B
        /// 2.   - 1
        /// 3.   - 2
        /// 4.     - 005
        /// 5.   - 3 [V]
        final GROUP_B = stateManager.refRows[1];
        final GROUP_B_2 = GROUP_B.type.group.children.last;
        stateManager.toggleExpandedRowGroup(rowGroup: GROUP_B);
        stateManager.toggleExpandedRowGroup(rowGroup: GROUP_B_2);

        stateManager.insertRows(5, [createRow('B', '3', '006')]);

        expect(stateManager.refRows.length, 6);
        expect(stateManager.refRows[0].cells['column1']!.value, 'A');
        expect(stateManager.refRows[1].cells['column1']!.value, 'B');
        expect(stateManager.refRows[2].cells['column2']!.value, '1');
        expect(stateManager.refRows[3].cells['column2']!.value, '2');
        expect(stateManager.refRows[4].cells['column3']!.value, '005');
        expect(stateManager.refRows[5].cells['column2']!.value, '3');
      });

      test('Inserting row at index 6 should add the row.', () {
        /// Before
        /// 0. A
        /// 1. B
        /// 2.   - 1
        /// 3.     - 003
        /// 4.     - 004
        /// 5.   - 2
        /// 6. [V]
        /// After
        /// 0. A
        /// 1. B
        /// 2.   - 1
        /// 3.     - 003
        /// 4.     - 004
        /// 5.     - 006 [V]
        /// 6.   - 2
        final GROUP_B = stateManager.refRows[1];
        final GROUP_B_1 = GROUP_B.type.group.children.first;
        stateManager.toggleExpandedRowGroup(rowGroup: GROUP_B);
        stateManager.toggleExpandedRowGroup(rowGroup: GROUP_B_1);

        stateManager.insertRows(6, [createRow('B', '1', '006')]);

        expect(stateManager.refRows.length, 7);
        expect(stateManager.refRows[0].cells['column1']!.value, 'A');
        expect(stateManager.refRows[1].cells['column1']!.value, 'B');
        expect(stateManager.refRows[2].cells['column2']!.value, '1');
        expect(stateManager.refRows[3].cells['column3']!.value, '003');
        expect(stateManager.refRows[4].cells['column3']!.value, '004');
        expect(stateManager.refRows[5].cells['column3']!.value, '006');
        expect(stateManager.refRows[6].cells['column2']!.value, '2');
      });

      test('Inserting rows at index 1 should add the rows.', () {
        /// Before
        /// 0. A
        /// 1. B [V]
        /// 2.   - 1
        /// 3.     - 003
        /// 4.     - 004
        /// 5.   - 2
        /// After
        /// 0. A
        /// 1. C (1 > 006) [V]
        /// 2. B
        /// 3.   - 1
        /// 4.     - 003
        /// 5.     - 004
        /// 6.   - 2
        /// 7.   - 3 > (007)
        final GROUP_B = stateManager.refRows[1];
        final GROUP_B_1 = GROUP_B.type.group.children.first;
        stateManager.toggleExpandedRowGroup(rowGroup: GROUP_B);
        stateManager.toggleExpandedRowGroup(rowGroup: GROUP_B_1);

        expect(stateManager.refRows.length, 6);
        expect(stateManager.refRows[0].cells['column1']!.value, 'A');
        expect(stateManager.refRows[1].cells['column1']!.value, 'B');
        expect(stateManager.refRows[2].cells['column2']!.value, '1');
        expect(stateManager.refRows[3].cells['column3']!.value, '003');
        expect(stateManager.refRows[4].cells['column3']!.value, '004');
        expect(stateManager.refRows[5].cells['column2']!.value, '2');

        stateManager.insertRows(1, [
          createRow('C', '1', '006'),
          createRow('B', '3', '007'),
        ]);

        expect(stateManager.refRows.length, 8);
        expect(stateManager.refRows[0].cells['column1']!.value, 'A');
        expect(stateManager.refRows[1].cells['column1']!.value, 'C');
        expect(stateManager.refRows[2].cells['column1']!.value, 'B');
        expect(stateManager.refRows[3].cells['column2']!.value, '1');
        expect(stateManager.refRows[4].cells['column3']!.value, '003');
        expect(stateManager.refRows[5].cells['column3']!.value, '004');
        expect(stateManager.refRows[6].cells['column2']!.value, '2');
        expect(stateManager.refRows[7].cells['column2']!.value, '3');

        final GROUP_C = stateManager.refRows[1];
        final GROUP_C_1 = GROUP_C.type.group.children.first;
        expect(GROUP_C_1.parent, GROUP_C);
        expect(GROUP_C_1.type.group.children.first.parent, GROUP_C_1);

        final GROUP_B_3 = stateManager.refRows[7];
        expect(GROUP_B_3.parent, GROUP_B);
        expect(GROUP_B_3.type.group.children.first.parent, GROUP_B_3);
      });

      test('Inserting rows at index 5 should add the rows.', () {
        /// Before
        /// 0. A
        /// 1. B
        /// 2.   - 1
        /// 3.     - 003
        /// 4.     - 004
        /// 5.   - 2 [V]
        /// After
        /// 0. A
        /// 1. B
        /// 2.   - 1
        /// 3.     - 003
        /// 4.     - 004
        /// 5.   - 3 > (007) [V]
        /// 6.   - 2 > (005, 006)
        final GROUP_B = stateManager.refRows[1];
        final GROUP_B_1 = GROUP_B.type.group.children.first;
        stateManager.toggleExpandedRowGroup(rowGroup: GROUP_B);
        stateManager.toggleExpandedRowGroup(rowGroup: GROUP_B_1);

        final GROUP_B_2 = stateManager.refRows[5];
        expect(GROUP_B_2.type.group.children.length, 1);

        stateManager.insertRows(5, [
          createRow('C', '2', '006'),
          createRow('C', '3', '007'),
        ]);

        expect(GROUP_B_2.type.group.children.length, 2);
        final GROUP_B_2_006 = GROUP_B_2.type.group.children[1];
        expect(GROUP_B_2_006.cells['column3']!.value, '006');
        expect(GROUP_B_2_006.parent, GROUP_B_2);
        expect(stateManager.refRows[6].cells['column2']!.value, '2');

        expect(GROUP_B.type.group.children.length, 3);
        final GROUP_B_3 = stateManager.refRows[5];
        final GROUP_B_3_007 = GROUP_B_3.type.group.children[0];
        expect(GROUP_B_3.cells['column2']!.value, '3');
        expect(GROUP_B_3_007.cells['column3']!.value, '007');
        expect(GROUP_B_3.parent, GROUP_B);
        expect(GROUP_B_3_007.parent, GROUP_B_3);
      });

      test(
        'Column1 to be Descending sorted, insert 5 with (C, 1, 006), (D, 1, 007).',
        () {
          /// Before
          /// 0. B
          /// 1.   - 1
          /// 2.     - 003
          /// 3.     - 004
          /// 4.   - 2
          /// 5. A [V]
          /// After
          /// 0. B
          /// 1.   - 1
          /// 2.     - 003
          /// 3.     - 004
          /// 4.   - 2
          /// 5. C (1 > 006) [V]
          /// 6. D (1 > 007)
          /// 7. A
          final GROUP_B = stateManager.refRows[1];
          final GROUP_B_1 = GROUP_B.type.group.children.first;

          stateManager.toggleExpandedRowGroup(rowGroup: GROUP_B);
          stateManager.toggleExpandedRowGroup(rowGroup: GROUP_B_1);

          stateManager.sortDescending(stateManager.columns.first);

          expect(stateManager.refRows[0].cells['column1']!.value, 'B');
          expect(stateManager.refRows[5].cells['column1']!.value, 'A');

          stateManager.insertRows(5, [
            createRow('C', '1', '006'),
            createRow('D', '1', '007'),
          ]);

          expect(stateManager.refRows[0].cells['column1']!.value, 'B');
          expect(stateManager.refRows[5].cells['column1']!.value, 'C');
          expect(stateManager.refRows[6].cells['column1']!.value, 'D');
          expect(stateManager.refRows[7].cells['column1']!.value, 'A');

          stateManager.sortBySortIdx(stateManager.columns.first);

          expect(stateManager.refRows[0].cells['column1']!.value, 'C');
          expect(stateManager.refRows[1].cells['column1']!.value, 'D');
          expect(stateManager.refRows[2].cells['column1']!.value, 'A');
        },
      );

      test(
        'Column1 to be Descending sorted, insert 2 with (C, 1, 006), (C, 3, 007).',
        () {
          /// Before
          /// 0. B
          /// 1.   - 1
          /// 2.     - 003 [V]
          /// 3.     - 004
          /// 4.   - 2
          /// 5. A
          /// After
          /// 0. B
          /// 1.   - 1
          /// 2.     - 006 [V]
          /// 3.     - 007
          /// 4.     - 003
          /// 5.     - 004
          /// 6.   - 2
          /// 7. A
          final GROUP_B = stateManager.refRows[1];
          final GROUP_B_1 = GROUP_B.type.group.children.first;

          stateManager.toggleExpandedRowGroup(rowGroup: GROUP_B);
          stateManager.toggleExpandedRowGroup(rowGroup: GROUP_B_1);

          stateManager.sortDescending(stateManager.columns.first);

          expect(stateManager.refRows[0].cells['column1']!.value, 'B');
          expect(stateManager.refRows[5].cells['column1']!.value, 'A');

          stateManager.insertRows(2, [
            createRow('C', '1', '006'),
            createRow('C', '3', '007'),
          ]);

          expect(stateManager.refRows[0].cells['column1']!.value, 'B');
          expect(stateManager.refRows[1].cells['column2']!.value, '1');
          expect(stateManager.refRows[2].cells['column3']!.value, '006');
          expect(stateManager.refRows[3].cells['column3']!.value, '007');
          expect(stateManager.refRows[4].cells['column3']!.value, '003');
          expect(stateManager.refRows[5].cells['column3']!.value, '004');
          expect(stateManager.refRows[6].cells['column2']!.value, '2');
          expect(stateManager.refRows[7].cells['column1']!.value, 'A');

          stateManager.sortBySortIdx(stateManager.columns.first);

          expect(stateManager.refRows[0].cells['column1']!.value, 'A');
          expect(stateManager.refRows[1].cells['column1']!.value, 'B');
          expect(stateManager.refRows[2].cells['column2']!.value, '1');
          expect(stateManager.refRows[3].cells['column3']!.value, '006');
          expect(stateManager.refRows[4].cells['column3']!.value, '007');
          expect(stateManager.refRows[5].cells['column3']!.value, '003');
          expect(stateManager.refRows[6].cells['column3']!.value, '004');
        },
      );
    });

    group('prependRows', () {
      test('Adding row (C, 1, 006) should add the row.', () {
        /// Before
        /// 0. A
        /// 1. B
        /// After
        /// 0. C
        /// 1. A
        /// 2. B
        stateManager.prependRows([createRow('C', '1', '006')]);

        expect(stateManager.refRows.length, 3);
        final GROUP_C = stateManager.refRows[0];
        final GROUP_C_1 = GROUP_C.type.group.children.first;
        final GROUP_C_1_006 = GROUP_C_1.type.group.children.first;
        expect(GROUP_C.cells['column1']!.value, 'C');
        expect(GROUP_C_1.cells['column2']!.value, '1');
        expect(GROUP_C_1_006.cells['column3']!.value, '006');
        expect(GROUP_C_1_006.parent, GROUP_C_1);
        expect(GROUP_C_1_006.parent?.parent, GROUP_C);
      });

      test('Adding row (B, 2, 006) should add the row.', () {
        /// Before
        /// 0. A
        /// 1. B
        /// After
        /// 0. A
        /// 1. B (2 > 005, 006)
        final GROUP_B = stateManager.refRows[1];
        final GROUP_B_2 = GROUP_B.type.group.children[1];
        expect(stateManager.refRows.length, 2);
        expect(GROUP_B_2.type.group.children.length, 1);

        stateManager.prependRows([createRow('B', '2', '006')]);

        final GROUP_B_2_006 = GROUP_B_2.type.group.children[1];
        expect(stateManager.refRows.length, 2);
        expect(GROUP_B_2.type.group.children.length, 2);
        expect(GROUP_B_2_006.cells['column3']!.value, '006');
      });

      test(
        'Adding rows (A, 1, 006), (B, 1, 007), (C, 1, 008) should add the rows.',
        () {
          /// Before
          /// 0. A
          /// 1. B
          /// After
          /// 0. C (1 > 008)
          /// 1. A (1 > 001 006)
          /// 2. B (1 > 003, 004, 007)
          stateManager.prependRows([
            createRow('A', '1', '006'),
            createRow('B', '1', '007'),
            createRow('C', '1', '008'),
          ]);

          final GROUP_C = stateManager.refRows[0];
          final GROUP_C_1 = GROUP_C.type.group.children.first;
          final GROUP_C_1_008 = GROUP_C_1.type.group.children.first;
          final GROUP_A = stateManager.refRows[1];
          final GROUP_A_1 = GROUP_A.type.group.children.first;
          final GROUP_A_1_006 = GROUP_A_1.type.group.children.last;
          final GROUP_B = stateManager.refRows[2];
          final GROUP_B_1 = GROUP_B.type.group.children.first;
          final GROUP_B_1_007 = GROUP_B_1.type.group.children.last;

          expect(GROUP_C.cells['column1']!.value, 'C');
          expect(GROUP_C_1.cells['column2']!.value, '1');
          expect(GROUP_C_1_008.cells['column3']!.value, '008');
          expect(GROUP_C_1_008.parent, GROUP_C_1);
          expect(GROUP_C_1_008.parent?.parent, GROUP_C);

          expect(GROUP_A_1_006.cells['column3']!.value, '006');
          expect(GROUP_A_1_006.parent, GROUP_A_1);
          expect(GROUP_A_1_006.parent?.parent, GROUP_A);
          expect(GROUP_B_1_007.cells['column3']!.value, '007');
          expect(GROUP_B_1_007.parent, GROUP_B_1);
          expect(GROUP_B_1_007.parent?.parent, GROUP_B);
        },
      );
    });

    group('appendRows', () {
      test('Adding row (C, 1, 006) should add the row.', () {
        /// Before
        /// 0. A
        /// 1. B
        /// After
        /// 0. A
        /// 1. B
        /// 2. C (1 > 006)
        stateManager.appendRows([createRow('C', '1', '006')]);

        expect(stateManager.refRows.length, 3);
        final GROUP_C = stateManager.refRows[2];
        final GROUP_C_1 = GROUP_C.type.group.children.first;
        final GROUP_C_1_006 = GROUP_C_1.type.group.children.first;
        expect(GROUP_C.cells['column1']!.value, 'C');
        expect(GROUP_C_1.cells['column2']!.value, '1');
        expect(GROUP_C_1_006.cells['column3']!.value, '006');
      });

      test(
        'Adding rows (B, 3, 006), (C, 1, 007), (C, 2, 008) should add the rows.',
        () {
          /// Before
          /// 0. A
          /// 1. B
          /// After
          /// 0. A
          /// 1. B (3 > 006)
          /// 2. C (1 > 007, 2 > 008)
          stateManager.appendRows([
            createRow('B', '3', '006'),
            createRow('C', '1', '007'),
            createRow('C', '2', '008'),
          ]);

          expect(stateManager.refRows.length, 3);
          final GROUP_B = stateManager.refRows[1];
          final GROUP_B_3 = GROUP_B.type.group.children.last;
          final GROUP_B_3_006 = GROUP_B_3.type.group.children.first;
          expect(GROUP_B_3.cells['column2']!.value, '3');
          expect(GROUP_B_3_006.cells['column3']!.value, '006');

          final GROUP_C = stateManager.refRows[2];
          final GROUP_C_1 = GROUP_C.type.group.children.first;
          final GROUP_C_1_007 = GROUP_C_1.type.group.children.first;
          final GROUP_C_2 = GROUP_C.type.group.children.last;
          final GROUP_C_2_008 = GROUP_C_2.type.group.children.first;
          expect(GROUP_C.cells['column1']!.value, 'C');
          expect(GROUP_C_1.cells['column2']!.value, '1');
          expect(GROUP_C_1_007.cells['column3']!.value, '007');
          expect(GROUP_C_2.cells['column2']!.value, '2');
          expect(GROUP_C_2_008.cells['column3']!.value, '008');
        },
      );
    });

    group('removeRows', () {
      test('Removing row 001 should remove the row.', () {
        /// A - 1 - 001
        ///   - 2 - 002
        /// B - 1 - 003, 004
        ///   - 2 - 005
        final A = stateManager.refRows[0];
        final A_1 = A.type.group.children[0];
        final A_1_001 = A_1.type.group.children[0];
        expect(A_1_001.cells['column3']!.value, '001');

        stateManager.removeRows([A_1_001]);

        expect(stateManager.refRows[0], A);
        expect(stateManager.refRows[0].type.group.children.length, 1);
        expect(stateManager.refRows[0].type.group.children[0], isNot(A_1));

        findRemovedRows(e) => e.key == A_1.key || e.key == A_1_001.key;
        expect(
          stateManager.iterateAllRowAndGroup.where(findRemovedRows).length,
          0,
        );
      });

      test('Removing row 003 should remove the row.', () {
        /// A - 1 - 001
        ///   - 2 - 002
        /// B - 1 - 003, 004
        ///   - 2 - 005
        final B = stateManager.refRows[1];
        final B_1 = B.type.group.children[0];
        final B_1_003 = B_1.type.group.children[0];

        expect(stateManager.iterateAllRowAndGroup.length, 11);

        stateManager.removeRows([B_1_003]);

        expect(stateManager.iterateAllRowAndGroup.length, 10);

        expect(B_1.type.group.children.length, 1);
        expect(B_1.type.group.children[0], isNot(B_1_003));
        findRemovedRows(e) => e.key == B_1_003;
        expect(
          stateManager.iterateAllRowAndGroup.where(findRemovedRows).length,
          0,
        );
      });

      test('Removing rows 003, 004 should remove the rows.', () {
        /// A - 1 - 001
        ///   - 2 - 002
        /// B - 1 - 003, 004
        ///   - 2 - 005
        final B = stateManager.refRows[1];
        final B_1 = B.type.group.children[0];
        final B_1_003 = B_1.type.group.children[0];
        final B_1_004 = B_1.type.group.children[1];

        expect(B.type.group.children.length, 2);
        expect(stateManager.iterateAllRowAndGroup.length, 11);

        stateManager.removeRows([B_1_003, B_1_004]);

        expect(B.type.group.children.length, 1);
        expect(stateManager.iterateAllRowAndGroup.length, 8);
        expect(B.type.group.children[0], isNot(B_1));
        findRemovedRows(e) =>
            e.key == B_1 || e.key == B_1_003 || e.key == B_1_004;
        expect(
          stateManager.iterateAllRowAndGroup.where(findRemovedRows).length,
          0,
        );
      });
    });
  });

  /// G100
  ///   - G110
  ///     - R111
  ///     - R112
  ///   - R120
  ///   - R130
  /// G200
  ///   - R210
  ///   - G220
  ///     - R221
  ///     - R222
  group('Grouping up to 3 levels - TrinaRowGroupTreeDelegate', () {
    late List<TrinaColumn> columns;

    late List<TrinaRow> rows;

    late TrinaGridStateManager stateManager;

    Map<String, TrinaCell> createCell(String value) {
      return {
        'column1': TrinaCell(value: value),
        'column2': TrinaCell(value: ''),
        'column3': TrinaCell(value: ''),
        'column4': TrinaCell(value: ''),
        'column5': TrinaCell(value: ''),
      };
    }

    setUp(() {
      columns = [
        TrinaColumn(
          title: 'column1',
          field: 'column1',
          type: TrinaColumnType.text(),
        ),
        TrinaColumn(
          title: 'column2',
          field: 'column2',
          type: TrinaColumnType.text(),
        ),
        TrinaColumn(
          title: 'column3',
          field: 'column3',
          type: TrinaColumnType.text(),
        ),
        TrinaColumn(
          title: 'column4',
          field: 'column4',
          type: TrinaColumnType.text(),
        ),
        TrinaColumn(
          title: 'column5',
          field: 'column5',
          type: TrinaColumnType.text(),
        ),
      ];

      rows = [
        TrinaRow(
          cells: createCell('G100'),
          type: TrinaRowType.group(
            children: FilteredList(
              initialList: [
                TrinaRow(
                  cells: createCell('G110'),
                  type: TrinaRowType.group(
                    children: FilteredList(
                      initialList: [
                        TrinaRow(cells: createCell('R111')),
                        TrinaRow(cells: createCell('R112')),
                      ],
                    ),
                  ),
                ),
                TrinaRow(cells: createCell('R120')),
                TrinaRow(cells: createCell('R130')),
              ],
            ),
          ),
        ),
        TrinaRow(
          cells: createCell('G200'),
          type: TrinaRowType.group(
            children: FilteredList(
              initialList: [
                TrinaRow(cells: createCell('R210')),
                TrinaRow(
                  cells: createCell('G220'),
                  type: TrinaRowType.group(
                    children: FilteredList(
                      initialList: [
                        TrinaRow(cells: createCell('R221')),
                        TrinaRow(cells: createCell('R222')),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ];

      stateManager = createStateManager(columns: columns, rows: rows);

      stateManager.setRowGroup(
        TrinaRowGroupTreeDelegate(
          resolveColumnDepth: (column) => stateManager.columnIndex(column),
          showText: (cell) => cell.row.type.isNormal,
        ),
      );
    });

    test('When there is a row group, return true.', () {
      expect(stateManager.hasRowGroups, true);
    });

    test('When there is a row group, return true.', () {
      expect(stateManager.enabledRowGroups, true);
    });

    test('When there is a row group, return TrinaRowGroupTreeDelegate.', () {
      expect(stateManager.rowGroupDelegate is TrinaRowGroupTreeDelegate, true);
    });

    test('When there is a row group, return 2 rows.', () {
      expect(stateManager.iterateAllMainRowGroup.length, 2);
    });

    test('When there is a row group, return 4 rows.', () {
      expect(stateManager.iterateAllRowGroup.length, 4);
    });

    test('When there is a row group, return 11 rows.', () {
      expect(stateManager.iterateAllRowAndGroup.length, 11);
    });

    test('When there is a row group, return 7 rows.', () {
      expect(stateManager.iterateAllRow.length, 7);
    });

    test('When there is a row group, return 2 rows.', () {
      expect(stateManager.refRows.length, 2);
      expect(stateManager.isMainRow(stateManager.refRows[0]), true);
      expect(stateManager.isMainRow(stateManager.refRows[1]), true);
    });

    test('When there is a row group, the parent should be set correctly.', () {
      final G100 = stateManager.refRows[0];
      final G100_CHILDREN = G100.type.group.children;
      expect(G100.parent, null);
      expect(G100_CHILDREN.length, 3);
      expect(G100_CHILDREN.length, 3);
      expect(G100_CHILDREN[0].parent, G100);
      expect(G100_CHILDREN[1].parent, G100);
      expect(G100_CHILDREN[2].parent, G100);

      final G110 = G100_CHILDREN[0];
      final G110_CHILDREN = G110.type.group.children;
      expect(G110_CHILDREN.length, 2);
      expect(G110_CHILDREN[0].parent, G110);
      expect(G110_CHILDREN[0].parent?.parent, G100);
      expect(G110_CHILDREN[1].parent, G110);
      expect(G110_CHILDREN[1].parent?.parent, G100);

      final G200 = stateManager.refRows[1];
      expect(G200.parent, null);
      expect(G200.type.group.children.length, 2);
      expect(G200.type.group.children[0].parent, G200);
      expect(G200.type.group.children[1].parent, G200);

      final G220 = G200.type.group.children[1];
      final G220_CHILDREN = G220.type.group.children;
      expect(G220_CHILDREN.length, 2);
      expect(G220_CHILDREN[0].parent, G220);
      expect(G220_CHILDREN[0].parent?.parent, G200);
      expect(G220_CHILDREN[1].parent, G220);
      expect(G220_CHILDREN[1].parent?.parent, G200);
    });

    test(
      'When all columns are removed and new columns are added, the cells of the existing rows should be added.',
      () {
        stateManager.removeColumns(columns);

        expect(stateManager.refColumns.originalList.length, 0);
        expect(stateManager.refRows.originalList.length, 2);

        for (final row in stateManager.refRows.originalList) {
          expect(row.parent, null);
          expect(row.cells['column1'], null);
          expect(row.cells['column2'], null);
          expect(row.cells['column3'], null);
          expect(row.cells['column4'], null);
          expect(row.cells['column5'], null);
        }

        stateManager.insertColumns(0, [
          TrinaColumn(
            title: 'column6',
            field: 'column6',
            type: TrinaColumnType.text(),
          ),
        ]);

        expect(stateManager.refColumns.originalList.length, 1);
        expect(stateManager.refRows.originalList.length, 2);

        final rowAndGroup = stateManager.iterateAllRowAndGroup.toList();

        expect(rowAndGroup.length, 11);
        for (final row in rowAndGroup) {
          expect(row.cells['column1'], null);
          expect(row.cells['column2'], null);
          expect(row.cells['column3'], null);
          expect(row.cells['column4'], null);
          expect(row.cells['column5'], null);
          expect(row.cells['column6'], isNot(null));
        }
      },
    );

    /// G300
    ///   - G310
    ///   - G320
    ///     - G321
    ///     - G322
    /// G100
    ///   - G110
    ///     - R111
    ///     - R112
    ///   - R120
    ///   - R130
    /// G200
    ///   - R210
    ///   - G220
    ///     - R221
    ///     - R222
    group('insertAll', () {
      group('Adding a 3-depth group at position 0.', () {
        setUp(() {
          stateManager.insertRows(0, [
            TrinaRow(
              cells: createCell('G300'),
              type: TrinaRowType.group(
                children: FilteredList(
                  initialList: [
                    TrinaRow(cells: createCell('G310')),
                    TrinaRow(
                      cells: createCell('G320'),
                      type: TrinaRowType.group(
                        children: FilteredList(
                          initialList: [
                            TrinaRow(cells: createCell('G321')),
                            TrinaRow(cells: createCell('G322')),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ]);
        });

        test('The first row should have G300 added.', () {
          expect(stateManager.refRows[0].cells['column1']!.value, 'G300');
          expect(stateManager.refRows[1].cells['column1']!.value, 'G100');
          expect(stateManager.refRows[2].cells['column1']!.value, 'G200');
        });

        test('The added rows should have their parent set.', () {
          final G300 = stateManager.refRows[0];
          final G310 = G300.type.group.children[0];
          final G320 = G300.type.group.children[1];
          final G321 = G320.type.group.children[0];
          final G322 = G320.type.group.children[1];

          expect(G310.parent, G300);
          expect(G320.parent, G300);
          expect(G321.parent, G320);
          expect(G321.parent?.parent, G300);
          expect(G322.parent, G320);
          expect(G322.parent?.parent, G300);
        });

        test('The added G300 should have its sortIdx set.', () {
          final G300 = stateManager.refRows[0];
          final G100 = stateManager.refRows[1];
          final G200 = stateManager.refRows[2];
          expect(G300.sortIdx, 0);
          expect(G100.sortIdx, 1);
          expect(G200.sortIdx, 2);
        });

        test('Toggling G300 should add G310 and G320 to refRows.', () {
          final G300 = stateManager.refRows[0];
          expect(G300.cells['column1']!.value, 'G300');

          stateManager.toggleExpandedRowGroup(rowGroup: G300);

          expect(stateManager.refRows[0].cells['column1']!.value, 'G300');
          expect(stateManager.refRows[1].cells['column1']!.value, 'G310');
          expect(stateManager.refRows[2].cells['column1']!.value, 'G320');
        });

        test(
          'Toggling G300 and adding G400 to the 1st index of G310 should make G400 a child of G310.',
          () {
            final G300 = stateManager.refRows[0];
            stateManager.toggleExpandedRowGroup(rowGroup: G300);

            final addedRow = TrinaRow(cells: createCell('G400'));

            stateManager.insertRows(1, [addedRow]);

            expect(stateManager.refRows[0].cells['column1']!.value, 'G300');
            expect(stateManager.refRows[1].cells['column1']!.value, 'G400');
            expect(stateManager.refRows[2].cells['column1']!.value, 'G310');
            expect(stateManager.refRows[3].cells['column1']!.value, 'G320');
            expect(stateManager.refRows[4].cells['column1']!.value, 'G100');
            expect(stateManager.refRows[5].cells['column1']!.value, 'G200');

            final G400 = stateManager.refRows[1];
            expect(G400.parent, G300);

            expect(G300.type.group.children[0].sortIdx, 0);
            expect(G300.type.group.children[0], G400);
            expect(G300.type.group.children[1].sortIdx, 1);
            expect(G300.type.group.children[1].cells['column1']!.value, 'G310');
            expect(G300.type.group.children[2].sortIdx, 2);
            expect(G300.type.group.children[2].cells['column1']!.value, 'G320');

            /// Re-toggling G300 should make G100 and G200 the next level.
            stateManager.toggleExpandedRowGroup(rowGroup: G300);
            expect(stateManager.refRows[0].cells['column1']!.value, 'G300');
            expect(stateManager.refRows[1].cells['column1']!.value, 'G100');
            expect(stateManager.refRows[2].cells['column1']!.value, 'G200');
          },
        );

        test(
          'Toggling G200 and G220 and adding G400 to the 7th index should add it as the last group.',
          () {
            final G200 = stateManager.refRows[2];
            final G220 = G200.type.group.children[1];
            stateManager.toggleExpandedRowGroup(rowGroup: G200);
            stateManager.toggleExpandedRowGroup(rowGroup: G220);

            final addedRow = TrinaRow(cells: createCell('G400'));

            stateManager.insertRows(7, [addedRow]);

            expect(stateManager.refRows[0].cells['column1']!.value, 'G300');
            expect(stateManager.refRows[1].cells['column1']!.value, 'G100');
            expect(stateManager.refRows[2].cells['column1']!.value, 'G200');
            expect(stateManager.refRows[3].cells['column1']!.value, 'R210');
            expect(stateManager.refRows[4].cells['column1']!.value, 'G220');
            expect(stateManager.refRows[5].cells['column1']!.value, 'R221');
            expect(stateManager.refRows[6].cells['column1']!.value, 'R222');
            expect(stateManager.refRows[7].cells['column1']!.value, 'G400');
          },
        );
      });
    });
  });

  group('RowGroupState expandAllRowGroups and collapseAllRowGroups', () {
    late TrinaGridStateManager stateManager;
    late List<TrinaColumn> columns;
    late List<TrinaRow> rows;

    setUp(() {
      columns = [
        TrinaColumn(
          title: 'Category',
          field: 'category',
          type: TrinaColumnType.text(),
        ),
        TrinaColumn(
          title: 'Subcategory',
          field: 'subcategory',
          type: TrinaColumnType.text(),
        ),
        TrinaColumn(
          title: 'Product',
          field: 'product',
          type: TrinaColumnType.text(),
        ),
      ];

      rows = [
        TrinaRow(
          cells: {
            'category': TrinaCell(value: 'Electronics'),
            'subcategory': TrinaCell(value: 'Phones'),
            'product': TrinaCell(value: 'Smartphone X'),
          },
        ),
        TrinaRow(
          cells: {
            'category': TrinaCell(value: 'Electronics'),
            'subcategory': TrinaCell(value: 'Phones'),
            'product': TrinaCell(value: 'Smartphone Y'),
          },
        ),
        TrinaRow(
          cells: {
            'category': TrinaCell(value: 'Electronics'),
            'subcategory': TrinaCell(value: 'Laptops'),
            'product': TrinaCell(value: 'Laptop Z'),
          },
        ),
        TrinaRow(
          cells: {
            'category': TrinaCell(value: 'Clothing'),
            'subcategory': TrinaCell(value: 'Shirts'),
            'product': TrinaCell(value: 'T-Shirt'),
          },
        ),
      ];

      stateManager = TrinaGridStateManager(
        columns: columns,
        rows: rows,
        gridFocusNode: FocusNode(),
        scroll: TrinaGridScrollController(),
      );

      stateManager.setRowGroup(
        TrinaRowGroupByColumnDelegate(columns: [columns[0], columns[1]]),
      );
    });

    tearDown(() {
      stateManager.dispose();
    });

    test('expandAllRowGroups should expand all collapsed groups', () {
      // Initially, all groups should be collapsed
      final groupRows = stateManager.iterateAllRowGroup.toList();
      expect(groupRows.isNotEmpty, true);

      // Check that some groups are collapsed
      final collapsedGroups = groupRows
          .where((row) => !row.type.group.expanded)
          .toList();
      expect(collapsedGroups.isNotEmpty, true);

      // Expand all groups
      stateManager.expandAllRowGroups();

      // Check that all groups are now expanded
      final allGroupsExpanded = stateManager.iterateAllRowGroup.every(
        (row) => row.type.group.expanded,
      );
      expect(allGroupsExpanded, true);
    });

    test('collapseAllRowGroups should collapse all expanded groups', () {
      // First expand all groups
      stateManager.expandAllRowGroups();

      // Verify all groups are expanded
      final allGroupsExpanded = stateManager.iterateAllRowGroup.every(
        (row) => row.type.group.expanded,
      );
      expect(allGroupsExpanded, true);

      // Collapse all groups
      stateManager.collapseAllRowGroups();

      // Check that all groups are now collapsed
      final allGroupsCollapsed = stateManager.iterateAllRowGroup.every(
        (row) => !row.type.group.expanded,
      );
      expect(allGroupsCollapsed, true);
    });

    test(
      'expandAllRowGroups should do nothing when row groups are not enabled',
      () {
        // Create a state manager without row groups
        final stateManagerNoGroups = TrinaGridStateManager(
          columns: columns,
          rows: rows,
          gridFocusNode: FocusNode(),
          scroll: TrinaGridScrollController(),
        );

        // This should not throw an error
        expect(
          () => stateManagerNoGroups.expandAllRowGroups(),
          returnsNormally,
        );

        stateManagerNoGroups.dispose();
      },
    );

    test(
      'collapseAllRowGroups should do nothing when row groups are not enabled',
      () {
        // Create a state manager without row groups
        final stateManagerNoGroups = TrinaGridStateManager(
          columns: columns,
          rows: rows,
          gridFocusNode: FocusNode(),
          scroll: TrinaGridScrollController(),
        );

        // This should not throw an error
        expect(
          () => stateManagerNoGroups.collapseAllRowGroups(),
          returnsNormally,
        );

        stateManagerNoGroups.dispose();
      },
    );

    test('expandAllRowGroups should actually expand visible rows', () {
      stateManager.setRowGroup(
        TrinaRowGroupByColumnDelegate(columns: [columns[0], columns[1]]),
      );

      // Initially, only main group rows should be visible
      final initialVisibleCount = stateManager.refRows.length;

      // Expand all groups
      stateManager.expandAllRowGroups();

      // Now more rows should be visible
      final expandedVisibleCount = stateManager.refRows.length;
      expect(expandedVisibleCount, greaterThan(initialVisibleCount));

      // Collapse all groups
      stateManager.collapseAllRowGroups();

      // Should be back to initial count
      final collapsedVisibleCount = stateManager.refRows.length;
      expect(collapsedVisibleCount, equals(initialVisibleCount));
    });

    test('collapseAllRowGroups should actually collapse visible rows', () {
      stateManager.setRowGroup(
        TrinaRowGroupByColumnDelegate(columns: [columns[0], columns[1]]),
      );

      // Expand all first
      stateManager.expandAllRowGroups();
      final expandedCount = stateManager.refRows.length;

      // Then collapse all
      stateManager.collapseAllRowGroups();
      final collapsedCount = stateManager.refRows.length;

      expect(collapsedCount, lessThan(expandedCount));
    });
  });
}
