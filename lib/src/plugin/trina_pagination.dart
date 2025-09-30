import 'dart:math';

import 'package:flutter/material.dart';
import 'package:trina_grid/trina_grid.dart';

import '../ui/ui.dart';

/// A widget for client-side pagination.
///
/// Server-side pagination can be implemented
/// using the [TrinaLazyPagination] or [TrinaInfinityScrollRows] widgets.
class TrinaPagination extends TrinaStatefulWidget {
  const TrinaPagination(
    this.stateManager, {
    this.pageSizeToMove,
    this.showTotalRows,
    this.enableGotoPage,
    super.key,
  }) : assert(pageSizeToMove == null || pageSizeToMove > 0);

  final TrinaGridStateManager stateManager;

  /// Set the number of moves to the previous or next page button.
  ///
  /// Default is null.
  /// Moves the page as many as the number of page buttons currently displayed.
  ///
  /// If this value is set to 1, the next previous page is moved by one page.
  final int? pageSizeToMove;

  /// Display total number of rows in the footer.
  ///
  /// If null, defaults to configuration value [TrinaGridConfiguration.paginationShowTotalRows].
  final bool? showTotalRows;

  /// Enable "Go to page" functionality.
  ///
  /// If null, defaults to configuration value [TrinaGridConfiguration.paginationEnableGotoPage].
  /// Shows a button to open a dialog for jumping to a specific page.
  final bool? enableGotoPage;

  @override
  TrinaPaginationState createState() => TrinaPaginationState();
}

abstract class _TrinaPaginationStateWithChange
    extends TrinaStateWithChange<TrinaPagination> {
  late int page;

  late int totalPage;

  @override
  TrinaGridStateManager get stateManager => widget.stateManager;

  @override
  void initState() {
    super.initState();

    page = stateManager.page;

    totalPage = stateManager.totalPage;

    stateManager.setPage(page, notify: false);

    updateState(TrinaNotifierEventForceUpdate.instance);
  }

  @override
  void updateState(TrinaNotifierEvent event) {
    page = update<int>(page, stateManager.page);

    totalPage = update<int>(totalPage, stateManager.totalPage);
  }
}

class TrinaPaginationState extends _TrinaPaginationStateWithChange {
  late double _maxWidth;

  late Color _iconColor;
  late Color _disabledIconColor;
  late Color _activatedBorderColor;

  final _iconSplashRadius = TrinaGridSettings.rowHeight / 2;
  final _gotoPageController = TextEditingController();

  bool get _isFirstPage => page < 2;

  bool get _isLastPage => page > totalPage - 1;

  @override
  void dispose() {
    _gotoPageController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    // Initialize color values before calling super.initState()
    // because super.initState() calls updateState which needs these values
    _iconColor = widget.stateManager.configuration.style.iconColor;
    _disabledIconColor =
        widget.stateManager.configuration.style.disabledIconColor;
    _activatedBorderColor =
        widget.stateManager.configuration.style.activatedBorderColor;

    super.initState();
  }

  @override
  void updateState(TrinaNotifierEvent event) {
    super.updateState(event);

    _iconColor = update<Color>(
      _iconColor,
      stateManager.configuration.style.iconColor,
    );

    _disabledIconColor = update<Color>(
      _disabledIconColor,
      stateManager.configuration.style.disabledIconColor,
    );

    _activatedBorderColor = update<Color>(
      _activatedBorderColor,
      stateManager.configuration.style.activatedBorderColor,
    );
  }

  /// maxWidth < 450 : 1
  /// maxWidth >= 450 : 3
  /// maxWidth >= 550 : 5
  /// maxWidth >= 650 : 7
  int get _itemSize {
    final countItemSize = ((_maxWidth - 350) / 100).floor();

    return countItemSize < 0 ? 0 : min(countItemSize, 3);
  }

  int get _startPage {
    final itemSizeGap = _itemSize + 1;

    var start = page - itemSizeGap;

    if (page + _itemSize > totalPage) {
      start -= _itemSize + page - totalPage;
    }

    return start < 0 ? 0 : start;
  }

  int get _endPage {
    final itemSizeGap = _itemSize + 1;

    var end = page + _itemSize;

    if (page - itemSizeGap < 0) {
      end += itemSizeGap - page;
    }

    return end > totalPage ? totalPage : end;
  }

  List<int> get _pageNumbers {
    return List.generate(
      _endPage - _startPage,
      (index) => _startPage + index,
      growable: false,
    );
  }

  int get _pageSizeToMove {
    if (widget.pageSizeToMove == null) {
      return 1 + (_itemSize * 2);
    }

    return widget.pageSizeToMove!;
  }

  void _firstPage() {
    _movePage(1);
  }

  void _beforePage() {
    setState(() {
      page -= _pageSizeToMove;

      if (page < 1) {
        page = 1;
      }

      _movePage(page);
    });
  }

  void _nextPage() {
    setState(() {
      page += _pageSizeToMove;

      if (page > totalPage) {
        page = totalPage;
      }

      _movePage(page);
    });
  }

  void _lastPage() {
    _movePage(totalPage);
  }

  void _movePage(int page) {
    stateManager.setPage(page);
  }

  ButtonStyle _getNumberButtonStyle(bool isCurrentIndex) {
    return TextButton.styleFrom(
      disabledForegroundColor: Colors.transparent,
      shadowColor: Colors.transparent,
      padding: const EdgeInsets.fromLTRB(5, 0, 0, 10),
      backgroundColor: Colors.transparent,
    );
  }

  TextStyle _getNumberTextStyle(bool isCurrentIndex) {
    return TextStyle(
      fontSize: isCurrentIndex
          ? stateManager.configuration.style.iconSize
          : null,
      color: isCurrentIndex ? _activatedBorderColor : _iconColor,
    );
  }

  Widget _makeNumberButton(int index) {
    var pageFromIndex = index + 1;

    var isCurrentIndex = page == pageFromIndex;

    return TextButton(
      onPressed: () {
        stateManager.setPage(pageFromIndex);
      },
      style: _getNumberButtonStyle(isCurrentIndex),
      child: Text(
        pageFromIndex.toString(),
        style: _getNumberTextStyle(isCurrentIndex),
      ),
    );
  }

  void _showGotoPageDialog() {
    _gotoPageController.clear();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Go to Page'),
        content: TextField(
          controller: _gotoPageController,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: InputDecoration(
            labelText: 'Page number (1-$totalPage)',
            border: const OutlineInputBorder(),
          ),
          onSubmitted: (value) {
            _handleGotoPage();
            Navigator.of(context).pop();
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _handleGotoPage();
              Navigator.of(context).pop();
            },
            child: const Text('Go'),
          ),
        ],
      ),
    );
  }

  void _handleGotoPage() {
    final pageNumber = int.tryParse(_gotoPageController.text);
    if (pageNumber != null && pageNumber >= 1 && pageNumber <= totalPage) {
      _movePage(pageNumber);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a valid page number (1-$totalPage)'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, size) {
        _maxWidth = size.maxWidth;

        final Color iconColor = _iconColor;

        final Color disabledIconColor = _disabledIconColor;

        return SizedBox(
          width: _maxWidth,
          height: TrinaGridSettings.rowHeight + 20,
          child: Align(
            alignment: Alignment.center,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  IconButton(
                    onPressed: _isFirstPage ? null : _firstPage,
                    icon: const Icon(Icons.first_page),
                    color: iconColor,
                    disabledColor: disabledIconColor,
                    splashRadius: _iconSplashRadius,
                    mouseCursor: _isFirstPage
                        ? SystemMouseCursors.basic
                        : SystemMouseCursors.click,
                  ),
                  IconButton(
                    onPressed: _isFirstPage ? null : _beforePage,
                    icon: const Icon(Icons.navigate_before),
                    color: iconColor,
                    disabledColor: disabledIconColor,
                    splashRadius: _iconSplashRadius,
                    mouseCursor: _isFirstPage
                        ? SystemMouseCursors.basic
                        : SystemMouseCursors.click,
                  ),
                  ..._pageNumbers.map(_makeNumberButton),
                  if (widget.showTotalRows ??
                      stateManager.configuration.paginationShowTotalRows)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        '/ $totalPage [${stateManager.refRows.originalList.length}]',
                        style: TextStyle(
                          color: _activatedBorderColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  IconButton(
                    onPressed: _isLastPage ? null : _nextPage,
                    icon: const Icon(Icons.navigate_next),
                    color: iconColor,
                    disabledColor: disabledIconColor,
                    splashRadius: _iconSplashRadius,
                    mouseCursor: _isLastPage
                        ? SystemMouseCursors.basic
                        : SystemMouseCursors.click,
                  ),
                  IconButton(
                    onPressed: _isLastPage ? null : _lastPage,
                    icon: const Icon(Icons.last_page),
                    color: iconColor,
                    disabledColor: disabledIconColor,
                    splashRadius: _iconSplashRadius,
                    mouseCursor: _isLastPage
                        ? SystemMouseCursors.basic
                        : SystemMouseCursors.click,
                  ),
                  if (widget.enableGotoPage ??
                      stateManager.configuration.paginationEnableGotoPage)
                    IconButton(
                      onPressed: _showGotoPageDialog,
                      icon: const Icon(Icons.search),
                      color: iconColor,
                      splashRadius: _iconSplashRadius,
                      tooltip: 'Go to page',
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
