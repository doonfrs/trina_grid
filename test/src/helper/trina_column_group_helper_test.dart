import 'package:flutter_test/flutter_test.dart';
import 'package:trina_grid/trina_grid.dart';

import '../../helper/column_helper.dart';

void main() {
  group('exists', () {
    test(
      'When the field is in the columnGroup.fields list, true should be returned.',
      () {
        const title = 'title';

        const field = 'DUMMY_FIELD';

        final fields = ['DUMMY_FIELD'];

        final columnGroup = TrinaColumnGroup(title: title, fields: fields);

        expect(
          TrinaColumnGroupHelper.exists(field: field, columnGroup: columnGroup),
          true,
        );
      },
    );

    test(
      'When the field is not in the columnGroup.fields list, false should be returned.',
      () {
        const title = 'title';

        const field = 'NON_EXISTS_DUMMY_FIELD';

        final fields = ['DUMMY_FIELD'];

        final columnGroup = TrinaColumnGroup(title: title, fields: fields);

        expect(
          TrinaColumnGroupHelper.exists(field: field, columnGroup: columnGroup),
          false,
        );
      },
    );

    test(
      'When the field is in the columnGroup.children list, true should be returned.',
      () {
        const title = 'title';

        const field = 'DUMMY_FIELD';

        final children = [
          TrinaColumnGroup(title: 'title', fields: ['DUMMY_FIELD']),
        ];

        final columnGroup = TrinaColumnGroup(title: title, children: children);

        expect(
          TrinaColumnGroupHelper.exists(field: field, columnGroup: columnGroup),
          true,
        );
      },
    );

    test(
      'When the field is not in the columnGroup.children list, false should be returned.',
      () {
        const title = 'title';

        const field = 'NON_EXISTS_DUMMY_FIELD';

        final children = [
          TrinaColumnGroup(title: 'title', fields: ['DUMMY_FIELD']),
        ];

        final columnGroup = TrinaColumnGroup(title: title, children: children);

        expect(
          TrinaColumnGroupHelper.exists(field: field, columnGroup: columnGroup),
          false,
        );
      },
    );

    test(
      'When the field is in the columnGroup.children list of depth 2, true should be returned.',
      () {
        const title = 'title';

        const field = 'DUMMY_FIELD';

        final children = [
          TrinaColumnGroup(
            title: 'title',
            children: [
              TrinaColumnGroup(title: 'title', fields: ['DUMMY_FIELD']),
            ],
          ),
        ];

        final columnGroup = TrinaColumnGroup(title: title, children: children);

        expect(
          TrinaColumnGroupHelper.exists(field: field, columnGroup: columnGroup),
          true,
        );
      },
    );
  });

  group('existsFromList', () {
    test('When the field is in the list, true should be returned.', () {
      const field = 'column1';

      final columnGroupList = [
        TrinaColumnGroup(title: 'title', fields: ['column1', 'column2']),
        TrinaColumnGroup(title: 'title', fields: ['column3', 'column4']),
        TrinaColumnGroup(title: 'title', fields: ['column5', 'column6']),
      ];

      expect(
        TrinaColumnGroupHelper.existsFromList(
          field: field,
          columnGroupList: columnGroupList,
        ),
        true,
      );
    });

    test('When the field is not in the list, false should be returned.', () {
      const field = 'non_exists';

      final columnGroupList = [
        TrinaColumnGroup(title: 'title', fields: ['column1', 'column2']),
        TrinaColumnGroup(title: 'title', fields: ['column3', 'column4']),
        TrinaColumnGroup(title: 'title', fields: ['column5', 'column6']),
      ];

      expect(
        TrinaColumnGroupHelper.existsFromList(
          field: field,
          columnGroupList: columnGroupList,
        ),
        false,
      );
    });
  });

  group('getGroupIfExistsFromList', () {
    test('When the field is in the group, the group should be returned.', () {
      const field = 'column1';

      final columnGroup = TrinaColumnGroup(
        title: 'title',
        fields: ['column1', 'column2'],
      );

      final columnGroupList = [
        columnGroup,
        TrinaColumnGroup(title: 'title', fields: ['column3', 'column4']),
        TrinaColumnGroup(title: 'title', fields: ['column5', 'column6']),
      ];

      expect(
        TrinaColumnGroupHelper.getGroupIfExistsFromList(
          field: field,
          columnGroupList: columnGroupList,
        ),
        columnGroup,
      );
    });

    test('When the field is not in the group, null should be returned.', () {
      const field = 'non_exists';

      final columnGroupList = [
        TrinaColumnGroup(title: 'title', fields: ['column1', 'column2']),
        TrinaColumnGroup(title: 'title', fields: ['column3', 'column4']),
        TrinaColumnGroup(title: 'title', fields: ['column5', 'column6']),
      ];

      expect(
        TrinaColumnGroupHelper.getGroupIfExistsFromList(
          field: field,
          columnGroupList: columnGroupList,
        ),
        null,
      );
    });
  });

  group('separateLinkedGroup', () {
    test(
      'When the columnGroupList is empty, an empty list should be returned.',
      () {
        final columnGroupList = <TrinaColumnGroup>[];

        final columns = ColumnHelper.textColumn('column', count: 6, start: 1);

        expect(
          TrinaColumnGroupHelper.separateLinkedGroup(
            columnGroupList: columnGroupList,
            columns: columns,
          ),
          isEmpty,
        );
      },
    );

    test('When the columns is empty, an empty list should be returned.', () {
      final columnGroupList = <TrinaColumnGroup>[
        TrinaColumnGroup(title: 'title', fields: ['column1', 'column2']),
        TrinaColumnGroup(title: 'title', fields: ['column3', 'column4']),
        TrinaColumnGroup(title: 'title', fields: ['column5', 'column6']),
      ];

      final columns = <TrinaColumn>[];

      expect(
        TrinaColumnGroupHelper.separateLinkedGroup(
          columnGroupList: columnGroupList,
          columns: columns,
        ),
        isEmpty,
      );
    });

    test(
      'When the columns is [column1, column2, column3, column4, column5, column6], '
      '3 TrinaColumnGroupPair should be returned.',
      () {
        final columnGroupList = <TrinaColumnGroup>[
          TrinaColumnGroup(title: 'title', fields: ['column1', 'column2']),
          TrinaColumnGroup(title: 'title', fields: ['column3', 'column4']),
          TrinaColumnGroup(title: 'title', fields: ['column5', 'column6']),
        ];

        final columns = ColumnHelper.textColumn('column', count: 6, start: 1);

        final result = TrinaColumnGroupHelper.separateLinkedGroup(
          columnGroupList: columnGroupList,
          columns: columns,
        );

        expect(result.length, 3);

        expect(result[0].group, same(columnGroupList[0]));
        expect(result[1].group, same(columnGroupList[1]));
        expect(result[2].group, same(columnGroupList[2]));

        expect(result[0].columns.length, 2);
        expect(result[1].columns.length, 2);
        expect(result[2].columns.length, 2);

        expect(
          result[0].columns,
          containsAllInOrder(<TrinaColumn>[columns[0], columns[1]]),
        );
        expect(
          result[1].columns,
          containsAllInOrder(<TrinaColumn>[columns[2], columns[3]]),
        );
        expect(
          result[2].columns,
          containsAllInOrder(<TrinaColumn>[columns[4], columns[5]]),
        );
      },
    );

    test(
      'When the columns is [column1, column3, column4, column2, column5, column6], '
      '4 TrinaColumnGroupPair should be returned.',
      () {
        final columnGroupList = <TrinaColumnGroup>[
          TrinaColumnGroup(title: 'title', fields: ['column1', 'column2']),
          TrinaColumnGroup(title: 'title', fields: ['column3', 'column4']),
          TrinaColumnGroup(title: 'title', fields: ['column5', 'column6']),
        ];

        final columns = [
          ...ColumnHelper.textColumn('column', count: 1, start: 1),
          ...ColumnHelper.textColumn('column', count: 1, start: 3),
          ...ColumnHelper.textColumn('column', count: 1, start: 4),
          ...ColumnHelper.textColumn('column', count: 1, start: 2),
          ...ColumnHelper.textColumn('column', count: 1, start: 5),
          ...ColumnHelper.textColumn('column', count: 1, start: 6),
        ];

        final result = TrinaColumnGroupHelper.separateLinkedGroup(
          columnGroupList: columnGroupList,
          columns: columns,
        );

        expect(result.length, 4);

        expect(result[0].group, same(columnGroupList[0]));
        expect(result[1].group, same(columnGroupList[1]));
        expect(result[2].group, same(columnGroupList[0]));
        expect(result[3].group, same(columnGroupList[2]));

        expect(result[0].columns.length, 1);
        expect(result[1].columns.length, 2);
        expect(result[2].columns.length, 1);
        expect(result[3].columns.length, 2);

        expect(
          result[0].columns,
          containsAllInOrder(<TrinaColumn>[columns[0]]),
        );
        expect(
          result[1].columns,
          containsAllInOrder(<TrinaColumn>[columns[1], columns[2]]),
        );
        expect(
          result[2].columns,
          containsAllInOrder(<TrinaColumn>[columns[3]]),
        );
        expect(
          result[3].columns,
          containsAllInOrder(<TrinaColumn>[columns[4], columns[5]]),
        );
      },
    );

    test(
      'When columns is [column1, column2, column3, column4, column5, column6], '
      'and column6 is not in the group, column6 should be included in a new group and 4 groups should be returned.',
      () {
        final columnGroupList = <TrinaColumnGroup>[
          TrinaColumnGroup(title: 'title', fields: ['column1', 'column2']),
          TrinaColumnGroup(title: 'title', fields: ['column3', 'column4']),
          TrinaColumnGroup(title: 'title', fields: ['column5']),
        ];

        final columns = ColumnHelper.textColumn('column', count: 6, start: 1);

        final result = TrinaColumnGroupHelper.separateLinkedGroup(
          columnGroupList: columnGroupList,
          columns: columns,
        );

        expect(result.length, 4);

        expect(result[0].group.expandedColumn, false);
        expect(result[1].group.expandedColumn, false);
        expect(result[2].group.expandedColumn, false);

        expect(result[3].group.expandedColumn, true);
        expect(result[3].columns, contains(columns[5]));
      },
    );
  });

  group('maxDepth', () {
    test('When the depth of the group is 1, 1 should be returned.', () {
      const expectedDepth = 1;

      final columnGroupList = [
        TrinaColumnGroup(title: 'title', fields: ['column1', 'column2']),
        TrinaColumnGroup(title: 'title', fields: ['column3', 'column4']),
        TrinaColumnGroup(title: 'title', fields: ['column5', 'column6']),
      ];

      expect(
        TrinaColumnGroupHelper.maxDepth(columnGroupList: columnGroupList),
        expectedDepth,
      );
    });

    test('When the depth of the group is 2, 2 should be returned.', () {
      const expectedDepth = 2;

      final columnGroupList = [
        TrinaColumnGroup(
          title: 'title',
          children: [
            TrinaColumnGroup(title: 'title', fields: ['column1']),
            TrinaColumnGroup(title: 'title', fields: ['column2']),
          ],
        ),
        TrinaColumnGroup(title: 'title', fields: ['column3', 'column4']),
        TrinaColumnGroup(title: 'title', fields: ['column5', 'column6']),
      ];

      expect(
        TrinaColumnGroupHelper.maxDepth(columnGroupList: columnGroupList),
        expectedDepth,
      );
    });

    test('When the depth of the group is 3, 3 should be returned.', () {
      const expectedDepth = 3;

      final columnGroupList = [
        TrinaColumnGroup(
          title: 'title',
          children: [
            TrinaColumnGroup(title: 'title', fields: ['column1']),
            TrinaColumnGroup(
              title: 'title',
              children: [
                TrinaColumnGroup(title: 'title', fields: ['column2']),
                TrinaColumnGroup(title: 'title', fields: ['column3']),
              ],
            ),
          ],
        ),
        TrinaColumnGroup(title: 'title', fields: ['column4']),
        TrinaColumnGroup(title: 'title', fields: ['column5', 'column6']),
      ];

      expect(
        TrinaColumnGroupHelper.maxDepth(columnGroupList: columnGroupList),
        expectedDepth,
      );
    });

    test('When the depth of the group is 3, 3 should be returned.', () {
      const expectedDepth = 3;

      final columnGroupList = [
        TrinaColumnGroup(
          title: 'title',
          children: [
            TrinaColumnGroup(
              title: 'title',
              children: [
                TrinaColumnGroup(title: 'title', fields: ['column2']),
                TrinaColumnGroup(title: 'title', fields: ['column3']),
              ],
            ),
            TrinaColumnGroup(title: 'title', fields: ['column1']),
          ],
        ),
        TrinaColumnGroup(title: 'title', fields: ['column4']),
        TrinaColumnGroup(title: 'title', fields: ['column5', 'column6']),
      ];

      expect(
        TrinaColumnGroupHelper.maxDepth(columnGroupList: columnGroupList),
        expectedDepth,
      );
    });

    test('When the depth of the group is 4, 4 should be returned.', () {
      const expectedDepth = 4;

      final columnGroupList = [
        TrinaColumnGroup(
          title: 'title',
          children: [
            TrinaColumnGroup(
              title: 'title',
              children: [
                TrinaColumnGroup(title: 'title', fields: ['column2']),
                TrinaColumnGroup(
                  title: 'title',
                  children: [
                    TrinaColumnGroup(title: 'title', fields: ['column3']),
                    TrinaColumnGroup(title: 'title', fields: ['column5']),
                  ],
                ),
              ],
            ),
            TrinaColumnGroup(title: 'title', fields: ['column1']),
          ],
        ),
        TrinaColumnGroup(title: 'title', fields: ['column4']),
        TrinaColumnGroup(title: 'title', fields: ['column6']),
      ];

      expect(
        TrinaColumnGroupHelper.maxDepth(columnGroupList: columnGroupList),
        expectedDepth,
      );
    });

    test('When the depth of the group is 5, 5 should be returned.', () {
      const expectedDepth = 5;

      final columnGroupList = [
        TrinaColumnGroup(
          title: 'title',
          children: [
            TrinaColumnGroup(
              title: 'title',
              children: [
                TrinaColumnGroup(title: 'title', fields: ['column2']),
                TrinaColumnGroup(
                  title: 'title',
                  children: [
                    TrinaColumnGroup(title: 'title', fields: ['column3']),
                    TrinaColumnGroup(
                      title: 'title',
                      children: [
                        TrinaColumnGroup(title: 'title', fields: ['column5']),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            TrinaColumnGroup(title: 'title', fields: ['column1']),
          ],
        ),
        TrinaColumnGroup(title: 'title', fields: ['column4']),
        TrinaColumnGroup(title: 'title', fields: ['column6']),
      ];

      expect(
        TrinaColumnGroupHelper.maxDepth(columnGroupList: columnGroupList),
        expectedDepth,
      );
    });
  });
}
