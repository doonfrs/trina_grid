import 'package:flutter/material.dart';
import 'dart:async';
import 'package:trina_grid/src/widgets/trina_horizontal_scroll_bar.dart';
import 'package:trina_grid/src/widgets/trina_vertical_scroll_bar.dart';
import 'package:trina_grid/trina_grid.dart';

import 'scrolls/trina_single_child_smooth_scroll_view.dart';
import 'scrolls/trina_smooth_list_view.dart';
import 'ui.dart';

class TrinaBodyRows extends TrinaStatefulWidget {
  final TrinaGridStateManager stateManager;

  const TrinaBodyRows(this.stateManager, {super.key});

  @override
  TrinaBodyRowsState createState() => TrinaBodyRowsState();
}

class TrinaBodyRowsState extends TrinaStateWithChange<TrinaBodyRows> {
  List<TrinaColumn> _columns = [];

  List<TrinaRow> _rows = [];
  List<TrinaRow> _frozenTopRows = [];
  List<TrinaRow> _frozenBottomRows = [];
  List<TrinaRow> _scrollableRows = [];

  late final ScrollController _verticalScroll;
  late final ScrollController _horizontalScroll;

  // Timers for scroll update
  Timer? _verticalScrollTimer;
  Timer? _horizontalScrollTimer;

  // Value notifiers for scroll info to avoid rebuilding the entire widget
  final ValueNotifier<double> _verticalScrollOffsetNotifier =
      ValueNotifier<double>(0.0);
  final ValueNotifier<double> _verticalScrollExtentNotifier =
      ValueNotifier<double>(1.0);
  final ValueNotifier<double> _verticalViewportExtentNotifier =
      ValueNotifier<double>(1.0);

  // Value notifiers for horizontal scroll
  final ValueNotifier<double> _horizontalScrollOffsetNotifier =
      ValueNotifier<double>(0.0);
  final ValueNotifier<double> _horizontalScrollExtentNotifier =
      ValueNotifier<double>(1.0);
  final ValueNotifier<double> _horizontalViewportExtentNotifier =
      ValueNotifier<double>(1.0);

  @override
  TrinaGridStateManager get stateManager => widget.stateManager;

  @override
  void initState() {
    super.initState();

    _horizontalScroll = stateManager.scroll.horizontal!.addAndGet();
    stateManager.scroll.setBodyRowsHorizontal(_horizontalScroll);

    _verticalScroll = stateManager.scroll.vertical!.addAndGet();
    stateManager.scroll.setBodyRowsVertical(_verticalScroll);

    // Listen to scroll changes for the fake scrollbars
    _verticalScroll.addListener(_updateVerticalScrollInfo);
    _horizontalScroll.addListener(_updateHorizontalScrollInfo);

    // Initialize scroll info with default values
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_verticalScroll.hasClients) {
        _updateVerticalScrollInfo();
      }
      if (_horizontalScroll.hasClients) {
        _updateHorizontalScrollInfo();
      }
    });

    updateState(TrinaNotifierEventForceUpdate.instance);
  }

  void _updateVerticalScrollInfo() {
    if (!_verticalScroll.hasClients) return;

    // Update value notifiers without triggering setState
    _verticalScrollOffsetNotifier.value = _verticalScroll.offset;
    _verticalScrollExtentNotifier.value =
        _verticalScroll.position.maxScrollExtent;
    _verticalViewportExtentNotifier.value =
        _verticalScroll.position.viewportDimension;
  }

  void _updateHorizontalScrollInfo() {
    if (!_horizontalScroll.hasClients) return;

    // Update value notifiers without triggering setState
    _horizontalScrollOffsetNotifier.value = _horizontalScroll.offset;
    _horizontalScrollExtentNotifier.value =
        _horizontalScroll.position.maxScrollExtent;
    _horizontalViewportExtentNotifier.value =
        _horizontalScroll.position.viewportDimension;
  }

  @override
  void dispose() {
    _verticalScroll.removeListener(_updateVerticalScrollInfo);
    _horizontalScroll.removeListener(_updateHorizontalScrollInfo);

    // Cancel pending timers
    _verticalScrollTimer?.cancel();
    _horizontalScrollTimer?.cancel();

    _verticalScroll.dispose();
    _horizontalScroll.dispose();
    _verticalScrollOffsetNotifier.dispose();
    _verticalScrollExtentNotifier.dispose();
    _verticalViewportExtentNotifier.dispose();
    _horizontalScrollOffsetNotifier.dispose();
    _horizontalScrollExtentNotifier.dispose();
    _horizontalViewportExtentNotifier.dispose();
    super.dispose();
  }

  @override
  void updateState(TrinaNotifierEvent event) {
    forceUpdate();

    _columns = _getColumns();

    // Get frozen rows from the original list to keep them across pagination
    _frozenTopRows = stateManager.refRows.originalList
        .where((row) => row.frozen == TrinaRowFrozen.start)
        .toList();
    _frozenBottomRows = stateManager.refRows.originalList
        .where((row) => row.frozen == TrinaRowFrozen.end)
        .toList();

    // Get non-frozen rows from the current page
    _rows = stateManager.refRows;
    _scrollableRows = _rows
        .where((row) => row.frozen == TrinaRowFrozen.none)
        .toList();

    // Cancel existing timers before creating new ones
    _verticalScrollTimer?.cancel();
    _horizontalScrollTimer?.cancel();

    if (_verticalScroll.hasClients) {
      // Use a sync update if possible, otherwise schedule a short timer
      if (mounted) {
        _verticalScrollTimer = Timer(const Duration(milliseconds: 100), () {
          if (mounted) {
            _updateVerticalScrollInfo();
          }
        });
      }
    }

    if (_horizontalScroll.hasClients) {
      if (mounted) {
        _horizontalScrollTimer = Timer(const Duration(milliseconds: 100), () {
          if (mounted) {
            _updateHorizontalScrollInfo();
          }
        });
      }
    }
  }

  List<TrinaColumn> _getColumns() {
    return stateManager.showFrozenColumn == true
        ? stateManager.bodyColumns
        : stateManager.columns;
  }

  Widget _buildRow(BuildContext context, TrinaRow row, int index) {
    Widget rowWidget = TrinaBaseRow(
      key: ValueKey('body_row_${row.key}'),
      rowIdx: index,
      row: row,
      columns: _columns,
      stateManager: stateManager,
      visibilityLayout: true,
    );

    return stateManager.rowWrapper?.call(
          context,
          rowWidget,
          row,
          stateManager,
        ) ??
        rowWidget;
  }

  // Build the fake vertical scrollbar using ValueListenableBuilder

  @override
  Widget build(BuildContext context) {
    final scrollConfig = stateManager.configuration.scrollbar;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: stateManager.style.rowColor,
        borderRadius: stateManager.configuration.style.gridBorderRadius,
      ),
      child: Column(
        children: [
          // Main content with vertical scrollbar
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Main grid content
                Expanded(
                  child:
                      (scrollConfig.smoothScrolling
                      ? TrinaSingleChildSmoothScrollView.new
                      : SingleChildScrollView.new)(
                        controller: _horizontalScroll,
                        scrollDirection: Axis.horizontal,
                        physics: const ClampingScrollPhysics(),
                        child: CustomSingleChildLayout(
                          delegate: ListResizeDelegate(stateManager, _columns),
                          child: Column(
                            children: [
                              // Frozen top rows
                              if (_frozenTopRows.isNotEmpty)
                                Column(
                                  children: _frozenTopRows
                                      .asMap()
                                      .entries
                                      .map(
                                        (e) =>
                                            _buildRow(context, e.value, e.key),
                                      )
                                      .toList(),
                                ),
                              // Scrollable rows
                              Expanded(
                                child:
                                    (scrollConfig.smoothScrolling
                                    ? TrinaSmoothListView.builder
                                    : ListView.builder)(
                                      cacheExtent: stateManager.rowsCacheExtent,
                                      controller: _verticalScroll,
                                      scrollDirection: Axis.vertical,
                                      physics: const ClampingScrollPhysics(),
                                      itemCount: _scrollableRows.length,
                                      itemExtent:
                                          stateManager.rowWrapper != null
                                          ? null
                                          : stateManager.rowTotalHeight,
                                      addRepaintBoundaries: false,
                                      itemBuilder: (ctx, i) => _buildRow(
                                        context,
                                        _scrollableRows[i],
                                        i + _frozenTopRows.length,
                                      ),
                                    ),
                              ),
                              // Frozen bottom rows
                              if (_frozenBottomRows.isNotEmpty)
                                Column(
                                  children: _frozenBottomRows
                                      .asMap()
                                      .entries
                                      .map(
                                        (e) => _buildRow(
                                          context,
                                          e.value,
                                          e.key +
                                              _frozenTopRows.length +
                                              _scrollableRows.length,
                                        ),
                                      )
                                      .toList(),
                                ),
                            ],
                          ),
                        ),
                      ),
                ),

                // Fake vertical scrollbar
                if (scrollConfig.showVertical)
                  LayoutBuilder(
                    builder: (context, constraints) {
                      return TrinaVerticalScrollBar(
                        stateManager: stateManager,
                        verticalScrollExtentNotifier:
                            _verticalScrollExtentNotifier,
                        verticalViewportExtentNotifier:
                            _verticalViewportExtentNotifier,
                        verticalScrollOffsetNotifier:
                            _verticalScrollOffsetNotifier,
                        context: context,
                        height: constraints.maxHeight,
                      );
                    },
                  ),
              ],
            ),
          ),

          // Fake horizontal scrollbar
          if (scrollConfig.showHorizontal)
            LayoutBuilder(
              builder: (context, constraints) {
                return TrinaHorizontalScrollBar(
                  stateManager: stateManager,
                  horizontalScrollExtentNotifier:
                      _horizontalScrollExtentNotifier,
                  horizontalViewportExtentNotifier:
                      _horizontalViewportExtentNotifier,
                  horizontalScrollOffsetNotifier:
                      _horizontalScrollOffsetNotifier,
                  context: context,
                  width: constraints.maxWidth,
                );
              },
            ),
        ],
      ),
    );
  }
}

class ListResizeDelegate extends SingleChildLayoutDelegate {
  TrinaGridStateManager stateManager;

  List<TrinaColumn> columns;

  ListResizeDelegate(this.stateManager, this.columns)
    : super(relayout: stateManager.resizingChangeNotifier);

  @override
  bool shouldRelayout(covariant SingleChildLayoutDelegate oldDelegate) {
    return true;
  }

  double _getWidth() {
    return columns.fold(
      0,
      (previousValue, element) => previousValue + element.width,
    );
  }

  @override
  Size getSize(BoxConstraints constraints) {
    return constraints.tighten(width: _getWidth()).biggest;
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    return const Offset(0, 0);
  }

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    return constraints.tighten(width: _getWidth());
  }
}
