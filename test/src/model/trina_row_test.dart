import 'package:flutter_test/flutter_test.dart';
import 'package:trina_grid/trina_grid.dart';

import '../../matcher/trina_object_matcher.dart';

void main() {
  group('fromJson', () {
    test(
      'When all checkboxes are checked, all groups and rows should be checked',
      () {
        final json = {
          'column1': 'value1',
          'column2': 'value2',
          'column3': 'value3',
        };

        expect(
          TrinaRow.fromJson(json),
          TrinaObjectMatcher<TrinaRow>(
            rule: (row) {
              return row.cells.length == 3 &&
                  row.cells['column1']!.value == 'value1' &&
                  row.cells['column2']!.value == 'value2' &&
                  row.cells['column3']!.value == 'value3' &&
                  row.type.isNormal;
            },
          ),
        );
      },
    );

    test(
      'When all checkboxes are checked, all groups and rows should be checked',
      () {
        final json = {'column1': 123, 'column2': 3.12, 'column3': -123};

        expect(
          TrinaRow.fromJson(json),
          TrinaObjectMatcher<TrinaRow>(
            rule: (row) {
              return row.cells.length == 3 &&
                  row.cells['column1']!.value == 123 &&
                  row.cells['column2']!.value == 3.12 &&
                  row.cells['column3']!.value == -123 &&
                  row.type.isNormal;
            },
          ),
        );
      },
    );

    test('When childrenField is children'
        'then type should be group.', () {
      final json = {
        'column1': 'group value1',
        'column2': 'group value2',
        'column3': 'group value3',
        'children': [
          {
            'column1': 'child1 value1',
            'column2': 'child1 value2',
            'column3': 'child1 value3',
          },
          {
            'column1': 'child2 value1',
            'column2': 'child2 value2',
            'column3': 'child2 value3',
          },
        ],
      };

      expect(
        TrinaRow.fromJson(json, childrenField: 'children'),
        TrinaObjectMatcher<TrinaRow>(
          rule: (row) {
            final bool checkCell =
                row.cells.length == 3 &&
                row.cells['column1']!.value == 'group value1' &&
                row.cells['column2']!.value == 'group value2' &&
                row.cells['column3']!.value == 'group value3';

            final bool checkChild1 =
                row.type.group.children[0].type.isNormal &&
                row.type.group.children[0].cells['column1']!.value ==
                    'child1 value1' &&
                row.type.group.children[0].cells['column2']!.value ==
                    'child1 value2' &&
                row.type.group.children[0].cells['column3']!.value ==
                    'child1 value3';

            final bool checkChild2 =
                row.type.group.children[1].type.isNormal &&
                row.type.group.children[1].cells['column1']!.value ==
                    'child2 value1' &&
                row.type.group.children[1].cells['column2']!.value ==
                    'child2 value2' &&
                row.type.group.children[1].cells['column3']!.value ==
                    'child2 value3';

            return checkCell &&
                row.type.isGroup &&
                row.type.group.children.length == 2 &&
                checkChild1 &&
                checkChild2;
          },
        ),
      );
    });

    test('When childrenField is items', () {
      final json = {
        'column1': 'group value1',
        'column2': 'group value2',
        'column3': 'group value3',
        'items': [
          {
            'column1': 'child1 value1',
            'column2': 'child1 value2',
            'column3': 'child1 value3',
          },
          {
            'column1': 'child2 value1',
            'column2': 'child2 value2',
            'column3': 'child2 value3',
          },
        ],
      };

      expect(
        TrinaRow.fromJson(json, childrenField: 'items'),
        TrinaObjectMatcher<TrinaRow>(
          rule: (row) {
            final bool checkCell =
                row.cells.length == 3 &&
                row.cells['column1']!.value == 'group value1' &&
                row.cells['column2']!.value == 'group value2' &&
                row.cells['column3']!.value == 'group value3';

            final bool checkChild1 =
                row.type.group.children[0].type.isNormal &&
                row.type.group.children[0].cells['column1']!.value ==
                    'child1 value1' &&
                row.type.group.children[0].cells['column2']!.value ==
                    'child1 value2' &&
                row.type.group.children[0].cells['column3']!.value ==
                    'child1 value3';

            final bool checkChild2 =
                row.type.group.children[1].type.isNormal &&
                row.type.group.children[1].cells['column1']!.value ==
                    'child2 value1' &&
                row.type.group.children[1].cells['column2']!.value ==
                    'child2 value2' &&
                row.type.group.children[1].cells['column3']!.value ==
                    'child2 value3';

            return checkCell &&
                row.type.isGroup &&
                row.type.group.children.length == 2 &&
                checkChild1 &&
                checkChild2;
          },
        ),
      );
    });

    test('When childrenField is null'
        'then type should be normal.', () {
      final json = {
        'column1': 'group value1',
        'column2': 'group value2',
        'column3': 'group value3',
        'children': [
          {
            'column1': 'child1 value1',
            'column2': 'child1 value2',
            'column3': 'child1 value3',
          },
          {
            'column1': 'child2 value1',
            'column2': 'child2 value2',
            'column3': 'child2 value3',
          },
        ],
      };

      expect(
        TrinaRow.fromJson(json, childrenField: null),
        TrinaObjectMatcher<TrinaRow>(
          rule: (row) {
            return row.cells.length == 4 &&
                row.cells['column1']!.value == 'group value1' &&
                row.cells['column2']!.value == 'group value2' &&
                row.cells['column3']!.value == 'group value3' &&
                row.cells['children']!.value is List<Map<String, String>> &&
                row.type.isNormal;
          },
        ),
      );
    });

    test('When childrenField is not null'
        'then type should be group.', () {
      final json = {
        'column1': 'group value1',
        'column2': 'group value2',
        'column3': 'group value3',
        'children': [
          {
            'column1': 'child1 value1',
            'column2': 'child1 value2',
            'column3': 'child1 value3',
            'children': [
              {
                'column1': 'child1-1 value1',
                'column2': 'child1-1 value2',
                'column3': 'child1-1 value3',
              },
              {
                'column1': 'child1-2 value1',
                'column2': 'child1-2 value2',
                'column3': 'child1-2 value3',
              },
            ],
          },
          {
            'column1': 'child2 value1',
            'column2': 'child2 value2',
            'column3': 'child2 value3',
          },
        ],
      };

      expect(
        TrinaRow.fromJson(json, childrenField: 'children'),
        TrinaObjectMatcher<TrinaRow>(
          rule: (row) {
            final bool checkCell =
                row.cells.length == 3 &&
                row.cells['column1']!.value == 'group value1' &&
                row.cells['column2']!.value == 'group value2' &&
                row.cells['column3']!.value == 'group value3';

            final bool checkChild1 =
                row.type.group.children[0].type.isGroup &&
                row.type.group.children[0].cells['column1']!.value ==
                    'child1 value1' &&
                row.type.group.children[0].cells['column2']!.value ==
                    'child1 value2' &&
                row.type.group.children[0].cells['column3']!.value ==
                    'child1 value3';

            final bool checkChild1_1 =
                row
                    .type
                    .group
                    .children[0]
                    .type
                    .group
                    .children[0]
                    .type
                    .isNormal &&
                row
                        .type
                        .group
                        .children[0]
                        .type
                        .group
                        .children[0]
                        .cells['column1']!
                        .value ==
                    'child1-1 value1' &&
                row
                        .type
                        .group
                        .children[0]
                        .type
                        .group
                        .children[0]
                        .cells['column2']!
                        .value ==
                    'child1-1 value2' &&
                row
                        .type
                        .group
                        .children[0]
                        .type
                        .group
                        .children[0]
                        .cells['column3']!
                        .value ==
                    'child1-1 value3';

            final checkChild1_2 =
                row
                    .type
                    .group
                    .children[0]
                    .type
                    .group
                    .children[1]
                    .type
                    .isNormal &&
                row
                        .type
                        .group
                        .children[0]
                        .type
                        .group
                        .children[1]
                        .cells['column1']!
                        .value ==
                    'child1-2 value1' &&
                row
                        .type
                        .group
                        .children[0]
                        .type
                        .group
                        .children[1]
                        .cells['column2']!
                        .value ==
                    'child1-2 value2' &&
                row
                        .type
                        .group
                        .children[0]
                        .type
                        .group
                        .children[1]
                        .cells['column3']!
                        .value ==
                    'child1-2 value3';

            final checkChild2 =
                row.type.group.children[1].type.isNormal &&
                row.type.group.children[1].cells['column1']!.value ==
                    'child2 value1' &&
                row.type.group.children[1].cells['column2']!.value ==
                    'child2 value2' &&
                row.type.group.children[1].cells['column3']!.value ==
                    'child2 value3';

            return checkCell &&
                row.type.isGroup &&
                row.type.group.children.length == 2 &&
                checkChild1 &&
                row.type.group.children[0].type.group.children.length == 2 &&
                checkChild1_1 &&
                checkChild1_2 &&
                checkChild2;
          },
        ),
      );
    });
  });

  group('toJson', () {
    test('When type is normal'
        'then json should be as expected.', () {
      final TrinaRow row = TrinaRow(
        cells: {
          'column1': TrinaCell(value: 'value1'),
          'column2': TrinaCell(value: 'value2'),
          'column3': TrinaCell(value: 'value3'),
        },
      );

      expect(row.toJson(), {
        'column1': 'value1',
        'column2': 'value2',
        'column3': 'value3',
      });
    });

    test('When type is normal', () {
      final TrinaRow row = TrinaRow(
        cells: {
          'column1': TrinaCell(value: 123),
          'column2': TrinaCell(value: 3.12),
          'column3': TrinaCell(value: -123),
        },
      );

      expect(row.toJson(), {'column1': 123, 'column2': 3.12, 'column3': -123});
    });

    test('When type is group', () {
      final TrinaRow row = TrinaRow(
        cells: {
          'column1': TrinaCell(value: 'group value1'),
          'column2': TrinaCell(value: 'group value2'),
          'column3': TrinaCell(value: 'group value3'),
        },
        type: TrinaRowType.group(
          children: FilteredList(
            initialList: [
              TrinaRow(
                cells: {
                  'column1': TrinaCell(value: 'child1 value1'),
                  'column2': TrinaCell(value: 'child1 value2'),
                  'column3': TrinaCell(value: 'child1 value3'),
                },
              ),
              TrinaRow(
                cells: {
                  'column1': TrinaCell(value: 'child2 value1'),
                  'column2': TrinaCell(value: 'child2 value2'),
                  'column3': TrinaCell(value: 'child2 value3'),
                },
              ),
            ],
          ),
        ),
      );

      expect(row.toJson(), {
        'column1': 'group value1',
        'column2': 'group value2',
        'column3': 'group value3',
        'children': [
          {
            'column1': 'child1 value1',
            'column2': 'child1 value2',
            'column3': 'child1 value3',
          },
          {
            'column1': 'child2 value1',
            'column2': 'child2 value2',
            'column3': 'child2 value3',
          },
        ],
      });
    });

    test('When includeChildren is false'
        'then children should not be included.', () {
      final TrinaRow row = TrinaRow(
        cells: {
          'column1': TrinaCell(value: 'group value1'),
          'column2': TrinaCell(value: 'group value2'),
          'column3': TrinaCell(value: 'group value3'),
        },
        type: TrinaRowType.group(
          children: FilteredList(
            initialList: [
              TrinaRow(
                cells: {
                  'column1': TrinaCell(value: 'child1 value1'),
                  'column2': TrinaCell(value: 'child1 value2'),
                  'column3': TrinaCell(value: 'child1 value3'),
                },
              ),
              TrinaRow(
                cells: {
                  'column1': TrinaCell(value: 'child2 value1'),
                  'column2': TrinaCell(value: 'child2 value2'),
                  'column3': TrinaCell(value: 'child2 value3'),
                },
              ),
            ],
          ),
        ),
      );

      expect(row.toJson(includeChildren: false), {
        'column1': 'group value1',
        'column2': 'group value2',
        'column3': 'group value3',
      });
    });

    test('When includeChildren is false'
        'then children should not be included.', () {
      final TrinaRow row = TrinaRow(
        cells: {
          'column1': TrinaCell(value: 'group value1'),
          'column2': TrinaCell(value: 'group value2'),
          'column3': TrinaCell(value: 'group value3'),
        },
        type: TrinaRowType.group(
          children: FilteredList(
            initialList: [
              TrinaRow(
                cells: {
                  'column1': TrinaCell(value: 'child1 value1'),
                  'column2': TrinaCell(value: 'child1 value2'),
                  'column3': TrinaCell(value: 'child1 value3'),
                },
                type: TrinaRowType.group(
                  children: FilteredList(
                    initialList: [
                      TrinaRow(
                        cells: {
                          'column1': TrinaCell(value: 'child1-1 value1'),
                          'column2': TrinaCell(value: 'child1-1 value2'),
                          'column3': TrinaCell(value: 'child1-1 value3'),
                        },
                      ),
                      TrinaRow(
                        cells: {
                          'column1': TrinaCell(value: 'child1-2 value1'),
                          'column2': TrinaCell(value: 'child1-2 value2'),
                          'column3': TrinaCell(value: 'child1-2 value3'),
                        },
                      ),
                    ],
                  ),
                ),
              ),
              TrinaRow(
                cells: {
                  'column1': TrinaCell(value: 'child2 value1'),
                  'column2': TrinaCell(value: 'child2 value2'),
                  'column3': TrinaCell(value: 'child2 value3'),
                },
              ),
            ],
          ),
        ),
      );

      expect(row.toJson(), {
        'column1': 'group value1',
        'column2': 'group value2',
        'column3': 'group value3',
        'children': [
          {
            'column1': 'child1 value1',
            'column2': 'child1 value2',
            'column3': 'child1 value3',
            'children': [
              {
                'column1': 'child1-1 value1',
                'column2': 'child1-1 value2',
                'column3': 'child1-1 value3',
              },
              {
                'column1': 'child1-2 value1',
                'column2': 'child1-2 value2',
                'column3': 'child1-2 value3',
              },
            ],
          },
          {
            'column1': 'child2 value1',
            'column2': 'child2 value2',
            'column3': 'child2 value3',
          },
        ],
      });
    });

    test('When childrenField is items'
        'then children should be as expected.', () {
      final TrinaRow row = TrinaRow(
        cells: {
          'column1': TrinaCell(value: 'group value1'),
          'column2': TrinaCell(value: 'group value2'),
          'column3': TrinaCell(value: 'group value3'),
        },
        type: TrinaRowType.group(
          children: FilteredList(
            initialList: [
              TrinaRow(
                cells: {
                  'column1': TrinaCell(value: 'child1 value1'),
                  'column2': TrinaCell(value: 'child1 value2'),
                  'column3': TrinaCell(value: 'child1 value3'),
                },
                type: TrinaRowType.group(
                  children: FilteredList(
                    initialList: [
                      TrinaRow(
                        cells: {
                          'column1': TrinaCell(value: 'child1-1 value1'),
                          'column2': TrinaCell(value: 'child1-1 value2'),
                          'column3': TrinaCell(value: 'child1-1 value3'),
                        },
                      ),
                      TrinaRow(
                        cells: {
                          'column1': TrinaCell(value: 'child1-2 value1'),
                          'column2': TrinaCell(value: 'child1-2 value2'),
                          'column3': TrinaCell(value: 'child1-2 value3'),
                        },
                      ),
                    ],
                  ),
                ),
              ),
              TrinaRow(
                cells: {
                  'column1': TrinaCell(value: 'child2 value1'),
                  'column2': TrinaCell(value: 'child2 value2'),
                  'column3': TrinaCell(value: 'child2 value3'),
                },
              ),
            ],
          ),
        ),
      );

      expect(row.toJson(childrenField: 'items'), {
        'column1': 'group value1',
        'column2': 'group value2',
        'column3': 'group value3',
        'items': [
          {
            'column1': 'child1 value1',
            'column2': 'child1 value2',
            'column3': 'child1 value3',
            'items': [
              {
                'column1': 'child1-1 value1',
                'column2': 'child1-1 value2',
                'column3': 'child1-1 value3',
              },
              {
                'column1': 'child1-2 value1',
                'column2': 'child1-2 value2',
                'column3': 'child1-2 value3',
              },
            ],
          },
          {
            'column1': 'child2 value1',
            'column2': 'child2 value2',
            'column3': 'child2 value3',
          },
        ],
      });
    });
  });
}
