import 'dart:async';

import 'package:flutter/material.dart';
import 'package:trina_grid/trina_grid.dart';

/// A callback function to implement when the scroll reaches the end.
typedef TrinaInfinityScrollRowsFetch =
    Future<TrinaInfinityScrollRowsResponse> Function(
      TrinaInfinityScrollRowsRequest,
    );

/// Request data to get data when scrolling has reached the end.
class TrinaInfinityScrollRowsRequest {
  TrinaInfinityScrollRowsRequest({
    this.lastRow,
    this.sortColumn,
    this.filterRows = const <TrinaRow>[],
  });

  /// If [lastRow] is null , it points to the beginning of the data.
  /// If not null, the next data is loaded with reference to this value.
  final TrinaRow? lastRow;

  /// If the sort condition is set, the column for which the sort is set.
  /// The value of [TrinaColumn.sort] is the sort status of the column.
  final TrinaColumn? sortColumn;

  /// Filtering status when filtering conditions are set.
  ///
  /// If this list is empty, filtering is not set.
  /// Filtering column, type, and filtering value are set in [TrinaRow.cells].
  ///
  /// [filterRows] can be converted to Map type as shown below.
  /// ```dart
  /// FilterHelper.convertRowsToMap(filterRows);
  ///
  /// // Assuming that filtering is set in column2, the following values are returned.
  /// // {column2: [{Contains: 123}]}
  /// ```
  ///
  /// The filter type in FilterHelper.defaultFilters is the default,
  /// If there is user-defined filtering,
  /// the title set by the user is returned as the filtering type.
  /// All filtering can change the value returned as a filtering type by changing the name property.
  /// In case of TrinaFilterTypeContains filter, if you change the static type name to include
  /// TrinaFilterTypeContains.name = 'include';
  /// {column2: [{include: abc}, {include: 123}]} will be returned.
  final List<TrinaRow> filterRows;
}

/// The return value of the fetch callback function of [TrinaInfinityScrollRow]
/// when the scroll reaches the end.
class TrinaInfinityScrollRowsResponse {
  TrinaInfinityScrollRowsResponse({required this.isLast, required this.rows});

  /// Set this value to true if all items are returned.
  final bool isLast;

  /// Rows to be added.
  final List<TrinaRow> rows;
}

/// When the end of the list is reached
/// by scrolling, arrow keys, or PageDown key manipulation
/// Add the response result to the grid by calling the [fetch] callback function.
///
/// ```dart
/// createFooter: (s) => TrinaInfinityScrollRows(
///   fetch: fetch,
///   stateManager: s,
/// ),
/// ```
class TrinaInfinityScrollRows extends StatefulWidget {
  const TrinaInfinityScrollRows({
    this.initialFetch = true,
    this.fetchWithSorting = true,
    this.fetchWithFiltering = true,
    required this.fetch,
    required this.stateManager,
    super.key,
  });

  /// Decide whether to call the fetch function first.
  final bool initialFetch;

  /// Decide whether to handle sorting in the fetch function.
  /// Default is true.
  /// If this value is false, the list is sorted with the current grid loaded.
  final bool fetchWithSorting;

  /// Decide whether to handle filtering in the fetch function.
  /// Default is true.
  /// If this value is false,
  /// the list is filtered while it is currently loaded in the grid.
  final bool fetchWithFiltering;

  /// A callback function that returns the data to be added.
  final TrinaInfinityScrollRowsFetch fetch;

  final TrinaGridStateManager stateManager;

  @override
  State<TrinaInfinityScrollRows> createState() =>
      _TrinaInfinityScrollRowsState();
}

class _TrinaInfinityScrollRowsState extends State<TrinaInfinityScrollRows> {
  late final StreamSubscription<TrinaGridEvent> _events;

  int _fetchVersion = 0;
  bool _isFetching = false;

  bool _isLast = false;

  TrinaGridStateManager get stateManager => widget.stateManager;

  ScrollController get scroll => stateManager.scroll.bodyRowsVertical!;

  @override
  void initState() {
    super.initState();

    if (widget.fetchWithSorting) {
      stateManager.setSortOnlyEvent(true);
    }

    if (widget.fetchWithFiltering) {
      stateManager.setFilterOnlyEvent(true);
    }

    _events = stateManager.eventManager!.listener(_eventListener);

    scroll.addListener(_scrollListener);

    if (widget.initialFetch) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        _update(null);
      });
    }
  }

  @override
  void dispose() {
    scroll.removeListener(_scrollListener);

    _events.cancel();

    super.dispose();
  }

  void _eventListener(TrinaGridEvent event) {
    if (event is TrinaGridCannotMoveCurrentCellEvent &&
        event.direction.isDown &&
        !_isFetching) {
      _update(stateManager.refRows.last);
    } else if (event is TrinaGridChangeColumnSortEvent) {
      _update(null);
    } else if (event is TrinaGridSetColumnFilterEvent) {
      _update(null);
    }
  }

  void _scrollListener() {
    if (scroll.offset == scroll.position.maxScrollExtent && !_isFetching) {
      _update(stateManager.refRows.last);
    }
  }

  void _update(TrinaRow? lastRow) {
    if (lastRow == null) _isLast = false;

    if (_isLast) return;

    // Increment version to mark this as the current fetch
    // This allows new fetches to supersede in-progress ones
    final thisVersion = ++_fetchVersion;
    _isFetching = true;

    stateManager.setShowLoading(
      true,
      level: lastRow == null
          ? TrinaGridLoadingLevel.rows
          : TrinaGridLoadingLevel.rowsBottomCircular,
    );

    final request = TrinaInfinityScrollRowsRequest(
      lastRow: lastRow,
      sortColumn: stateManager.getSortedColumn,
      filterRows: stateManager.filterRows,
    );

    widget
        .fetch(request)
        .then((response) {
          // Only process if this is still the current fetch and widget is mounted
          if (thisVersion != _fetchVersion || !mounted) return;

          if (lastRow == null) {
            scroll.jumpTo(0);
            stateManager.removeAllRows(notify: false);
          }

          stateManager.appendRows(response.rows);

          stateManager.setShowLoading(false);

          _isFetching = false;

          _isLast = response.isLast;

          if (!_isLast) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (scroll.hasClients && scroll.position.maxScrollExtent == 0) {
                var lastRow = stateManager.rows.isNotEmpty
                    ? stateManager.rows.last
                    : null;
                _update(lastRow);
              }
            });
          }
        })
        .catchError((error) {
          // Only handle error if this is still the current fetch
          if (thisVersion != _fetchVersion || !mounted) return;

          _isFetching = false;
          stateManager.setShowLoading(false);
        });
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
