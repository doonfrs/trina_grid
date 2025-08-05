import 'dart:math';

import 'package:flutter/material.dart';
import 'package:trina_grid/trina_grid.dart';

import '../../dummy_data/development.dart';
import '../../widget/trina_example_button.dart';
import '../../widget/trina_example_screen.dart';

class CustomPaginationScreen extends StatefulWidget {
  static const routeName = 'feature/custom-pagination';

  const CustomPaginationScreen({super.key});

  @override
  State<CustomPaginationScreen> createState() => _CustomPaginationScreenState();
}

class _CustomPaginationScreenState extends State<CustomPaginationScreen> {
  late final TrinaGridStateManager stateManager;

  final List<TrinaColumn> columns = [];

  final List<TrinaRow> rows = [];

  final List<TrinaRow> fakeFetchedRows = [];

  @override
  void initState() {
    super.initState();

    final dummyData = DummyData(10, 1000);

    columns.addAll(dummyData.columns);

    fakeFetchedRows.addAll(dummyData.rows);
  }

  Future<TrinaLazyPaginationResponse> fetch(
    TrinaLazyPaginationRequest request,
  ) async {
    List<TrinaRow> tempList = fakeFetchedRows;

    if (request.filterRows.isNotEmpty) {
      final filter = FilterHelper.convertRowsToFilter(
        request.filterRows,
        stateManager.refColumns,
      );

      tempList = fakeFetchedRows.where(filter!).toList();
    }

    if (request.sortColumn != null && !request.sortColumn!.sort.isNone) {
      tempList = [...tempList];

      tempList.sort((a, b) {
        final sortA = request.sortColumn!.sort.isAscending ? a : b;
        final sortB = request.sortColumn!.sort.isAscending ? b : a;

        return request.sortColumn!.type.compare(
          sortA.cells[request.sortColumn!.field]!.valueForSorting,
          sortB.cells[request.sortColumn!.field]!.valueForSorting,
        );
      });
    }

    final page = request.page;
    final pageSize = request.pageSize;
    final totalPage = (tempList.length / pageSize).ceil();
    final start = (page - 1) * pageSize;
    final end = start + pageSize;

    Iterable<TrinaRow> fetchedRows = tempList.getRange(
      max(0, start),
      min(tempList.length, end),
    );

    await Future.delayed(const Duration(milliseconds: 500));

    return Future.value(TrinaLazyPaginationResponse(
      totalPage: totalPage,
      rows: fetchedRows.toList(),
      totalRecords: tempList.length,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return TrinaExampleScreen(
      title: 'Custom Pagination UI',
      topTitle: 'Custom Pagination UI',
      topContents: const [
        Text('This screen demonstrates how to customize the pagination UI.'),
        Text(
            'You can enable\\disable through `TrinaLazyPagination.showLoading` and customize the loading widget through `TrinaLazyPagination.customLoadingWidget`.'),
      ],
      topButtons: [
        TrinaExampleButton(
          url:
              'https://github.com/doonfrs/trina_grid/blob/master/demo/lib/screen/feature/custom_pagination_screen.dart',
        ),
      ],
      body: TrinaGrid(
        columns: columns,
        rows: rows,
        onLoaded: (TrinaGridOnLoadedEvent event) {
          stateManager = event.stateManager;
          stateManager.setShowColumnFilter(true);
        },
        onChanged: (TrinaGridOnChangedEvent event) {
          print(event);
        },
        configuration: const TrinaGridConfiguration(),
        createFooter: (stateManager) {
          return TrinaLazyPagination(
            pageSizes: [10, 20, 50, 100],
            showPageSizeSelector: true,
            initialPage: 1,
            initialPageSize: 10,
            initialFetch: true,
            fetchWithSorting: true,
            fetchWithFiltering: true,
            pageSizeToMove: null,
            fetch: fetch,
            stateManager: stateManager,
            // Customizing the pagination UI
            builder: (context, paginationState) {
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: Colors.blueGrey[50],
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Page size selector
                    Row(
                      children: [
                        const Text('Rows per page:'),
                        const SizedBox(width: 8),
                        DropdownButton<int>(
                          value: paginationState.pageSize,
                          items: [10, 20, 50, 100].map((size) {
                            return DropdownMenuItem(
                              value: size,
                              child: Text('$size'),
                            );
                          }).toList(),
                          onChanged: (newSize) {
                            if (newSize != null) {
                              paginationState.setPageSize(newSize);
                            }
                          },
                        ),
                      ],
                    ),
                    // Page navigation controls
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.first_page),
                            onPressed: paginationState.page > 1
                                ? () => paginationState.setPage(1)
                                : null,
                          ),
                          IconButton(
                            icon: const Icon(Icons.chevron_left),
                            onPressed: paginationState.page > 1
                                ? () => paginationState
                                    .setPage(paginationState.page - 1)
                                : null,
                          ),
                          Text(
                              'Page ${paginationState.page} of ${paginationState.totalPage}'),
                          IconButton(
                            icon: const Icon(Icons.chevron_right),
                            onPressed:
                                paginationState.page < paginationState.totalPage
                                    ? () => paginationState
                                        .setPage(paginationState.page + 1)
                                    : null,
                          ),
                          IconButton(
                            icon: const Icon(Icons.last_page),
                            onPressed:
                                paginationState.page < paginationState.totalPage
                                    ? () => paginationState
                                        .setPage(paginationState.totalPage)
                                    : null,
                          ),
                        ],
                      ),
                    ),
                    // Total records display
                    Text('Total records: ${paginationState.totalRecords}'),
                    const SizedBox(width: 16),
                    TextButton.icon(
                      onPressed: paginationState.refresh,
                      label: const Text('Refresh'),
                      icon: const Icon(Icons.refresh),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
