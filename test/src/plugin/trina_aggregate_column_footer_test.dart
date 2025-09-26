import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:mockito/mockito.dart';
import 'package:trina_grid/trina_grid.dart';
import 'package:rxdart/rxdart.dart';

import '../../helper/trina_widget_test_helper.dart';
import '../../mock/shared_mocks.mocks.dart';

void main() {
  late MockTrinaGridStateManager stateManager;

  late PublishSubject<TrinaNotifierEvent> subject;

  buildWidget({
    required TrinaColumn column,
    required FilteredList<TrinaRow> rows,
    required TrinaAggregateColumnType type,
    TrinaAggregateColumnGroupedRowType groupedRowType =
        TrinaAggregateColumnGroupedRowType.all,
    TrinaAggregateColumnIterateRowType iterateRowType =
        TrinaAggregateColumnIterateRowType.filteredAndPaginated,
    TrinaAggregateFilter? filter,
    NumberFormat? format,
    List<InlineSpan> Function(String)? titleSpanBuilder,
    AlignmentGeometry? alignment,
    EdgeInsets? padding,
    bool enabledRowGroups = false,
  }) {
    return TrinaWidgetTestHelper('TrinaAggregateColumnFooter : ', (
      tester,
    ) async {
      stateManager = MockTrinaGridStateManager();

      subject = PublishSubject<TrinaNotifierEvent>();

      when(stateManager.streamNotifier).thenAnswer((_) => subject);

      when(
        stateManager.configuration,
      ).thenReturn(const TrinaGridConfiguration());

      when(stateManager.refRows).thenReturn(rows);

      when(stateManager.enabledRowGroups).thenReturn(enabledRowGroups);

      when(
        stateManager.iterateAllMainRowGroup,
      ).thenReturn(rows.originalList.where((r) => r.isMain));

      when(
        stateManager.iterateFilteredMainRowGroup,
      ).thenReturn(rows.filterOrOriginalList.where((r) => r.isMain));

      when(
        stateManager.iterateMainRowGroup,
      ).thenReturn(rows.where((r) => r.isMain));

      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: TrinaAggregateColumnFooter(
              rendererContext: TrinaColumnFooterRendererContext(
                stateManager: stateManager,
                column: column,
              ),
              type: type,
              groupedRowType: groupedRowType,
              iterateRowType: iterateRowType,
              filter: filter,
              numberFormat: format ?? NumberFormat('#,###'),
              titleSpanBuilder: titleSpanBuilder,
              alignment: alignment,
              padding: padding,
            ),
          ),
        ),
      );
    });
  }

  group('number column.', () {
    final columns = [
      TrinaColumn(
        title: 'column',
        field: 'column',
        type: TrinaColumnType.number(),
      ),
    ];

    buildWidget(
      column: columns.first,
      rows: FilteredList<TrinaRow>(initialList: []),
      type: TrinaAggregateColumnType.sum,
    ).test(
      'When sum is set, the value should be displayed in the specified format.',
      (tester) async {
        final found = find.text('0');

        expect(found, findsOneWidget);
      },
    );

    buildWidget(
      column: columns.first,
      rows: FilteredList<TrinaRow>(initialList: []),
      type: TrinaAggregateColumnType.average,
    ).test(
      'When average is set, the value should be displayed in the specified format.',
      (tester) async {
        final found = find.text('0');

        expect(found, findsOneWidget);
      },
    );

    buildWidget(
      column: columns.first,
      rows: FilteredList<TrinaRow>(initialList: []),
      type: TrinaAggregateColumnType.min,
    ).test(
      'When min is set, the value should be displayed in the specified format.',
      (tester) async {
        final found = find.text('');

        expect(found, findsOneWidget);
      },
    );

    buildWidget(
      column: columns.first,
      rows: FilteredList<TrinaRow>(initialList: []),
      type: TrinaAggregateColumnType.max,
    ).test(
      'When max is set, the value should be displayed in the specified format.',
      (tester) async {
        final found = find.text('');

        expect(found, findsOneWidget);
      },
    );

    buildWidget(
      column: columns.first,
      rows: FilteredList<TrinaRow>(initialList: []),
      type: TrinaAggregateColumnType.count,
    ).test(
      'When count is set, the value should be displayed in the specified format.',
      (tester) async {
        final found = find.text('0');

        expect(found, findsOneWidget);
      },
    );

    buildWidget(
      column: columns.first,
      rows: FilteredList<TrinaRow>(
        initialList: [
          TrinaRow(cells: {'column': TrinaCell(value: 1000)}),
          TrinaRow(cells: {'column': TrinaCell(value: 2000)}),
          TrinaRow(cells: {'column': TrinaCell(value: 3000)}),
        ],
      ),
      type: TrinaAggregateColumnType.sum,
    ).test(
      'When sum is set, the value should be displayed in the specified format.',
      (tester) async {
        final found = find.text('6,000');

        expect(found, findsOneWidget);
      },
    );

    buildWidget(
      column: columns.first,
      rows: FilteredList<TrinaRow>(
        initialList: [
          TrinaRow(cells: {'column': TrinaCell(value: 1000)}),
          TrinaRow(cells: {'column': TrinaCell(value: 2000)}),
          TrinaRow(cells: {'column': TrinaCell(value: 3000)}),
        ],
      ),
      type: TrinaAggregateColumnType.average,
    ).test(
      'When average is set, the value should be displayed in the specified format.',
      (tester) async {
        final found = find.text('2,000');

        expect(found, findsOneWidget);
      },
    );

    buildWidget(
      column: columns.first,
      rows: FilteredList<TrinaRow>(
        initialList: [
          TrinaRow(cells: {'column': TrinaCell(value: 1000)}),
          TrinaRow(cells: {'column': TrinaCell(value: 2000)}),
          TrinaRow(cells: {'column': TrinaCell(value: 3000)}),
        ],
      ),
      type: TrinaAggregateColumnType.min,
    ).test(
      'When min is set, the value should be displayed in the specified format.',
      (tester) async {
        final found = find.text('1,000');

        expect(found, findsOneWidget);
      },
    );

    buildWidget(
      column: columns.first,
      rows: FilteredList<TrinaRow>(
        initialList: [
          TrinaRow(cells: {'column': TrinaCell(value: 1000)}),
          TrinaRow(cells: {'column': TrinaCell(value: 2000)}),
          TrinaRow(cells: {'column': TrinaCell(value: 3000)}),
        ],
      ),
      type: TrinaAggregateColumnType.max,
    ).test(
      'When max is set, the value should be displayed in the specified format.',
      (tester) async {
        final found = find.text('3,000');

        expect(found, findsOneWidget);
      },
    );

    buildWidget(
      column: columns.first,
      rows: FilteredList<TrinaRow>(
        initialList: [
          TrinaRow(cells: {'column': TrinaCell(value: 1000)}),
          TrinaRow(cells: {'column': TrinaCell(value: 2000)}),
          TrinaRow(cells: {'column': TrinaCell(value: 3000)}),
        ],
      ),
      type: TrinaAggregateColumnType.count,
    ).test(
      'When count is set, the value should be displayed in the specified format.',
      (tester) async {
        final found = find.text('3');

        expect(found, findsOneWidget);
      },
    );

    buildWidget(
      column: columns.first,
      rows: FilteredList<TrinaRow>(
        initialList: [
          TrinaRow(cells: {'column': TrinaCell(value: 1000)}),
          TrinaRow(cells: {'column': TrinaCell(value: 2000)}),
          TrinaRow(cells: {'column': TrinaCell(value: 3000)}),
        ],
      ),
      type: TrinaAggregateColumnType.count,
      filter: (cell) => cell.value > 1000,
    ).test(
      'When filter is set, the count value should be displayed based on the filter condition.',
      (tester) async {
        final found = find.text('2');

        expect(found, findsOneWidget);
      },
    );

    buildWidget(
      column: columns.first,
      rows: FilteredList<TrinaRow>(
        initialList: [
          TrinaRow(cells: {'column': TrinaCell(value: 1000)}),
          TrinaRow(cells: {'column': TrinaCell(value: 2000)}),
          TrinaRow(cells: {'column': TrinaCell(value: 3000)}),
        ],
      ),
      type: TrinaAggregateColumnType.count,
      format: NumberFormat('Total : #,###'),
    ).test(
      'When count is set, the value should be displayed in the specified format.',
      (tester) async {
        final found = find.text('Total : 3');

        expect(found, findsOneWidget);
      },
    );

    buildWidget(
      column: columns.first,
      rows: FilteredList<TrinaRow>(
        initialList: [
          TrinaRow(cells: {'column': TrinaCell(value: 1000)}),
          TrinaRow(cells: {'column': TrinaCell(value: 2000)}),
          TrinaRow(cells: {'column': TrinaCell(value: 3000)}),
        ],
      ),
      type: TrinaAggregateColumnType.sum,
      titleSpanBuilder: (text) {
        return [
          const WidgetSpan(child: Text('Left ')),
          WidgetSpan(child: Text('Value : $text')),
          const WidgetSpan(child: Text(' Right')),
        ];
      },
    ).test(
      'When titleSpanBuilder is set, the sum value should be displayed in the specified widget.',
      (tester) async {
        expect(find.text('Left '), findsOneWidget);
        expect(find.text('Value : 6,000'), findsOneWidget);
        expect(find.text(' Right'), findsOneWidget);
      },
    );

    buildWidget(
      column: columns.first,
      rows: FilteredList<TrinaRow>(
        initialList: [
          TrinaRow(cells: {'column': TrinaCell(value: 1000)}),
          TrinaRow(cells: {'column': TrinaCell(value: 2000)}),
          TrinaRow(cells: {'column': TrinaCell(value: 3000)}),
        ],
      )..setFilter((element) => element.cells['column']!.value > 1000),
      type: TrinaAggregateColumnType.sum,
    ).test(
      'When filter is applied, only the filtered results should be aggregated.',
      (tester) async {
        expect(find.text('5,000'), findsOneWidget);
      },
    );

    buildWidget(
      column: columns.first,
      rows: FilteredList<TrinaRow>(
        initialList: [
          TrinaRow(cells: {'column': TrinaCell(value: 1000)}),
          TrinaRow(cells: {'column': TrinaCell(value: 2000)}),
          TrinaRow(cells: {'column': TrinaCell(value: 3000)}),
        ],
      )..setFilterRange(FilteredListRange(0, 2)),
      type: TrinaAggregateColumnType.sum,
    ).test(
      'When pagination is applied, only the paginated results should be aggregated.',
      (tester) async {
        expect(find.text('3,000'), findsOneWidget);
      },
    );

    buildWidget(
      column: columns.first,
      rows: FilteredList<TrinaRow>(
        initialList: [
          TrinaRow(cells: {'column': TrinaCell(value: 1000)}),
          TrinaRow(cells: {'column': TrinaCell(value: 2000)}),
          TrinaRow(cells: {'column': TrinaCell(value: 3000)}),
        ],
      )..setFilterRange(FilteredListRange(0, 2)),
      type: TrinaAggregateColumnType.sum,
      iterateRowType: TrinaAggregateColumnIterateRowType.all,
    ).test(
      'When iterateRowType is all, even if pagination is applied, all rows should be included in the aggregation.',
      (tester) async {
        expect(find.text('6,000'), findsOneWidget);
      },
    );

    buildWidget(
      column: columns.first,
      rows:
          FilteredList<TrinaRow>(
              initialList: [
                TrinaRow(cells: {'column': TrinaCell(value: 1000)}),
                TrinaRow(cells: {'column': TrinaCell(value: 2000)}),
                TrinaRow(cells: {'column': TrinaCell(value: 3000)}),
              ],
            )
            ..setFilter((element) => element.cells['column']!.value > 1000)
            ..setFilterRange(FilteredListRange(0, 2)),
      type: TrinaAggregateColumnType.sum,
      iterateRowType: TrinaAggregateColumnIterateRowType.filtered,
    ).test(
      'When iterateRowType is filtered, pagination should be ignored and only the filtered results should be included in the aggregation.',
      (tester) async {
        expect(find.text('5,000'), findsOneWidget);
      },
    );

    buildWidget(
      column: columns.first,
      rows: FilteredList<TrinaRow>(
        initialList: [
          TrinaRow(cells: {'column': TrinaCell(value: 1000)}),
          TrinaRow(cells: {'column': TrinaCell(value: 2000)}),
          TrinaRow(cells: {'column': TrinaCell(value: 3000)}),
        ],
      )..setFilter((element) => element.cells['column']!.value > 1000),
      type: TrinaAggregateColumnType.sum,
      iterateRowType: TrinaAggregateColumnIterateRowType.all,
    ).test(
      'When iterateRowType is all, even if the filter is applied, all rows should be included in the aggregation.',
      (tester) async {
        expect(find.text('6,000'), findsOneWidget);
      },
    );
  });

  group('RowGroups', () {
    final columns = [
      TrinaColumn(
        title: 'column',
        field: 'column',
        type: TrinaColumnType.number(),
      ),
    ];

    buildWidget(
      column: columns.first,
      rows: FilteredList<TrinaRow>(
        initialList: [
          TrinaRow(
            cells: {'column': TrinaCell(value: 1000)},
            type: TrinaRowType.group(
              children: FilteredList(
                initialList: [
                  TrinaRow(cells: {'column': TrinaCell(value: 2000)}),
                  TrinaRow(cells: {'column': TrinaCell(value: 2000)}),
                ],
              ),
            ),
          ),
          TrinaRow(cells: {'column': TrinaCell(value: 2000)}),
          TrinaRow(cells: {'column': TrinaCell(value: 3000)}),
        ],
      ),
      type: TrinaAggregateColumnType.sum,
      groupedRowType: TrinaAggregateColumnGroupedRowType.all,
      enabledRowGroups: true,
      titleSpanBuilder: (text) {
        return [WidgetSpan(child: Text('Value : $text'))];
      },
    ).test('When GroupedRowType is all, '
        'Value : 10,000 should be displayed.', (tester) async {
      expect(find.text('Value : 10,000'), findsOneWidget);
    });

    buildWidget(
      column: columns.first,
      rows: FilteredList<TrinaRow>(
        initialList: [
          TrinaRow(
            cells: {'column': TrinaCell(value: 1000)},
            type: TrinaRowType.group(
              children: FilteredList(
                initialList: [
                  TrinaRow(cells: {'column': TrinaCell(value: 2000)}),
                  TrinaRow(cells: {'column': TrinaCell(value: 2000)}),
                ],
              ),
            ),
          ),
          TrinaRow(cells: {'column': TrinaCell(value: 2000)}),
          TrinaRow(cells: {'column': TrinaCell(value: 3000)}),
        ],
      ),
      type: TrinaAggregateColumnType.sum,
      groupedRowType: TrinaAggregateColumnGroupedRowType.expandedAll,
      enabledRowGroups: true,
      titleSpanBuilder: (text) {
        return [WidgetSpan(child: Text('Value : $text'))];
      },
    ).test('When GroupedRowType is expandedAll and the group row is collapsed, '
        'Value : 6,000 should be displayed.', (tester) async {
      expect(find.text('Value : 6,000'), findsOneWidget);
    });

    buildWidget(
      column: columns.first,
      rows: FilteredList<TrinaRow>(
        initialList: [
          TrinaRow(
            cells: {'column': TrinaCell(value: 1000)},
            type: TrinaRowType.group(
              children: FilteredList(
                initialList: [
                  TrinaRow(cells: {'column': TrinaCell(value: 2000)}),
                  TrinaRow(cells: {'column': TrinaCell(value: 2000)}),
                ],
              ),
              expanded: true,
            ),
          ),
          TrinaRow(cells: {'column': TrinaCell(value: 2000)}),
          TrinaRow(cells: {'column': TrinaCell(value: 3000)}),
        ],
      ),
      type: TrinaAggregateColumnType.sum,
      groupedRowType: TrinaAggregateColumnGroupedRowType.expandedAll,
      enabledRowGroups: true,
      titleSpanBuilder: (text) {
        return [WidgetSpan(child: Text('Value : $text'))];
      },
    ).test('When GroupedRowType is expandedAll and the group row is expanded, '
        'Value : 10,000 should be displayed.', (tester) async {
      expect(find.text('Value : 10,000'), findsOneWidget);
    });

    buildWidget(
      column: columns.first,
      rows: FilteredList<TrinaRow>(
        initialList: [
          TrinaRow(
            cells: {'column': TrinaCell(value: 1000)},
            type: TrinaRowType.group(
              children: FilteredList(
                initialList: [
                  TrinaRow(cells: {'column': TrinaCell(value: 2000)}),
                  TrinaRow(cells: {'column': TrinaCell(value: 2000)}),
                ],
              ),
              expanded: true,
            ),
          ),
          TrinaRow(cells: {'column': TrinaCell(value: 2000)}),
          TrinaRow(cells: {'column': TrinaCell(value: 3000)}),
        ],
      ),
      type: TrinaAggregateColumnType.sum,
      groupedRowType: TrinaAggregateColumnGroupedRowType.rows,
      enabledRowGroups: true,
      titleSpanBuilder: (text) {
        return [WidgetSpan(child: Text('Value : $text'))];
      },
    ).test('When GroupedRowType is rows, '
        'Value : 9,000 should be displayed.', (tester) async {
      expect(find.text('Value : 9,000'), findsOneWidget);
    });

    buildWidget(
      column: columns.first,
      rows: FilteredList<TrinaRow>(
        initialList: [
          TrinaRow(
            cells: {'column': TrinaCell(value: 1000)},
            type: TrinaRowType.group(
              children: FilteredList(
                initialList: [
                  TrinaRow(cells: {'column': TrinaCell(value: 2000)}),
                  TrinaRow(cells: {'column': TrinaCell(value: 2000)}),
                ],
              ),
              expanded: false,
            ),
          ),
          TrinaRow(cells: {'column': TrinaCell(value: 2000)}),
          TrinaRow(cells: {'column': TrinaCell(value: 3000)}),
        ],
      ),
      type: TrinaAggregateColumnType.sum,
      groupedRowType: TrinaAggregateColumnGroupedRowType.expandedRows,
      enabledRowGroups: true,
      titleSpanBuilder: (text) {
        return [WidgetSpan(child: Text('Value : $text'))];
      },
    ).test(
      'When GroupedRowType is expandedRows and the group row is collapsed, '
      'Value : 5,000 should be displayed.',
      (tester) async {
        expect(find.text('Value : 5,000'), findsOneWidget);
      },
    );

    buildWidget(
      column: columns.first,
      rows: FilteredList<TrinaRow>(
        initialList: [
          TrinaRow(
            cells: {'column': TrinaCell(value: 1000)},
            type: TrinaRowType.group(
              children: FilteredList(
                initialList: [
                  TrinaRow(cells: {'column': TrinaCell(value: 2000)}),
                  TrinaRow(cells: {'column': TrinaCell(value: 2000)}),
                ],
              ),
              expanded: true,
            ),
          ),
          TrinaRow(cells: {'column': TrinaCell(value: 2000)}),
          TrinaRow(cells: {'column': TrinaCell(value: 3000)}),
        ],
      ),
      type: TrinaAggregateColumnType.sum,
      groupedRowType: TrinaAggregateColumnGroupedRowType.expandedRows,
      enabledRowGroups: true,
      titleSpanBuilder: (text) {
        return [WidgetSpan(child: Text('Value : $text'))];
      },
    ).test('When GroupedRowType is expandedRows and the group row is expanded, '
        'Value : 9,000 should be displayed.', (tester) async {
      expect(find.text('Value : 9,000'), findsOneWidget);
    });

    buildWidget(
      column: columns.first,
      rows: FilteredList<TrinaRow>(
        initialList: [
          TrinaRow(
            cells: {'column': TrinaCell(value: 1000)},
            type: TrinaRowType.group(
              children: FilteredList(
                initialList: [
                  TrinaRow(cells: {'column': TrinaCell(value: 2000)}),
                  TrinaRow(cells: {'column': TrinaCell(value: 2000)}),
                ],
              ),
              expanded: true,
            ),
          ),
          TrinaRow(cells: {'column': TrinaCell(value: 2000)}),
          TrinaRow(cells: {'column': TrinaCell(value: 3000)}),
        ],
      )..setFilter((element) => element.cells['column']!.value > 1000),
      type: TrinaAggregateColumnType.sum,
      groupedRowType: TrinaAggregateColumnGroupedRowType.all,
      enabledRowGroups: true,
    ).test(
      'When the filter is applied, only the filtered results should be included in the aggregation.',
      (tester) async {
        expect(find.text('5,000'), findsOneWidget);
      },
    );

    buildWidget(
      column: columns.first,
      rows: FilteredList<TrinaRow>(
        initialList: [
          TrinaRow(
            cells: {'column': TrinaCell(value: 1000)},
            type: TrinaRowType.group(
              children: FilteredList(
                initialList: [
                  TrinaRow(cells: {'column': TrinaCell(value: 2000)}),
                  TrinaRow(cells: {'column': TrinaCell(value: 2000)}),
                ],
              ),
              expanded: true,
            ),
          ),
          TrinaRow(cells: {'column': TrinaCell(value: 2000)}),
          TrinaRow(cells: {'column': TrinaCell(value: 3000)}),
        ],
      )..setFilterRange(FilteredListRange(0, 2)),
      type: TrinaAggregateColumnType.sum,
      groupedRowType: TrinaAggregateColumnGroupedRowType.all,
      enabledRowGroups: true,
    ).test(
      'When pagination is set, only the paginated results should be included in the aggregation.',
      (tester) async {
        expect(find.text('7,000'), findsOneWidget);
      },
    );

    buildWidget(
      column: columns.first,
      rows: FilteredList<TrinaRow>(
        initialList: [
          TrinaRow(
            cells: {'column': TrinaCell(value: 1000)},
            type: TrinaRowType.group(
              children: FilteredList(
                initialList: [
                  TrinaRow(cells: {'column': TrinaCell(value: 2000)}),
                  TrinaRow(cells: {'column': TrinaCell(value: 2000)}),
                ],
              ),
              expanded: true,
            ),
          ),
          TrinaRow(cells: {'column': TrinaCell(value: 2000)}),
          TrinaRow(cells: {'column': TrinaCell(value: 3000)}),
        ],
      )..setFilter((element) => element.cells['column']!.value > 1000),
      type: TrinaAggregateColumnType.sum,
      iterateRowType: TrinaAggregateColumnIterateRowType.all,
      groupedRowType: TrinaAggregateColumnGroupedRowType.all,
      enabledRowGroups: true,
    ).test(
      'When iterateRowType is all, even if the filter is applied, all rows should be included in the aggregation.',
      (tester) async {
        expect(find.text('10,000'), findsOneWidget);
      },
    );

    buildWidget(
      column: columns.first,
      rows:
          FilteredList<TrinaRow>(
              initialList: [
                TrinaRow(
                  cells: {'column': TrinaCell(value: 1000)},
                  type: TrinaRowType.group(
                    children: FilteredList(
                      initialList: [
                        TrinaRow(cells: {'column': TrinaCell(value: 2000)}),
                        TrinaRow(cells: {'column': TrinaCell(value: 2000)}),
                      ],
                    ),
                    expanded: true,
                  ),
                ),
                TrinaRow(cells: {'column': TrinaCell(value: 2000)}),
                TrinaRow(cells: {'column': TrinaCell(value: 3000)}),
              ],
            )
            ..setFilter((element) => element.cells['column']!.value > 1000)
            ..setFilterRange(FilteredListRange(0, 2)),
      type: TrinaAggregateColumnType.sum,
      iterateRowType: TrinaAggregateColumnIterateRowType.filtered,
      groupedRowType: TrinaAggregateColumnGroupedRowType.all,
      enabledRowGroups: true,
    ).test(
      'When iterateRowType is filtered, pagination should be ignored and only the filtered results should be included in the aggregation.',
      (tester) async {
        expect(find.text('5,000'), findsOneWidget);
      },
    );
  });
}
