import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:trina_grid/trina_grid.dart';

import '../../mock/mock_methods.dart';

void main() {
  final mock = MockMethods();

  group('applyFilter', () {
    test('When the rows is empty, the filter should not be called.', () {
      final FilteredList<TrinaRow> rows = FilteredList();

      final mockFilter = mock.oneParamReturnBool<TrinaRow>;

      expect(rows.originalList.length, 0);

      TrinaRowGroupHelper.applyFilter(rows: rows, filter: mockFilter);

      verifyNever(mockFilter(any));
    });

    test('When the rows is not empty, the filter should be called.', () {
      final FilteredList<TrinaRow> rows = FilteredList(
        initialList: [TrinaRow(cells: {})],
      );

      final mockFilter = mock.oneParamReturnBool<TrinaRow>;

      expect(rows.originalList.length, 1);

      when(mockFilter(any)).thenReturn(true);

      TrinaRowGroupHelper.applyFilter(rows: rows, filter: mockFilter);

      verify(mockFilter(any)).called(1);
    });

    test('When the filter is set, calling null should remove the filter.', () {
      final FilteredList<TrinaRow> rows = FilteredList(
        initialList: [
          TrinaRow(cells: {'column1': TrinaCell(value: 'test1')}),
          TrinaRow(cells: {'column1': TrinaCell(value: 'test2')}),
          TrinaRow(cells: {'column1': TrinaCell(value: 'test3')}),
        ],
      );

      filter(TrinaRow row) => row.cells['column1']!.value == 'test1';

      expect(rows.length, 3);

      TrinaRowGroupHelper.applyFilter(rows: rows, filter: filter);

      expect(rows.length, 1);

      expect(rows.hasFilter, true);

      TrinaRowGroupHelper.applyFilter(rows: rows, filter: null);

      expect(rows.length, 3);

      expect(rows.hasFilter, false);
    });

    test('When the group row is included, the filter should be included.', () {
      final FilteredList<TrinaRow> rows = FilteredList(
        initialList: [
          TrinaRow(cells: {'column1': TrinaCell(value: 'test1')}),
          TrinaRow(cells: {'column1': TrinaCell(value: 'test2')}),
          TrinaRow(
            cells: {'column1': TrinaCell(value: 'test3')},
            type: TrinaRowType.group(
              children: FilteredList(
                initialList: [
                  TrinaRow(cells: {'column1': TrinaCell(value: 'group1')}),
                  TrinaRow(cells: {'column1': TrinaCell(value: 'group2')}),
                ],
              ),
            ),
          ),
        ],
      );

      final mockFilter = mock.oneParamReturnBool<TrinaRow>;

      when(mockFilter(any)).thenReturn(true);

      TrinaRowGroupHelper.applyFilter(rows: rows, filter: mockFilter);

      verify(mockFilter(any)).called(greaterThanOrEqualTo(2));
    });

    test(
      'When the child rows of the group are filtered and the filter is removed, '
      'the child rows should be included in the list.',
      () {
        final FilteredList<TrinaRow> rows = FilteredList(
          initialList: [
            TrinaRow(cells: {'column1': TrinaCell(value: 'test1')}),
            TrinaRow(cells: {'column1': TrinaCell(value: 'test2')}),
            TrinaRow(
              cells: {'column1': TrinaCell(value: 'test3')},
              type: TrinaRowType.group(
                children: FilteredList(
                  initialList: [
                    TrinaRow(cells: {'column1': TrinaCell(value: 'group1')}),
                    TrinaRow(cells: {'column1': TrinaCell(value: 'group2')}),
                  ],
                ),
              ),
            ),
          ],
        );

        filter(TrinaRow row) =>
            !row.cells['column1']!.value.toString().startsWith('group');

        TrinaRowGroupHelper.applyFilter(rows: rows, filter: filter);

        expect(rows[2].type.group.children.length, 0);

        TrinaRowGroupHelper.applyFilter(rows: rows, filter: null);

        expect(rows[2].type.group.children.length, 2);
      },
    );
  });
}
