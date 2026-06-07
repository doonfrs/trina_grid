import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:trina_grid/trina_grid.dart';

import '../../dummy_data/development.dart';
import '../../widget/trina_example_button.dart';
import '../../widget/trina_example_screen.dart';

class ColumnFilteringScreen extends StatefulWidget {
  static const routeName = 'feature/column-filtering';

  const ColumnFilteringScreen({super.key});

  @override
  _ColumnFilteringScreenState createState() => _ColumnFilteringScreenState();
}

class _ColumnFilteringScreenState extends State<ColumnFilteringScreen> {
  final List<TrinaColumn> columns = [];

  // The grid starts empty; the lazy pagination plugin fetches page 1 on load.
  final List<TrinaRow> rows = [];

  // Large in-memory dataset that [fetch] slices per page (stands in for a
  // server). Enough rows so pagination spans many pages.
  final List<TrinaRow> fakeFetchedRows = [];

  /// Assigned in [TrinaGrid.onLoaded]. Kept nullable because the control panel
  /// can be built/tapped before onLoaded fires.
  TrinaGridStateManager? stateManager;

  // Mirrors of grid state so the switches reflect reality.
  bool _showFilter = true;
  bool _showFooter = true;
  bool _showHorizontalScroll = true;
  bool _tallFooter = false;

  // Pagination feedback, updated from onLazyFetchCompleted.
  int _page = 1;
  int _totalPage = 0;
  int _loads = 0;

  @override
  void initState() {
    super.initState();

    columns.addAll([
      TrinaColumn(
        title: 'Text',
        field: 'text',
        type: TrinaColumnType.text(),
        width: 220,
        // Footer renderer so the grid has a footer band that can be
        // shown/hidden (Bug #367 repro: footer collapse jumps the grid).
        footerRenderer: (rendererContext) {
          return _wrapFooter(
            TrinaAggregateColumnFooter(
              rendererContext: rendererContext,
              type: TrinaAggregateColumnType.count,
              numberFormat: NumberFormat('Count : #,###'),
              alignment: Alignment.center,
            ),
          );
        },
      ),
      TrinaColumn(
        title: 'Number',
        field: 'number',
        type: TrinaColumnType.number(),
        width: 220,
        footerRenderer: (rendererContext) {
          return _wrapFooter(
            TrinaAggregateColumnFooter(
              rendererContext: rendererContext,
              type: TrinaAggregateColumnType.sum,
              numberFormat: NumberFormat('Sum : #,###'),
              alignment: Alignment.center,
            ),
          );
        },
      ),
      TrinaColumn(
        title: 'Date',
        field: 'date',
        type: TrinaColumnType.date(),
        width: 220,
      ),
      TrinaColumn(
        title: 'Disable',
        field: 'disable',
        type: TrinaColumnType.text(),
        enableFilterMenuItem: false,
        width: 220,
      ),
      TrinaColumn(
        title: 'Select',
        field: 'select',
        type: TrinaColumnType.select(<String>['A', 'B', 'C', 'D', 'E', 'F']),
        width: 220,
      ),
      TrinaColumn(
        title: 'Regex',
        field: 'regex',
        type: TrinaColumnType.text(),
        width: 240,
      ),
      // Extra wide columns so the grid overflows horizontally and the
      // horizontal scrollbar is active (Bug #367 repro: scrollbar flicker).
      TrinaColumn(
        title: 'Extra 1',
        field: 'extra1',
        type: TrinaColumnType.text(),
        width: 250,
      ),
      TrinaColumn(
        title: 'Extra 2',
        field: 'extra2',
        type: TrinaColumnType.text(),
        width: 250,
      ),
      TrinaColumn(
        title: 'Extra 3',
        field: 'extra3',
        type: TrinaColumnType.text(),
        width: 250,
      ),
    ]);

    // Build a large fake dataset for the lazy pagination fetch to page through.
    fakeFetchedRows.addAll(
      DummyData.rowsByColumns(length: 1000, columns: columns),
    );

    // A few rows with predictable patterns so the Regex / custom filters have
    // matching data to find.
    for (var i = 0; i < 5; i++) {
      fakeFetchedRows.add(
        TrinaRow(
          cells: {
            'text': TrinaCell(value: 'Text value ${i + 1}'),
            'number': TrinaCell(value: i + 100),
            'date': TrinaCell(value: '2025-05-${i + 1}'),
            'disable': TrinaCell(value: 'Disable value ${i + 1}'),
            'select': TrinaCell(value: ['A', 'B', 'C', 'D', 'E', 'F'][i % 6]),
            'regex': TrinaCell(value: 'user${i + 1}@example.com'),
            'extra1': TrinaCell(value: 'extra1 ${i + 1}'),
            'extra2': TrinaCell(value: 'extra2 ${i + 1}'),
            'extra3': TrinaCell(value: 'extra3 ${i + 1}'),
          },
        ),
      );
    }
  }

  /// Lazy pagination data source. Slices [fakeFetchedRows] by page and applies
  /// the server-side filter/sort state from the request.
  Future<TrinaLazyPaginationResponse> fetch(
    TrinaLazyPaginationRequest request,
  ) async {
    List<TrinaRow> tempList = fakeFetchedRows;
    final sm = stateManager;

    if (sm != null && request.filterRows.isNotEmpty) {
      final filter = FilterHelper.convertRowsToFilter(
        request.filterRows,
        sm.refColumns,
      );
      if (filter != null) {
        tempList = fakeFetchedRows.where(filter).toList();
      }
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
    final fetchedRows = tempList.getRange(
      max(0, start),
      min(tempList.length, end),
    );

    // Simulated network latency so the loading + layout jump is perceptible.
    await Future.delayed(const Duration(milliseconds: 450));

    return TrinaLazyPaginationResponse(
      totalPage: totalPage,
      rows: fetchedRows.toList(),
      totalRecords: tempList.length,
    );
  }

  /// Wraps a footer widget in a [SizedBox] whose height tracks [_tallFooter].
  ///
  /// Changing the footer widget height is the only reliable way to change the
  /// footer band height, because the grid layout pass overwrites
  /// `stateManager.columnFooterHeight` with the measured footer size.
  Widget _wrapFooter(Widget child) {
    return SizedBox(height: _tallFooter ? 90 : 45, child: child);
  }

  /// The grid configuration, factored out so the horizontal-scrollbar toggle
  /// can rebuild the FULL config via setConfiguration without dropping the
  /// custom columnFilter block.
  TrinaGridConfiguration _buildConfiguration() {
    return TrinaGridConfiguration(
      // Keep explicit column widths so the grid overflows horizontally.
      columnSize: const TrinaGridColumnSizeConfig(
        autoSizeMode: TrinaAutoSizeMode.none,
      ),
      scrollbar: TrinaGridScrollbarConfig(
        isAlwaysShown: true,
        showHorizontal: _showHorizontalScroll,
        showVertical: true,
      ),

      /// If columnFilter is not set, the default setting is applied.
      ///
      /// Return the value returned by resolveDefaultColumnFilter through the
      /// resolver function. Prevents errors returning filters that are not in
      /// the filters list.
      columnFilter: TrinaGridColumnFilterConfig(
        filters: const [
          ...FilterHelper.defaultFilters,
          // custom filter
          ClassYouImplemented(),
        ],
        resolveDefaultColumnFilter: (column, resolver) {
          if (column.field == 'text') {
            return resolver<TrinaFilterTypeContains>() as TrinaFilterType;
          } else if (column.field == 'number') {
            return resolver<TrinaFilterTypeGreaterThan>() as TrinaFilterType;
          } else if (column.field == 'date') {
            return resolver<TrinaFilterTypeLessThan>() as TrinaFilterType;
          } else if (column.field == 'select') {
            return resolver<ClassYouImplemented>() as TrinaFilterType;
          } else if (column.field == 'regex') {
            return resolver<TrinaFilterTypeRegex>() as TrinaFilterType;
          }

          return resolver<TrinaFilterTypeContains>() as TrinaFilterType;
        },
      ),
    );
  }

  /// Reloads the current page through the real lazy-pagination path
  /// (setShowLoading -> clear rows -> insert rows -> hide loading), which
  /// momentarily collapses the filter row / footer / scrollbar so the body
  /// jumps. Passing page: null reloads whatever page is currently shown.
  void _handleReload() {
    stateManager?.eventManager!.addEvent(
      TrinaGridChangeLazyPageEvent(page: null),
    );
  }

  void _toggleFilter(bool value) {
    setState(() => _showFilter = value);
    stateManager?.setShowColumnFilter(value);
  }

  void _toggleFooter(bool value) {
    setState(() => _showFooter = value);
    stateManager?.setShowColumnFooter(value);
  }

  void _toggleTallFooter(bool value) {
    setState(() => _tallFooter = value);
    // The footerRenderer reads _tallFooter at build time; relayout to apply.
    stateManager?.notifyListeners();
  }

  void _toggleHorizontalScroll(bool value) {
    setState(() => _showHorizontalScroll = value);
    final sm = stateManager;
    if (sm == null) return;
    sm.setConfiguration(_buildConfiguration());
    sm.notifyListeners();
  }

  Widget _buildSwitch(String label, bool value, ValueChanged<bool> onChanged) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label),
        const SizedBox(width: 4),
        Switch(value: value, onChanged: onChanged),
      ],
    );
  }

  Widget _buildControlPanel() {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bug #367 repro controls - watch the grid jump while this panel stays still',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 12,
              runSpacing: 4,
              children: [
                ElevatedButton.icon(
                  onPressed: _handleReload,
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Reload current page'),
                ),
                _buildSwitch('Show Filter Row', _showFilter, _toggleFilter),
                _buildSwitch('Show Footer', _showFooter, _toggleFooter),
                _buildSwitch('Tall Footer', _tallFooter, _toggleTallFooter),
                _buildSwitch(
                  'Horizontal Scrollbar',
                  _showHorizontalScroll,
                  _toggleHorizontalScroll,
                ),
                Text('Page $_page / $_totalPage   Loads: $_loads'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TrinaExampleScreen(
      title: 'Column filtering',
      topTitle: 'Column filtering',
      topContents: const [
        Text('Filter rows by setting filters on columns.'),
        SizedBox(height: 10),
        Text(
          'Select the SetFilter menu from the menu that appears when you tap the icon on the right of the column',
        ),
        Text(
          'If the filter is set to all or complex conditions, TextField under the column is deactivated.',
        ),
        Text(
          'Also, like the Disable column, if enableFilterMenuItem is false, it is excluded from all column filtering conditions.',
        ),
        Text(
          'In the case of the Select column, it is a custom filter that can filter multiple filters with commas. (ex: a,b,c)',
        ),
        Text(
          'The Regex column demonstrates the new Regex filter type that allows filtering with regular expressions.',
        ),
        SizedBox(height: 10),
        Text(
          'This screen uses lazy pagination backed by 1000 rows. It reproduces issue #367: changing pages, reloading, or toggling the filter row, footer, or horizontal scrollbar makes the grid layout jump.',
        ),
        SizedBox(height: 10),
        Text('Check out the source to add custom filters.'),
      ],
      topButtons: [
        TrinaExampleButton(
          url:
              'https://github.com/doonfrs/trina_grid/blob/master/demo/lib/screen/feature/column_filtering_screen.dart',
        ),
      ],
      body: Column(
        children: [
          _buildControlPanel(),
          const SizedBox(height: 8),
          Expanded(
            child: TrinaGrid(
              columns: columns,
              rows: rows,
              onLoaded: (TrinaGridOnLoadedEvent event) {
                stateManager = event.stateManager;
                stateManager!.setShowColumnFilter(_showFilter);
                stateManager!.setShowColumnFooter(_showFooter);
              },
              onChanged: (TrinaGridOnChangedEvent event) {
                print(event);
              },
              onLazyFetchCompleted: (TrinaGridOnLazyFetchCompletedEvent event) {
                if (!mounted) return;
                setState(() {
                  _page = event.page;
                  _totalPage = event.totalPage;
                  _loads++;
                });
              },
              configuration: _buildConfiguration(),
              createFooter: (stateManager) {
                return TrinaLazyPagination(
                  initialPage: 1,
                  initialPageSize: 30,
                  initialFetch: true,
                  fetchWithSorting: true,
                  fetchWithFiltering: true,
                  showTotalRows: true,
                  enableGotoPage: true,
                  fetch: fetch,
                  stateManager: stateManager,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ClassYouImplemented implements TrinaFilterType {
  @override
  String get title => 'Custom contains';

  @override
  get compare =>
      ({
        required String? base,
        required String? search,
        required TrinaColumn? column,
      }) {
        var keys = search!.split(',').map((e) => e.toUpperCase()).toList();

        return keys.contains(base!.toUpperCase());
      };

  const ClassYouImplemented();
}
