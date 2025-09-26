import 'package:flutter_test/flutter_test.dart';
import 'package:trina_grid/trina_grid.dart';

void main() {
  group('sum', () {
    test('When the column is not a number, 0 should be returned.', () {
      final column = TrinaColumn(
        title: 'column',
        field: 'column',
        type: TrinaColumnType.text(),
      );

      final rows = [
        TrinaRow(cells: {'column': TrinaCell(value: '10.001')}),
        TrinaRow(cells: {'column': TrinaCell(value: '10.001')}),
        TrinaRow(cells: {'column': TrinaCell(value: '10.001')}),
        TrinaRow(cells: {'column': TrinaCell(value: '10.001')}),
        TrinaRow(cells: {'column': TrinaCell(value: '10.001')}),
      ];

      expect(TrinaAggregateHelper.sum(rows: rows, column: column), 0);
    });

    test(
      'When sum is called without a condition, the total sum should be returned.',
      () {
        final column = TrinaColumn(
          title: 'column',
          field: 'column',
          type: TrinaColumnType.number(),
        );

        final rows = [
          TrinaRow(cells: {'column': TrinaCell(value: 10)}),
          TrinaRow(cells: {'column': TrinaCell(value: 20)}),
          TrinaRow(cells: {'column': TrinaCell(value: 30)}),
          TrinaRow(cells: {'column': TrinaCell(value: 40)}),
          TrinaRow(cells: {'column': TrinaCell(value: 50)}),
        ];

        expect(TrinaAggregateHelper.sum(rows: rows, column: column), 150);
      },
    );

    test(
      'When sum is called without a condition, the total sum should be returned.',
      () {
        final column = TrinaColumn(
          title: 'column',
          field: 'column',
          type: TrinaColumnType.number(),
        );

        final rows = [
          TrinaRow(cells: {'column': TrinaCell(value: -10)}),
          TrinaRow(cells: {'column': TrinaCell(value: -20)}),
          TrinaRow(cells: {'column': TrinaCell(value: -30)}),
          TrinaRow(cells: {'column': TrinaCell(value: -40)}),
          TrinaRow(cells: {'column': TrinaCell(value: -50)}),
        ];

        expect(TrinaAggregateHelper.sum(rows: rows, column: column), -150);
      },
    );

    test(
      'When sum is called without a condition, the total sum should be returned.',
      () {
        final column = TrinaColumn(
          title: 'column',
          field: 'column',
          type: TrinaColumnType.number(format: '#,###.###'),
        );

        final rows = [
          TrinaRow(cells: {'column': TrinaCell(value: 10.001)}),
          TrinaRow(cells: {'column': TrinaCell(value: 10.001)}),
          TrinaRow(cells: {'column': TrinaCell(value: 10.001)}),
          TrinaRow(cells: {'column': TrinaCell(value: 10.001)}),
          TrinaRow(cells: {'column': TrinaCell(value: 10.001)}),
        ];

        expect(TrinaAggregateHelper.sum(rows: rows, column: column), 50.005);
      },
    );

    test(
      'When a condition is present, the sum of the items that match the condition should be returned.',
      () {
        final column = TrinaColumn(
          title: 'column',
          field: 'column',
          type: TrinaColumnType.number(format: '#,###.###'),
        );

        final rows = [
          TrinaRow(cells: {'column': TrinaCell(value: 10.001)}),
          TrinaRow(cells: {'column': TrinaCell(value: 10.002)}),
          TrinaRow(cells: {'column': TrinaCell(value: 10.001)}),
          TrinaRow(cells: {'column': TrinaCell(value: 10.002)}),
          TrinaRow(cells: {'column': TrinaCell(value: 10.001)}),
        ];

        expect(
          TrinaAggregateHelper.sum(
            rows: rows,
            column: column,
            filter: (TrinaCell cell) => cell.value == 10.001,
          ),
          30.003,
        );
      },
    );

    test(
      'When a condition is present, if there are no matching items, 0 should be returned.',
      () {
        final column = TrinaColumn(
          title: 'column',
          field: 'column',
          type: TrinaColumnType.number(format: '#,###.###'),
        );

        final rows = [
          TrinaRow(cells: {'column': TrinaCell(value: 10.001)}),
          TrinaRow(cells: {'column': TrinaCell(value: 10.002)}),
          TrinaRow(cells: {'column': TrinaCell(value: 10.001)}),
          TrinaRow(cells: {'column': TrinaCell(value: 10.002)}),
          TrinaRow(cells: {'column': TrinaCell(value: 10.001)}),
        ];

        expect(
          TrinaAggregateHelper.sum(
            rows: rows,
            column: column,
            filter: (TrinaCell cell) => cell.value == 10.003,
          ),
          null,
        );
      },
    );
  });

  group('average', () {
    test(
      'When average is called without a condition, the total average should be returned.',
      () {
        final column = TrinaColumn(
          title: 'column',
          field: 'column',
          type: TrinaColumnType.number(format: '#,###'),
        );

        final rows = [
          TrinaRow(cells: {'column': TrinaCell(value: 10)}),
          TrinaRow(cells: {'column': TrinaCell(value: 20)}),
          TrinaRow(cells: {'column': TrinaCell(value: 30)}),
          TrinaRow(cells: {'column': TrinaCell(value: 40)}),
          TrinaRow(cells: {'column': TrinaCell(value: 50)}),
        ];

        expect(TrinaAggregateHelper.average(rows: rows, column: column), 30);
      },
    );

    test(
      'When average is called without a condition, the total average should be returned.',
      () {
        final column = TrinaColumn(
          title: 'column',
          field: 'column',
          type: TrinaColumnType.number(format: '#,###'),
        );

        final rows = [
          TrinaRow(cells: {'column': TrinaCell(value: -10)}),
          TrinaRow(cells: {'column': TrinaCell(value: -20)}),
          TrinaRow(cells: {'column': TrinaCell(value: -30)}),
          TrinaRow(cells: {'column': TrinaCell(value: -40)}),
          TrinaRow(cells: {'column': TrinaCell(value: -50)}),
        ];

        expect(TrinaAggregateHelper.average(rows: rows, column: column), -30);
      },
    );

    test(
      'When average is called without a condition, the total average should be returned.',
      () {
        final column = TrinaColumn(
          title: 'column',
          field: 'column',
          type: TrinaColumnType.number(format: '#,###.###'),
        );

        final rows = [
          TrinaRow(cells: {'column': TrinaCell(value: 10.001)}),
          TrinaRow(cells: {'column': TrinaCell(value: 10.002)}),
          TrinaRow(cells: {'column': TrinaCell(value: 10.003)}),
          TrinaRow(cells: {'column': TrinaCell(value: 10.004)}),
          TrinaRow(cells: {'column': TrinaCell(value: 10.005)}),
        ];

        expect(
          TrinaAggregateHelper.average(rows: rows, column: column),
          10.003,
        );
      },
    );
  });

  group('min', () {
    test(
      'When min is called without a condition, the minimum value should be returned.',
      () {
        final column = TrinaColumn(
          title: 'column',
          field: 'column',
          type: TrinaColumnType.number(format: '#,###'),
        );

        final rows = [
          TrinaRow(cells: {'column': TrinaCell(value: 101)}),
          TrinaRow(cells: {'column': TrinaCell(value: 102)}),
          TrinaRow(cells: {'column': TrinaCell(value: 103)}),
          TrinaRow(cells: {'column': TrinaCell(value: 104)}),
          TrinaRow(cells: {'column': TrinaCell(value: 105)}),
        ];

        expect(TrinaAggregateHelper.min(rows: rows, column: column), 101);
      },
    );

    test(
      'When min is called without a condition, the minimum value should be returned.',
      () {
        final column = TrinaColumn(
          title: 'column',
          field: 'column',
          type: TrinaColumnType.number(format: '#,###'),
        );

        final rows = [
          TrinaRow(cells: {'column': TrinaCell(value: -101)}),
          TrinaRow(cells: {'column': TrinaCell(value: -102)}),
          TrinaRow(cells: {'column': TrinaCell(value: -103)}),
          TrinaRow(cells: {'column': TrinaCell(value: -104)}),
          TrinaRow(cells: {'column': TrinaCell(value: -105)}),
        ];

        expect(TrinaAggregateHelper.min(rows: rows, column: column), -105);
      },
    );

    test(
      'When min is called without a condition, the minimum value should be returned.',
      () {
        final column = TrinaColumn(
          title: 'column',
          field: 'column',
          type: TrinaColumnType.number(format: '#,###.###'),
        );

        final rows = [
          TrinaRow(cells: {'column': TrinaCell(value: 10.001)}),
          TrinaRow(cells: {'column': TrinaCell(value: 10.002)}),
          TrinaRow(cells: {'column': TrinaCell(value: 10.003)}),
          TrinaRow(cells: {'column': TrinaCell(value: 10.004)}),
          TrinaRow(cells: {'column': TrinaCell(value: 10.005)}),
        ];

        expect(TrinaAggregateHelper.min(rows: rows, column: column), 10.001);
      },
    );

    test(
      'When a condition is present, the minimum value of the items that match the condition should be returned.',
      () {
        final column = TrinaColumn(
          title: 'column',
          field: 'column',
          type: TrinaColumnType.number(format: '#,###.###'),
        );

        final rows = [
          TrinaRow(cells: {'column': TrinaCell(value: 10.001)}),
          TrinaRow(cells: {'column': TrinaCell(value: 10.002)}),
          TrinaRow(cells: {'column': TrinaCell(value: 10.003)}),
          TrinaRow(cells: {'column': TrinaCell(value: 10.004)}),
          TrinaRow(cells: {'column': TrinaCell(value: 10.005)}),
        ];

        expect(
          TrinaAggregateHelper.min(
            rows: rows,
            column: column,
            filter: (TrinaCell cell) => cell.value >= 10.003,
          ),
          10.003,
        );
      },
    );

    test(
      'When a condition is present, if there are no matching items, null should be returned.',
      () {
        final column = TrinaColumn(
          title: 'column',
          field: 'column',
          type: TrinaColumnType.number(format: '#,###.###'),
        );

        final rows = [
          TrinaRow(cells: {'column': TrinaCell(value: 10.001)}),
          TrinaRow(cells: {'column': TrinaCell(value: 10.002)}),
          TrinaRow(cells: {'column': TrinaCell(value: 10.001)}),
          TrinaRow(cells: {'column': TrinaCell(value: 10.002)}),
          TrinaRow(cells: {'column': TrinaCell(value: 10.001)}),
        ];

        expect(
          TrinaAggregateHelper.min(
            rows: rows,
            column: column,
            filter: (TrinaCell cell) => cell.value == 10.003,
          ),
          null,
        );
      },
    );
  });

  group('max', () {
    test(
      'When a condition is present, the maximum value of the items that match the condition should be returned.',
      () {
        final column = TrinaColumn(
          title: 'column',
          field: 'column',
          type: TrinaColumnType.number(format: '#,###.###'),
        );

        final rows = [
          TrinaRow(cells: {'column': TrinaCell(value: 10.001)}),
          TrinaRow(cells: {'column': TrinaCell(value: 10.002)}),
          TrinaRow(cells: {'column': TrinaCell(value: 10.003)}),
          TrinaRow(cells: {'column': TrinaCell(value: 10.004)}),
          TrinaRow(cells: {'column': TrinaCell(value: 10.005)}),
        ];

        expect(
          TrinaAggregateHelper.max(
            rows: rows,
            column: column,
            filter: (TrinaCell cell) => cell.value >= 10.003,
          ),
          10.005,
        );
      },
    );

    test(
      'When a condition is present, if there are no matching items, null should be returned.',
      () {
        final column = TrinaColumn(
          title: 'column',
          field: 'column',
          type: TrinaColumnType.number(format: '#,###.###'),
        );

        final rows = [
          TrinaRow(cells: {'column': TrinaCell(value: 10.001)}),
          TrinaRow(cells: {'column': TrinaCell(value: 10.002)}),
          TrinaRow(cells: {'column': TrinaCell(value: 10.003)}),
          TrinaRow(cells: {'column': TrinaCell(value: 10.004)}),
          TrinaRow(cells: {'column': TrinaCell(value: 10.005)}),
        ];

        expect(
          TrinaAggregateHelper.max(
            rows: rows,
            column: column,
            filter: (TrinaCell cell) => cell.value >= 10.006,
          ),
          null,
        );
      },
    );
  });

  group('count', () {
    test(
      'When count is called without a condition, the total count should be returned.',
      () {
        final column = TrinaColumn(
          title: 'column',
          field: 'column',
          type: TrinaColumnType.number(format: '#,###.###'),
        );

        final rows = [
          TrinaRow(cells: {'column': TrinaCell(value: 10.001)}),
          TrinaRow(cells: {'column': TrinaCell(value: 10.002)}),
          TrinaRow(cells: {'column': TrinaCell(value: 10.003)}),
          TrinaRow(cells: {'column': TrinaCell(value: 10.004)}),
          TrinaRow(cells: {'column': TrinaCell(value: 10.005)}),
        ];

        expect(TrinaAggregateHelper.count(rows: rows, column: column), 5);
      },
    );

    test(
      'When a condition is present, the count of the items that match the condition should be returned.',
      () {
        final column = TrinaColumn(
          title: 'column',
          field: 'column',
          type: TrinaColumnType.number(format: '#,###.###'),
        );

        final rows = [
          TrinaRow(cells: {'column': TrinaCell(value: 10.001)}),
          TrinaRow(cells: {'column': TrinaCell(value: 10.002)}),
          TrinaRow(cells: {'column': TrinaCell(value: 10.003)}),
          TrinaRow(cells: {'column': TrinaCell(value: 10.004)}),
          TrinaRow(cells: {'column': TrinaCell(value: 10.005)}),
        ];

        expect(
          TrinaAggregateHelper.count(
            rows: rows,
            column: column,
            filter: (TrinaCell cell) => cell.value >= 10.003,
          ),
          3,
        );
      },
    );

    test(
      'When a condition is present, if there are no matching items, 0 should be returned.',
      () {
        final column = TrinaColumn(
          title: 'column',
          field: 'column',
          type: TrinaColumnType.number(format: '#,###.###'),
        );

        final rows = [
          TrinaRow(cells: {'column': TrinaCell(value: 10.001)}),
          TrinaRow(cells: {'column': TrinaCell(value: 10.002)}),
          TrinaRow(cells: {'column': TrinaCell(value: 10.003)}),
          TrinaRow(cells: {'column': TrinaCell(value: 10.004)}),
          TrinaRow(cells: {'column': TrinaCell(value: 10.005)}),
        ];

        expect(
          TrinaAggregateHelper.count(
            rows: rows,
            column: column,
            filter: (TrinaCell cell) => cell.value >= 10.006,
          ),
          0,
        );
      },
    );
  });
}
