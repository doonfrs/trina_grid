import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:trina_grid/trina_grid.dart';

/// Callback function to implement to add lazy pagination data.
typedef TrinaLazyPaginationFetch = Future<TrinaLazyPaginationResponse> Function(
    TrinaLazyPaginationRequest);

/// Callback function to build a custom pagination widget.
///
typedef TrinaPaginationBuilder = Widget Function(
    BuildContext context, TrinaLazyPaginationState paginationState);

/// Request data for lazy pagination processing.
class TrinaLazyPaginationRequest {
  TrinaLazyPaginationRequest({
    required this.page,
    this.pageSize = 10,
    this.sortColumn,
    this.filterRows = const <TrinaRow>[],
  });

  /// Request page.
  final int page;

  /// Page size (items per page)
  final int pageSize;

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

/// Response data for lazy pagination.
class TrinaLazyPaginationResponse {
  TrinaLazyPaginationResponse({
    required this.totalPage,
    required this.rows,
    this.totalRecords,
  }) {
    final frozenStartRows =
        rows.where((row) => row.frozen == TrinaRowFrozen.start).toList();
    if (frozenStartRows.isNotEmpty) {
      rows.removeWhere((row) => row.frozen == TrinaRowFrozen.start);
      for (var row in frozenStartRows) {
        rows.insert(0, row);
      }
    }

    final frozenEndRows =
        rows.where((row) => row.frozen == TrinaRowFrozen.end).toList();
    if (frozenEndRows.isNotEmpty) {
      rows.removeWhere((row) => row.frozen == TrinaRowFrozen.end);
      for (var row in frozenEndRows) {
        rows.add(row);
      }
    }
  }

  /// Total number of pages to create pagination buttons.
  final int totalPage;

  /// Rows to be added.
  final List<TrinaRow> rows;

  /// Total number of records
  final int? totalRecords;
}

/// Widget for processing lazy pagination.
///
/// ```dart
/// createFooter: (stateManager) {
///   return TrinaLazyPagination(
///     fetch: fetch,
///     stateManager: stateManager,
///   );
/// },
/// ```
///
/// You can listen for fetch completion events at the grid level by setting the onLazyFetchCompleted
/// callback on the TrinaGrid widget:
///
/// ```dart
/// TrinaGrid(
///   columns: columns,
///   rows: rows,
///   onLazyFetchCompleted: (event) {
///     // Handle the lazy fetch completed event
///     print('Fetch completed: page ${event.page} of ${event.totalPage}');
///     print('Total records: ${event.totalRecords}');
///
///     // You can access the state manager if needed
///     event.stateManager.setShowLoading(false);
///   },
///   createFooter: (stateManager) {
///     return TrinaLazyPagination(
///       fetch: fetch,
///       stateManager: stateManager,
///     );
///   },
/// )
/// ```
class TrinaLazyPagination extends StatefulWidget {
  TrinaLazyPagination({
    this.initialPage = 1,
    this.initialPageSize = 10,
    this.initialFetch = true,
    this.fetchWithSorting = true,
    this.fetchWithFiltering = true,
    this.pageSizeToMove,
    this.showPageSizeSelector = false,
    this.pageSizes = const [10, 20, 30, 50, 100],
    this.showLoading = true,
    this.loadingLevel = TrinaGridLoadingLevel.rows,
    this.customLoadingWidget,
    this.onPageSizeChanged,
    this.dropdownDecoration,
    this.dropdownItemDecoration,
    this.pageSizeDropdownIcon,
    required this.fetch,
    required this.stateManager,
    this.onLazyFetchCompleted,
    this.builder,
    super.key,
  }) : assert(
          !showPageSizeSelector || pageSizes.contains(initialPageSize),
          'initialPageSize must be included in pageSizes list when showPageSizeSelector is true',
        );

  /// Set the first page.
  final int initialPage;

  /// Set the initial page size
  final int initialPageSize;

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

  /// Set the number of moves to the previous or next page button.
  ///
  /// Default is null.
  /// Moves the page as many as the number of page buttons currently displayed.
  ///
  /// If this value is set to 1, the next previous page is moved by one page.
  final int? pageSizeToMove;

  /// Whether to show page size selector dropdown
  final bool showPageSizeSelector;

  /// Available page sizes in dropdown (only used when showPageSizeSelector is true)
  final List<int> pageSizes;

  /// Callback when page size changes (only used when showPageSizeSelector is true)
  final void Function(int pageSize)? onPageSizeChanged;

  /// Decoration for the dropdown button (only used when showPageSizeSelector is true)
  final BoxDecoration? dropdownDecoration;

  /// Decoration for dropdown items (only used when showPageSizeSelector is true)
  final BoxDecoration? dropdownItemDecoration;

  /// Icon for the dropdown (only used when showPageSizeSelector is true)
  final Icon? pageSizeDropdownIcon;

  /// A callback function that returns the data to be added.
  final TrinaLazyPaginationFetch fetch;

  final TrinaGridStateManager stateManager;

  final void Function(int page, int totalPage, int? totalRecords)?
      onLazyFetchCompleted;

  /// A callback function that returns a widget for custom pagination.
  final TrinaPaginationBuilder? builder;

  /// Whether to show the loading indicator when [fetch] is called.
  final bool showLoading;

  /// Specifies where the loading indicator will be displayed.
  ///
  /// see [TrinaGridLoadingLevel]
  final TrinaGridLoadingLevel loadingLevel;

  /// A custom widget to be displayed instead of the default loading indicator.
  final Widget? customLoadingWidget;
  @override
  State<TrinaLazyPagination> createState() => TrinaLazyPaginationState();
}

class TrinaLazyPaginationState extends State<TrinaLazyPagination> {
  late final StreamSubscription<TrinaGridEvent> _events;

  int _page = 1;
  late int _pageSize;
  int _totalPage = 0;
  int? _totalRecords;
  bool _isFetching = false;

  TrinaGridStateManager get stateManager => widget.stateManager;

  // Expose state
  int get page => _page;
  int get pageSize => _pageSize;
  int get totalPage => _totalPage;
  int? get totalRecords => _totalRecords;

  bool get isFirstPage => _page < 2;

  bool get isLastPage => _page >= _totalPage;

  int get _pageSizeToMove => widget.pageSizeToMove ?? 1;

  @override
  void initState() {
    super.initState();

    _page = widget.initialPage;
    _pageSize = widget.initialPageSize;

    if (widget.fetchWithSorting) {
      stateManager.setSortOnlyEvent(true);
    }

    if (widget.fetchWithFiltering) {
      stateManager.setFilterOnlyEvent(true);
    }

    _events = stateManager.eventManager!.listener(_eventListener);

    if (widget.initialFetch) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        setPage(widget.initialPage);
      });
    }
  }

  @override
  void dispose() {
    _events.cancel();
    super.dispose();
  }

  void _eventListener(TrinaGridEvent event) {
    if (event is TrinaGridChangeColumnSortEvent ||
        event is TrinaGridSetColumnFilterEvent) {
      setPage(1);
    } else if (event is TrinaGridChangeLazyPageEvent) {
      setPage((event.page == null || event.page! < 1) ? _page : event.page!);
    }
  }

  void setPage(int page) async {
    if (_isFetching) return;

    _isFetching = true;

    stateManager.setShowLoading(
      widget.showLoading,
      level: widget.loadingLevel,
      customLoadingWidget: widget.customLoadingWidget,
    );

    widget
        .fetch(
      TrinaLazyPaginationRequest(
        page: page,
        pageSize: _pageSize,
        sortColumn: stateManager.getSortedColumn,
        filterRows: stateManager.filterRows,
      ),
    )
        .then((data) {
      if (!mounted) return;
      stateManager.scroll.bodyRowsVertical!.jumpTo(0);

      stateManager.refRows.clearFromOriginal();
      stateManager.insertRows(0, data.rows);

      setState(() {
        _page = page;
        _totalPage = data.totalPage;
        _totalRecords = data.totalRecords;
        _isFetching = false;
      });

      stateManager.setShowLoading(false);

      // Call the onLazyFetchCompleted callback if provided
      if (widget.onLazyFetchCompleted != null) {
        widget.onLazyFetchCompleted!(_page, _totalPage, _totalRecords);
      }

      // Call the grid-level onLazyFetchCompleted callback if provided
      if (stateManager.onLazyFetchCompleted != null) {
        stateManager.onLazyFetchCompleted!(
          TrinaGridOnLazyFetchCompletedEvent(
            stateManager: stateManager,
            page: _page,
            totalPage: _totalPage,
            totalRecords: _totalRecords,
          ),
        );
      }
    });
  }

  void setPageSize(int size) {
    if (_pageSize == size) return;

    setState(() {
      _pageSize = size;
    });

    // Reset to first page with new page size
    setPage(1);
  }

  void firstPage() => setPage(1);

  void lastPage() => setPage(_totalPage);

  void previousPage() {
    var beforePage = _page - _pageSizeToMove;
    if (beforePage < 1) {
      beforePage = 1;
    }
    setPage(beforePage);
  }

  void nextPage() {
    var nextPage = _page + _pageSizeToMove;
    if (nextPage > _totalPage) {
      nextPage = _totalPage;
    }
    setPage(nextPage);
  }

  /// Triggers a re-fetch of the current page's data.
  void refresh() {
    setPage(_page);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.builder != null) {
      return widget.builder!(context, this);
    }

    return _PageSizeDropdownPaginationWidget(
      iconColor: stateManager.style.iconColor,
      disabledIconColor: stateManager.style.disabledIconColor,
      activatedColor: stateManager.style.activatedBorderColor,
      iconSize: stateManager.style.iconSize,
      height: stateManager.footerHeight,
      page: _page,
      totalPage: _totalPage,
      pageSizeToMove: widget.pageSizeToMove,
      setPage: setPage,
      pageSizes: widget.pageSizes,
      currentPageSize: _pageSize,
      onPageSizeChanged: (size) {
        setPageSize(size);
        if (widget.onPageSizeChanged != null) {
          widget.onPageSizeChanged!(size);
        }
      },
      dropdownDecoration: widget.dropdownDecoration,
      dropdownItemDecoration: widget.dropdownItemDecoration,
      pageSizeDropdownIcon: widget.pageSizeDropdownIcon,
      totalRecords: totalRecords,
      showPageSizeSelector: widget.showPageSizeSelector,
    );
  }
}

/// Widget with page size dropdown
class _PageSizeDropdownPaginationWidget extends StatefulWidget {
  const _PageSizeDropdownPaginationWidget({
    required this.iconColor,
    required this.disabledIconColor,
    required this.activatedColor,
    required this.iconSize,
    required this.height,
    required this.page,
    required this.totalPage,
    this.pageSizeToMove,
    required this.setPage,
    required this.pageSizes,
    required this.currentPageSize,
    required this.onPageSizeChanged,
    this.dropdownDecoration,
    this.dropdownItemDecoration,
    this.pageSizeDropdownIcon,
    this.showPageSizeSelector = false,
    this.totalRecords,
  });

  final Color iconColor;
  final Color disabledIconColor;
  final Color activatedColor;
  final double iconSize;
  final double height;
  final int page;
  final int totalPage;
  final int? pageSizeToMove;
  final void Function(int page) setPage;
  final List<int> pageSizes;
  final int currentPageSize;
  final void Function(int) onPageSizeChanged;
  final BoxDecoration? dropdownDecoration;
  final BoxDecoration? dropdownItemDecoration;
  final Icon? pageSizeDropdownIcon;
  final bool showPageSizeSelector;
  final int? totalRecords;

  @override
  State<_PageSizeDropdownPaginationWidget> createState() =>
      _PageSizeDropdownPaginationWidgetState();
}

class _PageSizeDropdownPaginationWidgetState
    extends State<_PageSizeDropdownPaginationWidget> {
  double _maxWidth = 0;

  final _iconSplashRadius = TrinaGridSettings.rowHeight / 2;

  bool get _isFirstPage => widget.page < 2;

  bool get _isLastPage => widget.page > widget.totalPage - 1;

  int get _itemSize {
    final countItemSize = ((_maxWidth - 350) / 100).floor();
    return countItemSize < 0 ? 0 : min(countItemSize, 3);
  }

  int get _startPage {
    final itemSizeGap = _itemSize + 1;
    var start = widget.page - itemSizeGap;
    if (widget.page + _itemSize > widget.totalPage) {
      start -= _itemSize + widget.page - widget.totalPage;
    }
    return start < 0 ? 0 : start;
  }

  int get _endPage {
    final itemSizeGap = _itemSize + 1;
    var end = widget.page + _itemSize;
    if (widget.page - itemSizeGap < 0) {
      end += itemSizeGap - widget.page;
    }
    return end > widget.totalPage ? widget.totalPage : end;
  }

  List<int> get _pageNumbers {
    return List.generate(
      _endPage - _startPage,
      (index) => _startPage + index,
      growable: false,
    );
  }

  int get _pageSizeToMove {
    return widget.pageSizeToMove ?? 1;
  }

  void _firstPage() {
    _movePage(1);
  }

  void _beforePage() {
    int beforePage = widget.page - _pageSizeToMove;
    if (beforePage < 1) {
      beforePage = 1;
    }
    _movePage(beforePage);
  }

  void _nextPage() {
    int nextPage = widget.page + _pageSizeToMove;
    if (nextPage > widget.totalPage) {
      nextPage = widget.totalPage;
    }
    _movePage(nextPage);
  }

  void _lastPage() {
    _movePage(widget.totalPage);
  }

  void _movePage(int page) {
    widget.setPage(page);
  }

  ButtonStyle _getNumberButtonStyle(bool isCurrentIndex) {
    return TextButton.styleFrom(
      disabledForegroundColor: Colors.transparent,
      shadowColor: Colors.transparent,
      padding: const EdgeInsets.fromLTRB(3, 0, 0, 3),
      backgroundColor: Colors.transparent,
    );
  }

  TextStyle _getNumberTextStyle(bool isCurrentIndex) {
    return TextStyle(
      fontSize: isCurrentIndex ? widget.iconSize - 2 : null,
      color: isCurrentIndex ? widget.activatedColor : widget.iconColor,
    );
  }

  Widget _makeNumberButton(int index) {
    var pageFromIndex = index + 1;
    var isCurrentIndex = widget.page == pageFromIndex;
    return TextButton(
      onPressed: () {
        _movePage(pageFromIndex);
      },
      style: _getNumberButtonStyle(isCurrentIndex),
      child: Text(
        pageFromIndex.toString(),
        style: _getNumberTextStyle(isCurrentIndex),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, size) {
        _maxWidth = size.maxWidth;

        return SizedBox(
          width: size.maxWidth,
          height: widget.height,
          child: Align(
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (widget.totalRecords != null) _totalRecordsWidget(),
                const Spacer(),
                Row(
                  children: [
                    _firstPageIconButton(),
                    _beforePageIconButton(),
                    ..._pageNumbers.map(_makeNumberButton),
                    _nextPageIconButton(),
                    _lastPageIconButton(),
                  ],
                ),
                const Spacer(),
                if (widget.showPageSizeSelector) _pageSizeDropdownButton(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _totalRecordsWidget() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          Icon(
            Icons.table_rows,
            color: widget.iconColor,
            size: widget.iconSize,
          ),
          Text(
            widget.totalRecords.toString(),
            style: TextStyle(
              color: widget.iconColor,
              fontSize: widget.iconSize - 3,
            ),
          ),
        ],
      ),
    );
  }

  IconButton _lastPageIconButton() {
    return IconButton(
      onPressed: _isLastPage ? null : _lastPage,
      icon: const Icon(Icons.last_page),
      color: widget.iconColor,
      disabledColor: widget.disabledIconColor,
      splashRadius: _iconSplashRadius,
      mouseCursor:
          _isLastPage ? SystemMouseCursors.basic : SystemMouseCursors.click,
    );
  }

  IconButton _nextPageIconButton() {
    return IconButton(
      onPressed: _isLastPage ? null : _nextPage,
      icon: const Icon(Icons.navigate_next),
      color: widget.iconColor,
      disabledColor: widget.disabledIconColor,
      splashRadius: _iconSplashRadius,
      mouseCursor:
          _isLastPage ? SystemMouseCursors.basic : SystemMouseCursors.click,
    );
  }

  IconButton _beforePageIconButton() {
    return IconButton(
      onPressed: _isFirstPage ? null : _beforePage,
      icon: const Icon(Icons.navigate_before),
      color: widget.iconColor,
      disabledColor: widget.disabledIconColor,
      splashRadius: _iconSplashRadius,
      mouseCursor:
          _isFirstPage ? SystemMouseCursors.basic : SystemMouseCursors.click,
    );
  }

  IconButton _firstPageIconButton() {
    return IconButton(
      onPressed: _isFirstPage ? null : _firstPage,
      icon: const Icon(Icons.first_page),
      color: widget.iconColor,
      disabledColor: widget.disabledIconColor,
      splashRadius: _iconSplashRadius,
      mouseCursor:
          _isFirstPage ? SystemMouseCursors.basic : SystemMouseCursors.click,
    );
  }

  Widget _pageSizeDropdownButton() {
    return Container(
      decoration: widget.dropdownDecoration,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          SizedBox(
            child: DropdownButton<int>(
              value: widget.currentPageSize,
              focusColor: Colors.transparent,
              underline: const SizedBox.shrink(),
              isDense: true,
              icon: widget.pageSizeDropdownIcon ??
                  Icon(Icons.view_list, color: widget.iconColor),
              items: widget.pageSizes.map<DropdownMenuItem<int>>((int value) {
                return DropdownMenuItem<int>(
                  value: value,
                  child: Container(
                    decoration: widget.dropdownItemDecoration,
                    child: Text(
                      '$value',
                      style: TextStyle(
                        color: widget.iconColor,
                        fontSize: widget.iconSize - 3,
                      ),
                    ),
                  ),
                );
              }).toList(),
              onChanged: (int? value) {
                if (value != null) {
                  widget.onPageSizeChanged(value);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
