import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:trina_grid/trina_grid.dart';

import 'ui.dart';

class TrinaBodyColumnsFooter extends TrinaStatefulWidget {
  final TrinaGridStateManager stateManager;

  const TrinaBodyColumnsFooter(
    this.stateManager, {
    super.key,
  });

  @override
  TrinaBodyColumnsFooterState createState() => TrinaBodyColumnsFooterState();
}

class TrinaBodyColumnsFooterState
    extends TrinaStateWithChange<TrinaBodyColumnsFooter> {
  List<TrinaColumn> _columns = [];

  int _itemCount = 0;

  late final ScrollController _scroll;

  // Track the end padding needed to account for vertical scrollbar
  double _verticalScrollbarWidth = 0;

  @override
  TrinaGridStateManager get stateManager => widget.stateManager;

  @override
  void initState() {
    super.initState();

    _scroll = stateManager.scroll.horizontal!.addAndGet();

    // Calculate vertical scrollbar width when needed
    _updateVerticalScrollbarWidth();

    // Listen for configuration changes that might affect scrollbar visibility
    stateManager.addListener(_handleConfigChange);

    updateState(TrinaNotifierEventForceUpdate.instance);
  }

  void _handleConfigChange() {
    _updateVerticalScrollbarWidth();
  }

  void _updateVerticalScrollbarWidth() {
    final scrollConfig = stateManager.configuration.scrollbar;
    // Only account for vertical scrollbar width if it's shown
    if (scrollConfig.showVertical && scrollConfig.columnShowScrollWidth) {
      _verticalScrollbarWidth = scrollConfig.thickness +
          4; // Add padding as in TrinaVerticalScrollBar
    } else {
      _verticalScrollbarWidth = 0;
    }
  }

  @override
  void dispose() {
    _scroll.dispose();
    stateManager.removeListener(_handleConfigChange);

    super.dispose();
  }

  @override
  void updateState(TrinaNotifierEvent event) {
    _columns = update<List<TrinaColumn>>(
      _columns,
      _getColumns(),
      compare: listEquals,
    );

    _itemCount = update<int>(_itemCount, _columns.length);

    // Update scrollbar width on state changes
    _updateVerticalScrollbarWidth();
  }

  List<TrinaColumn> _getColumns() {
    return stateManager.showFrozenColumn
        ? stateManager.bodyColumns
        : stateManager.columns;
  }

  TrinaVisibilityLayoutId _makeFooter(TrinaColumn e) {
    return TrinaVisibilityLayoutId(
      id: e.field,
      child: TrinaBaseColumnFooter(
        stateManager: stateManager,
        column: e,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _scroll,
      scrollDirection: Axis.horizontal,
      physics: const ClampingScrollPhysics(),
      child: Row(
        children: [
          TrinaVisibilityLayout(
            delegate: ColumnFooterLayoutDelegate(
              stateManager: stateManager,
              columns: _columns,
              textDirection: stateManager.textDirection,
            ),
            scrollController: _scroll,
            initialViewportDimension:
                MediaQuery.of(context).size.width - _verticalScrollbarWidth,
            children: _columns.map(_makeFooter).toList(growable: false),
          ),
          // Add a spacer with the same width as the vertical scrollbar
          SizedBox(width: _verticalScrollbarWidth),
        ],
      ),
    );
  }
}

class ColumnFooterLayoutDelegate extends MultiChildLayoutDelegate {
  final TrinaGridStateManager stateManager;

  final List<TrinaColumn> columns;

  final TextDirection textDirection;

  ColumnFooterLayoutDelegate({
    required this.stateManager,
    required this.columns,
    required this.textDirection,
  }) : super(relayout: stateManager.resizingChangeNotifier);

  @override
  Size getSize(BoxConstraints constraints) {
    return Size(
      columns.fold(
        0,
        (previousValue, element) => previousValue += element.width,
      ),
      stateManager.columnFooterHeight,
    );
  }

  @override
  void performLayout(Size size) {
    final isLTR = textDirection == TextDirection.ltr;
    final items = isLTR ? columns : columns.reversed;
    double dx = 0;

    for (TrinaColumn col in items) {
      var width = col.width;

      if (hasChild(col.field)) {
        var boxConstraints = BoxConstraints.tight(
          Size(width, stateManager.columnFooterHeight),
        );

        layoutChild(col.field, boxConstraints);

        positionChild(col.field, Offset(dx, 0));
      }
      dx += width;
    }
  }

  @override
  bool shouldRelayout(covariant MultiChildLayoutDelegate oldDelegate) {
    return true;
  }
}
